//Include Lignum implementation 
#include <Lignum.h>

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
int main(int argc, char** argv)
{
  //sym2dL is the  L-system. LGMAD and LGMdouble are  here optional to
  //remind you  that there is  a possibility to data  exchange between
  //L-system and LIGNUM (in this example it is not used)
  poplar::LSystem<poplarsegment,poplarbud,LGMAD,LGMdouble> poplarL;
  //Create the tree.
  Tree<poplarsegment,poplarbud> poplartree(Point(0,0,0),
					  PositionVector(0,0,1.0));
  //Start by evaluating the axiom (see start in sym2d.L)
  poplarL.start();
  //Update tree so that structures match
  poplarL.lstringToLignum(poplartree,1,LGMstatus);
  //Typically  you will  write  something like  this  in the  for-loop
  //(derivationLength returns the derivation length defined in sym2d.L
  //bu naturally  you can ignore  it and derive  as many times  as you
  //want).
  vector<PositionVector> pv;
  AccumulateDown(poplartree,pv,
		 AppendSequence<vector<PositionVector> >(),
		 CreateLeaves<poplarsegment,poplarbud>(0.5,0.5,0.5));
  for (int i=0; i < poplarL.derivationLength() ; i++)
  {
    
    cout << "Step: " << i << endl;  
    ForEach(poplartree,DoPhotosynthesis());
    ForEach(poplartree,DoRespiration());
    // LGMdouble init = 0.0;
    // LGMdouble p = Accumulate(poplartree,init,CollectPhotosynthates());
    // init = 0.0;
    //cout<<"all p:"<<p<<endl;
    // LGMdouble m = Accumulate(poplartree,init,CollectRespiration());
    //cout<<"all m:"<<m<<endl;
    UnitPM unit(0.0, 0.0);
    UnitPM m=Accumulate(poplartree,unit,CollectPAndM());
    //Update string so that structures match
    poplarL.lignumToLstring(poplartree,1,LGMstatus);  
    
    cout << "lignumToLstring done " << endl;
    //one derivation 
    ForEach(poplartree,DropAllLeaves<poplarsegment,poplarbud>());
    poplarL.derive();
    cout << "derive done " << endl;
    //Update tree so that structures match
    poplarL.lstringToLignum(poplartree,1,LGMstatus);
    cout << "lstringToLignum done " << endl;
    pv.clear();
    AccumulateDown(poplartree,pv,
    		   AppendSequence<vector<PositionVector> >(),
      		   CreateLeaves<poplarsegment,poplarbud>(0.5,0.5,0.5));
  }

  //Some optional clean up see End in sym2d.L
  poplarL.end();  
  cout << endl;
  //Visualize  LIGNUM  - Note  the  Graphics  is  under development  so
  //interface may change but in  any case you will have some function.
  //But because you know OpenGL you probably can visualize the tree
  //yourself! Let us know if you do so, we probly use it!
  VisualizeHwTree(poplartree);
}
