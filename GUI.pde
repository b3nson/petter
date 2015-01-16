import java.util.List;
import java.awt.Insets;

CallbackListener cb;
GuiImage imgMap;
Insets insets;

boolean showMENU = false;

int c = 0;
int d = 0;

int indentX = 0;
int indentY = 10;
int gapX = 10;
int gapY = 22;
int ypos = 0;
int sep = 30;
int h = 20;
int w = 180;
int imgMapHeight = 0;
int tickMarks = 11;

//color c1 = color(218, 78, 57);    // red
color c1 = color(16, 181, 198);    // blue
color c2 = color(60, 105, 97, 180);// green
color c3 = color(200, 200, 200);  //lightgray for separatorlines

ArrayList settingFiles;

Boolean settingsBoxOpened = false;
Boolean shiftPressed = false;
Boolean shiftProcessed = false;

Slider last;
Slider xTileNumSlider, yTileNumSlider, pageOffsetSlider, absTransXSlider, absTransYSlider, relTransXSlider, relTransYSlider, absRotSlider, relRotSlider, absScaSlider, relScaSlider, strokeWeightSlider;
Group main, style;
DropdownList penner_rot, penner_sca, penner_tra, formatDropdown;
ListBox settingsFilelist;
Button currentOver;
Button imageMapButton, closeImgMapButton;
Bang bgcolorBang;
Toggle mapScaleToggle, mapRotToggle, mapTraToggle, invertMapToggle, pageOrientationToggle, showRefToggle, showNfoToggle, showGuiExportToggle, strokeModeToggle;
Textlabel dragOffset, zoomLabel;
Numberbox wBox, hBox;



