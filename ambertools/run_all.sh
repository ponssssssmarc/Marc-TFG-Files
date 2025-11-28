#!/bin/bash
# Script per executar min -> heat -> equil -> prod automàticament

# Canvia això si vols utilitzar pmemd.cuda
ENGINE="pmemd"     
# ENGINE="pmemd.cuda"   # <–– actiu si tens GPU

PRMTOP="complex.prmtop"

echo "========== MINIMIZATION =========="
$ENGINE -O -i min.in -o min.out -p $PRMTOP -c complex.inpcrd -r min.rst -ref complex.inpcrd

if [ ! -f "min.rst" ]; then
    echo "ERROR: min.rst no existeix. La minimització ha fallat."
    exit 1
fi

echo "========== HEATING =========="
$ENGINE -O -i heat.in -o heat.out -p $PRMTOP -c min.rst -r heat.rst -x heat.nc -ref min.rst

if [ ! -f "heat.rst" ]; then
    echo "ERROR: heating ha fallat."
    exit 1
fi

echo "========== EQUILIBRATION =========="
$ENGINE -O -i equil.in -o equil.out -p $PRMTOP -c heat.rst -r equil.rst -x equil.nc -ref heat.rst

if [ ! -f "equil.rst" ]; then
    echo "ERROR: equilibration ha fallat."
    exit 1
fi

echo "========== PRODUCTION =========="
$ENGINE -O -i prod.in -o prod.out -p $PRMTOP -c equil.rst -r prod.rst -x prod.nc

if [ ! -f "prod.nc" ]; then
    echo "ERROR: production ha fallat."
    exit 1
fi

echo "========== TOT COMPLET =========="
echo "🎉 Simulació finalitzada amb èxit!"
echo "Resultats:"
echo " - Trajectory: prod.nc"
echo " - Restart final: prod.rst"

