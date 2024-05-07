# 
# step2_MakeBetterGraphsWithMovingArrow.mcr
# ==================================================
#
# Hein J. Wijma, 2024-02-26
#
# this is to create a graph to illustrate where the energy is relatively with the corresponding QM structure beside it
#
# recent additions/improvments
# + better preparation layout, change to longitudinal format to better show the structures and the graph
# + start scan in the middle, at the optimal structure, rather than at an end
# + allow to take short breaks in the movie, to more easily show during a presentation what is happening at special points, give breaks in seconds
# + add information in plot on which snapshot is currently displayed (both name forward/backward)
# + plot not the step but the varied distance/angle/dihedral 
# + allow the lowest value to be plotted to be set manually
# + adapt the most commonly used parameter names to make it easier to guess what they mean
# + include the most important settings as an additional file, for easier storage and modification 
# + thoroughly tested different plotting settings in the positive range
# + added something to make sure no algorithmic errors are created due to rounding errors by input (for example 0 + 0.4 = 0 under Yanaconda, idem  1 * 0.4 = 0)
# + give more messages
# + give opportunity to look at complete plot before the movie starts
# + create a fast scan movie, where it skips most snapshots, and then immediately after the real movie, with a message

# the settings
# =====================================

# the most important things, essentially need to be adapted every time
# ----------------------------------------------------------------------

# this is in a separate file for easier handling with multiple analyses to do for multiple scans
include step2_settingsForAdeScan.mcr


# more standard settings, should rarely need to be changed
# ----------------------------------------------------------

# It is VERY IMPORTANT to use ACCURATE NOTATIONS for the settings. 
# - Examples of accurate notations are 1. (in Yanaconda this is a 1 with many trailing zeros) or 1.500000000000000000000000000 . 
# - AVOID notations like 1 or 1.5 as these give rounding errors. 
# - The resulting rounding errors results in the misplacement of ticks and the wrong scaling of the axis relative to the graph. 
# - Thus with rounding errors the graphs will give minima at the wrong spots, etc. 
# - the accurate notations are not necessary for strings (text or numbers in between ' ') 


# this is the maximum pixels size (in X-dimension for the resulting movie). This can be maximally 1920 for an mp4 movie. Making it much smaller does not make sense since the ray tracing is lighting fast with so few atoms. It is the set-up of the scene that is time consuming and that is not influenced by the number of pixels.  
# this does not require accurate notation. 
maxXdimension = 1800 

# not implemented (yet) maxYdimension = 1152 # this can be maximally 1152 for an mp4 movie

# how far the labels should be from the axis 
tickLabelOfsetYoffset   = -0.90000000
unitXOffset = -0.90000000

# origin of the axis, where it starts. X and Y go as expected. Positive values from Y go into the screen. 
Xnul = 1.  # 2.50000000000000000000000
Ynul = -0.7500000000000000  #-1.500000000000000000000
Znul = 1.

# max lenghts of the X and Y-axis, in Angstrom 
lenghtYaxisOnScreen = 3. #50000000000000000000000000
lenghtXaxisOnScreen = 5.

# ofsets for the numerical values, for placing them relative to an invisible dummy atom that is positioned at the end of the tick
tickLabelOfsetX=-0.350000000
tickLabelOfsetY=0.
tickLabelOfsetZ=-0.00000000

# the radii of the axis, the graph, and the arrow
# these do not require accurate notation either.
axisRadius = 0.005
graphRadius = 0.025
arrowRadius = 0.03
tickLength = 0.25
labelHeight = 0.2
colorLabels = 'black'
colorAxis = 'black'
colorGraph = 'black'
colorArrow = 'black'

# offset and lenght of indicator arrow 
arrowOfSet  = 0.1
arrowLength = 0.5


# the actual script
# =====================================

# some general things
# ----------------------

#for speedUp
CONSOLE off
# to make the fonts look nicer
LabelPar FONT=ARIAL
# to record how long it takes
startTime = SYSTEMTIME
# adapt the dimensions
dimensionXatStart, dimensionYatStart = SCREENSIZE
SCREENSIZE (dimensionXatStart),(dimensionXatStart/2.5)
# to prevent the user from accidentally hiding a snapshot by clicking next to the ContinueButton
HUD off