void setupGUI() {
  gui.setColorActive(c1);
  gui.setColorBackground(color(100));
  gui.setColorForeground(color(50));
  gui.setColorLabel(color(0, 255, 0));
  gui.setColorValue(color(255, 0, 0));
  gui.setColorCaptionLabel(color(255, 255, 255));
  gui.setColorValueLabel(color(255, 255, 255));

  gui.enableShortcuts();  
  
  println("setupGUI");
  main = gui.addGroup("main")
           .setPosition(fwidth+12,10)
           .hideBar()
           //.setBackgroundHeight(height-38)
           //.setWidth(guiwidth-24)
           //.setBackgroundWidth(guiwidth-12)
           //.setBackgroundColor(color(255,50))
           .close()
           ;
   
  ypos += 10;
  
  formatDropdown = gui.addDropdownList("formats")
     .setGroup(main)
     .setPosition(indentX, ypos+21)
     .setSize(54, 300)
     .setItemHeight(h)
     .setBarHeight(h)
     //.activateEvent(true)
     .setBackgroundColor(color(190))
     //.addItems(formatsx)
     ;
  addFormatItems(formatDropdown);
  formatDropdown.captionLabel().style().marginTop = h/4+1;

     
  wBox = gui.addNumberbox("width")
     .setPosition(indentX+67, ypos)
     .setSize(34, h)
     .setLabel("")
     .setRange(20,2000)
     .setDecimalPrecision(0) 
     //.setMultiplier(0.1) // set the sensitifity of the numberbox
     .setValue(pdfwidth)
     .setLock(true)
     .setLabelVisible(false)
     .setGroup(main)
     ;

  hBox = gui.addNumberbox("height")
     .setPosition(indentX +107, ypos)
     .setSize(34, h)
     .setLabel("")
     .setRange(20,2000)
     .setDecimalPrecision(0) 
     //.setMultiplier(0.1) // set the sensitifity of the numberbox
     .setValue(pdfheight)
     .setLock(true)
     .setGroup(main)
     ;

   pageOrientationToggle = gui.addToggle("pageOrientation")
     .setLabel("p/l")
     .setPosition(indentX+8*h, ypos)
     .setSize(h, h)
     .setValue(true)
     .setGroup(main)
     ;
     styleLabel(pageOrientationToggle, "p/l");
     
  ypos += sep;
  

   showRefToggle = gui.addToggle("showRef")
     .setLabel("REF")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setValue(false)
     .setGroup(main)
     ;
     styleLabel(showRefToggle, "REF");
   indentX += h*2;

   showNfoToggle = gui.addToggle("showNfo")
     .setLabel("NFO")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setValue(false)
     .setGroup(main)
     ;
     styleLabel(showNfoToggle, "NFO");
   indentX += h*4;

   showGuiExportToggle = gui.addToggle("guiExport")
     .setLabel("GUIEXP")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setValue(false)
     .setGroup(main)
     ;
     styleLabel(showGuiExportToggle, "GUIEXP");
   indentX += h*2;
 
   bgcolorBang = gui.addBang("changebgcolor")
     .setLabel("BG")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setGroup(main)
     ;
     styleLabel(bgcolorBang, "BG");
   indentX = 0;
 
   
  ypos += sep;

   pageOffsetSlider = gui.addSlider("absPageOffset")
     .setLabel("pageOffset")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(0,250) // values can range from big to small as well
     .setSliderMode(Slider.FLEXIBLE)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ;
     styleLabel(pageOffsetSlider, "offset");
  ypos += sep;

   xTileNumSlider = gui.addSlider("xtilenum")
     .setLabel("xtilenum")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(0,180) // values can range from big to small as well
     .setSliderMode(Slider.FLEXIBLE)
     .setGroup(main)
     ;
     styleLabel(xTileNumSlider, "xtilenum   (LEFT/RIGHT)");
  ypos += gapY;


  yTileNumSlider = gui.addSlider("ytilenum")
     .setLabel("ytilenum")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(0,260) // values can range from big to small as well
     .setSliderMode(Slider.FLEXIBLE)
     .setGroup(main)
     ;   
     styleLabel(yTileNumSlider, "ytilenum   (UP/DOWN)");
  ypos += sep;
  



  absTransXSlider = gui.addSlider("absTransX")
     .setLabel("global trans X")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(-400,400)
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.004)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ;  
     styleLabel(absTransXSlider, "global trans X");     
  ypos += gapY;
  
  absTransYSlider = gui.addSlider("absTransY")
     .setLabel("global trans Y")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(-400,400)
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.004)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ;
     styleLabel(absTransYSlider, "global trans Y");   
  ypos += gapY;
  
  relTransXSlider = gui.addSlider("relTransX")
     .setLabel("relative trans x")
     .setPosition(indentX,ypos)
     .setSize(w,h)
     .setRange(-400, 400)
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.005)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ;  
     styleLabel(relTransXSlider, "relative trans X");
  ypos += gapY;
  
  relTransYSlider = gui.addSlider("relTransY")
     .setLabel("relative trans y")
     .setPosition(indentX,ypos)
     .setSize(w,h)
     .setRange(-400, 400)
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.005)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ;  
     styleLabel(relTransYSlider, "relative trans Y");
  ypos += gapY+gapY;
  
  penner_tra = gui.addDropdownList("traType")
     .setGroup(main)
     .setPosition(indentX,ypos)
     .setSize(w, 300)
     .setItemHeight(h)
     .setBarHeight(h)
     .activateEvent(true)
     .setBackgroundColor(color(190))
     ;
  addItems(penner_tra);
  penner_tra.captionLabel().style().marginTop = h/4+1;

  ypos += sep/2;








  absRotSlider = gui.addSlider("absRot")
     .setLabel("global rot")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(-180,180)
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.003)
     .setNumberOfTickMarks(17)
     .showTickMarks(false)
     .snapToTickMarks(false)
     .setGroup(main)
     ;  
     styleLabel(absRotSlider, "global rot");

  ypos += gapY;

  relRotSlider = gui.addSlider("relRot")
     .setLabel("relative rot")
     .setPosition(indentX,ypos)
     .setSize(w,h)
     .setRange(0,360)
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.003)
     .setNumberOfTickMarks(17)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ;  
     styleLabel(relRotSlider, "relative rot");

  ypos += gapY+gapY;

  penner_rot = gui.addDropdownList("rotType")
     .setGroup(main)
     .setPosition(indentX,ypos)
     .setSize(w, 300)
     .setItemHeight(h)
     .setBarHeight(h)
     .activateEvent(true)
     .setBackgroundColor(color(190))     
     ;
  addItems(penner_rot);
  penner_rot.captionLabel().style().marginTop = h/4+1;
  ypos += sep/2;





  absScaSlider = gui.addSlider("absScale")
     .setLabel("global scale")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(-5.0,5.0) // values can range from big to small as well
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.01)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ;  
     styleLabel(absScaSlider, "global scale");
  ypos += gapY;
 
  relScaSlider = gui.addSlider("relScale")
     .setLabel("relative scale")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(-5.0,5.0) // values can range from big to small as well
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.01)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ; 
     styleLabel(relScaSlider, "relative scale");
  ypos += gapY+gapY;

  penner_sca = gui.addDropdownList("scaType")
     .setGroup(main)
     .setPosition(indentX,ypos)
     .setSize(w, 300)
     .setItemHeight(h)
     .setBarHeight(h)
     .activateEvent(true)
     .setBackgroundColor(color(190))
     ;
  addItems(penner_sca);
  penner_sca.captionLabel().style().marginTop = h/4+1;
  ypos += sep;



  imgMap = new GuiImage(indentX, ypos);
  imgMap.pre();
  main.addCanvas(imgMap);

  ypos -= gapY-2;

  mapScaleToggle = gui.addToggle("sca")
     .setValue(mapScale)
     .setPosition(indentX,ypos)
     .setSize(h,h)
     .setGroup(main)
     .setLabel("S")
     .hide();
     ;
   mapScaleToggle.getCaptionLabel().setPadding(8,-14);

  mapRotToggle = gui.addToggle("rot")
     .setValue(mapRot)
     .setPosition(indentX +1*h,ypos)
     .setSize(h,h)
     .setGroup(main)
     .setLabel("R")
     .hide()
     ;
   mapRotToggle.getCaptionLabel().setPadding(8,-14);

  mapTraToggle = gui.addToggle("tra")
     .setValue(mapTra)
     .setPosition(indentX +2*h,ypos)
     .setSize(h,h)
     .setGroup(main)
     .setLabel("T")
     .hide()
     ;
   mapTraToggle.getCaptionLabel().setPadding(8,-14);
     
  invertMapToggle = gui.addToggle("invertMap")
     .setValue(invertMap)
     .setPosition(indentX +4*h,ypos)
     .setSize(h,h)
     .setGroup(main)
     .setLabel("I")
     .hide()
     ;
   invertMapToggle.getCaptionLabel().setPadding(8,-14);

  closeImgMapButton = gui.addButton("X")
     .setValue(0)
     .setPosition(indentX+w-h,ypos)
     .setSize(h, h)
     .setGroup("main")
     .hide()
     ;
   closeImgMapButton.getCaptionLabel().setPadding(8,-14);

 ypos += gapY+imgMapHeight;
  
 style = gui.addGroup("style")
           .setPosition(indentX,ypos)
           .setBackgroundHeight(100)
           .activateEvent(true)
           .setGroup(main)
           //.close()
           ;
  if(disableStyle) style.open();
  else style.close();
  
  ypos += gapY;
  
  strokeModeToggle = gui.addToggle("strokeMode")
     .setValue(strokeMode)
     .setPosition(indentX,indentY)
     .setSize(h,h)
     .setGroup(style)
     ;
  
  strokeWeightSlider = gui.addSlider("strokeWeight")
     .setLabel("strokeWeight")
     .setPosition(indentX+h+h/2,indentY)
     .setSize(w-h-h/2,h)
     .setRange(0f,25.0) // values can range from big to small as well
     .setSliderMode(Slider.FLEXIBLE)
     .setGroup(style)
     ;   
     styleLabel(strokeWeightSlider, "strokeWeight");
  ypos += gapY;

 gui.addColorPicker("fillColor")
     .setPosition(indentX,indentY+gapY)
     .setColorValue(color(255, 255, 255, 255))
     .setGroup(style)
    ;     
  
  cb = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
       callbackEvent(theEvent);
    }
  }; 
  gui.addCallback(cb);
  
  formatDropdown.bringToFront();
  penner_sca.bringToFront();
  penner_rot.bringToFront();
  penner_tra.bringToFront();
  
  
  ControllerProperties cprop = gui.getProperties();
  cprop.remove(closeImgMapButton);
  cprop.remove(bgcolorBang);
  //cprop.remove(pageOrientationToggle);
  //cprop.remove(invertMapToggle);
  //cprop.remove(mapScaleToggle);
  //cprop.remove(mapRotToggle);
  //cprop.remove(mapTraToggle); 


  dragOffset = gui.addTextlabel("dragoffset" )
     .setPosition(indentX, fheight-31)
     .setText("OFFSET: 0 x 0")
     .setGroup(main)
     ;

  zoomLabel = gui.addTextlabel("zoomlabel" )
     .setPosition(indentX+guiwidth-70, fheight-31)
     .setText("ZOOM: 1.0")
     .setGroup(main)
     ;

} //setupGUI



