#include <poplar.h>
#include <poplarmetabolism.h>

// declared in poplar.h poplarsegment class.

class LeafResize
{
 public:
  LeafResize(double la){leafArea=la;}
  void LeafResize :: operator()(BroadLeaf<Triangle>* b)  
  {
     SetValue(*b, LGAA, leafArea); 
  }
  double leafArea;
};


TcData& poplarsegment::diameterGrowth(TcData& data)
{
  //New segment (age == 0) is iteratively set. 
  if (GetValue(*this, SUBAGE) > 0.0){
    const ParametricCurve& fm = GetFunction(GetTree(*this),LGMFM);
    LGMdouble Asu = GetValue(data,LGAAs); //sapwood area from above
    LGMdouble Ahown  = GetValue(*this,LGAAh);//own heartwood
    //Sapwood  requirement  of  remaining  foliage,  assume  fm  returns
    //proportion initial  foliage present, declining function  from 1 to
    //0.
    LGMdouble Asr = fm(GetValue(*this,LGAage))*GetValue(*this,LGAAs0);
    // cout<<GetValue(*this,LGAage)<<": the value of age and As0:"<<GetValue(*this,LGAAs0)<<endl; 
    //**cout<<"the value of Asr:"<<Asr<<endl;
    //possible new radius
    LGMdouble Rnew = sqrt((Asu + Ahown + Asr)/PI_VALUE);
    //compare Rnew to R, choose max
    Rnew = max(Rnew, GetValue(*this,LGAR));
    //New wood radius
    //**cout<<Rnew<<": the value of new radius"<<endl;
    SetValue(*this,LGAR, Rnew);
  } 
  //Pass down sapwood area requirement
  SetValue(data,LGAAs,GetValue(*this,LGAAs)); 

  
   LGMdouble As=GetValue(*this, LGAAs);
   LGMdouble Af=As*20*10;
    list<BroadLeaf<Triangle> *> leaves=GetLeafList(*this);
    int nLeaves = leaves.size();
    double la;
    if(nLeaves>=1 && Af>0)
    {  la= min(Af/(double)(nLeaves), 0.005);
    //cout<<"number of leaves: "<<nLeaves<<" leafArea: "<<la<<endl;
       LeafResize f(la);
       for_each(leaves.begin(), leaves.end(), f); 
    }
  return data;
}


int PoplarLeaf::photosynthesis()
{
  // cout << "poplarleaf photosynthesis "<< endl;

    LGMdouble T = 25; //temperature of leaf.l
    double Ca=360, Kc=460, Ko=330;
    double Ci=0.7 * Ca * ((1.674-0.061294*T+0.0011688*pow(T,2)-0.0000088741*pow(T,3))/0.73547);
    double Oi=210*((0.047-0.0013087*T+0.000025603*pow(T, 2)-0.00000021441*pow(T,3))/0.026934);
    double Vcmax=57.15;
    double Vomax=0.21*Vcmax;
    double Wc=(Vcmax*Ci)/(Ci+Kc*(1+Oi/Ko));
    double G = (0.5*Vomax*Kc*Oi)/(Vcmax*Ko);

    double Jmax=105;
    double Q=GetValue((*this), LGAQabs);  //(*this).bla.Q_in;  //Qabs-absorbed radiation
      double a = 0.0551;
       double J =a* Q *pow((1+pow(a, 2)*pow(Q,2)/pow(Jmax, 2)), 0.5);
       double Wj = (J*Ci)/(4.5*Ci+10.5*G);

  KGC Rd=2.21;
  KGC Photo =(KGC)((1-G/Ci) * min(Wc,Wj));        //(umole/m2/s)
  // cout<<"Q: "<<Q<<" <J: "<<J<<endl;
  //Emole = 2.176 *100000 joule/mole; umole = 0.2176 J 
  //  KGC A=Photo*0.01;          //0.01KG/MJ?? p0=0.001    
  // KGC A=Photo-Rd;//  Rd is (umolm-2s-1), so all photosynthesis have to multifilied by leaf area (0.01m-2) and time.

  //  KGC A=Photo*0.000001*30*60*0.5 *44 *0.001; //3 (umole/m2/s)* 0.000001Mole *30*60(s) * 0.1m2(should be all leaves in one new branch??no, only one leaf area) * 44 *0.001Kg
   
  KGC A=Photo * 30 *60 * 0.000001 *12 * 0.001;// * GetValue(*this, LGAA); //(umole/m2/s) * time * 0.000001mole * Carbon(12) *0.001Kg: LeafArea(* GetValue(*this, LGAA)) is not included here any more because it is already timed in VoxelSpaceI.h for Qabs.
  // cout<<"leaf area: "<<GetValue(*this, LGAA)<<"Photo: "<<Photo<<endl;
       SetValue(*this, LGAP, A);     //(*this).bla.P=A;

      
  //** cout <<"print the photosynthesis of segment: "<<GetValue(*this, LGAP)<<endl; 
  
  return 1;
}

