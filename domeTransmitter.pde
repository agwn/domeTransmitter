import processing.serial.*;
import processing.opengl.*;
import java.lang.reflect.Method;
import hypermedia.net.*;
import java.io.*;

// This should be 127.0.0.1, 58802
String transmit_address = "127.0.0.1";
int transmit_port       = 58082;


// Display configuration
int displayWidth = 60;
int displayHeight = 32;

boolean VERTICAL = false;
int FRAMERATE = 20;
int TYPICAL_MODE_TIME = 6000;

float bright = 0.5;  // Global brightness modifier

Routine drop = new Seizure();
Routine backupRoutine = null;

//WiiController controller;

Routine[] enabledRoutines = new Routine[] {
  new WarpSpeedMrSulu(), 
  new Warp(new WarpSpeedMrSulu(), false, false, 0.5, 0.5), 
  //new RGBRoutine(), 
  new Warp(new RGBRoutine(), true, true, 0.5, 0.5), 
  //new RainbowColors(), 
  new Warp(new RainbowColors(), true, true, 0.5, 0.5), 
  new Warp(null, true, false, 0.5, 0.5), 
  new Waves(), 
  //denew DropTheBomb(), 
  //new Fire(), 
  new ColorDrop(), 
  //new Animator("anim-nyancat", 1, .5, 0, 0, 0), 
  new Bursts(), 
  //new Greetz(), 
  //new Chase(), 
  //new FFTDemo(),
};

int w = 0;
int x = displayWidth;
PFont font;
int ZOOM = 1;

long modeFrameStart;
int mode = 0;


int direction = 1;
int position = 0;
Routine currentRoutine = null;

LEDDisplay sign;

PGraphics fadeLayer;
int fadeOutFrames = 0;
int fadeInFrames = 0;

Serial ctrlPort;
String input = "";
String kbdInput = "";
int lf = 10; // ASCII linefeed

int rMin = 128;
int rMax = 255;
int gMin = 128;
int gMax = 255;
int bMin = 128;
int bMax = 255;


void setup() {
  size(displayWidth, displayHeight, P2D);

  frameRate(FRAMERATE);

  sign = new LEDDisplay(this, displayWidth, displayHeight, true, transmit_address, transmit_port);
  sign.setAddressingMode(LEDDisplay.ADDRESSING_HORIZONTAL_NORMAL);
  sign.setEnableGammaCorrection(true);

  setMode(0);

  // configure serial input
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  println(list);
  // List all the available serial ports:
  println(Serial.list());

  // The first serial port on my mac is the Arduino so I just open that.
  // Consult the output of println(Serial.list()); to figure out which you
  // should be using.
  if (Serial.list().length > 0) {
    ctrlPort = new Serial(this, Serial.list()[0], 115200);
    //ctrlPort = new Serial(this, "COM46", 115200);

    // Fire a serialEvent() when when a linefeed comes in to the serial port.
    ctrlPort.bufferUntil(lf);
    ctrlPort.write(lf);
  }

  //controller = new WiiController();

  for (Routine r : enabledRoutines) {
    r.setup(this);
  }

  drop.setup(this);
}

void setFadeLayer(int g) {
  fadeLayer = createGraphics(displayWidth, displayHeight, P2D);
  fadeLayer.beginDraw();
  fadeLayer.stroke(g);
  fadeLayer.fill(g);
  fadeLayer.rect(0, 0, displayWidth, displayHeight);
  fadeLayer.endDraw();
}

void setMode(int newMode) {
  currentRoutine = enabledRoutines[newMode];

  mode = newMode;
  modeFrameStart = frameCount;
  println("New mode " + currentRoutine.getClass().getName());

  currentRoutine.reset();
}

void newMode() {
  int newMode = mode;
  String methodName;

  fadeOutFrames = FRAMERATE;
  setFadeLayer(240);
  if (enabledRoutines.length > 1) {
    while (newMode == mode) {
      newMode = int((mode+1)%enabledRoutines.length);
    }
  }

  setMode(newMode);
}


void newMode(int mode) {
  int newMode = mode;
  String methodName;

  fadeOutFrames = FRAMERATE;
  setFadeLayer(240);
  if ((mode >= 0) && (mode < enabledRoutines.length)) {
    newMode = mode;
  }
  else {
    if (enabledRoutines.length > 1) {
      while (newMode == mode) {
        newMode = int((mode+1)%enabledRoutines.length);
      }
    }
  }

  setMode(newMode);
}