void addFormatItems(DropdownList l) {
  l.addItem("CUSTOM",  0);
  for(int i=0; i<formats.length; i++) {
    println(formats[i][0]);
    l.addItem(formats[i][0], i+1);
  }
}

void addItems(DropdownList l) {
l.addItem("Linear.easeIn   ",  0);
l.addItem("Linear.easeOut  ",  1);
l.addItem("Linear.easeInOut",  2);
l.addItem("Quad.easeIn     ",  3);
l.addItem("Quad.easeOut    ",  4);
l.addItem("Quad.easeInOut  ",  5);
l.addItem("Cubic.easeIn    ",  6);
l.addItem("Cubic.easeOut   ",  7);
l.addItem("Cubic.easeInOut ",  8);
l.addItem("Quart.easeIn    ",  9);
l.addItem("Quart.easeOut   ",  10);
l.addItem("Quart.easeInOut ",  11);
l.addItem("Quint.easeIn    ",  12);
l.addItem("Quint.easeOut   ",  13);
l.addItem("Quint.easeInOut ",  14);
l.addItem("Sine.easeIn     ",  15);
l.addItem("Sine.easeOut    ",  16);
l.addItem("Sine.easeInOut  ",  17);
l.addItem("Circ.easeIn     ",  18);
l.addItem("Circ.easeOut    ",  19);
l.addItem("Circ.easeInOut  ",  20);
l.addItem("Expo.easeIn     ",  21);
l.addItem("Expo.easeOut    ",  22);
l.addItem("Expo.easeInOut  ",  23);
l.addItem("Back.easeIn     ",  24);
l.addItem("Back.easeOut    ",  25);
l.addItem("Back.easeInOut  ",  26);
l.addItem("Bounce.easeIn   ",  27);
l.addItem("Bounce.easeOut  ",  28);
l.addItem("Bounce.easeInOut",  29);
l.addItem("Elastic.easeIn  ",  30);
l.addItem("Elastic.easeOut ",  31);
l.addItem("Elastic.easeInOu",  32);
}


