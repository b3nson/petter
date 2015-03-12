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
import penner.easing.*;
import controlP5.*;
import sojamo.drop.*;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;

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
PGraphicsPDF pdf;

String settingspath = "i/settings/";
String outputpath = "o/";
String subfolder = "";
String[] names;
String[] helptext;
String name;

ArrayList<PShape> svg;
PShape ref;
PShape nfo;
PShape s;
PImage map;

int absPageOffset = 25;
int pageOffset = 25;
int manualOffsetX = 0;
int manualOffsetY = 0;
int manualNFOX = 0;
int manualNFOY = 0;
int xtilenum = 8;
int ytilenum = 10;
float tilewidth, tileheight, tilescale;
float absTransX = 0;
float absTransY = 0;
float absScreenX;
float absScreenY;

float zoom = 1.0;
float relTransX = 0;
float relTransY = 0;
float absRot = 0;
float relRot = 90;
float absScale = 1.0;
float relScale = 0.0;
float relsca = 0.0;
boolean mapScale = false;
boolean mapRot = false;
boolean mapTra = false;
boolean invertMap = false;
boolean strokeMode = true;
boolean stroke = true;
boolean fill = true;
boolean random = false;
boolean dragAllowed = false;
boolean showRef = false;
boolean showNfo = false;
boolean nfoOnTop = true;
boolean guiExport = false;
boolean guiExportNow = false;
boolean sequencing = false;
int seed = 0;
float mapValue = 0f;

int abscount = 0;
boolean xaligndraw = false;
boolean shift = false;
int rotType = 0;
int scaType = 0;
int traType = 0;
int animType = 0;

boolean exportCurrentFrame = false;
String timestamp = "";
String filename = "";
String formatName = "";

boolean disableStyle = false;
float strokeWeight = 2.0;
color[] bgcolor = {color(10,125,100)};
color[] strokecolor = {color(0,0,0)};
color[] shapecolor = {color(255,255,255)};

boolean pageOrientation = true;
String[][] formats = { 
  { "A5", "437", "613" },
  { "A4", "595", "842" },
  { "A3", "842", "1191" },
  { "A2", "1191", "1684" },
  { "Q1", "800", "800" }
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
  size(fwidth+(showMENU?guiwidth:0), fheight);
  if (frame != null) {
    frame.setResizable(true);
  } 
  
  smooth();
  shapeMode(CENTER);
  
  PFont pfont = createFont("i/fonts/PFArmaFive.ttf", 8, false);
  ControlFont font = new ControlFont(pfont);

  gui = new ControlP5(this, font);
  gui.setAutoDraw(false);
  drop = new SDrop(this);  
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
  try { svg.add(loadShape("i/default.svg"));}  catch(NullPointerException e) {svg.add(createShape(RECT, 0, 0, 50, 50));} //<>//
  try { ref = loadShape("i/ref.svg");}         catch(NullPointerException e) {showRef = false;} //<>//
  try { nfo = loadShape("i/info.svg");}        catch(NullPointerException e) {showNfo = false;} //<>//
  //try { map = loadImage("album.jpg");}         catch(NullPointerException e) {}
  try { names = loadStrings("i/names.txt");}   catch(NullPointerException e) {} //<>//
  try { helptext = loadStrings("i/help.txt");} catch(NullPointerException e) {} //<>// //<>// //<>// //<>// //<>// //<>// //<>//

  setupGUI(); //<>//

  pageOffsetSlider.setValue(absPageOffset);
  formatDropdown.setIndex(2);
  penner_rot.setValue(rotType);
  penner_sca.setValue(scaType);
  penner_tra.setValue(traType);
  penner_anim.setValue(animType);
  showRefToggle.setState(showRef);
  showNfoToggle.setState(showNfo);
  nfoLayerToggle.setState(nfoOnTop);
  last = null;

  undo.setUndoStep();
  
  println("  , _");
  println(" /|/ \\ __|__|_  _  ,_");
  println("  |__/|/ |  |  |/ /  |");
  println("  |   |_/|_/|_/|_/   |/ v0.2");
  println(" ");
  println("  Press M for menu");
  println("        H for help");
}


