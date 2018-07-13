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
  public void reset();
  public void setOffsetX(float ox);
  public void setOffsetY(float oy);
  public void setScaleX(float sx);
  public void setScaleY(float sy);
  public float getOffsetX();
  public float getOffsetY();
  public float getScaleX();
  public float getScaleY();
}


// ---------------------------------------------------------------------------
//  TileSVG
// ---------------------------------------------------------------------------

public class TileSVG extends PShapeSVG implements Tile {

  float scalex = 1f;
  float scaley = 1f;
  float offsetx = 0f;
  float offsety = 0f;

  String filepath = null;


  public TileSVG(String path) {
    super(loadXML(path));
    filepath = path;
    handleLFKN_VDB();
  }


  public void draw(PGraphics g) {
    g.pushMatrix();
    g.translate(offsetx, offsety);    
    g.translate(width/2, height/2);
    g.scale(scalex, scaley);
    g.translate(-width/2, -height/2);
    
    super.draw(g);
    
    g.popMatrix();
  }

  public void reset() {
    scalex = 1f; 
    scaley = 1f; 
    offsetx = 0f;
    offsety = 0f;
  }
  
  public void setOffsetX(float ox) { offsetx = ox; }
  public void setOffsetY(float oy) { offsety = oy; }
  public void setScaleX(float sx) { scalex = sx; }
  public void setScaleY(float sy) { scaley = sy; }
  public float getOffsetX() { return offsetx; }
  public float getOffsetY() { return offsety; }
  public float getScaleX() { return scalex; }
  public float getScaleY() { return scaley; }

  private void handleLFKN_VDB() {
    boolean lfknvdb = false;

    if (split(filepath, ".lafkon.net").length > 1) {
      filepath =  split(filepath, ".pdf")[0] +".svg";
    }
    try {
      int index = this.getChildIndex(this.getChild("disclaimer"));
      this.removeChild(index); // remove disclaimer from LFKN-VDB-svgs
    } 
    catch (ArrayIndexOutOfBoundsException e) { println("CATCH" +e);
    }
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


  public TileShape(PShape s, float w, float h) {
    super();
    this.addChild(s);
    this.width = w;
    this.height = h;
  }


  public void draw(PGraphics g) {
    g.pushMatrix();
    g.translate(offsetx, offsety);    
    g.translate(width/2, height/2);
    g.scale(scalex, scaley);
    g.translate(-width/2, -height/2);
    
    super.draw(g);
    
    g.popMatrix();
  }

  public void reset() {
    scalex = 1f; 
    scaley = 1f; 
    offsetx = 0f;
    offsety = 0f;
  }
  
  public void setOffsetX(float ox) { offsetx = ox; }
  public void setOffsetY(float oy) { offsety = oy; }
  public void setScaleX(float sx) { scalex = sx; }
  public void setScaleY(float sy) { scaley = sy; }
  public float getOffsetX() { return offsetx; }
  public float getOffsetY() { return offsety; }
  public float getScaleX() { return scalex; }
  public float getScaleY() { return scaley; }

}