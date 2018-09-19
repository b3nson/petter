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

import java.util.LinkedList;

import controlP5.ControlP5;
import processing.core.PApplet;

public class Memento {

	private int capacity;
	private ControlP5 gui;
	private LinkedList<String> deque;
	private int index = 0;

	public Memento(ControlP5 gui, int capacity) {
		this.gui = gui;
		this.capacity = capacity;
		deque = new LinkedList<String>();
	}

	public void undo() {
		if (index < deque.size() - 1) {
			index++;
			gui.getProperties().getSnapshot(deque.get(index));
		}
	}

	public void redo() {
		if (index > 0) {
			index--;
			gui.getProperties().getSnapshot(deque.get(index));
		}
	}

	public void setUndoStep() {
		// when not on head of undo-list, remove head-elements first
		if (index != 0) {
			for (int i = 0; i < index; i++) {
				deque.pollFirst();
			}
			index = 0;
		}

		String id = PApplet.str(Petter.petter.millis());
		if (deque.size() < capacity) {
			deque.offerFirst(id);
			gui.getProperties().setSnapshot(id);
		} else {
			deque.pollLast(); // remove and
			setUndoStep(); // try again
		}
		// println(deque);
	}
}
