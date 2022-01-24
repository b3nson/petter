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
 
import java.util.List;
import java.util.Arrays;

CallbackListener cbAllUndo, cbDropdownHover;
CallbackListener cbColorChange;

boolean showMENU = true;
boolean showANIMATE = false;
boolean showHELP = false;
boolean batchmode = false;
boolean batchnow = false;
boolean showScrollbar = false;
int batchwait = 1;

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
int helpwidth = 330;
int helpheight = ceil(68 * 9.6); //68 lines in help.txt
int infoheight = 22;
int scrollOffset = 0;
float scrollbarWidth = 2;
float scrollbarHeight = 0;
float scrollbarY = 0;

float mapwidth = 0;
float mapheight = 0;
float showExportLabelTimer = 0;
  
color c1 = color(16, 181, 198);    // blue
color c2 = color(60, 105, 97, 180);// green
color c3 = color(200, 200, 200);  //lightgray for separatorlines
color bg = color(100);

ArrayList settingFiles;
String renderer ="";

Boolean shiftPressed = false;
Boolean shiftProcessed = false;

Group main, imgmapGroup, style, animate, help, helptextbox, info, exportinfo, styleLineGroup;
Slider xTileNumSlider, yTileNumSlider, pageOffsetSlider, absTransXSlider, absTransYSlider, relTransXSlider, relTransYSlider, absRotSlider, relRotSlider, absScaSlider, relScaSlider, strokeWeightSlider, last;
ScrollableListPlus penner_rot, penner_sca, penner_tra, settingsFilelist;
ScrollableListPlus penner_anim, formatDropdown;
Button animSetInButton, animSetOutButton, animRunButton, animExportButton, animGotoInButton, animGotoOutButton, clearInOutValuesButton;
RadioButton linecapRadioButton, linejoinRadioButton;
Bang bgcolorBang, strokecolorBang, shapecolorBang, tileeditorBang, mapeditorBang;
Toggle pageOrientationToggle, showRefToggle, showNfoToggle, showGuiExportToggle, strokeModeToggle, strokeToggle, fillToggle, nfoLayerToggle, exportFormatToggle;
Textlabel dragOffset, zoomLabel, stylefillLabel, helptextLabel, fpsLabel, lastguielem, exportConfirmationLabel;
Numberbox wBox, hBox, animFrameNumBox;
//save values to hidden controllers to get saved in properties 
Numberbox bgcolorSaveLabel, strokecolorSaveLabel, strokecolorAlphaSaveLabel, shapecolorSaveLabel, shapecolorAlphaSaveLabel, styleSaveLabel, loopDirectionSaveLabel, linebylineSaveLabel;
Slider offsetxSaveLabel, offsetySaveLabel;
Label tmp;


// ---------------------------------------------------------------------------
//  GUI SETUP
// ---------------------------------------------------------------------------

void setupGUI() {
  gui.setColorActive(c1);
  gui.setColorBackground(bg);
  gui.setColorForeground(color(30));
  gui.setColorCaptionLabel(color(255, 255, 255));
  gui.setColorValueLabel(color(255, 255, 255));
  gui.enableShortcuts();  

// ---------------------------------------------------------------------------
//  GUI SETUP - MAIN MENU
// ---------------------------------------------------------------------------

  main = gui.addGroup("main")
           .setPosition(viewwidth+12, 0)
           .hideBar()
           .close()
           ;
   
  ypos += 20;
  
  tileeditorBang = gui.addBang("tileEditor")
     .setLabel("TileEditor")
     .setPosition(indentX, ypos)
     .setSize(h*4+8, 20)
     .setGroup(main)
     ;
     tileeditorBang.getCaptionLabel().setPadding(6,-14);
     tileeditorBang.setColorForeground(color(100));  
  
  mapeditorBang = gui.addBang("mapEditor")
     .setLabel("MapEditor")
     .setPosition(indentX +94, ypos)
     .setSize(h*4+6, 20)
     .setGroup(main)
     ;
     mapeditorBang.getCaptionLabel().setPadding(6,-14);
     mapeditorBang.setColorForeground(color(100));
  
  ypos += sep;  
  
  formatDropdown = new ScrollableListPlus(gui, "formats");
  formatDropdown
     .setGroup(main)
     .setPosition(indentX, ypos)
     .setSize(46, 300)
     .setItemHeight(h)
     .setBarHeight(h)
     .setBackgroundColor(color(190))
     .setType(ControlP5.DROPDOWN)
     .close();
     ;
  addFormatItems(formatDropdown);
  //formatDropdown.getCaptionLabel().getStyle().marginTop = h/4+1;

     
  wBox = gui.addNumberbox("width")
     .setPosition(indentX+54, ypos)
     .setSize(34, h)
     .setLabel("")
     .setRange(20,2000)
     .setDecimalPrecision(0) 
     //.setMultiplier(0.1)
     .setValue(pagewidth)
     .setLock(true)
     .setLabelVisible(false)
     .setGroup(main)
     ;

  hBox = gui.addNumberbox("height")
     .setPosition(indentX +94, ypos)
     .setSize(34, h)
     .setLabel("")
     .setRange(20,2000)
     .setDecimalPrecision(0) 
     //.setMultiplier(0.1)
     .setValue(pageheight)
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
     
  ypos += sep+8;
  

   showRefToggle = gui.addToggle("showRef")
     .setLabel("REF")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setValue(false)
     .setGroup(main)
     ;
     styleLabel(showRefToggle, "REF");
     showRefToggle.getCaptionLabel().setPadding(-h,-10);
   indentX += h+12;

   showNfoToggle = gui.addToggle("showNfo")
     .setLabel("NFO")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setValue(false)
     .setGroup(main)
     ;
     styleLabel(showNfoToggle, "NFO");
     showNfoToggle.getCaptionLabel().setPadding(-h,-10);
   indentX += h+12;

   nfoLayerToggle = gui.addToggle("nfoOnTop")
     .setLabel("nfotop")
     .setPosition(indentX, ypos)
     .setMode(ControlP5.SWITCH)
     .setSize(h, h)
     .setValue(nfoOnTop)
     .setGroup(main)
     ;
     styleLabel(nfoLayerToggle, "nfotop");
     nfoLayerToggle.getCaptionLabel().setPadding(-h,-10);
   indentX += h+12;
     
   bgcolorBang = gui.addBang("changebgcolor")
     .setLabel("C")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setGroup(main)
     ;
   bgcolorBang.setView(new ColorBangView());
   bgcolorBang.setColorForeground(bgcolor[0]);

     
   indentX += h+12;
 
   showGuiExportToggle = gui.addToggle("guiExport")
     .setLabel("GUIEXP")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setValue(false)
     .setGroup(main)
     ;
     styleLabel(showGuiExportToggle, "GUIEXP");
     showGuiExportToggle.getCaptionLabel().setPadding(-h,-10);
   indentX += h+12;

   exportFormatToggle = gui.addToggle("exportFormat")
     .setLabel("pdf/svg")
     .setPosition(indentX, ypos)
     .setMode(ControlP5.SWITCH)
     .setSize(h, h)
     .setValue(nfoOnTop)
     .setGroup(main)
     ;
     styleLabel(exportFormatToggle, "pdf/svg");
     exportFormatToggle.getCaptionLabel().setPadding(-h,-10);

   indentX = 0;
 
   
  ypos += sep;

   pageOffsetSlider = gui.addSlider("absPageOffset")
     .setLabel("pageOffset")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(0,250) 
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
     .setRange(0,180) 
     .setSliderMode(Slider.FLEXIBLE)
     .setGroup(main)
     ;
     styleLabel(xTileNumSlider, "xtilenum   (LEFT/RIGHT)");
  ypos += gapY;


  yTileNumSlider = gui.addSlider("ytilenum")
     .setLabel("ytilenum")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(0,260) 
     .setSliderMode(Slider.FLEXIBLE)
     .setGroup(main)
     ;   
     styleLabel(yTileNumSlider, "ytilenum   (UP/DOWN)");
  ypos += sep;




  absTransXSlider = gui.addSlider("absTransX")
     .setLabel("global trans X")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(-500,500)
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
     .setRange(-500,500)
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
     .setRange(-1000, 1000)
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
     .setRange(-1000, 1000)
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.005)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ;  
     styleLabel(relTransYSlider, "relative trans Y");
  ypos += gapY;
  
  penner_tra = new ScrollableListPlus(gui, "traType");
  penner_tra
     .setGroup(main)
     .setPosition(indentX,ypos)
     .setSize(w, 300)
     .setItemHeight(h)
     .setBarHeight(h)
     ////.activateEvent(true)
     .setBackgroundColor(color(190))
     .setType(ControlP5.DROPDOWN)
     .close();
     ;
  addItems(penner_tra);
  //penner_tra.getCaptionLabel().getStyle().marginTop = h/4+1;

  ypos += sep;



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

  ypos += gapY;

  penner_rot = new ScrollableListPlus(gui, "rotType");
  penner_rot
     .setGroup(main)
     .setPosition(indentX,ypos)
     .setSize(w, 300)
     .setItemHeight(h)
     .setBarHeight(h)
     //.activateEvent(true)
     .setBackgroundColor(color(190))     
     .setType(ControlP5.DROPDOWN)
     .close();
     ;
  addItems(penner_rot);
  //penner_rot.getCaptionLabel().getStyle().marginTop = h/4+1;
  ypos += sep;  


  absScaSlider = gui.addSlider("absScale")
     .setLabel("global scale")
     .setPosition(indentX, ypos)
     .setSize(w,h)
     .setRange(-5.0,5.0) 
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
     .setRange(-5.0,5.0) 
     .setSliderMode(Slider.FLEXIBLE)
     .setDecimalPrecision(1)
     .setScrollSensitivity(0.01)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     .setGroup(main)
     ; 
     styleLabel(relScaSlider, "relative scale");
  ypos += gapY;

  penner_sca = new ScrollableListPlus(gui, "scaType");
  penner_sca
     .setGroup(main)
     .setPosition(indentX,ypos)
     .setSize(w, 300)
     .setItemHeight(h)
     .setBarHeight(h)
     //.activateEvent(true)
     .setBackgroundColor(color(190))
     .setType(ControlP5.DROPDOWN)
     .close();
     ;
  addItems(penner_sca);
  //penner_sca.getCaptionLabel().getStyle().marginTop = h/4+1;
  ypos += sep;


