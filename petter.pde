/**
 * Petter - vector-graphic-based pattern generator.
 * http://www.lafkon.net/petter/
 * Copyright (C) 2020 LAFKON/Benjamin Stephan
 * 
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 */

import processing.pdf.*;
import processing.svg.*;
import processing.javafx.*;
import penner.easing.*;
import controlP5.*;
import gifAnimation.*;
import java.util.*;


static int ROT = 0;
static int TRA = 1;
static int SCA = 2;
static int ANM = 3;

static int lastKey = ' ';
final static int KEYS = 0500;
final static boolean[] keysDown = new boolean[KEYS];

ControlP5 gui;
ControlFont font;
ColorPicker bg_copi, stroke_copi, shape_copi, type_copi;
TileEditor tileEditor;
MapEditor mapEditor;
Iterator iterator;
Memento undo;
PGraphics pdf; 

String version = "0.6";
String settingspath = "i/settings/";
String outputpath = "o/";
String tmppath = "tmp/";
String subfolder = "";
String[] names;
String[] helptext;
String[] systemfonts;
String name;

ArrayList<PShape> svg;
ArrayList<String> svgpath;
ArrayList<PImage> map;
PShape ref;
PShape nfo;
PShape s;
PImage checker;

int mapIndex = 0;
int absPageOffset = 25;
int pageOffset = 25;
int xtilenum = 8;
int ytilenum = 10;
int tilecount;
float manualOffsetX = 0;
float manualOffsetY = 0;
float tilewidth, tileheight, tilescale;
float absTransX = 0;
float absTransY = 0;
float absScreenX;
float absScreenY;

float zoom = 1.0;
float tmpzoom = 0;
float nfoscale = 1.0;
float relTransX = 0;
float relTransY = 0;
float absRot = 0;
float relRot = 90;
float absScale = 1.0;
float relScale = 0.0;
float totaltranslatex = 0.0;
float totaltranslatey = 0.0;
float totalscale = 0.0;
float totalrotate = 0.0;
float customStrokeWeight = 2.0;
boolean strokeMode = true;
boolean globalStyle = false;
boolean customStroke = true;
boolean customFill = true;
boolean random = false;
boolean loopDirection = false; //false = X before Y | true = Y before X
boolean tileSelectionMode = false; //false = by gridorder | true = by iterator-order
boolean linebyline = false;
boolean dragAllowed = false;
boolean showRef = false;
boolean showNfo = false;
boolean nfoOnTop = true;
boolean exportFormat = true; //true=PDF|false=SVG
boolean guiExport = false;
boolean guiExportNow = false;
boolean showTmpInfoLabel = false;
boolean showExportLabel = false;
boolean sequencing = false;
boolean shift = false;
boolean colorpicking = false;
int seed = 0;
int fps = 0;
float mapValue = 0f;

int abscount = 0;
int rotType = 0;
int scaType = 0;
int traType = 0;
int animType = 0;
int joinmode = ROUND;
int capmode = SQUARE;

boolean exportCurrentFrame = false;
boolean exportOnNextLoop = false;
String timestamp = "";
String filename = "";
String formatName = "";
String sketchPath;

color[] bgcolor = {color(random(255), random(255), random(255))};
color[] strokecolor = {color(0, 0, 0, 255)};
color[] shapecolor = {color(255, 255, 255, 255)};
color[] typecolor = {color(0, 0, 0, 255)};
color[] recentcolors = {bgcolor[0], strokecolor[0], shapecolor[0], typecolor[0]};

boolean pageOrientation = true;
String[][] formats = { 
  { "A5", "437", "613" }, 
  { "A4", "595", "842" }, 
  { "A3", "842", "1191" }, 
  { "A2", "1191", "1684" }, 
  { "Q1", "800", "800" },
  { "WWE-Final", "576", "768" },
  { "FullHD", "1920", "1080" }
};
int viewwidth = 595;
int viewheight = 842;
int pagewidth = 595;
int pageheight = 842;
int guiwidth = 310;

int manualNFOX = viewwidth/2;
int manualNFOY = viewheight/6*5;



// ---------------------------------------------------------------------------
//  SETUP
// ---------------------------------------------------------------------------

