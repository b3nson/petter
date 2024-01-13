/**
 * Petter - vector-graphic-based pattern generator.
 * http://www.lafkon.net/petter/
 * Copyright (C) 2021 LAFKON/Benjamin Stephan
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


public interface Iterator {
  void setTileGrid(int xnum, int ynum, boolean loopdir);
  boolean hasNext();
  int[] next();
}


// ---------------------------------------------------------------------------
//  Iterator management
// ---------------------------------------------------------------------------

ArrayList<Iterator> iteratorList = new ArrayList<Iterator>();
int iteratorIndex = 0;

void setupIterators() {
  iteratorList.add(new Scanline());
  iteratorList.add(new Snake());
}

void setIterator(int i) {
  iterator = iteratorList.get(i);
}

Iterator getIterator() {
  return iteratorList.get(iteratorIndex);
}

void prevIterator() {
  if(iteratorIndex > 0) {
    iteratorIndex--;
  } else {
    iteratorIndex = iteratorList.size()-1;
  }
  setIterator(iteratorIndex);
}

void nextIterator() {
  if(iteratorIndex+1 < iteratorList.size()) {
    iteratorIndex++;
  } else {
    iteratorIndex = 0;
  }
  setIterator(iteratorIndex);
}




// ---------------------------------------------------------------------------
//  Scanline Iterator (Default)
// ---------------------------------------------------------------------------

public class Scanline implements Iterator {

  private int firstOrderNum;
  private int secondOrderNum;
  private boolean loopdir;
  
  private int tileCountAll;
  private int tileCountCur;
  
  private int firstOrderIndex = 0;
  private int secondOrderIndex = 0;
  private int[] gridPos = {0, 0};
  
  private int firstOrderPos = 0;
  private int secondOrderPos = 0;  
  
  public Scanline() {}
  
  public void setTileGrid(int xnum, int ynum, boolean loopdir) {
    this.firstOrderNum = loopdir?ynum:xnum;
    this.secondOrderNum = loopdir?xnum:ynum;
    this.loopdir = loopdir;
    tileCountAll = firstOrderNum * secondOrderNum;
    tileCountCur = 0;
    firstOrderIndex = 0;
    secondOrderIndex = 0;
  }

   public boolean hasNext() {
      if(tileCountCur < tileCountAll) {
        return true;
      }
    return false;
  }
  
  //SCANLINE x>y or y>x
  public int[] next() { 
    
    tileCountCur++;
    
    if(firstOrderIndex < firstOrderNum) {
      firstOrderPos = firstOrderIndex;
      firstOrderIndex++;
    } else {
      firstOrderIndex = 0;
      firstOrderPos = firstOrderIndex;
      firstOrderIndex++;
      secondOrderIndex++;
    }
    if(secondOrderIndex < secondOrderNum) {
      secondOrderPos = secondOrderIndex;
    } else {
      secondOrderPos = 0;
    }

    gridPos[0] = loopdir?secondOrderPos:firstOrderPos;
    gridPos[1] = loopdir?firstOrderPos:secondOrderPos;
        
    return gridPos;
  }
}



// ---------------------------------------------------------------------------
//  Snake Iterator
// ---------------------------------------------------------------------------

public class Snake implements Iterator {

  private int firstOrderNum;
  private int secondOrderNum;
  private boolean loopdir;
  
  private int tileCountAll;
  private int tileCountCur;
  
  private int firstOrderIndex = 0;
  private int secondOrderIndex = 0;
  private int[] gridPos = {0, 0};
  
  private int firstOrderPos = 0;
  private int secondOrderPos = 0;  
  
  private boolean forwardDir = true;
  
  public Snake() {}
  
  public void setTileGrid(int xnum, int ynum, boolean loopdir) {
    this.firstOrderNum = loopdir?ynum:xnum;
    this.secondOrderNum = loopdir?xnum:ynum;
    this.loopdir = loopdir;
    tileCountAll = firstOrderNum * secondOrderNum;
    tileCountCur = 0;
    firstOrderIndex = 0;
    secondOrderIndex = 0;
  }
  
  public boolean hasNext() {
      if(tileCountCur < tileCountAll) {
        return true;
      }
    return false;
  }
  
  //SNAKE x>y or y>x
  public int[] next() { 
    
    tileCountCur++;    
    forwardDir = (secondOrderIndex % 2) == 0;
    
    if(firstOrderIndex < firstOrderNum && firstOrderIndex >= 0) {
      firstOrderPos = firstOrderIndex;
      firstOrderIndex += forwardDir?1:-1; //++ or --
    } else {
      firstOrderIndex = !forwardDir?0:firstOrderNum-1;
      firstOrderPos = firstOrderIndex;
      firstOrderIndex += !forwardDir?1:-1; //++ or --
      secondOrderIndex++;
    }
    if(secondOrderIndex < secondOrderNum) {
      secondOrderPos = secondOrderIndex;
    } else {
      secondOrderPos = 0;
    }

    gridPos[0] = loopdir?secondOrderPos:firstOrderPos;
    gridPos[1] = loopdir?firstOrderPos:secondOrderPos;
        
    return gridPos;
  }
}
