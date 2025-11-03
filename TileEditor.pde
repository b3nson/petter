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

import drop.*;

class TileEditor extends PApplet {

  PApplet parent;

  private ControlP5 cp5;
  SDrop drop;
  DropTargetSVG dropSVGadd, dropSVGrep, dropSVGnfo;

  PFont typefont;
  PGraphics clonetile;

  PShape svg;
  TileShape ts;
  Tile explodeOrigin;

  boolean opened = true;
  boolean drag = false;
  boolean reset = false;
  boolean recursive = false;
  boolean typeEditorOpened = false;
  boolean typeEditorCreated = false;
  boolean fontlistLoaded = false;
  boolean showFPS = false;
  boolean clipboard = false;

  int w, h;
  int svgindex = -1;
  int svglength = 0;
  int time = -1;
  int TIMEOUT = 300;
  int fontsize = 100;
  int lockColor = 130;
  int unlockColor = 255;
  int prevTypeColor = -1;

  float dragoffsetx, dragoffsety, offsetx, offsety;
  float scalex = 1f;
  float scaley = 1f;
  float rotation = 0f;
  float zoom = 1f;
  float baseline = 0f;
  float typeypos = 0f;

  float clipboard_x, clipboard_y;
  float clipboard_sx, clipboard_sy;
  float clipboard_r;

  String fontname = "Monospaced";
  String renderer = "";
  char lastchar = 'P';

  ArrayList<PShape> tileeditorshapelist;

  Group mainGroup, mainTileGroup, mainSortGroup, mainAddGroup, mainInfoGroup, typeGroup;
  Button closeButton, nextTileButton, prevTileButton, resetTileButton;
  Button deleteTileButton, moveTileBackButton, moveTileForeButton, explodeTileButton;
  Bang typecolorBang;
  Button addTextButton, duplicateTileButton;
  Toggle recursiveToggle, disableGlobalStyleToggle;
  Textfield tileCountLabel;
  Textlabel tezoomLabel, sLabel, rLabel, pLabel, fpsLabel;

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
    surface.setIcon(pettericon);
    //surface.setLocation(10, 10);
    
    shapeMode(CENTER);
    rectMode(CENTER);
    textMode(SHAPE);
    textAlign(CENTER, BASELINE);

    cp5 = new ControlP5(this, font);
    cp5.setAutoDraw(false);

    drop = new SDrop(this);
    dropSVGadd = new DropTargetSVG(this, cp5, ADDSVG);
    dropSVGrep = new DropTargetSVG(this, cp5, REPLACESVG);
    dropSVGnfo = new DropTargetSVG(this, cp5, NFOSVG);
    drop.addDropListener(dropSVGadd);
    drop.addDropListener(dropSVGrep);
    drop.addDropListener(dropSVGnfo);
    dropSVGadd.updateTargetRect(w, h);
    dropSVGrep.updateTargetRect(w, h);
    dropSVGnfo.updateTargetRect(w, h);

    mainGroup = cp5.addGroup("mainGroup")
      .setPosition(0, 0)
      .hideBar()
      .setBackgroundHeight(h)
      .setWidth(w)
      .setOpen(true)
      ;

    // ---------------------------------------------------

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

    // ---------------------------------------------------

    fpsLabel = cp5.addTextlabel("fps" )
      .setSize(100, 30)
      .setPosition(10, 40)
      .setText("fps")
      .setVisible(false)
      .setGroup(mainGroup)
      ;

    closeButton = cp5.addButton("CLOSE")
      .setPosition(w-70-10, this.h-52)
      .setSize(70, 26)
      .setId(2)
      .setGroup(mainGroup);
    ;

    // ---------------------------------------------------

    mainTileGroup = cp5.addGroup("mainTileGroup")
      .setLabel("TILE")
      .setPosition(100, this.h-56)
      .setWidth(259)
      .hideArrow()
      .disableCollapse()
      .setOpen(true)
      .setBackgroundHeight(34)
      //.setBackgroundColor(color(50))
      .setColorBackground(color(60))
      .setColorForeground(color(60))
      .setGroup(mainGroup)
      ;

