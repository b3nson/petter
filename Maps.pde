/**
 * Petter - vector-graphic-based pattern generator.
 * http://www.lafkon.net/petter/
 * Copyright (C) 2022 LAFKON/Benjamin Stephan
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
  boolean getMapPermit(float tilex, float tiley);
  float getMapValue(float tilex, float tiley);
  void mouseEvent(MouseEvent e);
}



// ---------------------------------------------------------------------------
//  ImageMap
// ---------------------------------------------------------------------------

public class ImageMap extends DropListener implements EffectorMap {

  PApplet p;
  SDrop drop;

  int petterw, petterh;
  int imgw, imgh;
  int rectw, recth, rectx, recty;
  int cropX, cropY, cropW, cropH;
  int dragOffsetX, dragOffsetY;
  int droptargetx, droptargety, droptargetwidth, droptargetheight;
  int cornerSize = 16;
  int maxw = 400;
  int maxh = 400;
  int h = 20;

  float iar; //image-aspect-ratio
  float car; //canvas-aspect-ratio
  float par; //petter-aspect-ratio

  boolean mouseInside = false;
  boolean insideCorner1 = false;
  boolean insideCorner3 = false;
  boolean insideRect = false;
  boolean canStartDrag = false;
  boolean drag = false;
  boolean startedInside = false;
  boolean dragC1 = false;
  boolean dragC3 = false;
  boolean over = false;
  boolean newvaliddrop = false;
  boolean imgloaded = false;
  boolean killGreen = false;

  int dropColor, c1, c1aaa, c2, c2aaa, c2aa, c2a, rectStrokeColor, rectFillColor, cornerColor;

  Range imgmapHistogramRange;
  Textlabel infolabel;
  Group gifseqGroup;
  Button closeImgButton, mapFramePrevButton, mapFrameNextButton, mapFrameFirstButton, mapFrameLastButton;
  Toggle killGreenButton;

  ImageMap() {
    super();
  }

  void setup(ControlP5 cp5, String name, Group tabgroup) {
    p = cp5.papplet;
    drop = new SDrop(p);
    drop.addDropListener(this);
    updateTargetRect(20, 40, p.width-40, p.height-100);

    //define colors in setup, otherwise sporadic wrong colors
    p.colorMode(RGB, 255, 255, 255, 255);
    dropColor = p.color(16, 181, 198, 150);
    c1 = p.color(16, 181, 198, 255);
    c1aaa = p.color(16, 181, 198, 60);
    c2 = p.color(0, 255, 150, 255);
    c2aaa = p.color(0, 255, 150, 30);
    c2aa = p.color(0, 255, 150, 100);
    c2a = p.color(0, 255, 150, 160);
    rectStrokeColor = c1;
    rectFillColor = c1aaa;
    cornerColor = c1;

    imgmapHistogramRange = cp5.addRange("contrast")
      .setBroadcast(false)
      .setPosition(20, 0)
      .setSize(tabgroup.getWidth()-80, 20)
      .setHandleSize(10)
      .setRange(0f, 1f)
      .setRangeValues(0f, 1f)
      .setVisible(false)
      .setGroup(tabgroup)
      ;
    styleLabel(imgmapHistogramRange, "contrast");

    infolabel = cp5.addTextlabel("infolabel" )
      .setPosition((p.width)/2-36, (p.height)/2-30)
      .setText("Drop image here.")
      .setGroup(tabgroup);
    ;

    closeImgButton = cp5.addButton("closeImg")
      .setLabel("X")
      .setValue(0)
      .setPosition(20, 30)
      .setSize(h, h)
      .setVisible(false)
      .plugTo(this, "closeImg")
      .setGroup(tabgroup)
      ;
    closeImgButton.getCaptionLabel().setPadding(8, -14);

    killGreenButton = cp5.addToggle("killGreen")
      .setLabel("XG")
      .setValue(0)
      .setPosition(tabgroup.getWidth()-40, 30)
      .setSize(h, h)
      .setVisible(false)
      .plugTo(this, "killGreen")
      .setGroup(tabgroup)
      ;
    killGreenButton.getCaptionLabel().setPadding(5, -14);

    gifseqGroup = cp5.addGroup("gifseq")
      .setPosition(20, 30)
      .hideBar()
      .open()
      .setVisible(false)
      .setGroup(tabgroup)
      ;

    mapFramePrevButton = cp5.addButton("f<")
      .setLabel("<")
      .setValue(0)
      .setPosition(0, 0)
      .setSize(h, h)
      .plugTo(this, "prevMapFrame")
      .setGroup(gifseqGroup)
      ;
    mapFramePrevButton.getCaptionLabel().setPadding(8, -14);

    mapFrameNextButton = cp5.addButton("f>")
      .setLabel(">")
      .setValue(0)
      .setPosition(h+4, 0)
      .setSize(h, h)
      .plugTo(this, "nextMapFrame")
      .setGroup(gifseqGroup)
      ;
    mapFrameNextButton.getCaptionLabel().setPadding(8, -14);

    mapFrameFirstButton = cp5.addButton("ffirst")
      .setLabel("<I")
      .setValue(0)
      .setPosition(h+h+4+6, 0)
      .setSize(h, h)
      .plugTo(this, "firstMapFrame")
      .setGroup(gifseqGroup)
      ;
    mapFrameFirstButton.getCaptionLabel().setPadding(8, -14);

    mapFrameLastButton = cp5.addButton("flast")
      .setLabel("I>")
      .setValue(0)
      .setPosition(h+h+h+6+4+4, 0)
      .setSize(h, h)
      .plugTo(this, "lastMapFrame")
      .setGroup(gifseqGroup)
      ;
    mapFrameLastButton.getCaptionLabel().setPadding(8, -14);

    //TODO
    //non-uniform targetRect
    //edge behaviour: black/white/green/repeat
  }

  void draw(PGraphics g) {

    if (map.size() != 0 && mapIndex < map.size()) {
      if (map.get(mapIndex) != null) {
        try {
          if (newvaliddrop && map.get(mapIndex).width > 0) { //async img loaded
            //calc image-draw-size
            iar = (float)map.get(mapIndex).width / (float)map.get(mapIndex).height;
            car = float(maxw)/float(maxh);
            if (iar > car) { // quer
              imgw = maxw;
              imgh = round(float(maxw) / iar);
            } else {        //hoch
              imgh = maxh;
              imgw = round(float(maxh) * iar);
            }

            //calc initial rect-draw-size
            if (iar > par) { //image querer als pettercanvas
              rectw = (int) (imgh*par);
              recth = imgh;
            } else { //image höher als pettercanvas
              rectw = imgw;
              recth = (int ) (imgw/par);
            }

            closeImgButton.setPosition(20, g.height/2 - imgh/2 -40);
            closeImgButton.setVisible(true);
            rectx = 0;
            recty = 0;
            recalcImageCropbox();
            newvaliddrop = false;
            imgloaded = true;
          }

          if (imgloaded) {
            g.pushMatrix();
            g.pushStyle();
            g.imageMode(CENTER);
            g.translate(g.width/2, g.height/2);
            g.image(map.get(mapIndex), 0, 0, imgw, imgh); //problem during svg-export
            g.popStyle();

            float rectwhalf = (float)rectw/2;
            float recthhalf = (float)recth/2f;
            int mx = p.pmouseX - g.width/2;// + mouseXOffset;
            int my = p.pmouseY - g.height/2 ;//+ mouseYOffset;
            int mxrel = mx - rectx;
            int myrel = my - recty;

            //mouse inside selectrect
            if ( (mxrel >= -rectwhalf && mxrel <= rectwhalf && myrel >= -recthhalf && myrel <= recthhalf   ) || drag == true ) {
              rectStrokeColor = c2a;
              rectFillColor = c2aa;
              cornerColor = rectStrokeColor;
              insideRect = true;
              insideCorner1 = false;
              insideCorner3 = false;

              if (mxrel >= rectwhalf-cornerSize && myrel >= recthhalf-cornerSize) {
                insideCorner3 = true;
                cornerColor = c2;
                rectStrokeColor = c2;
              } else if (mxrel <= -rectwhalf+cornerSize && myrel <= -recthhalf+cornerSize) {
                insideCorner1 = true;
                cornerColor = c2;
                rectStrokeColor = c2;
              }
            } else { //outside selectrect
              rectStrokeColor = c1;
              rectFillColor = c1aaa;
              cornerColor = rectStrokeColor;
              insideRect = false;
              insideCorner1 = false;
              insideCorner3 = false;
              canStartDrag = false;
            }

            if (insideRect && !p.mousePressed) {
              canStartDrag = true;
            }

            if (insideRect && canStartDrag && p.mousePressed && !drag) {
              startedInside = true;
              drag = true;
              dragOffsetX = mxrel;
              dragOffsetY = myrel;
              if (insideCorner1) {
                dragC1 = true;
                dragOffsetX = (int)(rectwhalf+dragOffsetX)*2;
              } else if (insideCorner3) {
                dragC3 = true;
                dragOffsetX = (int)(rectwhalf-dragOffsetX)*2;
              }
            }

            if (drag) {
              if (p.mousePressed && startedInside) {
                if (dragC1 || dragC3) {
                  rectw = abs(mxrel)*2 + dragOffsetX;
                  recth = (int) ((float)rectw/par);
                  rectwhalf = (float)rectw/2;
                  recthhalf = (float)recth/2;
                } else {
                  rectx = mx-dragOffsetX;
                  recty = my-dragOffsetY;
                }
                rectStrokeColor = c2;
                rectFillColor = c2aaa;
                cornerColor = c2;
              } else {
                startedInside = false;
                insideRect = false;
                drag = false;
                dragC1 = false;
                dragC3 = false;
                insideCorner1 = false;
                insideCorner3 = false;
              }
              recalcImageCropbox();
            }

            //rectx = constrain(a, x-e, ww);
            //recty = constrain(b, y-f, y+hh);
            g.pushStyle();
            g.colorMode(RGB, 255, 255, 255, 255);
            g.rectMode(CENTER);

            g.fill(cornerColor);
            g.noStroke();
            g.triangle(rectx+rectwhalf, recty+recthhalf, rectx+rectwhalf, recty+recthhalf-cornerSize, rectx+rectwhalf-cornerSize, recty+recthhalf);
            g.triangle(rectx-rectwhalf, recty-recthhalf, rectx-rectwhalf, recty-recthhalf+cornerSize, rectx-rectwhalf+cornerSize, recty-recthhalf);

            g.fill(rectFillColor);
            g.stroke(rectStrokeColor);
            g.rect(rectx, recty, rectw, recth);

            if (drag) { //crosshair
              g.line(rectx-3, recty, rectx+3, recty);
              g.line(rectx, recty-3, rectx, recty+3);
            }

            g.popStyle();
            g.popMatrix();
          } //img loaded
        }
        catch(NullPointerException e) {
          println(e);
        }
      }
    }

    if (over) {
      g.colorMode(RGB, 255, 255, 255, 255);
      g.pushStyle();
      g.fill(dropColor);
      g.noStroke();
      g.rectMode(CORNER);
      g.rect(droptargetx, droptargety, droptargetwidth, droptargetheight);
      g.popStyle();
    }
  } //draw


  // --- PETTER-CALLBACK ----------------------------------------------------|

  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles) {
    this.petterw = petterw;
    this.petterh = petterh;
    par = float(petterw)/float(petterh);

    //calc rect-draw-size
    if (iar > par) { //image querer als pettercanvas
      float rectscale = (float)recth/(float)imgh;
      rectw = (int) (imgh*par*rectscale);
      recth = (int) (imgh*rectscale);
    } else { //image höher als pettercanvas
      float rectscale = (float)rectw/(float)imgw;
      rectw = (int) (imgw*rectscale);
      recth = (int) ((imgw/par)*rectscale);
    }
  }

  boolean getMapPermit(float tilex, float tiley) {
    if (killGreen) {
      try {
        float absScreenXPos = map(tilex, 0, petterw, cropX, cropW ) ;
        float absScreenYPos = map(tiley, 0, petterh, cropY, cropH );

        int px = (int)constrain(absScreenYPos, 0, map.get(mapIndex).height-1)*(int)map.get(mapIndex).width-1+(int)constrain(absScreenXPos, 0, map.get(mapIndex).width-1);
        color col;
        try {
          col = map.get(mapIndex).pixels[px];
          if (col == color(0, 255, 0)) { //green doesn't get mapped
            return false;
          } else {
            return true;
          }
        }
        catch(ArrayIndexOutOfBoundsException e) { return true; }
      }
      catch(Exception e) { return true; } //IndexOutOfBoundsException | NullPointerException
    } else {
      return true;
    }
  }

  float getMapValue(float tilex, float tiley) {
    float mapValuex = 0f;

    try {
      //map von petterpos auf cropped großbild-pos
      float absScreenXPos = map(tilex, 0, petterw, cropX, cropW ) ;
      float absScreenYPos = map(tiley, 0, petterh, cropY, cropH );

      int px = (int)constrain(absScreenYPos, 0, map.get(mapIndex).height-1)*(int)map.get(mapIndex).width-1+(int)constrain(absScreenXPos, 0, map.get(mapIndex).width-1);
      color col;
      try {
        col = map.get(mapIndex).pixels[px];
      }
      catch(ArrayIndexOutOfBoundsException e) {
        //println("OUTOFBOUNDS " +e);
        //col = color(255,255,255);
        return 1f;
      }
      //http://de.wikipedia.org/wiki/Grauwert#In_der_Bildverarbeitung
      mapValuex = ((p.red(col)/255f)*0.299f) + ((p.green(col)/255f)*0.587f) + ((p.blue(col)/255f)*0.114f);
      //histogram/contrast
      mapValuex = constrain(map(mapValuex, constrain(imgmapHistogramRange.getLowValue()-0.00001, 0, 0.9999), constrain(imgmapHistogramRange.getHighValue(), 0.0001, 1f), 0f, 1f), 0.0, 1.0);
    } catch(Exception e) {} //IndexOutOfBoundsException | NullPointerException

    return mapValuex;
  }

  void mouseEvent(MouseEvent e) {
    int type = e.getAction();
    switch(type) {
      case processing.event.MouseEvent.WHEEL:
        int tmpw = rectw + e.getCount();
        int tmph = (int) ((float)tmpw/par);
        if ((tmpw > 1 || tmph > 1) && imgloaded) {
          rectw = tmpw;
          recth = tmph;
          recalcImageCropbox();
        }
        break;
      case processing.event.MouseEvent.ENTER:
        mouseInside = true;
        break;
      case processing.event.MouseEvent.EXIT:
        mouseInside = false;
        break;
    }
  }


  // --- INTERNAL UTIL ------------------------------------------------------|

  void recalcImageCropbox() {
    //left-top-corner: map rectxy-center auf rectxy-corner -> map rectxy von previewimg-dims auf auf originalimg-dims
    cropX = (int)map( (imgw-rectw)/2 + rectx, 0, imgw, 0, map.get(mapIndex).width);
    cropY = (int)map( (imgh-recth)/2 + recty, 0, imgh, 0, map.get(mapIndex).height);

    //right-bottom-corner: map rectwh von previewimg-dims auf originalimg-dims + versatz
    cropW = (int)map(rectw, 0, imgw, 0, map.get(mapIndex).width ) + cropX;
    cropH = (int)map(recth, 0, imgh, 0, map.get(mapIndex).height) + cropY;
  }

  void updateTargetRect(int xx, int yy, int ww, int hh) {
    droptargetx = xx;
    droptargety = yy;
    droptargetwidth = ww;
    droptargetheight = hh;
    setTargetRect(droptargetx, droptargety, droptargetwidth, droptargetheight);
  }

  void showUiControls(boolean flag) {
    imgmapHistogramRange.setVisible(flag);
    killGreenButton.setVisible(flag);
    closeImgButton.hide();
    if (map.size() > 1) {
      gifseqGroup.setVisible(flag);
    }
  }

  // --- UI-CALLBACK --------------------------------------------------------|


  void prevMapFrame() {
    prevImgMapFrame();
  }
  void nextMapFrame() {
    nextImgMapFrame();
  }
  void firstMapFrame() {
    firstImgMapFrame();
  }
  void lastMapFrame() {
    lastImgMapFrame();
  }

  void closeImg() {
    showUiControls(false);
    imgloaded = false;
    map.clear();
    mapIndex = 0;
    infolabel.setVisible(true);
    mapEditor.deactivateMapUsage(this);
  }

  void killGreen(boolean state) {
    killGreen = state;
  }

  void dropEnter() {
    this.over = true;
    showUiControls(false);
  }

  void dropLeave() {
    if (!newvaliddrop && imgloaded) {
      showUiControls(true);
    }
    this.over = false;
  }

  String lastImgDropped = "x";
  String lastUrlDropped = "y";

  void dropEvent(DropEvent theDropEvent) {
    boolean url = theDropEvent.isURL();
    boolean file = theDropEvent.isFile();
    boolean img = theDropEvent.isImage();

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
        String ext = path.substring(path.lastIndexOf('.') + 1);
        map.clear();
        mapIndex = 0;
        if (ext.equals("gif")) {
          ArrayList<PImage> tmpimg = new ArrayList<PImage>(Arrays.asList(Gif.getPImages(p, path)));
          map = tmpimg;
          if (map.size() > 1) frames = map.size();
        } else {
          frames = 25;
          map.add(requestImage(path));
        }
        animFrameNumBox.setValue(frames);
        mapIndex = 0;
        newvaliddrop = true;
        imgloaded = false;
        showUiControls(true);
        infolabel.setVisible(false);
      } else {
        lastImgDropped = "x";
        lastUrlDropped = "y";
        showUiControls(false);
      }
    }
    this.over = false;
  }
}//ImageMap









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
      .setPosition(20, 0)
      .setSize(tabgroup.getWidth()-80, 20)
      .setRange(0.002, 0.5)
      .setSliderMode(Slider.FLEXIBLE)
      .setScrollSensitivity(0.005)
      .setNumberOfTickMarks(tickMarks)
      .showTickMarks(false)
      .snapToTickMarks(false)
      .plugTo(this, "noiseScaleChange")
      .setValue(noiseScale)
      .setScrollSensitivity(0.04)
      .setLabel("scale")
      .setGroup(tabgroup)
      ;
    styleLabel(scaleSlider, "scale");

    detailSlider = cp5.addSlider("noisedetail")
      .setPosition(20, 25)
      .setSize(tabgroup.getWidth()-80, 20)
      .setRange(1, 8)
      .setSliderMode(Slider.FLEXIBLE)
      .setScrollSensitivity(0.005)
      .setNumberOfTickMarks(tickMarks)
      .showTickMarks(false)
      .snapToTickMarks(false)
      .plugTo(this, "noiseDetailChange")
      .setValue(noiseDetail)
      .setScrollSensitivity(0.04)
      .setLabel("detail")
      .setGroup(tabgroup)
      ;
    styleLabel(detailSlider, "detail");

    seedBang = cp5.addBang("noiseSeedChange")
      .setPosition(20, 50)
      .setSize(20, 20)
      .plugTo(this, "noiseSeedChange")
      .setLabel("seed")
      .setGroup(tabgroup)
      ;
    seedBang.getCaptionLabel().setPadding(1, -14);
    seedBang.setColorForeground(color(100));
  }

  void draw(PGraphics g) {
    if (newNoisemapAvailable) {
      flowfield = tmpflowfield;
      cols = tmpcols;
      rows = tmprows;
      cellsize = tmpcellsize;
      newNoisemapAvailable = false;
    }
    g.rectMode(CENTER);
    g.pushMatrix();
    g.translate((g.width-w)/2, (g.height-h)/2);
    for (int i=0; i<cols; i++) {
      for (int j=0; j<rows; j++) {
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
    if (par > car) { // quer
      this.w = maxw;
      this.h = round(float(maxw) / par);
    } else {  //hoch
      this.h = maxh;
      this.w = round(float(maxh) * par);
    }
    if (xtiles != 0) {
      tmpcellsize = float(this.w)/float(xtiles);
    }
    //counterscale noisescale for consistent map on xtile-changes
    if (tmpcols != 0 && xtiles != tmpcols && xtiles > 0) {
      float f = ((xtiles-tmpcols) / (float)xtiles) * noiseScale;
      noiseScale -= f;
      scaleSlider.changeValue(noiseScale);
    }
    tmpcols = xtiles;
    tmprows = round(this.h/tmpcellsize);
    generateNoisemap();
  }

  boolean getMapPermit(float tilex, float tiley) {
    return true;
  }

  float getMapValue(float tilex, float tiley) {
    float xx = map(tilex, 0, pagewidth, 0, w);
    float yy = map(tiley, 0, pageheight, 0, h);
    int fieldx = floor(xx / cellsize);
    int fieldy = floor(yy / cellsize);
    try {
      return map(flowfield[fieldx][fieldy].x, 0f, TWO_PI, 0f, 1f);
    } catch(ArrayIndexOutOfBoundsException e) { return 0f; }
  }

  void mouseEvent(MouseEvent e) {
  }

  // --- INTERNAL UTIL ------------------------------------------------------|

  private void generateNoisemap() {
    tmpflowfield = new PVector[tmpcols][tmprows];
    float xoff = 0;
    for (int i=0; i<tmpcols; i++) {
      float yoff = 0;
      for (int j=0; j<tmprows; j++) {
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
      .setPosition(20, 0)
      .setSize(tabgroup.getWidth()-80, 20)
      .setRange(1, 150)
      .plugTo(this, "changeCols")
      .setValue(cols)
      .setSliderMode(Slider.FLEXIBLE)
      .setScrollSensitivity(0.04)
      .setNumberOfTickMarks(tickMarks)
      .showTickMarks(false)
      .snapToTickMarks(false)
      .setLabel("cols")
      .setGroup(tabgroup)
      ;
    styleLabel(colSlider, "cols");

    rowSlider = cp5.addSlider("pmrows")
      .setPosition(20, 25)
      .setSize(tabgroup.getWidth()-80, 20)
      .setRange(1, 150)
      .plugTo(this, "changeRows")
      .setValue(rows)
      .setSliderMode(Slider.FLEXIBLE)
      .setScrollSensitivity(0.04)
      .setNumberOfTickMarks(tickMarks)
      .showTickMarks(false)
      .snapToTickMarks(false)
      .setLabel("rows")
      .setGroup(tabgroup)
      ;
    styleLabel(rowSlider, "rows");
  }

  void draw(PGraphics g) {
    g.rectMode(CORNER);
    g.pushMatrix();
    g.translate((g.width-w)/2, (g.height-h)/2);
    for (int i=0; i<cols; i++) {
      for (int j=0; j<rows; j++) {
        g.fill(i%2==j%2?black:white);
        g.rect(i*cellwidth, j*cellheight, cellwidth, cellheight);
      }
    }
    g.popMatrix();
  }

  // --- PETTER-CALLBACK ----------------------------------------------------|

  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles) {
    float par = float(petterw)/float(petterh);
    float car = float(maxw)/float(maxh);
    if (par > car) { // quer
      this.w = maxw;
      this.h = round(float(maxw) / par);
    } else {  //hoch
      this.h = maxh;
      this.w = round(float(maxh) * par);
    }
    cellwidth  = float(w)/float(cols);
    cellheight = float(h)/float(rows);
  }

  boolean getMapPermit(float tilex, float tiley) {
    return true;
  }

  float getMapValue(float tilex, float tiley) {
    float ww = float(pagewidth)/float(cols);
    float hh = float(pageheight)/float(rows);
    int fieldx = floor(tilex / ww);
    int fieldy = floor(tiley / hh);

    if (fieldx%2==fieldy%2) {
      return map(black, 0, 255, 0, 1);
    } else {
      return map(white, 0, 255, 0, 1);
    }
  }

  void mouseEvent(MouseEvent e) {
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












// ---------------------------------------------------------------------------
//  GradientMap
// ---------------------------------------------------------------------------

public class GradientMap implements EffectorMap {

  PApplet p;
  ControlP5 cp5;
  PGraphics canvas;

  private int ww, hh, x, y, petterw, petterh, xtiles, ytiles;
  private int maxw = 400;
  private int maxh = 400;
  private int white = color(255, 255, 255, 255);
  private int black = color(0, 0, 0, 255);
  private float gradientSize = 283;
  private int gradientCenterX = 0;
  private int gradientCenterY = 0;
  private float maxRectCornerX, maxRectCornerY, petRectCornerX, petRectCornerY;
  private boolean invColors = false;
  private boolean dragAllowed = false;  
  private boolean updateCanvas = true;  
  
        int mx, my, mxrel, myrel;
        int dragOffsetX = 0;
        int dragOffsetY = 0;
        
  Slider gradientSizeSlider;
  Range gradientDistributionRange;
  Toggle invColorsToggle;

  GradientMap() {
    super();
  }

  void setup(ControlP5 cp5, String name, Group tabgroup) {
    this.cp5 = cp5;
    this.p = cp5.papplet;

    gradientSizeSlider = cp5.addSlider("gradientsize")
      .setPosition(20, 0)
      .setSize(tabgroup.getWidth()-80, 20)
      .setRange(0, 800)
      .plugTo(this, "changeGradientSize")
      .setValue(gradientSize)
      .setSliderMode(Slider.FLEXIBLE)
      .setScrollSensitivity(-0.04)
      .setNumberOfTickMarks(tickMarks)
      .showTickMarks(false)
      .snapToTickMarks(false)
      .setLabel("size")
      .setGroup(tabgroup)
      ;
    styleLabel(gradientSizeSlider, "gradientsize");

    gradientDistributionRange = cp5.addRange("distribution")
      .setBroadcast(false)
      .setPosition(20, 25)
      .setSize(tabgroup.getWidth()-80, 20)
      .setHandleSize(10)
      .setRange(0f, 100f)
      .setRangeValues(0f, 100f)
      .setGroup(tabgroup)
      ;
    styleLabel(gradientDistributionRange, "dist");

    invColorsToggle = cp5.addToggle("gminvColors")
      .setPosition(20, 50)
      .setSize(20, 20)
      .plugTo(this, "invertColors")
      .setLabel("I")
      .setValue(invColors)
      .setGroup(tabgroup)
      ;
    invColorsToggle.getCaptionLabel().setPadding(8, -14);

    canvas = createGraphics(maxw, maxh, JAVA2D);
    gradientCenterX = maxw/2;
    gradientCenterY = maxh/2;
  }

  void draw(PGraphics g) {
    g.pushStyle();
    g.rectMode(CORNER);

    if (updateCanvas) {
      canvas.beginDraw();
      canvas.clip((maxw-ww)/2, (maxh-hh)/2, ww, hh);
      canvas.background(invColors?white:black);
      canvas.ellipseMode(RADIUS);
      canvas.noStroke();

      int radius = (int)gradientSize;
        
      for (int r = radius; r > 0; --r) {
        float distmin = map(gradientDistributionRange.getLowValue(), 0, 100, 0, radius);
        float distmax = map(gradientDistributionRange.getHighValue(), 0, 100, 0, radius);          
        float gamt = map(r, distmin, distmax+0.0001, 0, 1);
        
        color gcol = lerpColor(invColors?black:white, invColors?white:black, gamt);
        canvas.fill(gcol);
        canvas.ellipse(gradientCenterX+dragOffsetX, gradientCenterY+dragOffsetY, r, r);
      }
      canvas.endDraw();
      updateCanvas = false;      
    }

    p.image(canvas, maxRectCornerX, maxRectCornerY );

    //petterrect outline
    g.noFill();
    g.stroke(255);
    g.rect(petRectCornerX, petRectCornerY, ww, hh);
    g.popStyle();
  }

  // --- PETTER-CALLBACK ----------------------------------------------------|

  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles) {
    this.petterw = petterw;
    this.petterh = petterh;
    this.xtiles = xtiles;
    this.ytiles = ytiles;
    float par = float(petterw)/float(petterh);
    float car = float(maxw)/float(maxh);
    if (par > car) { // quer
      this.ww = maxw;
      this.hh = round(float(maxw) / par);
    } else {  //hoch
      this.hh = maxh;
      this.ww = round(float(maxh) * par);
    }
    maxRectCornerX = (p.width-maxw)/2;
    maxRectCornerY = (p.height-maxh)/2;
    petRectCornerX = (p.width-ww)/2;
    petRectCornerY = (p.height-hh)/2;
  }

  boolean getMapPermit(float tilex, float tiley) {
    return true;
  }

  float getMapValue(float tilex, float tiley) {
    float mapValuex = 0f;
    try {
      int absScreenXPos = round(map(tilex, 0, petterw-1, 0, ww-1) +(float(maxw-ww)*0.5));
      int absScreenYPos = round(map(tiley, 0, petterh-1, 0, hh-1) +(float(maxh-hh)*0.5));
      color col;

      try {
        col = canvas.pixels[(absScreenYPos)*maxw +absScreenXPos];
        mapValuex = ((p.red(col)/255f)*0.299f) + ((p.green(col)/255f)*0.587f) + ((p.blue(col)/255f)*0.114f);
      } catch(ArrayIndexOutOfBoundsException e) { return 0f; }
    } catch(Exception e) {} //IndexOutOfBoundsException | NullPointerException
    return mapValuex;
  }

  // --- UI-CALLBACK --------------------------------------------------------|

  void mouseEvent(MouseEvent e) {
    int type = e.getAction();
    switch(type) {
      case processing.event.MouseEvent.WHEEL:
        updateCanvas = true;
        if(!cp5.isMouseOver()) {
          gradientSize = gradientSize + e.getCount();
          gradientSizeSlider.setValue(gradientSize);
        }
        break;
      case processing.event.MouseEvent.PRESS:
        if(!cp5.isMouseOver()) {
          this.dragAllowed = true;
          mx = p.pmouseX;
          my = p.pmouseY;       
        }
        updateCanvas = true;
        break;
      case processing.event.MouseEvent.DRAG:
        if(dragAllowed) {
          dragOffsetX = p.mouseX-mx;
          dragOffsetY = p.mouseY-my;
        }
        updateCanvas = true;
        break;
      case processing.event.MouseEvent.RELEASE:
        gradientCenterX += dragOffsetX;
        gradientCenterY += dragOffsetY;
        dragOffsetX = 0;
        dragOffsetY = 0;
        this.dragAllowed = false;
        updateCanvas = true;
        break;
    }
  }

  void changeGradientSize(int v) {
    gradientSize = v;
    updateCanvas = true;
  }

  void invertColors(boolean flag) {
    invColors = flag;
    updateCanvas = true;
  }
}//GradientMap











// ---------------------------------------------------------------------------
//  EraserMap
// ---------------------------------------------------------------------------

public class EraserMap implements EffectorMap {

  PApplet p;
  ControlP5 cp5;
  PGraphics canvas;

  private int ww, hh, x, y, petterw, petterh, xtiles, ytiles;
  private int maxw = 400;
  private int maxh = 400;
  private int white = color(255, 255, 255, 255);
  private int green = color(0, 255, 0, 255);
  private float brushSize = 10;
  private float maxRectCornerX, maxRectCornerY, petRectCornerX, petRectCornerY;
  private boolean invBrush = false;
  private boolean canvasEmpty = true;

  Slider brushSizeSlider;
  Bang clearBang;
  Toggle invBrushToggle;

  EraserMap() {
    super();
  }

  void setup(ControlP5 cp5, String name, Group tabgroup) {
    this.cp5 = cp5;
    this.p = cp5.papplet;

    brushSizeSlider = cp5.addSlider("emsize")
      .setPosition(20, 0)
      .setSize(tabgroup.getWidth()-80, 20)
      .setRange(1, 150)
      .plugTo(this, "changeBrushSize")
      .setValue(brushSize)
      .setSliderMode(Slider.FLEXIBLE)
      .setScrollSensitivity(0.04)
      .setNumberOfTickMarks(tickMarks)
      .showTickMarks(false)
      .snapToTickMarks(false)
      .setLabel("brushsize")
      .setGroup(tabgroup)
      ;
    styleLabel(brushSizeSlider, "brushsize");

    clearBang = cp5.addBang("clearCanvas")
      .setPosition(20, 25)
      .setSize(20, 20)
      .plugTo(this, "clearCanvas")
      .setLabel("clr")
      .setGroup(tabgroup)
      ;
    clearBang.getCaptionLabel().setPadding(3, -14);
    clearBang.setColorForeground(color(100));

    invBrushToggle = cp5.addToggle("invBrush")
      .setPosition(44, 25)
      .setSize(20, 20)
      .plugTo(this, "invertBrush")
      .setLabel("I")
      .setValue(invBrush)
      .setGroup(tabgroup)
      ;
    invBrushToggle.getCaptionLabel().setPadding(8, -14);

    canvas = createGraphics(maxw, maxh, JAVA2D);
  }

  void draw(PGraphics g) {
    g.pushStyle();
    g.rectMode(CORNER);

    //draw line to canvas
    if (p.mousePressed) {
      canvasEmpty = false;
      canvas.beginDraw();
      canvas.stroke(invBrush?white:green);
      canvas.strokeWeight(brushSize);
      canvas.strokeCap(ROUND);
      if (!cp5.isMouseOver()) {
        canvas.line(p.mouseX-maxRectCornerX, p.mouseY-maxRectCornerY, p.pmouseX-maxRectCornerX, p.pmouseY-maxRectCornerY);
      }
      canvas.endDraw();
    }

    //petterrect bgfill
    g.fill(255);
    g.rect(petRectCornerX, petRectCornerY, ww, hh);

    //draw canvas
    p.image(canvas, maxRectCornerX, maxRectCornerY );

    //brushtip
    g.stroke(0);
    g.strokeWeight(1f);
    g.noFill();
    g.ellipse(p.mouseX, p.mouseY, brushSize, brushSize);

    //petterrect outline
    g.stroke(255);
    g.rect(petRectCornerX, petRectCornerY, ww, hh);

    //draw griddots. dirty...needs tilewidth/height from pettermain
    float tw = (float(ww)/xtiles);
    float tscale = tw/tilewidth;
    float th = tileheight*tscale;
    g.stroke(c1);
    g.rectMode(CENTER);
    for (int i=0; i<xtiles; i++) {
      for (int j=0; j<ytiles; j++) {
        g.rect(i*tw +tw/2 +petRectCornerX, j*th +th/2 +petRectCornerY, 1, 1);
      }
    }

    g.popStyle();
  }

  // --- PETTER-CALLBACK ----------------------------------------------------|

  void updateCanvasBounds(int petterw, int petterh, int xtiles, int ytiles) {
    this.petterw = petterw;
    this.petterh = petterh;
    this.xtiles = xtiles;
    this.ytiles = ytiles;
    float par = float(petterw)/float(petterh);
    float car = float(maxw)/float(maxh);
    if (par > car) { // quer
      this.ww = maxw;
      this.hh = round(float(maxw) / par);
    } else {  //hoch
      this.hh = maxh;
      this.ww = round(float(maxh) * par);
    }
    maxRectCornerX = (p.width-maxw)/2;
    maxRectCornerY = (p.height-maxh)/2;
    petRectCornerX = (p.width-ww)/2;
    petRectCornerY = (p.height-hh)/2;
  }

  boolean getMapPermit(float tilex, float tiley) {
    if(canvasEmpty) {
      return true;
    } else {
    try {
      int absScreenXPos = round(map(tilex, 0, petterw-1, 0, ww-1) +(float(maxw-ww)*0.5));
      int absScreenYPos = round(map(tiley, 0, petterh-1, 0, hh-1) +(float(maxh-hh)*0.5));
      color col;
      try {
        col = canvas.pixels[(absScreenYPos)*maxw +absScreenXPos];
        if (col == color(0, 255, 0)) { //green doesn't get mapped
          return false;
        }
      } catch(ArrayIndexOutOfBoundsException e) { return false; }
    } catch(Exception e) {} //IndexOutOfBoundsException | NullPointerException
    return true;
    }
  }

  float getMapValue(float tilex, float tiley) {
    return 0f;
  }

  // --- UI-CALLBACK --------------------------------------------------------|

  void mouseEvent(MouseEvent e) {
    int type = e.getAction();
    switch(type) {
      case processing.event.MouseEvent.WHEEL:
        brushSizeSlider.setValue(brushSize+e.getCount());
        break;
    }
  }

  void changeBrushSize(int v) {
    brushSize = v;
  }

  void clearCanvas() {
    canvas.clear();
    canvasEmpty = true;
  }

  void invertBrush(boolean flag) {
    invBrush = flag;
  }
}//EraserMap