// ---------------------------------------------------------------------------
//  GUI SETUP - SAVELABELS - Workaround to save additional values in cp5-properties 
// ---------------------------------------------------------------------------


  bgcolorSaveLabel = gui.addNumberbox("bgcolorSaveLabel" )
     .setPosition(0, 0)
     .setValue(bgcolor[0])
     .setGroup(main)
     .hide()
     ;
     
  strokecolorSaveLabel  = gui.addNumberbox("strokecolorSaveLabel" )
     .setPosition(0, 0)
     .setValue( color(red(strokecolor[0]), green(strokecolor[0]), blue(strokecolor[0]) ))
     .setGroup(main)
     .hide()
     ;

  strokecolorAlphaSaveLabel  = gui.addNumberbox("strokecolorAlphaSaveLabel" )
     .setPosition(0, 0)
     .setValue(alpha(strokecolor[0]))
     .setGroup(main)
     .hide()
     ;

  shapecolorSaveLabel  = gui.addNumberbox("shapecolorSaveLabel" )
     .setPosition(0, 0)
     .setValue( color(red(shapecolor[0]), green(shapecolor[0]), blue(shapecolor[0]) ))
     .setGroup(main)
     .hide()
     ;
     
  shapecolorAlphaSaveLabel  = gui.addNumberbox("shapecolorAlphaSaveLabel" )
     .setPosition(0, 0)
     .setValue(alpha(shapecolor[0]))
     .setGroup(main)
     .hide()
     ;

  styleSaveLabel = gui.addNumberbox("styleSaveLabel" )
     .setPosition(0, 0)
     .setValue((int(globalStyle)))
     .setGroup(main)
     .hide()
     ;

  loopDirectionSaveLabel = gui.addNumberbox("loopDirectionSaveLabel" )
     .setPosition(0, 0)
     .setValue((int(loopDirection)))
     .setGroup(main)
     .hide()
     ;
     
  linebylineSaveLabel = gui.addNumberbox("linebylineSaveLabel" )
     .setPosition(0, 0)
     .setValue((int(linebyline)))
     .setGroup(main)
     .hide()
     ;
     
  offsetxSaveLabel = gui.addSlider("offsetxSaveLabel" )
     .setPosition(0, 0)
     .setRange(-5000f, 5000f)
     .setValue(manualOffsetX)
     .setGroup(main)
     .hide()
     ;

  offsetySaveLabel = gui.addSlider("offsetySaveLabel" )
   .setPosition(0, 0)
   .setRange(-5000f, 5000f)
   .setValue(manualOffsetY)
   .setGroup(main)
   .hide()
   ;
  
  ypos += gapY;