    deleteTileButton = cp5.addButton("DELETE")
      .setLabel("DELETE")
      .setPosition(0, 4)
      .setSize(44, 26)
      .setId(6)
      .setGroup(mainTileGroup)
      ;

    resetTileButton = cp5.addButton("RESET")
      .setLabel("RESET")
      .setPosition(49, 4)
      .setSize(38, 26)
      .setId(5)
      .setGroup(mainTileGroup)
      ;

    duplicateTileButton = cp5.addButton("DUPLICATE")
      .setLabel("DUPLICATE")
      .setPosition(91, 4)
      .setSize(54, 26)
      .setId(12)
      .setGroup(mainTileGroup)
      ;

    explodeTileButton = cp5.addButton("EXPLODE")
      .setLabel("EXPLODE")
      .setPosition(149, 4)
      .setSize(50, 16)
      .setId(9)
      .setGroup(mainTileGroup)
      ;

    recursiveToggle = cp5.addToggle("recursive")
      .setLabel("RECURSIVE")
      .setPosition(149, 22)
      .setSize(50, 8)
      .setValue(recursive)
      .setId(10)
      .setGroup(mainTileGroup)
      ;
    controlP5.Label lr = recursiveToggle.getCaptionLabel();
    lr.setHeight(10);
    lr.getStyle().setPadding(2, 2, 2, 2);
    lr.getStyle().setMargin(-15, 0, 0, 3);

    disableGlobalStyleToggle = cp5.addToggle("DISABLEGLOBALSTYLE")
      .setLabel("   DISABLE \nGLOBALSTYLE")
      .setPosition(203, 4)
      .setSize(56, 26)
      .setId(13)
      .setGroup(mainTileGroup)
      ;
    controlP5.Label lg = disableGlobalStyleToggle.getCaptionLabel();
    lg.setHeight(10);
    lg.getStyle().setPadding(2, 2, 2, 2);
    lg.getStyle().setMargin(-28, 0, 0, 1);

    // ---------------------------------------------------

    mainSortGroup = cp5.addGroup("mainSortGroup")
      .setLabel("SORT")
      .setPosition(10, this.h-56)
      .setWidth(64)
      .hideArrow()
      .disableCollapse()
      .setOpen(true)
      .setBackgroundHeight(34)
      //.setBackgroundColor(color(50))
      .setColorBackground(color(60))
      .setColorForeground(color(60))
      .setGroup(mainGroup)
      ;

    moveTileForeButton = cp5.addButton("<")
      .setLabel("<")
      .setPosition(0, 4)
      .setSize(30, 26)
      .setId(7)
      .setGroup(mainSortGroup)
      ;

    moveTileBackButton = cp5.addButton(">")
      .setLabel(">")
      .setPosition(34, 4)
      .setSize(30, 26)
      .setId(8)
      .setGroup(mainSortGroup);
    ;

    // ---------------------------------------------------

    mainAddGroup = cp5.addGroup("mainAddGroup")
      .setLabel("ADD")
      .setPosition(375, this.h-56)
      .setWidth(30)
      .hideArrow()
      .disableCollapse()
      .setOpen(true)
      .setBackgroundHeight(34)
      //.setBackgroundColor(color(50))
      .setColorBackground(color(60))
      .setColorForeground(color(60))
      .setGroup(mainGroup)
      ;

    addTextButton = cp5.addButton("+T")
      .setPosition(0, 4)
      .setSize(30, 26)
      .setId(11)
      .setGroup(mainAddGroup);
    ;

    // ---------------------------------------------------

    mainInfoGroup = cp5.addGroup("mainInfoGroup")
      .setLabel("INFO")
      .setPosition(0, this.h-22)
      .setSize(this.w, 22)
      .hideBar()
      .setOpen(true)
      .setBackgroundHeight(24)
      .setBackgroundColor(color(45))
      .setGroup(mainGroup)
      ;

    tezoomLabel = cp5.addTextlabel("tezoomlabel" )
      .setPosition(this.w-60, 7)
      .setText("ZOOM:  1.0")
      .setGroup(mainInfoGroup);
    ;

    sLabel = cp5.addTextlabel("sLabel" )
      .setPosition(10, 7)
      .setText("S:  1.0")
      .setGroup(mainInfoGroup)
      ;

