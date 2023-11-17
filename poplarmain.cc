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
#include <PoplarConstants.h>
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
  cout << "Usage: ./poplar -iter <years>  -xml <file.xml> -toFile <datafile.txt> -writeInterval <number>" <<endl; 
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
  int structure_update = 0;
  //account for the foliage growth (used in the root growth)
  double foliage_growth = 0.0;
  const ParametricCurve radiation_index("radiationindex.fun");
  //Collect foliage masses from each structure update
  double wf_su1,wf_su2,wf_su3,wf_su4;
  wf_su1 = wf_su2= wf_su3 = wf_su4 = 0.0;
//   debug_file << left << setfill(' ') << " "
//              << setw(12) << " X " << setw(12) << " Y " << setw(12) << " Z "
//              << setw(12) << " Qin " << setw(12) << " Qabs " 
// 	     << setw(12) << " T " 
//              << setw(12) << " Vcmax " << setw(12)  << " Jmax " 
// 	     << setw(12) << " J " 
//              << setw(12) << " Oi " << setw(12) << " Ci " << setw(12) << " Wc " 
// 	     << setw(14) << " Wj " << setw(14) << " Al-Rd " << setw(12) 
// 	     << " Rd " << setw(12) << " Al " << setw(12) << " P " << endl;

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
	     << setw(12) << "Dbase"
	     << setw(12) << "D1.3"
	     << setw(12) << "Wf 1"
	     << setw(12) << "Wf 2"
	     << setw(12) << "Wf 3"
	     << setw(12) << "Wf 4"
	     << setw(12) << "Wf"
	     << setw(12) << "WsTot"
	     << setw(12) << "WsStem"
	     << setw(12) << "WsBranch" 
	     << setw(12) << "Wr"
	     << setw(12) << "P"
	     << setw(12) << "M"
	     << setw(12) << "R:S"
	     << setw(12) << "WoodTot"
	     << endl;
  }
    
  
  poplar::LSystem<poplarsegment,poplarbud,PoplarBD, PoplarBudData> poplarL;
  Erythrina::LSystem<poplarsegment,poplarbud,LGMAD,LGMdouble> rootL;
 
  //Create the tree.
  Tree<poplarsegment,poplarbud> poplartree(Point(5.0, 5.0, 0),
					   PositionVector(0,0,1.0));

  //initialization of parameters and functions
  InitializeTree<poplarsegment, poplarbud> init_poplar(metafile, VERBOSE);
  init_poplar.initialize(poplartree);

  // SetValue(poplartree,TreeRefRadiation,2480.0);

  Firmament& f = GetFirmament(poplartree);
  f.resize(INCLINATION,AZIMUTH,1200); //resize:  inclinations,  azimuths,  1200 MJ/year for previous tree,  

  //create voxel space 
  VoxelSpace vs(Point(0,0,0), Point(50, 50, 18), 1, 1, 1, 50, 50, 18,  GetFirmament(poplartree));


  //Start by evaluating the axiom (see start in sym2d.L)
 
  poplarL.start();
  //cout << "Start" <<endl;
  //cout << "RootStart" <<endl;
  poplarL.lstringToLignum(poplartree, 1, PoplarD);

  //First leaves
  vector<PositionVector> pv;
  cout << "CREATE LEAVES " <<endl;
  ForEach(poplartree,DisplaySegmentData<poplarsegment,poplarbud,Triangle>());
  //DisplayStructure(poplartree);
  AccumulateDown(poplartree,pv,
		 AppendSequence<vector<PositionVector> >(),
		 CreatePoplarLeaves(PETIOLE_LENGTH,LEAF_BASE,LEAF_HEIGHT)); 
  cout << "CREATE LEAVES " <<endl;
