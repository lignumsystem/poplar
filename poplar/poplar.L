//Your  L-system will be similar to this. See 
//LEngine README for user caveats, e.g. please do not
//use C++ keywords in comments.
#include <mathsym.h>
#include <Uniform.h>
#include <Gauss.h> 
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
//The declare the modules your need
module F(double);
module B(double,double,double);
module Pitch(double);
module Turn(double);
module Roll(double);

//Define the derivation length
derivation length: 40;

//Define the Start corresponding to the axiom
Start:
{
  produce B(0, 4,0);
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
// the symbol rewrites to itself. "produce" denotes
//the rewriting and corresponds to "return" in C++ 
B(leaf, alive,order):
{
  if (order == 0){
   int seed = 1111111;
   double r = g1(10.0, 1.0, seed);
   double I = g2(36.0, 5.0, seed);
   double A = g3(167.0, 105.0, seed);
  // cout << "r " << r << " I " << I << " A " << A << endl;
   produce F(r/100.0) SB() Roll(A*PI_VALUE/180.0) Pitch((90-I)*PI_VALUE/180) B(1, alive,order+1) EB() 
           B(0, alive,order);
  }
 else if  (order == 1 && alive>0){
   int seed = 1111111;
   double r = g1(10.0, 1.0, seed);
   double A = 180.0*(u(seed)-0.5);
   double I =100.0*(u(seed)-0.5);
  // cout << "r " << r << " I " << I << " A " << A << endl;
   produce F(r/100.0)  SB() Turn(A*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(1, alive,order+1) EB() 
           B(0, alive-1,order);
  }
 else if  (order == 2 && alive){
   int seed = 1111111;
   double r = g1(10.0, 1.0, seed);
   double A = 180.0*(u(seed)-0.5);
   double I =100.0*(u(seed)-0.5);
  // cout << "r " << r << " I " << I << " A " << A << endl;
   produce F(r/100.0)  SB() Turn(A*PI_VALUE/180.0) Pitch(I*PI_VALUE/180.0) B(1, alive,order+1) EB() 
           B(0, alive-1,order);
  }
 else
   produce B(leaf, alive,order);


}

//This is a ToDO for Jari: interpretation typically
//defines the graphical visualization of symbols. But
//we visualize LIGNUM and thus this is practically 
//unnecessary for us. However, "lc2" cannot compile
//L-files unless you have one  interpretation   

interpretation:

F(s) :
{
  ;
}

//Finally, "close" the "namespace"
close poplar;
