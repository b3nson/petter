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
  boolean over = false;
  int mode = -1;
  int margin = 20;
  int cw, ch;
  int x, y, w, h;
  int col;
  int colTile = color(16, 181, 198, 150);
  int colNfo  = color(60, 105, 97, 180);
  Textlabel label;

  DropTargetSVG(PApplet app, int mode) {
    this.app = app;
    this.mode = mode;
    setTargetRect(viewwidth, viewheight, mode);
  }

  void draw() {
    if (over) {
      fill(col);
      rect(x, y, w, h);
      label.draw(app);
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
      label = new Textlabel(gui, "ADD", cw/2-5, h/2, 400, 200);
      col = colTile;
    } else if (mode == REPLACESVG) {
      x = margin;
      w = cw-(2*margin);
      h = ((ch-(margin*2))/7)*3;
      y = h+margin;
      label = new Textlabel(gui, "REPLACE", cw/2-20, (h/2)+h, 400, 200);
      col = colTile;
    } else if (mode == NFOSVG) {
      x = margin;
      h = (ch-(margin*2))/7;
      y = ch-h-margin;
      w = cw-(2*margin);
      label = new Textlabel(gui, "NFO", cw/2-20, (h/2)+y-10, 400, 200);
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
      }      
      println(path);
    }
  }
}//class DropTargetSVG




// ---------------------------------------------------------------------------
//  DROPTARGETIMG
// ---------------------------------------------------------------------------

class DropTargetIMG extends DropListener {

  PApplet app;
  boolean over = false;
  int cw, ch;  
  int col = color(16, 181, 198, 150);

  DropTargetIMG(PApplet app) {
    this.app = app;
    cw = viewwidth;
    ch = viewheight;
    setTargetRect(cw+10, 10, guiwidth-20, height-20);
  }

  void draw() {
    if (over) {
      fill(col);
      rect(cw+10, 10, guiwidth-20, height-20);
    }
  }

  void updateTargetRect(int newwidth, int newheight) {
    cw = newwidth;
    ch = newheight;
    setTargetRect(cw+10, 10, guiwidth-20, height-20);
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

    boolean url = theDropEvent.isURL();
    boolean file = theDropEvent.isFile();
    boolean img = theDropEvent.isImage();  

    //IMAGEMAP ======================================================  
    //somewhat complicated testing due to different behaviour on linux and osx
    //there seems to be a bug in sDrop (not correctly working in linux)
    if ((url&&!file&&img) || (!url&&file&&img)) {
      if (!url&&file&&img) {
        lastImgDropped = trim(theDropEvent.filePath());
      }
      if (url&&!file&&img) {
        lastUrlDropped = theDropEvent.url();
        try {
          lastUrlDropped = trim(split(lastUrlDropped, "file://")[1]);
        } 
        catch(ArrayIndexOutOfBoundsException e) {
          lastUrlDropped = "";
        }
      }      
      if ( (lastUrlDropped.equals(lastImgDropped)) == false) {
        String path = url ? theDropEvent.url() : theDropEvent.filePath();
        String p = path.substring(path.lastIndexOf('.') + 1);
        map.clear();
        mapIndex = 0;
        if (p.equals("gif")) {
          ArrayList<PImage> tmpimg = new ArrayList<PImage>(Arrays.asList(Gif.getPImages(app, path)));
          map = tmpimg;
        } else {
          //map.add(theDropEvent.loadImage()); //fails in Processing 3.x
          map.add(requestImage(path));
        }
        imgMap.setup(app);
        updateImgMap();
      } else {
        lastImgDropped = "x";
        lastUrlDropped = "y";
      }
    }
  }
}//class DropTargetIMG




// ---------------------------------------------------------------------------
//  GUIIMAGE
// ---------------------------------------------------------------------------

class GuiImage extends Canvas {

  int x = 0;
  int y = 0;
  int hh = 0;
  int ww = 0;

  int wtmp = 0;

  int mx, my, offsetx, offsety;
  int a, b, e, f ;
  int cornerSize = 12;