void styleLabel(Controller c) {
  c.getCaptionLabel().setColorBackground(c2);
}
void styleLabel(Controller c, String text) {
  controlP5.Label l = c.getCaptionLabel();
  if (c instanceof controlP5.Toggle || c instanceof controlP5.Bang) {
    l.setHeight(10);
    l.getStyle().setPadding(2, 2, 2, 2);
    l.getStyle().setMargin(-22, 0, 0, 20);
  } 
  else {
    l.setHeight(20);
    l.getStyle().setPadding(4, 4, 4, 4);
    l.getStyle().setMargin(-4, 0, 0, 0);
    l.setColorBackground(c2);
  }

  l.setText(text);
}


void fillColor(int col) {
  //println("picker\talpha:"+alpha(col)+"\tred:"+red(col)+"\tgreen:"+green(col)+"\tblue:"+blue(col)+"\tcol"+col);
  fillColor = col;
}
void updatextilenumSlider() {
  xTileNumSlider.setValue(xtilenum);
  undo.setUndoStep(); 
}
void updateytilenumSlider() {
  yTileNumSlider.setValue(ytilenum);
  undo.setUndoStep(); 
}



// +++++++ EVENTHANDLING +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void callbackEvent(CallbackEvent theEvent) {
  //println("CallbackEvent: " +theEvent.getController());
  if (theEvent.getAction() == ControlP5.ACTION_RELEASED || theEvent.getAction() == ControlP5.ACTION_RELEASEDOUTSIDE) {
     undo.setUndoStep(); 
  } 
  
}

void controlEvent(ControlEvent theEvent) {
 
  if(theEvent.isController() && theEvent.getController() instanceof Slider) {
   Slider tmp =  (Slider)theEvent.getController();
   if(tmp != xTileNumSlider && tmp != yTileNumSlider) {
      last = tmp;
      if(shiftPressed && !shiftProcessed) {
        enterShiftMode();
      }
    }
  }
  if (theEvent.isFrom("formats")) {
    int num = (int)theEvent.getGroup().getValue();
    println(num);
    formatDropdown.setColorBackground(color(100));
    formatDropdown.getItem(num).setColorBackground(c1);

    if(formatDropdown.getItem(num).getText() == "CUSTOM") {
      wBox.setLock(false);
      hBox.setLock(false);
    } else {
      wBox.setLock(true);
      hBox.setLock(true);
      int ww = int(formats[formatDropdown.getItem(num).getValue()-1][1]);
      int hh = int(formats[formatDropdown.getItem(num).getValue()-1][2]);
      if(ww != fwidth || hh != fheight) {
        wBox.setValue(ww);
        hBox.setValue(hh);
        canvasResize();  
      }
    }
  } 
  else if (theEvent.isFrom("rotType")) {
    rotType = (int)theEvent.getGroup().getValue();
    penner_rot.setColorBackground(color(100));
    penner_rot.getItem(rotType).setColorBackground(c1);
  }   
  else if (theEvent.isFrom("scaType")) {
    scaType = (int)theEvent.getGroup().getValue();
    penner_sca.setColorBackground(color(100));
    penner_sca.getItem(scaType).setColorBackground(c1);
  }
  else if (theEvent.isFrom("traType")) {
    traType = (int)theEvent.getGroup().getValue();
    penner_tra.setColorBackground(color(100));
    penner_tra.getItem(traType).setColorBackground(c1);
  }    
  else if(theEvent.isFrom("style")) {
    toggleSvgStyle();
    disableStyle = !disableStyle;
  } 
  else if(theEvent.isFrom(pageOrientationToggle)) {
    if(pageOrientation) {
      if((fwidth > fheight)) {
        togglePageOrientation();
      }
    } else {
      if((fwidth < fheight)) {
        togglePageOrientation();
      }      
    }
  }
  else if (theEvent.isFrom(settingsFilelist)) {
    int val = (int)theEvent.group().value();
    loadSettings((String)settingFiles.get(val), true);
  } 
  else if (theEvent.isFrom(closeImgMapButton)) {
    mapScale = false;
    mapRot = false;
    mapTra = false;
    map = null;
    updateImgMap();
  } 
  else if (theEvent.isFrom(mapScaleToggle)) {
    mapScale = ((Toggle)theEvent.getController()).getState();
    updateImgMap();
  } 
  else if (theEvent.isFrom(mapRotToggle)) {
    mapRot = ((Toggle)theEvent.getController()).getState();
    updateImgMap();
  }   
  else if (theEvent.isFrom(mapTraToggle)) {
    mapTra = ((Toggle)theEvent.getController()).getState();
    updateImgMap();
  }   
  else if (theEvent.isFrom(wBox)) {
    canvasResize();
  } 
  else if (theEvent.isFrom(hBox)) {
    canvasResize();

  }   
}

