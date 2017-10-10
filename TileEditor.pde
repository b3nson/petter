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


class TileEditor extends PApplet {

  PApplet parent;

  private ControlP5 cp5;

  PShape svg;
  
  boolean opened = true;
  boolean preview = true;
  boolean drag = false;
  boolean reset = false;

  int w, h;
  int svgindex = -1;
  int svglength = 0;
  int time = -1;
  int TIMEOUT = 300;

  float offsetx, offsety, tmpx, tmpy;
  float scalex = 1f;
  float scaley = 1f;
  float zoom = 1f;
  
  ArrayList<PShape> shapelist;

  Button okButton, cancelButton, nextTileButton, prevTileButton, resetTileButton;
  Button deleteTileButton, moveTileBackButton, moveTileForeButton;
  Toggle previewToggle;
  Textfield tileCountLabel;
  Textlabel tezoomLabel;
  

  public TileEditor(PApplet theParent, int theWidth, int theHeight) {
    super();   
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public void settings() {
    size(w, h, JAVA2D); //P2D/JAVA2D
  }

  public void setup() { 
    //surface.setLocation(10, 10);
    shapeMode(CENTER);
    rectMode(CENTER);
    
    cp5 = new ControlP5(this, font);

    previewToggle = cp5.addToggle("preview")
      .setLabel("LIVE PREVIEW")
      .setPosition(144, h-21)
      .setSize(10, 10)
      .setValue(true)
      .setId(4)
      ;

    controlP5.Label l = previewToggle.getCaptionLabel();
    l.setHeight(10);
    l.getStyle().setPadding(2, 2, 2, 2);
    l.getStyle().setMargin(-15, 0, 0, 14);

    okButton = cp5.addButton("CLOSE")
      .setPosition(w-40-10, h-30-10)
      .setSize(40, 30)
      .setId(2)
      ;

    prevTileButton = cp5.addButton("PREV")
      .setLabel("<")
      .setPosition(0, 0)
      .setSize(w/2-20-1, 30)
      .setId(0)
      ;

    nextTileButton = cp5.addButton("NEXT")
      .setLabel(">")
      .setPosition(w/2+20+1, 0)
      .setSize(w/2, 30)
      .setId(1)
      ;

    tileCountLabel = cp5.addTextfield("TILECOUNT" )
      .setPosition(w/2 -20, 0)
      .setSize(40, 30)
      .setText("    1 / 1") 
      .setFocus(false)
      .setLock(true)
      .setColor(255)
      .setColorBackground(color(80))
      .setColorForeground(color(80))
      .setLabelVisible(false)
      .setLabel("")
      ;   

    resetTileButton = cp5.addButton("RESET TILE")
      .setLabel("RESET TILE")
      .setPosition(w-50-60-10, h-40)
      .setSize(60, 30)
      .setId(5)
      ;
    
    deleteTileButton = cp5.addButton("DELETE TILE")
      .setLabel("DELETE TILE")
      .setPosition(w-50-120-20, h-40)
      .setSize(60, 30)
      .setId(6)
      .hide()
      ;

    moveTileForeButton = cp5.addButton("<")
      .setLabel("<")
      .setPosition(10, h-40)
      .setSize(30, 30)
      .setId(7)
      .hide()
      ;
      
    moveTileBackButton = cp5.addButton(">")
      .setLabel(">")
      .setPosition(45, h-40)
      .setSize(30, 30)
      .setId(8)
      .hide()
      ;
      
    tezoomLabel = cp5.addTextlabel("tezoomlabel" )
      .setPosition(85, h-20)
      .setText("ZOOM:  1.0")
      ;

    ControllerProperties prop = cp5.getProperties();
    prop.remove(okButton);
    prop.remove(previewToggle);
    prop.remove(prevTileButton);
    prop.remove(nextTileButton);
    prop.remove(resetTileButton);
    prop.remove(deleteTileButton);
    prop.remove(moveTileBackButton);
    prop.remove(moveTileForeButton);
    prop.remove(tezoomLabel);
    prop.remove(tileCountLabel);

    show();
    smooth();
  }//end setup


  //---------------------------------------------------------------------------------- DRAW


  void draw() {
    background(50);

    //timeout for scroll-scale without live-preview
    if ( time != -1 ) {
      if (millis() > time+TIMEOUT) {
        time = -1;
        updateScale();
      }
    }

    if (svg != null) {
      //shapeMode(CENTER);
      
      pushMatrix();
      translate(w/2, h/2);
      scale(zoom);

      strokeWeight(1f/zoom);

      //viewbox fill
      fill(200, 100);
      noStroke();
      rect(0, 0, svg.width, svg.height);

      pushStyle();
      if (customStyle) {
        svg.disableStyle();

        if (customStroke) {
          stroke(strokecolor[0]);
          strokeWeight(customStrokeWeight);
        } else {
          noStroke();
        }
        if (customFill) {
          fill(shapecolor[0]);
        } else {
          noFill();
        }
      } else {
        svg.enableStyle();
      }

      if (preview) {
        shape(svg);        
      } else {
        shape(svg, tmpx-((Tile)( shapelist.get(svgindex) )).offsetx, tmpy-((Tile)( shapelist.get(svgindex) )).offsety );
      }

      popStyle();

      //viewbox refsize
      noFill();
      stroke(0, 150, 255, 80);
      rect(0, 0, shapelist.get(0).width, shapelist.get(0).height);

      //viewbox
      stroke(150, 80);
      rect(0, 0, svg.width, svg.height);
      line(-svg.width/2, -svg.height/2, svg.width/2, svg.height/2 );
      line(svg.width/2, -svg.height/2, -svg.width/2, svg.height/2 );
      popMatrix();
    }
  }//draw


  //---------------------------------------------------------------------------------- FUNCTIONS


  public void setTileList(ArrayList<PShape> slist) {
    shapelist = slist;
    svgindex = 0;
    svglength = slist.size();
    svg = shapelist.get(svgindex);
    //setCountLabel();
  }
  
  public void updateTileList(ArrayList<PShape> slist, int mode) {
    shapelist = slist;
    svglength = shapelist.size();
    if (mode == REPLACESVG) {
      svgindex = 0;
      offsetx = 0;
      offsety = 0;
      scalex = 1;
      scaley = 1;
      tmpx = 0;
      tmpy = 0;
    }
    svg = shapelist.get(svgindex);
    setCountLabel();
    setDeleteButtonStatus();
    setMoveButtonStatus();
  }

  private void updateScale() {    
    ((Tile)( shapelist.get(svgindex) )).scalex = scalex;
    ((Tile)( shapelist.get(svgindex) )).scaley = scaley;
  }

  private void updateTranslate() {
    ((Tile)( shapelist.get(svgindex) )).offsetx -= offsetx;
    ((Tile)( shapelist.get(svgindex) )).offsety -= offsety;
  }

  private void moveTileOrder(int index, boolean direction) {
    PShape tmp = shapelist.get(svgindex);
    shapelist.remove(index);
    
    if(direction) { //move left
      shapelist.add(svgindex-1, tmp);
      prevTile();  
    } else {        //move right
      shapelist.add(svgindex+1, tmp);
      nextTile();
    } 
  }
  
  private void resetTile(int index) {
    ((Tile)( shapelist.get(svgindex) )).reset();
    tmpx = 0;
    tmpy = 0;
    scalex = 1;
    scaley = 1;
  }

  private void deleteTile(int index) {
    shapelist.remove(index);
    svglength = shapelist.size();
    if(svgindex > svglength-1) {
      svgindex--;
    } 
    svg = shapelist.get(svgindex);
    updateLocalValuesfromTile();
    
    setCountLabel();
    setDeleteButtonStatus();
    setMoveButtonStatus();
  }

  private void prevTile() {
    if (svglength > 1) {
      svgindex = (svgindex-1)%svglength;
      if (svgindex == -1) svgindex = svglength-1;
      setCountLabel();

      ((Tile)( svg )).offsetx = tmpx; //vorsichtshalber, wenn prev before dragrelease
      ((Tile)( svg )).offsety = tmpy;

      svg = shapelist.get(svgindex);
      updateLocalValuesfromTile();
      setMoveButtonStatus();
    }
  }

  private void nextTile() {
    if (svglength > 1) {
      svgindex = (svgindex+1)%svglength;
      setCountLabel();

      ((Tile)( svg )).offsetx = tmpx; //vorsichtshalber, wenn next before dragrelease
      ((Tile)( svg )).offsety = tmpy;

      svg = shapelist.get(svgindex);
      updateLocalValuesfromTile();
      setMoveButtonStatus();
    }
  }

  private void updateLocalValuesfromTile() {
    tmpx = ((Tile)( svg )).offsetx;
    tmpy = ((Tile)( svg )).offsety;
    scalex = ((Tile)( svg )).scalex;
    scaley = ((Tile)( svg )).scaley;    
  }
  
  
  //---------------------------------------------------------------------------------- CALLBACK


  public void controlEvent(ControlEvent theEvent) {
    switch(theEvent.getId()) {
      case(0): //PREV
      prevTile();
      break;
      case(1): //NEXT
      nextTile();
      break;
      case(2): //OK
      closeAndApply();
      break;
      case(3): //X
      closeAndCancel();
      break;
      case(4): //PREVIEW
      //togglePreview();
      break;
      case(5): //RESETTILE
      resetTile(svgindex);
      break;
      case(6): //DELETETILE
      deleteTile(svgindex);
      break;
      case(7): //MOVEFORE
      moveTileOrder(svgindex, true);
      break;
      case(8): //MOVEBACK
      moveTileOrder(svgindex, false);
      break;
    }
  }

  public void hide() {
    this.noLoop();
    opened = false;
    surface.setVisible(false); 
    //win.hide();
  }

  public void show() {
    this.loop();
    opened = true;
    surface.setVisible(true);
    keysDown[lastKey] = false; //reset missing keyRelease
    
    setDeleteButtonStatus();
    setMoveButtonStatus();
    setCountLabel();
    //win.show();
  }

  private void closeAndApply() {
    hide(); 
    //win.dispatchEvent(new WindowEvent(win, WindowEvent.WINDOW_CLOSING));
  }

  private void closeAndCancel() {
    hide(); 
    //win.dispatchEvent(new WindowEvent(win, WindowEvent.WINDOW_CLOSING));
  }

  private void scaleGUI(boolean bigger) {
    if (bigger) {
      this.zoom += .1;
    } else {
      if (this.zoom > 0.1) {
        this.zoom -= .1;
      }
    }
    tezoomLabel.setText("ZOOM:  " +nf(zoom, 1, 1));
  }

  private void scaleGUI(float newzoom) {
    this.zoom = newzoom;
    tezoomLabel.setText("ZOOM:  " +nf(zoom, 1, 1));
  }

  private void setCountLabel() {
    tileCountLabel.setText("    " +(svgindex+1) +" / " +shapelist.size());
  }

  private void setDeleteButtonStatus() {
    if(svglength <= 1) {
      deleteTileButton.hide();
    } else {
      deleteTileButton.show();    
    }
  }

  private void setMoveButtonStatus() {
    if(svglength == 1) {
      moveTileForeButton.hide();
      moveTileBackButton.hide();
    } else {
      if(svgindex == 0) {
        moveTileForeButton.hide();
        moveTileBackButton.show();
      } else if(svgindex == svglength-1) {
        moveTileBackButton.hide();
        moveTileForeButton.show();
      } else {
        moveTileForeButton.show();
        moveTileBackButton.show();
      }
    }
  }
  
  
  
  //---------------------------------------------------------------------------------- UIINPUT


  void mousePressed() {}

  void mouseDragged ( ) {
    drag = true;
    offsetx = ((pmouseX - mouseX)/zoom);
    offsety = ((pmouseY - mouseY)/zoom);

    tmpx -= offsetx;
    tmpy -= offsety;

    if (preview) {
      updateTranslate();
    }
  }  

  void mouseReleased() {
    if (drag || reset) {
      drag = false;
      reset = false;

      if (!preview) {
        ((Tile)( shapelist.get(svgindex) )).offsetx = tmpx;
        ((Tile)( shapelist.get(svgindex) )).offsety = tmpy;
        offsetx = 0;
        offsety = 0;
        updateTranslate();
      }
    }
  }

  void mouseWheel(MouseEvent event) {
    if (!preview) {
      time = millis();
    }
    float e = event.getAmount();
    
    scalex -= e*0.01;
    scaley -= e*0.01;

    if (preview) {
      updateScale();
    }
  }


  void keyPressed() {
    if (key == CODED) {
      if (keyCode == LEFT) {
        prevTile();
      } else if (keyCode == RIGHT) {
        nextTile();
      } else { //forward to pettermain
        parent.key=key;
        parent.keyCode=keyCode;
        parent.keyPressed(); 
      }
    } else {
      if (key == RETURN || key == ENTER) {
        closeAndApply();
      } else if (key == ESC || keyCode==ESC) {
        key=0;
        keyCode=0;
        closeAndCancel();
      } else if (key == 'p') {
        preview = !preview;
        previewToggle.setState(preview);
      } else if (key == 't') {
        hide();
      } else if (keyCode == 93 || keyCode == 107) { //PLUS
        this.scaleGUI(true);
      } else if (keyCode == 47 || keyCode == 109) { //MINUS
        this.scaleGUI(false);
      } else { //forward to pettermain
        parent.key = key;
        parent.keyCode = keyCode;
        parent.keyPressed(); 
      }
    }
  }
  
  void keyReleased() {
    processKey(keyCode, false); //debounce parent
  }
}