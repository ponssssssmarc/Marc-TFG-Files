import matplotlib.pyplot as plt

residues = []
rmsf = []

with open("rmsf_300ns.dat") as f:
    for line in f:
        if line.startswith("#"):
            continue
        cols = line.split()
        if len(cols) < 2:
            continue
        residues.append(float(cols[0]))
        rmsf.append(float(cols[1]))

plt.figure(figsize=(12, 4))
plt.plot(residues, rmsf, linewidth=2)
plt.xlabel("Residue Number")
plt.ylabel("RMSF (Å)")
plt.title("RMSF dels residus (CA) - 300 ns")
plt.grid()
plt.tight_layout()
plt.savefig("rmsf_300ns.png", dpi=300)
plt.close()