void setup() {
  frameRate(100);
  size(905, 842, JAVA2D); //JAVA2D/FX2D
  smooth();
  colorMode(RGB, 255);
  shapeMode(CENTER);
  
  //surface.setResizable(true);
  surface.setSize(905, 842);
  surface.setTitle("petter " +version);
  sketchPath = sketchPath();
  
  PImage pettericon = loadImage("i/assets/icon.png");
  surface.setIcon(pettericon);

  checker = createCheckerboard(200, 200);

  PFont pfont = createFont("i/assets/PFArmaFive.ttf", 8, false);
  font = new ControlFont(pfont);

  gui = new ControlP5(this, font);
  gui.setAutoDraw(false);

  setupIterators();
  iterator = getIterator();
  
  undo = new Memento(gui, 50);

  svg = new ArrayList<PShape>();
  svgpath = new ArrayList<String>();
  map = new ArrayList<PImage>();
  
  try { svg.add(new TileSVG("i/_petter-def.svg"));}  catch(NullPointerException e) {svg.add(new TileShape(createShape(RECT, 0, 0, 50, 50),50f,50f));}
  try { svgpath.add(sketchPath() +"/i/_petter-def.svg");}  catch(NullPointerException e) {}
  try { ref = loadShape("i/_petter-ref.svg");}         catch(NullPointerException e) {showRef = false;}
  try { nfo = new TileSVG("i/_petter-nfo.svg");}        catch(NullPointerException e) {showNfo = false;}
  try { names = loadStrings("i/assets/names.txt");}   catch(NullPointerException e) {}
  try { helptext = loadStrings("i/assets/help.txt");} catch(NullPointerException e) {} 

  setupGUI();

  pageOffsetSlider.setValue(absPageOffset);
  formatDropdown.setValue(2);
  penner_rot.setValue(rotType);
  penner_sca.setValue(scaType);
  penner_tra.setValue(traType);
  penner_anim.setValue(animType);
  showRefToggle.setState(showRef);
  showNfoToggle.setState(showNfo);
  nfoLayerToggle.setState(nfoOnTop);
  exportFormatToggle.setState(exportFormat);
  //strokeWeightSlider.setValue(strokeWeight);
  last = null;

  undo.setUndoStep();

  println("  , _");
  println(" /|/ \\ __|__|_  _  ,_");
  println("  |__/|/ |  |  |/ /  |");
  println("  |   |_/|_/|_/|_/   |/ v" +version);
  println(" ");
  println("  Press TAB for menu");
  println("          H for help");
  println("");

  checkArgs();
  ControlP5.DEBUG = false;
}


// ---------------------------------------------------------------------------
//  DRAW
// ---------------------------------------------------------------------------

