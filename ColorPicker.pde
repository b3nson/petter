import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.Frame;
import java.awt.BorderLayout;

public class ColorPicker extends PApplet {

  final Frame win;
  PApplet parent;

  private ControlP5 cp5;

  int w, h;

  float hue = 0;
  float sat = 0;
  float bri = 0;

  color startCol;  
  color curCol;
  Boolean preview = true;
  
  ColorSlider2DView satpick;
  ColorSlider1DView huepick;

  String name;
  Textlabel rgbValueLabel, hsbValueLabel, hexValueLabel;
  Slider2D s2D;
  Slider s1D;
  Button okButton, cancelButton;
  Toggle previewToggle;

  //public ColorPicker(PApplet theParent, String theName, int theWidth, int theHeight) {
  //  this(theParent, theName, theWidth, theHeight, #AE57B4);
  //}

  public ColorPicker(PApplet theParent, String theName, int theWidth, int theHeight, int col) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
    startCol = col;
    name = theName;

    win = new Frame(theName);
    win.add(this);
    this.init();
    win.setTitle(theName);
    win.setSize(this.w, this.h);
    win.setLocationRelativeTo(null);    
    //win.setLocation(frame.getLocation().x, frame.getLocation().y);
    //win.setUndecorated(true);
    win.setResizable(true);
    win.setVisible(true);
  }  

  void setup() {    
    win.addWindowListener(new WindowAdapter() {
      @Override
        public void windowClosing(WindowEvent windowEvent) { 
        curCol=startCol;
        hide();
      }
    }
    );    

    size(w, h);
    colorMode(HSB);
    frameRate(25);

    cp5 = new ControlP5(this);
    satpick = new ColorSlider2DView(this);
    huepick = new ColorSlider1DView(this);

    s2D = cp5.addSlider2D("s2D")
      .setPosition(10, 10)
        .setSize(255, 255)
          //.setArrayValue(new float[] {80, 50})
          .setColorBackground(0) 
            .setMaxX(255)
              .setMaxY(0)
                .setMinX(0)
                  .setMinY(255)
                    .setId(0)
                      .setView(satpick)
                        //.disableCrosshair()
                        ;
    //s2D.plugTo(parent, "satbri");
    s2D.getCaptionLabel().hide();
    s2D.getValueLabel().hide();

    s1D = cp5.addSlider("s1D")
      .setPosition(270, 10)
        .setSize(20, 255)
          .setRange(255, 0)
            .setValue(128)
              .setSliderMode(Slider.FLEXIBLE)
                .setHandleSize(1) 
                  .setId(1)
                    .setScrollSensitivity(0.0392) 
                      .setView(huepick)
                        ;
    //s1D.plugTo(parent, "hue");
    s1D.getCaptionLabel().hide();
    s1D.getValueLabel().hide();


    rgbValueLabel = cp5.addTextlabel("RGB" )
      .setPosition(300, 104)
        .setText("RGB")
          ;   

    hsbValueLabel = cp5.addTextlabel("HSB" )
      .setPosition(300, 140)
        .setText("HSB")
          ;   

    hexValueLabel = cp5.addTextlabel("HEX" )
      .setPosition(300, 176)
        .setText("HEX")
          ;       

    previewToggle = cp5.addToggle("preview")
     .setLabel("preview")
     .setPosition(302, 196)
     .setSize(10, 10)
     .setValue(true)
      .setId(4)
     ;
     
    okButton = cp5.addButton("OK")
      .setPosition(300, 236)
        .setSize(40, 30)
          .setId(2)
            .plugTo(parent, "open")
              ;
    cancelButton = cp5.addButton("X")
      .setPosition(342, 236)
        .setSize(18, 30)
          .setId(3)
            ;

    hue = hue(startCol);
    sat = saturation(startCol);
    bri = brightness(startCol)-255; 

    s1D.setValue(hue);
    s2D.setArrayValue(new float[] {sat, bri});

    smooth();
  } //end setup


  void draw() {
    colorMode(HSB);
    background(50);

    fill(curCol);
    rect(300, 10, 60, 80);

    int xpos = (int)s1D.getPosition().x;
    int ypos = (int)s1D.getPosition().y;

    loadPixels();
    for ( int j = 0; j < 255; j++ ) {
      for ( int i = 0; i < 20; i++ ) {   
        set(  i+xpos, j+ypos, color( j, 255, 255 ) );
      }
    }


    xpos = (int)s2D.getPosition().x;
    ypos = (int)s2D.getPosition().y;

    loadPixels();
    for ( int j = 0; j < 255; j++ ) { 
      for ( int i = 0; i < 255; i++ ) {
        set(  j+xpos, i+ypos, color( hue, j, 255 - i ) );
      }
    }
    colorMode(RGB);
  }

  public void hide() {
    noLoop();
    win.hide();
  }

  public void show() {
    loop();
    win.show();
    updatePreviewColor();
  }

  
  void updatePreviewColor() {
    colorMode(HSB);
    curCol =  color(hue, sat, bri);
    rgbValueLabel.setText("R " +(int)red(curCol) +"\nG " +(int)green(curCol) +"\nB " +(int)blue(curCol));
    hsbValueLabel.setText("H " +(int)hue(curCol) +"\nS " +(int)saturation(curCol) +"\nB " +(int)brightness(curCol));
    hexValueLabel.setText(hex(curCol, 6));
    colorMode(RGB);
  }

  public color getColorRGB() {
    //colorMode(RGB);
    if(preview) {
      return color(red(curCol), green(curCol), blue(curCol));
    } else {
      return color(red(startCol), green(startCol), blue(startCol));
    }
  }
  public color getColorHSB() {
    //colorMode(HSB);
    if(preview) {    
      return color(hue(curCol), saturation(curCol), brightness(curCol));
    } else {
      return color(hue(startCol), saturation(startCol), brightness(startCol));
    }
  }

  public void controlEvent(ControlEvent theEvent) {
    switch(theEvent.getId()) {
      case(0): //sat-bri
        sat = (theEvent.getController().getArrayValue())[0];
        bri = (theEvent.getController().getArrayValue())[1];
        updatePreviewColor();
      break;
      case(1): //hue
        hue = (theEvent.getController().getValue());
        updatePreviewColor();
      break;
      case(2): //OK
        startCol=curCol;
        win.dispatchEvent(new WindowEvent(win, WindowEvent.WINDOW_CLOSING));
      break;
      case(3): //X
        curCol=startCol;
        win.dispatchEvent(new WindowEvent(win, WindowEvent.WINDOW_CLOSING));
      break;
      case(4): //PREVIEW
       preview = boolean((int)theEvent.getController().getValue());
      break;
    }
  }

  void keyPressed() {
    if (key == RETURN || key == ENTER) {
      okButton.trigger();
    } else if (key == ESC || keyCode==ESC) {
      key=0;
      keyCode=0;
      cancelButton.trigger();
    }
  }

  void keyTyped() {
    if (keyCode==ESC || key == ESC) { 
      key = 0; 
      keyCode = 0;
    }
  }

  void mouseWheel(MouseEvent event) {
    float e = event.getAmount();
    cp5.setMouseWheelRotation((int)e);
  }
}



