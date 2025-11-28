#!/usr/bin/env python3
"""
PyMOL Script: Anàlisi ponts Hidrogen 1NWW - Versió Final & Corregida
Ús: pymol -r analisi_1nww_FINAL.py
"""

import pymol
from pymol import cmd

# === INICI ===
cmd.reinitialize()
cmd.set('fetch_path', '/tmp')
cmd.set('retain_order', 1)

# === 1. CARREGAR PDB ===
pdb_file = '1NNW.pdb'
cmd.load(pdb_file, 'enzim_substrat')
print(f"\n✅ Carregat: {pdb_file}")

# === 2. DETECTAR SUBSTRAT INTEL·LIGENT ===
print("\n🔍 Detectant substrat específic...")

# Llista de possibles noms de residus per al ligand/substrat
# Prova en ordre de prioritat
substrat_candidates = [
    ('resn VPM', 'Valpromida (inhibidor)'),
    ('resn LIM', 'Limonè epòxid (substrat natural)'),
    ('resn LIG', 'Ligand genèric'),
    ('resn UNL', 'Molècula desconeguda'),
    ('chain B', 'Cadena B (substrat en cadena separada)'),
    ('chain C', 'Cadena C (substrat en cadena separada)'),
]

substrat_trobat = None
for seleccio, descripcio in substrat_candidates:
    try:
        cmd.select('temp_substrat', seleccio)
        num_atoms = cmd.count_atoms('temp_substrat')
        if num_atoms > 0:
            cmd.select('seleccio_substrat', seleccio)
            substrat_trobat = descripcio
            print(f"   ✅ {descripcio}: {num_atoms} àtoms")
            break
    except:
        continue

# Si encara no ha trobat res, prova heteroàtoms generals
if not substrat_trobat:
    cmd.select('seleccio_substrat', 'hetero and not solvent')
    if cmd.count_atoms('seleccio_substrat') > 0:
        substrate_trobat = "Heteroàtoms (no aigua)"
        print(f"   ✅ {substrat_trobat}: {cmd.count_atoms('seleccio_substrat')} àtoms")

# Darrer recurs: tot el que no sigui proteïna
if not substrat_trobat:
    cmd.select('seleccio_substrat', 'not polymer.protein')
    print(f"   ⚠️  Usant selectió genèrica: àtoms no proteïna")
    print(f"   💡 Si això inclou aigua/ions, revisa el PDB!")

# === 3. SELECCIONAR CENTRE ACTIU ===
cmd.select('seleccio_centre_actiu', '(resi 53+55+99+101+132 and polymer.protein)')
print("✅ Centre actiu seleccionat (residus 53,55,99,101,132)")

# === 4. VISUALITZACIÓ ===
cmd.hide('everything')
cmd.show('cartoon', 'polymer.protein')
cmd.color('cyan', 'polymer.protein')

# Centre actiu en groc
cmd.show('sticks', 'seleccio_centre_actiu')
cmd.color('yellow', 'seleccio_centre_actiu')
cmd.show('spheres', 'seleccio_centre_actiu')
cmd.set('sphere_scale', 0.3, 'seleccio_centre_actiu')

# Substrat en magenta
cmd.show('sticks', 'seleccio_substrat')
cmd.color('magenta', 'seleccio_substrat')
cmd.show('spheres', 'seleccio_substrat')
cmd.set('sphere_scale', 0.4, 'seleccio_substrat')

# === 5. PONTS D'HIDROGEN (CORREGIT PER PyMOL 3.1) ===
# Elimina selecció anterior si existeix
cmd.delete('ponts_H_centre')

# Calcula distàncies (sense argument 'angle' per compatibilitat)
cmd.distance('ponts_H_centre', 'seleccio_centre_actiu', 'seleccio_substrat', 
             mode=2, cutoff=3.5)

# Configura aparença
cmd.hide('labels', 'ponts_H_centre')
cmd.set('dash_width', 3)
cmd.set('dash_color', 'red')
cmd.set('dash_length', 0.25)
cmd.set('dash_gap', 0.2)

# === 6. AJUSTAR VISTA ===
cmd.zoom('seleccio_centre_actiu or seleccio_substrat', 12)
cmd.orient('seleccio_centre_actiu')

# === 7. INFORME (SENSE ERRORS) ===
print("\n" + "="*60)
print("📊 INFORME D'ANÀLISI")
print("="*60)

print("\n📍 Centre actiu:")
cmd.iterate('seleccio_centre_actiu', 'print(f"   • Residu {resi} {resn}")')

print("\n🎯 Substrat:")
cmd.iterate('seleccio_substrat', 'print(f"   • {resn} {resi}")')

num_hbonds = cmd.count_states('ponts_H_centre')
print(f"\n🔢 Ponts d'hidrogen detectats: {num_hbonds}")

if num_hbonds == 0:
    print("\n💡 No s'han detectat ponts d'hidrogen amb cutoff=3.5 Å")
    print("   Prova augmentant-lo a 4.0 Å o 4.5 Å si cal")
else:
    print(f"\n✅ Perfecte! S'han detectat {num_hbonds} interaccions")

print("\n🎉 Anàlisi completada amb èxit!")
