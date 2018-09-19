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

package net.lafkon.petter;

import controlP5.Button;
import controlP5.ControlEvent;
import controlP5.ControlP5;
import controlP5.ControllerProperties;
import controlP5.ControllerView;
import controlP5.Slider;
import controlP5.Slider2D;
import controlP5.Textlabel;
import controlP5.Toggle;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.MouseEvent;

import static net.lafkon.petter.Petter.undo;

public class ColorPicker extends PApplet {

	PApplet parent;
	private ControlP5 cp5;

	private int w = 380;
	private int h = 285;

	private float hue = 0;
	private float sat = 0;
	private float bri = 0;

	private int startCol;
	private int curCol;
	private int[] srccol;

	private String name;

	private boolean opened = true;
	private boolean preview = true;
	private boolean undoable = true;

	private ColorSlider2DView satpick;
	private ColorSlider1DView huepick;
	private Slider2D s2D;
	private Slider s1D;
	private Textlabel rgbValueLabel, hsbValueLabel, hexValueLabel;
	private Button okButton, cancelButton;
	private Toggle previewToggle;

	public ColorPicker(PApplet theParent, String theName, int theWidth, int theHeight, int[] col) {
		parent = theParent;
		// w = theWidth;
		// h = theHeight;
		startCol = col[0];
		curCol = col[0];
		srccol = col;
		name = theName;
	}
	// using a color-array here, to set color-value of mainapp directly (like pass-by-reference in C/C++)

	// ---------------------------------------------------------------------------
	// SETUP
	// ---------------------------------------------------------------------------

	public void settings() {
		size(w, h, JAVA2D);
	}

	public void setup() {
		surface.setTitle(name);
		colorMode(HSB);
		frameRate(25);

		cp5 = new ControlP5(this);
		satpick = new ColorSlider2DView(this);
		huepick = new ColorSlider1DView(this);

		s2D = cp5.addSlider2D("s2D").setPosition(10, 10).setSize(255, 255).setColorBackground(0).setMaxX(255).setMaxY(0)
				.setMinX(0).setMinY(255).setId(0).setView(satpick)
		// .disableCrosshair()
		;
		s2D.getCaptionLabel().hide();
		s2D.getValueLabel().hide();

		s1D = cp5.addSlider("s1D").setPosition(270, 10).setSize(20, 255).setRange(255, 0).setValue(128)
				.setSliderMode(Slider.FLEXIBLE).setHandleSize(1).setId(1).setScrollSensitivity(0.0392f)
				.setView(huepick);
		s1D.getCaptionLabel().hide();
		s1D.getValueLabel().hide();

		rgbValueLabel = cp5.addTextlabel("RGB").setPosition(300, 104).setText("RGB");

		hsbValueLabel = cp5.addTextlabel("HSB").setPosition(300, 140).setText("HSB");

		hexValueLabel = cp5.addTextlabel("HEX").setPosition(300, 176).setText("HEX");

		previewToggle = cp5.addToggle("preview").setLabel("preview").setPosition(302, 196).setSize(10, 10)
				.setValue(true).setId(4);

		okButton = cp5.addButton("OK").setPosition(300, 236).setSize(40, 30).setId(2);
		cancelButton = cp5.addButton("CANCEL").setLabel("X").setPosition(342, 236).setSize(18, 30).setId(3);

		ControllerProperties prop = cp5.getProperties();
		prop.remove(cancelButton);
		prop.remove(okButton);
		prop.remove(previewToggle);
		prop.remove(hexValueLabel);
		prop.remove(hsbValueLabel);
		prop.remove(rgbValueLabel);
		prop.remove(s1D);
		prop.remove(s2D);

		show();
		smooth();
	} // end setup

	// ---------------------------------------------------------------------------
	// DRAW
	// ---------------------------------------------------------------------------

	public void draw() {
		colorMode(HSB);
		background(50);
		noStroke();

		fill(curCol);
		rect(300, 10, 60, 40);

		fill(startCol);
		rect(300, 50, 60, 40);

		int xpos = (int) s1D.getPosition()[0];
		int ypos = (int) s1D.getPosition()[1];

		loadPixels();
		for (int j = 0; j < 255; j++) {
			for (int i = 0; i < 20; i++) {
				set(i + xpos, j + ypos, color(j, 255, 255));
			}
		}

		xpos = (int) s2D.getPosition()[0];
		ypos = (int) s2D.getPosition()[1];

		loadPixels();
		for (int j = 0; j < 255; j++) {
			for (int i = 0; i < 255; i++) {
				set(j + xpos, i + ypos, color(hue, j, 255 - i));
			}
		}
		colorMode(RGB);
	}

	// ---------------------------------------------------------------------------
	// GUI FUNCTIONS
	// ---------------------------------------------------------------------------

	public boolean isOpen() {
		return opened;
	}

	public void setUndoable(boolean able) {
		undoable = able;
	}

	public void hide() {
		this.noLoop();
		surface.setVisible(false);
		opened = false;
	}

