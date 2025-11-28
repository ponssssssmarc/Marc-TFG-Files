from pymol import cmd
import csv

def calcula_distancies_hbond(output_csv="distancies_HBonds.csv", max_dist=4.0):
    print("Calculant distàncies H–O, H–N, H–F...")

    # Definim les seleccions bàsiques
    hidrogens = "elem H"
    acceptors = "elem O or elem N or elem F"

    # Obtenim llistes d’àtoms
    h_atoms = cmd.get_model(hidrogens).atom
    acc_atoms = cmd.get_model(acceptors).atom

    dades = []

    # Comparació doble H - (O, N, F)
    for h in h_atoms:
        sel_h = f"index {h.index}"

        for a in acc_atoms:
            # Evitar que sigui el mateix àtom (redundant per H)
            if h.index == a.index:
                continue

            sel_a = f"index {a.index}"

            # Calcular distància
            d = cmd.get_distance(sel_h, sel_a)

            if d <= max_dist:
                dades.append([
                    h.name, h.resn, h.resi, h.chain,
                    a.name, a.resn, a.resi, a.chain,
                    round(d, 3)
                ])
                print(f"H-bond: {h.name}({h.resn}{h.resi}) – "
                      f"{a.name}({a.resn}{a.resi}) = {d:.3f} Å")

    # Escriure CSV
    with open(output_csv, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            "H_name","H_res","H_resi","H_chain",
            "Acc_name","Acc_res","Acc_resi","Acc_chain",
            "Dist (Å)"
        ])
        writer.writerows(dades)

    print(f"\nFitxer CSV generat: {output_csv}")
    print(f"Total de contactes trobats: {len(dades)}")


# Comando PyMOL
cmd.extend("calcula_distancies_hbond", calcula_distancies_hbond)

