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


public interface Tile {  
  public void draw(PGraphics g);
  public void resetTransform();
  public Tile getOrigin();
  public void setOffsetX(float ox);
  public void setOffsetY(float oy);
  public void setScaleX(float sx);
  public void setScaleY(float sy);
  public void setRotation(float ro);
  public float getOffsetX();
  public float getOffsetY();
  public float getScaleX();
  public float getScaleY();
  public float getRotation();
  public float getWidth();
  public float getHeight();
  public float[] getTransformParams();
  public void setTransformParams(float[] params);
  public void enableGlobalStyle();
  public void disableGlobalStyle();
  public void useGlobalStyle(boolean use);
  public void toggleUseGlobalStyle();
  public boolean getUseGlobalStyle();
  public void setExplodable(boolean flag);
  public boolean isExplodable();
}


// ---------------------------------------------------------------------------
//  TileSVG
// ---------------------------------------------------------------------------

public class TileSVG extends PShapeSVG implements Tile {

  float scalex = 1f;
  float scaley = 1f;
  float offsetx = 0f;
  float offsety = 0f;
  float rotation = 0f;

  boolean useGlobalStyle = true;
  boolean explodable = true;
  Tile origin = null;
  String filepath = null;

  public TileSVG(String path) {
    super(loadXML(path));
    filepath = path;
    handleLFKN_VDB();
    if(globalStyle) enableGlobalStyle();
  }

  public void draw(PGraphics g) {
    try {
      g.pushMatrix();
      g.translate(offsetx, offsety);    
      g.translate(width/2, height/2);
      g.scale(scalex, scaley);
      g.rotate(rotation);
      g.translate(-width/2, -height/2);
      g.pushStyle();
      setDrawStyle(exportCurrentFrame?pdf:g);
      super.draw(g);
      g.popStyle();
      g.popMatrix();
    } catch(Exception e) { 
      //e.printStackTrace(); 
    }
  }

  private void setDrawStyle(PGraphics g) {
    if(globalStyle && useGlobalStyle) {
      if (customStroke) {
        g.stroke(strokecolor[0]);
        g.strokeWeight(customStrokeWeight); //setAbsoluteStrokeWeight
        if(!strokeMode) {                   //setRelativeStrokeWeight
          if(tileEditor == null || !tileEditor.getG().equals(g)) { //dirty! if not tileeditor drawing
            float relsw = ((ease(SCA, abscount, 1.0, relScale, tilecount))*(absScale)*(tilescale)*((Tile)s).getScaleX());
            if (relsw != 0f) { relsw = abs(customStrokeWeight*(1/relsw)); }
            g.strokeWeight(relsw);
          }
        }
      } else { g.noStroke(); }
      if (customFill) {
        g.fill(shapecolor[0]);
      } else {
        g.noFill();
      }
      g.strokeJoin(joinmode);
      g.strokeCap(capmode);
    }
  }

  public void resetTransform() {
    scalex = 1f; 
    scaley = 1f; 
    offsetx = 0f;
    offsety = 0f;
    rotation = 0f;
  }
  
  public void enableGlobalStyle() { 
    if(useGlobalStyle) {
      this.disableStyle(); 
      super.disableStyle();
    }
  }
  
  public void disableGlobalStyle() { 
    if(useGlobalStyle) {
      this.enableStyle(); 
      super.enableStyle();
    }
  }
  
  public void useGlobalStyle(boolean use) { 
    this.useGlobalStyle = use; 
    if(use) {
      if(globalStyle) {
        this.disableStyle(); 
        super.disableStyle();
      }
    } else {
      if(globalStyle) {
        this.enableStyle(); 
        super.enableStyle();
      }
    }
  }
  
  public void toggleUseGlobalStyle() { 
    useGlobalStyle(!useGlobalStyle); 
  }
  
  public Tile getOrigin() { return null; }
  public void setOffsetX(float ox) { offsetx = ox; }
  public void setOffsetY(float oy) { offsety = oy; }
  public void setScaleX(float sx) { scalex = sx; }
  public void setScaleY(float sy) { scaley = sy; }
  public void setRotation(float ro) { rotation = ro; }
  public float getOffsetX() { return offsetx; }
  public float getOffsetY() { return offsety; }
  public float getScaleX() { return scalex; }
  public float getScaleY() { return scaley; }
  public float getRotation() { return rotation; }
  public boolean getUseGlobalStyle() { return useGlobalStyle; }
  public void setExplodable(boolean flag) { explodable = flag; }
  public boolean isExplodable() { return explodable; }
  
  public float[] getTransformParams() {
    float[] params = {offsetx, offsety, scalex, scaley, rotation};
    return params;
  }
  
  public void setTransformParams(float[] params) {
    if(params.length == 5) {
      offsetx = params[0];
      offsety = params[1];
      scalex = params[2];
      scaley = params[3];
      rotation = params[4];
    }
  }

