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
const double bendUp = 2.0*PI_VALUE/180.0;     //10.0*PI_VALUE/180.0;
const double maxIncl =8.0/9.0*PI_VALUE/2.0;

Uniform u(-1);
int generator = 1;
Gauss g1(-1);
Gauss g2(-1);
Gauss g3(-1); 
Bernoulli ber( -1);

//File for inclination distribution
const ParametricCurve finclination("inclination.fun");

//Left or right turn
inline  double Sign(Uniform& u1)
{
   double r = u1(generator);
   if (r < 0.5)
      return -1.0;
   else
      return 1.0;
}

inline  double RollAngle(Uniform& u1)
{
   double r = u1(generator);
   double angle = r*360.0;
   //radians
   angle = angle*PI_VALUE/180.0;
   return angle;
}
 
//The bifurcation angle in side branches see Alice thesis pp. 85-86
//This is also the pitching angle in the main axis 
inline  double TurnAngle(Uniform& u1)
{      
   //Between 30 and 70, assume uniform distribution
   //omit for now the radar chart Fig 15 showing most of the angles falling between 40 and 50 
   double  r = u1(generator); // r = [0:1]
   //Bifurcation angle in degrees 
   double angle = finclination(r);
   //change the measured inclination to turtle pitch or turn
   //the measured inclination is from horizontal
   angle = 90-angle;
   //radians
   angle = angle*PI_VALUE/180.0;
   return angle;
}

//Declare the modules your need 
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
  //Terminating bud not creating leaves
  PoplarBudData d1(ALIVE,0.1,0.0,1.0);
  //Axillary buds assoaciated with a leaf
  PoplarBudData d2(DORMANT,0.1,1.0,1.0);

  produce F(0.2, 0) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(d1) EB() 
                    SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(d1) EB()
          B(d1);    

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
  PoplarBudData dorm(DORMANT, 0.1, GetValue(d, LGAomega)+1, 1.0);
  PoplarBudData d1(GetValue(d, LGAstate), 0.1, GetValue(d, LGAomega), 1.0);

  LGMdouble o=GetValue(d, LGAomega);
  LGMdouble st = GetValue(d, LGAstate);

  //Bend branches upwards 0<=asin(direct.getZ()) &&

  PositionVector direct = GetDirection(d);
  direct.normalize();
  double fac = 0.0;
  if(asin(direct.getZ())<maxIncl)
  {
    PositionVector up(0.0, 0.0, 1.0);
    PositionVector cr = Cross(up, direct);
    fac = cr.length();
    fac *= bendUp;
    if (o>1)
       fac *= 5.0;
    //fac = abs(fac);
  }

 if (GetValue(d, LGAstate)==DEAD)
      produce B(dead);
 else if (GetValue(d, LGAstate)==DORMANT)
      produce B(dorm);
 else if (GetValue(d, LGAomega)==0.0){
    produce F(0.3, o) Split() SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()  B(d1);
 }
 else if (GetValue(d,LGAomega) == 1.0){
         double sign = Sign(u);
         double angle = TurnAngle(u);
         produce F(0.3, o) Split() SB() Turn(sign*angle) B(dorm) EB()  B(d1);
 }
 else if (GetValue(d,LGAomega) == 2.0){
         double sign = Sign(u);
         double angle = TurnAngle(u);
         produce F(0.3, o) Split()  SB() Turn(sign*angle) B(dorm) EB() B(d1);
 }
 else
    produce B(dead);
}