// ---------------------------------------------------------------------------
//  GUI SETUP - STYLE MENU
// ---------------------------------------------------------------------------

 style = gui.addGroup("style")
           .setPosition(indentX, ypos)
           .setBackgroundHeight(100)
           .activateEvent(true)
           .setGroup(main)
           .close()
           ;
  if(globalStyle) style.open();
  else style.close();

  strokeToggle = gui.addToggle("customStroke")
     .setLabel("X")
     .setValue(customStroke)
     .setPosition(indentX,indentY)
     .setSize(h,h)
     .setMode(ControlP5.SWITCH_BACK)
     .setGroup(style)
     ;
     strokeToggle.getCaptionLabel().setPadding(8,-14);

   strokecolorBang = gui.addBang("changestrokecolor")
     .setLabel("C")
     .setPosition(indentX+h+h/2,indentY)
     .setSize(h, h)
     .setGroup(style)
     ;
     strokecolorBang.setView(new ColorBangView());
     strokecolorBang.setColorForeground(strokecolor[0]);
     
  strokeModeToggle = gui.addToggle("strokeMode")
     .setLabel("")
     .setValue(strokeMode)
     .setPosition(indentX+3*h,indentY)
     .setSize(h,h)
     .setMode(ControlP5.SWITCH)
     .setGroup(style)
     ;
  
  strokeWeightSlider = gui.addSlider("customStrokeWeight")
     .setLabel("strokeWeight")
     .setPosition(indentX+4.5*h,indentY)
     .setSize(w-4*h,h)
     .setRange(0f,25.0)
     .setSliderMode(Slider.FLEXIBLE)
     .setNumberOfTickMarks(tickMarks)
     .showTickMarks(false)   
     .snapToTickMarks(false)
     //.setDecimalPrecision(2)
     //.setScrollSensitivity(0.004)
     .setScrollSensitivity(0.004)
     .setGroup(style)
     ;   
     styleLabel(strokeWeightSlider, "strokeoptions");     
  
  fillToggle = gui.addToggle("customFill")
     .setLabel("X")
     .setValue(customFill)
     .setPosition(indentX,indentY+sep)
     .setSize(h,h)
     .setMode(ControlP5.SWITCH_BACK)
     .setGroup(style)
     ;
     fillToggle.getCaptionLabel().setPadding(8,-14);

   shapecolorBang = gui.addBang("changeshapecolor")
     .setLabel("C")
     .setPosition(indentX+h+h/2,indentY+sep)
     .setSize(h, h)
     .setGroup(style)
     ;
     shapecolorBang.setView(new ColorBangView());
     shapecolorBang.setColorForeground(shapecolor[0]);

   styleLineGroup = gui.addGroup("linejoin/linecap")
     .setPosition(10, 100)
     .setPosition(indentX,indentY+sep+sep)
     .setBackgroundHeight(100)
     .setSize(0,0)
     .disableCollapse()
     .open()
     .setGroup(style)
     ;
     tmp = styleLineGroup.getCaptionLabel();
     tmp.setHeight(20);
     tmp.getStyle().setPadding(4, 4, 4, 4);
     tmp.getStyle().setMargin(8, 0, 0, 190);
     tmp.setColorBackground(c2);
  
   linejoinRadioButton = gui.addRadioButton("linejoinmode")
     .setPosition(0,0)
     .setSize(28,12)
     .setItemsPerRow(3)
     .setSpacingColumn(1)
     .addItem("RND", ROUND)
     .addItem("MTR", MITER)
     .addItem("BVL", BEVEL)
     .setGroup(styleLineGroup)
     .activate(0)
     ;
     for(Toggle t:linejoinRadioButton.getItems()) {
       t.getCaptionLabel().getStyle().moveMargin(-1,0,0,-33);
       t.getCaptionLabel().getStyle().movePadding(0,0,0,8);
     }
  
   linecapRadioButton = gui.addRadioButton("linecapmode")
     .setPosition(94,0)
     .setSize(28,12)
     .setItemsPerRow(3)
     .setSpacingColumn(1)
     .addItem("SQR", SQUARE)
     .addItem("PRJ", PROJECT)
     .addItem("rnd", ROUND)
     .setGroup(styleLineGroup)
     .activate(0)
     ;
     for(Toggle t:linecapRadioButton.getItems()) {
       t.getCaptionLabel().getStyle().moveMargin(-1,0,0,-33);
       t.getCaptionLabel().getStyle().movePadding(0,0,0,8);
     }
     
     ypos += gapY;
     
// ---------------------------------------------------------------------------
//  GUI SETUP - ANIMATE MENU
// ---------------------------------------------------------------------------   

 animate = gui.addGroup("animate")
           .setPosition(indentX, ypos)
           .setBackgroundHeight(100)
           .activateEvent(true)
           .setGroup(main)
           .close()
           ;

  ypos = 0+indentY;
  
  animSetInButton = gui.addButton("registerStartValues")
     .setLabel("I")
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setGroup("animate")
     ;
  animSetInButton.getCaptionLabel().setPadding(10,-14);

  animSetOutButton = gui.addButton("registerEndValues")
     .setLabel("O")
     .setPosition(indentX+1.5*h, ypos)
     .setSize(h, h)
     .setGroup("animate")
     ;
  animSetOutButton.getCaptionLabel().setPadding(8,-14);

  clearInOutValuesButton = gui.addButton("clearKeyframes")
     .setLabel("X")
     .setValue(0)
     .setPosition(indentX+3*h, ypos)
     .setSize(h/2, h)
     .setGroup("animate")
     ;
  clearInOutValuesButton.getCaptionLabel().setPadding(3,-14);
  
  
  penner_anim = new ScrollableListPlus(gui, "animType");
  penner_anim
     .setPosition(indentX+4*h, ypos)
     .setSize(104, 70)
     .setItemHeight(12)
     .setBarHeight(h)
     //.activateEvent(true)
     .setBackgroundColor(color(190))
     .setGroup("animate")
     .setType(ControlP5.DROPDOWN)
     .close();
     ;
  addItems(penner_anim);
  //penner_anim.getCaptionLabel().getStyle().marginTop = h/4+1;
  
  ypos += sep;

  animGotoInButton = gui.addButton("<")
     .setValue(0)
     .setPosition(indentX, ypos)
     .setSize(h, h)
     .setGroup("animate")
     ;
  animGotoInButton.getCaptionLabel().setPadding(10,-14);

  animGotoOutButton = gui.addButton(">")
     .setValue(0)
     .setPosition(indentX+1.5*h, ypos)
     .setSize(h, h)
     .setGroup("animate")
     ;
  animGotoOutButton.getCaptionLabel().setPadding(8,-14);
  
  animFrameNumBox = gui.addNumberbox("frames")
     .setPosition(indentX+3*h, ypos)
     .setSize(34, h)
     .setLabel("f")
     .setRange(2,10000)
     .setValue(frames)
     .setLabelVisible(false)
     .setGroup("animate")
     ;
  animFrameNumBox.getCaptionLabel().getStyle().marginLeft = 28;
  animFrameNumBox.getCaptionLabel().getStyle().marginTop = -17;

  animRunButton = gui.addButton("RUN")
     .setValue(0)
     .setPosition(indentX+5*h, ypos)
     .setSize(2*h, h)
     .setGroup("animate")
     ;
  animRunButton.getCaptionLabel().setPadding(12,-12);

  animExportButton = gui.addButton("EXPORT")
     .setValue(0)
     .setPosition(indentX+7.2*h, ypos)
     .setSize(2*h, h)
     .setGroup("animate")
     ;
  animExportButton.getCaptionLabel().setPadding(7,-12);
  
// ---------------------------------------------------------------------------
//  GUI SETUP - LAST ELEM
// ---------------------------------------------------------------------------  

  lastguielem = gui.addTextlabel("last" )
     .setPosition(indentX, animate.getPosition()[1]+h)
     .setText("----------")
     .setGroup(main)
     .hide()
     ;
   
