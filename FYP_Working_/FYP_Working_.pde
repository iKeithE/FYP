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
import processing.opengl.*;

ControlP5 cp5;
ControlWindow controlWindow;

SimpleOpenNI  context;
PImage img;
Kinect kinect;

public PImage background;
PImage ball;

PMatrix3D  orientation = new PMatrix3D();//create a new matrix to store the steadiest orientation (used in rendering)
PMatrix3D  newOrientaton = new PMatrix3D();//create a new matrix to store the newest rotations/orientation (used in getting data from the sensor)

public PVector jointPos = new PVector();

public PShape IronMan;

public PVector jointPos_LeftHand = new PVector();

//Start camera at 10 degrees
float deg = 10;

//Variable
boolean drawSkel = false;
boolean drawBot = false;

public float rot = 0;



void setup(){
  //Set window size
  size(1000, 800, P3D);
  
  //Load background image
  background = loadImage("data/background.jpg");
  // The file "bot.obj" must be in the data folder
  // of the current sketch to load successfully
  IronMan = loadShape("Ironman.obj");
  
  
  
  cp5 = new ControlP5(this);
  
  //Create button to pick an image for the head
  cp5.addButton("Enable/ Disable Skeleton")
     .setValue(0)
     .setPosition(0,525)
     .setSize(200, 50)
     .activateBy(ControlP5.PRESSED);
     
    cp5.addButton("Draw 3D Robot")
      .setValue(0)
      .setPosition(0, 570)
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
      }//End if drawSken enabled
      
      //TESTING
      
      newOrientaton.reset();//reset the raw sensor orientation 
      float confidence = context.getJointOrientationSkeleton(i,SimpleOpenNI.SKEL_HEAD,newOrientaton);//retrieve the head orientation from OpenNI
      if(confidence > 0.001){//if the new orientation is steady enough (and play with the 0.001 value to see what works best)
        orientation.reset();//reset the matrix and get the new values
        orientation.apply(newOrientaton);//copy the steady orientation to the matrix we use to render the avatar
      }
      //draw a box using the head's orientation
      translate(jointPos.x, jointPos.y);
      pushMatrix();
      applyMatrix(orientation);//rotate box based on head orientation
      box(40);
      
      
      popMatrix();  
        
        //TESTING END
        
      // get 3D position of a joint
      context.getJointPositionSkeleton(i,SimpleOpenNI.SKEL_HEAD,jointPos);
      
      
      
    }//End if skeleton is being tracked
  }//End checking for 3 users
  
  if(drawBot)
  {
    drawRobot();
  }
  
//  if(keyPressed && key == ' ') {
//    IronMan.scale(1.1);
//    IronMan.rotateZ(0.1);
//  }

  
  //shape(IronMan, 700, 100);
  
}//End Draw Method

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
  
  //Get 3D position of a body part
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,jointPos_LeftHand);
  println("X: " + jointPos_LeftHand.x);
  println("Y: " + jointPos_LeftHand.y);
  println("Z: " + jointPos_LeftHand.z);
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
  
  if(theEvent.getController().getName() == "Enable/ Disable Skeleton")
  {
    if(drawSkel == false)
    {
      drawSkel = true; print("Skeleton Drawing enabled\n");
    } else {drawSkel = false; print("Skeleton Drawing disabled\n");}
  }//End if Skeleton button pressed
  
  
  if(theEvent.getController().getName() == "Draw 3D Robot")
  {
    if(drawBot == false)
    {
      drawBot = true; print("Robot Enabled\n");
    } else {drawBot = false; print("Robot Disabled\n");}
  }
}//End If GUI buttons are pressed

public void drawRobot()
{
  pushMatrix();
  translate(width - 100, (height/2)-100);
  //Head
  rotateY(rot);
  box(40);
  
  translate(0,80,0);
  scale(0.8,1);
  //Body
  box(80);
  translate(70,0,0);
  scale(1,2);
  //Arm
  box(30);
  translate(-140,0,0);
  //Arm
  box(30);
  translate(50,50,0);
  scale(1,1.5);
  //Leg
  box(30);
  translate(40,0,0);
  //Leg
  box(30);
  rotate(45);
  popMatrix();
}//End draw head