    rLabel = cp5.addTextlabel("rLabel" )
      .setPosition(55, 7)
      .setText("R:  0.0")
      .setGroup(mainInfoGroup)
      ;

    pLabel = cp5.addTextlabel("pLabel" )
      .setPosition(95, 7)
      .setText("P:  0.0 x 0.0")
      .setGroup(mainInfoGroup)
      ;

    // ---------------------------------------------------

    ControllerProperties prop = cp5.getProperties();
    prop.remove(mainGroup);
    prop.remove(mainTileGroup);
    prop.remove(mainSortGroup);
    prop.remove(mainAddGroup);
    prop.remove(mainInfoGroup);
    prop.remove(closeButton);
    prop.remove(addTextButton);
    prop.remove(recursiveToggle);
    prop.remove(prevTileButton);
    prop.remove(nextTileButton);
    prop.remove(resetTileButton);
    prop.remove(deleteTileButton);
    prop.remove(explodeTileButton);
    prop.remove(duplicateTileButton);
    prop.remove(disableGlobalStyleToggle);
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
      .setSize(176, h-40)
      .setItemHeight(20)
      .setBarHeight(20)
      .setBackgroundColor(color(190))
      .setType(ControlP5.DROPDOWN)
      .setId(101)
      .setGroup(typeGroup)
      .close();
    ;

    fontsizeBox = cp5.addNumberbox("fontsizeBox")
      .setPosition(196, 10)
      .setSize(40, 20)
      .setLabel("fontsize")
      .setRange(1, 2000)
      .setDecimalPrecision(0)
      .setValue(100)
      .setLabelVisible(true)
      .setGroup(typeGroup)
      ;

    baselineBox = cp5.addNumberbox("baseline")
      .setPosition(246, 10)
      .setSize(40, 20)
      .setLabel("baseline")
      .setRange(-200, 200)
      .setDecimalPrecision(2)
      .setMultiplier(0.1)
      .setValue(0)
      .setLabelVisible(true)
      .setGroup(typeGroup)
      ;

    typecolorBang = cp5.addBang("changetypecolor")
      .setLabel("C")
      .setPosition(296, 10)
      .setSize(20, 20)
      .setGroup(typeGroup)
      ;
    typecolorBang.getCaptionLabel().setPadding(8, -14);
    typecolorBang.setColorForeground(typecolor[0]);

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
    prop.remove(typecolorBang);

    typeEditorCreated = true;

