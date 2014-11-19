import processing.pdf.*;
import penner.easing.*;
import controlP5.*;
import sojamo.drop.*;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;


static int ROT = 0;
static int TRA = 1;
static int SCA = 2;
static int CS = 0;
static int A4 = 1;
static int A3 = 2;
static int A2 = 3;

final static int KEYS = 0500;
final static boolean[] keysDown = new boolean[KEYS];

ControlP5 gui;
SDrop drop;
DropTargetSVG dropSVGadd;
DropTargetSVG dropSVGrep;
DropTargetIMG dropIMG;
DropTargetNFO dropNFO;
Memento undo;
PGraphicsPDF pdf;

String settingspath = "i/settings/";
String outputpath = "o/";

ArrayList<PShape> svg;
PShape ref;
PShape nfo;
PShape s;
PImage map;

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
boolean strokeMode = false;
boolean random = false;
boolean dragAllowed = false;
boolean showRef = false;
boolean showNfo = false;
boolean guiExport = false;
boolean guiExportNow = false;
int seed = 0;
float mapValue = 0f;

int abscount = 0;
boolean xaligndraw = false;
boolean shift = false;
int rotType = 0;
int scaType = 0;
int traType = 0;

boolean exportCurrentFrame = false;
String timestamp = "";
String filename = "";
String formatName = "";
int pdfSize = CS;

boolean disableStyle = false;
float strokeWeight = 1.0;
int fillColor = 128;

boolean pageOrientation = true;
int[][] formats = { 
  {
    437, 613
  }
  , {
    595, 842
  }
  , {
    842, 1191
  }
  , {
    1191, 1684
  }
};
//int fwidth = 595;
//int fheight = 842;
int fwidth = 600; //ausnahme für customformat von constant
int fheight = 842;
int guiwidth = 310;


void setup() {  
  frameRate(25);
  size(fwidth, fheight);   //A4 595x842   A3 842x1191  A2 1191x1684
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
  undo = new Memento(gui, 35);

  svg = new ArrayList<PShape>();
  try {
    svg.add(loadShape("i/default.svg"));
    ref = loadShape("i/ref.svg");
    nfo = loadShape("i/info.svg");
    //map = loadImage("album.jpg");
  } 
  catch(NullPointerException e) {
  }

  setupGUI();

  if (ref != null) showRef = true;
  if (nfo != null) showNfo = true;
  pageOffsetSlider.setValue(pageOffset);
  penner_rot.setValue(rotType);
  penner_sca.setValue(scaType);
  penner_tra.setValue(traType);
  pdfSizeButton.activate(pdfSize);
  showRefToggle.setState(showRef);
  showNfoToggle.setState(showNfo);
  last = null;
  //mapScaleToggle.setValue(mapScale);
  //mapRotToggle.setValue(mapRot);

  undo.setUndoStep();
}

void draw() {
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
    strokeWeight(strokeWeight);
    fill(fillColor);
  } 

  if (exportCurrentFrame) {
    if(!guiExportNow) {
      timestamp = year() +"" +nf(month(), 2) +"" +nf(day(), 2) +"" +"-" +nf(hour(), 2) +"" +nf(minute(), 2) +"" +nf(second(), 2);
      saveSettings(timestamp);
    }
    
    if(!guiExportNow) {
      filename = outputpath +timestamp +"_" +formatName +"_petter.pdf";
      pdf = (PGraphicsPDF) createGraphics(formats[pdfSize][pageOrientation?0:1], formats[pdfSize][pageOrientation?1:0], PDF, filename);
    } else {
      filename = outputpath +timestamp +"_" +formatName +"_petter+GUI.pdf";
      pdf = (PGraphicsPDF) createGraphics(int(formats[pdfSize][pageOrientation?0:1]+(guiwidth*0.75)), formats[pdfSize][pageOrientation?1:0], PDF, filename);
    }
    
    beginRecord(pdf); 
    pdf.shapeMode(CENTER);   
    pdf.pushStyle();
    if (disableStyle) {
      pdf.strokeWeight(strokeWeight);
      pdf.fill(fillColor);
    }
    pdf.pushMatrix();  
    if (pdfSize == CS) {
      pdf.scale(0.7345);
    } else {
      pdf.scale((float)Math.pow(1.41, pdfSize-1));
    }
    
    //saveFrame("frame.png");
  }

  pushStyle();
  fill(0);
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

  randomSeed(seed);

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
            //popMatrix();
            //popMatrix();
            abscount++;
            continue;
          }
          mapValue = ( brightness(col) /255);
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
          float sv = mapValue * (relScale);
          scale( invertMap ? (1-sv) : sv );
        } 
        catch (ArrayIndexOutOfBoundsException e) {
        }
      } else {  
        relsca = ease(SCA, abscount, 1.0, relScale, ((xtilenum*ytilenum)-1));
        scale(relsca);
      }

      //setRelativeStrokeWeight
      if (disableStyle && strokeMode) {
        float sw = abs(strokeWeight*(1/((relsca==0.0?1:relsca)*(absScale==0f?1:absScale)*(tilescale==0f?1:tilescale))));
        strokeWeight(sw);
        if (exportCurrentFrame) {
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
  
  if (nfo != null && showNfo) {
    shape(nfo, fwidth/2+manualNFOX, fheight/4*3+manualNFOY);
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

  dropSVGadd.draw();
  dropSVGrep.draw();
  dropIMG.draw();
  dropNFO.draw();
  //dragOffset.draw();
}


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
  }
}

