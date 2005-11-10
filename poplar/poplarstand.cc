#include <algorithm>
#include <iostream>
#include <iomanip>

//Include Lignum implementation 
#include <Lignum.h>
#include <RootFunctor.h>
#include <TreeFunctor.h>
#include <TreeFunctorI.h>
//#include <Zbrent.h>
#include <CompareLeaves.h>
#include <Bisection.h>
#include <Shading.h>

//Include the implementation of the  tree segment and bud You probably
//define your own segment and bud in real project for cottonwood.
#include <poplar.h>
#include <poplarmetabolism.h>
#include <VoxelSpace.h>
#include <VisualFunctor.h>
#include <Polygon.h>
//Impelements VisualizeLGMTree
#include <GLSettings.h>
#include <OpenGLUnix.h>

//Includes all kinds of stuff, turtle graphics etc.
//Include this always for your program
#include <lengine.h>

#include <time.h>   //temperary for creating stochastic seed=time();

//LSystem captures the rewriting process  This is how you get acces to
//rewriting process defined in  sym2d.L: wrap LSystem.h into namespace
//corresponding namespace. You can naturally have several L-systems in
//your program. See examples in LEngine/L2Lignum.
namespace poplar{
#include <LSystem.h>
}

namespace Erythrina{
#include <LSystem.h>
}

int main(int argc, char** argv)
{
  //Implement the poplar stand here

}




