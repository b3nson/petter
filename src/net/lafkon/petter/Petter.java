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

import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.core.PShape;
import processing.event.MouseEvent;
import processing.pdf.*;
import processing.svg.*;

import controlP5.*;

import sojamo.drop.*;

import net.lafkon.petter.DropTargetIMG;
import net.lafkon.petter.DropTargetSVG;

import java.awt.Component;
import java.util.*;

import static net.lafkon.petter.GUI.showNfoToggle;
import static net.lafkon.petter.GUI.penner_rot;
import static net.lafkon.petter.GUI.penner_sca;
import static net.lafkon.petter.GUI.penner_tra;
import static net.lafkon.petter.GUI.showHELP;
import static net.lafkon.petter.GUI.shiftPressed;
import static net.lafkon.petter.GUI.imgMap;
import static net.lafkon.petter.GUI.pageOffsetSlider;
import static net.lafkon.petter.GUI.batchmode;
import static net.lafkon.petter.GUI.bgcolorBang;
import static net.lafkon.petter.GUI.shapecolorBang;
import static net.lafkon.petter.GUI.strokecolorBang;
import static net.lafkon.petter.GUI.bgcolorSaveLabel;
import static net.lafkon.petter.GUI.shapecolorSaveLabel;
import static net.lafkon.petter.GUI.strokecolorSaveLabel;
import static net.lafkon.petter.GUI.batchnow;
import static net.lafkon.petter.GUI.batchwait;
import static net.lafkon.petter.GUI.last;
import static net.lafkon.petter.GUI.formatDropdown;
import static net.lafkon.petter.GUI.penner_anim;
import static net.lafkon.petter.GUI.showExportLabelTimer;
import static net.lafkon.petter.GUI.showRefToggle;
import static net.lafkon.petter.GUI.nfoLayerToggle;
import static net.lafkon.petter.GUI.exportFormatToggle;
import static net.lafkon.petter.GUI.fpsLabel;
import static net.lafkon.petter.GUI.dragOffset;
import static net.lafkon.petter.GUI.offsetxSaveLabel;
import static net.lafkon.petter.GUI.offsetySaveLabel;
import static net.lafkon.petter.GUI.loopDirectionSaveLabel;
import static net.lafkon.petter.GUI.linebylineSaveLabel;

import static net.lafkon.petter.GUI.scaleGUI;
import static net.lafkon.petter.GUI.openAnimate;
import static net.lafkon.petter.GUI.ease;
import static net.lafkon.petter.GUI.enterShiftMode;
import static net.lafkon.petter.GUI.leaveShiftMode;
import static net.lafkon.petter.GUI.menuScroll;
import static net.lafkon.petter.GUI.generateName;
import static net.lafkon.petter.GUI.generateTimestamp;
import static net.lafkon.petter.GUI.saveSettings;
import static net.lafkon.petter.GUI.checkArgs;
import static net.lafkon.petter.GUI.showExportLabel;
import static net.lafkon.petter.GUI.updatextilenumSlider;
import static net.lafkon.petter.GUI.updateytilenumSlider;
import static net.lafkon.petter.GUI.setupGUI;
import static net.lafkon.petter.GUI.toggleMenu;
import static net.lafkon.petter.GUI.toggleSettings;
import static net.lafkon.petter.GUI.toggleRandom;
import static net.lafkon.petter.GUI.toggleAnimate;
import static net.lafkon.petter.GUI.toggleHelp;
import static net.lafkon.petter.GUI.prevImgMapFrame;
import static net.lafkon.petter.GUI.nextImgMapFrame;
import static net.lafkon.petter.GUI.toggleTileEditor;
import static net.lafkon.petter.GUI.changeSliderRange;
import static net.lafkon.petter.GUI.loadDefaultSettings;

import static net.lafkon.petter.sequencer.seqname;
import static net.lafkon.petter.sequencer.registerAnimEndValues;
import static net.lafkon.petter.sequencer.registerAnimStartValues;
import static net.lafkon.petter.sequencer.showInValues;
import static net.lafkon.petter.sequencer.showOutValues;
import static net.lafkon.petter.sequencer.startSequencer;

