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
  void draw(PGraphics g);
  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles);
  float getMapValue(float tilex, float tiley);
  
}




// ---------------------------------------------------------------------------
//  PerlinNoiseMap
// ---------------------------------------------------------------------------

public class PerlinNoiseMap implements EffectorMap {
  
  private int w, h, x, y;
  private int cols = 8; 
  private int rows = 10;
  private int maxw = 400;
  private int maxh = 400;

  boolean newNoisemapAvailable = false;
  
  PVector[][] flowfield, tmpflowfield;
  float cellsize = 10;
  int tmpcols, tmprows;
  float tmpcellsize;
  float noiseScale = 0.1; // 0.04; //0.005-0.03
  int noiseDetail = 4;
  
  
  Slider scaleSlider, detailSlider;
  Bang seedBang;

  PerlinNoiseMap() {
    super();
  }

 void setup(ControlP5 cp5, String name, Group tabgroup) {
   scaleSlider = cp5.addSlider("noisescale")
     .setPosition(20,0)
     .setSize(tabgroup.getWidth()-80, 20)
     .setRange(0.002, 0.5)
     .plugTo(this, "noiseScaleChange")
     .setValue(noiseScale)
     .setScrollSensitivity(0.04)
     .setLabel("noisescale")
     .setGroup(tabgroup)
     ;
   
   detailSlider = cp5.addSlider("noisedetail")
     .setPosition(20,25)
     .setSize(tabgroup.getWidth()-80, 20)
     .setRange(1, 8)
     .plugTo(this, "noiseDetailChange")
     .setValue(noiseDetail)
     .setScrollSensitivity(0.04)
     .setLabel("noisedetail")
     .setGroup(tabgroup)
     ;
     
   seedBang = cp5.addBang("noiseSeedChange")
     .setPosition(20, 50)
     .setSize(20, 20)
     .plugTo(this, "noiseSeedChange")
     .setLabel("seed")
     .setGroup(tabgroup)
     ;
     seedBang.getCaptionLabel().setPadding(1,-14);
     seedBang.setColorForeground(color(100));
  }
  
  void draw(PGraphics g) {
    if(newNoisemapAvailable) {
     flowfield = tmpflowfield; 
     cols = tmpcols;
     rows = tmprows;
     cellsize = tmpcellsize;
     newNoisemapAvailable = false;
    }
    g.rectMode(CENTER);
    g.pushMatrix();
    g.translate((g.width-w)/2, (g.height-h)/2);
    for (int i=0;i<cols;i++) {
      for (int j=0;j<rows;j++) {
        g.pushMatrix();
          g.translate(i*cellsize+cellsize/2, j*cellsize+cellsize/2);
          g.fill(map(flowfield[i][j].x, 0f, TWO_PI, 0f, 255f ));
          g.rect(0, 0, cellsize, cellsize);
        g.popMatrix();
      }
    }    
    g.popMatrix();
  } 
  //switch to flowfieldview?
  
