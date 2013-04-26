class Chase extends Routine {
  void draw() {
    background(0);
    stroke(color(random(varMin[0],varMax[0]), random(varMin[1],varMax[1]), random(varMin[2],varMax[2])));

    long frame = frameCount - modeFrameStart;
    line(frame/3.0%displayWidth, 0, frame/3.0%displayWidth, displayHeight);
    line((frame/3.0+2)%displayWidth, 0, ((frame/3.0+2))%displayWidth, displayHeight);

    if (frame > FRAMERATE*TYPICAL_MODE_TIME) {
      newMode();
    }
  }
}