void PoplarLeafPhotosynthesis::operator()(BroadLeaf<Triangle>* b)
{
  //cout<<"   Hello, I am photosynthesis in leaf"<<endl;
  //You can do it this way: first do your computations (c.f. above) and simply
  //set  the  value:  SetValue(*b,P,RESULT);  Or call  the  method  if
  //interface (argument type) is fine
  ((PoplarLeaf*)b)->photosynthesis();
  //**  b->photosynthesis(1);
  
}

void PoplarLeafRespiration::operator()(BroadLeaf<Triangle>* bl)
{ 
  //** cout<<"   I am respiration in leaf"<<endl;
  // Tree<poplarsegment, poplarbud>& t = dynamic_cast<Tree<poplarsegment, poplarbud>&>(GetTree(*this));
  SetValue(*bl, LGAM, 0.25 *GetValue(*bl, LGAWf));
  // SetValue(*bl, LGAM, 0.0); //0.25 is growth respiration for poplar
  // cout<<"LGPmf: "<<GetValue(t, LGPmf)<<endl;
}

void poplarsegment::photosynthesis()
{
  // LGMdouble p0=1000;
  LGMdouble T=25;
  //cout<<"Hello, I am photosynthesis for pop-seg"<<endl;

  //   list<BroadLeaf<Triangle>*> leaves = GetLeafList(*this);
  list<BroadLeaf<Triangle> *> leaves = GetLeafList(*this);

  //Use functor to traverse leaf list instead of do-while loops
  for_each(leaves.begin(), leaves.end(), PoplarLeafPhotosynthesis());
  
}

void poplarsegment::respiration()
{
  LGMdouble m_hw = 0.0;
  LGMdouble init = 0.0;

  Tree<poplarsegment, poplarbud>& t = dynamic_cast<Tree<poplarsegment, poplarbud>&>(GetTree(*this));
  //cout<<"    I am respiration in segment"<<endl;
  list<BroadLeaf<Triangle>*> leaves=GetLeafList(*this);
  //leaf respiration
  for_each(leaves.begin(), leaves.end(),PoplarLeafRespiration());
  m_hw += accumulate(leaves.begin(), leaves.end(), init, CollectLeafRespiration());
  //segment respiration
  //*SetValue(*this,LGAM,1.0);
  //**ms-- maintenance respiration rate of sapwood
  //**ws--  mass of sapwood
  //cout<<"LGPms and LGAWs:"<<GetValue(t,LGPms)<<", "<<GetValue(*this,LGAWs)<<endl;
  m_hw += GetValue(t,LGPms)*GetValue(*this,LGAWs);
  SetValue(*this,LGAM, m_hw/4.0);  
}

