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
//  GUIIMAGE
// ---------------------------------------------------------------------------

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
    if(map.size() != 0 && mapIndex < map.size()) {
      if(map.get(mapIndex) != null) {
        pushStyle();
        if(wtmp != map.get(mapIndex).width) {
          hh = (int)(((float)map.get(mapIndex).height / (float)map.get(mapIndex).width) * (float)(ww));
          imgMapHeight = hh;
          updateImgMap();
          a = 0;
          b = y;
  
          if(map.get(mapIndex).height > map.get(mapIndex).width) {
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
      
      g.image(map.get(mapIndex), x, y, ww,  hh);
      wtmp = map.get(mapIndex).width;
     
      mx = mouseX-(int)main.getPosition()[0]-1;
      my = mouseY-(int)main.getPosition()[1]-3;
  
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
          canStartDrag = false;
      }
      if(inside && !mousePressed) {
        canStartDrag = true;
      } 
      if(inside && canStartDrag && mousePressed && !drag) {
        startedInside = true;
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
        if(mousePressed && startedInside) {
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
          startedInside = false;
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
      popStyle();
      }
    }
  }
}


// ---------------------------------------------------------------------------
//  DROPTARGETSVG
// ---------------------------------------------------------------------------

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
  
  //SVGs ==========================================================
      String path = theDropEvent.toString();
      if (split(path, ".lafkon.net").length > 1) {
        path =  split(path, ".pdf")[0] +".svg";
      }
      if (path.toLowerCase().endsWith(".svg")) {
        println("SVG: " +path);
        PShape sh = loadShape(path);
        if(customStyle) sh.disableStyle();
        tmpsvg.add(sh);
        
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
    
    boolean url = theDropEvent.isURL();
    boolean file = theDropEvent.isFile();
    boolean img = theDropEvent.isImage();  

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
        String path = url ? theDropEvent.url() : theDropEvent.filePath();
        String p = path.substring(path.lastIndexOf('.') + 1);
        map.clear();
        mapIndex = 0;
        if(p.equals("gif")) {
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
  
}//class DropTarget


// ---------------------------------------------------------------------------
//  DROPTARGETNFO
// ---------------------------------------------------------------------------

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
    y1 = (ch/7)*6-10;
    w1 = cw-20;
    h1 = (ch/7)*1+5;    
    setTargetRect(x1, y1, w1, h1);
  }
  
  void dropEnter() {
    over = true;
  }

  void dropLeave() {
    over = false;
  }
  
  void dropEvent(DropEvent theDropEvent) {
  
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


// ---------------------------------------------------------------------------
//  ScrollableListPlus - temporarily till controlP5-lib makes itemHover in ScrollableList visible
// ---------------------------------------------------------------------------

class ScrollableListPlus extends ScrollableList {

  ScrollableListPlus( ControlP5 theControlP5, String theName ) {
    super(theControlP5, theName);
    registerProperty( "value" );
  }

  public ScrollableListPlus setValue( float theValue ) {
    super.setValue(theValue);
    return this;
  }

  int getItemHover() {
    return itemHover;
  }
}

