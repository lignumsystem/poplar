#include <Bernoulli.h>
#include <iostream>

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
#include <VisualFunctor.h>

//Impelements VisualizeLGMTree
#include <OpenGLUnix.h>

//The three following global  variables create problems when compiling
//poplar. You may get undefined symbols for _cam_x, _cam_y and _cam_z
//if commented. If uncommented you may get double decalarations!!!
// GLfloat cam_x;
// GLfloat cam_y;
// GLfloat cam_z;

//Impelements  VisualizeLGMTree.  Visualization  may and  probaly will
//change in the future so the header file name may be something else.
//#include <OpenGLUnix.h>

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
  poplarL.lstringToLignum(poplartree,1,LGAstatus);
  rootL.lstringToRootSystem(poplartree);
  //Typically  you will  write  something like  this  in the  for-loop
  //(derivationLength returns the derivation length defined in sym2d.L
  //bu naturally  you can ignore  it and derive  as many times  as you
  //want).
  

  Firmament& f = GetFirmament(poplartree);
  //resize:  inclinations,  azimuths,  MJ/year
  f.resize(40,20,1200);
  // vector<double> direct_direction;
  //  f.directRadiation(direct_direction);

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

   FILE * fFile;
   float a, b, c, d, e, ff, g, h;
   float direct, diffuse;

   char * filename[12]={"jan.dat", "feb.dat", "mar.dat", "apr.dat", 
			"may.dat", "jun.dat", "jul.dat", "aug.dat", 
			"sep.dat", "oct.dat", "nov.dat", "dec.dat" };

  for (int i=0; i < 3; i++) // poplarL.derivationLength()--yearly
  //for (int i=0; i < 7 ; i++)
  {
    
    cout << "Step: " << i << endl;  


    //weather data read begin:

    //   for (int month=0; month<12; month++)
      {
    vs.reset();
    DumpHwTree(vs, poplartree);   

     fFile = fopen("weatherdata.dat", "r"); 
    // fFile = fopen(filename[month], "r");
    if (fFile==NULL)
      exit(1);
    
    int j=0;
    while (!feof(fFile))
      {
	if(j<6)
	  {
            fscanf(fFile, "%f %f %f %f %f %f %f %f\n", &a, &b, &c, &d, &e, &ff, &g, &h);
	    // cout<<a<<" "<<b<<" "<<c<<" "<<d<<" "<<e<<" "<<ff<<" "<<g<<endl;
	    direct += e/6;
            diffuse += ff/6; 
            j++;
	  }
        else
	  {
	    j=0;
	    vector<double> a(3);
            a[0] = cos(d)*sin(c);
            a[1] = cos(d)*cos(c);
            a[2] = sin(d);
            f.setSunPosition(a);   
	    f.setDirectRadiation(direct);
	    f.setDiffuseRadiation(diffuse);
 
            vs.calculatePoplarLight();
 
	    ForEach(poplartree, DoPhotosynthesis());
            ForEach(poplartree, DoRespiration()); 
	  }
	
      }
    fclose(fFile);
    //weather data read done
   

   
    poplarL.lignumToLstring(poplartree,1,LGAstatus);  
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
    ForEach(poplartree, SetSegmentLength<poplarsegment, poplarbud>(1.0)); //defined in poplar.h

    TcData data;
    AccumulateDown(poplartree,data,TreeDiameterGrowth<poplarsegment,poplarbud>());
    // cout<<".....................TcData............."<<GetValue(data, As)<<endl;

    poplarL.lstringToLignum(poplartree,1,LGAstatus);
    rootL.lstringToRootSystem(poplartree);
    cout << "lstringToLignum done " << endl;

    pv.clear();
    AccumulateDown(poplartree,pv,
		   AppendSequence<vector<PositionVector> >(),
		   CreateTriangleLeaves<poplarsegment,poplarbud,Triangle>(0.2,0.1,0.1));
      }

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

  glutInit(&argc,argv);
   VisualizeHwTree<poplarsegment,poplarbud,Triangle>(poplartree);  //program stuck here Jan202004


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

