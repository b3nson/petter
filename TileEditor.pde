
//============================================================================
// TILEEDITOR
//============================================================================


class TileEditor extends PApplet {

  PApplet parent;
  
  private ControlP5 cp5;

  int w, h;

  boolean opened = true;
  boolean preview = true;
  boolean drag = false;
  boolean reset = false;

  int svgindex = -1;
  int svglength = 0;
  int time = -1;
  int TIMEOUT = 300;

  PShapeSVG bot, svg, tmp;
  XML xml;
  String[] viewbox;
  int dragx, dragy, vbx, vby, vbw, vbh;  
  float scalefactor = 1.0;
  ArrayList<PShape> shapelistOrg;
  ArrayList<String> pathlistOrg;
  XML[] xmllistOwn;
  float refx, refy, refw, refh;
  
  Button okButton, cancelButton, nextTileButton, prevTileButton, resetTileButton;
  Toggle previewToggle;
  Textlabel viewboxlabel;

//---------------------------------------------------------------------------------- SETUP
  
  public TileEditor(PApplet theParent, int theWidth, int theHeight) {
    super();   
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }

  public void settings() {
    size(w, h, JAVA2D);
  }

  public void setup() {
    surface.setLocation(10, 10);
    shapeMode(CENTER);
    rectMode(CENTER);

    cp5 = new ControlP5(this);

    previewToggle = cp5.addToggle("preview")
      .setLabel("LIVE PREVIEW")
      .setPosition(w-140, h-10-14)
      .setSize(10, 10)
      .setValue(true)
      .setId(4)
      ;

    controlP5.Label l = previewToggle.getCaptionLabel();
    l.setHeight(10);
    l.getStyle().setPadding(2, 2, 2, 2);
    l.getStyle().setMargin(-15, 0, 0, 14);
    
    okButton = cp5.addButton("OK")
      .setPosition(w-40-10, h-30-10)
      .setSize(40, 30)
      .setId(2)
      ;

    prevTileButton = cp5.addButton("PREV")
      .setLabel("<")
      .setPosition(0, 0)
      .setSize(w/2, 30)
      .setId(0)
      ;
      
    nextTileButton = cp5.addButton("NEXT")
      .setLabel(">")
      .setPosition(w/2+1, 0)
      .setSize(w/2, 30)
      .setId(1)
      ;

    resetTileButton = cp5.addButton("RESET")
      .setLabel("RESET")
      .setPosition(10, h-40)
      .setSize(60, 30)
      .setId(5)
      ;
      
    ControllerProperties prop = cp5.getProperties();
    prop.remove(okButton);
    prop.remove(previewToggle);
    prop.remove(prevTileButton);
    prop.remove(nextTileButton);
    prop.remove(resetTileButton);

    show();
    smooth();
  }//end setup


//---------------------------------------------------------------------------------- DRAW


  void draw() {
    background(50);

    if ( time != -1 ) {
      if (millis() > time+TIMEOUT) {
        time = -1;
        updateSVG();
      }
    }

    if (svg != null) {
      pushMatrix();
      translate(w/2, h/2);

      //viewbox fill
      fill(200, 100);
      noStroke();
      rect(0, 0, svg.width, svg.height);
      
      shape(svg, dragx, dragy);
      
      //viewbox stroke
      noFill();
      stroke(150, 100);
      rect(0, 0, svg.width, svg.height);
      
      //viewbox refsize
      stroke(150, 180);
      rect(0, 0, refw, refh );
      line(-refw/2, -refh/2, refw/2, refh/2 );
      line(refw/2, -refh/2, -refw/2, refh/2 );
      
      popMatrix();
    }
  }//draw


//---------------------------------------------------------------------------------- FUNCTIONS

  public void setTileList(ArrayList<String> plist, ArrayList<PShape> slist) {
    pathlistOrg = plist;
    shapelistOrg = slist;
    xmllistOwn = new XML[shapelistOrg.size()];

    svgindex = 0;
    svglength = slist.size();
    loadXML(svgindex);
  }
  
  public void updateTileList(ArrayList<String> plist, ArrayList<PShape> slist, int mode) {
    pathlistOrg = plist;
    shapelistOrg = slist;
    svglength = pathlistOrg.size();
    
    if(mode == ADDSVG) {
      xmllistOwn = Arrays.copyOf(xmllistOwn, xmllistOwn.length+1);
    } else if(mode == REPLACESVG) {
      svgindex = 0;
      xmllistOwn = new XML[shapelistOrg.size()];
      loadXML(svgindex);
    }
  }
  
  private void resetToOriginal(int index) {
    xmllistOwn[index] = null;
    loadXML(index);
    reset = true;
  }