  private void handleLFKN_VDB() {
    if (split(filepath, ".lafkon.net").length > 1) {
      filepath =  split(filepath, ".pdf")[0] +".svg";
    }
    try {
      int index = this.getChildIndex(this.getChild("disclaimer"));
      this.removeChild(index); // remove disclaimer from LFKN-VDB-svgs
    } 
    catch (ArrayIndexOutOfBoundsException e) {}
  }
}


// ---------------------------------------------------------------------------
//  TileShape
// ---------------------------------------------------------------------------

public class TileShape extends PShape implements Tile {

  float scalex = 1f;
  float scaley = 1f;
  float offsetx = 0f;
  float offsety = 0f;
  float rotation = 0f;

  boolean useGlobalStyle = true;
  boolean explodable = true;
  Tile origin = null;

  public TileShape(PShape s, float w, float h) {
    super();
    this.addChild(s);
    this.width = w;
    this.height = h;
    if(globalStyle) enableGlobalStyle();
  }

  public TileShape(PShape s, float w, float h, Tile origin) {
    this(s, w, h);
    this.origin = origin;
    setOffsetX(origin.getOffsetX());
    setOffsetY(origin.getOffsetY());
    setScaleX(origin.getScaleX());
    setScaleY(origin.getScaleY());
    setRotation(origin.getRotation());
  }

  public void draw(PGraphics g) {
    try {
      g.pushMatrix();
      g.translate(offsetx, offsety);    
      g.translate(width/2, height/2);
      g.scale(scalex, scaley);
      g.rotate(rotation);
      g.translate(-width/2, -height/2);
      g.pushStyle();
      setDrawStyle(exportCurrentFrame?pdf:g);
      super.draw(g);
      g.popStyle();
      g.popMatrix();
    } catch(Exception e) { 
      //e.printStackTrace(); 
    }
  }

  private void setDrawStyle(PGraphics g) {
    if(globalStyle && useGlobalStyle) {
      if (customStroke) {
        g.stroke(strokecolor[0]);
        g.strokeWeight(customStrokeWeight); //setAbsoluteStrokeWeight
        if(!strokeMode) {                   //setRelativeStrokeWeight
          if(tileEditor == null || !tileEditor.getG().equals(g)) { //dirty! if not tileeditor drawing
            float relsw = ((ease(SCA, abscount, 1.0, relScale, tilecount))*(absScale)*(tilescale)*((Tile)s).getScaleX());
            if (relsw != 0f) { relsw = abs(customStrokeWeight*(1/relsw)); }
            g.strokeWeight(relsw);
          }
        }
      } else { g.noStroke(); }
      if (customFill) {
        g.fill(shapecolor[0]);
      } else {
        g.noFill();
      }
      g.strokeJoin(joinmode);
      g.strokeCap(capmode);
    }
  }

  public void resetTransform() {
    scalex = 1f; 
    scaley = 1f; 
    offsetx = 0f;
    offsety = 0f;
    rotation = 0f;
  }
  
  public void enableGlobalStyle() { 
    if(useGlobalStyle) {
      this.disableStyle(); 
      super.disableStyle();
    }
  }
  
  public void disableGlobalStyle() { 
    if(useGlobalStyle) {
      this.enableStyle(); 
      super.enableStyle();
    }
  }
  
  public void useGlobalStyle(boolean use) { 
    this.useGlobalStyle = use; 
    if(use) {
      if(globalStyle) {
        this.disableStyle(); 
        super.disableStyle();
      }
    } else {
      if(globalStyle) {
        this.enableStyle(); 
       super.enableStyle();
      }
    }
  }
  
  public void toggleUseGlobalStyle() { 
    useGlobalStyle(!useGlobalStyle); 
  }
  
  public Tile getOrigin() { return origin; }
  public void setOffsetX(float ox) { offsetx = ox; }
  public void setOffsetY(float oy) { offsety = oy; }
  public void setScaleX(float sx) { scalex = sx; }
  public void setScaleY(float sy) { scaley = sy; }
  public void setRotation(float ro) { rotation = ro; }
  public float getOffsetX() { return offsetx; }
  public float getOffsetY() { return offsety; }
  public float getScaleX() { return scalex; }
  public float getScaleY() { return scaley; }
  public float getRotation() { return rotation; }
  public boolean getUseGlobalStyle() { return useGlobalStyle; }
  public void setExplodable(boolean flag) { explodable = flag; }
  public boolean isExplodable() { return explodable; }
  
  public float[] getTransformParams() {
    float[] params = {offsetx, offsety, scalex, scaley, rotation};
    return params;
  }
  
  public void setTransformParams(float[] params) {
    if(params.length == 5) {
      offsetx = params[0];
      offsety = params[1];
      scalex = params[2];
      scaley = params[3];
      rotation = params[4];
    }
  }

}
