/**
 * Petter - vector-graphic-based pattern generator.
 * http://www.lafkon.net/petter/
 * Copyright (C) 2021 LAFKON/Benjamin Stephan
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


class MapEditor extends PApplet {

  PApplet parent;

  private ControlP5 cp5;
  private SDrop dropx;
  
  DropTargetIMG dropIMGx;
  
  boolean opened = true;
  boolean reset = false;
  boolean mapEditorOpened = false;
  boolean mapEditorCreated = false;
  
  int w, h;  
  

  public MapEditor(PApplet theParent, int theWidth, int theHeight) {
    super();   
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public void settings() {
    size(w, h, JAVA2D);
  } 
  
  // ---------------------------------------------------------------------------
  //  GUI SETUP
  // ---------------------------------------------------------------------------


  public void setup() { 
    cp5 = new ControlP5(this, font);
    
    dropx = new SDrop((Component)this.surface.getNative(), this);
    dropIMGx = new DropTargetIMG(this); 
    dropx.addDropListener(dropIMGx);
    
  }
  
  
  // ---------------------------------------------------------------------------
  //  DRAW
  // ---------------------------------------------------------------------------
  
  
  void draw() {
    background(50);
    shapeMode(CENTER);
    
        
    

  pushStyle();
  shapeMode(CENTER);
  noStroke();
  dropIMGx.draw();
  popStyle();
  }//draw
  
  
  // ---------------------------------------------------------------------------
  //  GUI EVENTHANDLING
  // ---------------------------------------------------------------------------



  // ---------------------------------------------------------------------------
  //  GUI ACTIONS
  // ---------------------------------------------------------------------------

  public void hide() {
    this.noLoop();
    opened = false;
    surface.setVisible(false); 
  }

  public void show() {
    this.loop();
    opened = true;
    surface.setVisible(true);
    keysDown[lastKey] = false; //reset missing keyRelease

    //setDeleteButtonStatus();
    //setMoveButtonStatus();
    //setCountLabel();
  }

  public void exit() { //on native window-close
    hide();
  }
  
  private void closeAndApply() {
    hide(); 
  }
  
  // ---------------------------------------------------------------------------
  //  INPUT EVENTS
  // ---------------------------------------------------------------------------
  

  void keyPressed() {
    if (key == CODED) {
      if (keyCode == LEFT) {
        //prevTile();
      } else if (keyCode == RIGHT) {
        //nextTile();
      } else { //forward to pettermain
        if (!mapEditorOpened) {
          parent.key=key;
          parent.keyCode=keyCode;
          parent.keyPressed();
        }
      }
    } else {
      if (!mapEditorOpened) {
        if (key == RETURN || key == ENTER) {
          closeAndApply();
        } else if (key == ESC || keyCode==ESC) {
          key=0;
          keyCode=0;
          closeAndApply();
        } else if (key == 't') {
          //hide();
        } else if (keyCode == 93 || keyCode == 107) { //PLUS
          //this.scaleGUI(true);
        } else { //forward to pettermain
          parent.key = key;
          parent.keyCode = keyCode;
          parent.keyPressed();
        }
      } else {
        if (key == ESC || keyCode==ESC) {
          key=0;
          keyCode=0;
          //closeTypeTileEditor();
          return;
        } else if (keyCode == 93 || keyCode == 107) { //PLUS
          //this.scaleGUI(true);
        } else if (keyCode == 47 || keyCode == 109) { //MINUS
          //this.scaleGUI(false);
        }
      }
    }
  }

  void keyReleased() {
    processKey(keyCode, false); //debounce parent
  }
  
}
