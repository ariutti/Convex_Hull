/*
 * La classe 'NVILUPPO CONVESSO' si occupa di valutare l'inviluppo convesso dati n punti 
 * nello spazio bidimensionale. La classe utilizza l'algoritmo di Graham per valutare l'inviluppo.
 * La classe prende in ingresso l'array di punti nello spazio.
 * ALGORITMO DI GRAHAM:
 * 1) trova il punto che abbia ordinata minima e ascissa minima, identificato come P0;
 * 2) riordina i rimanenti n-1 punti in base all'angolo; 
 * 3) elimina i punti allineati (NON IMPLEMENTATO);
 * 4) inserisci P0 nell'inviluppo CORRENTE e, se n >= 2 inserisci anche P1;
 * 5a) per ogni punto Pi tale che i = 3, ..., n;
 * 5b) per ogni j=i-1, ..., 0, scandisci a RITROSO i punti dell'inviluppo convesso CORRENTE ed elimina Pj
 *     se NON si trova dalla STESSA PARTE di P0 rispetto alla retta R passante per Pj e Pj-1. 
 *     Termina la scansione se Pj non deve essere eliminato;
 * 5c) Aggiungi Pi all'inviluppo convesso Corrente.
 */

class InviluppoConvesso {
  
  float[][] punti;  // i punti (x, y) passati per come sono stati creati in origine
  float[] angles;   // qui abbiamo tutti gli angoli di tutti i punti (non ordinati)
  
  // variabili necesarie per effettuare l'ordinamento
  float[] aux; 
  float[] b;
  int[] iB;
  
  int iTLM;   // l'indice del punto nell'angolo in ALTO a SINISTRA
  int[] iOrdinati;    // gli indici per come sono stati ordinati
 
  // variabili necesarie per il calcolo dell'inviluppo convesso
  CopyOnWriteArrayList< Integer > ipna;  // indici dei punti non allineati
  CopyOnWriteArrayList< Integer > ivic;  // indici dei vertici che compongono l'inviluppo convesso
  int nvic;     // numero dei vertici per l'inviluppo convesso
  Retta r;
  
  // *** COSTRUTTORE **********************************************************************************
  InviluppoConvesso( ) {
    // non fare nulla
  }
  
  // *** INIT *****************************************************************************************
  void init(float[][] original) {
    // se l'array di partenza è nullo non fare nulla e ritorna al chiamante
    if (original == null) {
      println("array di partenza vuoto");
      return;
    }
    
    // in alternativa costruisco tutti gli array di supporto necessari
    punti  = new float[original.length][2];
    punti = original;
    
    angles = new float[original.length];
    
    // 4 array di supporto per completare l'ordinamento
    aux   = new float[punti.length];
    iOrdinati = new int[punti.length];
    b     = new float[punti.length];
    iB    = new int[punti.length];

    // lista e retta necessari per la costrusione dell'inviluppo
    ipna = new CopyOnWriteArrayList<Integer>();
    ivic = new CopyOnWriteArrayList<Integer>(); 
    r = new Retta();
  }
  

