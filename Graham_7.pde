// questo pacchetto dal java util è inserito per maneggiare 
// ArrayList che subiscano modifiche strutturali mentre le 
// si sta cilando come nel caso dell'ultimo ciclo for
import java.util.concurrent.*; 

ArrayList<PVector> clicks;
int NPOINTS;
float[][] points;
float[] angles;
int iTLM;
//int iBRM;
int[] is; // indici ordianti
InviluppoConvesso ic;
int[] indiciInviluppoConvesso;

PFont f;
float margin = 20;

////////////////////////////////////////////////////////////////
void setup() {
  size(400, 400);
  smooth();
  clicks = new ArrayList<PVector>();
  ic = new InviluppoConvesso();
  inizializza();
  f = createFont("Courier", 72, true);
}

////////////////////////////////////////////////////////////////
void draw() {
  background(255);
  
  pushStyle();
  textFont(f);
  textSize(12);
  textAlign(LEFT);
  fill(0);
  
  
  if(NPOINTS == 0) {
    text("CALCOLO dell'INVILUPPO CONVESSO - mouse click", 10, 20);
  } else {
    text("CALCOLO dell'INVILUPPO CONVESSO - mouse click or space", 10, 20);
    
    // raggi congiungenti
    float w = 255;
    if(NPOINTS != 0)
      w = 255 / NPOINTS;
      
    strokeWeight(1);
    // nel seguente ciclo salto l'indice 0 perchè so che
    // in corrispondenza di questo 'indici[i]' mi restituisce
    // l'indice che in 'points[i]' corrisponde all'angolo 0.0
    // ossia al punto di origine
    for(int i = 1; i<points.length; i++) {
      stroke(255, 132, 0, w+w*i);
      line(points[iTLM][0], points[iTLM][1], points[ is[i] ][0], points[ is[i] ][1]);
      //disegno gli archi
      float dx = points[ is[i] ][0] - points[iTLM][0];
      float dy = points[ is[i] ][1] - points[iTLM][1];
      float r = sqrt(dx*dx + dy*dy);
      noStroke();
      fill(255, 132, 0, w);
      arc(points[iTLM][0], points[iTLM][1], 2*r, 2*r, PI-angles[ is[i] ], PI, PIE);
      fill(0);
      text((int)degrees( angles[ is[i] ])+"°", points[ is[i] ][0], points[ is[i] ][1]-5);
    }
    
    
    if(indiciInviluppoConvesso != null && indiciInviluppoConvesso.length > 0) {
      noFill();
      strokeWeight(1);
      stroke(255, 0, 0);
      beginShape();
      for(int i = 0; i < indiciInviluppoConvesso.length; i++) {
        vertex(points[ indiciInviluppoConvesso[i] ][0], points[ indiciInviluppoConvesso[i] ][1] );  
      }
      endShape(CLOSE);
      // indico quali sono gli indici dei punti che costituiscono i vertici del Convex Hull
      textFont(f);
      textSize(12);
      textAlign(LEFT);
      fill(0);
      text("vertici dell'inviluppo: ", 10, 40);
      for(int i = 0; i < indiciInviluppoConvesso.length; i++) {
        text( indiciInviluppoConvesso[i], 10+20*i, 55);
      }
    }
    
    
    //if(points.length >= 1) {
    // mirini
    strokeWeight(1);
    stroke(255, 0, 0, 100);
    line(margin, points[ iTLM ][1], width-2*margin, points[ iTLM ][1]);
    line(points[ iTLM ][0], margin, points[ iTLM ][0], height-margin);
    fill(255, 0, 0);
    if(points[ iTLM ][0] > width/2)
      textAlign(RIGHT);
    else
      textAlign(LEFT);
    text("TOP LEFT point", points[ iTLM ][0]+5, points[ iTLM ][1]-5);
//    stroke(0, 255, 0, 100);
//    line(margin, points[ iBRM ][1], width-2*margin, points[ iBRM ][1]);
//    line(points[ iBRM ][0], margin, points[ iBRM ][0], height-margin);
//    fill(0, 255, 0);
//    if(points[ iBRM ][0] > width/2)
//      textAlign(RIGHT);
//    else
//      textAlign(LEFT);
//    text("BOTTOM RIGHT point", points[ iBRM ][0]+5, points[ iBRM ][1]+13);
    // anelli
    strokeWeight(2);
    noFill();
    stroke(255, 0, 0);
    ellipse(points[ iTLM ][0], points[ iTLM ][1], 5, 5);
//    stroke(0, 255, 0);
//    ellipse(points[ iBRM ][0], points[ iBRM ][1], 5, 5);
  //}

  // punti nello spazio e relativi testi
  textFont(f);
  textSize(12);
  textAlign(CENTER);
  stroke(120);
  for(int i=0; i < points.length; i++) {
    fill(120, 80);
    ellipse(points[i][0], points[i][1], 5, 5);
    fill(120);
    text("["+i+"]", points[i][0], points[i][1]+15);
    fill(0);
    //text(points[i][0]+","+points[i][1], points[i][0], points[i][1]);
  }  
  
  
  } // fine dell' if(NPOINTS > =0 )
  
  popStyle();
}


////////////////////////////////////////////////////////////////
// vengono generati NVALUES randomici
void inizializza() {
  //println("clicks.size: "+clicks.size() );
  NPOINTS = clicks.size();
  points = new float[clicks.size()][2];
  angles = new float[clicks.size()];
  is     = new int[clicks.size()]; // indici ordinati
  
  for(int i = 0; i < clicks.size(); i++) {
    PVector pippo = clicks.get(i);
    points[i][0] = pippo.x;
    points[i][1] = pippo.y;
  }
  
  iTLM = -1;
//  iBRM = -1;
}
  
////////////////////////////////////////////////////////////////  
void reset() {
  clicks.clear();
  inizializza();
}

////////////////////////////////////////////////////////////////
void mousePressed() {
  PVector v = new PVector(mouseX, mouseY);
  //println(v.x+" - "+v.y);
  clicks.add(v);
  
  inizializza();
  
  ic.init(points);
  ic.calcola();
  iTLM = ic.getTopLeftMostIndex();
//  iBRM = ic.getBottomRightMostIndex();

  angles = ic.getAngles();
  is = ic.getOrderedIndex();
  indiciInviluppoConvesso = new int[ic.getNumberOfVertices()];
  indiciInviluppoConvesso = ic.getIndexOfVertices();
  
//  println();
//  println("        n vertici:\t"+ic.getNumberOfVertices());
//  
//  print("           indici:\t");
//  for(int i = 0; i < indiciInviluppoConvesso.length; i++) {
//    print(i+"\t");
//  }
//  println();
//  print("vertici inviluppo:\t");
//  for(int i = 0; i < indiciInviluppoConvesso.length; i++) {
//    print(indiciInviluppoConvesso[i]+"\t");
//  }
//  println();
}
////////////////////////////////////////////////////////////////
void keyPressed() {
  switch(key) {
    case ' ':
      reset();
    break;
    default:
    break;
  }
}