void enterShiftMode() {
  if(last != null && !shiftProcessed) {
    last.showTickMarks(true);
    last.snapToTickMarks(true);
    shiftProcessed = true;
  } 
}
void leaveShiftMode() {
  if(last != null && shiftProcessed) {
    last.showTickMarks(false);
    last.snapToTickMarks(false); 
   shiftProcessed = false; 
  }
}

void changebgcolor(float i) {
  if(colpi == null) {
    colpi = new ColorPicker(this, "colorpicker", 380, 300, bgcolor);
  } else {
    colpi.show(); 
  }
}

// +++++++ FRAME ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void canvasResize() {
  pdfwidth = (int) wBox.getValue();
  pdfheight = (int) hBox.getValue();
  resizeFrame(pdfwidth, pdfheight);
  
}

void resizeFrame(int newW, int newH) {
  fwidth = int(newW*zoom);
  fheight = int(newH*zoom); 
  
 println("fwh:   " +fwidth +"x" +fheight); 
 println("pdfwh: " +pdfwidth +"x" +pdfheight); 
 println("-------------------------------"); 

  insets = frame.getInsets();
  
  if (showMENU) {
    newW = fwidth+guiwidth;
    newH = fheight+insets.top;
  } else {
    newW = fwidth;
    newH = fheight+insets.top;
  }
  frame.setSize(newW, newH);
  gui.group("main").setPosition(fwidth+12,10);
  dragOffset.setPosition(indentX, fheight-31);
  zoomLabel.setPosition(indentX+guiwidth-70, fheight-31);
}



void scaleGUI(boolean bigger) {
  if(bigger) {
    zoom += .1;
  } else {
    if(zoom > 0.1) {
      zoom -= .1;
    }
  }
  zoomLabel.setText("ZOOM: " +zoom);
  resizeFrame(pdfwidth, pdfheight);
}



// +++++++ MENU and SETTINGS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void toggleMenu() {
  showMENU = !(gui.group("main").isOpen());
  insets = frame.getInsets();
  if (showMENU) {
    frame.setSize(fwidth+guiwidth, fheight+insets.top);
    style.setPosition(indentX, imgMap.y+imgMapHeight+h);
    gui.group("main").open();
  } else {
    frame.setSize(fwidth, fheight+insets.top);
    gui.group("main").close();
  }
}

void toggleSettings() {
  if(settingsFilelist == null || (settingsFilelist != null && !settingsFilelist.isOpen())) {
    
    gui.getProperties().setSnapshot("tmp");
    
    if(settingsFilelist != null) {
      settingsFilelist.remove();
    }
    findSettingFiles();
    
    settingsFilelist = gui.addListBox("filelist")
//      .setPosition(width/2-90, 200)
      .setPosition(20, 40)
      .setSize(180, 260)
      .setItemHeight(15)
      .setBarHeight(15);
  
    //settingsFilelist.captionLabel().toUpperCase(true);
    settingsFilelist.captionLabel().set("LAST SAVED SETTINGS");
    settingsFilelist.captionLabel().setColor(0xffffffff);
    settingsFilelist.captionLabel().style().marginTop = 3;
    settingsFilelist.valueLabel().style().marginTop = 3;
  
    for (int i = 0; i < settingFiles.size(); i++) {
      ListBoxItem lbi = settingsFilelist.addItem((String)(settingFiles.get(i)), i);
    }
    gui.getProperties().remove(settingsFilelist);
    settingsBoxOpened = true;
 } 
 else {
    settingsFilelist.close();
    settingsFilelist.hide();
    currentOver = null;
    settingsBoxOpened = false;
 } 
}

void loadSettings(String filename, boolean close) {
  gui.loadProperties(settingspath +filename);
  if(close) {
    settingsFilelist.close();
    settingsFilelist.hide();
    settingsBoxOpened = false;
  }
}

void saveSettings(String timestamp) {
  //gui.setFormat(ControllerProperties.Format);    
   gui.saveProperties(settingspath +timestamp +".ser");
}

void loadDefaultSettings() {
  gui.loadProperties("default.ser");
}


void findSettingFiles() {
  String[] allFiles = listFileNames(sketchPath("") +settingspath);
  allFiles = reverse(allFiles);
  settingFiles = new ArrayList(); 
  for (int k = 0; k < allFiles.length; k++) {
    String file = allFiles[k];
    if (file.indexOf(".ser") != -1) {
      settingFiles.add(file);
    }
  }
  allFiles = null;
  printArrayList(settingFiles); 
}

