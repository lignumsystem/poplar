//Your  L-system will be similar to this. See 
//LEngine README for user caveats, e.g. please do not
//use C++ keywords in comments.

#include <Uniform.h>
#include <Gauss.h> 
#include <Bernoulli.h>

#include <iostream>
using namespace std;

#include <mathsym.h>
#include <ParametricCurve.h>
using namespace cxxadt;

#include <LGMUnits.h>
using namespace Lignum;
#include <poplar.h>
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

//main stem roll
const double roll = 137.5*PI_VALUE/180.0;
//main stem branching angle
const double ba = 60.0*PI_VALUE/180.0;
const double bendUp = 10.0*PI_VALUE/180.0;
const double maxIncl =PI_VALUE/2.0;

//Functions for the number of leaf pairs and leaf sizes
ParametricCurve fleaf_pair("fleafpair.fun");
ParametricCurve fleaf_size("fleafsize.fun");


Uniform u(-1);
Gauss g1(-1);
Gauss g2(-1);
Gauss g3(-1); 
Bernoulli ber( -1);


//The declare the modules your need 
//F(length,branching order)
module F(double,double);
//B: Bud(alive, create_leaf_or_not,branching_order)
module B(PoplarBudData);
module Pitch(double);
module Turn(double);
module Roll(double);
module HRoll();
module Split();
module SplitBranch();
ignore: Roll Pitch Turn HRoll;

//Define the Start corresponding to the axiom
//state, status(leafSize), omega, brp-relative position  of the bud in a segment
Start:
{
  PoplarBudData d1(ALIVE,0.0,0.0,1.0);
  PoplarBudData d2(ALIVE,0.1,1.0,1.0);

 produce Roll(30.0 * PI_VALUE/180.0) F(0.05, 0)
           Roll(roll)  B(d1);    
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


//There are  two modes.   First, create the  new segments  and "Split"
//symbols  to  their  immediate  right  context.   Then  allocate  the
//photosynthesis by  elongating and shortening the  new segments. When
//the new  segments are of right  size, in the second  mode will split
//the segments (according to some function) to put the right number of
//leaves into right positions in the new growth.

//New segments: If there is a  segment in the left context, expand. If
//not, some split symbol is there instead to denote split mode
F(s,od)  < B(d):
{  
  PoplarBudData dead(DEAD, 0.0, GetValue(d, LGAomega), 1.0);
  PoplarBudData dorm(DORMANT, 0.1, GetValue(d, LGAomega), 1.0);
  PoplarBudData d1(GetValue(d, LGAstate), 0.0, GetValue(d, LGAomega), 1.0);
  PoplarBudData d2(GetValue(d, LGAstate), 0.1, GetValue(d, LGAomega)+1, 1.0);

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
  else if (GetValue(d, LGAomega)<3){
    int seed = time(NULL);
    double r = g1(5.5, 3.0, seed);  //for trees in Alley Cropping
    double I = g2(36.0, 5.0, seed); //  double I = g2(45.0, 21.0, seed);
          //cout<<"r: "<<r/10.0<<endl;
    if (GetValue(d,LGAomega) == 0)
         produce F(r/10.0, o) Split()  B(d1);
    else if (GetValue(d,LGAomega) == 1)
         produce F(r/10.0, o) Split()  Pitch(-fac)B(d1);
    else
         produce F(r/10.0, o) Split() Pitch(-fac)B(d1);
  }
  else
    produce B(dead);

}

//split the segment main axis
F(s,o) > Split():
{
   //cout<<"s: "<<s<<endl;
   PoplarBudData dorm(DORMANT, 0.1, o+1, 1.0);
   PoplarBudData d1(1.0, 0.0, o+1, 1.0);
   PoplarBudData d2(1.0, 0.1, o+1, 1.0);

   double A  = rand()%360;  //360.0*(u(seed++)-0.5);
   double A1 = rand()%360;  //360.0*(u(seed++)-0.5);
   double A2 = rand()%360;   //45-90;  //360.0*(u(seed++)-0.5);
   double A3 = rand()%360;   //45-90;  //360.0*(u(seed++)-0.5);
   double A4 = rand()%360;   

   double I  = rand()%30+20;  //100.0*(u(seed++)-0.5);
   double I1 = rand()%30+20;  //100.0*(u(seed++)-0.5);
   double I2 = rand()%30+20;  //-180;  //100.0*(u(seed++)-0.5);
   double I3 = rand()%30+20;  //-180;  //100.0*(u(seed++)-0.5);
   double I4 = rand()%30+20;

  if (s<0.1){
    produce F(s, o);
}
else if (0.1<=s && s<0.2)
{
 // cout<<s<<" :value of s(o=0)"<<endl;
  produce F(s/2, o) SB() Roll(A*PI_VALUE/180.0) Pitch(I*PI_VALUE/180) B(dorm) EB()
        F(s/2, o);
}
else 
{
produce F(s/3, o) SB() Roll(A*PI_VALUE/180.0) Pitch(I*PI_VALUE/180) B(dorm) EB()
        F(s/3, o) SB() Roll(A1*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180) B(dorm) EB()
        F(s/3, o);
}

}


//Remove split symbols after split 
Split():
{
   produce ;
}

F(s,o):
{
  produce F(s,o);
}

//This is a ToDO for Jari: interpretation typically
//defines the graphical visualization of symbols. But
//we visualize LIGNUM and thus this is practically 
//unnecessary for us. However, "lc2" cannot compile
//L-files unless you have one  interpretation   

interpretation:

F(s,o) :
{
  ;
}

//Finally, "close" the "namespace"
close poplar;