// ---------------------------------------------------------------------------
//  GUI SETUP - INFO LABELS
// --------------------------------------------------------------------------- 
   
  info = gui.addGroup("info")
    .setSize(guiwidth, infoheight)
    .setPosition(viewwidth, viewheight-infoheight)
    .setBackgroundHeight(infoheight+2)
    .setBackgroundColor(color(45))
    .hideBar()
    .open()
    ;
    
  dragOffset = gui.addTextlabel("dragoffset" )
     .setPosition(10, 7)
     .setText("OFFSET: 0 x 0")
     .setGroup(info)
     ;

  zoomLabel = gui.addTextlabel("zoomlabel" )
     .setPosition(guiwidth-60, 7)
     .setText("ZOOM: 1.0")
     .setGroup(info)
     ;

  exportinfo = gui.addGroup("exportinfo")
    .setSize(viewwidth, infoheight)
    .setPosition(0, viewheight-infoheight)
    .setBackgroundHeight(infoheight+2)
    .setBackgroundColor(230)
    .hideBar()
    .open()
    .hide()
    ;
    
  exportConfirmationLabel = gui.addTextlabel("exportlabel" )
    .setPosition(10, 7)
    .setText("")
    .setColor(0)
    .setGroup(exportinfo)
    ; 
   
// ---------------------------------------------------------------------------
//  GUI SETUP - HELP MENU
// ---------------------------------------------------------------------------   
  
  help = gui.addGroup("help")
    .setSize(viewwidth, viewheight+1)
    .setPosition(0, 0)
    .setBackgroundHeight(viewheight+1)
    .setBackgroundColor(color(0, 170))
    .hideBar()
    .close();

  helptextbox = gui.addGroup("helptextbox")
    .setSize(helpwidth, helpheight)
    .setPosition((viewwidth-helpwidth)/2, (viewheight-helpheight)/2)
    .setBackgroundHeight(helpheight)
    .setBackgroundColor(color(255))
    .hideBar()
    .setGroup(help);
  
  helptextLabel = gui.addTextlabel("shortcuts", "", 20, 20)
    .setSize(helpwidth, helpheight)
    .setMultiline(true)
    .setLineHeight(9)
    .setColorValue(color(0))
    .setGroup(helptextbox);

  fpsLabel = gui.addTextlabel("fps" )
   .setSize(100, 30)
   .setPosition(10, 10)
   .setText("fps")
   .setGroup(help)
   ;
     
   if(helptext != null) {
    for (int i = 0; i < helptext.length; i++) {
      String s = helptext[i];
      if(s.equals("")) s = ".";
      helptextLabel.append(s, 80);
    }
  }

     
// ---------------------------------------------------------------------------
//  GUI SETUP - FINAL CLEANUP
// --------------------------------------------------------------------------- 

  cbAllUndo = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
       callbackUndoAction(theEvent);
    }
  }; 
  gui.addCallback(cbAllUndo);

  cbDropdownHover = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
       callbackDropdownHover(theEvent);
    }
  }; 
  penner_tra.onMove(cbDropdownHover).onEnter(cbDropdownHover).onLeave(cbDropdownHover);
  penner_rot.onMove(cbDropdownHover).onEnter(cbDropdownHover).onLeave(cbDropdownHover);
  penner_sca.onMove(cbDropdownHover).onEnter(cbDropdownHover).onLeave(cbDropdownHover);
  //settingsFilelist not created yet. Created on userinput (Key 0)
  //settingsFilelist.onMove(cbDropdownHover).onEnter(cbDropdownHover).onLeave(cbDropdownHover);

  formatDropdown.bringToFront();
  penner_sca.bringToFront();
  penner_rot.bringToFront();
  penner_tra.bringToFront();
  penner_anim.bringToFront();
  info.bringToFront();
  
  ControllerProperties cprop = gui.getProperties();
  cprop.remove(tileeditorBang);
  cprop.remove(mapeditorBang);
  cprop.remove(bgcolorBang);
  cprop.remove(strokecolorBang);
  cprop.remove(shapecolorBang);
  cprop.remove(linecapRadioButton);
  cprop.remove(linejoinRadioButton);
  cprop.remove(animate);
  cprop.remove(animSetInButton);
  cprop.remove(animSetOutButton);
  cprop.remove(clearInOutValuesButton);
  cprop.remove(penner_anim);
  cprop.remove(animGotoInButton);
  cprop.remove(animGotoOutButton);
  cprop.remove(animFrameNumBox);
  cprop.remove(animRunButton);
  cprop.remove(animExportButton);
  cprop.remove(help);
  cprop.remove(helptextLabel);
  cprop.remove(helptextbox);
  cprop.remove(lastguielem);
  cprop.remove(dragOffset);
  cprop.remove(zoomLabel);
  cprop.remove(fpsLabel);
  cprop.remove(exportinfo);
  cprop.remove(exportConfirmationLabel);

  registerForAnimation(xTileNumSlider);
  registerForAnimation(yTileNumSlider);
  registerForAnimation(pageOffsetSlider);
  registerForAnimation(absTransXSlider);
  registerForAnimation(absTransYSlider); 
  registerForAnimation(relTransXSlider); 
  registerForAnimation(relTransYSlider); 
  registerForAnimation(absRotSlider); 
  registerForAnimation(relRotSlider); 
  registerForAnimation(absScaSlider); 
  registerForAnimation(relScaSlider);
  registerForAnimation(strokeWeightSlider);
  registerForAnimation(offsetxSaveLabel);
  registerForAnimation(offsetySaveLabel);  

  cprop.setFormat(ControlP5Constants.JSON);

  reorderGuiElements();
  
  if(showMENU) {
    showMENU = false;
    toggleMenu();
  }
  
  gui.saveProperties(); //save default properties
} //setupGUI



void addFormatItems(ScrollableList l) {
  l.addItem("CUSTOM",  0);
  for(int i=0; i<formats.length; i++) {
    l.addItem(formats[i][0], i+1);
  }
}

void addItems(ScrollableList l) {
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
l.addItem("Elastic.easeInOut",  32);
}


void styleLabel(Controller c) {
  c.getCaptionLabel().setColorBackground(c2);
}
void styleLabel(Controller c, String text) {
  controlP5.Label l = c.getCaptionLabel();
  if(c == shapecolorBang) {
      l.setHeight(20);
      l.getStyle().setPadding(4, 4, 4, 4);
      l.getStyle().setMargin(-22, 0, 0, 164);
      l.setColorBackground(c2);
  } else {
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
  }
    l.setText(text);
}



// ---------------------------------------------------------------------------
//  GUI GENERAL EVENTHANDLING
// ---------------------------------------------------------------------------

int orgType = -1;
int tmpType = -1;

