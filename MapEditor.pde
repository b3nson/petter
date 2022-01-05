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


class MapEditor extends PApplet {

  PApplet parent;
  private ControlP5 cp5;

  boolean opened = true;
  boolean reset = false;
  boolean mapEditorOpened = false;
  boolean mapEditorCreated = false;
  boolean invertT, invertR, invertS = false;

  int w, h;  
  int petterw, petterh, xtiles, ytiles;
  
  ArrayList<EffectorMap> effectorList;
  EffectorMap traMap;
  EffectorMap rotMap;
  EffectorMap scaMap;
  
  Group toggles;
  Toggle togT, togR, togS, invT, invR, invS;
  Button closeButton;

  public MapEditor(PApplet theParent, int theWidth, int theHeight) {
    super();   
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public void settings() {
    size(w, h, JAVA2D);
  } 
  

  // ---------------------------------------------------------------------------
  //  GUI SETUP
  // ---------------------------------------------------------------------------

  public void setup() {
    cp5 = new ControlP5(this, font);
    
    effectorList = new ArrayList<EffectorMap>();
    addEffectorMap("imgmap", new ImageMap());
    addEffectorMap("noisemap", new PerlinNoiseMap());  
    addEffectorMap("patternmap", new PatternMap());
  
    setupGui();
    updatePetterBounds(pagewidth, pageheight, xtilenum, ytilenum); // set inital values from pettermain
    show();
    smooth();
  }
  
  private void setupGui() {
    toggles = cp5.addGroup("toggles")
                 .setPosition(0,h-40-14)
                 .hideBar()
                 ;
  
    togT = cp5.addToggle("T")
       .setLabel("T")
       .setPosition(20, 0)
       .setSize(26, 26)
       .setValue(false)
       .plugTo(this, "toggleMapUsage")
       .setGroup(toggles);
    togT.getCaptionLabel().setPadding(12,-17);

    invT = cp5.addToggle("invertT")
       .setLabel("I")
       .setPosition(20, 28)
       .setSize(26, 12)
       .setValue(false)
       .setGroup(toggles);
    invT.getCaptionLabel().setPadding(12,-11);

    togR = cp5.addToggle("R")
       .setLabel("R")
       .setPosition(50, 0)
       .setSize(26, 26)
       .setValue(false)
       .plugTo(this, "toggleMapUsage")
       .setGroup(toggles);
    togR.getCaptionLabel().setPadding(12,-17);

    invR = cp5.addToggle("invertR")
       .setLabel("I")
       .setPosition(50, 28)
       .setSize(26, 12)
       .setValue(false)
       .setGroup(toggles);
    invR.getCaptionLabel().setPadding(12,-11);
    
    togS = cp5.addToggle("S")
       .setLabel("S")
       .setPosition(80, 0)
       .setSize(26, 26)
       .setValue(false)
       .plugTo(this, "toggleMapUsage")
       .setGroup(toggles);
    togS.getCaptionLabel().setPadding(12,-17);

    invS = cp5.addToggle("invertS")
       .setLabel("I")
       .setPosition(80, 28)
       .setSize(26, 12)
       .setValue(false)
       .setGroup(toggles);
    invS.getCaptionLabel().setPadding(12,-11);
    
    closeButton = cp5.addButton("CLOSE")
      .setPosition(w-70-20, 14)
      .setSize(70, 26)
      .plugTo(this, "hide")
      .setGroup(toggles);

    //TODO
    //ControllerProperties prop = cp5.getProperties();
    //prop.remove(typeGroup);
  }


  // ---------------------------------------------------------------------------
  //  DRAW
  // ---------------------------------------------------------------------------
    
  void draw() {
    background(50);
    shapeMode(CENTER);
    currentMap().draw(this.g);
  }//draw
  

  // ---------------------------------------------------------------------------
  //  MAP ACTIONS
  // ---------------------------------------------------------------------------

  public boolean traMapActive() {
    return traMap==null?false:true;
  }
  public boolean rotMapActive() {
    return rotMap==null?false:true;
  }
  public boolean scaMapActive() {
    return scaMap==null?false:true;
  }
  
  public float getTraMapValue(float tilex, float tiley) {
    return invertT?1-traMap.getMapValue(tilex, tiley):traMap.getMapValue(tilex, tiley);
  }
  public float getRotMapValue(float tilex, float tiley) {   
    return invertR?1-rotMap.getMapValue(tilex, tiley):rotMap.getMapValue(tilex, tiley);  
  }  
  public float getScaMapValue(float tilex, float tiley) {   
    return invertS?1-scaMap.getMapValue(tilex, tiley):scaMap.getMapValue(tilex, tiley);  
  }

  public void updatePetterBounds(int w, int h, int xtiles, int ytiles) { //pagewidth, pageheight, xtilenum, ytilenum
    this.petterw = w;
    this.petterh = h;
    this.xtiles = xtiles;
    this.ytiles = ytiles;
    currentMap().updateCanvasBounds(petterw, petterh, xtiles, ytiles);
  }
  
  public void toggleMapUsage(ControlEvent theEvent) {
    Controller c = theEvent.getController();
    float val = c.getValue();
    if(c == togT) {
      traMap = (val==0?null:currentMap());
      penner_tra.setVisible(val==0?true:false);
    } else if(c == togR) {
      rotMap = (val==0?null:currentMap());
      penner_rot.setVisible(val==0?true:false);
    } else if(c == togS) {
      scaMap = (val==0?null:currentMap()); 
      penner_sca.setVisible(val==0?true:false);
    }
  }  

  private void addEffectorMap(String mapname, EffectorMap newmap) {
    cp5.getTab("default").remove();
    effectorList.add(newmap);
    int effectorindex = effectorList.size()-1;
      
    cp5.addTab(mapname);
    cp5.getTab(mapname)
       .activateEvent(true)
       .setLabel(mapname)
       .setHeight(22)
       .setWidth(50)
       //.setColorActive(color(50))
       .setId(effectorindex)
       ; 
   
    Group gr = cp5.addGroup("g"+effectorindex)
                  .setPosition(0,40)
                  .setSize(width, height-40)
                  .hideBar()
                  ;
           
    gr.moveTo(mapname);
    newmap.setup(cp5, mapname, gr); 
    
    ControllerList alltabs = cp5.getWindow().getTabs();
    for(int i=1; i<alltabs.size();i++) { //not global tab [0]
      ControllerInterface<Tab> b = (ControllerInterface<Tab>)alltabs.get(i);
      ((Tab)b).setWidth(width/(alltabs.size()-1));
      ((Tab)b).setActive(i==1?true:false);
    }
  }//addEffectorMap


  // ---------------------------------------------------------------------------
  //  MAP UTIL
  // ---------------------------------------------------------------------------
  
  private EffectorMap currentMap() {
    return effectorList.get(currentTab().getId());
  }
  
  private Tab currentTab() {
    return cp5.getWindow().getCurrentTab();
  }
  
  private int currentTabId() {
    return cp5.getWindow().getCurrentTab().getId();
  }

  private void invertMap() {
    if(traMap==currentMap()) invT.toggle();
    if(rotMap==currentMap()) invR.toggle();
    if(scaMap==currentMap()) invS.toggle();
  }
  
  
  // ---------------------------------------------------------------------------
  //  GUI EVENTHANDLING
  // ---------------------------------------------------------------------------

  void controlEvent(ControlEvent theEvent) {
    //println("ctrlevt: "+ theEvent);
    if (theEvent.isTab()) {
      updateToggles();
      currentMap().updateCanvasBounds(petterw, petterh, xtiles, ytiles);
     }
  }


  // ---------------------------------------------------------------------------
  //  GUI ACTIONS
  // ---------------------------------------------------------------------------

  private void showNextTab() {
    int cid = currentTab().getId();
    if(cid < cp5.getWindow().getTabs().size()-2) {
    ControllerInterface<Tab> ct = (ControllerInterface<Tab>)cp5.getWindow().getTabs().get(cid+2); // next + not global[0]
    ((Tab)ct).bringToFront();
    updateToggles();
    currentMap().updateCanvasBounds(petterw, petterh, xtiles, ytiles);
    }
  }
  
  private void showPrefTab() {
    int cid = currentTab().getId();
    if(cid > 0) {
    ControllerInterface<Tab> ct = (ControllerInterface<Tab>)cp5.getWindow().getTabs().get(cid); // -not global[0]
    ((Tab)ct).bringToFront();
    updateToggles();
    currentMap().updateCanvasBounds(petterw, petterh, xtiles, ytiles);
    }
  }
  
  private void updateToggles() {
    toggles.moveTo(currentTab());  
    togT.changeValue(traMap==currentMap()?1f:0f);
    togR.changeValue(rotMap==currentMap()?1f:0f);
    togS.changeValue(scaMap==currentMap()?1f:0f);
  }
  
  public void hide() {
    this.noLoop();
    opened = false;
    surface.setVisible(false); 
  }

  public void show() {
    this.loop();
    frameRate(30);
    opened = true;
    surface.setVisible(true);
    keysDown[lastKey] = false; //reset missing keyRelease
  }

  public void exit() { //on native window-close
    hide();
  }
  
  private void closeAndApply() {
    hide(); 
  }


  // ---------------------------------------------------------------------------
  //  INPUT EVENTS
  // ---------------------------------------------------------------------------

  void keyPressed() {
    if (key == CODED) {
      if (keyCode == UP) {
        petterh += 10;
      } else if (keyCode == DOWN) {
        petterh -= 10;
      } else if (keyCode == LEFT) {
        showPrefTab();
      } else if (keyCode == RIGHT) {
        showNextTab();
      } else { //forward to pettermain
        if (!mapEditorOpened) {
          parent.key=key;
          parent.keyCode=keyCode;
          parent.keyPressed();
        }
      }
    } else {
      if (key == RETURN || key == ENTER) {
        closeAndApply();
      } else if (key == ESC || keyCode==ESC) {
        key=0;
        keyCode=0;
        closeAndApply();
      } else if (key == 'm') {
        hide();
      } else if (key == 't') { 
        togT.toggle();
      } else if(key == 'r') {
        togR.toggle();
      } else if(key == 's') {
        togS.toggle();
      } else if(key == 'i') {
        invertMap();
      } else { //forward to pettermain
        parent.key = key;
        parent.keyCode = keyCode;
        parent.keyPressed();
      }
    }
  }

  void keyReleased() {
    processKey(keyCode, false); //debounce parent
  }
  
  void mouseEntered() {
    currentMap().mouseEntered();
  }
  void mouseExited() {
    currentMap().mouseExited();
  }
}