//petiolLength, base and heighth
  double wf_init=0.0;
  //Initial root mass
  wf_init = Accumulate(poplartree,wf_init,CollectFoliageMass<poplarsegment,poplarbud>());
  SetValue(poplartree,TreeWr,GetValue(poplartree,LGPar)*wf_init);
   
  FILE * fFile;
  float a, b, c, d, e, ff, g, h;
  float direct=0, diffuse=-1, structureFlag=-1;
  char * filename[12]={"jan.dat", "feb.dat", "mar.dat", "apr.dat", 
		       "may.dat", "jun.dat", "jul.dat", "aug.dat", 
		       "sep.dat", "oct.dat", "nov.dat", "dec.dat" };

  int derivation=iter;
  
  for (int age=0; age<derivation; age++) // poplarL.derivationLength()--yearly
    {   
      //debug_file << "Tree age " << GetValue(poplartree,LGAage) <<endl; 
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
	  cout << "Tree photosynthesis begin" <<endl;
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
	      f.resize(INCLINATION,AZIMUTH,diffuse); 
	      last_diffuse = diffuse;
	      f.setSunPosition(a); 
	      f.setDirectRadiation(direct);
	      //cout << "Calculate Light begin" <<endl;
	      vs.calculatePoplarLight((LGMdouble)(diffuse), (LGMdouble)structureFlag); 
	      //cout << "Calculate Light end" <<endl;
	      //Set qabs and calculate radiation index
	      SetPoplarQabs<poplarsegment,poplarbud,Triangle>(vs,poplartree,radiation_index); 
	      // cout<<" setHwTree."<<endl;
	      LGMdouble maxQin = 0.0;
	      maxQin = Accumulate(poplartree, maxQin, GetQinMax<poplarsegment,poplarbud>() );
	      SetValue(poplartree, TreeQinMax, maxQin);
	      //  cout << "  TreeQinMax: " << maxQin << "  MJ/m2" << endl;

	      LGMdouble treeQabs = 0.0;
	      treeQabs = Accumulate(poplartree,treeQabs,
				    CollectQabs<poplarsegment,poplarbud>());
	      LGMdouble treeLA = 0.0;
	      treeLA = Accumulate(poplartree,treeLA,
				  CollectFoliageArea<poplarsegment, poplarbud>());
	      // cout << " Tree leaf area: " << treeLA << "  m2,  Qabs: " << treeQabs << "  MJ,  Qabs/(Qin*LA): " << treeQabs/(treeLA*GetFirmament(poplartree).diffuseBallSensor()) << endl;
    
  
	      // ForEach(poplartree, DoPhotosynthesis()); 
	      double treeWf0 = 0.0;
	      treeWf0 = Accumulate(poplartree,treeWf0,
				  CollectFoliageMass<poplarsegment,poplarbud>());
	      poplartree.photosynthesis();
	      double treeWf1 = 0.0;
	      treeWf1 = Accumulate(poplartree,treeWf1,
				   CollectFoliageMass<poplarsegment,poplarbud>());
	      //account for the foliage growth, note that if leaf have
	      //reached their max size,  the growth is practically zero
	      //(and due to floating point arithmetics it may be even negative
	      //if (treeWf1-treeWf0 > R_EPSILON){
	      //foliage_growth = foliage_growth + (treeWf1-treeWf0);
	      //}
	      
	      tree_photosynthesis += GetValue(poplartree,TreeP);
	      // cout << "Photosynthesis in 30 minutes:  " << GetValue(poplartree,TreeP) << endl;
	      structureFlag=1;
	    }//for (int i=0; i < 6*7*24*2; i++)
	  cout << "TreePhotosynthesis:  " << tree_photosynthesis<<endl;


	  ForEach(poplartree,SetMeanRadiationIndex<poplarsegment,poplarbud,Triangle>());

	  ForEach(poplartree, DoRespiration()); //poplartree.respiration(); //

	  ForEach(poplartree,SubAging<poplarsegment,poplarbud>()); 
	  //DisplayStructure(poplartree);
	  //One derivation of L-string, above ground trunk and tree crown
	  poplarL.derive();
	  //below ground roots
	  cout << "expand done " << endl;
	  //Update tree so that structures match 
	  poplarL.lstringToLignum(poplartree,1, PoplarD);
	  cout << "lstringToLignum done " << endl;
	  //DisplayStructure(poplartree);
	  TreePhysiologyVigourIndex(poplartree);
	  // cout << "Vigour index" << endl;
     
	  LGMdouble p = 0.0, m = 0.0;
	  LGMdouble P = tree_photosynthesis;
	  LGMdouble M = Accumulate(poplartree,m, SumTreeRespiration<poplarsegment, poplarbud>())
	    + GetValue(poplartree,LGPmr)* GetValue(poplartree,TreeWr)/NUMBER_OF_STRUCTURE_UPDATES;  
	  SetValue(poplartree,TreeM,M);  //should be M
	  SetValue(poplartree,TreeP,P);
	  cout<<"P: "<<P<<" M: "<<M<<endl;
	  
	  //The leaves remain 4 (from 0 to 3)  structure updates  
	  structure_update++;
	  //Collect foliage that has photosynthesised
	  double wf_su= 0.0;
	  Accumulate(poplartree,wf_su,CollectFoliageMass<poplarsegment, poplarbud>());
	  switch (structure_update){
	  case 1: 
	    wf_su1 =  wf_su;break;
	  case 2:
	    wf_su2 =  wf_su;break;
	  case 3:
	    wf_su3 =  wf_su;break;
	  case 4:
	    wf_su4 =  wf_su;break;
	  }
	  //This structure update at year N makes the last elongation.
	  //The leaves created will photosynthesize the following year
	  //N+1
	  if(structure_update==4)
	    {
	      cout << "Drop leaves " <<endl;
	      ForEach(poplartree, DropAllLeaves<poplarsegment, poplarbud,Triangle>());
	      double Wf= 0.0;
	      Accumulate(poplartree,Wf,CollectFoliageMass<poplarsegment, poplarbud>());
	      cout << "Wf " << Wf << " (should 0)" << endl;
	    }
	  //DisplayStructure(poplartree);
	  //Compentate root_senescence and take into account foliage growth
	  bool verbose = true;
	  PoplarGrowthAllocatorPropagateUp<poplarsegment, poplarbud,
	    SetSegmentLength, TryDiameterGrowth, double> G(poplartree, 0.0,
							   root_senescence,foliage_growth,verbose);
	  //Reset the leaf growth from the short time step. (We are not using it. leaves are born full sized)
	  foliage_growth = 0.0;
	  G.init();
	  cout << "G.init finished." << endl;
	  cout << "Bisection zero at:  " << Bisection(0.0, 10.0, G, GetValue(poplartree,LGPzbrentEpsilon)) << endl; 
	  //GetValue(poplartree,LGPzbrentEpsilon)=0.001
	  cout << "bisection finished." << endl;
	  poplarL.lignumToLstring(poplartree,1, PoplarD);  
	  cout << "lignumToLstring done " << endl; 
	  poplarL.derive();
	  cout << "Split done " << endl;
	  poplarL.lstringToLignum(poplartree,1, PoplarD);
	  pair<double, double> r0Qin(0.0, 0.0);
	  //   double r0Qin = 0.0;
	  PropagateUp(poplartree,r0Qin,ForwardR0Qin());
	  //DisplayStructure(poplartree);

	  //ForEach(poplartree,DisplaySegmentData<poplarsegment,poplarbud,Triangle>());
	  // cout << "lstringToLignum done " << endl;
	  //Creat leaves 
	  pv.clear();
	  AccumulateDown(poplartree,pv,
			 AppendSequence<vector<PositionVector> >(),
			 CreatePoplarLeaves(PETIOLE_LENGTH,LEAF_BASE,
					    LEAF_HEIGHT));   
	  TcData data;     
	  AccumulateDown(poplartree,data,
			 TreeDiameterGrowth<poplarsegment, poplarbud>());
	  //ForEach(poplartree,DisplaySegmentData<poplarsegment,poplarbud,Triangle>());
	  //Create roots accoriding to allocation
	  SetValue(poplartree, TreeWr, 
		   GetValue(poplartree,TreeWr)+G.getRootRequirement());

	  double Wfall= 0.0;
	  Accumulate(poplartree,Wfall,CollectFoliageMass<poplarsegment, poplarbud>());
	  cout << "Wfall " << Wfall<< endl;
 
          //Tree pruning
	  double length=0.0;
	  PropagateUp(poplartree, length, KillPoplarBuds<poplarsegment, poplarbud>());
	  poplarL.lignumToLstring(poplartree,1,PoplarD);  
	  poplarL.lstringToLignum(poplartree,1,PoplarD);
	  poplarL.prune(poplartree);
	  //This is the fourth structure update, maximum number of leaves in the tree
	  if (structure_update == 3 && !xmlfile.empty()){
	    if (interval && static_cast<int>(GetValue(poplartree,LGAage)) % interval == 0){
	      ostringstream xml_interval;
	      xml_interval << GetValue(poplartree,LGAage) << "-4th-structure-update-" << xmlfile;
	      XMLDomTreeWriter<poplarsegment,poplarbud,Triangle> writer;
	      cout << "Saving tree to "<< xml_interval.str() << " begin" <<endl; 
	      writer.writeTreeToXML(poplartree,xml_interval.str());
	      cout << "End" <<endl;
	    }
	  }
	  cout << "Structure update " << structure_update << endl;

	}
      structure_update = 0;
      fclose(fFile);
      if (age==derivation-1)
	cout<<"root mass age of "<<derivation<<": "<<GetValue(poplartree,TreeWr)<<endl;
      ForEach(poplartree,TreeAging<poplarsegment,poplarbud>());  
      //Root mortality for the allocation in the medium time step
      root_senescence = GetValue(poplartree,LGPsr)*GetValue(poplartree,TreeWr);
      SetValue(poplartree,TreeWr, 
	       GetValue(poplartree,TreeWr)-root_senescence);
     
      ForEach(poplartree, WakeupPoplarBuds<poplarsegment, poplarbud>());
      poplarL.lignumToLstring(poplartree,1,PoplarD);  
      poplarL.lstringToLignum(poplartree,1,PoplarD);  

      //Collect data for output file
      int age = static_cast<int>(GetValue(poplartree,LGAage));
      double h   = GetValue(poplartree,LGAH);
      double dbase = GetValue(poplartree,LGADbase);
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
                 << setw(12) << dbase
		 << setw(12) << d13
		 << setw(12) << wf_su1
		 << setw(12) << wf_su2
		 << setw(12) << wf_su3
		 << setw(12) << wf_su4 
		 << setw(12) << wf
		 << setw(12) << ws
		 << setw(12) << ws_stem
		 << setw(12) << ws_branch
		 << setw(12) << wr
		 << setw(12) << p
		 << setw(12) << m 
		 << setw(12) << wr/ws
		 << setw(12) << ws+wr
		 << endl;
      }
      wf_su1 = wf_su2 = wf_su3 = wf_su4 = 0.0;
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
  PrintTreeInformation<poplarsegment, poplarbud, ostream> printPoplar;
  printPoplar(poplartree);    //print out tree information such as tree height, dbh

  if (xmlfile.length() > 0){
    XMLDomTreeWriter<poplarsegment,poplarbud,Triangle> writer;
    writer.writeTreeToXML(poplartree,xmlfile);
  }
  return 0; 
}