void callbackDropdownHover(CallbackEvent theEvent) {
  ScrollableListPlus c = (ScrollableListPlus)theEvent.getController();
   
  if(theEvent.getAction() == ControlP5.ACTION_MOVE) {
    tmpType = c.getItemHover();
    if(tmpType == -1) {   
        tmpType = orgType;
    }
    if(c.equals(penner_tra)) {
      traType = tmpType;
    } else if(c.equals(penner_rot)) {
      rotType = tmpType;
    } else if(c.equals(penner_sca)) {
      scaType = tmpType;
    } else if(c.equals(settingsFilelist)) {
      if(tmpType >= settingsFilelist.getItems().size()) tmpType = orgType;
      if(tmpType == -1) {
        gui.getProperties().getSnapshot("tmp");
      } else {
        loadSettings((String)settingFiles.get(tmpType), false);
      }
    }
  } 
  else if(theEvent.getAction() == ControlP5.ACTION_ENTER) {
    tmpType = -1;
    orgType = (int)c.getValue();
    if(c.equals(settingsFilelist)) {
       gui.getProperties().setSnapshot("tmp");
       orgType = -1;
    }
  } 
  else if(theEvent.getAction() == ControlP5.ACTION_LEAVE) {       
    if(c.equals(penner_tra)) {
      traType = orgType;
    } else if(c.equals(penner_rot)) {
      rotType = orgType;
    } else if(c.equals(penner_sca)) {
      scaType = orgType;
    } else if(c.equals(settingsFilelist)) {
      gui.getProperties().getSnapshot("tmp");
    }
    tmpType = -1;
    orgType = -1;
  }
}

// UNDO-HANDLING -------------------------------------------------------------

Controller tmpctrl;
int tmpactn;

void callbackUndoAction(CallbackEvent theEvent) {
  //println("CALLBACK: " +theEvent.getController() +"ACTION: " +theEvent.getAction());
  Controller curctrl = theEvent.getController();
  int curactn = theEvent.getAction();

  //NO undo on colorpicker-buttons
  if(curctrl instanceof Bang) {
    return;
  }
  
  //SELECT item of Listboxes
  if(curctrl instanceof ScrollableList || curctrl instanceof ScrollableListPlus) {
    if(curactn == ControlP5.ACTION_LEAVE && tmpactn == ControlP5.ACTION_CLICK ) {
      undo.setUndoStep();
    }
    tmpactn = curactn;
    return;
  }

  //SCROLLWHEEL on Sliders and Numberboxes
  if(curctrl instanceof Slider || curctrl instanceof Numberbox) {
    if (curactn == ControlP5.ACTION_WHEEL) {
        tmpctrl = curctrl;
        return;
    }
    if (tmpctrl != null && curactn == ControlP5.ACTION_LEAVE) {
      if(curctrl == tmpctrl) {
        tmpctrl = null;
        undo.setUndoStep();
      }
    }    
  }
  
  //ALL others on RELEASE
  if (curactn == ControlP5.ACTION_RELEASE || curactn == ControlP5.ACTION_RELEASE_OUTSIDE) {
    if(curctrl.getParent() != animate && 
       curctrl.getParent() != penner_anim) {
          undo.setUndoStep();      
       }
  }
}


void controlEvent(ControlEvent theEvent) {
  if(theEvent.isController() && theEvent.getController() instanceof Slider) {
   Slider tmp =  (Slider)theEvent.getController();
   
   if(tmp != xTileNumSlider && tmp != yTileNumSlider) {
      if(shiftPressed && !shiftProcessed) {
        last = tmp;  
        enterShiftMode();
      } else if(shiftPressed && shiftProcessed) { //slider changed while shift-pressed
        if(last != null && !last.equals(tmp)) { 
          leaveShiftMode();
          last = tmp;
          enterShiftMode();
        }
      }
    }
  }
  
  if(theEvent.isController() && theEvent.getController() instanceof ScrollableListPlus) {
    ScrollableListPlus slp = (ScrollableListPlus)theEvent.getController();
    slp.updateHighlight(slp.getItem((int)slp.getValue()));
  }
  
  if (theEvent.isFrom("formats")) {
    int num = (int)theEvent.getController().getValue();

    formatDropdown.setColorBackground(color(100));
    //formatDropdown.getItem(num).setColorBackground(c1);
    if(formatDropdown.getItem(num).get("text").equals("CUSTOM")) {
      wBox.setLock(false);
      hBox.setLock(false);
    } else {
      wBox.setLock(true);
      hBox.setLock(true);
      
      int ww = int(formats[num-1][pageOrientation?1:2]);
      int hh = int(formats[num-1][pageOrientation?2:1]);
   
      if(ww != viewwidth || hh != viewheight) {
        wBox.setValue(ww);
        hBox.setValue(hh);
        canvasResize();  
      }
    }
  }
  else if (theEvent.isFrom("ytilenum") || theEvent.isFrom("xtilenum")) {
    if(mapEditor != null) mapEditor.updatePetterBounds(pagewidth, pageheight, xtilenum, ytilenum);
  }
  else if (theEvent.isFrom("rotType")) {
    rotType = (int)theEvent.getController().getValue();
    penner_rot.setColorBackground(color(100));
  }   
  else if (theEvent.isFrom("scaType")) {
    scaType = (int)theEvent.getController().getValue();
    penner_sca.setColorBackground(color(100));
  }
  else if (theEvent.isFrom("traType")) {
    traType = (int)theEvent.getController().getValue();
    penner_tra.setColorBackground(color(100));
  }    
  else if (theEvent.isFrom("animType")) {
    animType = (int)theEvent.getController().getValue();
    penner_anim.setColorBackground(color(100));
  } 
  else if(theEvent.isFrom("style")) {
    if(globalStyle) {
      disableGlobalStyle();
    } else {
      enableGlobalStyle();
    }
    styleSaveLabel.setValue((int(globalStyle)));
  } 
  else if(theEvent.isFrom(pageOrientationToggle)) {
    if(pageOrientation) {
      if((viewwidth > viewheight)) {
        togglePageOrientation();
      }
    } else {
      if((viewwidth < viewheight)) {
        togglePageOrientation();
      }      
    }
  }
  else if (theEvent.isFrom(settingsFilelist)) {
    int val = (int)theEvent.getController().getValue();
    loadSettings((String)settingFiles.get(val), true);
  } 
  else if (theEvent.isFrom(wBox)) {
    canvasResize();
  } 
  else if (theEvent.isFrom(hBox)) {
    canvasResize();
  }
  else if (theEvent.isFrom(tileeditorBang)) {
    toggleTileEditor();
  }
  else if (theEvent.isFrom(mapeditorBang)) {
    toggleMapEditor();
  }
  else if(theEvent.isFrom("animate")) {
    if(gui.getGroup("animate").isOpen())
      openAnimate();
    else
      closeAnimate();
  }   
  else if (theEvent.isFrom(animSetInButton)) {
    registerAnimStartValues();
  }   
  else if (theEvent.isFrom(animSetOutButton)) {
    registerAnimEndValues();
  }    
  else if (theEvent.isFrom(animRunButton)) {
    startSequencer(false);
  }    
  else if (theEvent.isFrom(animExportButton)) {
    startSequencer(true);
  }   
  else if (theEvent.isFrom(animGotoInButton)) {
    showInValues();
  }    
  else if (theEvent.isFrom(animGotoOutButton)) {
    showOutValues();
  } 
  else if (theEvent.isFrom(clearInOutValuesButton)) {
    deleteRegisteredValues();
  } 
  else if (theEvent.isFrom(bgcolorSaveLabel)) {
    if(focused) {bgcolor[0] = int(bgcolorSaveLabel.getValue());} //set color on undo/redo/loadsettings
    bgcolorBang.setColorForeground(bgcolor[0]);
  }
  else if (theEvent.isFrom(strokecolorSaveLabel) || theEvent.isFrom(strokecolorAlphaSaveLabel)) {
    if(focused) {strokecolor[0] = color(int(strokecolorSaveLabel.getValue()), int(strokecolorAlphaSaveLabel.getValue()));} //""
    strokecolorBang.setColorForeground(strokecolor[0]);
  }
  else if (theEvent.isFrom(shapecolorSaveLabel) || theEvent.isFrom(shapecolorAlphaSaveLabel)) {
    if(focused) {shapecolor[0] = color(int(shapecolorSaveLabel.getValue()), int(shapecolorAlphaSaveLabel.getValue()));} //""
    shapecolorBang.setColorForeground(shapecolor[0]);
  }
  else if (theEvent.isFrom(styleSaveLabel)) {
    //float to bool in 2 lines, otherwise won't work in processing 2.2.1
    int val = int(styleSaveLabel.getValue());
    if( globalStyle != boolean(val) ) {
      if(globalStyle) {
        disableGlobalStyle();
        style.close();
      } else {
        enableGlobalStyle();
        style.open(); 
      }
    }
  }
  else if (theEvent.isFrom(loopDirectionSaveLabel)) {
    //float to bool in 2 lines, otherwise won't work in processing 2.2.1
    int val = int(loopDirectionSaveLabel.getValue());
    loopDirection = boolean(val);
  }
  else if (theEvent.isFrom(linebylineSaveLabel)) {
    //float to bool in 2 lines, otherwise won't work in processing 2.2.1
    int val = int(linebylineSaveLabel.getValue());
    linebyline = boolean(val);
  }
  else if (theEvent.isFrom(offsetxSaveLabel)) {
    manualOffsetX = offsetxSaveLabel.getValue();
    dragOffset.setText("OFFSET: " +(int)manualOffsetX +" x " +(int)manualOffsetY);
  }
  else if (theEvent.isFrom(offsetySaveLabel)) {
    manualOffsetY = offsetySaveLabel.getValue();
    dragOffset.setText("OFFSET: " +(int)manualOffsetX +" x " +(int)manualOffsetY);
  }

} //controlEvent




