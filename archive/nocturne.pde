/*
REFERENCES: 
https://www.youtube.com/watch?v=fcdNSZ9IzJM
https://www.openprocessing.org/sketch/179401
https://www.openprocessing.org/sketch/90192
https://processing.org/examples/sinewave.html
https://processing.org/examples/multipleparticlesystems.html
https://processing.org/examples/simpleparticlesystem.html
*/


//import processing.sound.*;

int xspacing = 16;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave

float theta = 0.0;  // Start angle at 0
//float amplitude = 75.0;  // Height of wave --> moved as parameter
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave

//SoundFile file;

int Y_AXIS = 1;
color c1, c2;

color cloudFill, fade, far, near, mist;

int rainNum = 80;
Rain[] drops = new Rain[rainNum];

ArrayList<Tree> trees = new ArrayList<Tree>();

void setup() {
  size(1500, 700);
  smooth();
  
  //file = new SoundFile(this, "khiitest.wav");
  //file = new SoundFile(this, "khii.mp3"); // testing audio loop?? 
  //file.loop();
  
  c1 = color(17, 24, 51);
  c2 = color(24, 55, 112);

  // some setups aborted
  fade = color(64, 85, 128);

  w = width+16;
  dx = (TWO_PI / period) * xspacing;
  yvalues = new float[w/xspacing];

  //for (int i = 0; i < particleCount; i++) {
  //  sparks[i] = new Particle(176, 203, 235);

  for (int i = 0; i < smallStarList.length; i++) {
    smallStarList[i] = new smallStar();
  }
  
  for (int i = 0; i < bigStarList.length; i++) {
    bigStarList[i] = new bigStar();
  }
  
  for (int i = 0; i < fireflyList.length; i++) {
    fireflyList[i] = new firefly();
  }
  
  trees.add(new Tree(600,0));
  trees.add(new Tree(-500,0));
  trees.add(new Tree(300,0));
  trees.add(new Tree(50,0));
  trees.add(new Tree(400,0));
  for (int i = 0; i < rainNum; i++) {
    drops[i] = new Rain();
  }
  
  ps = new ParticleSystem(new PVector(400,600)); // buffer default loc
}

smallStar[] smallStarList = new smallStar[110];
bigStar[] bigStarList = new bigStar[50];
firefly[] fireflyList = new firefly[70];
float gMove = map(.15,0,.3,0,30);
ParticleSystem ps;


void draw() {
  background(0);
  setGradient(0, 0, width, height, c1, c2, Y_AXIS);

  makeFade(fade);
  //clouds(cloudFill); //cloud reference from https://www.openprocessing.org/sketch/179401

  for (int i = 0; i < smallStarList.length; i++) {
    smallStarList[i].display();
  }
  
  for (int i = 0; i < bigStarList.length; i++) {
    bigStarList[i].display();
  }

  drawMountains();
  
  ps.addParticle();
  ps.run();
  for (Tree tree : trees) {
    tree.display(); 
  }
  
  anotherNoiseWave();

  calcWave(30.0);
  renderWave();
  
  for (int i = 0; i < fireflyList.length; i++) {
    fireflyList[i].update();
    fireflyList[i].display();
  }
  
  ps.setOrigin(new PVector(mouseX,mouseY)); 
  
  //if (raining) {  for temp rain no-respawn fix 
    for (int i = 0; i < rainNum; i++) {
      drops[i].update();
    }
  //}
}

void makeFade(color fade) {
  for (int i = 0; i < height/3; i++) {
    float a = map(i,0,height/3,360,0);
    strokeWeight(1);
    stroke(fade,a);
    line(0,i,width,i);
  }
}

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  ParticleSystem(PVector location) {
    origin = location.copy();
    particles = new ArrayList<Particle>();
  }
  
  void addParticle() {
    particles.add(new Particle(origin));
  }
  
  void setOrigin(PVector origin) {
    this.origin = origin; 
  }
  
  void run() { 
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0,0.05);
    velocity = new PVector(random(-1,1),random(-2,0));
    location = l.copy();
    lifespan = 255.0;
  }

  void run() {
    update();
    display();
  }

  // update location 
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    lifespan -= 10.0;
  }

  // display particles
  void display() {
    noStroke();
    //fill(216,226,237,lifespan-15);
    //ellipse(location.x,location.y,3,3);
    fill(237,240,255,lifespan);
    //ellipse(location.x,location.y,5,5);
    float w = random(3,9);
    ellipse(location.x,location.y,w,w);
  }
  
  // "irrelevant" particle
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}