# load the scene and get the geometric information
# ---------------------------------------------------------------------
LOADSCE (sceneToLoad)
numberOfObjects = COUNTOBJ all
REMOVEOBJ all
for i = 1 to numberOfObjects
  ADDOBJ (i)
  geometryOfInterest(i) = (commandToAnalyzeGeometry)
  REMOVEOBJ (i)
ADDOBJ all

# previously scene created by superimposing on element O, better on nitrogen
SUPATOM OBJ 2-(numberOfObjects) element N , OBJ 1 element N

# allow the user to set a nice visualization of the scene file
# ---------------------------------------------------------------------
SHOWMESSAGE Please set desired orientation and visuals before addition of the graph, the graph will appear in the right 50% of the screen
WAIT ContinueButton
HIDEMESSAGE


# load the data
# -------------------------------------
LOADTAB (tableToLoad)
rawData() = TAB 1
DELTAB 1
numberOfEntries = COUNT rawData
numberOfRows    = (numberOfEntries) / 3
# also determine the lowest energy point
lowestEnergy = 10000000000.
for i = 1 to numberOfRows
  index = ((i-1) * 3) 
  energies_kJPerMol(i) = rawData((index)+2)
  if energies_kJPerMol(i) < lowestEnergy
    lowestEnergy = (energies_kJPerMol(i))
    lowestEnergyPosition = (i)
  nameOfSnapshot(i)    = rawData((index)+3)

# partially for debugging, save a table with the geometric feature
for i = 1 to numberOfRows
  TABULATE '(0.000+(geometryOfInterest(i)))'
  TABULATE '(0.000+(energies_kJPerMol(i)))'
  TABULATE '(nameOfSnapshot(i))'
SAVETAB 1,   (nameOfMovieWithoutExtension)_data.tab, Columns=3,NumFormat= 9.5f, header ='__geometry  E_kJ_mol    name'
DELTAB 1
# small check
if numberOfRows != numberOfObjects
  RAISEERROR The number of rows in (tableToLoad) is (numberOfRows) while the number of objects in (sceneToLoad) is (numberOfObjects)


# check if ticks look OK.
# -----------------------

# calculate percentage of data that will be plotted, give warning if it is not 100%
plotted = 0
notPlotted = 0
for i = 1 to numberOfRows
  thisIsPlotted = 'Yes'
  if energies_kJPerMol(i) > maximumOfYaxis
    thisIsPlotted = 'No'
  if energies_kJPerMol(i) < minimumOfYaxis
    thisIsPlotted = 'No'
  if geometryOfInterest(i) < minimumOfXaxis
    thisIsPlotted = 'No'
  if geometryOfInterest(i) > maximumOfXaxis
    thisIsPlotted = 'No'
  if thisIsPlotted == 'Yes'
    plotted = (plotted)+1
    PRINT point accepted
  else
    notPlotted = (notPlotted) + 1
    PRINT point not accepted
percentagePlotted = 100. * (plotted)/((plotted)+(notPlotted)) 
if percentagePlotted < 100
  SHOWMESSAGE Warning, only (0+(percentagePlotted)) % of the data to be plotted fits in the selected range
  WAIT ContinueButton
  HIDEMESSAGE

if 0 # this was there previously
  # check if the data are suitable to be plotted for the Y-axis
  maximumOfYaxis = max energies_kJPerMol
  if maximumOfYaxis > maximumOfYaxis 
    RAISEERROR data goes till (0.00+(maximumOfYaxis)) will not fit in plot, please adapt ticksForYaxis to be higher than (0.00+(maximumOfYaxis))
  if maximumOfYaxis*1.5 < maximumOfYaxis
    RAISEERROR Y graph much higher, namely (0.00+(maximumOfYaxis)) than the maximum of the data (0.00+(maximumOfYaxis))
  
  # check if the data are suitable to be plotted for the X-axis
  maximumOfXaxis = max geometryOfInterest
  if maximumOfXaxis > maximumOfXaxis
    RAISEERROR data goes till (0.00+(maximumOfXaxis)) will not fit in plot, please adapt ticksForXaxis to be higher than (0.00+(maximumOfXaxis))
  if maximumOfXaxis*1.5 < maximumOfXaxis
    RAISEERROR X graph much higher, namely (0.00+(maximumOfXaxis)) than the maximum of the data (0.00+(maximumOfXaxis))


