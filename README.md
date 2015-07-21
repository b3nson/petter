Petter
======
a vector-graphic-based pattern generator.

###Description:
Petter is a experimental [Processing](http://www.processing.org/)-application for experimental vector-based graphic design.    
Use [SVG](http://en.wikipedia.org/wiki/Scalable_Vector_Graphics)-Files as input to generate, influence and export graphic patterns as PDF.    
JPEG/PNG/GIF (also animated ones) can be used as a "ImageMap" to alter the pattern.    
Drag and Drop SVG and Image-Files into the GUI to set input-files, use gui-controls to alter the pattern,    
press 's' to export as PDF. Press 'h' for further help.    

See http://www.lafkon.net/petter/ for a gallery of outputs created with Petter.

![petter screenshot](http://www.lafkon.net/petter/ext/20150125-213016_595x842_Louise+GUI.gif "petter screenshot")
![petter animated sequence](http://www.lafkon.net/petter/ext/Josh_30f-half.gif "petter animated sequence")![petter animated sequence with animated imagemap](http://www.lafkon.net/petter/img/20150721-123430_27f_Rich+ANIM_thumb.gif "petter animated sequence with animated imagemap") Animated PDF-sequences with (right) and without (left) animated-gif as ImageMap.

###Keyboard Shortcuts:
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
S			-	Save PDF

------------------------------------------------------------------------
CREATE
------------------------------------------------------------------------

DRAG'N'DROP SVG-FILES (on canvas)	
		- one or multiple SVGS to add/replace tiles
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

C	- show prev frame of animated-gif-imagemap
V	- show next frame of animated-gif-imagemap
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

### Installation:
- Grab a copy of [Processing](http://www.processing.org/) for your OS, install it.
- Download/clone Petter to your Processing Sketch-Directory.
- Download and install external libraries (see below).


### Use of contributed Libraries:
- `penner.easing` - https://github.com/jesusgollonet/processing-penner-easing
- `controlP5` - http://www.sojamo.de/libraries/controlP5/
- `sojamo.drop` - http://www.sojamo.de/libraries/drop/
- `gifAnimation` - http://extrapixel.github.io/gif-animation/

###Known Issues:    
DragAndDrop does not work with FileManager `pcmanfm` under GNU/Linux.    
Use e.g. `Nautilus` instead.    
"The root error is pcmanfm sends a null-terminated-string for file list"    
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=664205


###License: 
```
Petter - vector-graphic-based pattern generator.
http://www.lafkon.net/petter/
Copyright (C) 2015 LAFKON/Benjamin Stephan
 
This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.
 
This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
```
