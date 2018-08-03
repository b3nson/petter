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
  PShape typeShape;
  Tile explodeOrigin;
  PFont typefont;

  boolean opened = true;
  boolean drag = false;
  boolean reset = false;
  boolean recursive = false;
  boolean typeEditorOpened = false;
  boolean typeEditorCreated = false;
  boolean fontlistLoaded = false;

  int w, h;
  int svgindex = -1;
  int svglength = 0;
  int time = -1;
  int TIMEOUT = 300;
  int fontsize = 100;
  int lockColor = 130;
  int unlockColor = 255;

  float offsetx, offsety, tmpx, tmpy;
  float scalex = 1f;
  float scaley = 1f;
  float rotation = 0f;
  float zoom = 1f;
  float baseline = 0f;
  float typeypos = 0f;

  String fontname = "Monospaced";
  char lastchar = 'P';

  ArrayList<PShape> shapelist;

  Group mainGroup, typeGroup;
  Button okButton, cancelButton, nextTileButton, prevTileButton, resetTileButton;
  Button deleteTileButton, moveTileBackButton, moveTileForeButton, explodeTileButton;
  Button addTextButton;
  Toggle recursiveToggle;
  Textfield tileCountLabel;
  Textlabel tezoomLabel, sLabel, rLabel, pLabel;

  ScrollableListPlus fontlist;
  Numberbox fontsizeBox, baselineBox;
  Button createTypeTileButton;

  public TileEditor(PApplet theParent, int theWidth, int theHeight) {
    super();   
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public void settings() {
    size(w, h, JAVA2D); //P2D/JAVA2D
  }


  // ---------------------------------------------------------------------------
  //  GUI SETUP
  // ---------------------------------------------------------------------------

  public void setup() { 
    //surface.setLocation(10, 10);
    shapeMode(CENTER);
    rectMode(CENTER);
    textMode(SHAPE);
    textAlign(CENTER, BASELINE);

    cp5 = new ControlP5(this, font);

    mainGroup = cp5.addGroup("mainGroup")
      .setPosition(0, 0)
      .hideBar()
      .setBackgroundHeight(h)
      .setWidth(w)
      .open()
      ;

    okButton = cp5.addButton("CLOSE")
      .setPosition(w-34-10, h-30-10)
      .setSize(34, 30)
      .setId(2)
      .setGroup(mainGroup);
    ;

    addTextButton = cp5.addButton("+T")
      .setPosition(w-40-30-10, h-40)
      .setSize(30, 30)
      .setId(11)
      //.setGroup(mainGroup);
      ;

    prevTileButton = cp5.addButton("PREV")
      .setLabel("<")
      .setPosition(0, 0)
      .setSize(w/2-20-1, 30)
      .setId(0)
      .setGroup(mainGroup);
    ;

    nextTileButton = cp5.addButton("NEXT")
      .setLabel(">")
      .setPosition(w/2+20+1, 0)
      .setSize(w/2, 30)
      .setId(1)
      .setGroup(mainGroup);
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
      .setGroup(mainGroup);
    ;   

    resetTileButton = cp5.addButton("RESET TILE")
      .setLabel("RESET TILE")
      .setPosition(w-40-60-30-10, h-40)
      .setSize(56, 30)
      .setId(5)
      .setGroup(mainGroup);
    ;

    deleteTileButton = cp5.addButton("DELETE TILE")
      .setLabel("DELETE TILE")
      .setPosition(w-50-180-30-20, h-40)
      .setSize(60, 30)
      .setId(6)
      .setGroup(mainGroup);
    ;

    explodeTileButton = cp5.addButton("EXPLODE")
      .setLabel("EXPLODE")
      .setPosition(w-50-110-30-20, h-40)
      .setSize(60, 18)
      .setId(9)
      .setGroup(mainGroup);
    ;

    recursiveToggle = cp5.addToggle("recursive")
      .setLabel("RECURSIVE")
      .setPosition(w-50-110-30-20, h-40+22)
      .setSize(8, 8)
      .setValue(recursive)
      .setId(10)
      .setGroup(mainGroup);
    ;

    controlP5.Label lr = recursiveToggle.getCaptionLabel();
    lr.setHeight(10);
    lr.getStyle().setPadding(2, 2, 2, 2);
    lr.getStyle().setMargin(-15, 0, 0, 14);


    moveTileForeButton = cp5.addButton("<")
      .setLabel("<")
      .setPosition(130, h-40)
      .setSize(30, 30)
      .setId(7)
      .setGroup(mainGroup);
    ;

    moveTileBackButton = cp5.addButton(">")
      .setLabel(">")
      .setPosition(165, h-40)
      .setSize(30, 30)
      .setId(8)
      .setGroup(mainGroup);
    ;

    tezoomLabel = cp5.addTextlabel("tezoomlabel" )
      .setPosition(60, h-20)
      .setText("ZOOM:  1.0")
      //.setGroup(mainGroup);
      ;

    sLabel = cp5.addTextlabel("sLabel" )
      .setPosition(10, h-20)
      .setText("S:  1.0")
      .setGroup(mainGroup);
    ;

    rLabel = cp5.addTextlabel("rLabel" )
      .setPosition(10, h-30)
      .setText("R:  0.0")
      .setGroup(mainGroup);
    ;

    pLabel = cp5.addTextlabel("pLabel" )
      .setPosition(10, h-40)
      .setText("P:  0.0 x 0.0")
      .setGroup(mainGroup);
    ;

    ControllerProperties prop = cp5.getProperties();
    prop.remove(mainGroup);
    prop.remove(okButton);
    prop.remove(addTextButton);
    prop.remove(recursiveToggle);
    prop.remove(prevTileButton);
    prop.remove(nextTileButton);
    prop.remove(resetTileButton);
    prop.remove(deleteTileButton);
    prop.remove(explodeTileButton);
    prop.remove(moveTileBackButton);
    prop.remove(moveTileForeButton);
    prop.remove(tezoomLabel);
    prop.remove(sLabel);
    prop.remove(rLabel);
    prop.remove(pLabel);
    prop.remove(tileCountLabel);

    show();
    smooth();
  }//end setup


  // ---------------------------------------------------------------------------
  //  GUI SETUP TYPEEDITOR
  // ---------------------------------------------------------------------------

  public void setupTypeTileEditor() {

    typeGroup = cp5.addGroup("typeGroup")
      .setPosition(10, 10)
      .hideBar()
      .setBackgroundHeight(h-19)
      .setWidth(w-20)
      .close()
      ;

    fontlist = new ScrollableListPlus(cp5, "updating...");
    fontlist
      .setPosition(10, 10)
      .setSize(200, h-40)
      .setItemHeight(20)
      .setBarHeight(20)
      .setBackgroundColor(color(190))
      .setType(ControlP5.DROPDOWN)
      .setId(101)
      .setGroup(typeGroup)
      .close();
    ; 

    fontsizeBox = cp5.addNumberbox("fontsizeBox")
      .setPosition(220, 10)
      .setSize(40, 20)
      .setLabel("fontsize")
      .setRange(1, 2000)
      .setDecimalPrecision(0) 
      .setValue(100)
      .setLabelVisible(true)
      .setGroup(typeGroup)
      ;

    baselineBox = cp5.addNumberbox("baseline")
      .setPosition(270, 10)
      .setSize(40, 20)
      .setLabel("baseline")
      .setRange(-200, 200)
      .setDecimalPrecision(2) 
      .setMultiplier(0.1)
      .setValue(0)
      .setLabelVisible(true)
      .setGroup(typeGroup)
      ;  

    createTypeTileButton = cp5.addButton("CREATE TILE")
      .setLabel("CREATE TILE")
      .setPosition(w-40-60, 10)
      .setSize(60, 20)
      .setId(100)
      .setGroup(typeGroup)
      ;


    ControllerProperties prop = cp5.getProperties();
    prop.remove(typeGroup);
    prop.remove(fontlist);
    prop.remove(fontsizeBox);     
    prop.remove(baselineBox);   
    prop.remove(createTypeTileButton);

    typeEditorCreated = true;

    fontsizeBox.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED || 
          theEvent.getAction() == ControlP5.ACTION_RELEASEDOUTSIDE) {
          fontsize = (int) fontsizeBox.getValue();
          createFont();
          createLetter();
        }
      }
    }
    );
  }//end setupTypeTileEditor


  // ---------------------------------------------------------------------------
  //  DRAW
  // ---------------------------------------------------------------------------
  
  
  void draw() {
    //timeout for scroll-scale without live-preview
    if ( time != -1 ) {
      if (millis() > time+TIMEOUT) {
        time = -1;
        updateScale();
        updateRotation();
      }
    }

   // --------------------------------------------------- draw tileditor
   
    if (!typeEditorOpened) {
      background(50);
      shapeMode(CENTER);
      
      if (svg != null) {
        pushMatrix();
        
        translate(w/2, h/2);
        scale(zoom);
        strokeWeight(1f/zoom);

        //mastertilesizeBox fill
        fill(200, 20);
        noStroke();
        float tw = shapelist.get(0).width;
        float th = shapelist.get(0).height;
        rect(0, 0, tw, th);

        pushStyle();
        checkAndSetCustomStyle(svg);
        shape(svg);
        popStyle();

        //mastertilesizeBox stroke
        noFill();
        if (svgindex == 0) { stroke(0, 255, 150, 150); } 
        else { stroke(0, 150, 255, 80); }
        rect(0, 0, tw, th);
        //currenttilesizeBox
        stroke(150, 60);
        rect(0, 0, svg.width, svg.height);
        //crosshair
        stroke(150, 100);
        line( -10, 0, 10, 0 );
        line( 0, -10, 0, 10 );
        
        popMatrix();
      }
    } 
    
   // --------------------------------------------------- draw typeditor
    
    else { //typeEditorOpened
      rectMode(CENTER);
      shapeMode(CORNER);
      background(50);
      
      fill(180);
      noStroke();
      rect(w/2, h/2, w-20, h-20); //bg

      if (!fontlistLoaded) {
        fill(0);
        text("FONTLIST LOADING...PLEASE WAIT", w/2, h/2);
        if (systemfonts != null) {
          fontlistLoaded = true;
          fontlist.addItems(systemfonts);
          fontlist.setLabel("available fonts");
          fontlist.update();
          //find, set and create defaultfont
          Object o = fontlist.getItem(fontname).get("value");
          fontlist.setValue( (o!=null) ? (int)o : 0 );
        }
      } else { //fontlist loaded
        pushMatrix();

        translate(w/2, h/2);
        scale(zoom);
        translate(-w/2, -h/2);
        strokeWeight(1f/zoom);

        if (typeShape != null) {   
          pushStyle();
          checkAndSetCustomStyle(typeShape);
          translate(0, ((float)fontsize / 100f) * baseline);
          shape(typeShape, ((float)w/2f), (float)h/2);
          translate(0, -((float)fontsize / 100f) * baseline);
          popStyle();
        }
        
        //typetilesizeBox stroke
        noFill();
        stroke(150, 80);
        rect(w/2, h/2, 100, 100);
        //mastertilesizeBox stroke
        stroke(0, 150, 255, 80);
        rect(w/2, h/2, shapelist.get(0).width, shapelist.get(0).height);
      
        popMatrix();
      }
      
    }
    
   // ---------------------------------------------------
   
  }//draw


  // ---------------------------------------------------------------------------
  //  TILE ACTIONS
  // ---------------------------------------------------------------------------

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
      rotation = 0;
      tmpx = 0;
      tmpy = 0;
    }
    svg = shapelist.get(svgindex);
    setCountLabel();
    setDeleteButtonStatus();
    setMoveButtonStatus();
    setExplodeButtonStatus();
    setValueLabels();
  }

  private void updateScale() {    
    ((Tile)( shapelist.get(svgindex) )).setScaleX(scalex);
    ((Tile)( shapelist.get(svgindex) )).setScaleY(scaley);
    sLabel.setText("S:  " +nf(scalex, 1, 2));
  }

  private void updateRotation() {    
    ((Tile)( shapelist.get(svgindex) )).setRotation(rotation);
    rLabel.setText("R:  " +nf(degrees(rotation), 1, 0));
  }

  private void updateTranslate() {
    float xo = ((Tile)( shapelist.get(svgindex) )).getOffsetX();
    float yo = ((Tile)( shapelist.get(svgindex) )).getOffsetY();
    ((Tile)( shapelist.get(svgindex) )).setOffsetX( xo - offsetx);
    ((Tile)( shapelist.get(svgindex) )).setOffsetY( yo - offsety);
    pLabel.setText("P:  " +nf(xo - offsetx, 1, 0) +" X " +nf(yo - offsety, 1, 0));
  }

  private void moveTileOrder(int index, boolean direction) {
    PShape tmp = shapelist.get(svgindex);
    shapelist.remove(index);

    if (direction) { //move left
      shapelist.add(svgindex-1, tmp);
      prevTile();
    } else {        //move right
      shapelist.add(svgindex+1, tmp);
      nextTile();
    }
  }

  private void resetTile(int index) {
    ((Tile)( shapelist.get(index) )).reset();
    tmpx = 0;
    tmpy = 0;
    scalex = 1;
    scaley = 1;
    rotation = 0;
    setValueLabels();
  }

  private void deleteTile(int index) {
    shapelist.remove(index);
    svglength = shapelist.size();
    if (svgindex > svglength-1) {
      svgindex--;
    } 
    svg = shapelist.get(svgindex);
    updateLocalValuesfromTile();

    setCountLabel();
    setDeleteButtonStatus();
    setMoveButtonStatus();
    setExplodeButtonStatus();
    setValueLabels();
  }

  private void prevTile() {
    if (svglength > 1) {
      svgindex = (svgindex-1)%svglength;
      if (svgindex == -1) svgindex = svglength-1;
      setCountLabel();

      ((Tile)( svg )).setOffsetX(tmpx); //vorsichtshalber, wenn prev before dragrelease
      ((Tile)( svg )).setOffsetY(tmpy);

      svg = shapelist.get(svgindex);
      updateLocalValuesfromTile();
      setMoveButtonStatus();
      setExplodeButtonStatus();
      setValueLabels();
    }
  }

  private void nextTile() {
    if (svglength > 1) {
      svgindex = (svgindex+1)%svglength;
      setCountLabel();

      ((Tile)( svg )).setOffsetX(tmpx); //vorsichtshalber, wenn prev before dragrelease
      ((Tile)( svg )).setOffsetY(tmpy);

      svg = shapelist.get(svgindex);
      updateLocalValuesfromTile();
      setMoveButtonStatus();
      setExplodeButtonStatus();
      setValueLabels();
    }
  }

  private void updateLocalValuesfromTile() {
    tmpx = ((Tile)( svg )).getOffsetX();
    tmpy = ((Tile)( svg )).getOffsetY();
    scalex = ((Tile)( svg )).getScaleX();
    scaley = ((Tile)( svg )).getScaleY();
    rotation = ((Tile)( svg )).getRotation();
  }

  private void explodeimplode(int svgindex, boolean recursive) {
    Tile t = (Tile)shapelist.get(svgindex);
    if ( t.getOrigin() != null ) {
      implodeTile(t);
    } else {
      if (t instanceof TileSVG) {
        explodeTile(t, recursive);
      }
    }
    setExplodeButtonStatus();
    if (customStyle) {
      enableCustomStyle();
    } else {
      disableCustomStyle();
    }
  }

  private void explodeTile(Tile t, boolean recursive) {
    explodeOrigin = (Tile)t;
    getSubShapes((PShape)t, t.getWidth(), t.getHeight());
    deleteTile(shapelist.indexOf(explodeOrigin));
    explodeOrigin = null;
  }

  private void implodeTile(Tile src) {
    Tile commonOrigin = src.getOrigin();
    shapelist.add(svgindex, (PShape)commonOrigin);
    for (int i = 0; i < shapelist.size(); i++) {
      Tile t = ((Tile)shapelist.get(i));
      if (t.getOrigin() != null && t.getOrigin().equals(commonOrigin)) {
        deleteTile(i);
        i--;
      }
    }    
    svgindex = shapelist.indexOf(commonOrigin); 
    svg = shapelist.get(svgindex);
  }

  private void getSubShapes(PShape s, float w, float h) {
    PShape[] children = s.getChildren();

    for (int i = children.length-1; i >= 0; i--) {
      int t = children[i].getFamily();
      if (t == PShape.PATH || t == PShape.PRIMITIVE || t == PShape.GEOMETRY) {
        shapelist.add(svgindex, ((PShape) new TileShape(children[i], w, h, explodeOrigin)) );
      } else if (t == PConstants.GROUP) {
        if (recursive) {
          getSubShapes(children[i], w, h);
        } else {
          if (children[i].getChildCount() != 0) {
            shapelist.add(svgindex, ((PShape) new TileShape(children[i], w, h, explodeOrigin)) );
          }
        }
      }
    }
  }

  void createTypeTile() {
    if (typeShape != null) {
      TileShape ts = new TileShape(typeShape, 100, 100);
      checkAndSetCustomStyle(ts);
      //from shapeMode CORNER to CENTER
      ts.translate( 50, 50 + ((float)fontsize / 100f) * baseline );
      shapelist.add(svgindex+1, (PShape) ts );
      svglength = shapelist.size();
      nextTile();
    }
  }

  void createLetter() {
    shapeMode(CORNER); //draws letters on correct y-baseline
    typeShape = typefont.getShape(lastchar, 0);
    typeShape.beginShape();
    typeShape.fill(20);
    typeShape.translate(-typeShape.width/2, typeypos); //x-center, because of shapeMode CORNER
    //s.translate(0, ((float)fontsize / 100f) * baseline); //wäre hier besser, aber muss dann jedesmal neu created werden
    typeShape.draw(g);
    typeShape.endShape(CLOSE);
  }

  void createFont() {
    typefont = createFont(fontname, fontsize, true);
    textSize(fontsize);
    textFont(typefont);
    typeypos = ((float)fontsize/2f) -  textDescent() ;
  }

  void checkAndSetCustomStyle(PShape s) {
    if (customStyle) {
      s.disableStyle();
      if (customStroke && strokeMode) {
        stroke(strokecolor[0]);
        strokeWeight(customStrokeWeight);
      } else if (customStroke && !strokeMode) {          
        stroke(strokecolor[0]);
        float sw = 1f;
        try {
          sw = ((Tile)s).getScaleX();    //typeTiles don't cast to Tile before 
        } catch(ClassCastException e) {} //they are actually *created* (as Tile)
        if (sw != 0f) {
          sw = abs(customStrokeWeight*(1/sw));
        }
        strokeWeight(sw);
      } else {
        noStroke();
      }
      if (customFill) {
        fill(shapecolor[0]);
      } else {
        noFill();
      }
    } else {
      s.enableStyle();
    }
  }

  // ---------------------------------------------------------------------------
  //  GUI EVENTHANDLING
  // ---------------------------------------------------------------------------


  public void controlEvent(ControlEvent theEvent) {

    if (theEvent.isController() && theEvent.getController() instanceof ScrollableListPlus) {
      ScrollableListPlus slp = (ScrollableListPlus)theEvent.getController();
      slp.updateHighlight(slp.getItem((int)slp.getValue()));
    }

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
      case(9): //EXPLODE/IMPLODE
      explodeimplode(svgindex, recursive);
      break;
      case(11): //TYPETILEDITOR
      if (!typeEditorOpened) {
        openTypeTileEditor();
      } else {
        closeTypeTileEditor();
      }
      break;
      case(100): //CREATETYPETILE
      createTypeTile();
      break;
      case(101): //FONTLIST
      fontname = (String)fontlist.getItem((int)fontlist.getValue()).get("text"); 
      createFont();
      createLetter();
      break;
    }
  }

  //CallbackListener for sizeBox above in setupTypeTileEditor()
  //if(theEvent.getAction() == ControlP5.ACTION_RELEASED || 
  //   theEvent.getAction() == ControlP5.ACTION_RELEASEDOUTSIDE) {
  //    fontsize = (int) fontsizeBox.getValue();
  //    createFont();
  //    createLetter();
  //}



  // ---------------------------------------------------------------------------
  //  GUI ACTIONS
  // ---------------------------------------------------------------------------

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

  private void openTypeTileEditor() {
    if (!typeEditorCreated) {
      parent.thread("loadSystemFonts");
      setupTypeTileEditor();
    }
    typeGroup.open();
    mainGroup.close();
    addTextButton.bringToFront();
    addTextButton.setWidth(70);
    addTextButton.setLabel("CLOSE");
    cp5.update();
    typeEditorOpened = true;
    if (fontlistLoaded) {
      createFont();
      createLetter();
    }
  }

  private void closeTypeTileEditor() {
    setDeleteButtonStatus();
    setMoveButtonStatus();
    setCountLabel();
    mainGroup.open();
    typeGroup.close();
    addTextButton.bringToFront();
    addTextButton.setWidth(30);
    addTextButton.setLabel("+T");
    typeEditorOpened = false;
    cp5.update();
  }

  private void closeAndApply() {
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
    if (svglength <= 1) {
      deleteTileButton.setBroadcast(false).setColorLabel(lockColor).setColorActive(bg).setColorForeground(bg);
    } else {
      deleteTileButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
    }
  }

  private void setMoveButtonStatus() {
    if (svglength == 1) {
      moveTileForeButton.setBroadcast(false).setColorLabel(lockColor).setColorActive(bg).setColorForeground(bg);
      moveTileBackButton.setBroadcast(false).setColorLabel(lockColor).setColorActive(bg).setColorForeground(bg);
    } else {
      if (svgindex == 0) {
        moveTileForeButton.setBroadcast(false).setColorLabel(lockColor).setColorActive(bg).setColorForeground(bg);
        moveTileBackButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
      } else if (svgindex == svglength-1) {
        moveTileBackButton.setBroadcast(false).setColorLabel(lockColor).setColorActive(bg).setColorForeground(bg);
        moveTileForeButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
      } else {
        moveTileForeButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
        moveTileBackButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
      }
    }
  }

  private void setExplodeButtonStatus() {
    Tile t = (Tile)shapelist.get(svgindex);
    if ( t.getOrigin() != null ) {
      explodeTileButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
      explodeTileButton.setLabel("IMPLODE");
      explodeTileButton.setHeight(30);
      recursiveToggle.hide();
    } else if (t instanceof TileSVG) {
      explodeTileButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
      explodeTileButton.setLabel("EXPLODE");
      explodeTileButton.setHeight(18);
      recursiveToggle.show();
    } else {
      explodeTileButton.setLabel("EXPLODE");
      explodeTileButton.setHeight(30);
      explodeTileButton.setBroadcast(false).setColorLabel(lockColor).setColorActive(bg).setColorForeground(bg);
      recursiveToggle.hide();
    }
  }

  private void setValueLabels() {
    pLabel.setText("P:  " +nf(((Tile)( shapelist.get(svgindex) )).getOffsetX(), 1, 0) +" X " +nf(((Tile)( shapelist.get(svgindex) )).getOffsetY(), 1, 0));
    rLabel.setText("R:  " +nf(degrees(rotation), 1, 0));
    sLabel.setText("S:  " +nf(scalex, 1, 2));
  }


  // ---------------------------------------------------------------------------
  //  INPUT EVENTS
  // ---------------------------------------------------------------------------

  void mousePressed() {
  }

  void mouseDragged ( ) {
    if (!typeEditorOpened) {
      drag = true;
      offsetx = ((pmouseX - mouseX)/zoom);
      offsety = ((pmouseY - mouseY)/zoom);

      tmpx -= offsetx;
      tmpy -= offsety;

      updateTranslate();
    }
  }  

  void mouseReleased() {
    if (drag || reset) {
      drag = false;
      reset = false;
    }
  }

  void mouseWheel(MouseEvent event) {
    float e = event.getAmount();
    if (!typeEditorOpened) {
      if (keysDown[ALT]) {
        rotation -= e*0.0174533;
        updateRotation();
      } else {
        scalex -= e*0.01;
        scaley -= e*0.01;
        updateScale();
      }
    }
  }

  void keyPressed() {
    if (key == CODED) {
      if (keyCode == LEFT) {
        prevTile();
      } else if (keyCode == RIGHT) {
        nextTile();
      } else { //forward to pettermain
        if (!typeEditorOpened) {
          parent.key=key;
          parent.keyCode=keyCode;
          parent.keyPressed();
        }
      }
    } else {
      if (!typeEditorOpened) {
        if (key == RETURN || key == ENTER) {
          closeAndApply();
        } else if (key == ESC || keyCode==ESC) {
          key=0;
          keyCode=0;
          closeAndApply();
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
      } else {
        if (key == ESC || keyCode==ESC) {
          key=0;
          keyCode=0;
          closeTypeTileEditor();
          return;
        } else if (keyCode == 93 || keyCode == 107) { //PLUS
          this.scaleGUI(true);
        } else if (keyCode == 47 || keyCode == 109) { //MINUS
          this.scaleGUI(false);
        }
        if (fontlistLoaded) {
          if (key == RETURN || key == ENTER) {
            createTypeTile();
          } else {
            lastchar = key;
            createLetter();
          }
        }
      }
    }
  }

  void keyReleased() {
    processKey(keyCode, false); //debounce parent
  }
}