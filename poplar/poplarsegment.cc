#include <poplar.h>
#include <poplarstand.h>
#include <poplarmetabolism.h>

// declared in poplar.h poplarsegment class.

class LeafResize
{
public:
  LeafResize(double la){leafArea=la;}
  LeafResize(){}
  void operator()(BroadLeaf<Triangle>* b)  
  {  leafArea=min((GetValue(*b, LGAA)+0.0000055), 0.007); //+0.00002; 0.001
    // cout<<"leafarea: "<<leafArea<<endl;
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

  /*   
       LGMdouble As=GetValue(*this, LGAAs);
       LGMdouble Af=As*20*10;
       list<BroadLeaf<Triangle> *> leaves=GetLeafList(*this);
       int nLeaves = leaves.size();
       double la;
       if(nLeaves>=1 && Af>0)
       {  la= min(Af/(double)(nLeaves), 0.008); // min(Af/(double)(nLeaves), 0.05);
       // cout<<"number of leaves: "<<nLeaves<<" leafArea: "<<la<<endl;
       LeafResize f(la);
       for_each(leaves.begin(), leaves.end(), f); 
       }
  */
  return data;
}


int PoplarLeaf::photosynthesis()
{
  //cout << "poplarleaf photosynthesis "<< endl;

  double const T = temperature; //temperature of leaf.l
  double const Q = GetValue(*this,LGAQabs); //Absorbed radiation

  double const Ca =380.0;  //MS: Table 2 (350) 360.0
  double const Dj = 200.0e3;//MS: A3-10
  double const Jmax25 = 88.01; //(86.75);//MS: Table 2
  double const Kc = 460.0;//MS: Table 2
  double const Ko = 330.0;//MS: Table 2
  double const Oa = 210.0;//MS: Table 2
  double const Q10 = 1.78;//MS: A3-12
  double const Rd25 = 1.09; //(2.21); //MS: Table 2
  double const R = 8.314; //MS: A3-5
  double const Sj = 650.0; //MS: A3-10
  double const Vcmax25 = 42.12; //MS: Table 2 (30.83)

  //Implementing Appendix 3 in the manuscript
  double Ci = 0.7*Ca*((1.6740-6.1294e-2*T+1.1688e-3*pow(T,2.0)-8.8741e-6*pow(T,3.0))/0.73547);//MS: A3-2
  double Oi = Oa*((4.700e-2-1.3087e-3*T+2.5603e-5*pow(T,2.0)-2.1441e-7*pow(T,3.0))/2.6934e-2); //MS: A3-4
  double Vcmax = Vcmax25*exp((T-25.0)*68000.0/(R*298.0*(273.0+T))); //MS: A3-5
  double Wc = (Ci*Vcmax)/(Ci+Kc*(1.0+Oi/Ko)); //MS: A3-7
  double exp1 = exp(((T-25.0)*65330.0)/(298.0*R*(T+273.0)));
  double exp2 = exp((298.0*Sj-Dj)/(298.0*R));
  double exp3 = exp(((T+273.0)*Sj-Dj)/(R*(T+273.0)));
  double Jmax = Jmax25*exp1*((1.0+exp2)/(1.0+exp3));//MS: A3-10
  double J = (Jmax*Q)/(Q+2.1*Jmax); //MS: A3-9
  double Vomax = 0.21*Vcmax; //MS: A3-6
  double G = (0.5*Vomax*Kc*Oi)/(Vcmax*Ko);//MS: A3-3
  double Wj = J/(4.5+(10.5*G/Ci)); //MS: A3-8
  double Rd = Rd25*pow(Q10,(T-25.0)/10.0); //MS: A3-12
  double Vc = min(Wc,Wj); //MS: A3-11
  double AlGross = (1-G/Ci)*Vc;
  double Al = (1-G/Ci)*Vc-Rd; //MS: A3-1

  
  /*
  double Ci=0.7 * Ca * ((1.674-0.061294*T+0.0011688*pow(T,2.0)-0.0000088741*pow(T,3.0))/0.73547);
  //double Oi=210*((0.047-0.0013087*T+0.000025603*pow(T, 2.0)-0.00000021441*pow(T,3))/0.026934);
  double Oi=210*((0.047-0.0013087*T+0.000025603*pow(T, 2.0)-0.0000088741*pow(T,3))/0.026934);
  double kvc=exp((T-25)*68000/(8.314*298*(273+T)));
  double kjmax=exp(((T-25)*65330)/(298*8.314*(273+T)))*(1+exp((298*650-200000)/(298*8.314)))/(1+exp(((273+T)*650-200000)/(8.314*(273+T))));
  //double Vcmax=30.83 * kvc;    //30.83; 93 from Turnbull
  double Vcmax = 42.12*kvc;
  double Vomax=0.21*Vcmax;
  double Wc=(Vcmax*Ci)/(Ci+Kc*(1+Oi/Ko));
  double G = (0.5*Vomax*Kc*Oi)/(Vcmax*Ko);

  //double Jmax= 86.75 * kjmax;    //86.75; 117 from turnbull
  double Jmax = 88.01*kjmax;
  double Q=GetValue((*this), LGAQabs);  //(*this).bla.Q_in;  //Qabs-absorbed radiation
  double a = 0.0551;
  double J = Jmax *Q*0.23/(Q*0.23+2.1*Jmax);  //=a* Q *pow((1+pow(a, 2)*pow(Q,2)/pow(Jmax, 2)), 0.5);
  double Wj = (J*Ci)/(4.5*Ci+10.5*G);

  //KGC Rd=2.21*pow(1.78, (T-25)/10);  //Rd=2.21;
  double Rd = 1.09*pow(1.78, (T-25)/10.0); 
  double GrossPhoto =(KGC)((1-G/Ci) * min(Wc,Wj));        //(umole/m2/s)
  // cout<<"Q: "<<Q<<" <J: "<<J<<endl;
  //Emole = 2.176 *100000 joule/mole; umole = 0.2176 J 
  //  KGC A=Photo*0.01;          //0.01KG/MJ?? p0=0.001  
  // cout<<"Q: "<<Q<<" Photo: "<<Photo<<" temperature: "<<T<<" Wc: "<<Wc<<" Wj: "<<Wj<<" Ci: "<<Ci<<" Oi: "<<Oi<<" J: "<<J<<" Vomax: "<<Vomax<<" G: "<<G<<endl; 
 
  //  if (Photo>Rd)
  // cout<<"Photo: "<<Photo<<" Rd: "<<Rd<<endl; 
  double Photo = GrossPhoto-Rd;
  */
  //  else
  //   Photo = 0 ; 
  
  //  Rd is (umolm-2s-1), so all photosynthesis have to multifilied by leaf area (0.01m-2) and time.
  //  cout<<"Rd respiration: "<<2.21* 30 *60 * 0.000001 *12 * 0.001 * GetValue(*this, LGAA)<<endl;;
  //  KGC A=Photo*0.000001*30*60*0.5 *44 *0.001; //3 (umole/m2/s)* 0.000001Mole *30*60(s) * 0.1m2(should be all leaves in one new branch??no, only one leaf area) * 44 *0.001Kg
   
  //KGC A=Al * 30 *60 * 0.000001 * (12) * 0.001 * GetValue(*this, LGAA);// * GetValue(*this, LGAA); //(umole/m2/s) * time * 0.000001mole * Carbon(12) *0.001Kg: LeafArea(* GetValue(*this, LGAA)) is not included here any more because it is already timed in VoxelSpaceI.h for Qabs.
  //  cout<<"leaf area: "<<GetValue(*this, LGAA)<<"Photo: "<<Photo<<endl;

  KGC A = Al*30.0*60.0*1.0e-6*12.0*1.0e-3*GetValue(*this,LGAA);

  SetValue(*this, LGAP, A);     //(*this).bla.P=A;

  extern fstream debug_file;
  debug_file << left  << setfill(' ') 
             << setw(12) << GetShape(*this).getCenterPoint().getX() 
             << setw(12) << GetShape(*this).getCenterPoint().getY() 
             << setw(12) << GetShape(*this).getCenterPoint().getZ() 
             << setw(12) << Q << " " 
             << setw(12) << T
             << setw(12) << Vcmax
             << setw(12) << Jmax 
             << setw(12) << J 
	     << setw(12) << Oi
	     << setw(12) << Ci
             << setw(14) << Wc 
             << setw(14) << Wj
             << setw(12) << Al
             << setw(12) << Rd
             << setw(12) << AlGross <<endl;

      
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
  // cout<<"leaf mass: "<<GetValue(*bl, LGAWf)<<endl;
  // Tree<poplarsegment, poplarbud>& t = dynamic_cast<Tree<poplarsegment, poplarbud>&>(GetTree(*this));
  SetValue(*bl, LGAM, 0.2 *GetValue(*bl, LGAWf));
  // SetValue(*bl, LGAM, 0.0); //0.25 is growth respiration for poplar, 0.25 is too big, use 0.05
  // cout<<"LGPmf: "<<GetValue(t, LGPmf)<<endl;
}

void poplarsegment::photosynthesis()
{
  // LGMdouble p0=1000;
  LGMdouble T=25;
  //cout<<"Hello, I am photosynthesis for pop-seg"<<endl;

  //   list<BroadLeaf<Triangle>*> leaves = GetLeafList(*this);
  list<BroadLeaf<Triangle> *> leaves = GetLeafList(*this);
 
  // if (day2>day1)
  { // cout<<"day1: "<<day1<<" day2: "<<day2<<endl;
    LeafResize f;
    for_each(leaves.begin(), leaves.end(), f); 
    //  day1=day2;
  }
  //Use functor to traverse leaf list instead of do-while loops
  for_each(leaves.begin(), leaves.end(), PoplarLeafPhotosynthesis());
  
}

void poplarsegment::respiration()
{
  LGMdouble m_hw = 0.0;
  LGMdouble init = 0.0;

  Tree<poplarsegment, poplarbud>& t = dynamic_cast<Tree<poplarsegment, poplarbud>&>(GetTree(*this));
 
  list<BroadLeaf<Triangle>*> leaves=GetLeafList(*this);
  //leaf respiration
  for_each(leaves.begin(), leaves.end(),PoplarLeafRespiration());
  // m_hw = accumulate(leaves.begin(), leaves.end(), init, CollectLeafRespiration()); //leaf respiration is already included in photosynthesis.     cout<<"leaf respiration: "<<m_hw<<endl;
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
	/*if (Cross(pdir,up).length() < R_EPSILON){
	  cout << "Petiole Up --> Cross(pdir,up) == 0 ---> No leaf here" <<endl;
	  cout << GetPoint(*ts) << endl;
	  pdv.clear();
	  return pdv;
	  }*/

	PositionVector level(1,0,0);
        PositionVector axis1;
	PositionVector axis2;
        if (Cross(pdir,up).length() < R_EPSILON)
	  axis1 = Cross(level,up).normalize();
        else 
	  axis1 = Cross(pdir,up).normalize();
	//limit the rotation  of the leaf normal to  [-90,90] degrees so
	//that the leaf normal does not point downwards
	double ran = (-90.0 +180.0*u(seed))*2.0*PI_VALUE/360.0; //(radians)
	PositionVector leaf_normal(0,0,1);
	leaf_normal.rotate(origo,axis1,ran);
	//We need also the left corner of the triangle. Create a vector
	//towards it.
	if (Cross(pdir,up).length() < R_EPSILON)
	  axis2 = Cross(level,down).normalize();
	else
	  axis2 = Cross(pdir,down).normalize();
	//We yet need the direction towards the apex of the triangle
	//to set the apex point
	PositionVector axis3 = Cross(leaf_normal,axis1).normalize();
	//I hope I got the cross  products right, but we will see in
	//the visualization how the leaves settle themselves

	Point right = point + base*0.5*(Point)axis1;
	Point left  = point + base*0.5*(Point)axis2;
	Point apex  = point + height*(Point)axis3;
	Triangle shape(left,right,apex);
	BroadLeaf<Triangle>* leaf = new BroadLeaf<Triangle>(shape,petiole);

	SetValue(*leaf, LGAdof, 0.6); //GetValue(GetTree(*tc), LGPdof)); // cout<<"LGAdof: "<<GetValue(*leaf, LGAdof)<<endl;
	SetValue(*leaf, LGAtauL, GetValue(GetTree(*tc), LGPtauL));
	SetValue(*leaf, LGAsf, GetValue(GetTree(*tc), LGPsf));
  
	double Af = 0.1 * 0.01; //GetValue(GetTree(*ts), LGPaleafmax);
	// cout<<"LGPaleafmax value: "<<GetValue(GetTree(*ts), LGPaleafmax)<<endl;
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