  // --- PETTER-CALLBACK ----------------------------------------------------|

  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles) {
    float par = float(petterw)/float(petterh);
    float car = float(maxw)/float(maxh);
    if(par > car) { // quer
      this.w = maxw;
      this.h = round(float(maxw) / par);
    }
    else {  //hoch
      this.h = maxh;
      this.w = round(float(maxh) * par);
    }
    if(xtiles != 0) {
      tmpcellsize = float(this.w)/float(xtiles);
    }
    //counterscale noisescale for consistent map on xtile-changes
    if(tmpcols != 0 && xtiles != tmpcols && xtiles > 0) { 
      float f = ((xtiles-tmpcols) / (float)xtiles) * noiseScale;
      noiseScale -= f;
      scaleSlider.changeValue(noiseScale);
    }
    tmpcols = xtiles;
    tmprows = round(this.h/tmpcellsize);  
    generateNoisemap();
  }

  float getMapValue(float tilex, float tiley) {
    float xx = map(tilex, 0, pagewidth, 0, w);
    float yy = map(tiley, 0, pageheight, 0, h);    
    int fieldx = floor(xx / cellsize);
    int fieldy = floor(yy / cellsize);
    return map(flowfield[fieldx][fieldy].x, 0f, TWO_PI, 0f, 1f);
  }
  
  // --- INTERNAL UTIL ------------------------------------------------------|
  
  private void generateNoisemap() {
    tmpflowfield = new PVector[tmpcols][tmprows];
    float xoff = 0;
    for (int i=0;i<tmpcols;i++) {
      float yoff = 0;
      for (int j=0;j<tmprows;j++) {
        float perlin = map(noise(xoff, yoff), 0, 1, 0, TWO_PI);
        tmpflowfield[i][j] = new PVector(perlin, perlin);
        yoff += noiseScale;
      }
      xoff += noiseScale;
    }    
    newNoisemapAvailable = true;
  }
  
  // --- UI-CALLBACK --------------------------------------------------------|
  
  void noiseScaleChange(float v) {
    noiseScale = v;
    generateNoisemap();
  }
  
  void noiseDetailChange(int v) {
    noiseDetail = v;
    noiseDetail(noiseDetail);
    generateNoisemap();
  }
  
  void noiseSeedChange() {
    noiseSeed(millis());
    generateNoisemap();
  }
}//PerlinNoiseMap







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
  
  private int w, h, x, y;
  private int cols = 1; 
  private int rows = 20;
  private int maxw = 400;
  private int maxh = 400;
  private int black = 0;
  private int white = 255;
  private float cellwidth;
  private float cellheight;
    
  Slider colSlider, rowSlider;

  PatternMap() {
    super();
  }

 void setup(ControlP5 cp5, String name, Group tabgroup) {
   colSlider = cp5.addSlider("pmcols")
     .setPosition(20,0)
     .setSize(tabgroup.getWidth()-80, 20)
     .setRange(1, 250)
     .plugTo(this, "changeCols")
     .setValue(cols)
     .setScrollSensitivity(0.04)
     .setLabel("cols")
     .setGroup(tabgroup)
     ;
   
   rowSlider = cp5.addSlider("pmrows")
     .setPosition(20,25)
     .setSize(tabgroup.getWidth()-80, 20)
     .setRange(1, 250)
     .plugTo(this, "changeRows")
     .setValue(rows)
     .setScrollSensitivity(0.04)
     .setLabel("rows")
     .setGroup(tabgroup)
     ;
  }
  
  void draw(PGraphics g) {
    g.rectMode(CORNER);
    g.pushMatrix();
    g.translate((g.width-w)/2, (g.height-h)/2);
    for(int i=0;i<cols; i++) {
      for(int j=0;j<rows; j++) {
        g.fill(i%2==j%2?black:white);
        g.rect(i*cellwidth, j*cellheight,cellwidth, cellheight);
      }
    }
    g.popMatrix();
  }
  
  // --- PETTER-CALLBACK ----------------------------------------------------|
  
  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles) {
    float par = float(petterw)/float(petterh);
    float car = float(maxw)/float(maxh);
    if(par > car) { // quer
      this.w = maxw;
      this.h = round(float(maxw) / par);
    }
    else {  //hoch
      this.h = maxh;
      this.w = round(float(maxh) * par);
    }
    cellwidth  = float(w)/float(cols);
    cellheight = float(h)/float(rows);
  }
  
  float getMapValue(float tilex, float tiley) {
    float ww = float(pagewidth)/float(cols); 
    float hh = float(pageheight)/float(rows);
    int fieldx = floor(tilex / ww);
    int fieldy = floor(tiley / hh);
    
    if(fieldx%2==fieldy%2) {
      return map(black, 0, 255, 0, 1);
    } else {
      return map(white, 0, 255, 0, 1);    
    }
  }

  // --- UI-CALLBACK --------------------------------------------------------|
  
  void changeCols(int v) {
    cols = v;
    cellwidth  = float(w)/float(cols);
    cellheight = float(h)/float(rows);
  }
  
  void changeRows(int v) {
    rows = v;
    cellwidth  = float(w)/float(cols);
    cellheight = float(h)/float(rows);
  }
  
}//PatternMap