class Tree {
  ArrayList<Branch> branches = new ArrayList<Branch>();
  ArrayList<Leaf> leaves = new ArrayList<Leaf>();
  int maxLevel = 8;
  Tree(float x, float y) {
    float rootLength = random(80.0, 150.0);
    branches.add(new Branch(this,x+width/2, y+height, x+width/2, y+height-rootLength, 0, null));
    subDivide(branches.get(0));
  }
  
  void display() {
    for (int i = 0; i < branches.size(); i++) {
      Branch branch = branches.get(i);
      branch.move();
      branch.display();
    }
    
    for (int i = leaves.size()-1; i > -1; i--) {
      Leaf leaf = leaves.get(i);
      leaf.move();
      leaf.display();
      leaf.destroyIfOutBounds();
    } 
  }

  void mousePress(PVector source) {
    float branchDistThreshold = 300*300;
    
    for (Branch branch : branches) {
      float distance = distSquared(mouseX, mouseY, branch.end.x, branch.end.y);
      if (distance > branchDistThreshold) {
        continue;
      }
      
      PVector explosion = new PVector(branch.end.x, branch.end.y);
      explosion.sub(source);
      explosion.normalize();
      float mult = map(distance, 0, branchDistThreshold, 10.0, 1.0); 
      explosion.mult(mult);
      branch.applyForce(explosion);
    }
    
    float leafDistThreshold = 50*50;
    
    for (Leaf leaf : leaves) {
      float distance = distSquared(mouseX, mouseY, leaf.pos.x, leaf.pos.y);
      if (distance > leafDistThreshold) {
        continue;
      }
      
      PVector explosion = new PVector(leaf.pos.x, leaf.pos.y);
      explosion.sub(source);
      explosion.normalize();
      float mult = map(distance, 0, leafDistThreshold, 2.0, 0.1);
      mult *= random(0.8, 1.2); // variation
      explosion.mult(mult);
      leaf.applyForce(explosion);
      
      leaf.dynamic = true;
    }
  }

 void subDivide(Branch branch) {
  ArrayList<Branch> newBranches = new ArrayList<Branch>();
  
  int newBranchCount = (int)random(1, 4);
  
  float minLength = 0.7;
  float maxLength = 0.85;
  
  switch(newBranchCount) {
    case 2:
      newBranches.add(branch.newBranch(random(-45.0, -10.0), random(minLength, maxLength)));
      newBranches.add(branch.newBranch(random(10.0, 45.0), random(minLength, maxLength)));
      break;
    case 3:
      newBranches.add(branch.newBranch(random(-45.0, -15.0), random(minLength, maxLength)));
      newBranches.add(branch.newBranch(random(-10.0, 10.0), random(minLength, maxLength)));
      newBranches.add(branch.newBranch(random(15.0, 45.0), random(minLength, maxLength)));
      break;
    default:
      newBranches.add(branch.newBranch(random(-45.0, 45.0), random(minLength, maxLength)));
      break;
  }
  
  for (Branch newBranch : newBranches) {
    this.branches.add(newBranch);

    if (newBranch.level < this.maxLevel) {
      subDivide(newBranch);
    } else {
      // generate random leaves position on last branch
      float offset = 5.0;
      for (int i = 0; i < 5; i++) {
        this.leaves.add(new Leaf(this,newBranch.end.x+random(-offset, offset), 
        newBranch.end.y+random(-offset, offset), newBranch));
      }
    }
  }
}
}

