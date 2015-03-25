/*---------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                          Keith  Eyre                                  DIT Kevin St. */
/*                                                           D11124850                             DT228/4 - 2014-2015 */
/*                                                 Real-Time Mapping & Projection                      March 26th 2015 */
/*                                                      Final Year Project                                             */
/*---------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                         Imports                                                     */
/*---------------------------------------------------------------------------------------------------------------------*/

import processing.opengl.*;                // OPEN_GL
import controlP5.*;                        // ControlP5 - GUI Interface Builder
import SimpleOpenNI.*;                     // SimpleOpenNI - Kinect library
import org.openkinect.processing.*;
import org.openkinect.*;

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                       Global Variables                                              */
/*---------------------------------------------------------------------------------------------------------------------*/

//Initialise ControlP5 for GUI interface
ControlP5 cp5;

ControlWindow controlWindow;

//Initialise Kinect
SimpleOpenNI  kinect;

//Floats
float zoom = 1.5f;
float rotX = radians(180);
float rotY = radians(0);

//PVectors
PVector centerOfMass = new PVector();
PVector userCenterOfBody = new PVector();
PVector userDirection = new PVector();

//PImages
PImage background;

//Texture images
PImage ironmanCostume;
PImage spidermanCostume;
PImage hulkCostume;

int costumeColourR = 225;
int costumeColourG = 0;
int costumeColourB = 0;


/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                       Setup Method                                                  */
/*---------------------------------------------------------------------------------------------------------------------*/

void setup() {
  //Set window size
  size(1024, 780, P3D);

  background = loadImage("background1.png");
//  ironmanCostume = loadImage("");
//  spidermanCostume = loadImage("");
//  hulkCostume = loadImage("");



  cp5 = new ControlP5(this);

  //Add GUI to screen
  addGUI();

  //Initialise kinect
  kinect = new SimpleOpenNI(this);

  //Check if SimpleOpenNI is initialise
  if (kinect.isInit() == false)
  {
    println("Failed to initialise SimpleOpenNI, check Kinect is connected!"); 
    exit();
    return;
  }

  //Get data from Kinect depth sensor
  kinect.enableDepth();

  //Start getting user data
  kinect.enableUser();

  //Disable mirror image from the Kinect to the screen
  kinect.setMirror(false);

  //Enable smoothening
  smooth();

  /*---------------------------------------------------------------------------------------------------------------------*/
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                        Draw Method                                                  */
/*---------------------------------------------------------------------------------------------------------------------*/

boolean backgroundBool;

void draw() {

  pushMatrix();
  //Update data from Kinect
  kinect.update();

  backgroundImage(backgroundBool);

  //Position screen in window
  translate(width/2, height/2, 0);

  //Scale image to screen
  scale(zoom);

  //Setup Mapping
  int[] userMap = kinect.userMap();
  int[] depthMap = kinect.depthMap();

  //Draw Skeleton on screen if available
  int[] users = kinect.getUsers(); //Get how many users from Kinect

  //Move back on the Z-axis so you can see everything
  translate(0, 0, -1000);


  //Draw skeletons for users on screen
  for (int i=0; i < users.length; i++)
  {
    if (kinect.isTrackingSkeleton(users[i]))
      drawSkeleton(users[i]);

    // Get and display the center of mass for each user with 3D crosshair shape
    if (kinect.getCoM(users[i], centerOfMass))
    {
      stroke(0, 255, 0);
      strokeWeight(3);
      beginShape(LINES);
      vertex(centerOfMass.x - 15, centerOfMass.y, centerOfMass.z);
      vertex(centerOfMass.x + 15, centerOfMass.y, centerOfMass.z);

      vertex(centerOfMass.x, centerOfMass.y - 15, centerOfMass.z);
      vertex(centerOfMass.x, centerOfMass.y + 15, centerOfMass.z);

      vertex(centerOfMass.x, centerOfMass.y, centerOfMass.z - 15);
      vertex(centerOfMass.x, centerOfMass.y, centerOfMass.z + 15);
      endShape();
    }//End if
  }//End for

  popMatrix();
}//End Draw Method


/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                  Draw Skeletons Joints                                              */
/*---------------------------------------------------------------------------------------------------------------------*/

boolean skelTrack;

void drawSkeleton(int userId)
{
  if (skelTrack) {
    pushMatrix();
    
    //To fix the invert from OpenNI
    rotateX(rotX);
    rotateY(rotY);

    scale(zoom);

    //Draw the skeleton with lines from joint to joint
    strokeWeight(3);

    drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

    drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

    drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

    drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

    drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);

    //Display the direction the user is pointing
    getUserDirection(userId, userDirection, userCenterOfBody);

    userDirection.mult(150);  // 150mm length
    userDirection.add(userCenterOfBody);

    stroke(255, 200, 200);
    line(userCenterOfBody.x, userCenterOfBody.y, userCenterOfBody.z, userDirection.x, userDirection.y, userDirection.z);

    strokeWeight(1);
    popMatrix();
  }
}


