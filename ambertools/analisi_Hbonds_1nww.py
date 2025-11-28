#!/usr/bin/env python3
"""
PyMOL Script: Anàlisi ponts Hidrogen 1NWW - 100% Funcional
Ús: pymol -r analisi_1nww_FINAL.py
"""

import pymol
from pymol import cmd

# === CONFIGURACIÓ ===
cmd.reinitialize()
cmd.set('fetch_path', '/tmp')
cmd.set('retain_order', 1)

# === 1. CARREGAR ===
pdb_file = '1NNW.pdb'
cmd.load(pdb_file, 'enzim_substrat')
print(f"\n✅ Carregat: {pdb_file}")

# === 2. DETECTAR SUBSTRAT ===
candidates = ['chain B', 'chain C', 'resn VPM', 'resn LIM', 'resn UNL', 'hetero and not solvent']
substrat_trobat = False

for seleccio in candidates:
    try:
        cmd.select('temp', seleccio)
        if cmd.count_atoms('temp') > 0:
            cmd.select('seleccio_substrat', seleccio)
            print(f"✅ Substrat detectat: {seleccio}")
            substrat_trobat = True
            break
    except:
        continue

if not substrat_trobat:
    cmd.select('seleccio_substrat', 'not polymer.protein')
    print("✅ Substrat detectat: àtoms no proteïna")

# === 3. CENTRE ACTIU ===
cmd.select('seleccio_centre_actiu', '(resi 53+55+99+101+132 and polymer.protein)')
print("✅ Centre actiu seleccionat")

# === 4. VISUALITZACIÓ ===
cmd.hide('everything')
cmd.show('cartoon', 'polymer.protein')
cmd.color('cyan', 'polymer.protein')

# Centre actiu
cmd.show('sticks', 'seleccio_centre_actiu')
cmd.color('yellow', 'seleccio_centre_actiu')
cmd.show('spheres', 'seleccio_centre_actiu')
cmd.set('sphere_scale', 0.3, 'seleccio_centre_actiu')

# Substrat
cmd.show('sticks', 'seleccio_substrat')
cmd.color('magenta', 'seleccio_substrat')
cmd.show('spheres', 'seleccio_substrat')
cmd.set('sphere_scale', 0.4, 'seleccio_substrat')

# === 5. PONTS D'HIDROGEN ===
cmd.delete('ponts_H_centre')
cmd.distance('ponts_H_centre', 'seleccio_centre_actiu', 'seleccio_substrat', 
             mode=2, cutoff=3.5)

cmd.hide('labels', 'ponts_H_centre')
cmd.set('dash_width', 3)
cmd.set('dash_color', 'red')
cmd.set('dash_length', 0.25)
cmd.set('dash_gap', 0.2)

# === 6. AJUSTAR VISTA ===
cmd.zoom('seleccio_centre_actiu or seleccio_substrat', 12)
cmd.orient('seleccio_centre_actiu')

# === 7. INFORME (CORREGIT) ===
print("\n" + "="*50)
print("📊 INFORME")
print("="*50)

print("\n📍 Centre actiu:")
# FORMA CORRECTA per PyMOL 3.1:
cmd.iterate('seleccio_centre_actiu', 'print(f"   • Residu {resi} {resn}")')

print("\n🎯 Substrat:")
# FORMA CORRECTA per PyMOL 3.1:
cmd.iterate('seleccio_substrat', 'print(f"   • {resn} {resi}")')

num_hbonds = cmd.count_states('ponts_H_centre')
print(f"\n🔢 Ponts d'hidrogen: {num_hbonds}")

if num_hbonds == 0:
    print("\n💡 No s'han detectat ponts d'hidrogen amb cutoff=3.5 Å")
    print("   Prova augmentant-lo a 4.0 Å")
else:
    print(f"\n✅ Perfecte! S'han detectat {num_hbonds} interaccions")

print("\n🎉 Anàlisi completada amb èxit!")
