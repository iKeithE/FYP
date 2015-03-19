/*---------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                          Keith  Eyre                                  DIT Kevin St. */
/*                                                           D11124850                             DT228/4 - 2014-2015 */
/*                                                 Real-Time Mapping & Projection                                      */
/*                                                      Final Year Project                                             */
/*---------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                         Imports                                                     */
/*---------------------------------------------------------------------------------------------------------------------*/

import processing.opengl.*;                //OPEN_GL
import controlP5.*;                        // ControlP5 - GUI Interface Builder
import SimpleOpenNI.*;                     //SimpleOpenNI - Kinect library
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

//Instansiate GUI ineer class
GUI gui = new GUI();



/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                       Setup Method                                                  */
/*---------------------------------------------------------------------------------------------------------------------*/

void setup() {
  //Set window size
  size(1024, 780, P3D);

  cp5 = new ControlP5(this);


  cp5.addButton("colorA")
    .setValue(0)
      .setPosition(100, 100)
        .setSize(200, 50)
          ;

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
  kinect.setMirror(true);

  //Enable smoothening
  smooth();

  /*---------------------------------------------------------------------------------------------------------------------*/
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                        Draw Method                                                  */
/*---------------------------------------------------------------------------------------------------------------------*/

void draw() {


  //Update data from Kinect
  kinect.update();

  //Set Background
  background(0, 0, 0);

  //Do inner class calls here (after backgroud for GUI stuff) 



  //Position screen in window
  translate(width/2, height/2, 0);


  // rotateX(rotX); //To fix the invert from OpenNI.... seems reasonable
  //rotateY(rotY);

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

      fill(0, 0, 0);
      text(Integer.toString(users[i]), centerOfMass.x, centerOfMass.y, centerOfMass.z);
    }//End if
  }//End for
}//End Draw Method


/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                  Draw Skeletons Joints                                              */
/*---------------------------------------------------------------------------------------------------------------------*/

void drawSkeleton(int userId)
{
  pushMatrix();
  rotateX(rotX); //To fix the invert from OpenNI.... seems reasonable
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

void drawLimb(int userId, int j1, int j2)
{
  //Draw lines from j1 to j2
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();

  float  confidence;

  //Get joint position fron Kinect
  confidence = kinect.getJointPositionSkeleton(userId, j1, jointPos1);
  confidence = kinect.getJointPositionSkeleton(userId, j2, jointPos2);

  stroke(255, 255, 255, confidence * 200 + 55);

  //Draw from joints at position 1 to 2 for skeleton
  line(jointPos1.x, jointPos1.y, jointPos1.z, jointPos2.x, jointPos2.y, jointPos2.z);

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

  if (confidence < 0.001f)
    //Do nothing
    return;

  //Push position onto the stack
  pushMatrix();

  //Move current position to where the joint is
  translate(jointPosition.x, jointPosition.y, jointPosition.z);

  //Apply the orientation matrix
  applyMatrix(orientation);

  //Draw orientation lines: X = RED, Y = GREEN, Z = BLUE
  //      R   G  B          opacity

  //X axis
  stroke(255, 0, 0, confidence * 200 + 55);
  line(0, 0, 0, length, 0, 0);
  // y - g
  stroke(0, 255, 0, confidence * 200 + 55);
  line(0, 0, 0, 0, length, 0);
  stroke(0, 0, 255, confidence * 200 + 55);
  line(0, 0, 0, 0, 0, length);

  popMatrix();
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                     Add Buttons                                                     */
/*---------------------------------------------------------------------------------------------------------------------*/

void addButton()
{
  //Add button for Skel tracking here

  //Add button for Orientation tracking here

  //Add button for costume super imposing here
}

/*---------------------------------------------------------------------------------------------------------------------*/
/*                                                     Extra Methods                                                   */
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
  //println("onVisibleUser - userId: " + userId);
}



void toggle(boolean theFlag) {
  if (theFlag==true) {
    println("a toggle event. TRUE");
  } else {
    println("a toggle event.FALSE");
  }
}

