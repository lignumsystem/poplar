#include <algorithm>
#include <iostream>
#include <sstream>
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
#include <PoplarGrowthAllocator.h>
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


fstream debug_file("PoplarPhotosynthesis.txt",ios_base::out);

void Usage()
{
  cout << "Usage: ./poplar -iter <iter>  -xml <file> -toFile <datafile>" <<endl; 
  exit(0);
}

int main(int argc, char** argv)
{
  string iterations;
  int iter=0;
  string metafile = "MetaFile.txt";
  string xmlfile;//tree outputfile
  string datafilename;//Data ouput file
  string writeinterval;//write interval command line argument
  int interval=0;//write interval to xml file
  //Root senescence at medium time step (structure update)
  double root_senescence=0.0;
  Lex l;
 
  debug_file << left << setfill(' ') << " "
             << setw(12) << " X " << setw(12) << " Y " << setw(12) << " Z "
             << setw(12) << " Qin " << setw(12) << " Qabs " 
	     << setw(12) << " T " 
             << setw(12) << " Vcmax " << setw(12)  << " Jmax " 
	     << setw(12) << " J " 
             << setw(12) << " Oi " << setw(12) << " Ci " << setw(12) << " Wc " 
	     << setw(14) << " Wj " << setw(14) << " Al-Rd " << setw(12) 
	     << " Rd " << setw(12) << " Al " << setw(12) << " P " << endl;

  //Iterations
  if (ParseCommandLine(argc,argv,"-iter",iterations)){
    iter = atoi(iterations.c_str());
  }
  else{
    Usage();
  }
  //Save the simulated poplar to xmlfile
  ParseCommandLine(argc,argv,"-xml",xmlfile);
  //Data file
  ParseCommandLine(argc,argv,"-toFile",datafilename);
  //Write interval
  ParseCommandLine(argc,argv,"-writeInterval",writeinterval);
  if (!writeinterval.empty())
    interval = atoi(writeinterval.c_str());
  fstream datafile;
  if (!datafilename.empty()){
    datafile.setf(ios_base::fixed,ios_base::floatfield);
    datafile.open(datafilename.c_str(), ios_base::out);
    if (!datafile){
      cout << "Could not open " << datafile <<endl;
      exit(0);
    }
    datafile << left << setw(6) << setfill(' ') << "Age"
		 << setw(12) << "H"
		 << setw(12) << "D1.3"
		 << setw(12) << "Wf"
		 << setw(12) << "WsTot"
		 << setw(12) << "WsStem"
		 << setw(12) << "WsBranch" 
		 << setw(12) << "Wr"
		 << setw(12) << "P"
		 << setw(12) << "M"
		 << endl;
  }
    
  
  poplar::LSystem<poplarsegment,poplarbud,PoplarBD, PoplarBudData> poplarL;
  Erythrina::LSystem<poplarsegment,poplarbud,LGMAD,LGMdouble> rootL;
 
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


  //Start by evaluating the axiom (see start in sym2d.L)
 
  poplarL.start();
  //cout << "Start" <<endl;
  rootL.start();
  //cout << "RootStart" <<endl;
  poplarL.lstringToLignum(poplartree, 1, PoplarD);

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

  int derivation=iter;
  
  for (int age=0; age<derivation; age++) // poplarL.derivationLength()--yearly
    {   
      debug_file << "Tree age " << GetValue(poplartree,LGAage) <<endl; 
      day1=0; day2=0;
      cout << "age: " << age << endl;  
      fFile = fopen("weatherdata.dat", "r"); // fFile = fopen(filename[month], "r");
      if (fFile==NULL)
        exit(1);   

      while (!feof(fFile))
        {  diffuse=-1, structureFlag=-1;
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
	  string name("VSDump.txt"); string sep(" ");
	  vs.writeVoxelBoxesToGnuPlotFile("VSDump.txt"," ");
	  LGMdouble tree_photosynthesis =0; 
	  LGMdouble tree_respiration = 0;
	  LGMdouble last_diffuse=0;
	  //Initialize to zero, read diffuse from weather data file.
	  f.setDiffuseRadiation(0);
	  //int day=0;
	  for (int i=0; i<6*7*24*2; i++)
	    { 
	      direct=0;
	      diffuse=0;
	      if(!feof(fFile))
		{  //day, time, elevation, azimuth, direct, diffuse, Ta(temperature), VPD(pressure)
		  fscanf(fFile, "%f %f %f %f %f %f %f %f\n", &a, &b, &c, &d, &ff, &e, &g, &h);
		  direct =ff;
		  diffuse =e;
		  day2=a;
		  float time = b;
		  //Correct the error in the weather data file. In the
		  //file the  sun azimuth increases up  until the noon
		  //12 o'clock when the  azimuth is PI. But after that
		  //the azimuth decreases, i.e. the sun goes backwards
		  //in the  sky! So to  make the sun circle  the right
		  //way increase the azimuth value after the mid day.
		  if (time > 12.0)
		    d = PI_VALUE + (PI_VALUE - d);
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

	      //The diffuse radiation should be used in the light model (calculatePoplarLight).
	      f.resize(40,20,diffuse); 
	      last_diffuse = diffuse;
	      f.setSunPosition(a); 
	      f.setDirectRadiation(direct);
	      vs.calculatePoplarLight((LGMdouble)(diffuse), (LGMdouble)structureFlag); 
	
	      SetPoplarQabs<poplarsegment,poplarbud,Triangle>(vs,poplartree); 
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
	    }//for (int i=0; i < 6*7*24*2; i++)
	  cout << "TreePhotosynthesis:  " << tree_photosynthesis<<endl;
	  //Why do we set the diffuse datiation here 
	  //f.setDiffuseRadiation(last_diffuse);
 
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
    
	  TreePhysiologyVigourIndex(poplartree);
	  // cout << "Vigour index" << endl;
     
	  LGMdouble p = 0.0, m = 0.0;
	  LGMdouble P = tree_photosynthesis;
	  LGMdouble M = Accumulate(poplartree,m, SumTreeRespiration<poplarsegment, poplarbud>())+ GetValue(poplartree,LGPmr)* GetValue(poplartree,TreeWr);  //0.1 * GetValue(poplartree,TreeWr) * 0.15;   // GetValue(poplartree,LGPmr)* GetValue(poplartree,TreeWr);   
	  //if (M>P) P=M+0.001; //WHY THIS????
	  SetValue(poplartree,TreeM,M);  //should be M
	  SetValue(poplartree,TreeP,P);
	  cout<<"P: "<<P<<" M: "<<M<<endl;
	  PoplarGrowthAllocatorPropagateUp<poplarsegment, poplarbud,
	    SetSegmentLength, TryDiameterGrowth, double> G(poplartree, 0.0,root_senescence);
   
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


	}
      fclose(fFile);
      if (age==derivation-1)
	cout<<"root mass age of "<<derivation<<": "<<GetValue(poplartree,TreeWr)<<endl;
      //sapwood senescence
      ForEach(poplartree,TreeAging<poplarsegment,poplarbud>());   //use this if using subage
      //Root mortality
      root_senescence = GetValue(poplartree,LGPsr)/4 *  GetValue(poplartree,TreeWr);
      SetValue(poplartree,TreeWr, 
	       GetValue(poplartree,TreeWr)-GetValue(poplartree,LGPsr)/4 *
	       GetValue(poplartree,TreeWr));
     
      ForEach(poplartree, WakeupPoplarBuds<poplarsegment, poplarbud>());
      poplarL.lignumToLstring(poplartree,1,PoplarD);  
      poplarL.lstringToLignum(poplartree,1,PoplarD);  
      drop_leaf_flag=1;
      int age = static_cast<int>(GetValue(poplartree,LGAage));
      double h   = GetValue(poplartree,LGAH);
      double d13 = GetValue(poplartree,LGADbh);
      double wf = 0.0;
      wf = Accumulate(poplartree,wf,CollectFoliageMass<poplarsegment,poplarbud>());
      double ws = 0.0;
      ws = Accumulate(poplartree,ws,CollectWoodMass<poplarsegment,poplarbud>());
      double ws_stem = 0.0;
      ws_stem =  Accumulate(poplartree,ws_stem,CollectStemWoodMass<poplarsegment,poplarbud>());
      double ws_branch = ws - ws_stem;
      double wr = GetValue(poplartree,TreeWr);
      double p = GetValue(poplartree,TreeP);
      double m = GetValue(poplartree,TreeM);
      if (datafile){
	datafile << left << setw(6) << setfill(' ') << age
		 << setw(12) << h
		 << setw(12) << d13
		 << setw(12) << wf
		 << setw(12) << ws
		 << setw(12) << ws_stem
		 << setw(12) << ws_branch
		 << setw(12) << wr
		 << setw(12) << p
		 << setw(12) << m 
		 << endl;
      }
      if (interval && !xmlfile.empty()){
	if (static_cast<int>(GetValue(poplartree,LGAage)) % interval == 0){
	  ostringstream xml_interval;
	  xml_interval << GetValue(poplartree,LGAage) << "-" << xmlfile;
	  XMLDomTreeWriter<poplarsegment,poplarbud,Triangle> writer;
	  cout << "Saving tree to "<< xml_interval.str() << " begin" <<endl; 
	  writer.writeTreeToXML(poplartree,xml_interval.str());
	  cout << "End" <<endl;
	}
      }
    }
  


  //Some optional clean up see End in sym2d.L
  poplarL.end();  
  rootL.end();
  PrintTreeInformation<poplarsegment, poplarbud, ostream> printPoplar;
  printPoplar(poplartree);    //print out tree information such as tree height, dbh

  if (xmlfile.length() > 0){
    XMLDomTreeWriter<poplarsegment,poplarbud,Triangle> writer;
    writer.writeTreeToXML(poplartree,xmlfile);
  }
  return 0;  

  // ForEach(poplartree, DropAllLeaves<poplarsegment, poplarbud,Triangle>());

  
  //new version of visualization
  /*
    LGMVisualization viz;
    viz.InitVisualization(argc,argv);
    //viz.OrderFoliage(true);
    viz.AddHwTree<poplarsegment,poplarbud, Triangle>(poplartree,string("koivu.bmp"), string("lehti.tga"));
							 
    viz.SetMode(SOLID);
    viz.StartVisualization();
  */

}




