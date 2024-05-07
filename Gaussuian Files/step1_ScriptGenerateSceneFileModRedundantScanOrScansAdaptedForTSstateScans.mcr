#
# step1_ScriptGenerateSceneFileModRedundantScanOrScans.mcr  
# ===========================================================
#
# Usage
#
# yasara -txt step1_ScriptGenerateSceneFileModRedundantScanOrScans.mcr "MT = 'scan_7_22_backward'" will take scan_7_22_backward.out as inputfile
#
# yasara -txt step1_ScriptGenerateSceneFileModRedundantScanOrScans.mcr "MT_backward = 'scan_7_22_backward'" "MT_forward='scan_7_22_forward'" wil take both as input file
# 


# settings
# -------------------------------------------

#select on which type of computer (Linux or Mac) you run the scripts. The command for one step has a different variation depending on it
CurrentComputer = 'Mac'



# The actual script
CONSOLE off

# check for valid input
# --------------------------------
PRINT '\n\n\nIMPORTANT'
if count MT
  PRINT The input suggested that there is a single input file called (MT)
  PRINT '================================================================================================'
  # this is the command for the later loop that analyses the single scan
  CurrentLoop ='if 1'
  h = 0
else
  if count MT_backward
    if count MT_forward
      PRINT The input suggested that there are two input files called (MT_backward) for the backward direction and (MT_forward) for the forward scan
      PRINT '===================================================================================================================================================='
      # this is the command for the later loop that analyses the single scan
      CurrentLoop ='for h = 1 to 2'
      PRINT (CurrentLoop)

# here start the loop to open one or two files and load the results, after initializing some variables that are shared between the loop instances
lowestEnergyOfEither = 10000000000.000000000000000000000000000000000000000000000000000
counter = 0
(CurrentLoop)
  # this was the easiest to define backward and reverse scans, more subtle ways gave errors. 
  if h == 1
    MT = '(MT_forward)'
  if h == 2
    MT = '(MT_backward)'
  if h == 0
    PRINT Running a single analysis on (MT) 
  else 
    PRINT Started working on (MT)
  PRINT '----------------------------------------' 


  # this is to create a series of files with structures, possibly to be loaded later
  SHELL rm x*
  SHELL sed -n "/ Standard orientation:/,/ Rotational constant/p" (MT).out>for_split.tab
  if CurrentComputer == 'Linux'  # this works on a linux computer
    SHELL csplit for_split.tab /Rotational/ '{*}'
  elif  CurrentComputer == 'Mac'
    SHELL cat for_split.tab| split -p Rotational -a 4
  else
    PRINT "Wrong computer selection. Please select a valid option"
    EXIT
  # and this gets a list of files
  SHELL echo '' > initial_tmp.tab
  SHELL ls x* >> initial_tmp.tab
  SHELL cat initial_tmp.tab | sed 's/xx/& /'g | sort -n -k2 | sed s'/xx /xx/'g>tmp.tab
  LOADTAB tmp.tab
  listFiles() = TAB 1
  DELTAB 1
  SHELL cp tmp.tab listFiles.tab
  SHELL echo '' > tmp.tab
  SHELL wc -l x* | grep x | sed 's/[a-z]//g'>> tmp.tab
  LOADTAB tmp.tab
  listLines() = TAB 1
  DELTAB 1
  

  # this is what gets the energies out of the Gaussian output files and load them
  SHELL grep -e 'SCF Done' -e 'out of'  (MT).out| sed 's/SCF Done/?/g'| tr '\n' ' ' |tr '?' '\n'| awk '{print $4 " " $11 " " $17 "  " $21}'> (MT)_energies_steps.tab
  LOADTAB (MT)_energies_steps.tab
  rawData = ()
  rawData() = TAB 1
  numberOfRows = count rawData
  numberOfRows = (numberOfRows) / 4
  DELTAB 1
  #  load them in and at the same time decide if it is relevant or not
  currentScanPoint = 0
  for i = 1 to numberOfRows
    index = (i-1) * 4
    energyValue(i) = (rawData((index)+1))
    step(i)        = (rawData((index)+2))
    scanPoint(i)   = (rawData((index)+4))
    maxNumberOfSteps = (rawData((index)+3))
    relevant(i)    = 'Yes'
    if currentScanPoint != scanPoint(i)
      currentScanPoint = (scanPoint(i))
      #PRINT new point, previous still relevant
    else
      # if it is still the same, make the previous point irrelevant
      relevant((i)-1) = 'No'
      #PRINT declared a point irrelevant
    if maxNumberOfSteps == step(i) 
      relevant(i) = 'No'
      #PRINT declared  point (i) irrelevant because it had not converged, at step (step(i)) out of the maximum number of steps of (maxNumberOfSteps) 
  # save the results
  SHELL rm  (MT)_energies_steps_relevance.tab
  for i = 1 to numberOfRows
    TABULATE '(0.000000000000+(energyValue(i)))'
    TABULATE '(0+(scanPoint(i)))'
    TABULATE '(0+(step(i)))'
    TABULATE '(relevant(i))'
    TABULATE '(listFiles(i))'
  SAVETAB 1, (MT)_energies_steps_relevance.tab, columns=5
  DELTAB 1
  PRINT '\nIMPORTANT\nAnalysed energies and relevant steps of (MT)'

  foundFirstValue = 'No'
  highestEnergy = -10000000.000000000000000000000000
  indexHighest = 0
  for i = 1 to numberOfRows
    # as a control experiment, verify that the value should be lower than the one just before that.
    if relevant(i) == 'Yes'
      if foundFirstValue == 'No'
        foundFirstValue = 'Yes'
        refValue = (energyValue(i))
      counter = (counter) + 1
      if highestEnergy < (energyValue(i))
        indexHighest = (counter)
        highestEnergy = (energyValue(i))
      SHELL echo ' J. B. Foresman, and D. J. Fox, Gaussian, Inc., Wallingford CT, 2016.' > tmp.out
      SHELL cat (listFiles(i)) >> tmp.out
      LOADG09 tmp.out
      if h == 0
        RENAMEOBJ (counter), point_(0+(scanPoint(i))) 
      if h == 1
        RENAMEOBJ (counter), frw_(0+(scanPoint(i))) 
        finalListObjects_(counter) = 'frw_(0+(scanPoint(i)))'
      if h == 2
        RENAMEOBJ (counter), rev_(0+(scanPoint(i)))  
        finalListObjects_(counter) = 'rev_(0+(scanPoint(i)))'
      # this is to keep track of the numbers of reverse and forward scans
      maxFor(h) = (counter)
      REMOVEOBJ all
      ADDOBJ (counter)
      TABULATE '(0.000000000000+(energyValue(i)))'
      energyValuesFinal(counter) = (energyValue(i))
      if (energyValue(i)) < lowestEnergyOfEither
        lowestEnergyOfEither = (energyValue(i))      
      # and now the relative energy in kJ/mol, versus the first point
      stepKept= (scanPoint(i))
      correctedValue =  (energyValue(i)) - (refValue) 
      correctedValueKJMol = (correctedValue) * 2625.5002
      TABULATE '(0.000 +(correctedValueKJMol))'
      TABULATE '(0+(stepKept))'
    SHELL rm (listFiles(i))

  PRINT '\nIMPORTANT\n got structures of relevant steps of (MT)'
  
  string1='energy_hartree'
  string2='E_kj/mol'
  string3='step'
  # get a header string for the data
  headerString= '___'
  headerString = '(headerString)(string1)  '
  headerString = '(headerString)(string2)      '
  headerString = '(headerString)(string3)  '
  
  for j = 1 to count atomDihedralA
    headerString = '(headerString)(labelDihedrals(j))   '  
  SAVETAB 1, (MT)_energies_steps_after_clean_up.tab, columns= 3, NumFormat= 9.5f, header =(headerString)
  DELTAB 1 
  
  # get rid of stuff that was temporarily created
  SHELL rm x*
  SHELL rm tmp.tab
  SHELL rm tmp.out
  SHELL rm  for_split.tab
  SHELL initial_tmp.tab
  SHELL listFiles.tab  

