#!/bin/bash -l

#!/bin/bash -l

#!/bin/bash
#SBATCH --time=150:59:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=8gb
## #SBATCH --job-name=equilibration
#SBATCH --partition=regular

##SBATCH --job-name=equil
##SBATCH -A snic2022-3-2
##SBATCH --time=20:00:00
##SBATCH -n 1
##SBATCH -c 16
##SBATCH --gpus-per-task=1


export GMX_BIN=/cvmfs/hpc.rug.nl/versions/2023.01/rocky8/x86_64/amd/zen3/software/GROMACS/2021.6-foss-2022a-CUDA-11.7.0/bin/gmx

echo "Host: $(hostname)"
echo "Tmpdir: $RUNDIR"

# copy files to scratch dir

echo "Time: $(date)" > run.log
start_time=$(date +%s)
echo -n "I'm working in this directory:" >> run.log
echo "   $PWD" >> run.log

echo >> run.log
echo "Steps:" >>  run.log				     
steps=$(ls -1v fep_*.mdp | sed 's/.mdp//')  
echo "${steps[@]}" >> run.log
echo >> run.log
equil='restart'
start_str='equil_11_300k_npt.gro'
restraints='STBO_ion.pdb'
prev='restart'

echo -n "Time: $(date)     " >> run.log
echo -n "Running the step: restart    --    " >> run.log
${GMX_BIN} grompp -f ${equil}.mdp -c ${start_str} -p topol_000.top -o ${equil}.tpr -r ${restraints} -maxwarn 1
if time ${GMX_BIN} mdrun -deffnm ${equil} -table table.xvg -tableb table_b0.xvg -c ${equil}.gro -pin on -ntmpi 1 -ntomp 16; then
  echo "OK" >> run.log
else
  echo "FAILED" >> run.log
  echo >> run.log
	  echo "Time: $(date)" >> run.log
	fi

for j in {000..050}; do
  step=fep_${j}
  top=topol_${j}
  echo -n "Time: $(date)     " >> run.log
  echo -n "Running the step: ${step}    --    " >> run.log
  ${GMX_BIN} grompp -f ${step}.mdp -c ${prev}.gro -p ${top}.top -o ${step}.tpr -t ${prev}.cpt -maxwarn 1
  if time ${GMX_BIN} mdrun -deffnm ${step} -table table.xvg -tableb table_b0.xvg -c ${step}.gro -pin on -ntmpi 1 -ntomp 16; then
    echo "OK" >> run.log
  else
    echo "FAILED" >> run.log
    echo >> run.log
    echo "Time: $(date)" >> run.log
    break
  fi
  prev=${step}
done

echo >> run.log
echo "Normal termination" >> run.log
echo "Time: $(date)" >> run.log
stop_time=$(date +%s)
echo "Total time: $((stop_time-start_time)) seconds" >> run.log

## cleanup
echo "Done"