// ---------------------------------------------------------------------------
//  GUI ACTIONS
// ---------------------------------------------------------------------------

void toggleMenu() {
  showMENU = !(gui.getGroup("main").isOpen());
  if (showMENU) {
    surface.setSize(viewwidth+guiwidth, viewheight);
    gui.getGroup("main").open();
  } else {
    surface.setSize(viewwidth, viewheight);    
    gui.getGroup("main").close();
  }
}

void toggleHelp() {  
  showHELP = !(gui.getGroup("help").isOpen());
  if (showHELP) {
    helptextbox.setPosition((viewwidth-helpwidth)/2, (viewheight-helpheight)/2);
    renderer = getRenderer(this);
    help.open();
  } else {
    help.close();
  }
  
  try {
    tileEditor.showHelp(showHELP);
    mapEditor.showHelp(showHELP);
  } catch(NullPointerException e) {}
}

void toggleAnimate() {
  showANIMATE = !(gui.getGroup("animate").isOpen());
  if (showANIMATE) {
    openAnimate();
  } else {
    closeAnimate();
  }
}

void openAnimate() {
  animate.open();
  reorderGuiElements();
}

void closeAnimate() {
  animate.close();
  reorderGuiElements();
}

void disableGlobalStyle() {
  globalStyle = false;
  for (int i = 0; i < svg.size (); i++) {
    ((Tile)svg.get(i)).disableGlobalStyle();
  }
  if(tileEditor != null) tileEditor.updateGlobalStyle();
  reorderGuiElements();
}

void enableGlobalStyle() {
  globalStyle = true;
  for (int i = 0; i < svg.size (); i++) {
    ((Tile)svg.get(i)).enableGlobalStyle();
  }
  if(tileEditor != null) tileEditor.updateGlobalStyle();
  reorderGuiElements();
}

void linejoinmode(int m) {
  if(m == -1) {
    List<Toggle> items = linejoinRadioButton.getItems();
    int i = 0;
    for(Toggle item : items){
      if(int(item.internalValue()) == joinmode ) {
        linejoinRadioButton.activate(i);
        items = null;
        break;
      }
      i++;
    }
  } else { joinmode = m; }
}

void linecapmode(int m) {
  if(m == -1) {
    List<Toggle> items = linecapRadioButton.getItems();
    int i = 0;
    for(Toggle item : items){
      if(int(item.internalValue()) == capmode ) {
        linecapRadioButton.activate(i);
        items = null;
        break;
      }
      i++;
    }
  } else { capmode = m; }
}

void reorderGuiElements() {
  int imgmapheight = mapheight == 0 ? (int)mapheight : (int)mapheight+h+gapY;
  int styleheight = style.isOpen() ? 90 : 4;
  int animateheight = animate.isOpen() ? 70 : 4;

  animate.setPosition(indentX, style.getPosition()[1]+gapY+styleheight);
  lastguielem.setPosition(indentX, animate.getPosition()[1]+h/2+animateheight);
  
  int scrollpos = (int)main.getPosition()[1];
  if(scrollpos < 0) {
    if( (lastguielem.getPosition()[1] < (viewheight-infoheight))) { 
      main.setPosition(main.getPosition()[0], 0);
      showScrollbar = false;
    } else {
      if(scrollpos < -1*((int)lastguielem.getPosition()[1] - (viewheight-infoheight))) {
        int newy = (int)lastguielem.getPosition()[1] - (viewheight-infoheight);
        main.setPosition(main.getPosition()[0], -newy);
        showScrollbar = true;
      }
    }
  } else {
     if((lastguielem.getPosition()[1] >= (viewheight-infoheight))) {
       showScrollbar = true; 
     } else {
       showScrollbar = false; 
     }
  }
  if(showScrollbar) {
    scrollbarHeight = ( (viewheight-infoheight) / lastguielem.getPosition()[1] ) * (viewheight-infoheight);
    scrollbarY = (-main.getPosition()[1] / lastguielem.getPosition()[1]) * (viewheight-infoheight);
  }
}

void showExportLabel(boolean state) {
  if(state) {
    exportConfirmationLabel.setText("EXPORTED:     " +filename);
    exportinfo.show();
    showExportLabel = true;
    showExportLabelTimer = millis();
  } else {
    exportConfirmationLabel.setText("");
    exportinfo.hide();
    showExportLabel = false;
    showExportLabelTimer = 0;
  }
}

