//Your  L-system will be similar to this. See 
//LEngine README for user caveats, e.g. please do not
//use C++ keywords in comments.
#include <mathsym.h>
#include <Uniform.h>
#include <Gauss.h> 
#include <Bernoulli.h>
#include <poplar.h>
using namespace cxxadt;

//First include lengine.h file for some necessary 
//declarations and definitions 
#include <lengine.h>

//Then wrap your L-system into a "namespace" so that you
//can have several tree sepecies in a program 
open poplar;

//lsys.h impelemnts the rewriting
#include <lsys.h>

//Then comes the model. This file is compiled to C++ so 
//you can first have some C++ declarations and definitions 

Uniform u(-1);
Gauss g1(-1);
Gauss g2(-1);
Gauss g3(-1); 
Bernoulli ber( -1);


//main stem branching angle
const double ba=60.0 * PI_VALUE/180.0;
const double bendUp=10.0* PI_VALUE/180.0;
const double maxIncl = 8.0; 



//The declare the modules your need
module F(double, int);
module B(PoplarBudData);
module Pitch(double);
module Turn(double);
module Roll(double);
module Split();
ignore: Roll Pitch Turn;

//Define the derivation length
derivation length: 30;

//Define the Start corresponding to the axiom
Start:
{ 
  int seed=time(0);
  srand(seed);
  PoplarBudData d(ALIVE, 1.0, 0.0, 1.0);   
  produce F(0.8, 0) B(d);          
}

//You can optionally have the following modules:
//StartEach is evaluated before each derivation and 
//typically e.g. initializes some variables  
StartEach:
{
}

//EndEach is similar to StartEach but is evaluated 
//after each derivation
EndEach:
{
}

//End is evaluated after the last derivation and
//typically does some clean up work e.g. deletes
//dynamically created variables. 
End:
{
}

//Here are the rewritings. If there is no rewriting 
//the symbol rewrites to itself. "produce" denotes
//the rewriting and corresponds to "return" in C++

F(s, od) < B(d):
{
  PoplarBudData dead(DEAD, 1.0, GetValue(d, LGAomega), 1.0);
  PoplarBudData dorm(DORMANT, 1.0, GetValue(d, LGAomega), 1.0);
  PoplarBudData d1(GetValue(d, LGAstate), 1.0, GetValue(d, LGAomega), 1.0);
  PoplarBudData d2(GetValue(d, LGAstate), 1.0, GetValue(d, LGAomega)+1, 1.0);

  LGMdouble o=GetValue(d, LGAomega);
  LGMdouble st = GetValue(d, LGAstate);

//Bend branches upwards

  PositionVector direct = GetDirection(d);
  direct.normalize();
  double fac = 0.0;
  if(asin(direct.getZ())<maxIncl)
  {
    PositionVector up(0.0, 0.0, 1.0);
    PositionVector cr = Cross(up, direct);
    fac = cr.length();
    fac *= bendUp;
  }

 if (GetValue(d, LGAstate)==DEAD)
      produce B(dead);
  else if (GetValue(d, LGAstate)==DORMANT)
      produce B(dorm);
  else {
    int seed = time(NULL);
   double r = g1(5.5, 3.0, seed);  //for trees in Alley Cropping
   double I = g2(36.0, 5.0, seed); //  double I = g2(45.0, 21.0, seed);

   produce F(r/10.0, o) Split() B(d1);

  }

}


F(s, o) > Split():
{
   PoplarBudData dorm(DORMANT, 1.0, o+1, 1.0);
   PoplarBudData d1(1.0, 1.0, o+1, 1.0);
   PoplarBudData d2(1.0, 1.0, o+1, 1.0);

   double A  = rand()%360;  //360.0*(u(seed++)-0.5);
   double A1 = rand()%360;  //360.0*(u(seed++)-0.5);
   double A2 = rand()%360;   //45-90;  //360.0*(u(seed++)-0.5);
   double A3 = rand()%360;   //45-90;  //360.0*(u(seed++)-0.5);

   double I  = rand()%30+30;  //100.0*(u(seed++)-0.5);
   double I1 = rand()%30+30;  //100.0*(u(seed++)-0.5);
   double I2 = rand()%75;  //-180;  //100.0*(u(seed++)-0.5);
   double I3 = rand()%75;   //-180;  //100.0*(u(seed++)-0.5);

  if (s<0.05){
    produce F(s, o);
}
else if (0.05<=s<0.1)
{
  cout<<s<<" :value of s(o=0)"<<endl;
  produce F(s/2, o) SB() Roll(A*PI_VALUE/180.0) Pitch(I*PI_VALUE/180) B(dorm) EB()
        F(s/2, o) ;
}
else
{
produce F(s/3, o) SB() Roll(A*PI_VALUE/180.0) Pitch(I*PI_VALUE/180) B(dorm) EB()
        F(s/3, o) SB() Roll(A1*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180) B(dorm) EB()
        F(s/3, o) ;
}

}


Split():
{
  produce ;
}

F(s, o):
{
  produce F(s, o);
}

//This is a ToDO for Jari: interpretation typically
//defines the graphical visualization of symbols. But
//we visualize LIGNUM and thus this is practically 
//unnecessary for us. However, "lc2" cannot compile
//L-files unless you have one  interpretation   

interpretation:

F(s, o) :
{
  ;
}

//Finally, "close" the "namespace"
close poplar;


