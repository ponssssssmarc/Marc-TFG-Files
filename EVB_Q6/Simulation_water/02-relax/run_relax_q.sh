#!/bin/bash
#SBATCH --time=20:59:00
#SBATCH --ntasks=1
#SBATCH --mem=8gb
#SBATCH --job-name=relax_water
#SBATCH --error=%J.err
#SBATCH --output=%J.err

# module load GCC/11.3.0
# alias evb="module load Anaconda3;module load GCC/11.3.0;conda activate evb"

#cp -r relax_001 $SCRATCHDIR
cd relax_001

OK="(\033[0;32m   OK   \033[0m)"
FAILED="(\033[0;31m FAILED \033[0m)"

steps=( $(ls -1v *inp | sed 's/.inp//') )
echo  $steps
#rs=$((1 + $RANDOM % 1000000))
#echo $rs
#sed -i s/987654321/$rs/ relax_001.inp

for step in ${steps[@]}
do
  echo "Running equilibration step ${step}"
  if Qdyn6 ${step}.inp > ${step}.log
  then
    echo -e "$OK"
  else 
    echo -e "$FAILED"
    echo "Check output (${step}.log) for more info."
    exit 1
  fi
done