// ---------------------------------------------------------------------------
//  DRAW
// ---------------------------------------------------------------------------

void draw() {
  
  if(sequencing) {
    animate();  
  }
  
  pageOffset = int(absPageOffset * zoom);

  if (keyPressed && key == CODED && keyCode == SHIFT && !shiftPressed) {
    shiftPressed = true;
    enterShiftMode();
  } else if (!keyPressed && shiftPressed) {
    shiftPressed = false;  
    leaveShiftMode();
    last = null;
  }
  if (settingsBoxOpened) {
    catchMouseover();
  }

  if (disableStyle) {
    if(stroke) {
      stroke(strokecolor[0]);
      strokeWeight(strokeWeight);
    } else {
       noStroke(); 
    }
    if(fill) {
      fill(shapecolor[0]);
    } else {
      noFill(); 
    }
  } 

  if (exportCurrentFrame) {
    formatName = pdfwidth +"x" +pdfheight;
    if(!guiExportNow) {
      timestamp = year() +"" +nf(month(), 2) +"" +nf(day(), 2) +"" +"-" +nf(hour(), 2) +"" +nf(minute(), 2) +"" +nf(second(), 2);
      if(!sequencing) {
        saveSettings(timestamp +"_" +name);
      }
    }
    if(!guiExportNow) {
      filename = outputpath +subfolder +timestamp +"_" +formatName +"_" +name +seqname +".pdf";//+"_petter.pdf";
      pdf = (PGraphicsPDF) createGraphics(pdfwidth, pdfheight, PDF, filename);
    } else {
      filename = outputpath +subfolder +timestamp +"_" +formatName +"_" +name +seqname +"+GUI.pdf";//+"_petter+GUI.pdf";
      pdf = (PGraphicsPDF) createGraphics(pdfwidth+(guiwidth), pdfheight, PDF, filename);
    }
    
    beginRecord(pdf); 
    pdf.shapeMode(CENTER);   
    pdf.pushStyle();
    if (disableStyle) {
      if(stroke) {
        pdf.stroke(strokecolor[0]);
        pdf.strokeWeight(strokeWeight);
      } else {
        pdf.noStroke(); 
      }
      if(fill) {
        pdf.fill(shapecolor[0]);
      } else {
        pdf.noFill(); 
      }
    }
    pdf.pushMatrix();  
    pdf.scale(1f/zoom);
    //pdf.scale((float)Math.pow(1.41, pdfSize-1));
    
    //saveFrame("frame.png");
  }

  if(bg_copi != null && bg_copi.isOpen()) {
    bgcolorBang.setColorForeground(bgcolor[0]);
  }
  if(disableStyle) {
    if(stroke_copi != null && stroke_copi.isOpen()) {
      strokecolorBang.setColorForeground(strokecolor[0]);
    }
    if(shape_copi != null && shape_copi.isOpen()) {
      shapecolorBang.setColorForeground(shapecolor[0]);
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

  abscount = 0;

  tilewidth  = (float(fwidth -  (2*pageOffset)) / xtilenum);
  tilescale = tilewidth / svg.get(0).width;
  tileheight = svg.get(0).height * tilescale;

  if (nfo != null && showNfo && !nfoOnTop) {
    pushMatrix(); 
    translate(fwidth/2+manualNFOX, fheight/4*3+manualNFOY);
    scale(zoom);
    shape(nfo);
    popMatrix();
  }
  
  randomSeed(seed);

  // ---------------------------------------------------
  // MAIN LOOP
  // ---------------------------------------------------  
  
  for (int i=0; i< (xaligndraw?xtilenum:ytilenum); i++) {
    for (int j=0; j< (xaligndraw?ytilenum:xtilenum); j++) {
      pushMatrix();
      translate(pageOffset, pageOffset);
      translate(manualOffsetX, manualOffsetY);
      pushMatrix();

      translate( (tilewidth/2)+(tilewidth*(xaligndraw?i:j)), (tileheight/2)+(tileheight*(xaligndraw?j:i)) ); //swap i/j for xalign/yaligndraw

      if ((mapScale || mapRot || mapTra) && map != null) {

        int cropX = (int)map((imgMap.a - imgMap.x), 0, imgMap.ww, 0, map.width);
        int cropY = (int)map((imgMap.b - imgMap.y), 0, imgMap.hh, 0, map.height);
        int cropW = (int)map(imgMap.e, 0, imgMap.ww, 0, map.width ) + cropX;
        int cropH = (int)map(imgMap.f, 0, imgMap.hh, 0, map.height) + cropY;

        absScreenX = screenX(0, 0);
        absScreenY = screenY(0, 0);
        absScreenX = map(absScreenX, pageOffset, fwidth-pageOffset, cropX, cropW ) ;
        absScreenY = map(absScreenY, pageOffset, ((float(fwidth-(2*pageOffset)) / fwidth) * fheight)+pageOffset, cropY, cropH );

        try {
          color col = map.pixels[(int)constrain(absScreenY, 0, map.height)*(int)map.width+(int)constrain(absScreenX, 0, map.width)];
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
        catch(ArrayIndexOutOfBoundsException e) {
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
        translate(ease(TRA, abscount, -relTransX, relTransX, ((xtilenum*ytilenum)-1)), ease(TRA, abscount, relTransY, -relTransY, ((xtilenum*ytilenum)-1)));
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
        rotate(radians(ease(ROT, abscount, 0, relRot, ((xtilenum*ytilenum)-1))));
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
        relsca = ease(SCA, abscount, 1.0, relScale, ((xtilenum*ytilenum)-1));
        scale(relsca);
      }

      //setRelativeStrokeWeight
      if (disableStyle && stroke && !strokeMode) {
        float sw = ((relsca)*(absScale)*(tilescale));
        if(sw != 0f) {
          sw = abs(strokeWeight*(1/sw));
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
        s = svg.get( (((xaligndraw?ytilenum:xtilenum)*i)+j)%svg.size() );
      }
      if (s != null) {
        shape(s);
      }

      popMatrix();
      popMatrix();
      abscount++;
    } //for j
  } //for i
  
  // ---------------------------------------------------

  if (nfo != null && showNfo && nfoOnTop) {
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
    gui.draw();
  }
  
  if (exportCurrentFrame) {
    pdf.popMatrix(); 
    pdf.popStyle();
    endRecord();  
    println(filename +" exported!");
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

  shapeMode(CENTER);
  noStroke();
  
  dropSVGadd.draw();
  dropSVGrep.draw();
  dropIMG.draw();
  dropNFO.draw();
  //dragOffset.draw();
}//DRAW END


// ---------------------------------------------------------------------------
//  INPUT EVENTS
// ---------------------------------------------------------------------------

void mouseMoved() {
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
    dragOffset.setText("OFFSET: " +manualOffsetX +" x " +manualOffsetY);
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
  } else if (keysDown['X']) {
    xaligndraw = !xaligndraw;
  } else if (keysDown['S']) {
    exportCurrentFrame = true;
    generateName();
  } else if (keysDown['M']) {
    toggleMenu();
  } else if (keysDown['0']) {
    toggleSettings();
  } else if (keysDown['R']) {
    toggleRandom();
  } else if (keysDown['G']) {
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
  }
  
}

void keyReleased() {
  processKey(keyCode, false);
}

void mouseWheel(MouseEvent event) {
  float e = event.getAmount();
  gui.setMouseWheelRotation((int)e);
}

static void processKey(int k, boolean set) {
  if (k < KEYS)  keysDown[k] = set;
}
