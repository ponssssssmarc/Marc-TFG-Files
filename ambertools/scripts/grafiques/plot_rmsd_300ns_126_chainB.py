import csv
import os
import matplotlib.pyplot as plt

frames = []
rmsd = []

with open("rmsd_300ns_126_chainB.dat") as f:
    for line in f:
        if line.startswith("#"):
            continue
        cols = line.split()
        if len(cols) < 2:
            continue
        frames.append(float(cols[0]))
        rmsd.append(float(cols[1]))

# Time conversion: set dt (ps) and ntwx (steps per frame) to your simulation values
# If you have csv_energies/dt.csv, we try to read dt from it as a fallback.
dt = 0.002  # ps
ntwx = 5000

dt_path = os.path.join("csv_energies", "dt.csv")
if os.path.exists(dt_path):
    try:
        last_val = None
        with open(dt_path, newline="") as f:
            reader = csv.reader(f)
            for row in reader:
                if not row:
                    continue
                candidate = row[1] if len(row) >= 2 else row[0]
                try:
                    last_val = float(candidate)
                except ValueError:
                    continue
        if last_val is not None:
            dt = last_val
    except Exception:
        pass

# Choose time unit for x-axis: 'ns' or 'ps'
time_unit = "ns"
if time_unit == "ps":
    time = [f * dt * ntwx for f in frames]
    xlabel = "Temps (ps)"
else:
    time = [f * dt * ntwx / 1000.0 for f in frames]
    xlabel = "Temps (ns)"

plt.figure(figsize=(9, 5))
plt.plot(time, rmsd, linewidth=2)
plt.xlabel(xlabel)
plt.ylabel("RMSD (Å)")
plt.title("RMSD cadena B (146-291, CA)")
plt.grid()
plt.tight_layout()
plt.savefig("rmsd_300ns_126_chainB.png", dpi=300)
plt.close()
