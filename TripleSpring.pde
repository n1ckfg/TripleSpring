import peasy.PeasyCam;

PeasyCam cam;
Thing tg;

int[][] result;
float t, c;
float mn = .5f*sqrt(3);
float ia = atan(sqrt(.5f));
int samplesPerFrame = 5;
int numFrames = 400;        
float shutterAngle = .6f;
boolean recording = true;
float DT = 0.01f; // Time step
int nsteps = 30000; // Number of steps
int n = 5;

void setup() {
  size(500,500,P3D);
  cam = new PeasyCam(this, 400);

  result = new int[width*height][3];
  tg = new Thing();
  tg.compute_path();
  strokeCap(ROUND);
}

void draw() {
  if (!recording) {
    t = mouseX*1.0f/width;
    c = mouseY*1.0f/height;
    if (mousePressed)
      println(c);
    draw_();
  } else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    c = 0;
    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 | 
        PApplet.parseInt(result[i][0]*1.0f/samplesPerFrame) << 16 | 
        PApplet.parseInt(result[i][1]*1.0f/samplesPerFrame) << 8 | 
        PApplet.parseInt(result[i][2]*1.0f/samplesPerFrame);
    updatePixels();

    /*
    saveFrame("fr###.png");
    println(frameCount,"/",numFrames);
    if (frameCount==numFrames) exit();
    */
  }
  
  surface.setTitle(""+frameRate);
}

//////////////////////////////////////////////////////////////////////////////

float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

float ease(float p, float g) {
  if (p < 0.5f) 
    return 0.5f * pow(2*p, g);
  else
    return 1 - 0.5f * pow(2*(1 - p), g);
}

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

PVector spring_force(float ax,float ay,float bx,float by,float k,float l0) {
    float xx = ax - bx;
    float yy = ay - by;
    
    float d = dist(xx,yy,0,0);
    
    float nx = xx/d;
    float ny = yy/d;
    
    float f = k*(d - l0);
    
    float fx = f*nx;
    float fy = f*ny;
    
    return new PVector(fx,fy);
}

float triangular(float q) {
  q = (q+10000)%1;
  if(q<0.25f) {
    return 4*q;
  } else if(q<0.75f) {
    return 2-4*q;
  } else {
    return 4*q-4;
  }
}

void draw_connection(float x,float y,float x_,float y_) {
  for(int i=0;i<n;i++) {
    stroke(255);
    strokeWeight(1);
    /*line(springarray[i].x,springarray[i].y,x,y);
    */
    float xx = x_ - x;
    float yy = y_ - y;
    
    float d = dist(xx,yy,0,0);
    
    float nx = xx/d;
    float ny = yy/d;
    
    stroke(255,150);
    strokeWeight(1);
    noFill();
    
    int m = 250;
    beginShape();
    for(int j=0;j<m;j++) {
      float p = 1.0f*j/m;
      
      float xxx = lerp(x_,x,p);
      float yyy = lerp(y_,y,p);
      
      int k = 5;
      
      float l = 10;
      
      //xxx += 25*ny*sin(TWO_PI*p*k);
      //yyy += -25*nx*sin(TWO_PI*p*k);
      xxx += l*ny*triangular(p*k);
      yyy += -l*nx*triangular(p*k);
      
      vertex(xxx,yyy);
      
    }
    endShape();
  }
}

void draw_() {
  background(0);
  push();
  translate(width/2,0.3*height);
  
  scale(1.0);
  
  tg.show(t);
  
  pop();
}
