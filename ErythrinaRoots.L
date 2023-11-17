/********************************************************
	 *	Generation de systeme racinaire de Erythrina    *
	 *	modele fracroot, Ozier-Lafontaine et al, 2000	*
	 *	C02                                             *
	 ********************************************************/

#include <math.h>
#include <utility>

#include <lengine.h>

#include <Uniform.h>


open Erythrina;

#include <lsys.h>


const int STEPS=30; //change the steps
const double ALPHA=0.99;
const double Q=0.72;
const double DMIN=0.01; //minimum diameter

const int RAM=0;
const int AXE=1;

inline double Da(double Db)
{
   return sqrt((Q/ALPHA)*pow(Db,2.0));
}

inline double Dr(double Db, double nbr)
{
   return sqrt((((1.0-Q)/nbr)/ALPHA)*pow(Db,2.0));
}

inline double Long(double D)
{
   return (D >0.035) ? (3.0*D) : 0.1; //used to be (6.961 * D) :0.1
}

inline pair<double,double> RandomRollAndPitch(double d,int RAMorAXE)
{
  double x=rand()%100;
  double y=rand()%100;

  if (0<=x<3)
     x=-75;
  else if (3<=x<5)
     x=-65;
  else if (5<=x<9)
     x=-55;
  else if (9<=x<14)
     x=-45;
  else if (14<=x<20)
     x=-35;
  else if (20<=x<25)
     x=-25;
  else if (25<=x<35)
     x=-15;
  else if (35<=x<45)
     x=-5;
  else if (45<=x<55)
     x=5;
  else if (55<=x<65)
     x=15;
  else if (65<=x<70)
     x=20;
  else if (70<=x<73)
     x=25;
  else if (73<=x<77)
     x=30;
  else if (77<=x<82)
     x=45;
  else if (82<=x<87)
     x=55;
  else if (87<=x<94)
     x=65;
  else if (94<=x<=100)
     x=75;
 
  if (0<=y<5)
     y=-75;
  else if (5<=x<10)
     y=-65;
  else if (10<=x<15)
     y=-55;
  else if (15<=x<20)
     y=-45;
  else if (20<=x<25)
     y=-35;
  else if (25<=x<30)
     y=-25;
  else if (30<=x<50)
     y=-15;
  else if (50<=x<65)
     y=-5;
  else if (65<=x<70)
     y=5;
  else if (70<=x<80)
     y=15;
  else if (80<=x<85)
     y=25;
  else if (85<=x<90)
     y=35;
  else if (90<=x<=100)
     y=45;

  y=rand()%150-75;
  pair<double,double> p(x/57.3,-1);
  return p;
}

Uniform u;
int seed = 1;



module B(double,double);
module F(double);
module Pitch(double);
module Roll(double);
module Turn(double);

derivation length: STEPS;

Start: 
{ 
   seed = 1;
   produce Pitch(0.6 * PI_VALUE) B(0.1,0.10);
         //pitch 180= turn downword,initially d=0.25, l=0.50
  // produce Pitch(0.6*PI_VALUE) Turn(PI_VALUE/3) B(0.1,0.10);
}



B(d,l):
{

  if (d > DMIN){ 
   double u1 = u(seed);
   pair<double,double> p1 = RandomRollAndPitch(d,AXE);
   pair<double,double> p2 = RandomRollAndPitch(d,RAM);
   pair<double,double> p3 = RandomRollAndPitch(d,1);
   if (u1 <= 0.9){ 
     double dr1 = Dr(d,1.0);
     double longdr1 = Long(Dr(d,1.0));
     double da1 = Da(d);
     double longdad = Long(Da(d));
     produce F(l) SB()  Roll(p1.first) Pitch(p1.second) B(dr1,longdr1) EB() 
             B(da1,longdad); 
   }
   else{
     double dr2 = Dr(d,2.0);
     double longdr2 = Long(Dr(d,2.0));
     double da1 = Da(d);
     double longdad = Long(Da(d));
     produce F(l) SB()  Roll(p1.first) Pitch(p1.second) B(dr2,longdr2) EB() 
                  SB()  Roll(p2.first) Pitch(p2.second) B(dr2,longdr2) EB() 
                B(da1,longdad);  
  }
 }
 else{ 
    produce B(d/2,l);
 }

}
     
interpretation:

F(s) :
{
  ;
}

close Erythrina;
