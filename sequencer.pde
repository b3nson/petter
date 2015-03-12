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
  endValuesRegistered = true;
  animSetOutButton.setColorBackground(color(255, 0, 0));
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
      if(export) {
        exportCurrentRun = true; 
        exportCurrentFrame = true;
        generateName();
        subfolder = name +"_" +frames +"f/";
      }
    }
  } else {
    stopSequencer();
    showOutValues();
  }
}

void stopSequencer() {
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
  }
}

void showOutValues() {
  if(endValuesRegistered) {
    for (int i = 0; i < animctrls.size(); i++) {
      float to = keyframeValues[i][1];
      animctrls.get(i).setValue(to);
      animctrls.get(i).setColorForeground(color(50));
    }
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
        //println(animctrls.get(i).getLabel() +"ANIM from: " +from +" to: " +to +"=== " +curval);
        }
      }
    }
    fcount++;
  } else {
    stopSequencer();
  }
}