//split the segment main axis
F(s,o) > Split():
{
  //cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
  // cout<<"s: "<<s<<endl;
   PoplarBudData dorm(DORMANT, 0.1, o+1, 1.0);
   PoplarBudData d1(1.0, 0.1, o+1, 1.0);
   PoplarBudData d2(1.0, 0.1, o+1, 1.0);
//Main axis
if (o == 0.0){
if (s<0.01){
    produce F(s, o);
}
else if (s < 0.02)
{
 // cout<<s<<" :value of s(o=0)"<<endl;
  produce F(s/2, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
          F(s/2, o);
}
else if (s < 0.04)
{
produce F(s/3, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/3, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/3, o);
}
else if (s <0.06)
{
produce F(s/4, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/4, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/4, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/4, o);
}
else if (s <0.08)
{
produce F(s/5, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/5, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/5, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/5, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/5, o);
}
else if (s <0.10)
{
produce F(s/6, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/6, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/6, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/6, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/6, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/6, o);
}
else if (s<0.12)
{
produce F(s/7, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/7, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/7, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/7, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/7, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/7, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/7, o);
}
else if (s < 0.14)
{
produce F(s/8, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/8, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/8, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/8, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/8, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/8, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/8, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/8, o);
}
else if (s < 0.16)
{
produce F(s/9, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/9, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/9, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/9, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/9, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/9, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/9, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/9, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/9, o);
}
else if (s < 0.18)
{
produce F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/10, o);
}
else if (s < 0.20)
{
produce F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/11, o);
}
else if (s < 0.22)
{
produce F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/12, o);
}
else if (s < 0.24)
{
produce F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/13, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/13, o);
}
else if (s < 0.26)
{
produce F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/14, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/14, o);
}
else if (s < 0.28)
{
produce F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/15, o);
}
else if (s < 0.30)
{
produce F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/16, o); 
}
else if (s < 0.32)
{
produce F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/17, o);
}
else if (s < 0.34)
{
produce F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/18, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/18, o);
}
else if (s < 0.36)
{
produce F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/19, o); 
}
else if (s < 0.38)
{
produce F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/20, o);
}
else if (s < 0.40)
{
produce F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/21, o);
}
else if (s < 0.42)
{
produce F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/22, o);
}
else if (s < 0.44)
{
produce F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/23, o);
}
else if (s < 0.46)
{
produce F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/24, o);
}
else if (s < 0.48)
{
produce F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/25, o);
}
else if (s < 0.50)
{
produce F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/26, o);
}
else if (s < 0.52)
{
produce F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/27, o);
}
else if (s < 0.54)
{
produce F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/28, o);
}
else if (s < 0.56)
{
produce F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/29, o);
}
else if (s < 0.58)
{
produce F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/30, o);
}
else if (s < 0.60)
{
produce F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/31, o);
}
else if (s < 0.62)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/32, o);
}
else if (s < 0.64)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/33, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/33, o);
}
else if (s < 0.66)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/34, o);
}
else if (s < 0.68)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/35, o);
}
else if (s < 0.70)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/36, o);
}
else if (s < 0.72){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/37, o);
}
else if (s < 0.74){
produce F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/38, o);
}
else if (s < 0.76){
produce F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/39, o);
}
else if (s < 0.78){
produce F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/40, o);
}
else if (s < 0.80)
{
produce F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/41, o);
}
else if (s < 0.82){
produce F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//20
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//40
        F(s/42, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/42, o);
}
else if (s < 0.84){
produce F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//20
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//40
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/43, o);
}
else if (s < 0.86){
produce F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//20
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//40
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/44, o);
}
else if (s < 0.88){
produce F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//20
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//40
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/45, o);
}
else if (s < 0.90){
produce F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//20
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//40
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/46, o);
}
else{//s > 0.90
produce F(s/46, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
	F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()	
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//20
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
	F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()//40
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Roll(RollAngle(u)) Pitch(TurnAngle(u)) B(dorm) EB()
        F(s/47, o);
}
}
else {//branches
if (s<0.01){
    produce F(s, o);
}
else if (s < 0.02)
{
 // cout<<s<<" :value of s(o=0)"<<endl;
  produce F(s/2, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
          F(s/2, o);
}
else if (s < 0.04)
{
produce F(s/3, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/3, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/3, o);
}
else if (s <0.06)
{
produce F(s/4, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/4, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/4, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/4, o);
}
else if (s <0.08)
{
produce F(s/5, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/5, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/5, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/5, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/5, o);
}
else if (s <0.10)
{
produce F(s/6, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/6, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/6, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/6, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/6, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/6, o);
}
else if (s<0.12)
{
produce F(s/7, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/7, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/7, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/7, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/7, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/7, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/7, o);
}
else if (s < 0.14)
{
produce F(s/8, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/8, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/8, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/8, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/8, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/8, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/8, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/8, o);
}
else if (s < 0.16)
{
produce F(s/9, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/9, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/9, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/9, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/9, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/9, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/9, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/9, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/9, o);
}
else if (s < 0.18)
{
produce F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/10, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/10, o);
}
else if (s < 0.20)
{
produce F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/11, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/11, o);
}
else if (s < 0.22)
{
produce F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/12, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/12, o);
}
else if (s < 0.24)
{
produce F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/13, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/13, o);
}
else if (s < 0.26)
{
produce F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/14, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/14, o);
}
else if (s < 0.28)
{
produce F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/15, o);
}
else if (s < 0.30)
{
produce F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/16, o); 
}
else if (s < 0.32)
{
produce F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/17, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/17, o);
}
else if (s < 0.34)
{
produce F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/18, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/18, o);
}
else if (s < 0.36)
{
produce F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/19, o); 
}
else if (s < 0.38)
{
produce F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/20, o);
}
else if (s < 0.40)
{
produce F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/21, o);
}
else if (s < 0.42)
{
produce F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/22, o);
}
else if (s < 0.44)
{
produce F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/23, o);
}
else if (s < 0.46)
{
produce F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/24, o);
}
else if (s < 0.48)
{
produce F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/25, o);
}
else if (s < 0.50)
{
produce F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/26, o);
}
else if (s < 0.52)
{
produce F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/27, o);
}
else if (s < 0.54)
{
produce F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/28, o);
}
else if (s < 0.56)
{
produce F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/29, o);
}
else if (s < 0.58)
{
produce F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/30, o);
}
else if (s < 0.60)
{
produce F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/31, o);
}
else if (s < 0.62)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/32, o);
}
else if (s < 0.64)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/33, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/33, o);
}
else if (s < 0.66)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/34, o);
}
else if (s < 0.68)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/35, o);
}
else if (s < 0.70)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/36, o);
}
else if (s < 0.72){//s > 0.70
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/37, o);
}
else if (s < 0.74){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/38, o);
}
else if (s < 0.76){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/39, o);
}
else if (s < 0.78){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/40, o);                                            //40
}
else if (s < 0.80){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/41, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//40
        F(s/41, o);                                            
}
else if (s < 0.82){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//40
        F(s/42, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/42, o);   
}
else if (s < 0.84){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//40
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/43, o);   
}
else if (s < 0.86){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//40
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/44, o);   
}
else if (s < 0.88){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//40
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/45, o);   
}
else if (s < 0.90){
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//40
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/46, o);   
}
else{//s > 0.9
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
	F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()	
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//20
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
	F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()//40
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o) SB() Turn(Sign(u)*TurnAngle(u)) B(dorm) EB()
        F(s/47, o);   
}
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