  private void loadXML(int index) {
    try {
      xml = xmllistOwn[index];
    } catch(IndexOutOfBoundsException e) {
      xml = null;
    }
    
    if(xml == null) {
      xml = loadXML(pathlistOrg.get(index));
      
      try {  //remove lfkn-vdb disclaimer. dirty.
        String s = xml.getChild("path").getString("id");
        if ( s.equals("disclaimer") ) {
          xml.removeChild(xml.getChild("path"));
        }
      } catch (NullPointerException e) {}

      xmllistOwn[index] = xml;
    }

    viewbox = split( xml.getString("viewBox"), ' ');
    if(viewbox == null) {
      String w = xml.getString("width");
      String h = xml.getString("height");
      xml.setString("viewBox", "0 0 " +w +" " +h);
      viewbox = split( xml.getString("viewBox"), ' ');
    }
    if(index == 0) {
      refx = float(split( xml.getString("viewBox"), ' ')[0]);
      refy = float(split( xml.getString("viewBox"), ' ')[1]);
      refw = float(split( xml.getString("viewBox"), ' ')[2]);
      refh = float(split( xml.getString("viewBox"), ' ')[3]);
    }
    
    svg = new PShapeSVG(xml);
    
    scalefactor = (svg.width / int(viewbox[2]) );
    vbx = int(viewbox[0]);
    vby = int(viewbox[1]);
    vbw = int(viewbox[2]);
    vbh = int(viewbox[3]);
  }


  void updateSVG() {
    shapelistOrg.set(svgindex, tmp);
  }


  void updateXML() {
    vbx = int(int(viewbox[0])-(dragx/scalefactor));
    vby = int(int(viewbox[1])-(dragy/scalefactor));
    String vb = (  vbx +" " +vby +" " +vbw +" " +vbh ) ;
    xml.setString("viewBox", vb) ;

    try {
      tmp = new PShapeSVG(xml);
    } 
    catch(ArrayIndexOutOfBoundsException e) {
      e.printStackTrace();
    }
    //println(xml.getString("viewBox") );
  }
  
  
  private void prevTile() {
    int size = pathlistOrg.size();
    svgindex = (svgindex-1)%size;
    if(svgindex == -1) svgindex = size-1;

    loadXML(svgindex);
  }

  private void nextTile() {
    int size = pathlistOrg.size();
    svgindex = (svgindex+1)%size;

    loadXML(svgindex);
  }



//---------------------------------------------------------------------------------- CALLBACK


  public void controlEvent(ControlEvent theEvent) {
    switch(theEvent.getId()) {
      case(0): //PREV
        prevTile();
      break;
      case(1): //NEXT
        nextTile();
      break;
      case(2): //OK
        closeAndApply();
      break;
      case(3): //X
        closeAndCancel();
      break;
      case(4): //PREVIEW
        preview = boolean((int)theEvent.getController().getValue());
      break;
      case(5): //RESETTILE
        resetToOriginal(svgindex);
      break;
    }
  }

  public void hide() {
    this.noLoop();
    opened = false;
    surface.setVisible(false); //win.hide();
  }

  public void show() {
    this.loop();
    opened = true;
    surface.setVisible(true); //win.show();
  }

  private void closeAndApply() {
    hide(); 
    //win.dispatchEvent(new WindowEvent(win, WindowEvent.WINDOW_CLOSING));
  }

  private void closeAndCancel() {
    hide(); 
    //win.dispatchEvent(new WindowEvent(win, WindowEvent.WINDOW_CLOSING));
  }
  
//---------------------------------------------------------------------------------- UIINPUT

  void mousePressed() {
    pmouseX = mouseX;
    pmouseY = mouseY;
  }


  void mouseDragged ( ) {
    drag = true;
    dragx -= pmouseX-mouseX;
    dragy -= pmouseY-mouseY;

    if (preview) {
      updateXML();
      updateSVG();
    }
  }  

  void mouseReleased() {
    if(drag || reset) {
      drag = false;
      reset = false;
      updateXML();
      updateSVG();
      viewbox = split( xml.getString("viewBox"), ' ');
      svg = tmp;
  
      dragx = 0;
      dragy = 0;
    }
  }

  void mouseWheel(MouseEvent event) {
    if (!preview) {
      time = millis();
    }

    float e = event.getAmount();
    vbw += e;
    vbh += e;

    updateXML();
    if (preview) {
      updateSVG();
    }
    //viewbox = split( xml.getString("viewBox"), ' ');
    svg = tmp;
    scalefactor = (svg.width / vbw );
  }


  void keyPressed() {
    if (key == RETURN || key == ENTER) {
      //okButton.trigger();
      closeAndApply();
    } else if (key == ESC || keyCode==ESC) {
      key=0;
      keyCode=0;
      //cancelButton.trigger();
      closeAndCancel();
    }

    if (key == CODED) {
      if (keyCode == LEFT) {
        prevTile();
      } else if (keyCode == RIGHT) {
        nextTile();
      }
    } else {
      if (key == 'p') {
        preview = !preview;
        previewToggle.setState(preview);
      }
      
    }
  }

  void keyTyped() {
    if (keyCode==ESC || key == ESC) { 
      key = 0; 
      keyCode = 0;
    }
  }
}