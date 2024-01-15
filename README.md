# Petter
an experimental vectorgraphic pattern generator.  
[lafkon.net/petter](http://www.lafkon.net/petter/)

---

## Description:
Petter is an experimental ui-based [Processing](http://www.processing.org/)-App to create and save experimental visual patterns. Input and output is strictly vector-based (svg/pdf).

Use your own [svg](http://en.wikipedia.org/wiki/Scalable_Vector_Graphics)-files as input, alter the repetition and stacking of basic relative and absolute transformations, influence the resulting pattern with different effectors and export efficient vector-pdfs.

See [lafkon.net/petter](http://www.lafkon.net/petter/) for a gallery of outputs created along the way with Petter.  
Check [Installation](#installation) and [Basic instructions](#basic-instructions) below.

## Screenshots:
> Petter main-ui

![petter screenshot](http://www.lafkon.net/petter/ext/20150125-213016_595x842_Louise+GUI.gif "petter screenshot")

> Animated PDF-sequences 

![petter animated sequence](http://www.lafkon.net/petter/ext/Josh_30f-half.gif "petter animated sequence")![petter animated sequence with animated imagemap](http://www.lafkon.net/petter/ext/William-27f+GUI.gif "petter animated sequence with animated imagemap") 

> Petter MapEditor and TileEditor

<img src="http://www.lafkon.net/petter/ext/Petter_MapEditor-01a.png" width="49%"></src>
<img src="http://www.lafkon.net/petter/ext/Petter_TileEditor-01a.png" width="49%"></src>

## Keyboard shortcuts:
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

1	- apply previous Iterator
2	- apply next Iterator
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

## Installation:
- Grab a copy of [Processing](http://www.processing.org/) for your OS, install it.
- Download/clone Petter to your Processing Sketch-Directory.
- Download and install external libraries (see below).

## Basic instructions:
Check **Keyboard Shortcuts** above, as Petter relies heaviliy on shortcuts.
- Start app, play around, read help <kbd>H</kbd>, open **TileEditor** <kbd>T</kbd> and **MapEditor** <kbd>M</kbd>.
- Drag and drop svg-file(s) onto **TileEditor** to add tiles.
- Hit <kbd>S</kbd> to save the current pattern as pdf anytime. You'll find it in the `o`-directory of your sketch.
- Read help <kbd>H</kbd> again to find some new shortcuts and functions.

## Required libraries:
- `penner.easing` - http://github.com/jesusgollonet/processing-penner-easing
- `controlP5` - http://github.com/sojamo/controlp5 (> v2.2.3)
- `drop` - https://transfluxus.github.io/drop/
- `gifAnimation` - http://extrapixel.github.io/gif-animation/ (>= [3.0](https://github.com/extrapixel/gif-animation/tree/3.0))

## Command-line-options:
Implemented, not yet documented.

## License: 
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
