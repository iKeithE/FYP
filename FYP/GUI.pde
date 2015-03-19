class Test
{
  float x, y;

  //Constructor
  Test()
  {
    x = 100;
    y = 100;
  }



  void GUI()
  {
    pushMatrix();
    translate(x, y);
    rotate(theta);
    theta += 0.1f;
    x += 1;
    y += 1;
    stroke(255);
    fill(255);
    rect(-25, -25, 50, 50);
    popMatrix();
  }
}