    fontsizeBox.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        fontsizeBoxCallback(theEvent);
      }
    }
    );

    fontlist.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        fontlistHoverCallback(theEvent);
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
        pushStyle();

        translate(w/2, h/2);
        scale(zoom);
        strokeWeight(1f/zoom);

        //mastertilesizeBox fill
        fill(200, 20);
        noStroke();
        float tw = tileeditorshapelist.get(0).width;
        float th = tileeditorshapelist.get(0).height;
        rect(0, 0, tw, th);
        popStyle();

        shape(svg);

        pushStyle();
        //mastertilesizeBox stroke
        noFill();
        if (svgindex == 0) {
          stroke(0, 255, 150, 150);
        } else {
          stroke(0, 150, 255, 80);
        }
        strokeWeight(1f/zoom);
        rect(0, 0, tw, th);
        //currenttilesizeBox
        stroke(150, 60);
        rect(0, 0, svg.width, svg.height);
        //crosshair
        stroke(150, 100);
        line( -10, 0, 10, 0 );
        line( 0, -10, 0, 10 );

        popStyle();
        popMatrix();
      }
    }

    // --------------------------------------------------- draw typeditor

    else { //typeEditorOpened
      pushStyle();
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
        popStyle();

        if (ts != null) {
          pushMatrix();
          translate(0, ((float)fontsize / 100f) * baseline);
          shape(ts, ((float)w/2f)-50, ((float)h/2)-50) ;
          popMatrix();
        }

        pushStyle();
        //typetilesizeBox stroke
        strokeWeight(1f/zoom);
        noFill();
        stroke(150, 80);
        rect(w/2, h/2, 100, 100);
        //mastertilesizeBox stroke
        stroke(0, 150, 255, 80);
        rect(w/2, h/2, tileeditorshapelist.get(0).width, tileeditorshapelist.get(0).height);
        popStyle();
        popMatrix();
      }

      if (type_copi != null && type_copi.isOpen()) {
        if (typecolor[0] != prevTypeColor) {
          typecolorBang.setColorForeground(typecolor[0]);
          createLetter();
          prevTypeColor = typecolor[0];
        }
      }
    }

    // ---------------------------------------------------

    if (!(dropSVGadd.over || dropSVGrep.over || dropSVGnfo.over)) {
      if (showFPS) {
        fpsLabel.setText(this.renderer +" @ " +str((int)this.frameRate));
      }
      cp5.draw();
    } else {
      pushStyle();
      noStroke();
      dropSVGadd.draw(g);
      dropSVGrep.draw(g);
      dropSVGnfo.draw(g);
      popStyle();
    }
  }//draw


  // ---------------------------------------------------------------------------
  //  TILE ACTIONS
  // ---------------------------------------------------------------------------

  public void setTileList(ArrayList<PShape> slist) {
    tileeditorshapelist = slist;
    svgindex = 0;
    svglength = slist.size();
    svg = tileeditorshapelist.get(svgindex);
    //setCountLabel();
  }

  public void updateTileList(ArrayList<PShape> slist, int mode) {
    tileeditorshapelist = slist;
    svglength = tileeditorshapelist.size();
    if (mode == REPLACESVG) {
      svgindex = 0;
      dragoffsetx = 0;
      dragoffsety = 0;
      scalex = 1;
      scaley = 1;
      rotation = 0;
      offsetx = 0;
      offsety = 0;
    }
    svg = tileeditorshapelist.get(svgindex);
    setCountLabel();
    setDeleteButtonStatus();
    setMoveButtonStatus();
    setExplodeButtonStatus();
    setGlobalStyleButtonStatus();
    setValueLabels();
  }

  private void prevTile() {
    showTile((svgindex-1)%svglength);
  }

  private void nextTile() {
    showTile((svgindex+1)%svglength);
  }

  private void lastTile() {
    showTile(svglength-1);
  }

  private void showTile(int index) {
    if (svglength > 1) {
      svgindex = index;
      if (svgindex == -1) svgindex = svglength-1;
      setCountLabel();

      ((Tile)( svg )).setOffsetX(offsetx); //vorsichtshalber, wenn prev before dragrelease
      ((Tile)( svg )).setOffsetY(offsety);

      svg = tileeditorshapelist.get(svgindex);
      updateLocalValuesfromTile();
      setMoveButtonStatus();
      setExplodeButtonStatus();
      setDeleteButtonStatus();
      setGlobalStyleButtonStatus();
      setValueLabels();
    }
  }

  private void moveTileOrder(int index, boolean direction) {
    PShape tmp = tileeditorshapelist.get(svgindex);
    tileeditorshapelist.remove(index);

    if (direction) { //move left
      tileeditorshapelist.add(svgindex-1, tmp);
      prevTile();
    } else {        //move right
      tileeditorshapelist.add(svgindex+1, tmp);
      nextTile();
    }
  }

  private void resetTile(int index) {
    ((Tile)( tileeditorshapelist.get(index) )).resetTransform();
    offsetx = 0;
    offsety = 0;
    scalex = 1;
    scaley = 1;
    rotation = 0;
    setValueLabels();
  }

  private void deleteTile(int index) {
    if (svglength > 0) {
      tileeditorshapelist.remove(index);
      svglength = tileeditorshapelist.size();
      if (svgindex > svglength-1) {
        svgindex--;
      }
      svg = tileeditorshapelist.get(svgindex);
      updateLocalValuesfromTile();

      setCountLabel();
      setDeleteButtonStatus();
      setGlobalStyleButtonStatus();
      setMoveButtonStatus();
      setExplodeButtonStatus();
      setValueLabels();
    }
  }

  private void duplicateTile(int index) {
    Tile tmp = cloneTile( tileeditorshapelist.get(svgindex) );
    tileeditorshapelist.add(index+1, (PShape)tmp);
    svglength = tileeditorshapelist.size();
    nextTile();
  }

  private void setTileAsNFO() {
    Tile tmp = cloneTile( tileeditorshapelist.get(svgindex) );
    tmp.useGlobalStyle(false);
    nfo = (PShape)tmp;
  }

  private void toggleGlobalStyle(int svgindex) {
    ((Tile)tileeditorshapelist.get(svgindex)).toggleUseGlobalStyle();
  }

  private void explodeimplode(int svgindex, boolean recursive) {
    Tile t = (Tile)tileeditorshapelist.get(svgindex);
    if ( t.getOrigin() != null ) {
      implodeTile(t);
    } else {
      explodeTile(t, recursive);
    }
    svglength = tileeditorshapelist.size();
    setCountLabel();
    updateLocalValuesfromTile();
    setMoveButtonStatus();
    setExplodeButtonStatus();
    setDeleteButtonStatus();
    setGlobalStyleButtonStatus();
    setValueLabels();
  }

  private void copyTransforms() {
    clipboard_r = rotation;
    clipboard_sx = scalex;
    clipboard_sy = scaley;
    clipboard_x = offsetx;
    clipboard_y = offsety;
    clipboard = true;
  }
  
  private void pasteTransforms() {
    if(clipboard) { //copied anything?
      rotation = clipboard_r;
      scalex = clipboard_sx;
      scaley = clipboard_sy;
      offsetx = clipboard_x;
      offsety = clipboard_y;
      updateRotation();
      updateScale();
      updateTranslate();     
    }
  }

  private void updateScale() {
    ((Tile)( tileeditorshapelist.get(svgindex) )).setScaleX(scalex);
    ((Tile)( tileeditorshapelist.get(svgindex) )).setScaleY(scaley);
    sLabel.setText("S:  " +nf(scalex, 1, 2));
  }

  private void updateRotation() {
    ((Tile)( tileeditorshapelist.get(svgindex) )).setRotation(rotation);
    rLabel.setText("R:  " +nf(degrees(rotation), 1, 0));
  }

  private void updateTranslate() {
    ((Tile)( tileeditorshapelist.get(svgindex) )).setOffsetX(offsetx);
    ((Tile)( tileeditorshapelist.get(svgindex) )).setOffsetY(offsety);
    pLabel.setText("P:  " +nf(offsetx, 1, 0) +" X " +nf(offsety, 1, 0));
  }

  private void updateLocalValuesfromTile() {
    offsetx = ((Tile)( svg )).getOffsetX();
    offsety = ((Tile)( svg )).getOffsetY();
    scalex = ((Tile)( svg )).getScaleX();
    scaley = ((Tile)( svg )).getScaleY();
    rotation = ((Tile)( svg )).getRotation();
  }

  public void updateGlobalStyle() {
    if (ts != null) {
      if (globalStyle) {
        ts.enableGlobalStyle();
      } else {
        ts.disableGlobalStyle();
      }
    }
  }

  void createFont() {
    typefont = createFont(fontname, fontsize, true);
    textSize(fontsize);
    textFont(typefont);
    typeypos = ((float)fontsize/2f) -  textDescent() ;
  }

  void createLetter() {
    PShape typeShape;
    shapeMode(CORNER); //draws letters on correct y-baseline
    typeShape = typefont.getShape(lastchar, 0f);
    typeShape.beginShape();
    typeShape.fill(typecolor[0]);
    typeShape.translate(-typeShape.width/2, typeypos); //x-center, because of shapeMode CORNER
    //typeShape.draw(g); //no need to draw here
    typeShape.endShape(CLOSE);

    ts = new TileShape(typeShape, 100, 100);
    ts.translate(50, 50);
    ts.setExplodable(false);
  }

  void createTypeTile() {
    if (ts != null) {
      ts.translate(0, ((float)fontsize / 100f) * baseline);
      tileeditorshapelist.add(svgindex+1, (PShape) ts );
      svglength = tileeditorshapelist.size();
      createLetter();
      nextTile();
    }
  }


  // ---------------------------------------------------------------------------
  //  TILE ACTIONS UTIL
  // ---------------------------------------------------------------------------

  //Cloning via SVG-serialization as long as PShape-copying remains protected in PShape.java
  //https://github.com/processing/processing/blob/db659cf0fff5d76d535082297d8c0dec6b52386d/core/src/processing/core/PShape.java#L1437
  private Tile cloneTile(PShape toClone) {
    String filename = sketchPath +"/" +tmppath +toClone.hashCode() +".svg" ;
    clonetile = (PGraphicsSVG) createGraphics((int)toClone.getWidth(), (int)toClone.getHeight(), SVG, filename);

    float[] p = ((Tile)toClone).getTransformParams();
    ((Tile)toClone).resetTransform();

    beginRecord(clonetile);
    shape(toClone);
    endRecord();

    ((Tile)toClone).setTransformParams(p);
    Tile newTile = new TileSVG(filename);
    newTile.setTransformParams(p);
    newTile.setExplodable(((Tile)toClone).isExplodable());

    return newTile;
  }

  private void explodeTile(Tile t, boolean recursive) {
    explodeOrigin = (Tile)t;
    getSubShapes((PShape)t, t.getWidth(), t.getHeight(), recursive);
    deleteTile(tileeditorshapelist.indexOf(explodeOrigin));
    explodeOrigin = null;
  }

  private void implodeTile(Tile src) {
    Tile commonOrigin = src.getOrigin();
    tileeditorshapelist.add(svgindex, (PShape)commonOrigin);
    for (int i = 0; i < tileeditorshapelist.size(); i++) {
      Tile t = ((Tile)tileeditorshapelist.get(i));
      if (t.getOrigin() != null && t.getOrigin().equals(commonOrigin)) {
        deleteTile(i);
        i--;
      }
    }
    svgindex = tileeditorshapelist.indexOf(commonOrigin);
    svg = tileeditorshapelist.get(svgindex);
  }

  private void getSubShapes(PShape s, float w, float h, boolean recursive) {
    PShape[] children = s.getChildren();
    for (int i = children.length-1; i >= 0; i--) {
      int t = children[i].getFamily();
      if (t == PShape.PATH || t == PShape.PRIMITIVE || t == PShape.GEOMETRY) {
        tileeditorshapelist.add(svgindex, ((PShape) new TileShape(children[i], w, h, explodeOrigin)) );
      } else if (t == PConstants.GROUP) {
        if (recursive) {
          getSubShapes(children[i], w, h, recursive);
        } else {
          if (children[i].getChildCount() != 0) {
            tileeditorshapelist.add(svgindex, ((PShape) new TileShape(children[i], w, h, explodeOrigin)) );
          }
        }
      }
      svglength = tileeditorshapelist.size();
    }
  }

  public PGraphics getG() {
    return this.g;
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
      case(12): //DUPLICATE
      duplicateTile(svgindex);
      break;
      case(13): //DISABLEGLOBALSTYLE
      toggleGlobalStyle(svgindex);
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

  void fontsizeBoxCallback(CallbackEvent theEvent) {
    if (theEvent.getAction() == ControlP5.ACTION_RELEASE ||
      theEvent.getAction() == ControlP5.ACTION_RELEASE_OUTSIDE) {
      fontsize = (int) fontsizeBox.getValue();
      createFont();
      createLetter();
    }
  }

  String hoverfontname = "";
  String orgfontname = "";

  void fontlistHoverCallback(CallbackEvent theEvent) {
    if (systemfonts != null) {
      if (theEvent.getAction() == ControlP5.ACTION_MOVE) {
        int i = fontlist.getItemHover();
        if (i == -1 || i >= systemfonts.length) {
          hoverfontname = orgfontname;
        } else {
          hoverfontname = (String)fontlist.getItem(i).get("text");
        }
        if ( !hoverfontname.equals(fontname) ) {
          fontname = hoverfontname;
          createFont();
          createLetter();
        }
      } else if (theEvent.getAction() == ControlP5.ACTION_ENTER) {
        orgfontname = fontname;
        hoverfontname = " ";
      } else if (theEvent.getAction() == ControlP5.ACTION_LEAVE) {
        fontname = (String)fontlist.getItem((int)fontlist.getValue()).get("text");
        createFont();
        createLetter();
      }
    }
  }


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
    frameRate(30);
    opened = true;
    surface.setVisible(true);
    keysDown[lastKey] = false; //reset missing keyRelease

    setDeleteButtonStatus();
    setMoveButtonStatus();
    setCountLabel();
  }

  public void exit() { //on native window-close
    hide();
  }

  public void showHelp(boolean show) {
    if (show) this.renderer = getRenderer(this);
    showFPS = show;
    fpsLabel.setVisible(show);
  }

  private void openTypeTileEditor() {
    if (!typeEditorCreated) {
      parent.thread("loadSystemFonts");
      setupTypeTileEditor();
    }
    addTextButton.moveTo(typeGroup).setPosition(w-20-10-70, this.h-20-10-26)
      .setSize(70, 26).bringToFront().setLabel("CLOSE");
    typeGroup.setOpen(true);
    mainGroup.close();
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
    addTextButton.moveTo(mainAddGroup).setPosition(0, 4)
      .setSize(30, 26).bringToFront().setLabel("+T");
    mainGroup.setOpen(true);
    typeGroup.close();
    typeEditorOpened = false;
  }

  private void closeAndApply() {
    hide();
  }

  void changetypecolor() {
    if (type_copi == null) {
      type_copi = new ColorPicker(this, "typecolor", typecolor, recentcolors);
      type_copi.setUndoable(false);
      String[] args = {"colorpicker4"};
      PApplet.runSketch(args, type_copi);
    } else {
      type_copi.show();
    }
    colorpicking = true;
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
    tileCountLabel.setText("    " +(svgindex+1) +" / " +tileeditorshapelist.size());
  }

  private void setDeleteButtonStatus() {
    if (svglength <= 1) {
      deleteTileButton.setBroadcast(false).setColorLabel(lockColor).setColorActive(bg).setColorForeground(bg);
    } else {
      deleteTileButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
    }
  }

  private void setGlobalStyleButtonStatus() {
    Tile t = (Tile)tileeditorshapelist.get(svgindex);
    if (t.getUseGlobalStyle()) {
      //set the value of the controller without sending the broadcast event
      disableGlobalStyleToggle.changeValue(0f);
    } else {
      //set the value of the controller without sending the broadcast event
      disableGlobalStyleToggle.changeValue(1f);
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
    Tile t = (Tile)tileeditorshapelist.get(svgindex);
    if (t.isExplodable()) {
      if ( t.getOrigin() != null ) {
        explodeTileButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
        explodeTileButton.setLabel("IMPLODE");
        explodeTileButton.setHeight(26);
        recursiveToggle.hide();
      } else { /*if (t instanceof TileSVG) {*/
        explodeTileButton.setBroadcast(true).setColorLabel(unlockColor).setColorActive(c1).setColorForeground(color(30));
        explodeTileButton.setLabel("EXPLODE");
        explodeTileButton.setHeight(16);
        recursiveToggle.show();
      }
    } else {
      explodeTileButton.setLabel("EXPLODE");
      explodeTileButton.setHeight(26);
      explodeTileButton.setBroadcast(false).setColorLabel(lockColor).setColorActive(bg).setColorForeground(bg);
      recursiveToggle.hide();
    }
  }

  private void setValueLabels() {
    pLabel.setText("P:  " +nf(((Tile)( tileeditorshapelist.get(svgindex) )).getOffsetX(), 1, 0) +" X " +nf(((Tile)( tileeditorshapelist.get(svgindex) )).getOffsetY(), 1, 0));
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
      dragoffsetx = ((pmouseX - mouseX)/zoom);
      dragoffsety = ((pmouseY - mouseY)/zoom);

      offsetx -= dragoffsetx;
      offsety -= dragoffsety;

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
    float e = event.getCount();
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

  void mouseExited() {
    dropSVGadd.over = false;
    dropSVGrep.over = false;
    dropSVGnfo.over = false;
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
        } else if (key == 'n') {
          setTileAsNFO();
          if (!showNfo) {
            showNfo = true;
            showNfoToggle.setState(showNfo);
          } 
        } else if (key == 'c') {
          copyTransforms();
        } else if (key == 'v') {
          pasteTransforms();
        } else if (keyCode == 93 || keyCode == 107) { //PLUS
          this.scaleGUI(true);
        } else if (keyCode == 47 || keyCode == 109) { //MINUS
          this.scaleGUI(false);
        } else if (key == BACKSPACE || key == DELETE) { //DELETE
          deleteTile(svgindex);
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