class Leaf {
  PVector pos;
  PVector velocity = new PVector(0,0);
  PVector acc = new PVector(0,0);
  float dia;
  float a;
  float r;
  float g;
  PVector offset;
  boolean dynamic = false;
  Branch parent;
  Tree tree;
  Leaf(Tree tree, float x, float y, Branch parent) {
    this.pos = new PVector(x,y);
    this.dia = random(2,11);
    this.a = random(50,150);
    this.parent = parent;
    this.offset = new PVector(parent.restPos.x-this.pos.x, parent.restPos.y-this.pos.y);
     this.tree = tree;
    if (tree.leaves.size() % 5 == 0) {
      this.r = 232;
      this.g = 250;
    } else {
      this.r = 227;
      this.g = random(230,255);
    }
  }
  
  void display() {
    pushMatrix();
    noStroke();
    fill(this.r, g, 250, this.a);
    ellipse(this.pos.x,this.pos.y,this.dia,this.dia);
    popMatrix();
  }
  
  void bounds() {
    if (!this.dynamic) { return; }
  }
  
  void applyForce(PVector force) {
    this.acc.add(force);
  }
  
  void move() {
    if (this.dynamic) {
      // Sim leaf
      
      PVector gravity = new PVector(0, 0.025);
      this.applyForce(gravity);
      
      this.velocity.add(this.acc);
      this.pos.add(this.velocity);
      this.acc.mult(0);
      
      this.bounds();
    } else {
      // follow branch
      this.pos.x = this.parent.end.x+this.offset.x;
      this.pos.y = this.parent.end.y+this.offset.y;
    }
  } 
  
  void destroyIfOutBounds() {
    if (this.dynamic) {
      if (this.pos.x < 0 || this.pos.x > width || this.pos.y < 0 || this.pos.y > height) {
        tree.leaves.remove(this);
      }
    }
  }
}


class Branch {
  PVector start;
  PVector end;
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  int level;
  Branch parent = null;
  PVector restPos;
  float restLength;
  Tree tree;

  Branch(Tree tree, float x1, float y1, float x2, float y2, int level, Branch parent) {
    this.start = new PVector(x1, y1);
    this.end = new PVector(x2, y2);
    this.level = level;
    this.restLength = dist(x1, y1, x2, y2);
    this.restPos = new PVector(x2, y2);
    this.parent = parent;
    this.tree = tree;
  }

  void display() {
    pushMatrix();
    stroke(159, 200, 195+this.level*5);
    strokeWeight(tree.maxLevel-this.level+1);
    
    if (this.parent != null) {
      line(this.parent.end.x, this.parent.end.y, this.end.x, this.end.y);
    } else {
      line(this.start.x, this.start.y, this.end.x, this.end.y);
    }
    popMatrix();
  }

  Branch newBranch(float angle, float mult) {
    // calculate new branch's direction and length
    PVector direction = new PVector(this.end.x, this.end.y);
    direction.sub(this.start);
    float branchLength = direction.mag();

    float worldAngle = degrees(atan2(direction.x, direction.y))+angle;
    direction.x = sin(radians(worldAngle));
    direction.y = cos(radians(worldAngle));
    direction.normalize();
    direction.mult(branchLength*mult);
    
    PVector newEnd = new PVector(this.end.x, this.end.y);
    newEnd.add(direction);

    return new Branch(tree, this.end.x, this.end.y, newEnd.x, newEnd.y, this.level+1, this);
  }
  
  // branch bouncing 
  void applyForce(PVector force) {
    PVector forceCopy = force.get();
    
    // smaller branches will be more bouncy
    float divValue = map(this.level, 0, tree.maxLevel, 8.0, 2.0);
    forceCopy.div(divValue);
    
    this.acc.add(forceCopy);
  }
  
