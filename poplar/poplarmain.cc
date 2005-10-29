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
  string metafile = "MetaFile.txt";

  Lex l;

   poplar::LSystem<poplarsegment,poplarbud,PoplarBD, PoplarBudData> poplarL;
   Erythrina::LSystem<poplarsegment,poplarbud,LGMAD,LGMdouble> rootL;
 
  //Create the tree.
   Tree<poplarsegment,poplarbud> poplartree(Point(0, 0, 0),
  			   PositionVector(0,0,1.0));
   /* PoplarTree poplartree("fleafpair.fun","fleafsize.fun",
			"fbudsize.fun","fbudflush.fun",
			"fapical.fun","fvigorindex.fun",
			"fminsegment.fun","fpetiolelength.fun",
			"frce.fun",
			Point(0,0,0),PositionVector(0,0,1.0));*/


  //initialization of parameters and functions
  InitializeTree<poplarsegment, poplarbud> init_poplar(metafile, VERBOSE);
  init_poplar.initialize(poplartree);

  // SetValue(poplartree,TreeRefRadiation,2480.0);

  Firmament& f = GetFirmament(poplartree);
  f.resize(40,20,1200); //resize:  inclinations,  azimuths,  1200 MJ/year for previous tree,  

  //create voxel space 
  VoxelSpace vs(Point(0,0,0), Point(50, 50, 50), 1, 1, 1, 50, 50, 50,  GetFirmament(poplartree)); 
  //  VoxelSpace vs(Point(0,0,0), Point(50, 50, 18), 1, 1, 1, 50, 50, 18,  GetFirmament(poplartree));

  /*  string voxelfile="VoxelSpace.txt";
  ifstream vf(voxelfile.c_str());
   int vx,vy,vz; vx = vy = vz = 0;
  LGMdouble s1,s2,s3; s1 = s2 = s3 = 1.0;
    vf >> vx >> vy >> vz >> s1 >> s2 >> s3;
    cout << "Voxel Space: " << vx << " " << vy << " " << vz << " " 
       << s1 << " " << s2 << " " << s3 << endl;
    VoxelSpace vs(Point(0,0,0),Point(vx,vy,vz), s1,s2,s3, static_cast<int>(vx/s1),	static_cast<int>(vy/s2),	static_cast<int>(vz/s3), GetFirmament(poplartree));
  */

  //Start by evaluating the axiom (see start in sym2d.L)
  poplarL.start();
  rootL.start();
  poplarL.lstringToLignum(poplartree, 1, PoplarD);

   vector<PositionVector> pv;
    AccumulateDown(poplartree,pv,
  	 AppendSequence<vector<PositionVector> >(),
		   CreatePoplarLeaves(0.02,0.01,0.01));   //petiolLength, base and heighth
   
   FILE * fFile;
   float a, b, c, d, e, ff, g, h;
   float direct=0, diffuse=-1, structureFlag=-1;

   char * filename[12]={"jan.dat", "feb.dat", "mar.dat", "apr.dat", 
			"may.dat", "jun.dat", "jul.dat", "aug.dat", 
			"sep.dat", "oct.dat", "nov.dat", "dec.dat" };

  for (int age=0; age<3; age++) // poplarL.derivationLength()--yearly
  {
     cout << "age: " << age << endl;  
   
	fFile = fopen("weatherdata.dat", "r"); // fFile = fopen(filename[month], "r");
       if (fFile==NULL)
        exit(1);   

       while (!feof(fFile))
        {diffuse=-1, structureFlag=-1;
	  vs.reset();  //reset the voxelbox to be initial, all Qabs, Qin to be 0.
       BoundingBox bBox;
       bBox = Accumulate(poplartree, bBox,
			FindHwBoundingBox<poplarsegment,
			poplarbud,Triangle>()); 
      cout << bBox;
      Point span = bBox.getMax()-bBox.getMin();
      int nx, ny, nz;
      if(span.getX() < 0.3)
	nx = 1;
      else
	nx = static_cast<int>(span.getX()/0.3) + 1;
      if(span.getY() < 0.3)
	ny = 1;
      else
	ny = static_cast<int>(span.getY()/0.3) + 1;
      if(span.getZ() < 0.3)
	nz = 1;
      else
	nz = static_cast<int>(span.getZ()/0.3) + 1;
 
      vs.move(bBox.getMin());
      vs.resize(0.3,0.3,0.3,nx,ny,nz);  
	  
        DumpHwTree(vs,poplartree);

	LGMdouble treePhotosynthesis =0; 
	LGMdouble treeRespiration = 0;

	   for (int i=0; i<6*7*24*2; i++)
	     {
             direct=0;
             diffuse=0;
	    if(!feof(fFile))
	      {  //day, time, elevation, azimuth, diffuse, direct, Ta(temperature), VPD(pressure)
	        fscanf(fFile, "%f %f %f %f %f %f %f %f\n", &a, &b, &c, &d, &e, &ff, &g, &h);
                direct =ff;
                diffuse =e;
	      }
           else
	     break;
	    if (diffuse<0.1)
	      continue;

	    //cout<<"direct and diffuse value: "<<direct<<" ,"<<diffuse<<endl;
	    vector<double> a(3);
	    a[0] = sin(d);
            a[1] = cos(d);
            a[2] = c;  

	    vs.resetQinQabs();  //reset the voxelbox to be initial, all Qabs, Qin to be 0.
	    f.setSunPosition(a); 
  
	    f.setDirectRadiation(direct);
	    // f.setDiffuseRadiation(diffuse);  //diffuse
	    //Emole = 2.176 *100000 joule/mole; umole = 0.2176 J = 0.2176 * 10-6 MJ
            //radiation from data file is umole/m2/s

	vs.calculatePoplarLight((LGMdouble)diffuse, (LGMdouble)structureFlag); 
 	//    cout<<"diffuse: "<<diffuse<<" lastdiffuse: "<<lastdiffuse<<endl;
       SetHwTreeQabs(vs,poplartree); 

      LGMdouble maxQin = 0.0;
      maxQin = Accumulate(poplartree, maxQin, GetQinMax<poplarsegment,poplarbud>() );
      SetValue(poplartree, TreeQinMax, maxQin);
      //  cout << "  TreeQinMax: " << maxQin << "  MJ/m2" << endl;

    LGMdouble treeQabs = 0.0;
    treeQabs = Accumulate(poplartree,treeQabs,
			  CollectQabs<poplarsegment,poplarbud>());
    LGMdouble treeLA = 0.0;
    treeLA = Accumulate(poplartree,treeLA,CollectFoliageArea<
			  poplarsegment, poplarbud>());
    //  cout << " Tree leaf area: " << treeLA
    // << "  m2,  Qabs: " << treeQabs << "  MJ,  Qabs/(Qin*LA): "
    // << treeQabs/(treeLA*GetFirmament(poplartree).diffuseBallSensor()) << endl;

  
    // ForEach(poplartree, DoPhotosynthesis()); 
    poplartree.photosynthesis();
 
    treePhotosynthesis += GetValue(poplartree,TreeP);
    //cout << "TreePhotosynthesis:  " << treePhotosynthesis << "  kg C" << endl;
    structureFlag=1;
	  }
 
     ForEach(poplartree, DoRespiration());
	   //poplartree.respiration();

    //One derivation of L-string, above ground trunk and tree crown
    poplarL.derive();
    //below ground roots
    rootL.derive();
    cout << "expand done " << endl;
    //Update tree so that structures match
 
    poplarL.lstringToLignum(poplartree,1, PoplarD);
    rootL.lstringToRootSystem(poplartree);
    // cout << "lstringToLignum done " << endl;
    
    TreePhysiologyVigourIndex(poplartree);
    // cout << "Vigour index" << endl;
     
    LGMdouble p = 0.0, m = 0.0;
    LGMdouble P = treePhotosynthesis;
    LGMdouble M = Accumulate(poplartree,m, SumTreeRespiration<poplarsegment, poplarbud>()) + GetValue(poplartree,LGPmr)* GetValue(poplartree,TreeWr) ;
    SetValue(poplartree,TreeM,M);
    SetValue(poplartree,TreeP,P);
    cout<<"P: "<<P<<" M: "<<M<<endl;
    TreeGrowthAllocatorPropagateUp<poplarsegment, poplarbud,
      SetSegmentLength, TryDiameterGrowth, double> G(poplartree, 0.0);
   
    G.init();
    cout << "G.init finished." << endl;
    cout << "Bisection zero at:  " << Bisection(0.0, 10.0, G, GetValue(poplartree,LGPzbrentEpsilon)) << endl; //GetValue(poplartree,LGPzbrentEpsilon)=0.001

     

     poplarL.lignumToLstring(poplartree,1, PoplarD);  
     rootL.rootSystemToLstring(poplartree);
     cout << "lignumToLstring done " << endl; 

      poplarL.derive();
      cout << "Split done " << endl;

    poplarL.lstringToLignum(poplartree,1, PoplarD);
    rootL.lstringToRootSystem(poplartree);
    cout << "lstringToLignum done " << endl;

    pv.clear();

 
        AccumulateDown(poplartree,pv,
     	   AppendSequence<vector<PositionVector> >(),
           CreatePoplarLeaves(0.0,0.0001,0.0001));   //CreateTriangleLeaves<poplarsegment,poplarbud,Triangle>
      
     ForEach(poplartree,SubAging<poplarsegment,poplarbud>()); 
      double r0 = 0.0;
    PropagateUp(poplartree,r0,ForwardR0());
    // DiameterGrowthData data;  
    TcData data;     
    AccumulateDown(poplartree,data,
		   TreeDiameterGrowth<poplarsegment, poplarbud>());

    /////////do tree pruning
     double length=0.0;
      PropagateUp(poplartree, length, KillPoplarBuds<poplarsegment, poplarbud>());
      poplarL.lignumToLstring(poplartree,1,PoplarD);  
      poplarL.lstringToLignum(poplartree,1,PoplarD);
        poplarL.prune(poplartree);
    
  	}
     fclose(fFile);

    //sapwood senescence
        ForEach(poplartree,TreeAging<poplarsegment,poplarbud>());
    //Root mortality
    SetValue(poplartree,TreeWr, 
	     GetValue(poplartree,TreeWr)-GetValue(poplartree,LGPsr)*
	     GetValue(poplartree,TreeWr));
     
       ForEach(poplartree, WakeupPoplarBuds<poplarsegment, poplarbud>());
        poplarL.lignumToLstring(poplartree,1,PoplarD);  
       poplarL.lstringToLignum(poplartree,1,PoplarD);  
  }

  //Some optional clean up see End in sym2d.L
  poplarL.end();  
  rootL.end();
   
  PrintTreeInformation<poplarsegment, poplarbud, ostream> printPoplar;
  printPoplar(poplartree);    //print out tree information such as tree height, dbh

  // ForEach(poplartree, DropAllLeaves<poplarsegment, poplarbud,Triangle>());

  glutInit(&argc,argv);
  VisualizeHwTree<poplarsegment,poplarbud,Triangle>(poplartree);  

}