ADDOBJ all

# this always works since the first one (the first from the backward scan) is also close to the first one of the forward scane
SUPATOM OBJ 2-(counter) element O , OBJ 1 element O
if h == 2
  if 0
    # before saving the scene file, do the renumbering, assume there are never more than 10,000 objects
    newCounter = 10000
    # inverse them while increasing their number
    for i = (maxFor(1)) to 1 step -1
      newCounter = (newCounter) + 1
      RENUMBEROBJ (i), (newCounter)
      energyValuesFinal(newCounter) = (energyValuesFinal(i))
      finalListObjects_(newCounter) = '(finalListObjects_(i))'
      PRINT renumbering object (i) into (newCounter)
    # renumber back, to start at 1
    for i =10001 to newCounter
      newNumber = (i) - 10000
      RENUMBEROBJ (i), (newNumber)
      finalListObjects_(newNumber) =  '(finalListObjects_(i))'
      energyValuesFinal(newNumber) = (energyValuesFinal(i))
      PRINT renumbering object (i) into (newNumber)
  SAVESCE Combined_(MT_backward)_(MT_forward)_scanSteps
  # also create a combined tab file
  # first get a combined energy in kJ/mol, this needs the reference energy for both
  for i = 1 to counter
    # energy in Hartree
    TABULATE '(0.000000000000+(energyValuesFinal(i)))'
    correctedValue =  (energyValuesfinal(i)) - (lowestEnergyOfEither)
    correctedValueKJMol = (correctedValue) * 2625.5002
    TABULATE '(0.000 +(correctedValueKJMol))'
    TABULATE '(finalListObjects_(i))'
  SAVETAB 1,  Combined_(MT_backward)_(MT_forward)_energies_steps_after_clean_up.tab, columns= 3, NumFormat= 9.5f, header =(headerString)
  DELTAB 1
if h == 0
  # just one scene, this is easy
  SAVESCE (MT)_scanSteps

PRINT '\n\nIMPORTANT\nFinished script entirely'
EXIT
