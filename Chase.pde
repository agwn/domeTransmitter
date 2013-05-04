class Chase extends Routine {
  void draw() {
    background(0);
    stroke(color(random(varMin[0], varMax[0]), random(varMin[1], varMax[1]), random(varMin[2], varMax[2])));

    long frame = frameCount - modeFrameStart;
    for (int i=0; i<6; i++) {
      line((frame/3.0+random(2*i,2.5*i))%displayWidth, 0, ((frame/3.0+random(2*i,2.5*i)))%displayWidth, displayHeight);
    }
    if (frame > FRAMERATE*TYPICAL_MODE_TIME) {
      newMode();
    }
  }
}

