petter
======

DESCRIPTION:
TODO
repetition, variation
vector based
input: svg
output: pdf


![petter screenshot](http://conversations.tools/m/20140818-174400_CS_petter+GUI.png "petter screenshot")


##Keyboard Shortcuts
TODO

## Use of contributed Libraries
- `penner.easing` - https://github.com/jesusgollonet/processing-penner-easing
- `controlP5` - http://www.sojamo.de/libraries/controlP5/
- `sojamo.drop` - http://www.sojamo.de/libraries/drop/


####Known Issues:    
DragAndDrop does not work with FileManager `pcmanfm` under GNU/Linux.    
Use e.g. `Nautilus` instead.    
"The root error is pcmanfm sends a null-terminated-string for file list"    
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=664205



```
SHORTCUTS
========================================================================

------------------------------------------------------------------------
GENERAL 
------------------------------------------------------------------------

M		-	Show/Hide MAIN-MENU
H		- 	Show/Hide this HELP
+ / - 	- 	ZOOM IN / OUT
Z / Y 	- 	UNDO / REDO

SHIFT on Sliders	-	bigger steps
SCROLL on Sliders	-	finer steps

0 (ZERO)	-	Load previous Settings
S	-	Save PDF

------------------------------------------------------------------------
CREATE
------------------------------------------------------------------------

DRAG'N'DROP SVG-FILES (on canvas)	
		-	one or multiple SVGS to add/replace tiles
		- (bottom-area) to add/replace nfo-graphic
DRAG'N'DROP IMG-FILE (on menu)
		- set image as transformation-map

LEFTCLICK-DRAG THE CANVAS	- repos artwork
RIGHTCLICK-DRAG THE CANVAS	- repos nfo-graphic

CURSOR LEFT/RIGHT	- add/remove tiles in x-space (+SHIFT: 10)
CURSOR UP/DOWN		- add/remove tiles in y-space (+SHIFT: 10)

R	- randomize tile-order (when multiple different tiles are used)
X	- change cycle-order (L>R>T>B to T>B>L>R)
N	- show/hide NFO-Graphic

------------------------------------------------------------------------
ANIM
------------------------------------------------------------------------

A 	- show Anim menu
I	- set/overwrite start-values
O	- set/overwrite end-values
J	- view start-values
K	- view end-values
P	- view/testrun animation

========================================================================
```