  void sim() {
    PVector airDrag = new PVector(this.vel.x, this.vel.y);
    float dragMagnitude = airDrag.mag();
    airDrag.normalize();
    airDrag.mult(-1);
    airDrag.mult(0.025*dragMagnitude*dragMagnitude); // java mode
    this.applyForce(airDrag);
    
    PVector spring = new PVector(this.end.x, this.end.y);
    spring.sub(this.restPos);
    float stretchedLength = dist(this.restPos.x, this.restPos.y, this.end.x, this.end.y);
    spring.normalize();
    float elasticMult = map(this.level, 0, tree.maxLevel, 0.05, 0.1); // java mode
    spring.mult(-elasticMult*stretchedLength);
    this.applyForce(spring);
  }
  
  void move() {
    this.sim();
    
    this.vel.mult(0.95);
    
    // kill velocity below this threshold to reduce jittering
    if (this.vel.mag() < 0.05) {
      this.vel.mult(0);
    }
    
    this.vel.add(this.acc);
    this.end.add(this.vel);
    this.acc.mult(0);    
  }
}

float distSquared(float x1, float y1, float x2, float y2) {
  return (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
}
  
class smallStar {
  color c;
  float x;
  float y;
  float a;
  float h;
  float w;
  float centerX;
  float centerY;
  float ang;
  
  smallStar() {
    x = random(0,width);
    y = random(0,height/2);
    w = random(3,6);
    a = random(100,200);
    color[] colors = {color(232,248,255,a),color(235,234,175,a),color(242,242,208,a),
                         color(250,250,240,a),color(255,255,255,a)};
    int index = int(random(colors.length));
    c = colors[index];
    h = w;
    centerX = x + w/2;
    centerY = y + h/2;
    ang = random(0,PI)/random(1,4);
  }
  
  void display() {
    pushMatrix();
    ang = (this.ang + .01) % (2*PI);
    fill(this.c);
    noStroke();
    translate(centerX,centerY);
    rotate(ang);
    rect(-w/2,-h/2,w,h);
    popMatrix();
    //println("x" + this.x + "y" + this.y);
  }
}

class bigStar {
  float x;
  float y;
  float r1;
  float a;
  float flicker;
  float r2;
  color c;
  float ang;
  float angDir;
  
  bigStar() {
    x = random(0, width);
    y = random(0, height/2);
    r1 = random(2,5);
    a = random(40,180);
    flicker = random(400,800); 
    r2 = r1 * 2;
    color[] colors = {color(232,248,255,a),color(201,239,255,a),color(242,242,208,a),
                         color(250,250,240,a),color(255,255,255,a)};
    int index = int(random(colors.length));
    c = colors[index];
    float[] angles = {radians(millis()/170),radians(millis()/150),radians(millis()/-150),
                      radians(millis()/-170)};
    int index2 = int(random(angles.length));
    ang = angles[index2];
    angDir = (random(1)*0.1) - .05;
  }
  
  void display() {
    pushMatrix();
    //colorMode(RGB,255,255,255);
    //float newA = map(shine,-1,1,0,255);
    float newR = c >> 16 & 0xFF; //use bit shifts for faster processing
    float newG = c >> 8 & 0xFF;
    float newB = c & 0xFF;
    //float newAA = (a + newA) % 255;
    //float newC = color(newR, newG, newB, newAA); 
    float shine = sin(millis()/flicker);
    float a = this.a + map(shine,-1,1,40,100);
    //if (a < 0) { a = -a; };
    fill(newR,newG,newB,a);
    //fill(newC);
    noStroke();
    translate(x,y);
    ang = (this.ang + angDir) % (2*PI);
    rotate(ang);
    makeBigStar(0,0,r1,r2,5);
    popMatrix();
    //println("shine " + shine + "newAA " + newAA);
  }
}
    

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis) {
  noFill();
  for (int i = y; i <= y+h; i++) {
    float inter = map(i, y, y+h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, x+w, i);
  }
}

boolean raining = false;
//boolean rainToggle = false;

void keyPressed() {
  if (key == 'r') {
    if (raining == false) {
      raining = true;
      //rainNum = 80;
      //rainToggle = true;
    } else {
      raining = false;
    }
  }
}