  // *** CALCOLA **************************************************************************
  void calcola() {
    
    //*************************************************************************************
    // ALGORITMO DI GRAHAM - PARTE 1
    //*************************************************************************************
    // trova quali sono gli indici del punto top left most
    // su base delle coordinane X e Y
    iTLM = findMinIndex(punti);
    
    //*************************************************************************************
    // ALGORITMO DI GRAHAM - PARTE 2
    //*************************************************************************************
    // per ognuno dei punti dell'insieme calcolane l'angolo (in radianti) compreso tra:
    // - la retta orizzontale passante per il punto di indice 'iTLM'
    // - la retta congiunte il punto e il punto di 'iTLM'
    for(int i = 0; i < punti.length; i++) {
      if( i != iTLM)
        angles[i] = calcolaAngolo(punti[iTLM][0], punti[iTLM][1], punti[i][0], punti[i][1] );
      else 
        angles[i] = 0.0; // se l'indice in esame è proprio quello del punto in ALTO a SINISTRA, assegna angolo nullo
    }
    
    
    //*************************************************************************************
    // solo se ci sono più di 2 punti calcolo l'inviluppo convesso
    //if(punti.length > 2) {    
      
      // copio gli angoli nell'array ausiliario
      for(int i = 0; i< angles.length; i++) {
        aux[i] = angles[i];
        iOrdinati[i] = i;
      }
            
      //*************************************************************************************
      // effettuo l'ordinamento degli indici su base degli angoli
      // una volta che la funzione seguente avrà completato il suo ciclo, si avrà che
      // - angles[]  resta invariato;
      // - aux[]     contiene gli stessi identici valori di angles[] però ordinati in ordine crescente;
      // - iOrdinati[]  contiene gli indici elencati in ordine.
      riOrdina(0, punti.length-1);  
    
      
      //*************************************************************************************
      // una volta ordinati gli indici per angolo crescente devo occuparmi di eliminare 
      // tutti i punti che sono allineati o coincidenti.
      ipna.add( iOrdinati[0] ); // come scrivere "lista.add( indiceMIN );"
      float DISTANZA  = -1.0;
      float ANGOLO    = -1.0;
      for( int i = 1; i < iOrdinati.length; i++) {
        int iPlast = ipna.get( ipna.size()-1 ); // recupero l'ultimo elemento della lista (indice dell'ultimo punto aggiunto)
        float ANGOLOPlast  = angles[ iPlast ];
        float ANGOLOPi = angles[ iOrdinati[i] ];
        if ( ANGOLOPi == ANGOLOPlast ) {
          // i punti di indici iPlast e indici[i] sono allineati o coincidenti
          float DISTANZAPlast  = dist( punti[ iPlast ][0], punti[ iPlast ][1], punti[ iTLM ][0], punti[ iTLM ][1] );
          float DISTANZAPi = dist( punti[ iOrdinati[i] ][0], punti[ iOrdinati[i] ][1], punti[ iTLM ][0], punti[ iTLM ][0] );
          if( DISTANZAPi > DISTANZAPlast ) {
            // se DISTANZAPi è maggiore di DISTANZA significa che il punto di indice "indici[i]", pur essendo allineato 
            // al punto di indice "iPlast", è più distante rispetto al punto di indice "indiceMIN".
            // per questo rimuovo "iPlast" dalla lista e, al suo posto, inserisco "indici[i]".
            ipna.remove( ipna.size()-1 );
            ipna.add( iOrdinati[i] );
          } else {
            // in caso contrario ( DISTANZAPi <= DISTANZA ) non facci nulla. Il punto di indice iPlast" è già il punto più distante 
            // da "indiceMIN" seppur allineato con il punto "indici[i]".
          }
        } else {
          // se l'angolo che il punto di indice "indici[i]" forma con P0 (indiceMIN)
          // non è uguale ad ANGOLO, allora significa che può essere soltanto maggiore
          // questo perchè l'ordinamento per angolo crescente è già stato effettuato 
          // precedentemente, per cui possiamo proseguire
          ipna.add( iOrdinati[i] );
        }
      }
      
      println("la lista di punti NON allineati conta "+ipna.size()+" elementi:");
      for(int i=0; i < ipna.size(); i++) {
        println(i+") indice: "+ipna.get(i)+", angolo: "+degrees(angles[ ipna.get(i) ])+";");
      }
      println();



      if(ipna.size() > 2) {  
      //*************************************************************************************
      // CALCOLO DELL'INVILUPPO CONVESSO
          
      //*************************************************************************************
      // ALGORITMO DI GRAHAM - PARTE 4
      //*************************************************************************************
      // aggiungo i primi due punti dell'inviluppo convesso
      // il TOP LEFT point e il successivo in ordine di angolo
      ivic.add( ipna.get(0) );
      ivic.add( ipna.get(1) );     
      
      //*************************************************************************************
      // ALGORITMO DI GRAHAM - PARTE 5a, 5b e 5c
      //*************************************************************************************
      for( int i=2; i < ipna.size(); i++) {    
        for(int j= ivic.size()-1; j>0; j--) {
          int iPunto1 = ivic.get( j );
          int iPunto2 = ivic.get( j-1 );
          r.set(punti[iPunto1][0], punti[iPunto1][1], punti[iPunto2][0], punti[iPunto2][1]);
          int iPunto0 = ivic.get(0);
          //int iPuntoJ = iOrdinati[i];
          int iPuntoJ = ipna.get(i);
          boolean bSP = stessaParte( r, punti[ iPunto0 ][0], punti[ iPunto0 ][1], punti[ iPuntoJ ][0], punti[ iPuntoJ ][1]);
          if( !bSP ) {        
            ivic.remove(j);
          }
        }
        ivic.add(ipna.get(i));
      }
      nvic =  ivic.size();
    } 
  }
  
  
  // *** STESSA PARTE *********************************************************************************
  boolean stessaParte( Retta retta_, float P1x_, float P1y_, float P2x_, float P2y_) {
    float dx, dy, dx1, dx2, dy1, dy2;
    dx  = retta_.x2 - retta_.x1;
    dy  = retta_.y2 - retta_.y1;
    dx1 = P1x_ - retta_.x1;
    dy1 = P1y_ - retta_.y1;
    dx2 = P2x_ - retta_.x2;
    dy2 = P2y_ - retta_.y2;
    return ((((dx*dy1) - (dy*dx1))*((dx*dy2)-(dy*dx2))) >= 0);
  }
  