	public void show() {
		this.loop();
		opened = true;
		updateColor();
		initSliders(startCol);
		updatePreviewColor();
		surface.setVisible(true);
	}

	public void exit() { // on native window-close
		closeAndCancel();
	}

	private void closeAndApply() {
		startCol = curCol;
		srccol[0] = curCol;
		hide();
		if (undoable) {
			undo.setUndoStep();
		}
	}

	private void closeAndCancel() {
		curCol = startCol;
		srccol[0] = startCol;
		hide();
	}

	private void updateColor() {
		startCol = srccol[0];
		curCol = srccol[0];
	}

	private void updatePreviewColor() {
		colorMode(HSB);
		curCol = color(hue, sat, bri);
		if (preview) {
			srccol[0] = curCol;
		} else {
			srccol[0] = startCol;
		}
		rgbValueLabel.setText("R " + (int) red(curCol) + "\nG " + (int) green(curCol) + "\nB " + (int) blue(curCol));
		hsbValueLabel.setText(
				"H " + (int) hue(curCol) + "\nS " + (int) saturation(curCol) + "\nB " + (int) brightness(curCol));
		hexValueLabel.setText(hex(curCol, 6));
		colorMode(RGB);
	}

	private void initSliders(int c) {
		hue = hue(c);
		sat = saturation(c);
		bri = brightness(c) - 255;
		s1D.setValue(hue);
		s2D.setArrayValue(new float[]{sat, bri});
	}

	// ---------------------------------------------------------------------------
	// GUI LISTENER
	// ---------------------------------------------------------------------------

	public void controlEvent(ControlEvent theEvent) {
		switch (theEvent.getId()) {
			case (0) : // sat-bri
				sat = (theEvent.getController().getArrayValue())[0];
				bri = (theEvent.getController().getArrayValue())[1];
				updatePreviewColor();
				break;
			case (1) : // hue
				hue = (theEvent.getController().getValue());
				updatePreviewColor();
				break;
			case (2) : // OK
				closeAndApply();
				break;
			case (3) : // X
				closeAndCancel();
				break;
			case (4) : // PREVIEW
				preview = (int) theEvent.getController().getValue() == 1 ? true : false;
				updatePreviewColor();
				break;
		}
	}

	// ---------------------------------------------------------------------------
	// INPUT LISTENER
	// ---------------------------------------------------------------------------

	public void keyPressed() {
		if (key == RETURN || key == ENTER) {
			closeAndApply();
		} else if (key == ESC || keyCode == ESC) {
			key = 0;
			keyCode = 0;
			closeAndCancel();
		}
	}

	public void keyTyped() {
		if (keyCode == ESC || key == ESC) {
			key = 0;
			keyCode = 0;
		}
	}

	public void mouseWheel(MouseEvent event) {
		float e = event.getAmount();
		cp5.setMouseWheelRotation((int) e);
	}
}

// ---------------------------------------------------------------------------
// CUSTOM SLIDER-VIEWS (to prevent drawing of controller-background)
// ---------------------------------------------------------------------------

class ColorSlider2DView implements ControllerView<Slider2D> {
	PApplet theApplet;

	public ColorSlider2DView(PApplet a) {
		theApplet = a;
	}

	public void display(PGraphics g, Slider2D theController) {
		theApplet.noStroke();
		// draw no background
		// theApplet.fill(theController.getColor().getBackground());
		theApplet.noFill();
		theApplet.rect(0, 0, Petter.petter.width, Petter.petter.height);

		if (theController.isCrosshairs) {
			if (theController.isInside()) {
				theApplet.fill(theController.getColor().getBackground());
			} else {
				theApplet.fill(theController.getColor().getForeground());
			}
			theApplet.rect(0, (int) (theController.getCursorY() + theController.getCursorHeight() / 2),
					(int) theController.getWidth(), 1);
			theApplet.rect((int) (theController.getCursorX() + theController.getCursorWidth() / 2), 0, 1,
					(int) theController.getHeight());
		}

		theApplet.fill(theController.getColor().getActive());
		theApplet.rect((int) theController.getCursorX(), (int) theController.getCursorY(),
				(int) theController.getCursorWidth(), (int) theController.getCursorHeight());

		theController.getCaptionLabel().draw(g, 0, 0, theController);
		theController.getValueLabel().draw(g, 0, 0, theController);
	}
}

class ColorSlider1DView implements ControllerView<Slider> {
	PApplet theApplet;

	public ColorSlider1DView(PApplet a) {
		theApplet = a;
	}

	public void display(PGraphics g, Slider theController) {
		// draw no background
		// theApplet.fill(theController.getColor().getBackground());
		theApplet.noStroke();
		// drawHandle
		theApplet.fill(theController.isInside()
				? theController.getColor().getActive()
				: theController.getColor().getForeground());
		theApplet.rect(0, theController.getHeight() - theController.getValuePosition() - theController.getHandleSize(),
				theController.getWidth(), theController.getHandleSize());
	}
}