public class Petter extends PApplet {

	public static void main(String[] args) {
		PApplet.main(Petter.class);
	}

	/**
	 * Exposes the Papplet instance for use in Java Mode.
	 * Allows for use in static contexts.
	 */
	public static PApplet petter;

	public static final int ROT = 0;
	public static final int TRA = 1;
	public static final int SCA = 2;
	public static final int ANM = 3;

	public static int lastKey = ' ';
	final static int KEYS = 0500;
	public final static boolean[] keysDown = new boolean[KEYS];

	public static ControlP5 gui;
	public static ControlFont font;
	private static SDrop drop;
	public static DropTargetSVG dropSVGadd;

	public static DropTargetSVG dropSVGrep, dropSVGnfo;
	public static DropTargetIMG dropIMG;
	public static ColorPicker bg_copi, stroke_copi, shape_copi, type_copi;
	public static TileEditor tileEditor;
	public static Memento undo;
	public static PGraphics pdf;

	final static String version = "0.4";
	public final static String settingspath = "i/settings/";
	private static String outputpath = "o/";
	public static String tmppath = "tmp/";
	public static String subfolder = "";
	public static String[] names;
	public static String[] helptext;
	public static String[] systemfonts;
	public static String name;

	public static ArrayList<PShape> svg;
	public static ArrayList<String> svgpath;
	public static ArrayList<PImage> map;
	private static PShape ref;
	public static PShape nfo;
	public static PShape s;

	public static int mapIndex = 0;
	private static int absPageOffset = 25;
	public static int pageOffset = 25;
	public static int xtilenum = 8;
	public static int ytilenum = 10;
	private static int tilecount;
	public static float manualOffsetX = 0;
	public static float manualOffsetY = 0;
	public static float tilewidth, tileheight, tilescale;
	private static float absTransX = 0;
	private static float absTransY = 0;
	private static float absScreenX;
	private static float absScreenY;

	public static float zoom = 1.0f;
	private static float tmpzoom = 0;
	public static float nfoscale = 1.0f;
	private static float relTransX = 0;
	private static float relTransY = 0;
	private static float absRot = 0;
	private static float relRot = 90;
	public static float absScale = 1.0f;
	private static float relScale = 0.0f;
	public static float relsca = 0.0f;
	private static float totaltranslatex = 0.0f;
	private static float totaltranslatey = 0.0f;
	private static float totalscale = 0.0f;
	private static float totalrotate = 0.0f;
	public static float customStrokeWeight = 2.0f;
	public static boolean mapScale = false;
	public static boolean mapRot = false;
	public static boolean mapTra = false;
	public static boolean invertMap = false;
	public static boolean strokeMode = true;
	public static boolean globalStyle = false;
	public static boolean customStroke = true;
	public static boolean customFill = true;
	public static boolean random = false;
	public static boolean linebyline = false;
	private static boolean dragAllowed = false;
	private static boolean showRef = false;
	public static boolean showNfo = false;
	public static boolean nfoOnTop = true;
	private static boolean exportFormat = true; // true=PDF|false=SVG
	private static boolean guiExport = false;
	public static boolean guiExportNow = false;
	public static boolean showExportLabel = false;
	public static boolean sequencing = false;
	private static boolean shift = false;
	public static int seed = 0;
	private static int fps = 0;
	private static float mapValue = 0f;

	private static int abscount = 0;
	public static boolean loopDirection = false; // false = X before Y | true = Y before X
	public static int rotType = 0;
	public static int scaType = 0;
	public static int traType = 0;
	public static int animType = 0;

	public static boolean exportCurrentFrame = false;
	private static boolean exportOnNextLoop = false;
	public static String timestamp = "";
	public static String filename = "";
	public static String formatName = "";
	public static String sketchPath;