void toggleRandom() {
  random = !random;
  seed = mouseX;
}

void changebgcolor() {
  if(bg_copi == null) {
    bg_copi = new ColorPicker(this, "backgroundcolor", bgcolor, true, recentcolors);
    String[] args = {"colorpicker1"};
    PApplet.runSketch(args, bg_copi);
  } else {
    bg_copi.show(); 
  }
  colorpicking = true;

}
void changestrokecolor() {
  if(stroke_copi == null) {
    stroke_copi = new ColorPicker(this, "strokecolor", strokecolor, recentcolors);
    String[] args = {"colorpicker2"};
    PApplet.runSketch(args, stroke_copi);
  } else {
    stroke_copi.show();
  }
  colorpicking = true;

}
void changeshapecolor() {
  if(shape_copi == null) {
    shape_copi = new ColorPicker(this, "fillcolor", shapecolor, recentcolors);
    String[] args = {"colorpicker3"};
    PApplet.runSketch(args, shape_copi);
  } else {
    shape_copi.show(); 
  }
  colorpicking = true;
}

//void changetypecolor(float i) {} //in TileEditor
  
void toggleTileEditor() {
  if(tileEditor == null) {
    tileEditor = new TileEditor(this, 500, 600);
    String[] args = {"Petter - TILEEDITOR"};
    PApplet.runSketch(args, tileEditor);
    tileEditor.setTileList(svg);
  } else {
    if(tileEditor.opened) {
      tileEditor.hide(); 
    } else {
      tileEditor.show();
    }
  }
}

void toggleMapEditor() {
  if(mapEditor == null) {
    mapEditor = new MapEditor(this, 500, 600);
    String[] args = {"Petter - MAPEDITOR"};
    PApplet.runSketch(args, mapEditor);
  } else {
    if(mapEditor.opened) {
      mapEditor.hide(); 
    } else {
      mapEditor.show();
    }
  }
} 
 
void changeSliderRange(boolean increase) {
  if(gui.isMouseOver()) {
    try {
      ControllerInterface c = gui.getMouseOverList().get(0);
      if(c instanceof Slider) {
        Slider tmp = (Slider)c;
        if(increase) {
          tmp.setMin(tmp.getMin()*2f);
          tmp.setMax(tmp.getMax()*2f);
        } else {
          tmp.setMax(tmp.getMax()*0.5f);
          tmp.setMin(tmp.getMin()*0.5f);
        }
      }      
    } catch(IndexOutOfBoundsException e) {}
  }  
}

void updatextilenumSlider() {
  xTileNumSlider.setValue(xtilenum);
  undo.setUndoStep(); 
}

void updateytilenumSlider() {
  yTileNumSlider.setValue(ytilenum);
  undo.setUndoStep(); 
}

void enterShiftMode() {
  if(last != null && !shiftProcessed && last.isVisible()) { //omit invisible offset-sliders
    last.showTickMarks(true);
    last.snapToTickMarks(true);
    shiftProcessed = true;
  } 
}
void leaveShiftMode() {
  if(last != null && shiftProcessed && last.isVisible()) {
    last.showTickMarks(false);
    last.snapToTickMarks(false); 
    shiftProcessed = false; 
  }
}

void togglePageOrientation() {
  int tmppdfwidth = (int) hBox.getValue();
  int tmppdfheight = (int) wBox.getValue();  
  wBox.setValue(tmppdfwidth);
  hBox.setValue(tmppdfheight);
  
  canvasResize();
  
  int tmp = xtilenum;
  xtilenum = ytilenum;
  ytilenum = tmp;
  
  tilewidth  = (float(viewwidth -  (2*pageOffset)) / xtilenum);
  tilescale = tilewidth / svg.get(0).width;
  tileheight = svg.get(0).height * tilescale;
  
  while((tileheight * ytilenum) > viewheight) {
     ytilenum--; 
  }
  
  xTileNumSlider.setValue(xtilenum);
  yTileNumSlider.setValue(ytilenum); 
}

void nextImgMapFrame() {
  if(map.size() > mapIndex+1) {
    mapIndex++;
  }
}

void prevImgMapFrame() {
  if(mapIndex != 0) {
    mapIndex--;
  }  
}

void firstImgMapFrame() {
    mapIndex = 0;
}

void lastImgMapFrame() {
    mapIndex = map.size()-1;
}

void specImgMapFrame(int f) {
  if(map.size() != 0) {
    if(f < map.size()) {
      mapIndex = f;
    }  else {
      mapIndex = f%map.size();
    }
  }
}

// ---------------------------------------------------------------------------
//  FRAME RESIZING, ZOOM AND SCROLL
// ---------------------------------------------------------------------------

void canvasResize() {
  pagewidth = (int) wBox.getValue();
  pageheight = (int) hBox.getValue();
  resizeFrame(pagewidth, pageheight);
  if(mapEditor != null) mapEditor.updatePetterBounds(pagewidth, pageheight, xtilenum, ytilenum);
}

void resizeFrame(int newW, int newH) {
  viewwidth = int(newW*zoom);
  viewheight = int(newH*zoom); 
  
  if (showMENU) {
    newW = viewwidth+guiwidth;
    newH = viewheight;
  } else {
    newW = viewwidth;
    newH = viewheight;
  }
  surface.setSize(newW, newH);
  gui.getGroup("main").setPosition(viewwidth+12, main.getPosition()[1]);
  gui.getGroup("help").setSize(viewwidth, viewheight+1);
  gui.getGroup("helptextbox").setPosition((viewwidth-helpwidth)/2, (viewheight-helpheight)/2);
  gui.getGroup("info").setPosition(viewwidth, viewheight-infoheight);
  
  dropSVGadd.updateTargetRect(viewwidth, viewheight);
  dropSVGrep.updateTargetRect(viewwidth, viewheight);
  dropSVGnfo.updateTargetRect(viewwidth, viewheight);
  
  exportinfo.setSize(viewwidth, infoheight);
  exportinfo.setPosition(0, viewheight-infoheight);
  
  reorderGuiElements();
  
  gui.setGraphics(this, 0, 0);
  gui.update();
}

void scaleGUI(float newzoom) {
  zoom = newzoom;
  zoomLabel.setText("ZOOM: " +nf(zoom, 1, 1));
  resizeFrame(pagewidth, pageheight);
}

void scaleGUI(boolean bigger) {
  if(bigger) {
    zoom += .1;
  } else {
    if(zoom > 0.1) {
      zoom -= .1;
    }
  }
  zoomLabel.setText("ZOOM: " +nf(zoom, 1, 1));
  resizeFrame(pagewidth, pageheight);
}

