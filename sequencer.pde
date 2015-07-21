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
 
ArrayList<Slider> animctrls = new ArrayList<Slider>();
float[][] keyframeValues;
color[][] colorValues = new color[3][2];

int frames = 25;
int fcount = 0;
String seqname = "";
boolean startValuesRegistered = false;
boolean endValuesRegistered = false;
boolean exportCurrentRun = false;


void registerForAnimation(Slider s) {
  animctrls.add(s);
}

void registerAnimStartValues() {
  if(!startValuesRegistered && !endValuesRegistered) {
    keyframeValues = new float[animctrls.size()][2]; 
  }
  for (int i = 0; i < animctrls.size(); i++) {
    Slider s = animctrls.get(i);
    keyframeValues[i][0] = s.getValue();
  }
  registerColorStartValues();
  startValuesRegistered = true;
  animSetInButton.setColorBackground(color(255, 0, 0));
}

void registerAnimEndValues() {
  if(!startValuesRegistered && !endValuesRegistered) {
    keyframeValues = new float[animctrls.size()][2]; 
  }
  for (int i = 0; i < animctrls.size(); i++) {
    Slider s = animctrls.get(i);
    keyframeValues[i][1] = s.getValue();
  }
  registerColorEndValues();
  endValuesRegistered = true;
  animSetOutButton.setColorBackground(color(255, 0, 0));
}

void registerColorStartValues() {
  colorValues[0][0] = bgcolor[0];
  colorValues[1][0] = strokecolor[0];
  colorValues[2][0] = shapecolor[0];  
}

void registerColorEndValues() {
  colorValues[0][1] = bgcolor[0];
  colorValues[1][1] = strokecolor[0];
  colorValues[2][1] = shapecolor[0];  
}

void deleteRegisteredValues() {
  if(!sequencing) {
    keyframeValues = null;
    startValuesRegistered = false;
    endValuesRegistered = false;
    animSetInButton.setColorBackground(color(100));
    animSetOutButton.setColorBackground(color(100));
  }
}

void startSequencer(boolean export) {
  if(!sequencing) {
    if(startValuesRegistered && endValuesRegistered) {
      sequencing = true;
      mapIndex = 0;
      if(export) {
        exportCurrentRun = true; 
        exportCurrentFrame = true;
        generateName();
        generateTimestamp();
        subfolder = timestamp +"_" +frames +"f" +"_" +name+"/";
        showInValues();
        saveSettings(timestamp +"_" +"ANIMIN" +"_" +name);
      }
    }
  } else {
    stopSequencer();
    showOutValues();
  }
}

void stopSequencer() {
  if(exportCurrentRun) {
    saveSettings(timestamp +"_" +"ANIMOUT" +"_" +name);
  }
  exportCurrentRun = false;
  sequencing = false;
  exportCurrentFrame = false;
  seqname = "";
  subfolder = "";
  fcount = 0;  
}

void showInValues() {
  if(startValuesRegistered) {
    for (int i = 0; i < animctrls.size(); i++) {
      float from = keyframeValues[i][0];
      animctrls.get(i).setValue(from);
    }
    //manual color-assignement. dirty hack.
    bgcolor[0] = colorValues[0][0];
    strokecolor[0] = colorValues[1][0];
    shapecolor[0] = colorValues[2][0];
  }
}

void showOutValues() {
  if(endValuesRegistered) {
    for (int i = 0; i < animctrls.size(); i++) {
      float to = keyframeValues[i][1];
      animctrls.get(i).setValue(to);
      animctrls.get(i).setColorForeground(color(50));
    }
    //manual color-assignement. dirty hack.
    bgcolor[0] = colorValues[0][1];
    strokecolor[0] = colorValues[1][1];
    shapecolor[0] = colorValues[2][1];
  }
}

void animate() {
  if(guiExportNow) {
    fcount--;
  }
  if(sequencing && fcount < frames) {
    if(exportCurrentRun) {
      exportCurrentFrame = true;
      seqname = "-" +nf(fcount, 4);
    }
    
    specImgMapFrame(fcount);
    
    for (int i = 0; i < animctrls.size(); i++) {
      float from = keyframeValues[i][0];
      float to =   keyframeValues[i][1];
      if(from != to) {
        float curval = ease(ANM, fcount, from, to-from, frames-1);
        animctrls.get(i).setValue(curval);
        if(fcount == 1) {
          animctrls.get(i).setColorForeground(color(255, 0, 0));
        } else if(fcount == frames-1) {
          animctrls.get(i).setColorForeground(color(50));
        }
      }
    }
    //manual color-assignement. dirty hack.
    float curval = ease(ANM, fcount, 0f, 1f, frames-1);
    bgcolor[0] = lerpColor(colorValues[0][0], colorValues[0][1], curval);
    strokecolor[0] = lerpColor(colorValues[1][0], colorValues[1][1], curval);
    shapecolor[0] = lerpColor(colorValues[2][0], colorValues[2][1], curval);
    
    fcount++;
  } else {
    stopSequencer();
  }
}