	public static int[] bgcolor;
	public static int[] strokecolor;
	public static int[] shapecolor;
	public static int[] typecolor;

	public static boolean pageOrientation = true;
	public static String[][] formats = {{"A5", "437", "613"}, {"A4", "595", "842"}, {"A3", "842", "1191"},
			{"A2", "1191", "1684"}, {"Q1", "800", "800"}, {"FullHD", "1920", "1080"}};

	public static int fwidth = 595;
	public static int fheight = 842;
	public static int pdfwidth = 595;
	public static int pdfheight = 842;
	public static int guiwidth = 310;

	private static int manualNFOX = fwidth / 2;
	private static int manualNFOY = fheight / 6 * 5;

	// ---------------------------------------------------------------------------
	// SETUP
	// ---------------------------------------------------------------------------

	@Override
	public void settings() {
		size(905, 842, JAVA2D); // move size() to settings() Java mode.
	}

	public void setup() {
		petter = this; // set the static PApplet reference to this PApplet instance.

		bgcolor = new int[]{color(random(255), random(255), random(255))};
		strokecolor = new int[]{color(0, 0, 0)};
		shapecolor = new int[]{color(255, 255, 255)};
		typecolor = new int[]{color(0, 0, 0)};

		frameRate(100);
		// surface.setResizable(true);
		surface.setSize(905, 842);
		surface.setTitle("petter " + version);
		sketchPath = sketchPath();

		PImage pettericon = loadImage("i/icon.png");
		surface.setIcon(pettericon);

		smooth();
		shapeMode(CENTER);

		PFont pfont = createFont("i/fonts/PFArmaFive.ttf", 8, false);
		font = new ControlFont(pfont);

		gui = new ControlP5(this, font);
		gui.setAutoDraw(false);

		drop = new SDrop((Component) this.surface.getNative(), this);
		dropSVGadd = new DropTargetSVG(this, DropTargetSVG.ADDSVG);
		dropSVGrep = new DropTargetSVG(this, DropTargetSVG.REPLACESVG);
		dropSVGnfo = new DropTargetSVG(this, DropTargetSVG.NFOSVG);
		dropIMG = new DropTargetIMG(this);
		drop.addDropListener(dropSVGadd);
		drop.addDropListener(dropSVGrep);
		drop.addDropListener(dropSVGnfo);
		drop.addDropListener(dropIMG);

		undo = new Memento(gui, 50);

		svg = new ArrayList<PShape>();
		svgpath = new ArrayList<String>();
		map = new ArrayList<PImage>();

		try {
			svg.add(new TileSVG("i/default.svg"));
		} catch (NullPointerException e) {
			svg.add(new TileShape(createShape(RECT, 0, 0, 50, 50), 50f, 50f));
		}
		try {
			svgpath.add(sketchPath() + "/i/default.svg");
		} catch (NullPointerException e) {
		}
		try {
			ref = loadShape("i/ref.svg");
		} catch (NullPointerException e) {
			showRef = false;
		}
		try {
			nfo = new TileSVG("i/info.svg");
		} catch (NullPointerException e) {
			showNfo = false;
		}
		try {
			names = loadStrings("i/names.txt");
		} catch (NullPointerException e) {
		}
		try {
			helptext = loadStrings("i/help.txt");
		} catch (NullPointerException e) {
		}

		setupGUI();

		pageOffsetSlider.setValue(absPageOffset);
		formatDropdown.setValue(2);
		penner_rot.setValue(rotType);
		penner_sca.setValue(scaType);
		penner_tra.setValue(traType);
		penner_anim.setValue(animType);
		showRefToggle.setState(showRef);
		showNfoToggle.setState(showNfo);
		nfoLayerToggle.setState(nfoOnTop);
		exportFormatToggle.setState(exportFormat);
		// strokeWeightSlider.setValue(strokeWeight);
		last = null;

		undo.setUndoStep();

		println("  , _");
		println(" /|/ \\ __|__|_  _  ,_");
		println("  |__/|/ |  |  |/ /  |");
		println("  |   |_/|_/|_/|_/   |/ v" + version);
		println(" ");
		println("  Press M for menu");
		println("        H for help");
		println("");

		checkArgs();
		ControlP5.DEBUG = false;
	}

