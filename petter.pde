/**
 * Petter - vector-graphic-based pattern generator.
 * http://www.lafkon.net/petter/
 * Copyright (C) 2015 LAFKON/Benjamin Stephan
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
import penner.easing.*;
import controlP5.*;
import sojamo.drop.*;
import gifAnimation.*;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;
import java.awt.Component;
import java.util.*;

static int ROT = 0;
static int TRA = 1;
static int SCA = 2;
static int ANM = 3;

final static int KEYS = 0500;
final static boolean[] keysDown = new boolean[KEYS];

ControlP5 gui;
SDrop drop;
DropTargetSVG dropSVGadd;
DropTargetSVG dropSVGrep;
DropTargetIMG dropIMG;
DropTargetNFO dropNFO;
ColorPicker bg_copi, stroke_copi, shape_copi;
Memento undo;
PGraphics pdf; 

String settingspath = "i/settings/";
String outputpath = "o/";
String subfolder = "";
String[] names;
String[] helptext;
String name;

ArrayList<PShape> svg;
ArrayList<PImage> map;
PShape ref;
PShape nfo;
PShape s;

//PImage map;
int mapIndex = 0;
int absPageOffset = 25;
int pageOffset = 25;
int manualNFOX = 0;
int manualNFOY = 0;
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
float relTransX = 0;
float relTransY = 0;
float absRot = 0;
float relRot = 90;
float absScale = 1.0;
float relScale = 0.0;
float relsca = 0.0;
float customStrokeWeight = 2.0;
boolean mapScale = false;
boolean mapRot = false;
boolean mapTra = false;
boolean invertMap = false;
boolean strokeMode = true;
boolean customStroke = true;
boolean customFill = true;
boolean random = false;
boolean linebyline = false;
boolean dragAllowed = false;
boolean showRef = false;
boolean showNfo = false;
boolean nfoOnTop = true;
boolean exportFormat = true; //true=PDF|false=SVG
boolean guiExport = false;
boolean guiExportNow = false;
boolean sequencing = false;
int seed = 0;
int fps = 0;
float mapValue = 0f;

int abscount = 0;
boolean loopDirection = false; //false = X before Y | true = Y before X
boolean shift = false;
int rotType = 0;
int scaType = 0;
int traType = 0;
int animType = 0;

boolean exportCurrentFrame = false;
String timestamp = "";
String filename = "";
String formatName = "";

boolean customStyle = false;

color[] bgcolor = {color(random(255),random(255),random(255))};
color[] strokecolor = {color(0,0,0)};
color[] shapecolor = {color(255,255,255)};

boolean pageOrientation = true;
String[][] formats = { 
  { "A5", "437", "613" },
  { "A4", "595", "842" },
  { "A3", "842", "1191" },
  { "A2", "1191", "1684" },
  { "Q1", "800", "800" },
  { "FullHD", "1920", "1080" }
};
int fwidth = 595;
int fheight = 842;
int pdfwidth = 595;
int pdfheight = 842;
int guiwidth = 310;


// ---------------------------------------------------------------------------
//  SETUP
// ---------------------------------------------------------------------------

void setup() {  
  frameRate(25);
  //size(fwidth+(showMENU?guiwidth:0), fheight, JAVA2D);
  size(905, 842, JAVA2D);
  surface.setResizable(true);
  surface.setSize(905, 842);

  smooth();
  shapeMode(CENTER);
  
  PFont pfont = createFont("i/fonts/PFArmaFive.ttf", 8, false);
  ControlFont font = new ControlFont(pfont);

  gui = new ControlP5(this, font);
  gui.setAutoDraw(false);
  
  drop = new SDrop((Component)this.surface.getNative(), this);
  //drop = new SDrop(this);  
  dropSVGadd = new DropTargetSVG(this, true);
  dropSVGrep = new DropTargetSVG(this, false);
  dropIMG = new DropTargetIMG(this); 
  dropNFO = new DropTargetNFO(this);  
  drop.addDropListener(dropSVGadd);
  drop.addDropListener(dropSVGrep);
  drop.addDropListener(dropIMG);
  drop.addDropListener(dropNFO);
  
  undo = new Memento(gui, 50);

  svg = new ArrayList<PShape>();
  map = new ArrayList<PImage>();
  try { svg.add(loadShape("i/default.svg"));}  catch(NullPointerException e) {svg.add(createShape(RECT, 0, 0, 50, 50));}
  try { ref = loadShape("i/ref.svg");}         catch(NullPointerException e) {showRef = false;}
  try { nfo = loadShape("i/info.svg");}        catch(NullPointerException e) {showNfo = false;}
  try { names = loadStrings("i/names.txt");}   catch(NullPointerException e) {}
  try { helptext = loadStrings("i/help.txt");} catch(NullPointerException e) {} 

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
  println("  |   |_/|_/|_/|_/   |/ v0.2");
  println(" ");
  println("  Press M for menu");
  println("        H for help");
  
  checkArgs();
  ControlP5.DEBUG = false;
}


// ---------------------------------------------------------------------------
//  DRAW
// ---------------------------------------------------------------------------

void draw() {

  if(sequencing) {
    animate();  
  }

  if (keyPressed && key == CODED && keyCode == SHIFT && !shiftPressed) {
    shiftPressed = true;
    enterShiftMode();
  } else if (!keyPressed && shiftPressed) {
    shiftPressed = false;  
    leaveShiftMode();
    last = null;
  }

  if (customStyle) {
    if(customStroke) {
      stroke(strokecolor[0]);
      strokeWeight(customStrokeWeight);
    } else {
       noStroke(); 
    }
    if(customFill) {
      fill(shapecolor[0]);
    } else {
      noFill(); 
    }
  } 

  if (exportCurrentFrame) {
    if(!guiExportNow) {
      formatName = pdfwidth +"x" +pdfheight;
      if(!sequencing && !batchmode) {
        saveSettings(timestamp +"_" +name);
      }
    }
    if(!guiExportNow) {
      filename = outputpath +subfolder +timestamp +"_" +formatName +"_" +name +seqname;
      if(exportFormat) {
        filename += ".pdf";
        pdf = (PGraphicsPDF) createGraphics(pdfwidth, pdfheight, PDF, filename);
      } else {
        filename += ".svg";
        pdf = (PGraphicsSVG) createGraphics(pdfwidth, pdfheight, SVG, filename);
      }
    } else {
      filename = outputpath +subfolder +timestamp +"_" +formatName +"_" +name +seqname +"+GUI";
      if(exportFormat) {
        filename += ".pdf";
        pdf = (PGraphicsPDF) createGraphics(pdfwidth+guiwidth, pdfheight, PDF, filename);        
      } else {
        filename += ".svg";
        pdf = (PGraphicsSVG) createGraphics(pdfwidth+guiwidth, pdfheight, SVG, filename);
      }

    }
    
    beginRecord(pdf); 
    pdf.shapeMode(CENTER);   
    pdf.pushStyle();
    if (customStyle) {
      if(customStroke) {
        pdf.stroke(strokecolor[0]);
        pdf.strokeWeight(customStrokeWeight);
      } else {
        pdf.noStroke(); 
      }
      if(customFill) {
        pdf.fill(shapecolor[0]);
      } else {
        pdf.noFill(); 
      }
    }
   
    if(guiExportNow) { //reset scale to 1 for guiexport
      tmpzoom = zoom;
      scaleGUI(1f);
    }    
    
    pdf.pushMatrix();  
    pdf.scale(1f/zoom);
    
    //saveFrame("frame.png");
  }

  if(bg_copi != null && bg_copi.isOpen()) {
    bgcolorBang.setColorForeground(bgcolor[0]);
    bgcolorSaveLabel.setValue((bgcolor[0]));
  }
  if(customStyle) {
    if(stroke_copi != null && stroke_copi.isOpen()) {
      strokecolorBang.setColorForeground(strokecolor[0]);
      strokecolorSaveLabel.setValue((strokecolor[0]));
    }
    if(shape_copi != null && shape_copi.isOpen()) {
      shapecolorBang.setColorForeground(shapecolor[0]);
      shapecolorSaveLabel.setValue((shapecolor[0]));
    }
  }
  
  pushStyle();
    fill(bgcolor[0]);
    noStroke();
    rect(0, 0, fwidth, fheight);
  popStyle();
  
  if(!exportCurrentFrame || (exportCurrentFrame && guiExportNow)) {
    pushStyle();
      fill(50);
      noStroke();
      rect(fwidth, 0, guiwidth, fheight);
    popStyle();
  }

  if (nfo != null && showNfo && !nfoOnTop) {
    shapeMode(CENTER); 
    pushMatrix(); 
    translate(fwidth/2+manualNFOX, fheight/4*3+manualNFOY);
    scale(zoom);
    shape(nfo);
    popMatrix();
  }
  
  
  abscount = 0;
  if(!linebyline) { tilecount = (xtilenum*ytilenum)-1; } 
  else { tilecount = ytilenum-1; }
  pageOffset = int(absPageOffset * zoom);
  tilewidth  = (float(fwidth -  (2*pageOffset)) / xtilenum);
  tilescale = tilewidth / svg.get(0).width;
  tileheight = svg.get(0).height * tilescale;
  
  randomSeed(seed);

  // ---------------------------------------------------
  // MAIN LOOP
  // ---------------------------------------------------  

  for (int i=0; i< (loopDirection?xtilenum:ytilenum); i++) {
    for (int j=0; j< (loopDirection?ytilenum:xtilenum); j++ ) {
      pushMatrix();
      translate(pageOffset, pageOffset);
      translate(manualOffsetX, manualOffsetY);
      pushMatrix();

      translate( (tilewidth/2)+(tilewidth*(loopDirection?i:j)), (tileheight/2)+(tileheight*(loopDirection?j:i)) ); //swap i/j for xalign/yaligndraw

      if ((mapScale || mapRot || mapTra) && (map.size() != 0 && mapIndex < map.size() && map.get(mapIndex) != null) ) {
        int cropX = (int)map((imgMap.a - imgMap.x), 0, imgMap.ww, 0, map.get(mapIndex).width);
        int cropY = (int)map((imgMap.b - imgMap.y), 0, imgMap.hh, 0, map.get(mapIndex).height);
        int cropW = (int)map(imgMap.e, 0, imgMap.ww, 0, map.get(mapIndex).width ) + cropX;
        int cropH = (int)map(imgMap.f, 0, imgMap.hh, 0, map.get(mapIndex).height) + cropY;

        absScreenX = screenX(0, 0);
        absScreenY = screenY(0, 0);
        absScreenX = map(absScreenX, pageOffset, fwidth-pageOffset, cropX, cropW ) ;
        absScreenY = map(absScreenY, pageOffset, ((float(fwidth-(2*pageOffset)) / fwidth) * fheight)+pageOffset, cropY, cropH );

        try {
          color col = map.get(mapIndex).pixels[(int)constrain(absScreenY, 0, map.get(mapIndex).height)*(int)map.get(mapIndex).width+(int)constrain(absScreenX, 0, map.get(mapIndex).width)];
          if (col == color(0, 255, 0)) {
            popMatrix();
            popMatrix();
            abscount++;
            continue;
          }
          //http://de.wikipedia.org/wiki/Grauwert#In_der_Bildverarbeitung
          mapValue = ((red(col)/255f)*0.299f) + ((green(col)/255f)*0.587f) + ((blue(col)/255f)*0.114f);
          //mapValue = ( brightness(col) /255);
        } 
        catch(Exception e) { //ArrayIndexOutOfBoundsException | NullPointerException
          mapValue = 1f;
        }
      }

      scale(tilescale);

      float xx = absTransX*(map(j, 0f, (float)xtilenum, (float)-xtilenum/2+0.5, (float)xtilenum/2+0.5 ));
      float yy = absTransY*(map(i, 0f, (float)ytilenum, 0, (float)ytilenum ));
      translate(xx, yy );
      if (mapTra && map != null) {
        try {
          float tvx = (invertMap?(1.0-mapValue):mapValue) * ((float)relTransX*10); 
          float tvy = (invertMap?(1.0-mapValue):mapValue) * ((float)relTransY*10); 
          translate( tvx, tvy );
        } 
        catch (ArrayIndexOutOfBoundsException e) {
        }
      } else {
        translate(ease(TRA, abscount, -relTransX, relTransX, tilecount), ease(TRA, abscount, relTransY, -relTransY, tilecount));
      }

      rotate(radians(absRot));
      if (mapRot && map != null) {
        try {
          float rv = mapValue * (relRot); 
          rotate( rv );
        } 
        catch (ArrayIndexOutOfBoundsException e) {
        }
      } else {
        rotate(radians(ease(ROT, abscount, 0, relRot, tilecount)));
      }

      scale(absScale);
      if (mapScale && map != null) {
        try {
          relsca = mapValue * (relScale);
          scale( invertMap ? (1-relsca) : relsca );
        } 
        catch (ArrayIndexOutOfBoundsException e) {
        }
      } else {  
        relsca = ease(SCA, abscount, 1.0, relScale, tilecount);
        scale(relsca);
      }

      //setRelativeStrokeWeight
      if (customStyle && customStroke && !strokeMode) {
        float sw = ((relsca)*(absScale)*(tilescale));
        if(sw != 0f) {
          sw = abs(customStrokeWeight*(1/sw));
        } else {
          sw = 0f; 
        }

        stroke(strokecolor[0]);
        strokeWeight(sw);
        if (exportCurrentFrame) {
          pdf.stroke(strokecolor[0]);
          pdf.strokeWeight(sw);
        }
      }

      if (random) {
        s = svg.get(int(random(svg.size())));
      } else {
        s = svg.get( (((loopDirection?ytilenum:xtilenum)*i)+j)%svg.size() );
      }
      if (s != null) {
        shape(s);
      }

      popMatrix();
      popMatrix();
      if(!linebyline) {
        abscount++;
      }
    } //for j
    if(linebyline) {
      abscount++;
    }
  } //for i
  
  // ---------------------------------------------------
  
  if (nfo != null && showNfo && nfoOnTop) {
    shapeMode(CENTER); 
    pushMatrix(); 
    translate(fwidth/2+manualNFOX, fheight/4*3+manualNFOY);
    scale(zoom);
    shape(nfo);
    popMatrix();
  }
  
  if(exportCurrentFrame && guiExportNow) { 
    if (ref != null && showRef) {
      shapeMode(CORNER);
      shape(ref, 0, 0, fwidth, fheight);
    }
    gui.getWindow().draw(pdf);
    scaleGUI(tmpzoom); //recreate prev zoom
    tmpzoom = 0f;
  }

  if (exportCurrentFrame) {
    pdf.popMatrix(); 
    pdf.popStyle();
    endRecord();  
    println(filename +" exported!");
    if(batchmode && batchnow) {
      exit();  
    }
    if(guiExport && !guiExportNow) {
      guiExportNow = true;
    } else if(guiExport && guiExportNow){
      guiExportNow = false;
      exportCurrentFrame = false;
    } else if(!guiExport) {
      exportCurrentFrame = false;
    }
  }

  if(!exportCurrentFrame) {
    if (ref != null && showRef) {
      shapeMode(CORNER);
      shape(ref, 0, 0, fwidth, fheight);
    }  
    gui.draw();
  }

  if(batchmode) {
    if(batchwait > 0) {
       batchwait--; 
    } else {
      generateName();
      generateTimestamp();
      batchnow = true;
      exportCurrentFrame = true;
    }
  }
  
  shapeMode(CENTER);
  noStroke();
  
  dropSVGadd.draw();
  dropSVGrep.draw();
  dropIMG.draw();
  dropNFO.draw();
 
 if(showHELP) {
   fpsLabel.setText(str((int)frameRate));
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
  if ((mouseX <= fwidth) && (mouseY <= fheight)) {
    dragAllowed = true;
    pmouseX = mouseX;
    pmouseY = mouseY;
  }
}

void mouseDragged ( ) {
  if (dragAllowed && mouseButton == LEFT) {
    manualOffsetX -= pmouseX-mouseX;
    manualOffsetY -= pmouseY-mouseY;
    dragOffset.setText("OFFSET: " +(int)manualOffsetX +" x " +(int)manualOffsetY);
    offsetxSaveLabel.setValue(manualOffsetX);
    offsetySaveLabel.setValue(manualOffsetY);
  } else if(dragAllowed && mouseButton == RIGHT) {
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
  } else if (keysDown['Z']) {
    undo.undo();
  } else if (keysDown['Y']) {
    undo.redo();
  } else if (keysDown['S']) {
    exportCurrentFrame = true;
    generateName();
    generateTimestamp();
  } else if (keysDown['M']) {
    toggleMenu();
  } else if (keysDown['0']) {
    toggleSettings();
  } else if (keysDown['X']) {
    loopDirection = !loopDirection;
    loopDirectionSaveLabel.setValue((int(loopDirection)));
  } else if (keysDown['R']) {
    toggleRandom();
  } else if (keysDown['L']) {
    linebyline = !linebyline;
    linebylineSaveLabel.setValue((int(linebyline)));
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
  }
  
}

void keyReleased() {
  processKey(keyCode, false);
}

void mouseWheel(MouseEvent event) {
  float e = event.getAmount();
  menuScroll((int)e);
  gui.setMouseWheelRotation((int)e);
}

static void processKey(int k, boolean set) {
  if (k < KEYS)  keysDown[k] = set;
}