void catchMouseover() {
  //println(gui.getWindow().getMouseOverList());
  //println(gui.getWindow().getFirstFromMouseOverList());
  
  List overs = gui.getWindow().getMouseOverList();
  ControllerInterface over = gui.getWindow().getFirstFromMouseOverList();
 
  if(over == settingsFilelist) {
    if(currentOver == null) {
      gui.getProperties().setSnapshot("tmp");
    }
    for(int i = 0; i<overs.size(); i++)
      if(overs.get(i) instanceof controlP5.Button) {
        if(currentOver == null || currentOver != overs.get(i)) {
         currentOver = (Button)overs.get(i);
         
          int val = (int)currentOver.value();
          loadSettings((String)settingFiles.get(val), false);
        break;
        }
      }
    
  } else {
    if(currentOver != null) {
      gui.getProperties().getSnapshot("tmp");
      currentOver = null;
    }
  }
}

void togglePageOrientation() {
  int tw = fwidth;
  fwidth = fheight;
  fheight = tw; 
  frame.setSize(fwidth+guiwidth, fheight);
  main.setPosition(fwidth+12,18);
  
  tw = xtilenum;
  xtilenum = ytilenum;
  ytilenum = tw;
  
  tilewidth  = (float(fwidth -  (2*pageOffset)) / xtilenum);
  tilescale = tilewidth / svg.get(0).width;
  tileheight = svg.get(0).height * tilescale;
  
  while((tileheight * ytilenum) > fheight) {
     ytilenum--; 
  }
  
  xTileNumSlider.setValue(xtilenum);
  yTileNumSlider.setValue(ytilenum); 
 
  dropSVGadd.updateTargetRect(fwidth, fheight);
  dropSVGrep.updateTargetRect(fwidth, fheight);
  dropIMG.updateTargetRect(fwidth, fheight);
  dropNFO.updateTargetRect(fwidth, fheight);
  
  dragOffset.setPosition(indentX, fheight-31);
  zoomLabel.setPosition(indentX+guiwidth-70, fheight-31);
}

//===========================================================================
//===  GENERAL UTIL  ========================================================
//===========================================================================

void updateImgMap() {
  if(map != null) {
    style.setPosition(indentX, imgMap.y + ((int)(((float)map.height / (float)map.width) * (float)(w))) +h);
    closeImgMapButton.show();
    mapRotToggle.show();
    mapScaleToggle.show();
    mapTraToggle.show();
    invertMapToggle.show();
    penner_sca.setVisible(!mapScale);
    penner_rot.setVisible(!mapRot);
    penner_tra.setVisible(!mapTra);

/*
    if(mapScale) {
      penner_sca.hide();
    } 
    if(mapRot) {
      penner_rot.hide();
    }
    */
  } else {
      closeImgMapButton.hide();
      mapRotToggle.hide();
      mapScaleToggle.hide();
      mapTraToggle.hide();
      invertMapToggle.hide();
      style.setPosition(indentX, imgMap.y);
      penner_sca.show();
      penner_rot.show();
      penner_tra.show();
  }
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } 
  else {
    return null;
  }
}

void printArrayList(ArrayList l) {
  println("----------------------------------");
  for (int i = 0; i < l.size(); i++) {
    println(l.get(i));
  }
  println("----------------------------------");
}

//===========================================================================
//===  SUBCLASSES  ========================================================
//===========================================================================


class GuiImage extends Canvas {

  int x = 0;
  int y = 0;
  int hh = 0;
  int ww = 0;

  int wtmp = 0;
 
  int mx, my ,offsetx, offsety;
  int a, b, e, f ;
  int cornerSize = 12;
  
  boolean inside = false;  
  boolean drag = false;
  boolean dragC1 = false;
  boolean dragC3 = false;
  boolean insideCorner3 = false;
  boolean insideCorner1 = false;
  
  int cornerCol;
  int colOver = color(16, 181, 198, 128);
  int colCorner = color(50);
  int colCornerActive = color(100);
  int colCornerOver = color(5, 255, 190);
  
  public GuiImage(int xx, int yy) {
    x = xx;
    y = yy;
    ww = w;
  }
  public void setup(PApplet p) {
    wtmp = 0;
  }  

