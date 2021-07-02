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


public class ColorPicker extends PApplet {

  PApplet parent;
  private ControlP5 cp5;

  private int w = 390;//380
  private int h = 275;//300

  private float hue = 0;
  private float sat = 0;
  private float bri = 0;
  private float alp = 255;

  private color startCol;
  private color curCol;
  private color[] srccol;
  private color[] recents = {0,0,0,0};

  private String name;

  private boolean opened = true;
  private boolean preview = true;
  private boolean undoable = true;
  private boolean showalpha = true;

  private Slider2D s2D;
  private Slider s1Dh, s1Da;
  private Textlabel rgbValueLabel, hsbValueLabel, hexValueLabel;
  private Button okButton, cancelButton;
  private Button recentColor1Button, recentColor2Button, recentColor3Button, recentColor4Button;
  private Toggle previewToggle;
  private Group infoui;

  private PImage alphaChecker, curColChecker, startColChecker;
  private PImage hueBuffer, satbriBuffer, alphaBuffer;

  public ColorPicker(PApplet theParent, String theName, color[] col, boolean showAlphaSlider, color[] recents) {
    this(theParent, theName, col, showAlphaSlider);
    this.recents = recents;
  }
  
  public ColorPicker(PApplet theParent, String theName, color[] col, boolean showAlphaSlider) {
    this(theParent, theName, col);
    showalpha = showAlphaSlider;
    if(!showalpha) { w -= 25; }
  }

  public ColorPicker(PApplet theParent, String theName, color[] col, color[] recents) {
    this(theParent, theName, col);
    this.recents = recents;
  }
  
  public ColorPicker(PApplet theParent, String theName, color[] col) {
    parent = theParent;
    startCol = col[0];
    curCol = col[0];
    srccol = col;
    name = theName;
  }
  //using a color-array here, to set color-value of mainapp directly (like pass-by-reference in C/C++)


  // ---------------------------------------------------------------------------
  //  SETUP
  // ---------------------------------------------------------------------------

  void settings() {
    size(w, h, JAVA2D);
  }

  void setup() {
    surface.setTitle(name);
    frameRate(25);

    cp5 = new ControlP5(this);

    s2D = cp5.addSlider2D("s2D")
      .setPosition(10, 10)
      .setSize(255, 255)
      .setMaxX(255)
      .setMaxY(0)
      .setMinX(0)
      .setMinY(255)
      .setId(0)
      .setColorBackground(color(255, 1))//0 for alpha does not work
      ;
    s2D.getCaptionLabel().hide();
    s2D.getValueLabel().hide();

    s1Dh = cp5.addSlider("s1D")
      .setPosition(270, 10)
      .setSize(20, 255)
      .setRange(255, 0)
      .setValue(128)
      .setSliderMode(Slider.FLEXIBLE)
      .setHandleSize(1)
      .setId(1)
      .setScrollSensitivity(0.0392)
      .setColorBackground(color(255, 1))
      ;
    s1Dh.getCaptionLabel().hide();
    s1Dh.getValueLabel().hide();

    if(showalpha) {
      s1Da = cp5.addSlider("s1Da")
        .setPosition(295, 10)
        .setSize(20, 255)
        .setRange(255, 0)
        .setValue(128)
        .setSliderMode(Slider.FLEXIBLE)
        .setHandleSize(1)
        .setId(5)
        .setScrollSensitivity(0.0392)
        .setColorBackground(color(255, 1))
        ;
      s1Da.getCaptionLabel().hide();
      s1Da.getValueLabel().hide();
    }

    infoui = cp5.addGroup("infoui")
           .setPosition(295, 0)
           .hideBar()
           ;
    if(showalpha) {
      infoui.setPosition(320, 0);
    }
    
    recentColor1Button = cp5.addButton("rc1")
     .setLabel("A")
     .setPosition(0, 91)
     .setSize(15, 10)
     .setColor(new CColor(recents[0], recents[0], recents[0], recents[0], recents[0]))
     .setGroup(infoui)
     ;
     
    recentColor2Button = cp5.addButton("rc2")
     .setLabel("A")
     .setPosition(15, 91)
     .setSize(15, 10)
     .setColor(new CColor(recents[1], recents[1], recents[1], recents[1], recents[1]))
     .setGroup(infoui)
     ;
     
    recentColor3Button = cp5.addButton("rc3")
     .setLabel("A")
     .setPosition(30, 91)
     .setSize(15, 10)
     .setColor(new CColor(recents[2], recents[2], recents[2], recents[2], recents[2]))
     .setGroup(infoui)
     ;
     
    recentColor4Button = cp5.addButton("rc4")
     .setLabel("A")
     .setPosition(45, 91)
     .setSize(15, 10)
     .setColor(new CColor(recents[3], recents[3], recents[3], recents[3], recents[3]))
     .setGroup(infoui)
     ;
          
    rgbValueLabel = cp5.addTextlabel("RGB" )
      .setPosition(-2, 114)
      .setText("RGBA")
      .setGroup(infoui)
      ;

    hsbValueLabel = cp5.addTextlabel("HSB" )
      .setPosition(-2, 158)
      .setText("HSB")
      .setGroup(infoui)
      ;

    hexValueLabel = cp5.addTextlabel("HEX" )
      .setPosition(-2, 192)
      .setText("HEX")
      .setGroup(infoui)
      ;

    previewToggle = cp5.addToggle("preview")
      .setLabel("preview")
      .setPosition(0, 218)
      .setSize(10, 10)
      .setValue(true)
      .setId(4)
      .setGroup(infoui)
      ;
      previewToggle.getCaptionLabel().setPadding(14, -10);

    okButton = cp5.addButton("OK")
      .setPosition(0, 236)
      .setSize(40, 30)
      .setId(2)
      .setGroup(infoui)
      ;
      
    cancelButton = cp5.addButton("CANCEL")
      .setLabel("X")
      .setPosition(42, 236)
      .setSize(18, 30)
      .setId(3)
      .setGroup(infoui)
      ;

    ControllerProperties prop = cp5.getProperties();
    prop.remove(cancelButton);
    prop.remove(okButton);
    prop.remove(previewToggle);
    prop.remove(hexValueLabel);
    prop.remove(hsbValueLabel);
    prop.remove(rgbValueLabel);
    prop.remove(s1Dh);
    prop.remove(s1Da);
    prop.remove(s2D);

    if(showalpha) {
      alphaChecker = createCheckerboard(20, 255);
      curColChecker = createCheckerboard(60, 40);
      startColChecker = createCheckerboard(60, 40);
    }
    updateHueBuffer();
    
    colorMode(RGB, 255);
    
    show();
    smooth();
  } //end setup