void mousePressed() {
  PVector source = new PVector(mouseX, mouseY);
  for (Tree tree : trees) {
     tree.mousePress(source); 
  }
}

class firefly {
  PVector position;
  PVector velocity;
  float move;
  //float flicker;
  float a;
  
  firefly() {
    position = new PVector(random(0,width),random(400,650));
    velocity = new PVector(1*random(-1,1),-1*(random(-1,1)));
    move = random(-7,1);
    //flicker = sin(millis()/400.0);
    a = random(0,100); //map(flicker,-1,1,40,100);
  }
  
  void update() {
    position.add(velocity);
    if (position.x > width) {
      position.x = 0;
    }
    if (position.y > height || position.y < 360) {
      velocity.y = velocity.y * -1;
    }
  }
  
  void display() {
    pushMatrix();
    float flicker = sin(millis()/400.0);
    float a = (this.a + map(flicker,-1,1,40,100)) % 255;
    fill(255,255,240,a);
    ellipse(position.x,position.y,gMove+move, gMove+move);
    ellipse(position.x,position.y,(gMove+move)*0.5,(gMove+move)*0.5);
    popMatrix();
  }
}  

float yoff = 0.0;
float yoff2 = 0.0;

float time = 0;

void anotherNoiseWave() {
  float x = 0;
  while (x < width) {
    //stroke(255,255,255,5);
    stroke(0,65,117,120);
    //stroke(11, 114, 158, 12);
    line(x, 520 + 90 * noise(x/100, time), x, height);
    x++;
  }
  time = time + 0.02;
}

void calcWave(float amplitude) {
  // Increment theta (try different values for 'angular velocity' here
  theta += 0.02;

  // For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = sin(x)*amplitude;
    x+=dx;
  }
}

void renderWave() {
  noStroke();
  colorMode(RGB);
  float ellipsePulse = sin(millis()/600.0);
  float ellipseColor = map(ellipsePulse, -1, 1, 150, 245);
  fill((int)ellipseColor, 220, 250, ellipseColor-60);
  // A simple way to draw the wave with an ellipse at each location
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x*1.3*xspacing, height/1.2+yvalues[x], 6, 6);
  }
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x*1.7*xspacing, height/1.3+yvalues[x], 5, 5);
  }
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x*1.4*xspacing, height/1.15+yvalues[x], 7, 7);
  }
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x*1.5*xspacing, height/1.27+yvalues[x], 6, 6);
  }
}

class Rain {
  float x = random(0, width);
  float y = random(-1000, 0);
  float size = random(3, 7);
  float speed = random(20, 40);
  void update() {
    y += speed;
    fill(255, 255, 255, 180);
    //fill(185, 197, 209, random(20, 100));
    ellipse(x, y-5, size-3, size*2-3);
    fill(185, 197, 209, random(20, 100));
    //fill(255, 255, 255, 180);
    ellipse(x, y, size, size*2);

    if (y > height) {
      if (raining) {
        x = random(0, width);
        y = random(-10, 0);
      } 
      if (!raining) { // temp fix for stopping rain: let current rainfall not respawn at top
        //drops = new Rain[0];
        y = height;
        //speed = 0;
      }
    }
  }
}

void makeBigStar(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void drawMountains() {
  strokeWeight(15);
  strokeJoin(ROUND);
  for (int i = 0; i <= 10; i++ ) {
    float y = i*30;
    fill(map(i, 0, 5, 200, 35), map(i, 0, 5, 250, 100), map(i, 0, 5, 255, 140));
    stroke(map(i, 0, 5, 200, 35), map(i, 0, 5, 250, 110), map(i, 0, 5, 255, 150));
    beginShape();
    vertex(0, 400+y);
    for (int q = 0; q <= width; q+=10) {
      float y2 = 400+y-abs(sin(radians(q)+i))*cos(radians(i+q/2))*map(i, 0, 5, 100, 20);
      vertex(q, y2);
    }
    vertex(width, height);
    vertex(0, height);
    endShape(CLOSE);
  }
}