  // *** FIND MIN INDEX *******************************************************************************
  int findMinIndex(float[][] a) {  
    float winnerValue = Float.MAX_VALUE;
    int index = -1;
    for(int i=0; i < a.length; i++) {
      // trovo due y uguali
      if(a[i][1] == winnerValue) {
        // allora discrimino in base alla x
        if (a[i][0] <= a[index][0]) {
          index = i;
        }
      } else if (a[i][1] < winnerValue) {
        // eleggo l'attuale y a 'vincente'
        winnerValue = a[i][1];
        index = i;
      }
    }
    return index;
  }
  
  // *** CALCOLA ANGOLO *******************************************************************************
  float calcolaAngolo(float cx, float cy, float px, float py){
      float ADDENDO = 0.0;
      float FATTORE = 1.0;
      float dx = cx - px;
      float dy = cy - py;
      int quadrante = -1;
      if(py >= cy) {
        //quadranti I e II
        if(px <= cx) {
          quadrante = 1;
          ADDENDO = 0.0;
          FATTORE = -1.0;       
        } else {
          quadrante = 2;
          ADDENDO = PI;
          FATTORE = -1.0; 
        }
      } else {
        //quadranti III e IV
        if(px > cx) {
          quadrante = 3; 
          ADDENDO = PI;
          FATTORE = -1.0; 
        } else {
          quadrante = 4;
          ADDENDO = 2*PI;
          FATTORE = -1.0;
        }
      }
      if(dx == 0 )
        dx = 0.00001; // per prevenire una divisione per zero
      //angle = ADDENDO + FATTORE*(float)Math.atan(dy/dx);
      float angle = ADDENDO + FATTORE*atan(dy/dx);
      return angle;
  }
  
  // *** MERGE FUNCTIONS ******************************************************************************
  void riOrdina(int left, int right) {
    // effettuo il primo ordinamento
    mergeSort(aux, left, right);  // col fatto che merge sort è una funzione interna, forse posso evitare di passare aux come argomento
  }
  
  void mergeSort (float[] a, int left, int right) {
      if (left < right ) {
        int center = floor((left + right) / 2);
        mergeSort(a, left, center);
        mergeSort(a, center+1, right); 
        merge(a, left, center, right); 
      } 
  }
  
  void merge (float[] a, int left, int center, int right) {
    int i = left;
    int j = center+1;
    int k = left;
    
    while ( (i <= center) && (j <= right) ) {
      if (a[i] <= a[j]) {
        b[k] = a[i];
        iB[k] = iOrdinati[i];
        i++;
      } else {
        b[k] = a[j];
        iB[k] = iOrdinati[j];
        j++;
      }
      k ++;
    }
  
    while (i <= center) {
      b[k] = a[i];
      iB[k] = iOrdinati[i];
      i ++;
      k ++;
    }
  
    while (j <= right) {
      b[k] = a[j];
      iB[k] = iOrdinati[j];
      j ++;
      k ++;
    }
  
    for (k = left; k <= right; k++) {
      a[k] = b[k];
      iOrdinati[k] = iB[k];
    }
  }
  
  
  
  // *** GETTERS **************************************************************************************
  int getTopLeftMostIndex(){
   return iTLM; 
  }
  
  // ottieni gli angoli (non ordinati)
  float[] getAngles() {
    return angles;
  } 

  // ottieni in uscita l'array con gli indici degli elementi originari, ri-ordinati
  int[] getOrderedIndex() {   
    return iOrdinati;
  }
  
  // una volta ottenuto il poligono convesso è possibile ottenerne
  int getNumberOfVertices() {
    return ivic.size();    
  }
  
  int[] getIndexOfVertices() {
    int[] a = new int[ ivic.size() ];
    for(int i=0; i<a.length; i++) {
      a[i] = ivic.get(i);
    }
    return a;
  }
  
}