/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                  Get Direction of User                                              */
/*---------------------------------------------------------------------------------------------------------------------*/

void getUserDirection(int userId, PVector direction, PVector center)
{
  //PVectors for HEAD and LEFT & RIGHT shoulders
  PVector joint_HEAD = new PVector();
  PVector joint_LEFT = new PVector();
  PVector joint_RIGHT = new PVector();

  float confidence;

  confidence = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, joint_HEAD);
  confidence = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, joint_LEFT);
  confidence = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, joint_RIGHT);

  //Use the neck as the center point of the users body
  confidence = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, center);

  PVector up = PVector.sub(joint_HEAD, center);
  PVector left = PVector.sub(joint_RIGHT, center);

  direction.set(up.cross(left));
  direction.normalize();
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                     Draw User Limbs                                                 */
/*---------------------------------------------------------------------------------------------------------------------*/

//Forward vector
PVector bForward = new PVector(0, 0, -1);

int strokeR = 0;
int strokeG = 0;
int strokeB = 0;

void drawLimb(int userId, int j1, int j2)
{
  //Draw lines from j1 to j2
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();

  float  confidence;

  //Get joint position fron Kinect
  confidence = kinect.getJointPositionSkeleton(userId, j1, jointPos1);
  confidence = kinect.getJointPositionSkeleton(userId, j2, jointPos2);

  stroke(strokeR, strokeG, strokeB, 100);
  strokeWeight(1);
  //Draw box from joints at position 1 to 2 for skeleton
  PVector c = PVector.add(jointPos1, jointPos2);

  //Get distance between both joints
  float len = PVector.dist(jointPos1, jointPos2);
  c.mult(0.5f);
  pushMatrix();

  //Move to the origin of the limb
  translate(c.x, c.y, c.z);

  //Calcualte the rotation and angles of the 3D boxes to be drawn at
  PVector mForward = PVector.sub(jointPos2, jointPos1);
  mForward.normalize();
  float angle = acos(PVector.dot(bForward, mForward));
  PVector axis = bForward.cross(mForward);

  //Rotate objects on arbitary
  rotate(angle, axis.x, axis.y, axis.z);

  //Draw box
  box(50, 50, len);
  fill(costumeColourR, costumeColourG, costumeColourB);

  popMatrix();

  //Draw the X, Y and Z axis for each of the joints
  drawJointOrientation(userId, j1, jointPos1, 50);
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                  Draw Joint Orientations                                            */
/*---------------------------------------------------------------------------------------------------------------------*/

void drawJointOrientation(int userId, int jointType, PVector jointPosition, float length)
{  
  PMatrix3D  orientation = new PMatrix3D();

  float confidence = kinect.getJointOrientationSkeleton(userId, jointType, orientation);

  if (confidence < 0.0001f)
    //Do nothing
    return;

  //Push position onto the stack
  pushMatrix();

  //Move current position to where the joint is
  translate(jointPosition.x, jointPosition.y, jointPosition.z);

  //Apply the orientation matrix
  applyMatrix(orientation);
  
  //X axis
  stroke(255, 0, 0, confidence * 200 + 55);
  line(0, 0, 0, length, 0, 0);
  
  //Y axis
  stroke(0, 255, 0, confidence * 200 + 55);
  line(0, 0, 0, 0, length, 0);
  
  //Z axis
  stroke(0, 0, 255, confidence * 200 + 55);
  line(0, 0, 0, 0, 0, length);

  popMatrix();
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                     Add GUI Buttons                                                 */
/*---------------------------------------------------------------------------------------------------------------------*/

ListBox costumesList;

void addGUI()
{ 
  //Add button for Skel tracking here
  cp5.addToggle("skeletonTracking")
    .setCaptionLabel("Toggle Skeleton Tracking")
      .setPosition(0, height-200)
        .setSize(175, 50)
          .setValue(true)
            ;
  //Add ListBox of Costumes
  costumesList = cp5.addListBox("costumeList")
    .setCaptionLabel("Costumes")
      .setPosition(0, height-100)
        .setSize(175, 50)
          ;
  //Add Costumes to ListBox
  ListBoxItem lbi = costumesList.addItem("Iron Man Suit", 0);
  lbi = costumesList.addItem("Spider Man Suit", 1);
  lbi = costumesList.addItem("Hulk Suit", 2);

  //Toggle background on and off
  cp5.addToggle("backgroundImage")
    .setCaptionLabel("Toggle Background")
      .setPosition(width-175, height-200)
        .setSize(175, 50)
          .setValue(true)
            ;

  //Close application
  cp5.addButton("closeApp")
    .setCaptionLabel("Exit Application")
      .setPosition(width-175, height-100)
        .setSize(175, 50)
          ;
}//End addGUI method

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                     ControlEvent for Buttons and List Items                                         */
/*---------------------------------------------------------------------------------------------------------------------*/

void controlEvent(ControlEvent theEvent) {

  if (theEvent.isGroup() && theEvent.name().equals("costumeList")) {
    int cost = (int)theEvent.group().value();

    //Change costumes, stoke, and background for each item
    switch(cost)
    {
    case 0:
      println("Iron Man rocks!");
      background = loadImage("background1.png");
      backgroundImage(backgroundBool);
      costumeColourR = 255;
      costumeColourG = 0;
      costumeColourB = 0;
      strokeR = 255;
      strokeG = 215;
      strokeB = 0;
      break;

    case 1:
      println("Spiderman rocks");
      background = loadImage("background2.png");
      backgroundImage(backgroundBool);
      costumeColourR = 255;
      costumeColourG = 0;
      costumeColourB = 0;
      strokeR = 0;
      strokeG = 0;
      strokeB = 0;
      break;

    case 2:
      println("The Hulk rocks");
      background = loadImage("background3.png");
      backgroundImage(backgroundBool);
      costumeColourR = 0;
      costumeColourG = 255;
      costumeColourB = 0;
      strokeR = 0;
      strokeG = 100;
      strokeB = 0;
      break;

    default:
    }
  }
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                             Button Functionallity Methods                                           */
/*---------------------------------------------------------------------------------------------------------------------*/
void skeletonTracking(boolean theFlag) {
  if (theFlag==false)
  {
    skelTrack = false;
      println("Skeleton Tracking is off");
  } else 
  {
    skelTrack = true;
    println("Skeleton Tracking is on");
  }
}

void limbTextures(boolean theFlag) {
  if (theFlag==true) {
    println("Limb is on");
  } else {
    println("Limb is off");
  }
}

//Toggle background image on or off
void backgroundImage(boolean theFlag) {
  if (theFlag==true) {
    background(background);
    backgroundBool = true;
  } else {
    background(0, 0, 0);
    backgroundBool = false;
  }
}

//Close application
void closeApp(boolean theFlag) {
  println("Closing Application");
  exit();
}



/*---------------------------------------------------------------------------------------------------------------------*/
/*                                     User Entering/ Exiting Field of View Methods                                    */
/*---------------------------------------------------------------------------------------------------------------------*/

// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  kinect.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  println("onVisibleUser - userId: " + userId);
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                      End of Sketch                                                  */
/*---------------------------------------------------------------------------------------------------------------------*/
