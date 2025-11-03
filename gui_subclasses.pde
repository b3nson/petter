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


// ---------------------------------------------------------------------------
//  DROPTARGETSVG - ADD/REPLACE/NFO
// ---------------------------------------------------------------------------

static int ADDSVG = 0;
static int REPLACESVG = 1;
static int NFOSVG = 2;

class DropTargetSVG extends DropListener {

  PApplet app;
  ControlP5 cp5;
  
  boolean over = false;
  int mode = -1;
  int margin = 20;
  int cw, ch;
  int x, y, w, h;
  int col;
  int colTile = color(16, 181, 198, 150);
  int colNfo  = color(60, 105, 97, 180);
  Textlabel label;

  DropTargetSVG(PApplet app, ControlP5 cp5, int mode) {
    this.app = app;
    this.cp5 = cp5;
    this.mode = mode;
    setTargetRect(viewwidth, viewheight, mode);
  }

  void draw(PGraphics g) {
    if (over) {
      g.fill(col);
      g.rectMode(CORNER);
      g.rect(x, y, w, h);
      label.draw(g);
    }
  }

  void updateTargetRect(int newwidth, int newheight) {
    setTargetRect(newwidth, newheight, mode);
  }

  private void setTargetRect(int ww, int hh, int mode) {
    cw = ww;
    ch = hh;
    if (mode == ADDSVG) {
      x = margin;
      y = margin;
      w = cw-(2*margin);
      h = ((ch-(margin*2))/7)*3;
      label = new Textlabel(cp5, "ADD", cw/2-5, h/2, 400, 200);
      col = colTile;
    } else if (mode == REPLACESVG) {
      x = margin;
      w = cw-(2*margin);
      h = ((ch-(margin*2))/7)*3;
      y = h+margin;
      label = new Textlabel(cp5, "REPLACEALL", cw/2-20, (h/2)+h, 400, 200);
      col = colTile;
    } else if (mode == NFOSVG) {
      x = margin;
      h = (ch-(margin*2))/7;
      y = ch-h-margin;
      w = cw-(2*margin);
      label = new Textlabel(cp5, "NFO", cw/2-20, (h/2)+y-10, 400, 200);
      col = colNfo;
    } 
    setTargetRect(x, y, w, h);
  }

  void dropEnter() {
    over = true;
  }

  void dropLeave() {
    over = false;
  }

  void dropEvent(DropEvent theDropEvent) {
    ArrayList<PShape> tmpsvg = new ArrayList<PShape>();
    ArrayList<String> tmppath = new ArrayList<String>();
    String path = theDropEvent.toString();

    if (path.toLowerCase().endsWith(".svg")) {
      PShape sh = new TileSVG(path);

      if (mode  == ADDSVG || mode  == REPLACESVG) {
        tmpsvg.add(sh);
        tmppath.add(path);
      }

      if (mode  == ADDSVG) {
        svg.addAll(tmpsvg);
        svgpath.addAll(tmppath);
        print("ADDSVG: ");
      } else if (mode == REPLACESVG) {
        print("RPLSVG: ");
        generateName();
        if (over) {
          svg = tmpsvg;
          svgpath = tmppath;
        } else {
          svg.addAll(tmpsvg);
          svgpath.addAll(tmppath);
        }
      } else if (mode == NFOSVG) {
        print("NFOSVG: ");
        ((TileSVG)sh).useGlobalStyle(false);
        nfo = sh;
        showNfoToggle.setState(true);
      }

      if (tileEditor != null) {
        int tmpmode = mode;
        if (mode == REPLACESVG && !over) {
          tmpmode = ADDSVG;
        }
        tileEditor.updateTileList(svg, tmpmode);
        tileEditor.lastTile();
      }      
      println(path);
    }
  }
}//class DropTargetSVG


// ---------------------------------------------------------------------------
//  ColorBangView
// ---------------------------------------------------------------------------

class ColorBangView implements ControllerView<Bang> {
  
  public void display( PGraphics g , Bang c ) {
    //draw checkerboard 
    g.fill(64);
    g.rect(0, 0, 10, 10);
    g.rect(10, 10, 10, 10);
    g.fill(192);
    g.rect(10, 0, 10, 10);
    g.rect(0, 10, 10, 10);

    if (c.isActive()) {
      g.fill(c.getColor().getActive());
    } else {
      g.fill(c.getColor().getForeground());
    }

    g.rect(0, 0, c.getWidth(), c.getHeight());
    
    if (c.isLabelVisible()) {    
      int x = c.getWidth()/2 - c.getCaptionLabel().getWidth()/2;
      int y = c.getHeight()/2 - c.getCaptionLabel().getHeight()/2 - 1;
      translate(x, y);
      
      if(brightness(c.getColor().getForeground()) < 175) { c.getCaptionLabel().setColor(255); } 
      else { c.getCaptionLabel().setColor(0); }
      c.getCaptionLabel().draw(g);
    }
  }
}


// ---------------------------------------------------------------------------
//  ScrollableListPlus - temporarily till controlP5-lib makes itemHover in ScrollableList visible
// ---------------------------------------------------------------------------

class ScrollableListPlus extends ScrollableList {

  CColor activeColor = new CColor().setBackground(c1);
  CColor passiveColor = new CColor().setBackground(bg);
  Map< String, Object > newselected = null;
  Map< String, Object > oldselected = null;

  public ScrollableListPlus( ControlP5 theControlP5, String theName ) {
    super(theControlP5, theName);
    registerProperty( "value" );
  }

  public ScrollableListPlus setValue( float theValue ) {
    super.setValue(theValue);
    return this;
  }

  public void updateHighlight(Map< String, Object > item) {
    newselected = item;

    if (!newselected.equals(oldselected)) {
      newselected.put("color", activeColor); 
      if (oldselected != null) {
        oldselected.put("color", passiveColor);
      }
    }
    oldselected = newselected;
  }

  public int getItemHover() {
    return itemHover;
  }
}//class ScrollableListPlus
