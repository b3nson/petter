Petter
======
a vector-graphic-based pattern generator.

### Description:
Petter is a experimental [Processing](http://www.processing.org/)-application for experimental vector-based graphic design.    
Use [SVG](http://en.wikipedia.org/wiki/Scalable_Vector_Graphics)-Files as input to generate, influence and export graphic patterns as PDF.    
JPEG/PNG/GIF (also animated ones) can be used as a "ImageMap" to alter the pattern.    
Drag and Drop SVGs into the "TileEditor", use gui-controls to alter the pattern,    
press 's' to export as PDF. Press 'h' for further help.    

See http://www.lafkon.net/petter/ for a gallery of outputs created with Petter.

![petter screenshot](http://www.lafkon.net/petter/ext/20150125-213016_595x842_Louise+GUI.gif "petter screenshot")
![petter animated sequence](http://www.lafkon.net/petter/ext/Josh_30f-half.gif "petter animated sequence")![petter animated sequence with animated imagemap](http://www.lafkon.net/petter/ext/William-27f+GUI.gif "petter animated sequence with animated imagemap") 
Animated PDF-sequences with (bottom) and without (top) animated-gif as ImageMap.

### Keyboard Shortcuts:
```
SHORTCUTS
========================================================================

------------------------------------------------------------------------
GENERAL 
------------------------------------------------------------------------

TAB		-	Show/Hide MAIN-MENU
H		- 	Show/Hide this HELP
T		- 	Show/Hide TileEditor
M		- 	Show/Hide MapEditor
+ / - 		- 	ZOOM IN / OUT
Z / Y 		- 	UNDO / REDO
D 		-	RESET TO DEFAULT

SHIFT on Sliders	-	bigger steps
SCROLL on Sliders	-	finer steps
. / ; on Sliders	-	in/decrease sliderrange
D on Sliders		-	reset slider to default

0 (ZERO)	-	Load previous Settings
S		-	Save PDF

------------------------------------------------------------------------
CREATE
------------------------------------------------------------------------

DRAG'N'DROP SVG-FILES (on TileEditor)	
		- one or multiple SVGS to add/replace tiles
DRAG'N'DROP IMG-FILE (on MapEditor)
		- set image as transformation-map

LEFTCLICK-DRAG THE CANVAS	- repos artwork
RIGHTCLICK-DRAG THE CANVAS	- repos nfo-graphic
CTRL-SCROLL			- scale nfo-graphic

CURSOR LEFT/RIGHT	- add/remove tiles in x-space (+SHIFT: 10)
CURSOR UP/DOWN		- add/remove tiles in y-space (+SHIFT: 10)

1   - apply previous Iterator
2   - apply next Iterator
X	- change cycle-order (L>R>T>B to T>B>L>R)
R	- randomize tile-selection (when multiple different tiles are used)
E	- change tile-selection-mode (gridorder or iteratororder)
L	- change rel-transformations from tile-by-tile to line-by-line
N	- show/hide NFO-Graphic
B	- show/hide REF-Graphic

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
- For **Processing 3**.x choose `master`-branch: [master](https://github.com/b3nson/petter/tree/master)
- For **Processing 2**.x choose `processing-2.x`-branch: [processing-2.x](https://github.com/b3nson/petter/tree/processing-2.x)


### Use of contributed Libraries:
- `penner.easing` - http://github.com/jesusgollonet/processing-penner-easing
- `controlP5` - http://github.com/sojamo/controlp5 (> v2.2.3)
- `drop` - https://transfluxus.github.io/drop/
- `gifAnimation` - http://extrapixel.github.io/gif-animation/ (>= [3.0](https://github.com/extrapixel/gif-animation/tree/3.0))

### Command-Line-Options:
soon...


### Known Issues:    
DragAndDrop does not work with FileManager `pcmanfm` under GNU/Linux.    
Use e.g. `Nautilus` instead.    
"The root error is pcmanfm sends a null-terminated-string for file list"    
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=664205


### License: 
```
Petter - vector-graphic-based pattern generator.
http://www.lafkon.net/petter/
Copyright (C) 2024 LAFKON/Benjamin Stephan
 
This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.
 
This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
```
