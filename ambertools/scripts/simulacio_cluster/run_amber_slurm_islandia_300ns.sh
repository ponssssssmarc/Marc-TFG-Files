#!/bin/bash
#SBATCH -J marc
#SBATCH -e messages/messages.err.txt
#SBATCH -o messages/messages.out.txt
#SBATCH -p gpu-long
#SBATCH --hint=nomultithread
set -euo pipefail
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
ml use /hpcapps/lib-bio/modules/all
ml load Amber
pmemd --version
/hpcapps/source/a/Amber/test/amber24/bin/pmemd.cuda_SPFP --version
date
pwd
echo $PATH
echo "about to start working"
amber="/hpcapps/source/a/Amber/test/amber24/bin/pmemd.cuda_SPFP"
RESULTS="$PWD/results_10ns"
mkdir -p "$RESULTS"

# MINIMIZATION
${amber} -O \
  -i min.in \
  -o "$RESULTS/min.out" \
  -p 1NNW.prmtop \
  -c 1NNW.inpcrd \
  -r "$RESULTS/min.rst" \
  -ref 1NNW.inpcrd \
  -inf "$RESULTS/min.mdinfo"

# HEATING
${amber} -O \
  -i heat.in \
  -o "$RESULTS/heat.out" \
  -p 1NNW.prmtop \
  -c "$RESULTS/min.rst" \
  -r "$RESULTS/heat.rst" \
  -x "$RESULTS/heat.nc" \
  -ref "$RESULTS/min.rst" \
  -inf "$RESULTS/heat.mdinfo"

# EQUILIBRATION
${amber} -O \
  -i equil.in \
  -o "$RESULTS/equil.out" \
  -p 1NNW.prmtop \
  -c "$RESULTS/heat.rst" \
  -r "$RESULTS/equil.rst" \
  -x "$RESULTS/equil.nc" \
  -ref "$RESULTS/heat.rst" \
  -inf "$RESULTS/equil.mdinfo"

# PRODUCTION (300 ns)
${amber} -O \
  -i prod_300ns.in \
  -o "$RESULTS/prod_10ns_300ns.out" \
  -p 1NNW.prmtop \
  -c "$RESULTS/equil.rst" \
  -r "$RESULTS/prod_300ns.rst" \
  -x "$RESULTS/prod_300ns.nc" \
  -inf "$RESULTS/prod_300ns.mdinfo"