	// ---------------------------------------------------------------------------
	// DRAW
	// ---------------------------------------------------------------------------

	public void draw() {

		if (sequencing) {
			sequencer.animate();
		}

		if (shift && key == CODED && keyCode == SHIFT && !shiftPressed) {
			shiftPressed = true;
			enterShiftMode();
		} else if (!shift && shiftPressed) {
			shiftPressed = false;
			leaveShiftMode();
			last = null;
		}

		if (exportOnNextLoop) {
			exportCurrentFrame = true;
			exportOnNextLoop = false;
		}
		if (exportCurrentFrame) {
			if (!guiExportNow) {
				formatName = pdfwidth + "x" + pdfheight;
				if (!sequencing && !batchmode) {
					saveSettings(timestamp + "_" + name);
				}
			}
			if (!guiExportNow) {
				filename = outputpath + subfolder + timestamp + "_" + formatName + "_" + name + seqname;
				if (exportFormat) {
					filename += ".pdf";
					pdf = (PGraphicsPDF) createGraphics(pdfwidth, pdfheight, PDF, filename);
				} else {
					filename += ".svg";
					pdf = (PGraphicsSVG) createGraphics(pdfwidth, pdfheight, SVG, filename);
				}
			} else {
				filename = outputpath + subfolder + timestamp + "_" + formatName + "_" + name + seqname + "+GUI";
				if (exportFormat) {
					filename += ".pdf";
					pdf = (PGraphicsPDF) createGraphics(pdfwidth + guiwidth, pdfheight, PDF, filename);
				} else {
					filename += ".svg";
					pdf = (PGraphicsSVG) createGraphics(pdfwidth + guiwidth, pdfheight, SVG, filename);
				}
			}

			beginRecord(pdf);
			pdf.shapeMode(CENTER);
			pdf.pushStyle();

			if (guiExportNow) { // reset scale to 1 for guiexport
				tmpzoom = zoom;
				scaleGUI(1f);
			}

			pdf.pushMatrix();
			pdf.scale(1f / zoom);

			// saveFrame("frame.png");
		}

		if (bg_copi != null && bg_copi.isOpen()) {
			bgcolorBang.setColorForeground(bgcolor[0]);
			bgcolorSaveLabel.setValue((bgcolor[0]));
		}
		if (globalStyle) {
			if (stroke_copi != null && stroke_copi.isOpen()) {
				strokecolorBang.setColorForeground(strokecolor[0]);
				strokecolorSaveLabel.setValue((strokecolor[0]));
			}
			if (shape_copi != null && shape_copi.isOpen()) {
				shapecolorBang.setColorForeground(shapecolor[0]);
				shapecolorSaveLabel.setValue((shapecolor[0]));
			}
		}

		pushStyle();
		fill(bgcolor[0]);
		noStroke();
		rect(0, 0, fwidth, fheight);
		popStyle();

		if (!exportCurrentFrame || (exportCurrentFrame && guiExportNow)) {
			pushStyle();
			fill(50);
			noStroke();
			rect(fwidth, 0, guiwidth, fheight);
			popStyle();
		}

		if (nfo != null && showNfo && !nfoOnTop) {
			shapeMode(CENTER);
			pushMatrix();
			scale(zoom);
			translate(manualNFOX, manualNFOY);
			scale(nfoscale);
			shape(nfo);
			popMatrix();
		}

		abscount = 0;
		if (!linebyline) {
			tilecount = (xtilenum * ytilenum) - 1;
		} else {
			tilecount = ytilenum - 1;
		}
		pageOffset = (int) (absPageOffset * zoom);
		tilewidth = (float) ((fwidth - (2 * pageOffset)) / xtilenum);
		tilescale = tilewidth / svg.get(0).width;
		tileheight = svg.get(0).height * tilescale;

		randomSeed(seed);

		pushMatrix();
		translate(pageOffset, pageOffset);
		translate(manualOffsetX, manualOffsetY);

		// ---------------------------------------------------
		// MAIN LOOP
		// ---------------------------------------------------

		for (int i = 0; i < (loopDirection ? xtilenum : ytilenum); i++) {
			for (int j = 0; j < (loopDirection ? ytilenum : xtilenum); j++) {
				pushMatrix();

				translate((tilewidth / 2) + (tilewidth * (loopDirection ? i : j)),
						(tileheight / 2) + (tileheight * (loopDirection ? j : i))); // swap i/j for xalign/yaligndraw

				if ((mapScale || mapRot || mapTra)
						&& (map.size() != 0 && mapIndex < map.size() && map.get(mapIndex) != null)) {
					int cropX = (int) map((imgMap.a - imgMap.x), 0, imgMap.ww, 0, map.get(mapIndex).width);
					int cropY = (int) map((imgMap.b - imgMap.y), 0, imgMap.hh, 0, map.get(mapIndex).height);
					int cropW = (int) map(imgMap.e, 0, imgMap.ww, 0, map.get(mapIndex).width) + cropX;
					int cropH = (int) map(imgMap.f, 0, imgMap.hh, 0, map.get(mapIndex).height) + cropY;

					absScreenX = screenX(0, 0);
					absScreenY = screenY(0, 0);
					absScreenX = map(absScreenX, pageOffset, fwidth - pageOffset, cropX, cropW);
					absScreenY = map(absScreenY, pageOffset,
							(((float) fwidth - (2 * pageOffset) / fwidth) * fheight) + pageOffset, cropY, cropH);

					try {
						int col = map.get(mapIndex).pixels[(int) constrain(absScreenY, 0, map.get(mapIndex).height)
								* (int) map.get(mapIndex).width
								+ (int) constrain(absScreenX, 0, map.get(mapIndex).width)];
						if (col == color(0, 255, 0)) {
							popMatrix();
							abscount++;
							continue;
						}
						// http://de.wikipedia.org/wiki/Grauwert#In_der_Bildverarbeitung
						mapValue = ((red(col) / 255f) * 0.299f) + ((green(col) / 255f) * 0.587f)
								+ ((blue(col) / 255f) * 0.114f);
						// mapValue = ( brightness(col) /255);
					} catch (Exception e) { // ArrayIndexOutOfBoundsException | NullPointerException
						mapValue = 1f;
					}
				}

				float xx = absTransX
						* (map(j, 0f, (float) xtilenum, (float) -xtilenum / 2 + 0.5f, (float) xtilenum / 2 + 0.5f));
				float yy = absTransY * (map(i, 0f, (float) ytilenum, 0, (float) ytilenum));
				totaltranslatex = xx;
				totaltranslatey = yy;
				if (mapTra && map != null) {
					try {
						float tvx = (invertMap ? (1.0f - mapValue) : mapValue) * relTransX * 10;
						float tvy = (invertMap ? (1.0f - mapValue) : mapValue) * relTransY * 10;
						totaltranslatex += tvx;
						totaltranslatey += tvy;
					} catch (ArrayIndexOutOfBoundsException e) {
					}
				} else {
					totaltranslatex += ease(TRA, abscount, -relTransX, relTransX, tilecount);
					totaltranslatey += ease(TRA, abscount, relTransY, -relTransY, tilecount);
				}
				translate(totaltranslatex, totaltranslatey);

				totalrotate = absRot;
				if (mapRot && map != null) {
					try {
						float rv = mapValue * (relRot);
						totalrotate += rv;
					} catch (ArrayIndexOutOfBoundsException e) {
					}
				} else {
					totalrotate += ease(ROT, abscount, 0, relRot, tilecount);
				}
				rotate(radians(totalrotate));

				totalscale = absScale;
				if (mapScale && map != null) {
					try {
						relsca = mapValue * (relScale);
						totalscale *= invertMap ? (1 - relsca) : relsca;
					} catch (ArrayIndexOutOfBoundsException e) {
					}
				} else {
					relsca = ease(SCA, abscount, 1.0f, relScale, tilecount);
					totalscale *= relsca;
				}
				scale(totalscale * tilescale);

				if (random) {
					s = svg.get((int) random(svg.size()));
				} else {
					s = svg.get((((loopDirection ? ytilenum : xtilenum) * i) + j) % svg.size());
				}

				if (s != null) {
					shape(s);
				}

				popMatrix();
				if (!linebyline) {
					abscount++;
				}
			} // for j
			if (linebyline) {
				abscount++;
			}
		} // for i

		popMatrix();

		// ---------------------------------------------------

		if (nfo != null && showNfo && nfoOnTop) {
			shapeMode(CENTER);
			pushMatrix();
			scale(zoom);
			translate(manualNFOX, manualNFOY);
			scale(nfoscale);
			shape(nfo);
			popMatrix();
		}

		if (exportCurrentFrame && guiExportNow) {
			if (ref != null && showRef) {
				shapeMode(CORNER);
				shape(ref, 0, 0, fwidth, fheight);
			}
			gui.getWindow().draw(pdf);
			scaleGUI(tmpzoom); // recreate prev zoom
			tmpzoom = 0f;
		}

		if (exportCurrentFrame) {
			pdf.popMatrix();
			pdf.popStyle();
			endRecord();
			println(filename + " exported!");
			if (batchmode && batchnow) {
				exit();
			}

			if (!guiExport) {
				showExportLabel(true);
			} else if (guiExportNow) {
				showExportLabel(true);
			}

			if (guiExport && !guiExportNow) {
				guiExportNow = true;
			} else if (guiExport && guiExportNow) {
				guiExportNow = false;
				exportCurrentFrame = false;
			} else if (!guiExport) {
				exportCurrentFrame = false;
			}
		}

		if (showExportLabel) {
			if (millis() - showExportLabelTimer >= 4000) {
				showExportLabel(false);
			}
		}

		if (!exportCurrentFrame) {
			if (ref != null && showRef) {
				shapeMode(CORNER);
				shape(ref, 0, 0, fwidth, fheight);
			}
			gui.draw();
		}

		if (batchmode) {
			if (batchwait > 0) {
				batchwait--;
			} else {
				generateName();
				generateTimestamp();
				batchnow = true;
				exportCurrentFrame = true;
			}
		}

		shapeMode(CENTER);
		noStroke();

		dropSVGadd.draw();
		dropSVGrep.draw();
		dropSVGnfo.draw();
		dropIMG.draw();

		if (showHELP) {
			fpsLabel.setText(str((int) frameRate));
		}
	}// DRAW END

