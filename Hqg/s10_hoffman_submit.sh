#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -j y
#$ -N Hqg_s10
#$ -o s10_hoffman_production.log
#$ -q campus2.q,pod_smp.q,inter_smp.q
#$ -pe shared 7
#$ -l h_rt=04:00:00,h_data=6G,ma=1,ms=6

set -euo pipefail

export LC_ALL=C
export LANG=C

source /u/local/Modules/default/init/modules.sh
module load mathematica

cluster_directory="${HOME}/Hqg_s10"
cd "${cluster_directory}"

kernel_command="$(command -v WolframKernel || true)"
if [[ -z "${kernel_command}" ]]; then
  kernel_command="$(command -v math)"
fi

export HQG_WOLFRAM_KERNEL="${kernel_command}"
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

exec "${HQG_WOLFRAM_KERNEL}" -noinit -noprompt -script \
  s10_complete_virtual_endpoints_hqg.wl