//==========================================================================
//== Custom SliderView to prevent drawing of controller-background =========
//==========================================================================

class ColorSlider2DView implements ControllerView<Slider2D> {
  PApplet theApplet;

  public ColorSlider2DView(PApplet a) {
    theApplet = a;
  }
  
  public void display(PApplet theAppletx, Slider2D theController) {

    theApplet.noStroke();
    theApplet.noFill();

    //                        if (theController.isInside()) {
    //                                theApplet.fill(theController.getColor().getForeground());
    //                        } else {
    //                                theApplet.fill(theController.getColor().getBackground());
    //                        }

    //theApplet.fill(theController.getColor().getBackground());
    theApplet.rect(0, 0, getWidth(), getHeight());

    if (theController.isCrosshairs) {
      if (theController.isInside()) {
        theApplet.fill(theController.getColor().getBackground());
      } else {
        theApplet.fill(theController.getColor().getForeground());
      }
      theApplet.rect(0, (int) (theController.getCursorY() + theController.getCursorHeight() / 2), (int) theController.getWidth(), 1);
      theApplet.rect((int) (theController.getCursorX() + theController.getCursorWidth() / 2), 0, 1, (int) theController.getHeight());
    }

    theApplet.fill(theController.getColor().getActive());
    theApplet.rect((int) theController.getCursorX(), (int) theController.getCursorY(), (int) theController.getCursorWidth(), (int) theController.getCursorHeight());

    theController.getCaptionLabel().draw(theApplet, 0, 0, theController);
    theController.getValueLabel().draw(theApplet, 0, 0, theController);
  }
}