	// ---------------------------------------------------------------------------
	// INPUT EVENTS
	// ---------------------------------------------------------------------------

	public void mouseMoved() {
		// for testing-purposes
		// pageOffset = int((mouseX));
		// absScale = (float(mouseX)/100f);
		// relScale = (float(mouseX)/100f);
		// absTransX = (mouseX-(width/2))*2;
		// absTransY = (mouseY-(height/2))*2;
		// relTrans = (mouseX);
		// absRot = mouseX;
		// relRot = mouseY;
		// xtilenum = mouseX/10;
		// ytilenum = mouseY/10;
	}

	public void mousePressed() {
		if ((mouseX <= fwidth) && (mouseY <= fheight)) {
			dragAllowed = true;
			pmouseX = mouseX;
			pmouseY = mouseY;
		}
	}

	public void mouseDragged() {
		if (dragAllowed && mouseButton == LEFT) {
			manualOffsetX -= pmouseX - mouseX;
			manualOffsetY -= pmouseY - mouseY;
			dragOffset.setText("OFFSET: " + (int) manualOffsetX + " x " + (int) manualOffsetY);
			offsetxSaveLabel.setValue(manualOffsetX);
			offsetySaveLabel.setValue(manualOffsetY);
		} else if (dragAllowed && mouseButton == RIGHT) {
			manualNFOX -= pmouseX - mouseX;
			manualNFOY -= pmouseY - mouseY;
		}
	}