  public void draw(PApplet p) {
    pushStyle();
    
    if(map != null) {
      if(wtmp != map.width) {
        hh = (int)(((float)map.height / (float)map.width) * (float)(ww));
        imgMapHeight = hh;
        updateImgMap();
        a = 0;
        b = y;

        if(map.height > map.width) {
          e = ww;
          f = (int) ((float)ww * ((float)fheight) / (float)fwidth);
          if(f > hh) {
            f = hh;
            e = (int) ((float)hh * ((float)fwidth) / (float)fheight);
          }
        } else {
          f = hh;
          e = (int) ((float)hh * ((float)fwidth) / (float)fheight);
        }
    }

    p.image(map, x, y, ww,  hh);
    wtmp = map.width;
   
    mx = mouseX-(int)main.getPosition().x-1;
    my = mouseY-(int)main.getPosition().y-3;

    stroke(c1);
    strokeWeight(1f);
    cornerCol = colCorner;
        
    if( (mx >= a && mx <= a+e) && (my >= b && my <= b+f)  ) {
      fill(colOver);
      cornerCol = colCornerActive;
      inside = true;
      insideCorner1 = false;
      insideCorner3 = false;

      if(mx >= a+e-cornerSize && my >= b+f-cornerSize) {
        insideCorner3 = true;
        cornerCol = colCornerOver;
      } else if(mx <= a+cornerSize && my <= b+cornerSize) {
        insideCorner1 = true;
        cornerCol = colCornerOver;
      }
    } else {
        inside = false;
        insideCorner1 = false;
        insideCorner3 = false;
    }

    if(inside && mousePressed && !drag) {
      drag = true;
      offsetx = mx-a;
      offsety = my-b;
      if(insideCorner1 == true) {
        dragC1 = true; 
      }
      if(insideCorner3 == true) {
        dragC3 = true;
        offsetx = e-offsetx;
        offsety = f-offsety;
      }
    }
    
    if(drag) {
      if(mousePressed) {
        if(dragC1 == true) {   
          e = e-(mx-a)+offsetx;
          f = f-(my-b)+offsety;
          a = mx-offsetx;
          b = my-offsety;
        } else if(dragC3 == true) {
          //a = mx;
          //b = my;          
          e = mx-a+(offsetx);
          if(shiftPressed) {
            stroke(colCornerOver);
            f = (int) ((float)e * ((float)fheight) / (float)fwidth);
          } else {
            f = my-b+(offsety);
          }
        } else {
          a = mx-offsetx;
          b = my-offsety; 
        }
      } else {
       inside = false;
       drag = false; 
       dragC1 = false;
       dragC3 = false;       
       insideCorner1 = false;
       insideCorner3 = false;
      }
    }
    a = constrain(a, x-e,ww);
    b = constrain(b, y-f, y+hh);
    
    rect(a, b, e, f);
    fill(cornerCol);
    
    noStroke();
    triangle(a+1, b+1, a+cornerSize, b+1, a+1, b+cornerSize);
    triangle(a+e, b+f, a+e-cornerSize, b+f, a+e, b+f-cornerSize);
    }

  popStyle();
  }
}



class DropTargetSVG extends DropListener {
  
  PApplet app;
  boolean over = false;
  boolean addmode = false;
  int cw, ch;
  int x1,y1,w1,h1,x2,y2,w2,h2;
  int col = color(16, 181, 198, 150);
  Textlabel label;
  
  DropTargetSVG(PApplet app, boolean addmode) {
    this.app = app;
    this.addmode = addmode;
    cw = fwidth;
    ch = fheight;
    x1 = 10;
    y1 = 10;
    w1 = cw-20;
    h1 = (ch/7)*3-5;
    x2 = 10;
    y2 = (ch/7)*3+5;
    w2 = cw-20;
    h2 = (ch/7)*3-15;
    
    label = new Textlabel(gui,"ADD",100,100,400,200);

    if(addmode) {
      setTargetRect(x1, y1, w1, h1);
    } else {
      setTargetRect(x2, y2, w2, h2);
    }
  }
  
  void draw() {
    if(over) {
      fill(col);
      if(addmode) {
        rect(x1, y1, w1, h1);
        label.setPosition(cw/2-5, h1/2);
        label.setText("ADD");
      } else {
        rect(x2, y2, w2, h2);
        label.setPosition(cw/2-20, (h1/2)+h1);
        label.setText("REPLACE");
      }
      label.draw(app);
    }
  }
  
  void updateTargetRect(int newwidth, int newheight) {
    cw = newwidth;
    ch = newheight;
    x1 = 10;
    y1 = 10;
    w1 = cw-20;
    h1 = (ch/7)*3-5;
    x2 = 10;
    y2 = (ch/7)*3+5;
    w2 = cw-20;
    h2 = (ch/7)*3-15;    
    if(addmode) {
      setTargetRect(x1, y1, w1, h1);
    } else {
      setTargetRect(x2, y2, w2, h2);
    }
  }

  void dropEnter() {
    over = true;
  }

  void dropLeave() {
    over = false;
  }
  
