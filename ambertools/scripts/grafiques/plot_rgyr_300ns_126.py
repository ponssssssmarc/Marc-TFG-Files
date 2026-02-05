import csv
import os
import matplotlib.pyplot as plt

time = []
rgyr = []

with open("rgyr_300ns_126.dat") as f:
    for line in f:
        if line.startswith("#"):
            continue
        cols = line.split()
        if len(cols) < 2:
            continue
        time.append(float(cols[0]))
        rgyr.append(float(cols[1]))

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
    x = [t * dt * ntwx for t in time]
    xlabel = "Temps (ps)"
else:
    x = [t * dt * ntwx / 1000.0 for t in time]
    xlabel = "Temps (ns)"

plt.figure(figsize=(9, 5))
plt.plot(x, rgyr, linewidth=2)
plt.xlabel(xlabel)
plt.ylabel("Radius of Gyration (Å)")
plt.title("Radi de gir - 300 ns, 126")
plt.grid()
plt.tight_layout()
plt.savefig("rgyr_300ns_126.png", dpi=300)
plt.close()
