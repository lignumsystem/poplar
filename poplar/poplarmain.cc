#include <Bernoulli.h>
#include <iostream>

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

//Impelements VisualizeLGMTree
#include <OpenGLUnix.h>

//The three following global  variables create problems when compiling
//poplar. You may get undefined symbols for _cam_x, _cam_y and _cam_z
//if commented. If uncommented you may get double decalarations!!!
// GLfloat cam_x;
// GLfloat cam_y;
// GLfloat cam_z;


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
  //poplar.L is the  L-system. LGMAD and LGMdouble are here optional to
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
  // poplarL.lstringToLignum(poplartree,3,LGAstate, LGAstatus, LGAomega);
  poplarL.lstringToLignum(poplartree, 1, PoplarD);
  rootL.lstringToRootSystem(poplartree);
  //Typically  you will  write  something like  this  in the  for-loop
  //(derivationLength returns the derivation length defined in sym2d.L
  //bu naturally  you can ignore  it and derive  as many times  as you
  //want).
  

  Firmament& f = GetFirmament(poplartree);
  //resize:  inclinations,  azimuths,  MJ/year
  f.resize(40,20,1200);
  // vector<double> direct_direction;
  // f.directRadiation(direct_direction);

  cout << "regions: " << f.numberOfRegions() 
       << "Ball sensor: " << f.diffuseBallSensor()
       << "Plant sensor: " <<f.diffusePlaneSensor() <<endl;

  //create voxel space 
  // VoxelSpace vs(Point(0,0,0), Point(200, 200, 200), 4, 4, 4, 50, 50, 50,  GetFirmament(poplartree)); //originally (50, 50, 18), 1,1,1, 50, 50, 18
   VoxelSpace vs(Point(0,0,0), Point(50, 50, 18), 1, 1, 1, 50, 50, 18,  GetFirmament(poplartree));

   vector<PositionVector> pv;
  //Create Leaves (Triangle)
   // AccumulateDown(poplartree,pv,
   // AppendSequence<vector<PositionVector> >(),
   // CreateTriangleLeaves<poplarsegment,poplarbud,Triangle>(0.2,0.1,0.1));

  AccumulateDown(poplartree,pv,
  	 AppendSequence<vector<PositionVector> >(),
  	 CreatePoplarLeaves(0.2,0.1,0.1));



  //initialization of parameters and functions
  InitializeTree<poplarsegment, poplarbud> init_poplar(metafile, VERBOSE);
  init_poplar.initialize(poplartree);


  //**  PoplarGrowthFunction<poplarsegment,poplarbud> G(poplartree);
  //** ParametricCurve K(0.2);
   // EvaluateRadiationForHwTreeSegment<poplarsegment, poplarbud> R(K);
  //double wf=0;
  //  wf= Accumulate(poplartree, wf, CollectPAndM<poplarsegment, poplarbud>());
  // cout<<"result of collectnew foliage:  "<<wf<<endl;
  
    TreeGrowthAllocatorPropagateUp<poplarsegment, poplarbud,
       SetSegmentLength, TryDiameterGrowth, double> G(poplartree, 0.0);

   
   FILE * fFile;
   float a, b, c, d, e, ff, g, h;
   float direct=0, diffuse=100;

   char * filename[12]={"jan.dat", "feb.dat", "mar.dat", "apr.dat", 
			"may.dat", "jun.dat", "jul.dat", "aug.dat", 
			"sep.dat", "oct.dat", "nov.dat", "dec.dat" };
 
  for (int i=0; i <2; i++) // poplarL.derivationLength()--yearly
  {
     cout << "Step: " << i << endl;  
   
	fFile = fopen("weatherdata.dat", "r"); // fFile = fopen(filename[month], "r");
       if (fFile==NULL)
        exit(1);   
	
       while (!feof(fFile))
        {
           vs.reset();  //reset the voxelbox to be initial, all Qabs, Qin to be 0.
           DumpHwTree(vs, poplartree);       // dumpPopTree(vs, poplartree);
            direct=0;
            diffuse=0;
	      // cout<<"new cycle. "<<endl;
	   for (int i=0; i<4*7*24*2; i++)
	  {
	   fscanf(fFile, "%f %f %f %f %f %f %f %f\n", &a, &b, &c, &d, &e, &ff, &g, &h);

            direct +=ff;
            diffuse +=e;

	    /*    vector<double> a(3);
            a[0] = cos(d)*sin(c);
            a[1] = cos(d)*cos(c);
            a[2] = sin(d);

            f.setSunPosition(a);   
	    f.setDirectRadiation(direct);
	    f.setDiffuseRadiation(diffuse);
	    vs.calculatePoplarLight();*/
	   }
       cout<<"direct and diffuse value: "<<direct<<" ,"<<diffuse<<endl;
  vector<double> a(3);
            a[0] = 0;
            a[1] = 0;
            a[2] = 1;
	    f.setSunPosition(a);   
	    f.setDirectRadiation(direct);
	    f.setDiffuseRadiation(diffuse);
	    // vs.calculatePoplarLight(); 
	     vs.calculateTurbidLight();

  
	    //cout<<"calculatePoplarLight."<<endl;
        SetHwTreeQabs(vs,poplartree);  
        ForEach(poplartree, DoPhotosynthesis());  //ForEach(poplartree, CollectPhotosynthates());
        ForEach(poplartree, DoRespiration()); 
	   //cout<<"finish photosynthesis. "<<endl;
	//poplarL.lignumToLstring(poplartree,3,LGAstate, LGAstatus, LGAomega);  
    poplarL.lignumToLstring(poplartree, 1, PoplarD);  
    rootL.rootSystemToLstring(poplartree);
    cout << "lignumToLstring done " << endl; 
  
    //One derivation of L-string, above ground trunk and tree crown
    poplarL.derive();
    //below ground roots
    rootL.derive();
    cout << "expand done " << endl;
    //Update tree so that structures match
 
    //poplarL.lstringToLignum(poplartree,3,LGAstate, LGAstatus, LGAomega );
    poplarL.lstringToLignum(poplartree,1, PoplarD);
    rootL.lstringToRootSystem(poplartree);
    cout << "lstringToLignum done " << endl;
    
    TreePhysiologyVigourIndex(poplartree);
    cout << "Vigour index" << endl;
    G.init();
    cout << "Bisection zero at:  " << Bisection(0.0, 100.0, G, GetValue(poplartree,LGPzbrentEpsilon)) << endl;
   
    //poplarL.lignumToLstring(poplartree,3,LGAstate, LGAstatus, LGAomega);  
    poplarL.lignumToLstring(poplartree,1, PoplarD);  
    rootL.rootSystemToLstring(poplartree);
    cout << "lignumToLstring done " << endl; 

      poplarL.derive();
      cout << "Split done " << endl;

      // poplarL.lstringToLignum(poplartree,3,LGAstate, LGAstatus, LGAomega);
    poplarL.lstringToLignum(poplartree,1, PoplarD);
    rootL.lstringToRootSystem(poplartree);
    cout << "lstringToLignum done " << endl;

    pv.clear();
    //     AccumulateDown(poplartree,pv,
    // 	   AppendSequence<vector<PositionVector> >(),
    //        CreateTriangleLeaves<poplarsegment,poplarbud,Triangle>(0.2,0.1,0.1));

         AccumulateDown(poplartree,pv,
     	   AppendSequence<vector<PositionVector> >(),
            CreatePoplarLeaves(0.2,0.1,0.1));


  
    ForEach(poplartree,SubAging<poplarsegment,poplarbud>());  

    TcData data;    // DiameterGrowthData data;     
    AccumulateDown(poplartree,data,TreeDiameterGrowth<poplarsegment,poplarbud>());
      
      /////////do tree pruning"
      double length=0.0;
      PropagateUp(poplartree, length, KillPoplarBuds<poplarsegment, poplarbud>());
      // poplarL.lignumToLstring(poplartree,3,LGAstate, LGAstatus, LGAomega);  
      // poplarL.lstringToLignum(poplartree,3,LGAstate, LGAstatus, LGAomega);
      poplarL.lignumToLstring(poplartree,1,PoplarD);  
      poplarL.lstringToLignum(poplartree, 1, PoplarD);
      poplarL.prune(poplartree);

  }
    fclose(fFile);


    //  ForEach(poplartree,IncreaseAge<poplarsegment,poplarbud>(1.0));
    ForEach(poplartree,TreeAging<poplarsegment,poplarbud>()); 
	 // ForEach(poplartree,SubAging<poplarsegment,poplarbud>()); 

         ForEach(poplartree, WakeupPoplarBuds<poplarsegment, poplarbud>());
	 // poplarL.lignumToLstring(poplartree,3,LGAstate, LGAstatus, LGAomega);  
	 // poplarL.lstringToLignum(poplartree,3,LGAstate, LGAstatus, LGAomega);
         poplarL.lignumToLstring(poplartree,1,PoplarD);  
         poplarL.lstringToLignum(poplartree,1,PoplarD);  
  }

  //Some optional clean up see End in sym2d.L
  poplarL.end();  
  rootL.end();
  cout << endl;

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

     PrintTreeInformation<poplarsegment, poplarbud, ostream> printPoplar;
     printPoplar(poplartree);    //print out tree information such as tree height, dbh

     //  ForEach(poplartree, DropAllLeaves<poplarsegment, poplarbud,Triangle>());

  glutInit(&argc,argv);
   VisualizeHwTree<poplarsegment,poplarbud,Triangle>(poplartree);  

}






        //*****test bernoulli from poplar/bernoulli****
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
    //test bernoull done

 //*****test Bernoulli from c++adt/Bernoulli****

    /*   // Bernoulli ber( -1);
    long int seed;
    //  int seed=2222;
   double  test;
   int zero=0, one=0;
   seed=-time(0);
   Bernoulli ber(seed);
   for (int i=1; i<101; i++)
     {
       // cout<<"seed:"<<seed<<" ";
      double b=ber(0.4, seed - i);
      cout << b <<"  ";
      if (i%10==0) cout <<endl;
      if (b>0.5) one++;
      else zero++;    
    }
    cout << endl;
    cout <<"test result: "<<one <<" and " << zero << endl;
    test= (double)one/(double)(one+zero);
    cout << test <<endl;
    //test Bernoull done
*/

