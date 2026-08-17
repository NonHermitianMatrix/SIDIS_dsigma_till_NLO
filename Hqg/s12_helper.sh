#!/usr/bin/env bash

set -uo pipefail

script_directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
project_directory=$(cd -- "${script_directory}/../.." && pwd)
source_path="${script_directory}/s12_combine_factorization_hqg.wl"
production_log="${script_directory}/s12_v4_s10v4_production.log"
kernel_path="/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel"
lock_directory="${script_directory}/.s12_helper_lock"

memory_limit_kib=12582912
minimum_available_memory_kib=1572864
epoch_timeout_seconds=7200
kill_grace_seconds=60
attachment_poll_seconds=5
attachment_inactivity_seconds=2100
resume_interrupted=false

if [[ "${1-}" == "--resume-interrupted" ]]; then
  resume_interrupted=true
  shift
fi
if (( $# != 0 )); then
  echo "S12_HELPER_STOP: usage: s12_helper.sh [--resume-interrupted]"
  exit 2
fi

if ! mkdir -- "${lock_directory}" 2>/dev/null; then
  echo "S12_HELPER_STOP: another s12_helper instance holds ${lock_directory}"
  exit 2
fi

cleanup_lock() {
  rmdir -- "${lock_directory}" 2>/dev/null || true
}
trap cleanup_lock EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

latest_epoch_state() {
  local start_record terminal_record start_line terminal_line terminal_text

  if [[ ! -f "${production_log}" ]]; then
    echo "missing-log"
    return
  fi

  start_record=$(grep -nF \
    'S12_STAGE: validating S10, S11, paper, and BigTMD bindings' \
    "${production_log}" | tail -n 1)
  terminal_record=$(grep -nE \
    'S12_MEMORY_EPOCH_PAUSE|S12_SUCCESS_FINITE_FACTORIZED_HQG|S12_FATAL:' \
    "${production_log}" | tail -n 1)

  if [[ -z "${start_record}" ]]; then
    echo "missing-start"
    return
  fi
  if [[ -z "${terminal_record}" ]]; then
    echo "incomplete"
    return
  fi

  start_line=${start_record%%:*}
  terminal_line=${terminal_record%%:*}
  terminal_text=${terminal_record#*:}
  if (( terminal_line <= start_line )); then
    echo "incomplete"
  elif [[ "${terminal_text}" == *S12_SUCCESS_FINITE_FACTORIZED_HQG* ]]; then
    echo "success"
  elif [[ "${terminal_text}" == *S12_FATAL:* ]]; then
    echo "fatal"
  elif [[ "${terminal_text}" == *S12_MEMORY_EPOCH_PAUSE* ]]; then
    echo "pause"
  else
    echo "unknown"
  fi
}

wait_for_attached_epoch() {
  local state log_size new_log_size last_activity now

  state=$(latest_epoch_state)
  case "${state}" in
    pause)
      echo "S12_HELPER_RESTART: latest epoch is at a designed memory pause"
      sleep 5
      return 0
      ;;
    success)
      echo "S12_HELPER_COMPLETE: latest epoch reached symbolic success"
      exit 0
      ;;
    fatal)
      echo "S12_HELPER_STOP: latest epoch emitted S12_FATAL"
      exit 1
      ;;
    incomplete)
      if [[ "${resume_interrupted}" == true ]]; then
        echo "S12_HELPER_RESUME: explicitly resuming a user-interrupted epoch"
        return 0
      fi
      ;;
    *)
      echo "S12_HELPER_STOP: cannot attach to latest epoch state ${state}"
      exit 1
      ;;
  esac

  log_size=$(stat -c %s -- "${production_log}" 2>/dev/null || echo 0)
  last_activity=$(date +%s)
  echo "S12_HELPER_ATTACH: waiting for the active log epoch terminal marker"
  while true; do
    sleep "${attachment_poll_seconds}"
    state=$(latest_epoch_state)
    case "${state}" in
      pause)
        echo "S12_HELPER_RESTART: attached log epoch reached a designed memory pause"
        sleep 5
        return 0
        ;;
      success)
        echo "S12_HELPER_COMPLETE: attached log epoch reached symbolic success"
        exit 0
        ;;
      fatal)
        echo "S12_HELPER_STOP: attached log epoch emitted S12_FATAL"
        exit 1
        ;;
      incomplete)
        ;;
      *)
        echo "S12_HELPER_STOP: attached log epoch changed to invalid state ${state}"
        exit 1
        ;;
    esac

    new_log_size=$(stat -c %s -- "${production_log}" 2>/dev/null || echo 0)
    now=$(date +%s)
    if [[ "${new_log_size}" != "${log_size}" ]]; then
      log_size=${new_log_size}
      last_activity=${now}
    elif (( now - last_activity >= attachment_inactivity_seconds )); then
      echo "S12_HELPER_STOP: attached log had no activity for ${attachment_inactivity_seconds} seconds"
      exit 1
    fi
  done
}

run_epoch() {
  local available_memory_kib epoch_status state

  available_memory_kib=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
  if [[ ! "${available_memory_kib}" =~ ^[0-9]+$ ]] ||
      (( available_memory_kib < minimum_available_memory_kib )); then
    echo "S12_HELPER_STOP: available memory is below the 1.5 GiB launch floor"
    return 1
  fi

  echo "S12_HELPER_EPOCH_START: available_memory_kib=${available_memory_kib}"
  (
    ulimit -v "${memory_limit_kib}"
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    export MKL_NUM_THREADS=1
    cd -- "${project_directory}"
    timeout --signal=TERM --kill-after="${kill_grace_seconds}s" \
      "${epoch_timeout_seconds}s" \
      "${kernel_path}" -noinit -noprompt -script "${source_path}"
  ) 2>&1 | tee -a "${production_log}"
  epoch_status=${PIPESTATUS[0]}
  state=$(latest_epoch_state)

  if (( epoch_status == 75 )) && [[ "${state}" == "pause" ]]; then
    echo "S12_HELPER_RESTART: code 75 and designed memory-pause marker confirmed"
    return 75
  fi
  if (( epoch_status == 0 )) && [[ "${state}" == "success" ]]; then
    echo "S12_HELPER_COMPLETE: S12_SUCCESS_FINITE_FACTORIZED_HQG confirmed"
    return 0
  fi
  if [[ "${state}" == "fatal" ]]; then
    echo "S12_HELPER_STOP: S12_FATAL confirmed with exit code ${epoch_status}"
  elif (( epoch_status == 124 )); then
    echo "S12_HELPER_STOP: S12 epoch reached the ${epoch_timeout_seconds}-second timeout"
  elif (( epoch_status == 137 )); then
    echo "S12_HELPER_STOP: S12 epoch was killed; possible external OOM or forced kill"
  else
    echo "S12_HELPER_STOP: exit code ${epoch_status}, terminal state ${state}"
  fi
  return 1
}

if [[ ! -f "${source_path}" ]]; then
  echo "S12_HELPER_STOP: missing source ${source_path}"
  exit 1
fi

wait_for_attached_epoch

while true; do
  run_epoch
  epoch_status=$?
  if (( epoch_status == 75 )); then
    continue
  fi
  exit "${epoch_status}"
done
