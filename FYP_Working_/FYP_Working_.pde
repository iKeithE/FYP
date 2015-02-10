//Keith Eyre
//D11124850
//DT228/4
//Final Year Project - Mapping and RealTime Projection
import processing.opengl.*;
import controlP5.*;
import javax.swing.JFrame;
import SimpleOpenNI.*;
import org.openkinect.processing.*;
import org.openkinect.*;

ControlP5 cp5;
ControlWindow controlWindow;

SimpleOpenNI  context;
PImage img;
Kinect kinect;

PImage background;
PImage ball;
//Start camera at 10 degrees
float deg = 10;

//Variable
boolean drawSkel = false;



void setup(){
  //Set window size
  size(1000, 800);
  
  //Load background image
  background = loadImage("data/background.jpg");
  ball = loadImage("data/ball.png");
  
  cp5 = new ControlP5(this);
  
  //Create button to pick an image for the head
  cp5.addButton("Enable/ Disable Skeleton")
     .setValue(0)
     .setPosition(0,525)
     .setSize(200, 50)
     .activateBy(ControlP5.PRESSED);
  
  //Initialise context
  context = new SimpleOpenNI(this);
  //Get data from Kinect depth sensor
  context.enableDepth();

  //Start getting user data
  context.enableUser();
  
  //Mirror the image from the Kinect to the screen
  context.setMirror(true);
  
  //Set the size of the Kinect input box
  img=createImage(640,480,RGB);
  img.loadPixels();
}

void draw(){
    background(background);
 
  //Update data from Kinect camera
  context.update();
 
  // draw depth image
  image(context.depthImage(),0,0); 
 
  // for all users from 1 to 3
  int i;
  for (i=1; i<=3; i++)
  {
    // check if the skeleton is being tracked
    if(context.isTrackingSkeleton(i))
    {
      if(drawSkel)
      {
        drawSkeleton(i);  // draw the skeleton
      }
      
    }
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}


//is called everytime a new user appears
void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  //asks OpenNI to start tracking a skeleton data for this user
  //NOTE: you cannot request more than 2 skeletons at the same time due to the perfomance limitation
  //      so some user logic is necessary (e.g. only the closest user will have a skeleton)
  curContext.startTrackingSkeleton(userId);
}

//is called everytime a user disappears
void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
 
}

//If GUI buttons are pressed
public void controlEvent(ControlEvent theEvent) {
  
  if(theEvent.getController().getName() == "Right Leg")
  {
    if(drawSkel == false)
    {
      drawSkel = true;
    } else drawSkel = false;
    
    print("Skeleton Drawing changed");
  }//End if Right Leg Button
  
}//End If GUI buttons are pressed
