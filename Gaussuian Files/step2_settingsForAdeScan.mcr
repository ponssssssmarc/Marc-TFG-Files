# settings for scan_7_22
# ================================

# It is VERY IMPORTANT to use ACCURATE NOTATIONS for the settings. 
# - Examples of accurate notations are 1. (in Yanaconda this is a 1 with many trailing zeros) or 1.500000000000000000000000000 . 
# - AVOID notations like 1 or 1.5 as these give rounding errors. 
# - The resulting rounding errors results in the misplacement of ticks and the wrong scaling of the axis relative to the graph. 
# - Thus with rounding errors the graphs will give minima at the wrong spots, etc. 
# - the accurate notations are not necessary for strings (text or numbers in between ' ') 

tableToLoad = 'Combined_products_scan_reactants_scan_energies_steps_after_clean_up.tab'
sceneToLoad = 'Combined_products_scan_reactants_scan_scanSteps.sce'
nameOfMovieWithoutExtension = 'Combined_products_scan_reactants_scan_movie'

# this is to define the command to analyze the geometry that was varied in the scans
commandToAnalyzeGeometry = 'DISTANCE 1, 55'

# how to label the Y- and X-axis with units
labelForYaxis = 'energy \n[kj/mol] '
labelForXaxis = 'Cepoxide-Owater [angstrom]'

# the entries for the ticks, last is not used as tick but as maximum for graph
# IMPORTANT, insufficient accuracy here gives mispositioning of labels!
ticksForYaxis() = 50.,100.,150.
ticksForXaxis() = 1., 2.,3.,4.

# minima and maxima for the axes
maximumOfYaxis = 155.
maximumOfXaxis = 4.

# STILL TO BE IMPLEMENTED, REQUIRES CHANGES THROUGHOUT THE SCRIPT
minimumOfYaxis = 0. # NOT YET IMPLEMENTED, TRHOUGHOUT SCRIPT ASSUMED TO BE ZERO   
minimumOfXaxis = 0.

# possible to move the arrow in the opposite direction during the movie
loopBackward = 'No'

# should the indicator arrow take short pauses, where, of how many seconds.
# these will be followed in sequence, if the first condition is not encountered yet it will not try the other conditions. 
takePauseAtCertainPositions = 'Yes'
takePauseAtCertainPositionsAt()               = 'rev_1','frw_1'
takePauseAtCertainPositionsOfHowManySeconds() =   1    , 1

