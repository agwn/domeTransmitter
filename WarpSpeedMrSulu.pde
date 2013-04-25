class WarpSpeedMrSulu extends Routine {
  int NUM_STARS = 100;
  WarpStar[] warpstars;

  void setup(PApplet parent) {
    super.setup(parent);
    warpstars = new WarpStar[NUM_STARS];
    for (int i = 0; i<NUM_STARS; i++) {
      warpstars[i] = new WarpStar();
    }
  }

  void draw() {
    background(0);
    stroke(255);

    for (int i=0; i<NUM_STARS; i++) {
      warpstars[i].draw();
    }

    if (frameCount - modeFrameStart > FRAMERATE*TYPICAL_MODE_TIME) {
      newMode();
    }
  }
}


class WarpStar {
  float x;
  float y;
  float vx;
  float vy;
  float dx;
  float dy;
  int len;

  float r;
  float g;
  float b;

  public WarpStar() {
    this.reset();
  }

  public void reset() {

    //RGB 252/23/218
    //r = 252;
    //g = 23;
    //b = 218;
    //r = int(map(y, 0, displayHeight, 0, 255));
    //g = 0;
    //b = 0;
    //r = random(64, 255);
    //g = random(64, 255);
    //b = random(64, 255);
    r = random(rMin, rMax);
    g = random(gMin, gMax);
    b = random(bMin, bMax);
    // scale brightness.
    float bright = random(.5, 2);
    r = r*bright;
    g = g*bright;
    b = b*bright;

    y = int(random(0, displayHeight));

    if (random(0, 1) > 0.80) {
      x = int(random(0, displayWidth));
      vx = (random(0, 1)-0.5)*1.5;
      vy = 0;
      len = int(abs(vx)+1 * 10);
    }
    else {
      x = int(random(0, displayWidth));
      vx = 0;
      vy = (random(0, 1)-0.40)*1.5;
      len = int(abs(vy)+1 * 10);
    }

//    // override values for testing
//    if (true) {
//      x = int(random(0, displayWidth));
//      vx = (random(0, 1)-0.5)*1.5;
//      vy = (random(0, 1)-0.45)*1.5;
//      len = int(abs(vx)+1 * 10);
//    }

//    print("vy: ");
//    print(vy);
//    print(" len: ");
//    print(len);

    dx = int(random(2*displayWidth, 10*displayWidth));
    dy = int(random(2*displayHeight, 5*displayHeight));
//    print(" dx: ");
//    print(dx);
//    print(" dy: ");
//    println(dy);
  }

  public void draw() {
    float _r, _g, _b;
    float _x, _y;

    dx--;
    dy--;
    //dx = dx - abs(vx);
    //dy = dy - abs(vy);

    if ((dx > 0) || (dy > 0)) {
      x += vx;
      if (x < 0) x += displayWidth;
      if (x > displayWidth) x -= displayWidth;
      y += vy;
      if (y < 0) y += displayHeight;
      if (y > displayWidth) y -= displayHeight;

      stroke(r, g, b);

      point(x, y);

      _x = x;
      _y = y;
      for (int i=1; i<len; i++) {
        _r = int(0.90*r);
        _g = int(0.90*g);
        _b = int(0.90*b);
        stroke(color(_r, _g, _b));

        _x = (x-(i*vx));
        _y = (y-(i*vy));

        if (_x < 0) _x += displayWidth;
        if (_x > displayWidth) _x -= displayWidth;
        if (_y < 0) _y += displayHeight;
        if (_y > displayHeight) _y -= displayHeight;
        point(_x, _y);
      }
    }
    else {
      this.reset();
    }
  }
}