  // ---------------------------------------------------------------------------
  //  DRAW
  // ---------------------------------------------------------------------------

  void draw() {

    background(50);
    noStroke();

    if(showalpha) image(curColChecker, 320, 10);
    fill(curCol);
    rect(showalpha?320:295, 10, 60, 40);
    if(showalpha) image(startColChecker, 320, 50);
    fill(startCol);
    rect(showalpha?320:295, 50, 60, 40);

    image(satbriBuffer, s2D.getPosition()[0], s2D.getPosition()[1]);
    image(hueBuffer, s1Dh.getPosition()[0], s1Dh.getPosition()[1]);
    if(showalpha) image(alphaChecker, s1Da.getPosition()[0], s1Da.getPosition()[1]);
    if(showalpha) image(alphaBuffer, s1Da.getPosition()[0], s1Da.getPosition()[1]);
  }


  // ---------------------------------------------------------------------------
  //  GUI FUNCTIONS
  // ---------------------------------------------------------------------------

  public boolean isOpen() {
    return opened;
  }

  public void setUndoable(boolean able) {
    undoable = able;
  }

  public void hide() {
    this.noLoop();
    surface.setVisible(false);
    opened = false;
  }

  public void show() {
    this.loop();
    updateColor();
    initSliders(startCol);
    updatePreviewColor();
    updateRecentColorLabels();
    surface.setVisible(true);
    opened = true;
  }

  public void exit() { //on native window-close
   closeAndCancel();
  }

  public void setExtColor(color ec) {
    if(s1Dh != null) {
      curCol = ec;
      hue = hue(ec);
      sat = saturation(ec);
      bri = brightness(ec);
      alp = alpha(ec);
      updatePreviewColor();
      initSliders(ec);
    }
  }
  
  private void closeAndApply() {
    startCol = curCol;
    srccol[0] = curCol;
    setNewRecentColor(curCol);
    hide();
    if(undoable) {
      undo.setUndoStep();
    }
  }

  private void closeAndCancel() {
    curCol=startCol;
    srccol[0] = startCol;
    hide();
  }

  private void updateColor() {
    colorMode(RGB, 255);
    startCol = srccol[0];
    curCol = srccol[0];
  }

  private void updateRecentColorLabels() {
    colorMode(RGB, 255);
    recentColor1Button.setColor(new CColor(recents[0], recents[0], recents[0], recents[0], recents[0]));
    recentColor2Button.setColor(new CColor(recents[1], recents[1], recents[1], recents[1], recents[1]));
    recentColor3Button.setColor(new CColor(recents[2], recents[2], recents[2], recents[2], recents[2]));
    recentColor4Button.setColor(new CColor(recents[3], recents[3], recents[3], recents[3], recents[3]));
  }
  
  private void updatePreviewColor() {
    colorMode(HSB, 255, 255, 255, 255);
    color tmp = color(hue, sat, bri, alp);
    colorMode(RGB, 255);
    
    curCol =  tmp;
    
    if (preview) {
      srccol[0] = curCol;
    } else {
      srccol[0] = startCol;
    }
    
    String rgb = "R " +(int)red(curCol) +"\nG " +(int)green(curCol) +"\nB " +(int)blue(curCol);
    if(showalpha) {
      rgb += "\nA " +(int)alpha(curCol);
    }
    rgbValueLabel.setText(rgb);
    hsbValueLabel.setText("H " +(int)hue(curCol) +"\nS " +(int)saturation(curCol) +"\nB " +(int)brightness(curCol));
    hexValueLabel.setText(hex(curCol, 6));
  }

