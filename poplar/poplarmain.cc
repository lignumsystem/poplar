#include "randomc.h"
#include "bernoulli.h"
#include <Bernoulli.h>

//Include Lignum implementation 
#include <Lignum.h>
#include <RootFunctor.h>
#include <CompareLeaves.h>
#include <Bisection.h>
#include <Shading.h>


//Include the implementation of the  tree segment and bud You probably
//define your own segment and bud in real project for cottonwood.
#include <poplar.h>
#include <poplarmetabolism.h>
#include <VoxelSpace.h>


//Impelements  VisualizeLGMTree.  Visualization  may and  probaly will
//change in the future so the header file name may be something else.
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

  int iterations = 3;
  string metafile = "MetaFile.txt";
  /* if (argc != 3){
    cout << "Usage: ./pine Iterations MetaFile" << endl;
    return 0;
  }
  else{
    iterations = atoi(argv[argc-2]);
    metafile = string(argv[argc-1]);
  }
  */
  Lex l;
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
  

  Firmament& f = GetFirmament(poplartree);
  //resize:  inclinations,  azimuths,  MJ/year
  f.resize(40,20,1200);


  cout << "regions: " << f.numberOfRegions() 
       << "Ball sensor: " << f.diffuseBallSensor()
       << "Plant sensor: " <<f.diffusePlaneSensor() <<endl;

  //create voxel space 
   VoxelSpace vs(Point(0,0,0), Point(50, 50, 18), 1, 1, 1, 50, 50, 18,  GetFirmament(poplartree));
  

   vector<PositionVector> pv;
  //Create Leaves (Ellipse)
  AccumulateDown(poplartree,pv,
  	 AppendSequence<vector<PositionVector> >(),
  	 CreateTriangleLeaves<poplarsegment,poplarbud,Triangle>(0.2,0.1,0.1));

  //initialization of parameters and functions
  InitializeTree<poplarsegment, poplarbud> init_poplar(metafile, VERBOSE);
  init_poplar.initialize(poplartree);


   PoplarGrowthFunction<poplarsegment,poplarbud> G(poplartree);
   ParametricCurve K(0.2);
   // EvaluateRadiationForHwTreeSegment<poplarsegment, poplarbud> R(K);

  //double wf=0;
  //  wf= Accumulate(poplartree, wf, CollectPAndM<poplarsegment, poplarbud>());
  // cout<<"result of collectnew foliage:  "<<wf<<endl;

 

  for (int i=0; i < 3; i++) // poplarL.derivationLength()
  //for (int i=0; i < 7 ; i++)
  {
    
    cout << "Step: " << i << endl;  
   
      ForEach(poplartree, DoPhotosynthesis());
     ForEach(poplartree, DoRespiration());
   
    poplarL.lignumToLstring(poplartree,1,LGMstatus);  
    rootL.rootSystemToLstring(poplartree);
    cout << "lignumToLstring done " << endl;
    //One derivation of L-string, above ground trunk and tree crown
    poplarL.derive();
    //below ground roots
    rootL.derive();
    cout << "derive done " << endl;
    //Update tree so that structures match
    ForEach(poplartree,TreeAging<poplarsegment,poplarbud>());
       G.init();
       cout<<"init done"<<endl;
       // cout << "Bisection zero at:  " << Bisection(0.0,10.0,G) << endl;
       //    Bisection(0.0, 50.0, G);
    ForEach(poplartree, SetSegmentLength<poplarsegment, poplarbud>(1.0));

    TcData data;
    AccumulateDown(poplartree,data,TreeDiameterGrowth<poplarsegment,poplarbud>());
    // cout<<".....................TcData............."<<GetValue(data, As)<<endl;


    poplarL.lstringToLignum(poplartree,1,LGMstatus);
    rootL.lstringToRootSystem(poplartree);
    cout << "lstringToLignum done " << endl;

    pv.clear();
    AccumulateDown(poplartree,pv,
  	 AppendSequence<vector<PositionVector> >(),
  	 CreateTriangleLeaves<poplarsegment,poplarbud,Triangle>(0.2,0.1,0.1));

   vs.reset();
   dumpPopTree(vs, poplartree);
 
   vs.calculatePopLight();
  }

  //Some optional clean up see End in sym2d.L
  poplarL.end();  
  rootL.end();
  cout << endl;

  // ForEach(poplartree, DoPhotosynthesis());
  // ForEach(poplartree, DoRespiration());


 
  //Compare Leaves
  //ForEach(poplartree,ForEachLeafCompare<poplarsegment,poplarbud,Triangle>());
  //Demonstration of Algorithms for root system
  /*  ForEach(GetRootAxis(poplartree),
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
  cout << endl << "Display root structure done" << endl;*/
  
  //Visualize  LIGNUM  - Note  the  Graphics  is  under development  so
  //interface may change but in  any case you will have some function.
  //But because you know OpenGL you probably can visualize the tree
  //yourself! Let us know if you do so, we probly use it!

      //   VisualizeHwTree<poplarsegment,poplarbud,Triangle>(poplartree);

        //*****test Bernoulli from c++adt/Bernoulli****
      /* long int seed =time(0);
    cout<<"do nothing"<< endl;
    double p=0.3, result, test;
    int zero=0, one=0;
    StochasticLib obj(seed);
    for (int i=1; i<10001; i++)
    { 
     result=obj.Bernoulli(p);
     cout << result <<"  ";
     if (i%10==0) cout <<endl;
     if (result>0.5) one++;
     else zero++;    
    }
    cout << endl;
    cout <<"test result: "<<one <<" and " << zero << endl;
    test= (double)one/(double)(one+zero);
    cout << test <<endl; */
    //test Bernoull done

}
