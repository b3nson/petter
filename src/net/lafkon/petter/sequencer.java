package net.lafkon.petter;

import java.util.ArrayList;

import controlP5.Slider;
import processing.core.PApplet;

import static net.lafkon.petter.Petter.sequencing;
import static net.lafkon.petter.Petter.bgcolor;
import static net.lafkon.petter.Petter.strokecolor;
import static net.lafkon.petter.Petter.shapecolor;
import static net.lafkon.petter.Petter.mapIndex;
import static net.lafkon.petter.Petter.name;
import static net.lafkon.petter.Petter.timestamp;
import static net.lafkon.petter.Petter.ANM;
import static net.lafkon.petter.Petter.guiExportNow;
import static net.lafkon.petter.Petter.exportCurrentFrame;
import static net.lafkon.petter.Petter.subfolder;

import static net.lafkon.petter.GUI.animSetInButton;
import static net.lafkon.petter.GUI.animSetOutButton;

import static net.lafkon.petter.GUI.generateName;
import static net.lafkon.petter.GUI.saveSettings;
import static net.lafkon.petter.GUI.generateTimestamp;
import static net.lafkon.petter.GUI.ease;
import static net.lafkon.petter.GUI.specImgMapFrame;

public class sequencer {

	static ArrayList<Slider> animctrls = new ArrayList<Slider>();
	static 	float[][] keyframeValues;
	static int[][] colorValues = new int[3][2];

	public static int frames = 25;
	static int fcount = 0;
	public static String seqname = "";
	static boolean startValuesRegistered = false;
	static boolean endValuesRegistered = false;
	static boolean exportCurrentRun = false;

	public static void registerForAnimation(Slider s) {
		animctrls.add(s);
	}

	public static void registerAnimStartValues() {
		if (!startValuesRegistered && !endValuesRegistered) {
			keyframeValues = new float[animctrls.size()][2];
		}
		for (int i = 0; i < animctrls.size(); i++) {
			Slider s = animctrls.get(i);
			keyframeValues[i][0] = s.getValue();
		}
		registerColorStartValues();
		startValuesRegistered = true;
		animSetInButton.setColorBackground(Petter.petter.color(255, 0, 0));
	}

	public static void registerAnimEndValues() {
		if (!startValuesRegistered && !endValuesRegistered) {
			keyframeValues = new float[animctrls.size()][2];
		}
		for (int i = 0; i < animctrls.size(); i++) {
			Slider s = animctrls.get(i);
			keyframeValues[i][1] = s.getValue();
		}
		registerColorEndValues();
		endValuesRegistered = true;
		animSetOutButton.setColorBackground(Petter.petter.color(255, 0, 0));
	}

	public static void registerColorStartValues() {
		colorValues[0][0] = bgcolor[0];
		colorValues[1][0] = strokecolor[0];
		colorValues[2][0] = shapecolor[0];
	}

	public static void registerColorEndValues() {
		colorValues[0][1] = bgcolor[0];
		colorValues[1][1] = strokecolor[0];
		colorValues[2][1] = shapecolor[0];
	}

	public static void deleteRegisteredValues() {
		if (!sequencing) {
			keyframeValues = null;
			startValuesRegistered = false;
			endValuesRegistered = false;
			animSetInButton.setColorBackground(Petter.petter.color(100));
			animSetOutButton.setColorBackground(Petter.petter.color(100));
		}
	}

	public static void startSequencer(boolean export) {
		if (!sequencing) {
			if (startValuesRegistered && endValuesRegistered) {
				sequencing = true;
				mapIndex = 0;
				if (export) {
					exportCurrentRun = true;
					exportCurrentFrame = true;
					generateName();
					generateTimestamp();
					subfolder = timestamp + "_" + frames + "f" + "_" + name + "/";
					showInValues();
					saveSettings(timestamp + "_" + "ANIMIN" + "_" + name);
				}
			}
		} else {
			stopSequencer();
			showOutValues();
		}
	}

	public static void stopSequencer() {
		if (exportCurrentRun) {
			saveSettings(timestamp + "_" + "ANIMOUT" + "_" + name);
		}
		exportCurrentRun = false;
		sequencing = false;
		exportCurrentFrame = false;
		seqname = "";
		subfolder = "";
		fcount = 0;
	}

	public static void showInValues() {
		if (startValuesRegistered) {
			for (int i = 0; i < animctrls.size(); i++) {
				float from = keyframeValues[i][0];
				animctrls.get(i).setValue(from);
			}
			// manual color-assignement. dirty hack.
			bgcolor[0] = colorValues[0][0];
			strokecolor[0] = colorValues[1][0];
			shapecolor[0] = colorValues[2][0];
		}
	}

	public static void showOutValues() {
		if (endValuesRegistered) {
			for (int i = 0; i < animctrls.size(); i++) {
				float to = keyframeValues[i][1];
				animctrls.get(i).setValue(to);
				animctrls.get(i).setColorForeground(Petter.petter.color(50));
			}
			// manual color-assignement. dirty hack.
			bgcolor[0] = colorValues[0][1];
			strokecolor[0] = colorValues[1][1];
			shapecolor[0] = colorValues[2][1];
		}
	}

	public static void animate() {
		if (guiExportNow) {
			fcount--;
		}
		if (sequencing && fcount < frames) {
			if (exportCurrentRun) {
				exportCurrentFrame = true;
				seqname = "-" + PApplet.nf(fcount, 4);
			}

			specImgMapFrame(fcount);

			for (int i = 0; i < animctrls.size(); i++) {
				float from = keyframeValues[i][0];
				float to = keyframeValues[i][1];
				if (from != to) {
					float curval = ease(ANM, fcount, from, to - from, frames - 1);
					animctrls.get(i).setValue(curval);
					if (fcount == 1) {
						animctrls.get(i).setColorForeground(Petter.petter.color(255, 0, 0));
					} else if (fcount == frames - 1) {
						animctrls.get(i).setColorForeground(Petter.petter.color(50));
					}
				}
			}
			// manual color-assignement. dirty hack.
			float curval = ease(ANM, fcount, 0f, 1f, frames - 1);
			bgcolor[0] = Petter.petter.lerpColor(colorValues[0][0], colorValues[0][1], curval);
			strokecolor[0] = Petter.petter.lerpColor(colorValues[1][0], colorValues[1][1], curval);
			shapecolor[0] = Petter.petter.lerpColor(colorValues[2][0], colorValues[2][1], curval);

			fcount++;
		} else {
			stopSequencer();
		}
	}

}