  void dropEvent(DropEvent theDropEvent) {
    ArrayList<PShape> tmpsvg = new ArrayList<PShape>();
    File droppedFile = theDropEvent.file();
  
  //SVGs ==========================================================
      String path = theDropEvent.toString();
      if (split(path, ".lafkon.net").length > 1) {
        path =  split(path, ".pdf")[0] +".svg";
      }
      if (path.toLowerCase().endsWith(".svg")) {
        println("SVG: " +path);
        tmpsvg.add(loadShape(path));
        
        if (addmode) {
          svg.addAll(tmpsvg);
        } else {
          if(over) {
            svg = tmpsvg;
          } else {
            svg.addAll(tmpsvg);
          }
        }
      }
  }
  
}//class DropTarget

class DropTargetIMG extends DropListener {
  
  PApplet app;
  boolean over = false;
  int cw, ch;  
  int col = color(16, 181, 198, 150);
  
  DropTargetIMG(PApplet app) {
    this.app = app;
    cw = fwidth;
    ch = fheight;
    setTargetRect(cw+10,10,guiwidth-20, height-20);
  }
  
  void draw() {
    if(over) {
      fill(col);
      rect(cw+10,10,guiwidth-20, height-20);
    }
  }
  
  void updateTargetRect(int newwidth, int newheight) {
    cw = newwidth;
    ch = newheight;
    setTargetRect(cw+10,10,guiwidth-20, height-20);
  }
  
  void dropEnter() {
    over = true;
  }

  void dropLeave() {
    over = false;
  }
  
  String lastImgDropped = "x";
  String lastUrlDropped = "y";
  void dropEvent(DropEvent theDropEvent) {
    
    
    //println("XXX" +droppedFile.getPath());
    //if(lastImgDropped == droppedFile.getPath()) {
    //  println("samesame");
    //}
  boolean url = theDropEvent.isURL();
  boolean file = theDropEvent.isFile();
  boolean img = theDropEvent.isImage();  
  
  println("------------------------------------------");
  //println("isURL: " +theDropEvent.isURL()); 
  //println("isFil: " +theDropEvent.isFile()); 
  //println("isIMG: " +theDropEvent.isImage()); 
  
    /*
    File droppedFile = theDropEvent.file();
    String path = theDropEvent.filePath();
    String file = droppedFile.getPath();
    println("PATH");
    println(path);
     println("FILE");
     println(file);
     
     if((path == file) && (path != null)) {
       println("local");
     } else {
        println("remote");
     }
     */
     //println("after");


  //IMAGEMAP ======================================================  
   //somewhat complicated testing due to different behaviour on linux and osx
   //there seems to be a bug in sDrop (not correctly working in linux)
    if ((url&&!file&&img) || (!url&&file&&img)) {
      if(!url&&file&&img) {
        lastImgDropped = trim(theDropEvent.filePath());
      }
      if(url&&!file&&img) {
        lastUrlDropped = theDropEvent.url();
        try {
        lastUrlDropped = trim(split(lastUrlDropped, "file://")[1]);
        } catch(ArrayIndexOutOfBoundsException e) {
          lastUrlDropped = "";
        }
      }      
      if( (lastUrlDropped.equals(lastImgDropped)) == false) {
        map = theDropEvent.loadImage();
        imgMap.setup(app);
        updateImgMap();
      } else {
        lastImgDropped = "x";
        lastUrlDropped = "y"; 
      }
    } 
  }
  
}//class DropTarget

class DropTargetNFO extends DropListener {
  
  PApplet app;
  boolean over = false;
  int cw, ch;  
  int x1,y1,w1,h1;
  color col = color(60, 105, 97, 180);
  Textlabel label;

  
  DropTargetNFO(PApplet app) {
    this.app = app;
    cw = fwidth;
    ch = fheight;
    x1 = 10;
    y1 = (ch/7)*6-10;
    w1 = cw-20;
    h1 = (ch/7)*1+5;    
    label = new Textlabel(gui,"NFO",100,100,400,200);
    setTargetRect(x1, y1, w1, h1);
  }
  
  void draw() {
    if(over) {
      fill(col);
      rect(x1, y1, w1, h1);
      
      label.setPosition(cw/2-20, (h1/2)+y1-10);
      label.draw(app);
    }
  }
  
  void updateTargetRect(int newwidth, int newheight) {
    cw = newwidth;
    ch = newheight;
    x1 = 10;
    y1 = 10;
    w1 = cw-20;
    h1 = (ch/7)*3-5;
    setTargetRect(x1, y1, w1, h1);
  }
  
  void dropEnter() {
    over = true;
  }

  void dropLeave() {
    over = false;
  }
  
  void dropEvent(DropEvent theDropEvent) {
    File droppedFile = theDropEvent.file();
  
  //SVGs ==========================================================
      String path = theDropEvent.toString();
      if (split(path, ".lafkon.net").length > 1) {
        path =  split(path, ".pdf")[0] +".svg";
      }
      if (path.toLowerCase().endsWith(".svg")) {
        println("SVG: " +path);
        nfo = loadShape(path);        
      }
  }
  
}//class DropTarget