# draw the Y-axis
# --------------------------------------------------------------------

axisObject = SHOWARROW Start=Point, X=(Xnul), Y=(Ynul), Z=(Znul), End=Point, X=(Xnul), Y=((Ynul)+(lenghtYaxisOnScreen)), Z=(Znul), radius=(axisRadius), heads=0,color=(colorAxis) 
# annotate it with numbers
dummyObject = BUILDATOM DU
numberOfTicks =  COUNT ticksForYaxis
for i = 1 to numberOfTicks
  # draw a tick
  heightTick = (lenghtYaxisOnScreen)*(ticksForYaxis(i)) / maximumOfYaxis
  newObject = SHOWARROW Start=Point, X=(Xnul), Y=((Ynul)+(heightTick)), Z=(Znul), End=Point, X=(-(tickLength)+(Xnul)), Y=((Ynul)+(heightTick)), Z=(Znul), radius=(axisRadius), heads=0,color=(colorGraph)
  JOINOBJ (newObject), (axisObject)
  newObject = BUILDATOM DU
  POSATOM OBJ (newObject), X=(-(tickLength)+(Xnul)), Y=((Ynul)+(heightTick)), Z=(Znul), coordsys=global
  LABELATOM OBJ (newObject), (0+(ticksForYaxis(i))), height = (labelHeight), color=(colorLabels), X=(tickLabelOfsetX), Y=0, Z=(tickLabelOfsetZ)
  JOINOBJ (newObject), (dummyObject)
HIDEATOM element Du
# and the Y-axis label
newObject = BUILDATOM DU
POSATOM OBJ (newObject), X=(-(tickLength)+(Xnul)), Y=(((lenghtYaxisOnScreen)/2)+(Ynul)), Z=(Znul), coordsys=global
LABELATOM OBJ (newObject), (labelForYaxis), height = (labelHeight), color=(colorLabels), X=((tickLabelOfsetX)+(tickLabelOfsetYoffset)), Y=(tickLabelOfsetY), Z=(tickLabelOfsetZ)
JOINOBJ (newObject), (dummyObject)
HIDEATOM element Du


# draw the X-axis
#-------------------------------------------------------
newObject = SHOWARROW Start=Point, X=(Xnul), Y=(Ynul), Z=(Znul), End=Point, X=((Xnul)+(lenghtXaxisOnScreen)), Y=(Ynul), Z=(Znul), radius=(axisRadius), heads=0,color=(colorAxis)
JOINOBJ (newObject), (axisObject)
# annotate it with numbers
numberOfTicks =  COUNT ticksForXaxis
for i = 1 to numberOfTicks
  # draw a tick
  heightTick = (lenghtXaxisOnScreen)*( (ticksForXaxis(i))-(minimumOfXaxis)) / ((maximumOfXaxis)-(minimumOfXaxis))
  newObject = SHOWARROW Start=Point, X=((Xnul)+(heightTick)), Y=(Ynul), Z=(Znul), End=Point, X=(Xnul+(heightTick)), Y=(-(tickLength)+(Ynul)), Z=(Znul), radius=(axisRadius), heads=0,color=(colorGraph)
  JOINOBJ (newObject), (axisObject)
  newObject = BUILDATOM DU
  POSATOM OBJ (newObject), X=((Xnul+(heightTick))), Y=(-(tickLength)+(Ynul)), Z=(Znul), coordsys=global
  # in next line tickLabelOfsetX and tickLabelOfsetY shifted on purpose
  LABELATOM OBJ (newObject), (0+(ticksForXaxis(i))), height = (labelHeight), color=(colorLabels), X=0, Y=(tickLabelOfsetX), Z=(tickLabelOfsetZ)
  JOINOBJ (newObject), (dummyObject)