void handleInput(String s) {
  //print("received: " + s);
  // validate and process input
  switch (s.charAt(0)) {
  case 'm': // mode change
    // mode change
    if ('c' == s.charAt(1) && !switching_mode) {
      newMode();
      switching_mode = true;
    }
    else if (/*('0' <= s.charAt(1)) && (s.charAt(1) <='9') &&*/ (int(s.substring(1)) < enabledRoutines.length) && !switching_mode) {
      println("int: "+int(s.substring(1)));
      if (mode != (s.charAt(1)-'0')) {
        mode = s.charAt(1)-'0';
        newMode(mode);
        switching_mode = true;
      } // else already in that mode
    }
    else {
      println("Invalid mode selected");
    }
    break;
  case 'c':  // color change
    break;
  case 'r':  // set red value
    if (s.length() > 3) {
      print("set rMin: ");
      println(s.substring(1, 4));
      rMin = int(s.substring(1, 4));
    }
    break;
  case 'g':  // set green value
    if (s.length() > 3) {
      print("set gMin; ");
      println(s.substring(1, 4));
      gMin = int(s.substring(1, 4));
    }
    break;
  case 'b':  // set blue value
    if (s.length() > 3) {
      print("set bMin: ");
      println(s.substring(1, 4));
      bMin = int(s.substring(1, 4));
    }
    break;
  case 'R':  // set red value
    if (s.length() > 3) {
      print("set rMax: ");
      println(s.substring(1, 4));
      rMax = int(s.substring(1, 4));
    }
    break;
  case 'G':  // set green value
    if (s.length() > 3) {
      print("set gMax: ");
      println(s.substring(1, 4));
      gMax = int(s.substring(1, 4));
    }
    break;
  case 'B':  // set blue value
    if (s.length() > 3) {
      print("set bMax: ");
      println(s.substring(1, 4));
      bMax = int(s.substring(1, 4));
    }
    break;
  default:
    println("Invalid command!");
    break;
  }
}


// Buffer a string until a linefeed is encountered then process as control command.
void keyPressed() {
  if (key < 255) {
    kbdInput += str(key);
    if (key == lf) {
      print("rcvd from KB: " + kbdInput);
      handleInput(kbdInput);

      kbdInput = "";
    }
  }
}


// Process a line of text from the serial port.
void serialEvent(Serial p) {
  input = ctrlPort.readString();
  // validate and parse string
  print("rcvd from SP: " + input);
  handleInput(input);
}


boolean switching_mode = false; // if true, we already switched modes, so don't do it again this frame (don't freeze the display if someone holds the b button)
int seizure_count = 10;  // Only let seizure mode work for a short time.

void draw() {

  //if (!controller.buttonB) {
  // should test if mode switch is actually done?
  switching_mode = false;
  //}
  /*
  if (controller.buttonA) {
   seizure_count += 1;
   }
   else {
   seizure_count = 0;
   }
   
   // Jump into seizure mode
   if ((controller.buttonA || (keyPressed && key == 'a')) && currentRoutine != drop && seizure_count == 1) {
   drop.draw();
   backupRoutine = currentRoutine;
   currentRoutine = drop;
   drop.reset();
   }
   */
  if (fadeOutFrames > 0) {
    fadeOutFrames--;
    blend(fadeLayer, 0, 0, displayWidth, displayHeight, 0, 0, displayWidth, displayHeight, MULTIPLY);

    if (fadeOutFrames == 0) {
      fadeInFrames = FRAMERATE;
    }
  }
  else if (currentRoutine != null) {
    currentRoutine.draw();
  }
  else {
    println("Current method is null");
  }

  if (fadeInFrames > 0) {
    setFadeLayer(240 - fadeInFrames * (240 / FRAMERATE));
    blend(fadeLayer, 0, 0, displayWidth, displayHeight, 0, 0, displayWidth, displayHeight, MULTIPLY);
    fadeInFrames--;
  }

  if (currentRoutine.isDone) {
    currentRoutine.isDone = false;
    //newMode();
  }
  //}

  sign.sendData();
}