void draw() {

  if (sequencing) {
    animate();
  }

  if (shift && key == CODED && keyCode == SHIFT && !shiftPressed) {
    shiftPressed = true;
    enterShiftMode();
  } else if (!shift && shiftPressed) {
    shiftPressed = false;  
    leaveShiftMode();
    last = null;
  }

  if(exportOnNextLoop) {
    exportCurrentFrame = true;
    exportOnNextLoop = false;
  }
  if (exportCurrentFrame) {
    if (!guiExportNow) {
      formatName = pagewidth +"x" +pageheight;
      if (!sequencing && !batchmode) {
        saveSettings(timestamp +"_" +name);
      }
    }
    if (!guiExportNow) {
      filename = outputpath +subfolder +timestamp +"_" +formatName +"_" +name +seqname;
      if (exportFormat) {
        filename += ".pdf";
        pdf = (PGraphicsPDF) createGraphics(pagewidth, pageheight, PDF, filename);
      } else {
        filename += ".svg";
        pdf = (PGraphicsSVG) createGraphics(pagewidth, pageheight, SVG, filename);
      }
    } else {
      filename = outputpath +subfolder +timestamp +"_" +formatName +"_" +name +seqname +"+GUI";
      if (exportFormat) {
        filename += ".pdf";
        pdf = (PGraphicsPDF) createGraphics(pagewidth+guiwidth, pageheight, PDF, filename);
      } else {
        filename += ".svg";
        pdf = (PGraphicsSVG) createGraphics(pagewidth+guiwidth, pageheight, SVG, filename);
      }
    }

    beginRecord(pdf); 
    pdf.shapeMode(CENTER);   
    pdf.pushStyle();

    if (guiExportNow) { //reset scale to 1 for guiexport
      tmpzoom = zoom;
      scaleGUI(1f);
    }    

    pdf.pushMatrix();  
    pdf.scale(1f/zoom);

    //saveFrame("frame.png");
  }

  if (bg_copi != null && bg_copi.isOpen()) {
    bgcolorBang.setColorForeground(bgcolor[0]);
    bgcolorSaveLabel.setValue((bgcolor[0]));
  }
  if (globalStyle) {
    if (stroke_copi != null && stroke_copi.isOpen()) {
      strokecolorBang.setColorForeground(strokecolor[0]);
      strokecolorSaveLabel.setValue( color(red(strokecolor[0]), green(strokecolor[0]), blue(strokecolor[0]) ));
      strokecolorAlphaSaveLabel.setValue(alpha(strokecolor[0]));   
    }
    if (shape_copi != null && shape_copi.isOpen()) {
      shapecolorBang.setColorForeground(shapecolor[0]);
      shapecolorSaveLabel.setValue( color(red(shapecolor[0]), green(shapecolor[0]), blue(shapecolor[0]) ));
      shapecolorAlphaSaveLabel.setValue(alpha(shapecolor[0]));   
    }
  }

  if(alpha(bgcolor[0])!= 255f && !exportCurrentFrame) { // draw checkerboard in pagebg when bgcolor has alpha
    for(int j = 0; j < viewheight; j+=200) {
      for(int i = 0; i < viewwidth; i+=200) {
        image(checker, i, j);
      }
    }
  }

  pushStyle();
  fill(bgcolor[0]);
  noStroke();
  rect(0, 0, viewwidth, viewheight);
  popStyle();

  if (!exportCurrentFrame || (exportCurrentFrame && guiExportNow)) {
    pushStyle();
    fill(50);
    noStroke();
    rect(viewwidth, 0, guiwidth, viewheight);
    popStyle();
  }

  if (nfo != null && showNfo && !nfoOnTop) {
    shapeMode(CENTER); 
    pushMatrix();
    scale(zoom);
    translate(manualNFOX, manualNFOY);
    scale(nfoscale);
    shape(nfo);
    popMatrix();
  }
  
  pageOffset = int(absPageOffset);
  tilewidth  = (float(pagewidth) / xtilenum);
  tilescale = tilewidth / svg.get(0).width;
  tileheight = svg.get(0).height * tilescale;

  abscount = 0;
  tilecount = (xtilenum*ytilenum)-1;
  if(linebyline && iteratorIndex == 0) { 
    tilecount = (loopDirection?xtilenum:ytilenum)-1; 
  }

  randomSeed(seed);

  pushMatrix(); //outer matrix
  scale(zoom);
  translate(pageOffset + manualOffsetX, pageOffset + manualOffsetY);
  scale(((float)(pagewidth-(2*pageOffset)) / (float)pagewidth)); //scale for offset


  // ---------------------------------------------------
  // MAIN LOOP
  // ---------------------------------------------------  
  
  
  iterator.setTileGrid(xtilenum, ytilenum, loopDirection);
  
  while (iterator.hasNext()) {
    pushMatrix(); //inner matrix
    
    int[] gridpos = iterator.next(); // get next tile on grid dependent on iterator    
    int gridPosX = gridpos[0];
    int gridPosY = gridpos[1];
    int iterCount = gridpos[2];
    
    //Standard tile distribution
    float tilex = (tilewidth/2)+(tilewidth*gridPosX);
    float tiley = (tileheight/2)+(tileheight*gridPosY);
    translate(tilex, tiley);

    //SKIPTILE--------------------------------------
    if (mapEditor != null) {
      if(mapEditor.getMapPermit(tilex, tiley) == false) {
        popMatrix(); 
        if(linebyline && iteratorIndex == 0) { //only with scanline-iterator // same as on end of loop // refactor?
          if(!loopDirection && gridPosX == xtilenum-1 ||
              loopDirection && gridPosY == ytilenum-1 ) {
            abscount++;  
          }
        } else { abscount++; }    
        continue; 
      }
    }

    //TRANSLATE-------------------------------------
    totaltranslatex = absTransX*(map(gridPosX, 0f, (float)xtilenum, (float)-xtilenum/2+0.5, (float)xtilenum/2+0.5 ));
    totaltranslatey = absTransY*(map(gridPosY, 0f, (float)ytilenum, (float)-ytilenum/2+0.5, (float)ytilenum/2+0.5 ));      
    if (mapEditor != null && mapEditor.traMapActive()) {
      mapValue = mapEditor.getTraMapValue(tilex, tiley);
      totaltranslatex += (mapValue * ((float)relTransX));
      totaltranslatey += (mapValue * ((float)relTransY));
    } else {
      totaltranslatex += (ease(TRA, abscount, 0, -relTransX, tilecount)+(relTransX/2));
      totaltranslatey += (ease(TRA, abscount, 0, -relTransY, tilecount)+(relTransY/2));
    }
    translate(totaltranslatex, totaltranslatey);

    //ROTATE-------------------------------------
    totalrotate = absRot;
    if (mapEditor != null && mapEditor.rotMapActive()) {
      mapValue = mapEditor.getRotMapValue(tilex, tiley);
      totalrotate += (mapValue * (relRot));
    } else {
      totalrotate += ease(ROT, abscount, 0, relRot, tilecount);
    }
    rotate(radians(totalrotate));

    //SCALE-------------------------------------
    totalscale = absScale;
    if (mapEditor != null && mapEditor.scaMapActive()) {
      mapValue = mapEditor.getScaMapValue(tilex, tiley);
      totalscale *= (mapValue * (relScale));
    } else {  
      totalscale *= ease(SCA, abscount, 1.0, relScale, tilecount);
    }
    scale(totalscale*tilescale);

    //SELECTTILE-----------------------------
    int svgindex = 0;
    if (mapEditor != null && mapEditor.selMapActive()) {
      mapValue = mapEditor.getSelMapValue(tilex, tiley);
      svgindex = round( map(mapValue, 0, 1, 0, svg.size()-1) );
    } else if (random) {
      svgindex = int(random(svg.size()));
    } else if (svg.size() > 1) {
      if(!tileSelectionMode) {
        svgindex = ((xtilenum*gridPosY)+(gridPosX)) %svg.size(); //grid-order
      } else { 
        svgindex = (iterCount-1) %svg.size();                    //iteration-order
      }
    }
    s = svg.get(svgindex);
    
    //DRAWTILE-----------------------------
    if (s != null) {
      shape(s);
    }

    popMatrix(); //inner matrix

    //COUNT-----------------------------
    if(linebyline && iteratorIndex == 0) { //only with scanline-iterator
      if(!loopDirection && gridPosX == xtilenum-1 ||
          loopDirection && gridPosY == ytilenum-1 ) {
        abscount++;  
      }
    } else { abscount++; }
    
  } //while hasNext
  popMatrix(); //outer matrix


  // ---------------------------------------------------

  if (nfo != null && showNfo && nfoOnTop) {
    pushStyle();
    shapeMode(CENTER); 
    pushMatrix();
    scale(zoom);
    translate(manualNFOX, manualNFOY);
    scale(nfoscale);
    shape(nfo);
    popMatrix();
    popStyle();
  }

  if (exportCurrentFrame && guiExportNow) { 
    if (ref != null && showRef) {
      pushStyle();
      shapeMode(CORNER);
      shape(ref, 0, 0, viewwidth, viewheight);
      popStyle();
    }
    gui.getWindow().draw(pdf);
    scaleGUI(tmpzoom); //recreate prev zoom
    tmpzoom = 0f;
  }
  
  if(showScrollbar && !guiExportNow) {
    fill(c1);
    rect(viewwidth+guiwidth - 2, scrollbarY, 2, scrollbarHeight);
  }
  
  if (exportCurrentFrame) {
    pdf.popMatrix(); 
    pdf.popStyle();
    endRecord();  
    println(filename +" exported!");
    if (batchmode && batchnow) {
      exit();
    }
    
    if(!guiExport) {
      showExportLabel(true);
    } else if(guiExportNow) {
      showExportLabel(true);
    }
    
    if (guiExport && !guiExportNow) {
      guiExportNow = true;
    } else if (guiExport && guiExportNow) {
      guiExportNow = false;
      exportCurrentFrame = false;
    } else if (!guiExport) {
      exportCurrentFrame = false;
    }
  }

  if(showTmpInfoLabel) {
    if(millis() - showTmpInfoLabelTimer >= 4000) {
      showTmpInfoLabel(false, "");
    }
  }
  
  if(showExportLabel) {
    if(millis() - showExportLabelTimer >= 4000) {
      showExportLabel(false);
    }
  }

  if (!exportCurrentFrame) {
    if (ref != null && showRef) {
      pushStyle();
      shapeMode(CORNER);
      shape(ref, 0, 0, viewwidth, viewheight);
      popStyle();
    }  
    gui.draw();
  }

  if (batchmode) {
    if (batchwait > 0) {
      batchwait--;
    } else {
      generateName();
      generateTimestamp();
      batchnow = true;
      exportCurrentFrame = true;
    }
  }


  if(colorpicking) {
    if ((mouseX <= viewwidth) && (mouseY <= viewheight)) {
      if( (bg_copi != null && bg_copi.isOpen()) ||
          (stroke_copi != null && stroke_copi.isOpen()) ||
          (shape_copi != null && shape_copi.isOpen()) ||
          (type_copi != null && type_copi.isOpen())
         ) {
        pushStyle();
        color c = get(mouseX, mouseY);
        strokeWeight(1);
        noFill();
        stroke(255);
        rect(mouseX+13, mouseY+13, 22, 22);
        fill(c);
        stroke(0);
        rect(mouseX+14, mouseY+14, 20, 20);
        popStyle();
       } else {
         colorpicking = false; 
       }
    }
  }

  if (showHELP) {
    fpsLabel.setText(renderer +" @ " +str((int)frameRate));
  }

  if(cp5BoundsChanged) {
    gui.setGraphics(this, 0, 0); //hack to prevent cp5-bounds-bug
    cp5BoundsChanged = false;
  }
}//DRAW END