vector<PositionVector>& 
CreatePoplarLeaves::operator()(vector<PositionVector>& pdv,
			       TreeCompartment<poplarsegment, poplarbud>* tc)const
{ 
  
  if (poplarbud* b = dynamic_cast<poplarbud*>(tc)){ 
    if (GetValue(*b,LGAstatus)>0.0){    // == 1	     
      pdv.push_back(GetDirection(*b));
      SetValue(*b,LGAstatus,0.0); //leaf created, no more leaves for
      //this bud
    }
  }
  if (poplarsegment* ts = dynamic_cast<poplarsegment*>(tc)){
    if(GetValue(*ts, LGAage) == 0.0){
      Point origo(0,0,0);
      Point point = GetEndPoint(*ts);
      PositionVector up(0,0,1);
      PositionVector down(0,0,-1);
	
      static Uniform u; //uniform random number [0,1] for setting leaf
      //normals;  static makes it  common throughout
      //the  program and  not reinitialized  in each
      //call.
      int seed = 3267;
	
      if (GetValue(*ts, LGAL)==0.0)
	pdv.clear();
      for (unsigned int i = 0; i <pdv.size(); i++){
	PositionVector pdir = pdv[i];
	//Leaves are  created at the end  of the segment  where the buds
	//are, second argument is the intial length of the petiole
	Petiole petiole(point,point + pl*(Point)pdir);
	//Randomize  the leaf blade  normal by  rotating in  around axis
	//that lies in the horizontal plane defined by cross product of
	//petiole direction and up-vector. Also it is direction towards  
	//right corner of the triangle
	if (Cross(pdir,up).length() < R_EPSILON){
	  cout << "Petiole Up --> Cross(pdir,up) == 0 ---> No leaf here" <<endl;
	  cout << GetPoint(*ts) << endl;
	  pdv.clear();
	  return pdv;
	}
	PositionVector axis1 = Cross(pdir,up).normalize();
	//limit the rotation  of the leaf normal to  [-90,90] degrees so
	//that the leaf normal does not point downwards
	double ran = (-90.0 +180.0*u(seed))*2.0*PI_VALUE/360.0; //(radians)
	PositionVector leaf_normal(0,0,1);
	leaf_normal.rotate(origo,axis1,ran);
	//We need also the left corner of the triangle. Create a vector
	//towards it.
	PositionVector axis2 = Cross(pdir,down).normalize();
	//We yet need the direction towards the apex of the triangle
	//to set the apex point
	PositionVector axis3 = Cross(leaf_normal,axis1).normalize();
	//I hope I got the cross  products right, but we will see in
	//the visualization how the leaves settle themselves

	Point right = point + base*0.5*(Point)axis1;
	Point left  = point + base*0.5*(Point)axis2;
	Point apex  = point + height*(Point)axis3;
	Triangle shape(left,right,apex);
	BroadLeaf<Triangle>* leaf = new BroadLeaf<Triangle>(shape,petiole,leaf_normal);

	SetValue(*leaf, LGAdof, 0.6); //GetValue(GetTree(*tc), LGPdof)); // cout<<"LGAdof: "<<GetValue(*leaf, LGAdof)<<endl;
	SetValue(*leaf, LGAtauL, GetValue(GetTree(*tc), LGPtauL));
	SetValue(*leaf, LGAsf, GetValue(GetTree(*tc), LGPsf));
  
	double Af = 0.1 * 0.01; //GetValue(GetTree(*ts), LGPaleafmax);
	//  cout<<"LGPaleafmax value: "<<GetValue(GetTree(*ts), LGPaleafmax)<<endl;
	SetValue(*leaf, LGAA, Af); // 0.02);   //set the leaf area value, which is used in DumpLeaf()
	//cout<<"Insert leaf"<<endl;
	InsertLeaf(*ts,leaf);
	// Point p = GetCenterPoint(*leaf);
	// cout<<p<<endl;
      }
    }
    //clear the vector; don't create leaves twice
    pdv.clear();
  }
  return pdv;
}
