#!/bin/bash
#SBATCH --job-name=amber_md_10ns
#SBATCH --output=amber_full_md_10ns.out
#SBATCH --error=amber_full_md_10ns.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=normal1
#SBATCH --mem=25G
#SBATCH --time=120:00:00

set -euo pipefail

cd "${SLURM_SUBMIT_DIR:-$PWD}"
echo "JOB PWD=$(pwd)"

export AMBERHOME=/home/10033023/software/pmemd24
export PATH="$AMBERHOME/bin:$PATH"
PMEMD="$AMBERHOME/bin/pmemd"

RESULTS="$HOME/results"
mkdir -p "$RESULTS"


# MINIMIZATION
$PMEMD -O \
  -i min.in \
  -o "$RESULTS/min.out" \
  -p 1NNW.prmtop \
  -c 1NNW.inpcrd \
  -r "$RESULTS/min.rst" \
  -ref 1NNW.inpcrd \
  -inf "$RESULTS/min.mdinfo"

# HEATING
$PMEMD -O \
  -i heat.in \
  -o "$RESULTS/heat.out" \
  -p 1NNW.prmtop \
  -c "$RESULTS/min.rst" \
  -r "$RESULTS/heat.rst" \
  -x "$RESULTS/heat.nc" \
  -ref "$RESULTS/min.rst" \
  -inf "$RESULTS/heat.mdinfo"

# EQUILIBRATION
$PMEMD -O \
  -i equil.in \
  -o "$RESULTS/equil.out" \
  -p 1NNW.prmtop \
  -c "$RESULTS/heat.rst" \
  -r "$RESULTS/equil.rst" \
  -x "$RESULTS/equil.nc" \
  -ref "$RESULTS/heat.rst" \
  -inf "$RESULTS/equil.mdinfo"

# PRODUCTION (10 ns)
$PMEMD -O \
  -i prod_10ns.in \
  -o "$RESULTS/prod_10ns.out" \
  -p 1NNW.prmtop \
  -c "$RESULTS/equil.rst" \
  -r "$RESULTS/prod_10ns.rst" \
  -x "$RESULTS/prod_10ns.nc" \
  -inf "$RESULTS/prod_10ns.mdinfo"
