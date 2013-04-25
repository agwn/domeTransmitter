class ColorDrop extends Routine {
  void draw() {
    background(0);

    float frame_mult = 3;  // speed adjustment

    // lets add some jitter
    modeFrameStart = modeFrameStart - min(0, int(random(-3, 6)));

    long frame = frameCount - modeFrameStart;


    for (int col = 0; col < displayWidth; col++) {
      float phase = sin((float)((col+frame*frame_mult)%displayWidth)/displayWidth*3.146 + random(0, .01));

      float r = 0;
      float g = 0;
      float b = 0;


      if ((col+frame*frame_mult)%(3*displayWidth) < displayWidth) {
        r = random(255)*phase;
        g = random(128);
        b = random(128);
      }
      else if ((col+frame*frame_mult)%(3*displayWidth) < displayWidth*2) {
        r = random(128);
        g = random(255)*phase;
        b = random(128);
      }
      else {
        r = random(128);
        g = random(128);
        b = random(255)*phase;
      }

      stroke(r, g, b);
      line(col, 0, col, displayHeight);
    }

    if (frame > FRAMERATE*TYPICAL_MODE_TIME) {
      newMode();
    }
  }
}