	public void mouseReleased() {
		dragAllowed = false;
	}

	public void keyPressed() {
		processKey(keyCode, true);

		if (keysDown[SHIFT]) {
			shift = true;
		}
		if (keysDown[LEFT]) {
			if (keysDown[LEFT] && keysDown[SHIFT])
				xtilenum -= 10;
			else
				xtilenum -= 1;
			updatextilenumSlider();
		} else if (keysDown[RIGHT]) {
			if (keysDown[RIGHT] && keysDown[SHIFT])
				xtilenum += 10;
			else
				xtilenum += 1;
			updatextilenumSlider();
		} else if (keysDown[UP]) {
			if (keysDown[UP] && keysDown[SHIFT])
				ytilenum -= 10;
			else
				ytilenum -= 1;
			updateytilenumSlider();
		} else if (keysDown[DOWN]) {
			if (keysDown[DOWN] && keysDown[SHIFT])
				ytilenum += 10;
			else
				ytilenum += 1;
			updateytilenumSlider();
		} else if (keysDown['Z']) {
			undo.undo();
		} else if (keysDown['Y']) {
			undo.redo();
		} else if (keysDown['S']) {
			exportOnNextLoop = true;
			generateName();
			generateTimestamp();
			if (showExportLabel)
				showExportLabel(false);
		} else if (keysDown['M']) {
			toggleMenu();
		} else if (keysDown['0']) {
			toggleSettings();
		} else if (keysDown['X']) {
			loopDirection = !loopDirection;
			loopDirectionSaveLabel.setValue(loopDirection == true ? 1 : 0);
		} else if (keysDown['R']) {
			toggleRandom();
		} else if (keysDown['L']) {
			linebyline = !linebyline;
			linebylineSaveLabel.setValue(linebyline == true ? 1 : 0);

		} else if (keysDown['B']) {
			showRef = !showRef;
			showRefToggle.setState(showRef);
		} else if (keysDown['N']) {
			showNfo = !showNfo;
			showNfoToggle.setState(showNfo);
		} else if (keyCode == 93 || keyCode == 107) { // PLUS
			scaleGUI(true);
		} else if (keyCode == 47 || keyCode == 109) { // MINUS
			scaleGUI(false);
		} else if (keysDown['I']) {
			openAnimate();
			registerAnimStartValues();
		} else if (keysDown['O']) {
			openAnimate();
			registerAnimEndValues();
		} else if (keysDown['P']) {
			startSequencer(false);
		} else if (keysDown['A']) {
			toggleAnimate();
		} else if (keysDown['J']) {
			showInValues();
		} else if (keysDown['K']) {
			showOutValues();
		} else if (keysDown['H']) {
			toggleHelp();
		} else if (keysDown['C']) {
			prevImgMapFrame();
		} else if (keysDown['V']) {
			nextImgMapFrame();
		} else if (keysDown['T']) {
			toggleTileEditor();
		} else if (keysDown[',']) {
			changeSliderRange(false);
		} else if (keysDown['.']) {
			changeSliderRange(true);
		} else if (keysDown['D']) {
			loadDefaultSettings();
		}
	}

	public void keyReleased() {
		if (keysDown[SHIFT]) {
			shift = false;
		}
		processKey(keyCode, false);
	}

	public void mouseWheel(MouseEvent event) {
		float e = event.getAmount();
		if (keysDown[CONTROL]) {
			nfoscale += e / 100;
		} else {
			menuScroll((int) e);
			gui.setMouseWheelRotation((int) e);
		}
	}

	protected static void processKey(int k, boolean set) {
		if (set)
			lastKey = k;
		if (k < KEYS)
			keysDown[k] = set;
	}

}