//somewhat confusing and dirty
void menuScroll(int amount) {
  amount *= 2;
  if(!gui.isMouseOver() && mouseX > viewwidth) {
    int scrollpos = (int)main.getPosition()[1];
    if( (lastguielem.getPosition()[1]-scrollpos > (viewheight-infoheight))) {
      if(amount < 0) {
          if(scrollpos < 0) {
            scrollpos = (scrollpos-amount) > 0 ? 0 : scrollpos-amount;
            main.setPosition(main.getPosition()[0], scrollpos); 
          }
      } else {
        if((lastguielem.getPosition()[1]+scrollpos) > (viewheight-infoheight)) { //scroll upwards when longer
          main.setPosition(main.getPosition()[0], scrollpos-amount); 
        }
      }
    } else {
      if(scrollpos < 0) {
          main.setPosition(main.getPosition()[0], 0);
      }
    }
    scrollbarY = (-main.getPosition()[1] / lastguielem.getPosition()[1]) * (viewheight-infoheight);
  }
}


// ---------------------------------------------------------------------------
//  SETTINGS
// ---------------------------------------------------------------------------

void toggleSettings() {
  if(settingsFilelist == null || (settingsFilelist != null && !settingsFilelist.isOpen())) {
    gui.getProperties().setSnapshot("tmp");
    if(settingsFilelist != null) {
      settingsFilelist.remove();
    }
    try {
      findSettingFiles();
    } catch(NullPointerException e) {
      //no settings-folder
      return; 
    }
    
    settingsFilelist = new ScrollableListPlus(gui, "filelist");
    settingsFilelist
      .setPosition(30, 30)
      //.setSize(180, fheight-60)
      .setSize(180, 280)
      .setItemHeight(16)
      .setBarHeight(24)
      .setType(ControlP5.DROPDOWN);
  
    settingsFilelist.onMove(cbDropdownHover).onEnter(cbDropdownHover).onLeave(cbDropdownHover);
  
    settingsFilelist.getCaptionLabel().set("LAST SAVED SETTINGS");
    settingsFilelist.getCaptionLabel().setColor(0xffffffff);
    settingsFilelist.getCaptionLabel().getStyle().marginTop = 3;
    settingsFilelist.getValueLabel().getStyle().marginTop = 3;
  
    for (int i = 0; i < settingFiles.size(); i++) {
      settingsFilelist.addItem((String)(settingFiles.get(i)), i);
    }

    gui.getProperties().remove(settingsFilelist);
 } 
 else {
    gui.getProperties().getSnapshot("tmp");
    settingsFilelist.close();
    settingsFilelist.hide();
 } 
}

void loadSettings(String filename, boolean close) {
  //gui.getProperties().getSnapshot(settingspath +filename).print();
  try {
    gui.loadProperties(settingspath +filename);
  } catch(NullPointerException e) {}
  if(close) {
    settingsFilelist.close();
    settingsFilelist.hide();
    undo.setUndoStep();
  }
}

void saveSettings(String timestamp) {    
   gui.saveProperties(settingspath +timestamp +".json");
}

void loadDefaultSettings() {
  if(gui.isMouseOver()) {   //reset single controller
    try {
      ControllerInterface c = gui.getMouseOverList().get(0);
      if(c instanceof Slider || c instanceof ScrollableList) {
        c.setValue(  ((Controller)c).getDefaultValue() );
        println("Resetting " +c.getName());
      }
    } catch(IndexOutOfBoundsException e) {}
  }  
  else {                   //reset all controllers
    gui.loadProperties();
    nfoscale = 1f;
    println("Resetting all controllers ");
  }
  undo.setUndoStep();  
}

void findSettingFiles() {
  String[] allFiles = listFileNames(sketchPath("") +settingspath);
  allFiles = reverse(sort(allFiles));
  settingFiles = new ArrayList(); 
  for (int k = 0; k < allFiles.length; k++) {
    String file = allFiles[k];
    if (file.indexOf(".json") != -1) {
      settingFiles.add(file);
    }
  }
  allFiles = null;
  printArrayList(settingFiles); 
}


// ---------------------------------------------------------------------------
//  GENERAL UTIL
// ---------------------------------------------------------------------------

void checkArgs() {
  boolean firstSer = true;
  boolean firstSvg = true;
  
  if(args != null && args.length > 0) {
    for(int i=0; i<args.length; i++) {
      String ext = args[i].substring(args[i].lastIndexOf('.') + 1);
      if(ext.equals("svg")) {
        if(firstSvg) {
          firstSvg = false;
          svg.clear();
        }
        try { 
          svg.add(loadShape(args[i]));
        } catch(NullPointerException e) {svg.add(createShape(RECT, 0, 0, 50, 50));}
      } else if(ext.equals("json")) {
        if(firstSer) {
          firstSer = false;
          gui.loadProperties(args[i]);
        }
      }
    }
    if(!firstSer || !firstSvg) {
      batchmode = true;
      batchnow = false;
      undo.setUndoStep();
    }
  }
}

void generateName() {
    randomSeed(mouseX+mouseY+frameCount);
    if(batchmode) {
      name = "petterbatch";
    } else if(names != null) {
      name = names[int(random((float)names.length))];
    } else {
      name = "petter"; 
    }
    randomSeed(seed);
}

void generateTimestamp() {
  timestamp = year() +"" +nf(month(), 2) +"" +nf(day(), 2) +"" +"-" +nf(hour(), 2) +"" +nf(minute(), 2) +"" +nf(second(), 2);  
}

// return all files in a directory as string-array  
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

static String getRenderer(PApplet p) {
  Object window = p.getSurface().getNative();
  PGraphics pg  = p.getGraphics();
  if (window instanceof javafx.scene.canvas.Canvas) return "FX2D";
  else if (pg.isGL()) return pg.is3D()? "P3D" : "P2D";
  return "JAVA2D";
}

void printArrayList(ArrayList l) {
  println("----------------------------------");
  for (int i = 0; i < l.size(); i++) {
    println(l.get(i));
  }
  println("----------------------------------");
}

public void loadSystemFonts() {
  print("Loading system fonts... ");
  systemfonts = PFont.list();
  println("DONE");
}

PImage createCheckerboard(int ww, int hh) { 
  int sw = ww;
  int sh = hh;
  int col;
  int quadsize = 10;
  int[] checkercolors = {150, 180};
  boolean swap = false;
  PImage checkerboard = createImage(sw, sh, RGB);
  checkerboard.loadPixels();

  for ( int j = 0; j < sh; j++ ) {
    if(j%(quadsize*2) < quadsize) {
      swap = true;
    } else {
      swap = false;
    }
    for ( int i = 0; i < sw; i++ ) {
      int px = (j*sw)+i;
      if(px%(quadsize*2) < quadsize) {
        col = checkercolors[swap?0:1];
      } else {
        col = checkercolors[swap?1:0];
      }
      checkerboard.pixels[px] = color(col);
    }
  }  
  checkerboard.updatePixels();
  return checkerboard;
}

float ease(int type, float a, float b, float c, float d) {
  if (type == ROT) {
    type = rotType;
    if(c == 0f) { return 0f; }
  } else if (type == TRA) {
    type = traType;
    if(c == 0f) { return 0f; }
  } else if (type == SCA) {
    type = scaType;
    if(c == 0f) { return 1f; }
  } else /*if (type == ANM)*/ {
    type = animType;
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
