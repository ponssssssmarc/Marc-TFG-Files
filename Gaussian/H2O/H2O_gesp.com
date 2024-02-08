%chk=H2O_gesp
#HF/6-31G* scrf=smd SCF=tight Test Pop=MK iop(6/33=2) iop(6/42=6)
# iop(6/50=1)

calc RESP charges

0  1
  O    0.000000    0.116620    0.000000
  H    0.751055   -0.466480    0.000000
  H   -0.751055   -0.466480   -0.000000

g09.gesp

g09.gesp