void keyReleased() {
  processKey(keyCode, false);
}

static void processKey(int k, boolean set) {
  if (k < KEYS)  keysDown[k] = set;
}

void mouseWheel(MouseEvent event) {
  float e = event.getAmount();
  gui.setMouseWheelRotation((int)e);
}


//void dropEvent(DropEvent theDropEvent) {}

  void toggleSvgStyle() {
    if (!disableStyle) {
      for (int i = 0; i < svg.size (); i++) {
        svg.get(i).disableStyle();
      }
    } else {
      for (int i = 0; i < svg.size (); i++) {
        svg.get(i).enableStyle();
      }
    }
  }

void toggleRandom() {
  random = !random;
  seed = mouseX;
}

float ease(int type, float a, float b, float c, float d) {
  if (type == ROT) {
    type = rotType;
  } else if (type == TRA) {
    type = traType;
  } else {
    type = scaType;
  }

  switch(type) {
  case 0:
    return Linear.easeIn    (a, b, c, d);
  case 1:
    return Linear.easeOut   (a, b, c, d);
  case 2:
    return Linear.easeInOut (a, b, c, d);
  case 3:
    return Quad.easeIn     (a, b, c, d);
  case 4:
    return Quad.easeOut    (a, b, c, d);
  case 5:
    return Quad.easeInOut  (a, b, c, d);
  case 6:
    return Cubic.easeIn    (a, b, c, d);
  case 7:
    return Cubic.easeOut   (a, b, c, d);
  case 8:
    return Cubic.easeInOut (a, b, c, d);
  case 9:
    return Quart.easeIn    (a, b, c, d);
  case 10:
    return Quart.easeOut   (a, b, c, d);
  case 11:
    return Quart.easeInOut (a, b, c, d);
  case 12:
    return Quint.easeIn    (a, b, c, d);
  case 13:
    return Quint.easeOut   (a, b, c, d);
  case 14:
    return Quint.easeInOut (a, b, c, d);
  case 15:
    return Sine.easeIn    (a, b, c, d);
  case 16:
    return Sine.easeOut   (a, b, c, d);
  case 17:
    return Sine.easeInOut (a, b, c, d);
  case 18:
    return Circ.easeIn    (a, b, c, d);
  case 19:
    return Circ.easeOut   (a, b, c, d);
  case 20:
    return Circ.easeInOut (a, b, c, d);
  case 21:
    return Expo.easeIn    (a, b, c, d);
  case 22:
    return Expo.easeOut   (a, b, c, d);
  case 23:
    return Expo.easeInOut (a, b, c, d);
  case 24:
    return Back.easeIn    (a, b, c, d);
  case 25:
    return Back.easeOut   (a, b, c, d);
  case 26:
    return Back.easeInOut (a, b, c, d);
  case 27:
    return Bounce.easeIn    (a, b, c, d);
  case 28:
    return Bounce.easeOut   (a, b, c, d);
  case 29:
    return Bounce.easeInOut (a, b, c, d);
  case 30:
    return Elastic.easeIn    (a, b, c, d);
  case 31:
    return Elastic.easeOut   (a, b, c, d);
  case 32:
    return Elastic.easeInOut (a, b, c, d);
  default:
    return 0.0;
  }
}