// ---------------------------------------------------------------------------
//  INPUT EVENTS
// ---------------------------------------------------------------------------

void mouseMoved() {
  //for testing-purposes
  //pageOffset = int((mouseX));
  //absScale = (float(mouseX)/100f);
  //relScale = (float(mouseX)/100f);
  //absTransX = (mouseX-(width/2))*2;
  //absTransY = (mouseY-(height/2))*2;
  //relTrans = (mouseX);
  //absRot = mouseX;
  //relRot = mouseY;
  //xtilenum = mouseX/10;
  //ytilenum = mouseY/10;
}

void mousePressed() {
  if ((mouseX <= viewwidth) && (mouseY <= viewheight)) {
    dragAllowed = true;
    pmouseX = mouseX;
    pmouseY = mouseY;

    if(colorpicking) {
      ColorPicker tmpcp = null;
      if      (bg_copi != null && bg_copi.isOpen()) { tmpcp = bg_copi;}
      else if (stroke_copi != null && stroke_copi.isOpen()) {tmpcp = stroke_copi;}
      else if (shape_copi != null && shape_copi.isOpen()) {tmpcp = shape_copi;}
      else if (type_copi != null && type_copi.isOpen()) {tmpcp = type_copi;}

      if(tmpcp != null) {
        color c = get(mouseX, mouseY);
        tmpcp.setExtColor(c);
      }
    }
  }
}

