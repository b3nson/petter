/**
 * Petter - vector-graphic-based pattern generator.
 * http://www.lafkon.net/petter/
 * Copyright (C) 2020 LAFKON/Benjamin Stephan
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
 
 
public interface EffectorMap {
  void setup(ControlP5 cp5, String name, Group tabgroup);
  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles);
}


// ---------------------------------------------------------------------------
//  TestMap
// ---------------------------------------------------------------------------

public class TestMap implements EffectorMap {
  
  TestMap() {
    super();
  }
  
  void setup(ControlP5 cp5, String name, Group tabgroup) {
    cp5.addMatrix("myMatrix")
       .setPosition(50, 0)
       .setSize(200, 200)
       .setGrid(10, 10)
       .setGap(10, 1)
       .setInterval(200)
       .setGroup(tabgroup)
       ;  
  }
  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles) {
    //donothing
  }
}

// ---------------------------------------------------------------------------
//  TestMap
// ---------------------------------------------------------------------------

public class PackMap extends PatternMap {
    PackMap() {
    super();
  }
}

// ---------------------------------------------------------------------------
//  PatternMap
// ---------------------------------------------------------------------------

public class PatternMap implements EffectorMap {
  int cols = 1; 
  int rows = 20;
  PatternCanvas cc;
  Slider colSlider, rowSlider;

  PatternMap() {
    super();
  }

  void setup(ControlP5 cp5, String name, Group tabgroup) {
   colSlider = cp5.addSlider("pmcols")
       .setPosition(20,0)
       .setSize(tabgroup.getWidth()-80, 20)
       .setRange(1, 250)
       .plugTo(this, "cols")
       .setValue(cols)
       .setScrollSensitivity(0.04)
       .setLabel("cols")
       .setGroup(tabgroup)
       ;
       
    rowSlider = cp5.addSlider("pmrows")
       .setPosition(20,25)
       .setSize(tabgroup.getWidth()-80, 20)
       .setRange(1, 250)
       .plugTo(this, "rows")
       .setValue(rows)
       .setScrollSensitivity(0.04)
       .setLabel("rows")
       .setGroup(tabgroup)
       ;

  cc = new PatternCanvas(20, 60, 200, 250);

  tabgroup.addCanvas(cc);
  //updateCanvasBounds();
  
  }
  
  
  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles) {
    cc.updateBounds(petterw, petterh, xtiles, ytiles);
  }
  
  
  
  
private class PatternCanvas extends Canvas {

  int w, h, x, y;
  private int maxw = 400;
  private int maxh = 400;
  
  
  public PatternCanvas(int x, int y, int w, int h){
    this.w = w;
    this.h = h;
    this.x = x;
    this.y = y;
  }
  
  //public void setup(PGraphics g) {
  //  y = 200;
  //}  

  //public void update(PApplet p) {
    //mx = p.mouseX;
    //my = p.mouseY;
    //this.w = petterw;
    //this.h = petterh;
  //}
  
  public void updateBounds(int petterw, int petterh, int xtiles, int ytiles) {
    float par = float(petterw)/float(petterh);
    float car = float(maxw)/float(maxh);
    if(par > car) { // quer
      this.w = maxw;
      this.h = round(float(maxw) / par);
    }
    else {  //hoch
      this.h = this.maxh;
      this.w = round(float(maxh) * par);
    }
  }
  
  public void draw(PGraphics g) {
    
    float ww = float(w)/float(cols); //does not need to happen on every draw
    float hh = float(h)/float(rows);
    
    g.pushMatrix();
    g.translate((g.width-w)/2, 60);// (height-h)/2);
    for(int i=0;i<cols; i++) {
      for(int j=0;j<rows; j++) {
        g.fill(i%2==j%2?0:255);
        g.rect(i*ww, j*hh,ww, hh);
      }
    }
    g.popMatrix();  
  }
}
  
}
