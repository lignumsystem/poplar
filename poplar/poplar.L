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

//Functions for the number of leaf pairs and leaf sizes
ParametricCurve fleaf_pair("fleafpair.fun");
ParametricCurve fleaf_size("fleafsize.fun");


Uniform u(-1);
int generator = 1;
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
  //Terminating bud not creating leaves
  PoplarBudData d1(ALIVE,0.1,0.0,1.0);
  //Axillary buds assoaciated with a leaf
  PoplarBudData d2(DORMANT,0.1,1.0,1.0);


  // produce Roll(30.0 * PI_VALUE/180.0) F(0.2, 0)  Roll(roll)  B(d1);  
  produce Roll(30.0 * PI_VALUE/180.0) F(0.2, 0) SB() Pitch(PI_VALUE/4.0)  B(d2) EB() B(d1);    

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
  PoplarBudData d1(GetValue(d, LGAstate), 0.1, GetValue(d, LGAomega), 1.0);
  PoplarBudData d2(GetValue(d, LGAstate), 0.1, GetValue(d, LGAomega), 1.0);

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
  else if (GetValue(d, LGAomega)<3){
    int seed = time(NULL);
    double r = g1(5.5, 3.0, seed);  //for trees in Alley Cropping
    double I = g2(36.0, 5.0, seed); //  double I = g2(45.0, 21.0, seed);
          //cout<<"r: "<<r/10.0<<endl;
    if (GetValue(d,LGAomega) == 0){
         produce F(r/10.0, o) Split()  B(d1);
    }
    else if (GetValue(d,LGAomega) == 1)
         produce F(r/10.0, o) Split()  Pitch(-fac)B(d2);
    else
         produce F(r/10.0, o) Split() Pitch(-fac) B(d2);
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
   //Inclination
   double I  = rand()%30+28;  //100.0*(u(seed++)-0.5);Single/rand()%40+25; stand/23+25;
   double I1 = rand()%30+28;  //100.0*(u(seed++)-0.5);
   double I2 = rand()%30+28;  //-180;  //100.0*(u(seed++)-0.5);
   double I3 = rand()%30+28;  //-180;  //100.0*(u(seed++)-0.5);
   double I4 = rand()%30+28;
  //cout<<"angle A:"<<A<<" "<<A1<<" "<<A2<<" "<<A3<<" "<<A4<<endl;
 // cout<<"angle I:"<<I<<" "<<I1<<" "<<I2<<" "<<I3<<" "<<I4<<endl;

if (s<0.01){
    produce F(s, o);
}
else if (s < 0.02)
{
 // cout<<s<<" :value of s(o=0)"<<endl;
  produce F(s/2, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
          F(s/2, o);
}
else if (s < 0.04)
{
produce F(s/3, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/3, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/3, o);
}
else if (s <0.06)
{
produce F(s/4, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/4, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/4, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/4, o);
}
else if (s <0.08)
{
produce F(s/5, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/5, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/5, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/5, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/5, o);
}
else if (s <0.10)
{
produce F(s/6, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/6, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/6, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/6, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/6, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/6, o);
}
else if (s<0.12)
{
produce F(s/7, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/7, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/7, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/7, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/7, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/7, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/7, o);
}
else if (s < 0.14)
{
produce F(s/8, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/8, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/8, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/8, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/8, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/8, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/8, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/8, o);
}
else if (s < 0.16)
{
produce F(s/9, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/9, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/9, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/9, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/9, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/9, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/9, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/9, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/9, o);
}
else if (s < 0.18)
{
produce F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/10, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/10, o);
}
else if (s < 0.20)
{
produce F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/11, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/11, o);
}
else if (s < 0.22)
{
produce F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/12, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/12, o);
}
else if (s < 0.24)
{
produce F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/13, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/13, o);
}
else if (s < 0.26)
{
produce F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/14, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/14, o);
}
else if (s < 0.28)
{
produce F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/15, o);
}
else if (s < 0.30)
{
produce F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/16, o); 
}
else if (s < 0.32)
{
produce F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/17, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/17, o);
}
else if (s < 0.34)
{
produce F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/18, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/18, o);
}
else if (s < 0.36)
{
produce F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/19, o); 
}
else if (s < 0.38)
{
produce F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/20, o);
}
else if (s < 0.40)
{
produce F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/21, o);
}
else if (s < 0.42)
{
produce F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/22, o);
}
else if (s < 0.44)
{
produce F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/23, o);
}
else if (s < 0.46)
{
produce F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/24, o);
}
else if (s < 0.48)
{
produce F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/25, o);
}
else if (s < 0.50)
{
produce F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/26, o);
}
else if (s < 0.52)
{
produce F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/27, o);
}
else if (s < 0.54)
{
produce F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/28, o);
}
else if (s < 0.56)
{
produce F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/29, o);
}
else if (s < 0.58)
{
produce F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/30, o);
}
else if (s < 0.60)
{
produce F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/31, o);
}
else if (s < 0.62)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/32, o);
}
else if (s < 0.64)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/33, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/33, o);
}
else if (s < 0.66)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/34, o);
}
else if (s < 0.68)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/35, o);
}
else if (s < 0.70)
{
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/36, o);
}
else{//s > 0.70
cout << "LSYSTEM SEGMENT SPLIT LENGTH " << s << " ORDER " << o <<endl; 
produce F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
	F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
	F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
	F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()	
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I1*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
	F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I2*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I3*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o) SB() Roll(static_cast<int>(u(generator)*360.0)*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(dorm) EB()
        F(s/37, o);
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