  boolean inside = false;  
  boolean drag = false;
  boolean dragC1 = false;
  boolean dragC3 = false;
  boolean insideCorner3 = false;
  boolean insideCorner1 = false;
  boolean startedInside = false;
  boolean canStartDrag = false;

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

  public void draw(PGraphics g) {     
    if (map.size() != 0 && mapIndex < map.size()) {
      if (map.get(mapIndex) != null) {
        pushStyle();
        if (wtmp != map.get(mapIndex).width) {
          hh = (int)(((float)map.get(mapIndex).height / (float)map.get(mapIndex).width) * (float)(ww));
          imgMapHeight = hh;
          updateImgMap();
          a = 0;
          b = y;

          if (map.get(mapIndex).height > map.get(mapIndex).width) {
            e = ww;
            f = (int) ((float)ww * ((float)viewheight) / (float)viewwidth);
            if (f > hh) {
              f = hh;
              e = (int) ((float)hh * ((float)viewwidth) / (float)viewheight);
            }
          } else {
            f = hh;
            e = (int) ((float)hh * ((float)viewwidth) / (float)viewheight);
          }
        }

        try {
          g.image(map.get(mapIndex), x, y, ww, hh); //problem during svg-export
        } 
        catch(NullPointerException e) {
        }

        wtmp = map.get(mapIndex).width;

        mx = mouseX- (int)imgmapGroup.getAbsolutePosition()[0] -1;
        my = mouseY- (int)imgmapGroup.getAbsolutePosition()[1] -3;

        stroke(c1);
        strokeWeight(1f);
        cornerCol = colCorner;

        if ( (mx >= a && mx <= a+e) && (my >= b && my <= b+f)  ) {
          fill(colOver);
          cornerCol = colCornerActive;
          inside = true;
          insideCorner1 = false;
          insideCorner3 = false;

          if (mx >= a+e-cornerSize && my >= b+f-cornerSize) {
            insideCorner3 = true;
            cornerCol = colCornerOver;
          } else if (mx <= a+cornerSize && my <= b+cornerSize) {
            insideCorner1 = true;
            cornerCol = colCornerOver;
          }
        } else {
          inside = false;
          insideCorner1 = false;
          insideCorner3 = false;
          canStartDrag = false;
        }
        if (inside && !mousePressed) {
          canStartDrag = true;
        } 
        if (inside && canStartDrag && mousePressed && !drag) {
          startedInside = true;
          drag = true;
          offsetx = mx-a;
          offsety = my-b;
          if (insideCorner1 == true) {
            dragC1 = true;
          }
          if (insideCorner3 == true) {
            dragC3 = true;
            offsetx = e-offsetx;
            offsety = f-offsety;
          }
        }

        if (drag) {
          if (mousePressed && startedInside) {
            if (dragC1 == true) {   
              e = e-(mx-a)+offsetx;
              f = f-(my-b)+offsety;
              a = mx-offsetx;
              b = my-offsety;
            } else if (dragC3 == true) {
              //a = mx;
              //b = my;          
              e = mx-a+(offsetx);
              if (shiftPressed) {
                stroke(colCornerOver);
                f = (int) ((float)e * ((float)viewheight) / (float)viewwidth);
              } else {
                f = my-b+(offsety);
              }
            } else {
              a = mx-offsetx;
              b = my-offsety;
            }
          } else {
            startedInside = false;
            inside = false;
            drag = false; 
            dragC1 = false;
            dragC3 = false;       
            insideCorner1 = false;
            insideCorner3 = false;
          }
        }
        a = constrain(a, x-e, ww);
        b = constrain(b, y-f, y+hh);

        rect(a, b, e, f);
        fill(cornerCol);

        noStroke();
        triangle(a+1, b+1, a+cornerSize, b+1, a+1, b+cornerSize);
        triangle(a+e, b+f, a+e-cornerSize, b+f, a+e, b+f-cornerSize);
        popStyle();
      }
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
