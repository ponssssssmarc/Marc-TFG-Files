# EVB for epoxy hydrolysis

## GROMACS SIMULATION USING EMPIRICAL VALENCE BOND
Files for the attempted simulation can be found in the "EVB-GROMACS" directory. The Gaussian files used for this are in the directory "Gaussian".
This a GROMACS simulation using the Emperical Valence Bond for the hydrolysis of cis-Stilbene oxide with Limonene Epoxide Hydroxylase(LEH)
The simulation protocol was inspired by that carried out by Gabriel Onca et al., 2023 (https://doi.org/10.1021/acs.jctc.3c00714). The supporting files and tools he used during his simulation can be found in https://github.com/gabrieloanca/ JCTC_2023.git and https://github.com/gabrieloanca/gmxtools.git. The supporting document for his simulation is found at https://pubs.acs.org/doi/suppl/10.1021/acs.jctc.3c00714/suppl_file/ct3c00714_si_001.pdf.
The protocol implemented in this exercise can be found in the folder "supporting_document".
The softwares used were: Avogadro, Gaussian, Maestro, AmberTools and GROMACS (See "supporting_document" for installation guide)
The sub-folders present in 'Gaussian' contain relevant data from the calculations  performed for the reactants (Aspartate101(ASH101),cis-Stilbene oxide(STO), Water molecule(H2O)) and the products (RRDiol or SSDiol), Deprotonated Aspartate(ASP101), Protonated Aspartate132 (ASH132)). Each sub-folder contains the gaussian output files (.log files), ffld_server parameters (.ffld files) and the RESP charges (.ac files) which were used as input to ffld2gmx.py tool which generates GROMACS parameters in OPLS-AA format (.opls files)
# EMPIRICAL VALENCE BOND SIMULATION WITH Q6

The simulation files are located in the "EVB-Q6" directory, while the Gaussian files used for determining the transition state in the system (Quantum cluster calculation) can be found in the "QM-Files" directory. The software used for the EVB simulation was Q ([version Q6](https://github.com/JordiVillaFreixa/Q6) fork).
