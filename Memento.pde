import java.util.LinkedList;

public class Memento {
  
  private int capacity;
  private ControlP5 gui;
  private LinkedList <String>deque;
  private int index = 0;
  
  
  public Memento(ControlP5 gui, int capacity) {
    this.gui = gui;
    this.capacity = capacity;
    deque = new LinkedList<String>();
  }
  
  public void undo() {
    if(index < deque.size()-1) {
      index++;
      gui.getProperties().getSnapshot(deque.get(index));
    }
  }

  public void redo() {
    if(index > 0) {
      index--;
      gui.getProperties().getSnapshot(deque.get(index));
    }
  }


  public void setUndoStep() {
    //when not on head of undo-list, remove head-elements when new Action is triggered
    if(index != 0) {
       for(int i = 0; i<index ; i++) {
        deque.pollFirst();
       } 
       index = 0;
    }
    
    String key = str(millis());
    if(deque.size() < capacity) {
      deque.offerFirst(key);
      gui.getProperties().setSnapshot(key);
    } else {
       deque.pollLast(); //remove and
       setUndoStep();   //try again
    }
    
    //println(deque); 
  }
}
