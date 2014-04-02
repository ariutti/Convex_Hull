class Retta {
  float x1;
  float y1;
  float x2;
  float y2;
  boolean bDebug;
  
  Retta() {
    // non fare nulla
    bDebug = false;
  }
  
  void set(float x1_, float y1_, float x2_, float y2_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;
    if(bDebug)
      println("setto la retta passante per ("+(int)x1+", "+(int)y1+") e per ("+(int)x2+", "+(int)y2+");");
  }
}