class ColorSlider1DView implements ControllerView<Slider> {

  PApplet theApplet;

  public ColorSlider1DView(PApplet a) {
    theApplet = a;
  }

  //                Slider1DViewColor() {
  //                        //_myCaptionLabel.align(LEFT, BOTTOM_OUTSIDE).setPadding(0, Label.paddingY);
  //                        //_myValueLabel.set("" + adjustValue(getValue())).align(RIGHT_OUTSIDE, TOP);
  //                }
  //
  //                void setSnapValue() {
  //                        float n = PApplet.round(PApplet.map(_myValuePosition, 0, getHeight(), 0, _myTickMarks.size() - 1));
  //                        _myValue = PApplet.map(n, 0, _myTickMarks.size() - 1, _myMin, _myMax);
  //                }
  //
  //                void updateUnit() {
  //                        _myUnit = (_myMax - _myMin) / (height - _myHandleSize);
  //                }
  //
  //                void update() {
  //                        float f = _myMin + (-(_myControlWindow.mouseY - (_myParent.getAbsolutePosition().y + position.y) - height)) * _myUnit;
  //                        setValue(PApplet.map(f, 0, 1, _myMinReal, _myMaxReal));
  //                }
  //
  //                void updateInternalEvents(PApplet theApplet) {
  //                        float f = _myMin + (-(_myControlWindow.mouseY - (_myParent.getAbsolutePosition().y + position.y) - height)) * _myUnit;
  //                        setValue(PApplet.map(f, 0, 1, _myMinReal, _myMaxReal));
  //                }


  public void display(PApplet theAppletx, Slider theController) {
    // theApplet.fill(theController.getColor().getBackground());
    theApplet.noStroke();
    //if ((theController.getColor().getBackground() >> 24 & 0xff) > 0) {
      //theApplet.rect(0, 0, theController.getWidth(), theController.getHeight());
    //}

    theApplet.fill(theController.isInside() ? theController.getColor().getActive() : theController.getColor().getForeground());
    theApplet.rect(0, theController.getHeight() - theController.getValuePosition() - theController.getHandleSize(), theController.getWidth(), theController.getHandleSize());

    if (theController.getSliderMode() == controlP5.Slider.FLEXIBLE) {
      //theApplet.rect(0, theController.getHeight(), theController.getWidth(), -theController.getValuePosition());
    } else {
      //if (theController.isShowTickMarks) {
      //        theApplet.triangle(theController.getWidth(), theController.getHeight() - theController.getValuePosition(), theController.getWidth(), theController.getHeight() - theController.getValuePosition() - theController.getHandleSize(), 0, theController.getHeight() - theController.getValuePosition()
      //                       - theController.getHandleSize() / 2);
      //} else {
      //theApplet.rect(0, theController.getHeight() - theController.getValuePosition() - theController.getHandleSize(), theController.getWidth(), theController.getHandleSize());
      //}
    }

    if (theController.isLabelVisible()) {
      theController.getCaptionLabel().draw(theApplet, 0, 0, theController);
      theApplet.pushMatrix();
      //theApplet.translate(0, (int) PApplet.map(_myValue, _myMax, _myMin, 0, getHeight() - _myValueLabel.getHeight()));
      theController.getValueLabel().draw(theApplet, 0, 0, theController);
      theApplet.popMatrix();
    }

    //                        if (isShowTickMarks) {
    //                                theApplet.pushMatrix();
    //                                theApplet.pushStyle();
    //                                theApplet.translate(-4, (getSliderMode() == FIX) ? 0 : getHandleSize() / 2);
    //                                theApplet.fill(_myColorTickMark);
    //                                float x = (getHeight() - ((getSliderMode() == FIX) ? 0 : getHandleSize())) / (getTickMarks().size() - 1);
    //                                for (TickMark tm : getTickMarks()) {
    //                                        tm.draw(theApplet, getDirection());
    //                                        theApplet.translate(0, x);
    //                                }
    //                                theApplet.popStyle();
    //                                theApplet.popMatrix();
    //                        }
  }
}
