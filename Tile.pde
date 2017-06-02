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


public class Tile extends PShapeSVG {

  float scalex = 1f;
  float scaley = 1f;
  float offsetx = 0f;
  float offsety = 0f;

  String filepath = null;


  public Tile(String path) {
    super(loadXML(path));
    filepath = path;
    removeVdbDisclaimer();
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

  private void removeVdbDisclaimer() {
    //----------------------VDB
    boolean lfknvdb = false;

    if (split(filepath, ".lafkon.net").length > 1) {
      filepath =  split(filepath, ".pdf")[0] +".svg";
      lfknvdb = true;
    } else if (split(filepath, "LAFKON_").length > 1) { 
      lfknvdb = true;
    }

    if (lfknvdb) {
      try {
        int index = this.getChildIndex(this.getChild("disclaimer"));
        this.removeChild(index); // remove disclaimer from LFKN-VDB-svgs
      } 
      catch (ArrayIndexOutOfBoundsException e) {
      }
    }
  }


}