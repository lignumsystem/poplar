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
#include <XMLTree.h>
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


double temperature;
float day1=0, day2=0;

int main(int argc, char** argv)
{
  string metafile = "MetaFile.txt";
  string xmlfile;//tree output file
  Lex l;

  poplar::LSystem<poplarsegment,poplarbud,PoplarBD, PoplarBudData> poplarL;
  Erythrina::LSystem<poplarsegment,poplarbud,LGMAD,LGMdouble> rootL;
 
  //Save the simulated poplar to xmlfile
  ParseCommandLine(argc,argv,"-xml",xmlfile);
 
  //Create the tree.
   Tree<poplarsegment,poplarbud> poplartree(Point(5.0, 5.0, 0),
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
  // VoxelSpace vs(Point(0,0,0), Point(10, 10, 10), 0.2, 0.2, 0.2, 50, 50, 50,  GetFirmament(poplartree)); 
    VoxelSpace vs(Point(0,0,0), Point(50, 50, 18), 1, 1, 1, 50, 50, 18,  GetFirmament(poplartree));

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
  //cout << "Start" <<endl;
  rootL.start();
  //cout << "RootStart" <<endl;
  poplarL.lstringToLignum(poplartree, 1, PoplarD);
  //DisplayStructure(poplartree);
   vector<PositionVector> pv;
    AccumulateDown(poplartree,pv,
  	 AppendSequence<vector<PositionVector> >(),
		   CreatePoplarLeaves(0.02,0.01,0.01));   //petiolLength, base and heighth
   
   FILE * fFile;
   float a, b, c, d, e, ff, g, h;
   float direct=0, diffuse=-1, structureFlag=-1;
   int drop_leaf_flag=1;
   char * filename[12]={"jan.dat", "feb.dat", "mar.dat", "apr.dat", 
			"may.dat", "jun.dat", "jul.dat", "aug.dat", 
			"sep.dat", "oct.dat", "nov.dat", "dec.dat" };

   int derivation=4;
   srand(time(NULL));
  for (int age=0; age<2 /*derivation*/; age++) // poplarL.derivationLength()--yearly
  {   day1=0; day2=0;
     cout << "age: " << age << endl;  
	fFile = fopen("weatherdata.dat", "r"); // fFile = fopen(filename[month], "r");
       if (fFile==NULL)
        exit(1);   
  
       while (!feof(fFile))
        { 
           diffuse=-1, structureFlag=-1;
	  vs.reset();  //reset the voxelbox to be initial, all Qabs, Qin, leafarea to be 0.
       BoundingBox bBox;
       bBox = Accumulate(poplartree, bBox,
			FindHwBoundingBox<poplarsegment,
			poplarbud,Triangle>()); 
      cout << bBox;
      Point span = bBox.getMax()-bBox.getMin();
      cout<<"span: "<<span.getX()<<" "<<span.getY()<<" "<<span.getZ()<<endl;
      int nx, ny, nz;
      float vsize=0.2;
      if(span.getX() < vsize )
	nx = 3;
      else
	nx = static_cast<int>(span.getX()/vsize) + 3;
      if(span.getY() < vsize)
	ny = 3;
      else
	ny = static_cast<int>(span.getY()/vsize) + 3;
      if(span.getZ() < vsize)
	nz = 3;
      else
	nz = static_cast<int>(span.getZ()/vsize) + 3;
 
      vs.move(bBox.getMin());
      vs.resize(vsize, vsize, vsize,nx,ny,nz);  
	  
        DumpHwTree(vs,poplartree);

	LGMdouble tree_photosynthesis =0; 
	LGMdouble tree_respiration = 0;
	LGMdouble last_diffuse=0;
	f.setDiffuseRadiation(1200);
	//int day=0;
	   for (int i=0; i<6*7*24*2; i++)
	     { 
             direct=0;
             diffuse=0;
	    if(!feof(fFile))
	      {  //day, time, elevation, azimuth, diffuse, direct, Ta(temperature), VPD(pressure)
	        fscanf(fFile, "%f %f %f %f %f %f %f %f\n", &a, &b, &c, &d, &e, &ff, &g, &h);
                direct =ff;
                diffuse =e;
		day2=a;
	      }
           else
	     break;
	    temperature = (double)g;
	    if (diffuse<0.1)
	      continue;
	
	    //  cout<<"direct and diffuse value: "<<direct<<"   "<<diffuse<<endl;
	    vector<double> a(3);
	    a[0] = sin(d);
            a[1] = cos(d);
            a[2] = c;  

	    vs.resetQinQabs();  //reset the voxelbox to be initial, all Qabs, Qin to be 0.
	    f.setSunPosition(a); 
  
	    f.setDirectRadiation(direct);
	    // f.setDiffuseRadiation(diffuse);  //diffuse
	    last_diffuse = diffuse;
       
	vs.calculatePoplarLight((LGMdouble)(diffuse), (LGMdouble)structureFlag); 
	
        SetHwTreeQabs(vs,poplartree); 
	// cout<<" setHwTree."<<endl;
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
    // cout << " Tree leaf area: " << treeLA << "  m2,  Qabs: " << treeQabs << "  MJ,  Qabs/(Qin*LA): " << treeQabs/(treeLA*GetFirmament(poplartree).diffuseBallSensor()) << endl;
    
  
    // ForEach(poplartree, DoPhotosynthesis()); 
    poplartree.photosynthesis();
 
    tree_photosynthesis += GetValue(poplartree,TreeP);
    // cout << "Photosynthesis in 30 minutes:  " << GetValue(poplartree,TreeP) << endl;
    structureFlag=1;
	  }
    cout << "TreePhotosynthesis:  " << tree_photosynthesis<<endl;
     f.setDiffuseRadiation(last_diffuse);
 
    ForEach(poplartree, DoRespiration()); //poplartree.respiration(); //
 
    ForEach(poplartree,SubAging<poplarsegment,poplarbud>()); 
  
    //One derivation of L-string, above ground trunk and tree crown
    poplarL.derive();
    //below ground roots
    rootL.derive();
    cout << "expand done " << endl;
    //Update tree so that structures match
 
    poplarL.lstringToLignum(poplartree,1, PoplarD);
    rootL.lstringToRootSystem(poplartree);
    cout << "lstringToLignum done " << endl;
    //DisplayStructure(poplartree);   
    TreePhysiologyVigourIndex(poplartree);
    // cout << "Vigour index" << endl;
     
    LGMdouble p = 0.0, m = 0.0;
    LGMdouble P = tree_photosynthesis;
    LGMdouble M = Accumulate(poplartree,m, SumTreeRespiration<poplarsegment, poplarbud>())+ GetValue(poplartree,LGPmr)* GetValue(poplartree,TreeWr);  //0.1 * GetValue(poplartree,TreeWr) * 0.15;   // GetValue(poplartree,LGPmr)* GetValue(poplartree,TreeWr);   
    if (M>P) P=M+0.001;
    SetValue(poplartree,TreeM,M);  
    SetValue(poplartree,TreeP,P);
    cout<<"P: "<<P<<" M: "<<M<<endl;
    TreeGrowthAllocatorPropagateUp<poplarsegment, poplarbud,
      SetSegmentLength, TryDiameterGrowth, double> G(poplartree, 0.0);
   
    G.init();
    cout << "G.init finished." << endl;
    cout << "Bisection zero at:  " << Bisection(0.0, 10.0, G, GetValue(poplartree,LGPzbrentEpsilon)) << endl; //GetValue(poplartree,LGPzbrentEpsilon)=0.001
  cout << "bisection finished." << endl;
     //growth allocation need leaves to get Qin for segment so dropLeaves should behind Bisection   


 
   if(drop_leaf_flag==1)
   {//cout<<"drop leaves."<<endl;
     ForEach(poplartree, DropAllLeaves<poplarsegment, poplarbud,Triangle>());
     drop_leaf_flag=0;
   } 
 

     //DisplayStructure(poplartree);
     poplarL.lignumToLstring(poplartree,1, PoplarD);  
     rootL.rootSystemToLstring(poplartree);
     cout << "lignumToLstring done " << endl; 

      poplarL.derive();
      cout << "Split done " << endl;

    poplarL.lstringToLignum(poplartree,1, PoplarD);
    rootL.lstringToRootSystem(poplartree);
    // cout << "lstringToLignum done " << endl;
    //DisplayStructure(poplartree); 
    pv.clear();
        AccumulateDown(poplartree,pv,
     	   AppendSequence<vector<PositionVector> >(),
           CreatePoplarLeaves(0.0,0.0001,0.0001));   //CreateTriangleLeaves<poplarsegment,poplarbud,Triangle>
  
     pair<double, double> r0Qin(0.0, 0.0);
     //   double r0Qin = 0.0;
     PropagateUp(poplartree,r0Qin,ForwardR0Qin());
    // DiameterGrowthData data;  
    TcData data;     
    AccumulateDown(poplartree,data,
		   TreeDiameterGrowth<poplarsegment, poplarbud>());
    LGMdouble lMass = 0.0;
    lMass = Accumulate(poplartree,lMass,
                       CollectFoliageMass<poplarsegment,poplarbud>());
    //*cout<<"TreeWr: "<<GetValue(poplartree,TreeWr)<<" : "<<GetValue(poplartree,LGPar)*lMass<<endl;
    SetValue(poplartree, TreeWr, 
             GetValue(poplartree,TreeWr)+GetValue(poplartree,LGPar)*lMass);
 
          /////////do tree pruning
     double length=0.0;
      PropagateUp(poplartree, length, KillPoplarBuds<poplarsegment, poplarbud>());
      poplarL.lignumToLstring(poplartree,1,PoplarD);  
      poplarL.lstringToLignum(poplartree,1,PoplarD);
      poplarL.prune(poplartree);
	 

      /*      bBox = Accumulate(poplartree, bBox,
			FindHwBoundingBox<poplarsegment,
			poplarbud,Triangle>()); 
      cout << bBox;
      span = bBox.getMax()-bBox.getMin();
      cout<<"span: "<<span.getX()<<" "<<span.getY()<<" "<<span.getZ()<<endl;*/
}
     fclose(fFile);
    if (age==derivation-1)
      cout<<"root mass age of "<<derivation<<": "<<GetValue(poplartree,TreeWr)<<endl;
    //sapwood senescence
      ForEach(poplartree,TreeAging<poplarsegment,poplarbud>());   //use this if using subage
    //Root mortality
    SetValue(poplartree,TreeWr, 
	     GetValue(poplartree,TreeWr)-GetValue(poplartree,LGPsr)/4 *
	     GetValue(poplartree,TreeWr));
     
    ForEach(poplartree, WakeupPoplarBuds<poplarsegment, poplarbud>());
    poplarL.lignumToLstring(poplartree,1,PoplarD);  
    poplarL.lstringToLignum(poplartree,1,PoplarD);  
    drop_leaf_flag=1;

  
    // ForEach(poplartree, DropAllLeaves<poplarsegment, poplarbud,Triangle>());
  
    // PrintTreeInformation<poplarsegment, poplarbud, ostream> printPoplar;
    // printPoplar(poplartree);    //print out tree information such as tree height, dbh
  }

  //Some optional clean up see End in sym2d.L
  poplarL.end();  
  rootL.end();
  PrintTreeInformation<poplarsegment, poplarbud, ostream> printPoplar;
  printPoplar(poplartree);    //print out tree information such as tree height, dbh

  // ForEach(poplartree, DropAllLeaves<poplarsegment, poplarbud,Triangle>());

  if (xmlfile.length() > 0){
    XMLDomTreeWriter<poplarsegment,poplarbud,Triangle> writer;
    writer.writeTreeToXML(poplartree,xmlfile);
  }
  return 0;
}