void mouseDragged ( ) {
  if (dragAllowed && mouseButton == LEFT) {
    manualOffsetX -= pmouseX-mouseX;
    manualOffsetY -= pmouseY-mouseY;
    dragOffset.setText("OFFSET: " +(int)manualOffsetX +" x " +(int)manualOffsetY);
    offsetxSaveLabel.setValue(manualOffsetX);
    offsetySaveLabel.setValue(manualOffsetY);
  } else if (dragAllowed && mouseButton == RIGHT) {
    manualNFOX -= pmouseX-mouseX;
    manualNFOY -= pmouseY-mouseY;
  }
}

void mouseReleased() {
  dragAllowed = false;
}

void keyPressed() {  
  processKey(keyCode, true);

  if (keysDown[SHIFT]) {
    shift = true;
  }  
  if (keysDown[LEFT]) {
    if (keysDown[LEFT] && keysDown[SHIFT]) xtilenum -= 10;
    else xtilenum -= 1;
    updatextilenumSlider();
  } else if (keysDown[RIGHT]) {
    if (keysDown[RIGHT] && keysDown[SHIFT]) xtilenum += 10;
    else xtilenum += 1;        
    updatextilenumSlider();
  } else if (keysDown[UP]) {
    if (keysDown[UP] && keysDown[SHIFT]) ytilenum -= 10;
    else ytilenum -= 1;
    updateytilenumSlider();
  } else if (keysDown[DOWN]) {
    if (keysDown[DOWN] && keysDown[SHIFT]) ytilenum += 10;
    else ytilenum += 1;   
    updateytilenumSlider();
  } else if (keysDown[TAB]) {      
    toggleMenu();
  } else if (keysDown['Z']) {
    undo.undo();
  } else if (keysDown['Y']) {
    undo.redo();
  } else if (keysDown['S']) {
    exportOnNextLoop = true;
    generateName();
    generateTimestamp();
    if(showExportLabel) showExportLabel(false);
  } else if (keysDown['0']) {
    toggleSettings();
  } else if (keysDown['X']) {
    loopDirection = !loopDirection;
    loopDirectionSaveLabel.setValue((int(loopDirection)));
    showTmpInfoLabel(true, "loopdirection: " +(loopDirection?"y –> x":"x –> y"));
  } else if (keysDown['R']) {
    toggleRandom();
    showTmpInfoLabel(true, "random tile selection: " +(random?"on":"off"));
  } else if (keysDown['L']) {
    linebyline = !linebyline;
    linebylineSaveLabel.setValue((int(linebyline)));
    showTmpInfoLabel(true, "linebyline: " +(linebyline?"on":"off"));
  } else if (keysDown['E']) {
    tileSelectionMode = !tileSelectionMode;
    tileSelectionModeSaveLabel.setValue((int(tileSelectionMode)));
    showTmpInfoLabel(true, "tileSelectionMode: " +(tileSelectionMode?"iteratororder":"gridorder"));
  } else if (keysDown['B']) {
    showRef = !showRef;
    showRefToggle.setState(showRef);
  } else if (keysDown['N']) {
    showNfo = !showNfo;
    showNfoToggle.setState(showNfo);
  } else if (keyCode == 93 || keyCode == 107) { //PLUS
    scaleGUI(true);
  } else if (keyCode == 47 || keyCode == 109) { //MINUS
    scaleGUI(false);
  } else if (keysDown['I']) {
    openAnimate();
    registerAnimStartValues();
  } else if (keysDown['O']) {
    openAnimate();
    registerAnimEndValues();
  } else if (keysDown['P']) {
    startSequencer(false);
  } else if (keysDown['A']) {
    toggleAnimate();
  } else if (keysDown['J']) {
    showInValues();
  } else if (keysDown['K']) {
    showOutValues();
  } else if (keysDown['H']) {
    toggleHelp();
  } else if (keysDown['C']) {
    prevImgMapFrame();
  } else if (keysDown['V']) {
    nextImgMapFrame();
  } else if (keysDown['T']) {
    toggleTileEditor();
  } else if (keysDown['M']) {
    toggleMapEditor();
  }else if (keysDown[',']) {
    changeSliderRange(false);
  } else if (keysDown['.']) {
    changeSliderRange(true);
  } else if (keysDown['D']) {
    loadDefaultSettings();
  } else if (keysDown['1']) {
    prevIterator();
    showTmpInfoLabel(true, "iterator: " +iteratorIndex +" –>  " +iterator.getName());
  } else if (keysDown['2']) {
    nextIterator();
    showTmpInfoLabel(true, "iterator: " +iteratorIndex +" –>  " +iterator.getName());
  }
}

void keyReleased() {
  if (keysDown[SHIFT]) {
    shift = false;
  }  
  processKey(keyCode, false);
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (keysDown[CONTROL]) {
    nfoscale += e/100;
  } else {
    menuScroll((int)e);
    gui.setMouseWheelRotation((int)e);
  }
}

static void processKey(int k, boolean set) {
  if(set) lastKey = k;
  if (k < KEYS)  keysDown[k] = set;
}