HIDEATOM element Du
# and the Y-axis label
newObject = BUILDATOM DU
POSATOM OBJ (newObject), X=(((lenghtXaxisOnScreen)/2)+(Xnul)), Y=(-(tickLength)+(Ynul)), Z=(Znul), coordsys=global
LABELATOM OBJ (newObject), (labelForXaxis), height = (labelHeight), color=(colorLabels), X=(tickLabelOfsetX), Y=((tickLabelOfsetY)+(UnitXOffset)), Z=(tickLabelOfsetZ)
JOINOBJ (newObject), (dummyObject)
HIDEATOM element Du


# now draw the graph
# ------------------------------------
numberOfLines = (numberOfRows) - 1
# the following draws a graph by drawing lines (arrows without a head) between each datapoint
for i = 1 to numberOfLines
  firstHeight  = 0.+(energies_kJPerMol(i))
  secondHeight = 0.+(energies_kJPerMol((i)+1))
  firstX = (geometryOfInterest(i))-(minimumOfXaxis)
  secondX =(geometryOfInterest((i)+1))-(minimumOfXaxis)
  initialX = (Xnul) + ((firstX)*(lenghtXaxisOnScreen)/((maximumOfXaxis)-(minimumOfXaxis)))
  initialY = (Ynul) + ((firstHeight)*(lenghtYaxisOnScreen) /((maximumOfYaxis)-(minimumOfYaxis)))
  initialZ = (Znul)
  lastX  = (Xnul) + ((secondX)*(lenghtXaxisOnScreen)/((maximumOfXaxis)-(minimumOfXaxis)))
  lastY  = (Ynul) + ((secondHeight)* (lenghtYaxisOnScreen) /((maximumOfYaxis)-(minimumOfYaxis)))
  lastZ  = (Znul)
  #PRINT (0+(initialY)) and (0+(lastY))
  newObject = SHOWARROW Start=Point, X=(initialX), Y=(initialY), Z=(initialZ), End=Point, X=(lastX), Y=(lastY), Z=(lastZ), radius=(graphRadius), heads=0,color=(colorGraph)
  JOINOBJ (newObject), (axisObject)


SHOWMESSAGE Please verify that the scene looks OK. REDO procedure from start if not satisfied. Altering the scene now will MISALIGN the arrow.
WAIT ContinueButton
HIDEMESSAGE


# last opportunity to change the dimension such that less white space in the final movie, using graball, etc. 
# did not work, resulted in the arrow at the wrong spot
#GRABOBJ 1-(maximumOfXaxis)
#SHOWMESSAGE last option to get rid of white spaces, initially all the atom selected, GRABOBJ all can be used to select the graph as well, try not to rotate the scene now
#WAIT ContinueButton
#HIDEMESSAGE



# now move an arrow through the graph, this has to coincide with showing the right snapshot and the creation of a movie
# --------------------------------------------------------------------------------------------------------------------

# hide things
CONSOLE Off
HIDEOBJ element all

# set up the movie
dimensionX_original,dimensionY_original = ScreenSize
dimensionX = (dimensionX_original)
dimensionY = (dimensiony_original)
# 100 steps of shrinking by 5% till criteria are met
for i = 1 to 100
  if dimensionX > maxXdimension
    dimensionX = (dimensionX) / 1.05
# now make sure the ratio was not changed and that dimensionX is an even number
dimensionX = (dimensionX)/2
dimensionX = (dimensionX)*2
shrinkRatio = 1.*(dimensionX_original)/(dimensionX)
dimensionY = (dimensionY)/(shrinkRatio)

PRINT final dimensions were (dimensionX) (dimensionY)

