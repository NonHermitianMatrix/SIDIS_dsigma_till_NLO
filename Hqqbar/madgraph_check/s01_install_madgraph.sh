#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
download_dir="${script_dir}/downloads"
software_dir="${script_dir}/software"
archive_name="MG5_aMC_v3.7.0.tar.gz"
archive_path="${download_dir}/${archive_name}"
archive_url="https://launchpad.net/mg5amcnlo/3.0/3.6.x/+download/${archive_name}"
expected_md5="3ab9ce59816ad491742c1c927bf923c3"
six_wheel_name="six-1.17.0-py2.py3-none-any.whl"
six_wheel_path="${download_dir}/${six_wheel_name}"
six_wheel_url="https://files.pythonhosted.org/packages/b7/ce/149a00dd41f10bc29e5921b496af8b574d8413afcd5e30dfa0ed46c2cc5e/${six_wheel_name}"
expected_six_sha256="4721f391ed90541fddacab5acf947aa0d3dc7d27b2e1e8eda2be8970586c3274"
python_deps_dir="${script_dir}/python_deps"
manifest_path="${script_dir}/s01_install_manifest.txt"

mkdir -p -- "${download_dir}" "${software_dir}"

if [[ ! -f "${archive_path}" ]]; then
  temporary_archive="${archive_path}.tmp.$$"
  trap 'rm -f -- "${temporary_archive:-}"' EXIT
  curl -L --fail --retry 3 --retry-delay 2 \
    --output "${temporary_archive}" "${archive_url}"
  actual_temporary_md5=$(md5sum -- "${temporary_archive}" | awk '{print $1}')
  if [[ "${actual_temporary_md5}" != "${expected_md5}" ]]; then
    printf 'FATAL: downloaded archive MD5 mismatch: expected %s, got %s\n' \
      "${expected_md5}" "${actual_temporary_md5}" >&2
    exit 1
  fi
  mv -- "${temporary_archive}" "${archive_path}"
  trap - EXIT
fi

actual_md5=$(md5sum -- "${archive_path}" | awk '{print $1}')
if [[ "${actual_md5}" != "${expected_md5}" ]]; then
  printf 'FATAL: archive MD5 mismatch: expected %s, got %s\n' \
    "${expected_md5}" "${actual_md5}" >&2
  exit 1
fi

if [[ ! -f "${six_wheel_path}" ]]; then
  temporary_six_wheel="${six_wheel_path}.tmp.$$"
  trap 'rm -f -- "${temporary_six_wheel:-}"' EXIT
  curl -L --fail --retry 3 --retry-delay 2 \
    --output "${temporary_six_wheel}" "${six_wheel_url}"
  actual_temporary_six_sha256=$(
    sha256sum -- "${temporary_six_wheel}" | awk '{print $1}'
  )
  if [[ "${actual_temporary_six_sha256}" != "${expected_six_sha256}" ]]; then
    printf 'FATAL: downloaded six wheel SHA-256 mismatch: expected %s, got %s\n' \
      "${expected_six_sha256}" "${actual_temporary_six_sha256}" >&2
    exit 1
  fi
  mv -- "${temporary_six_wheel}" "${six_wheel_path}"
  trap - EXIT
fi

actual_six_sha256=$(sha256sum -- "${six_wheel_path}" | awk '{print $1}')
if [[ "${actual_six_sha256}" != "${expected_six_sha256}" ]]; then
  printf 'FATAL: six wheel SHA-256 mismatch: expected %s, got %s\n' \
    "${expected_six_sha256}" "${actual_six_sha256}" >&2
  exit 1
fi

if ! PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="${python_deps_dir}" \
    python3 -c 'import six; assert six.__version__ == "1.17.0"' 2>/dev/null; then
  mkdir -p -- "${python_deps_dir}"
  python3 -m pip install --no-index --no-deps --no-cache-dir --no-compile \
    --disable-pip-version-check \
    --target "${python_deps_dir}" "${six_wheel_path}"
fi

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="${python_deps_dir}" \
  python3 -c 'import six; assert six.__version__ == "1.17.0"'

mapfile -t archive_roots < <(
  tar -tzf "${archive_path}" |
    awk -F/ 'NF > 1 && $1 != "." && $1 != "" {print $1}' |
    sort -u
)
if [[ ${#archive_roots[@]} -ne 1 ]]; then
  printf 'FATAL: expected one archive root, found %s\n' \
    "${#archive_roots[@]}" >&2
  exit 1
fi

install_dir="${software_dir}/${archive_roots[0]}"
if [[ ! -d "${install_dir}" ]]; then
  tar -xzf "${archive_path}" -C "${software_dir}"
fi

if [[ ! -x "${install_dir}/bin/mg5_aMC" ]]; then
  printf 'FATAL: MadGraph entry point missing after extraction: %s\n' \
    "${install_dir}/bin/mg5_aMC" >&2
  exit 1
fi

temporary_manifest="${manifest_path}.tmp.$$"
trap 'rm -f -- "${temporary_manifest:-}"' EXIT
{
  printf 'archive_url=%s\n' "${archive_url}"
  printf 'archive_path=%s\n' "${archive_path}"
  printf 'archive_md5=%s\n' "${actual_md5}"
  printf 'archive_sha256=%s\n' \
    "$(sha256sum -- "${archive_path}" | awk '{print $1}')"
  printf 'archive_root=%s\n' "${archive_roots[0]}"
  printf 'install_dir=%s\n' "${install_dir}"
  printf 'six_wheel_url=%s\n' "${six_wheel_url}"
  printf 'six_wheel_sha256=%s\n' "${actual_six_sha256}"
  printf 'python_deps_dir=%s\n' "${python_deps_dir}"
  printf 'six_version=1.17.0\n'
  printf 'python=%s\n' "$(python3 --version 2>&1)"
  printf 'gcc=%s\n' "$(gcc --version | head -n 1)"
  printf 'gfortran=%s\n' "$(gfortran --version | head -n 1)"
  printf 'make=%s\n' "$(make --version | head -n 1)"
} > "${temporary_manifest}"
mv -- "${temporary_manifest}" "${manifest_path}"
trap - EXIT

printf 'HQQBAR_MADGRAPH_S01_SUCCESS\n'
printf 'MADGRAPH_INSTALL_DIR=%s\n' "${install_dir}"
printf 'MADGRAPH_ARCHIVE_MD5=%s\n' "${actual_md5}"
printf 'MADGRAPH_SIX_SHA256=%s\n' "${actual_six_sha256}"
