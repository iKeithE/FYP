//Keith Eyre
//D11124850
//DT228/4
//Final Year Project - Mapping and RealTime Projection

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

void setup(){
  //Set window size
  size(1000, 800);
  
  //Load background image
  background = loadImage("data/background.jpg");
  ball = loadImage("data/ball.png");
  
  cp5 = new ControlP5(this);
  
  //Create button to pick an image for the head
  cp5.addButton("Head")
     .setValue(0)
     .setPosition(0,525)
     .setSize(200, 50);
     
  cp5.addButton("Right Arm")
     .setValue(0)
     .setPosition(0,595)
     .setSize(200, 50);
  
  cp5.addButton("Left Arm")
     .setValue(0)
     .setPosition(0,665)
     .setSize(200, 50);
     
  cp5.addButton("Torso")
     .setValue(0)
     .setPosition(225,525)
     .setSize(200, 50);
     
  cp5.addButton("Right Leg")
     .setValue(0)
     .setPosition(225,595)
     .setSize(200, 50);
     
     cp5.addButton("Left Leg")
     .setValue(0)
     .setPosition(225,665)
     .setSize(200, 50);
  
  
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
 
  //Gets new data from Kinect
  context.update();
 
  //Get debth image from Kinect
  PImage depthImage=context.depthImage();
  depthImage.loadPixels();
 
  //get user pixels - array of the same size as depthImage.pixels, that gives information about the users in the depth image:
  int[] upix=context.userMap();
 
  //Colour users
  for(int i=0; i < upix.length; i++){
    if(upix[i] > 0){
      //there is a user on that position
      //NOTE: if you need to distinguish between users, check the value of the upix[i]
      img.pixels[i]=color(0,255,0);
    }else{
      //add depth data to the image
     img.pixels[i]=depthImage.pixels[i];
    }
  }
  img.updatePixels();
 
  //Draw the Kinect input to the centre of the window
  image(img,0,0);
 
  //draw significant points of users
 
  //get array of IDs of all users present 
  int[] users=context.getUsers();
 
  ellipseMode(CENTER);
 
  //iterate through users
  for(int i=0; i < users.length; i++){
    int uid=users[i];
    
    //draw center of mass of the user (simple mean across position of all user pixels that corresponds to the given user)
    PVector realCoM=new PVector();
    
    //get the CoM in realworld (3D) coordinates
    context.getCoM(uid,realCoM);
    PVector projCoM=new PVector();
    
    //convert realworld coordinates to projective (those that we can use to draw to our canvas)
    context.convertRealWorldToProjective(realCoM, projCoM);
    fill(255,0,0);
    ellipse(projCoM.x,projCoM.y,10,10);
 
    //check if user has a skeleton
    if(context.isTrackingSkeleton(uid)){
      //draw head
      PVector realHead=new PVector();
      
      //get realworld coordinates of the given joint of the user (in this case Head -> SimpleOpenNI.SKEL_HEAD)
              context.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_HEAD,realHead);
      PVector projHead=new PVector();
      context.convertRealWorldToProjective(realHead, projHead);
      fill(0,255,0);
      ellipse(projHead.x,projHead.y,10,10);
 
      //draw dot on left hand
      PVector realLHand=new PVector();
      context.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_LEFT_HAND,realLHand);
      PVector projLHand=new PVector();
      context.convertRealWorldToProjective(realLHand, projLHand);
      fill(255,255,0);
      ellipse(projLHand.x,projLHand.y,10,10);
      
      //draw dot on right hand
      PVector realRHand=new PVector();
      context.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_RIGHT_HAND,realRHand);
      PVector projRHand=new PVector();
      context.convertRealWorldToProjective(realRHand, projRHand);
      //fill(255,255,0);
      //ellipse(projRHand.x,projRHand.y,10,10);
      
      //Draw to hand location
      image(ball, projRHand.x-25, projRHand.y-25);
    }
  }
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