# make two movies, a fast one to quickly see how it will look like, after that a real one
for g = 1 to 2
  # different movies are set up here
  if (g == 1)  
    # the skip 24 will make that it skips 24 fromes fro every 25, so every second is now just one frame (of 1/25th of a second)
    SHOWMESSAGE starting with quick test movie in which 96% of the frames are skipped
    SAVEMPG (nameOfMovieWithoutExtension)_skipped96percentOfFrames.mp4,X=(dimensionX),Y=(dimensionY),FPS=25,Skip=24,RayTrace=Off,Menu=Off
  else
    # here follow the usual movie command
    SHOWMESSAGE finished quick test movie, now working on final movie
    SAVEMPG (nameOfMovieWithoutExtension).mp4,X=(dimensionX),Y=(dimensionY),FPS=25,Skip=0,RayTrace=On,Menu=Off

  # THE FOLLOWING SHOULD ALL BE SIMPLIFIED A LOT! JUST GO THROUGH THERE ONCE!  
  # allow to run either forward or backward. 
  if loopBackward == 'Yes'
    firstPoints() = (numberOfRows)
    lastPoints()  = 1
    steps()       = -1
  else 
    firstPoints() = 1
    lastPoints()  = (numberOfRows)
    steps()       = 1 

  # some initialization if there are short breaks
  if takePauseAtCertainPositions == 'Yes'
    detectedBreakEvents = 0
    numberOfBreakEvents = COUNT takePauseAtCertainPositionsAt

  for h = 1 to 1
    # create the snapshots for the movie, this is done by moving an arrow through the graph
    for i = (firstPoints(h)) to (lastPoints(h)) step (steps(h))
      SHOWOBJ (i)
      #endX =  (Xnul) + ((1.*(i)*(lenghtXaxisOnScreen))/(maximumOfXaxis))
      endX  =  (Xnul) + ((1.*((geometryOfInterest(i))-(minimumOfXaxis))*(lenghtXaxisOnScreen))/((maximumOfXaxis)-(minimumOfXaxis)))
      #firstX = (geometryOfInterest(i))
      endY = (Ynul) + (arrowOfSet)+ ((energies_kJPerMol(i))*(lenghtYaxisOnScreen) /(maximumOfYaxis))
      endZ = (Znul)
      topX = (endX)
      topY = (endY) + (arrowLength)
      topZ = (Znul)
      newArrow = SHOWARROW Start=Point, X=(topX), Y=(topY), Z=(topZ), End=Point, X=(endX), Y=(endY), Z=(endZ), radius=(arrowRadius), heads=1,color=(colorArrow)
      newAtom = BUILDATOM Du
      POSATOM OBJ (newAtom), X=((Xnul)+(lenghtXaxisOnScreen)), Y=((Ynul)+(lenghtYaxisOnScreen)), Z=(Znul), coordsys=global
      LABELATOM OBJ (newAtom), (nameOfSnapshot(i)), height = (labelHeight), color=(colorLabels), X=-1, Y=0, Z=(tickLabelOfsetZ)
      #LABELATOM OBJ (newAtom), 'snapshot (i)/(maximumOfXaxis)', height = (labelHeight), color=(colorLabels), X=-1.5, Y=-0.5, Z=(tickLabelOfsetZ)
      HIDEATOM OBJ (newAtom)
      WAIT 1
      # wait much longer if there should be a short pause
      if takePauseAtCertainPositions == 'Yes'
        if detectedBreakEvents < numberOfBreakEvents
          if takePauseAtCertainPositionsAt((detectedBreakEvents)+1) == nameOfSnapshot(i)
            SHOWMESSAGE FOUND ONE
            detectedBreakEvents = (detectedBreakEvents) + 1
            WAIT ((takePauseAtCertainPositionsOfHowManySeconds(detectedBreakEvents))*25)
      DELOBJ (newArrow) (newAtom)
      HIDEOBJ (i)
  
  # end the movie
  SAVEMPG Off

# put some information in a file so the user can later see how much time it all took
endTime = SYSTEMTIME
elapsedTime = (-(startTime) + (endTime))/1000
SHOWMESSAGE final dimensions were (dimensionX) (dimensionY) with shrink ration (shrinkRatio) while all the graphing and rendering took (0+(elapsedTime)) seconds
TABULATE (elapsedTime)
SAVETAB 1, (nameOfMovieWithoutExtension)_renderingTime.tab, Columns=1, header='time in seconds'
DELTAB 1


WAIT ContinueButton

# resize the screen to what the user used before
SCREENSIZE (dimensionXatStart),(dimensionYatStart)
EXIT 
