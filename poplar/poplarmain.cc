//Include Lignum implementation 
#include <Lignum.h>
#include <RootFunctor.h>
#include <CompareLeaves.h>

//Include the implementation of the  tree segment and bud You probably
//define your own segment and bud in real project for cottonwood.
#include <poplar.h>
#include <poplarmetabolism.h>

//Impelements  VisualizeLGMTree.  Visualization  may and  probaly will
//change in the future so the header file name may be something else.
#include <OpenGLUnix.h>

//Includes all kinds of stuff, turtle graphics etc.
//Include this always for your program
#include <lengine.h>

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
  //poplar.L is the  L-system. LGMAD and LGMdouble are  here optional to
  //remind you  that there is  a possibility to data  exchange between
  //L-system and LIGNUM (in this example it is not used)
  poplar::LSystem<poplarsegment,poplarbud,LGMAD,LGMdouble> poplarL;
  //Give Erythrina roots for poplar defined in ErythrinaRoots.L
  Erythrina::LSystem<poplarsegment,poplarbud,LGMAD,LGMdouble> rootL;

  //Create the tree.
  Tree<poplarsegment,poplarbud> poplartree(Point(0,0,0),
					   PositionVector(0,0,1.0));
  //Start by evaluating the axiom (see start in sym2d.L)
  poplarL.start();
  rootL.start();
  //Update tree so that structures match
  poplarL.lstringToLignum(poplartree,1,LGMstatus);
  rootL.lstringToRootSystem(poplartree);
  //Typically  you will  write  something like  this  in the  for-loop
  //(derivationLength returns the derivation length defined in sym2d.L
  //bu naturally  you can ignore  it and derive  as many times  as you
  //want).
  
  for (int i=0; i < poplarL.derivationLength() ; i++)
  {
    
    cout << "Step: " << i << endl;  
    
    poplarL.lignumToLstring(poplartree,1,LGMstatus);  
    rootL.rootSystemToLstring(poplartree);
    cout << "lignumToLstring done " << endl;
    //One derivation of L-string, above ground trunk and tree crown
    poplarL.derive();
    //below ground roots
    rootL.derive();
    cout << "derive done " << endl;
    //Update tree so that structures match
    poplarL.lstringToLignum(poplartree,1,LGMstatus);
    rootL.lstringToRootSystem(poplartree);
    cout << "lstringToLignum done " << endl;
  }

  //Some optional clean up see End in sym2d.L
  poplarL.end();  
  rootL.end();
  cout << endl;
  vector<PositionVector> pv;
  //Create Leaves (Ellipse)
  AccumulateDown(poplartree,pv,
		 AppendSequence<vector<PositionVector> >(),
		 CreateLeaves<poplarsegment,poplarbud,Ellipse>(0.5,0.5,0.5));

  //Compare Leaves
  ForEach(poplartree,ForEachLeafCompare<poplarsegment,poplarbud,Ellipse>());
  //Demonstration of Algorithms for root system
  ForEach(GetRootAxis(poplartree),
	  EchoCompartmentName<Tree<poplarsegment,poplarbud> >());
  int sum = 0;
  sum = Accumulate(GetRootAxis(poplartree),sum,
		   CountRootCompartments<Tree<poplarsegment,poplarbud>,int>());
  cout << "Accumulate Number of root compartments: " << sum << endl;
  
  sum = 0;
  sum = AccumulateDown(GetRootAxis(poplartree),sum,
		       CountRootCompartments<Tree<poplarsegment,poplarbud>,int>());
  cout << "AccumulateDown (1) Number of root compartments: " << sum << endl;

  sum = 0;
  sum = AccumulateDown(GetRootAxis(poplartree),sum,
		       AddRootCompartments<int>(),
		       CountRootCompartments<Tree<poplarsegment,poplarbud>,int>());
  cout << "AccumulateDown (2) Number of root compartments: " << sum << endl;

  cout << "PropagateUp status as reference" << endl;
  LGMdouble s=0.0;
  PropagateUp(GetRootAxis(poplartree),s,
	      PropagateStatusAsReference<Tree<poplarsegment,poplarbud> >());
  cout << "PropagateUp status as reference done" << endl;

  cout << "PropagateUp status as value" << endl;
  s=0.0;
  PropagateUp(GetRootAxis(poplartree),s,
	      PropagateStatusAsValue<Tree<poplarsegment,poplarbud> >());
  cout << "PropagateUp status as value done" << endl;

  cout << "Display root structure" << endl;
  DisplayStructure(GetRootAxis(poplartree));
  cout << endl << "Display root structure done" << endl;
  
  //Visualize  LIGNUM  - Note  the  Graphics  is  under development  so
  //interface may change but in  any case you will have some function.
  //But because you know OpenGL you probably can visualize the tree
  //yourself! Let us know if you do so, we probly use it!
  VisualizeHwTree(poplartree);
}