  private void initSliders(color c) {
    colorMode(RGB, 255);
    hue = hue(c);
    sat = saturation(c);
    bri = brightness(c)-255;
    alp = alpha(c);
    s1Dh.setValue(hue);
    s2D.setArrayValue(new float[] {sat, bri});
    if(showalpha) {
      s1Da.setValue(alp);
      updateAlphaBuffer();
    }
    updateSatBriBuffer();
  }

  private void setNewRecentColor(color c) {
    boolean duplicate = false;
    for(int i = 0; i<recents.length; i++) {
      if(recents[i] == c) {
         duplicate = true;
         break;
      }
    }
    if(!duplicate) {
      recents[3] = recents[2];
      recents[2] = recents[1];
      recents[1] = recents[0];
      recents[0] = curCol;
    }
  }

  // ---------------------------------------------------------------------------
  //  DRAW IMGBUFFERS
  // ---------------------------------------------------------------------------
  
  private void updateAlphaBuffer() {
    if(alphaBuffer == null) { alphaBuffer = createImage(20, 255, ARGB); }
    alphaBuffer.loadPixels();
    for ( int j = 0; j < 255; j++ ) {
      for ( int i = 0; i < 20; i++ ) {
        alphaBuffer.pixels[j*20+i] = color( red(curCol), green(curCol), blue(curCol), j );
      }
    }
    alphaBuffer.updatePixels();
  }

  private void updateSatBriBuffer() {
    colorMode(HSB, 255);
    if(satbriBuffer == null) { satbriBuffer = createImage(255, 255, RGB); }
    satbriBuffer.loadPixels();
    for ( int j = 0; j < 255; j++ ) {
      for ( int i = 0; i < 255; i++ ) {
        satbriBuffer.pixels[i*255+j] = color( hue, j, 255 - i );
      }
    }
    satbriBuffer.updatePixels();
    colorMode(RGB, 255);
  }

  private void updateHueBuffer() {
    colorMode(HSB, 255);
    if(hueBuffer == null) { hueBuffer = createImage(20, 255, RGB); }
    hueBuffer.loadPixels();
    for ( int j = 0; j < 255; j++ ) {
      for ( int i = 0; i < 20; i++ ) {
        hueBuffer.pixels[j*20+i] = color( j, 255, 255 );
      }
    }
    hueBuffer.updatePixels();
    colorMode(RGB, 255);
  }
  

PImage createCheckerboard(int ww, int hh) { 
  int sw = ww;
  int sh = hh;
  int col;
  int quadsize = 5;

  int[] checkercolors = {64, 192};
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


  // ---------------------------------------------------------------------------
  //  GUI LISTENER
  // ---------------------------------------------------------------------------

  public void controlEvent(ControlEvent theEvent) {
    switch(theEvent.getId()) {
      case(0): //sat-bri
      sat = (theEvent.getController().getArrayValue())[0];
      bri = (theEvent.getController().getArrayValue())[1];
      updatePreviewColor();
      if(showalpha) updateAlphaBuffer();
      break;
      case(1): //hue
      hue = (theEvent.getController().getValue());
      updatePreviewColor();
      if(showalpha) updateAlphaBuffer();
      updateSatBriBuffer();
      break;
      case(5): //alpha
      alp = (theEvent.getController().getValue());
      updatePreviewColor();
      break;
      case(2): //OK
      closeAndApply();
      break;
      case(3): //X
      closeAndCancel();
      break;
      case(4): //PREVIEW
      preview = boolean((int)theEvent.getController().getValue());
      updatePreviewColor();
      break;
    }
  }


  // ---------------------------------------------------------------------------
  //  INPUT LISTENER
  // ---------------------------------------------------------------------------
  
  public void mouseClicked(MouseEvent evt) {
     if(cp5.isMouseOver(cp5.getController("rc1"))) {
       setExtColor(recentColor1Button.getColor().getBackground());
     } else if (cp5.isMouseOver(cp5.getController("rc2"))) {
       setExtColor(recentColor2Button.getColor().getBackground());
     } else if (cp5.isMouseOver(cp5.getController("rc3"))) {
       setExtColor(recentColor3Button.getColor().getBackground());
     } else if (cp5.isMouseOver(cp5.getController("rc4"))) {
       setExtColor(recentColor4Button.getColor().getBackground());
     }
  }

  void keyPressed() {
    if (key == RETURN || key == ENTER) {
      closeAndApply();
    } else if (key == ESC || keyCode==ESC) {
      key=0;
      keyCode=0;
      closeAndCancel();
    }
  }

  void keyTyped() {
    if (keyCode==ESC || key == ESC) {
      key = 0;
      keyCode = 0;
    }
  }

  void mouseWheel(MouseEvent event) {
    float e = event.getAmount();
    cp5.setMouseWheelRotation((int)e);
  }
}
