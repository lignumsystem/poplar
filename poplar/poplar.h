#ifndef POPLAR_H
#define POPLAR_H

#include <Lignum.h>
using namespace cxxadt;

class poplarbud;
class poplarleaf;

//enumarations (i.e. names) for the attributes of poplar segment and bud
enum poplar_attributes {P1, Pb1};


class poplarsegment : public HwTreeSegment<poplarsegment,poplarbud,Triangle>
{
  friend LGMdouble SetValue(poplarsegment& ps, poplar_attributes name, 
			    LGMdouble value){
    LGMdouble tmp = GetValue(ps,name);
    if (name == P1)
      ps.p1 = value;
    else
      cerr << "Poplar segment Set Value Unknown attribute: " << name << endl; 
    return tmp;
  }
  friend LGMdouble GetValue(poplarsegment& ps, poplar_attributes name){
    if (name == P1)
      return ps.p1;
    else{
      cerr << "Poplar segment Get Value Unknown attribute: " << name << endl; 
      cerr << "Returning -1 " << endl; 
    }
    return -1.0;
  }

public:
  //Constructor for poplar segment. The argument list is as assumed by
  //L-system. If you need additional arguments add them after the last
  //one (the tree) and provide default values
  poplarsegment(const Point& p, const PositionVector& d, const LGMdouble go,
                const METER l, const METER r, const METER rn, 
                Tree<poplarsegment, poplarbud>* t)
    :HwTreeSegment<poplarsegment,poplarbud,Triangle>(p,d,go,l,r,rn,t){}
  virtual void photosynthesis(); 
  virtual void respiration();
private:
  //poplar specific segment attributes and structures here
  //initialize in constructor. p1 is just an example.
  LGMdouble p1;
};


class poplarbud : public Bud<poplarsegment, poplarbud>
{
  //Constructor  for poplar  bu. The  argument list  is as  assumed by
  //L-system. If you need additional arguments add them after the last
  //one (the tree) and provide default values
  friend LGMdouble SetValue(poplarbud& pb, poplar_attributes name,
			    LGMdouble value){
    LGMdouble tmp=GetValue(pb, name);
    if (name==Pb1)
      pb.pb1=value;
    else
      cerr << "Poplar bud Set Value Unknown attribute: " << name << endl; 
    return tmp;
  }

  friend LGMdouble GetValue(poplarbud& pb, poplar_attributes name){
    if (name==Pb1)
      return pb.pb1;
    else{
      cerr << "Poplar bud Get Value Unknown attribute: " << name << endl; 
      cerr << "Returning -1 " << endl; 
    }
    return -1.0;
  }

 public:
  poplarbud(const Point& p, const PositionVector& d, const LGMdouble omege, 
	    Tree<poplarsegment, poplarbud>* tree)
    :Bud<poplarsegment,poplarbud>(p,d,LGAomega,tree){}
 private:
  //poplar specific bud attributes and structures here
  //initialize in constructor
  LGMdouble pb1;
};

//void BroadLeaf<Triangle>::photosynthesis(const LGMdouble& p0)
//{
  // bla.P = p0 * bla.Qabs;
//}

class PoplarLeafPhotosynthesis
{
public:
  void operator()(BroadLeaf<Triangle>* bl);
};

class PoplarLeafRespiration
{
 public:
  void operator()(BroadLeaf<Triangle>* bl);
};




enum DGAD {DGWs, DGWf, DGWfnew};

class DiameterGrowthData:public TcData{
  friend double GetValue(const DiameterGrowthData& dgd, DGAD name);
  friend double SetValue(DiameterGrowthData& dgd, DGAD name, double value);
public:
  DiameterGrowthData():Ws(0.0),Wf(0.0),Wfnew(0.0){}
  DiameterGrowthData& operator=(TcData& tcd)
  {
    DiameterGrowthData& dgd = dynamic_cast<DiameterGrowthData&>(tcd);
    SetValue(*this,LGAAs,GetValue(dgd,LGAAs)); 
    SetValue(*this,DGWs,GetValue(dgd,DGWs));
    SetValue(*this,DGWf,GetValue(dgd,DGWf));
    SetValue(*this,DGWfnew,GetValue(dgd,DGWfnew));
    return *this;
  }
  DiameterGrowthData& operator+=(TcData& tcd)
  {
    DiameterGrowthData& dgd = dynamic_cast<DiameterGrowthData&>(tcd);
    SetValue(*this,LGAAs,GetValue(*this,LGAAs)+GetValue(dgd,LGAAs));
    SetValue(*this,DGWs,GetValue(*this,DGWs)+GetValue(dgd,DGWs));
    SetValue(*this,DGWf,GetValue(*this,DGWf)+GetValue(dgd,DGWf));
    SetValue(*this,DGWfnew,GetValue(*this,DGWfnew)+GetValue(dgd,DGWfnew));
    return *this;
  }
  void clear(){
    SetValue(*this,LGAAs,0.0);
    SetValue(*this,DGWs,0.0);
    SetValue(*this,DGWf,0.0);
    SetValue(*this,DGWfnew,0.0);
  }
private:
  double Ws,Wf,Wfnew;//Sapwood, total foliage and new foliage mass. 
};

inline double GetValue(const DiameterGrowthData& dgd, DGAD name)  
{
  if (name == DGWs)
    return dgd.Ws;
  else if (name == DGWf)
    return dgd.Wf;
  else if (name == DGWfnew)
    return dgd.Wfnew;
  else{
    cout << " DiameterGrowthData GetValue unknown name:" << endl;
    return -1.0;
  }
}
 
inline double SetValue(DiameterGrowthData& dgd, DGAD name, double value)  
{
  double old_value = GetValue(dgd,name);
  if (name == DGWs)
    dgd.Ws = value;
  else if (name == DGWf)
    dgd.Wf = value;
  else if (name == DGWfnew)
    dgd.Wfnew = value;
  return old_value;
}
   

template <class TS,class BUD>
class SetSegmentLength{
public:
  SetSegmentLength(double lamda):l(lamda),apical(1.0){}
  SetSegmentLength& operator=(const SetSegmentLength& sl){
    l = sl.lamda;
    apical = sl.apical;
    return *this;
  }
  TreeCompartment<TS,BUD>* operator()(TreeCompartment<TS,BUD>* tc)const
  {
      if (TS* ts = dynamic_cast<TS*>(tc)){
	  if (GetValue(*ts,LGAage) == 0.0){
	     Firmament& f = GetFirmament(GetTree(*ts));
	 double B = f.diffuseBallSensor();
	 const ParametricCurve& fip = GetFunction(GetTree(*ts),LGMIP);
	 //Omega starts from 1 
	 //TreeQinMax should work also for open trees: TreeQinMax should then equal to 
	 //Ball sensor reading
	 //Open grown branching effect
	 //double Lq = 1.0-(GetValue(*ts,LGAomega)-1.0)*GetValue(GetTree(*ts),q);
	 //Vigour index
	  double Lq = GetValue(*ts,LGAvi);
	 //In Tree Physiology for side branches fp is for example as follows:
	 //fp = (1-a)f(vi) = (1-0.2)(0.15+0.85vi) = 0.8(0.15+0.85vi)
	 Lq = apical*(0.15+0.85*Lq);
	 //experimental forest grown
	 //double Lq = pow(1.0 - GetValue(GetTree(*ts),q),GetValue(*ts,LGAomega)-1);
	 //relative light, if TreeQinMax is ball sensor reading, it is as for open grown pine
	 // B = GetValue(GetTree(*ts),TreeQinMax); // because don't know what is TreeQinMax
	 // B=1200;
         //0.8 describes the effect of branching  
	 double L_new = l*Lq; // = l*Lq*fip(GetValue(*ts,Qin)/B);  there are some problem for fip function so take fip()=1
         
	 L_new = max(L_new,0.0);
	  SetValue(*ts,LGAL,L_new);
	 //Initial radius
	 SetValue(*ts,LGAR,GetValue(GetTree(*ts),lr)*L_new);
	 //Reset previous Rh!!!!
	 SetValue(*ts,LGARh,0.0);
	 //Initial heartwood
	 SetValue(*ts,LGARh,sqrt((GetValue(GetTree(*ts),xi)*GetValue(*ts,LGAAs))/PI_VALUE));
	 //Initial foliage
	 SetValue(*ts,LGAWf,GetValue(GetTree(*ts),af)*GetValue(*ts,LGASa));
 	 //Remember original sapwood area As0
	 SetValue(*ts,LGAAs0,GetValue(*ts,LGAAs)); 
	 // cout<<GetValue(*ts, As)<<"check radius of segment................"<<GetValue(*ts, LGAR)<<endl;
	 }
     }//segment
     else if (Axis<TS,BUD>* axis = dynamic_cast<Axis<TS,BUD>*>(tc)){
      list<TreeCompartment<TS,BUD>*> & ls = GetTreeCompartmentList(*axis);
	 //new brancing [TS,BP,B]
	 if (ls.size() == 3)
	   apical = 0.8;
	 //old branch
	 else
	 apical = 1.0;
	   }
     return tc;
  }
private:
  double l;//Lamda to iterate segment lengths
  mutable double apical; //Apical dominance, 1 or less, e.g. 0.8
};

//This  is must be  the same  as diameterGrowth  method, but  we can't
//change the segment's dimensions.
template <class TS,class BUD>
class TryDiameterGrowth{
public:
  DiameterGrowthData& operator()(DiameterGrowthData& data, TreeCompartment<TS,BUD>* tc)const
  {
    if (TS* ts = dynamic_cast<TS*>(tc)){
      if (GetValue(*ts,LGAage) == 0){//New segment
	//Collect the masses
	SetValue(data,DGWfnew,GetValue(*ts,LGAWf));
	SetValue(data,DGWf,GetValue(*ts,LGAWf));
	SetValue(data,DGWs,GetValue(*ts,Ws));
	//Sapwood requirement
	SetValue(data,LGAAs,GetValue(*ts,LGAAs));
      }
      else{//old segment
	const ParametricCurve& fm = GetFunction(GetTree(*ts),LGMFM);
	//Sapwood requirement of  remaining foliage, assume fm returns
	//proportion of initial foliage present, declining function of
	//age from 1 to 0.
	LGMdouble Asr = fm(GetValue(*ts,LGAage))*GetValue(*ts,LGAAs0);
	//sapwood area from above
	LGMdouble Asu = GetValue(data,LGAAs); 
	//own heartwood, assume aging has done
	LGMdouble Ahown  = GetValue(*ts,Ah);
	//requirement for new radius: sapwood above + own heartwood + own foliage 
	LGMdouble Rnew = sqrt((Asu + Ahown + Asr)/PI_VALUE);
	//compare Rnew to R, choose max
	Rnew = max(Rnew, GetValue(*ts,LGAR));
	//New sapwood requirement, thickness growth
	double Asnew = PI_VALUE*pow(Rnew,2.0) -  GetValue(*ts,LGAA);
	
	//Mass of the new sapwood 
	double Wsnew = GetValue(GetTree(*ts),rho)*Asnew*GetValue(*ts,LGAL); 
	//Down goes new plus existing sapwood area 
	SetValue(data,LGAAs,Asnew+GetValue(*ts,LGAAs)); 
	//Mass of sapwood used in diamater growth
	SetValue(data,DGWs,GetValue(data,DGWs)+Wsnew);
	//Total foliage
	SetValue(data,DGWf,GetValue(data,DGWf)+GetValue(*ts,LGAWf));
      }
    }
    return data;
  }
};


//LPineGrowthFunction  will  implement in  the  function operator  the
//elongation/shortening of  segments, simulation of  diameter and root
//growth.   The it  returns  P-M-G.   Use it  with  some root  finding
//algorithm.  For  example Bisection. See function  operator that does
//the job.
template <class TS,class BUD>
class PoplarGrowthFunction{
public:
  PoplarGrowthFunction(Tree<TS,BUD>& tree):t(tree),P(-1.0),M(-1.0){}
  double operator()(double l);
  void init();
  double getP()const{return P;}
  double getM()const{return M;}
private:
  Tree<TS,BUD>& t;
  double P;
  double M;
};


//Collect photosynthates and respiration once per growth allocation.
template <class TS,class BUD>
void PoplarGrowthFunction<TS,BUD>::init()
{
  double p = 0.0;
  P = Accumulate(t,p,SumTreePhotosynthesis<TS,BUD>());
  double m = 0.0;
  M =  Accumulate(t,m,SumTreeRespiration<TS,BUD>());
  //if (P <= M)
  //cout << "P: " << P << " M: " << M << " P-M: " << P-M << endl;
} 

template <class TS,class BUD>
double PoplarGrowthFunction<TS,BUD>::operator()(double l)
{
  DiameterGrowthData data;
  

  //1.Elongate or shorten segment lengths
  ForEach(t,SetSegmentLength<TS,BUD>(l));

  //2. Simulate  diameter  growth  and  collect  sapwood  and  foliage
  //masses.
  data = AccumulateDown(t,data,TryDiameterGrowth<TS,BUD>());   
  

  //3. return P-M-G where G = iWs(l) + iWfnew(l) + iWrnew(l)
  //iWs = sapwood mass: new segments + thickening
  //iWfnew = new foliage
  //iWrnew = new roots = ar*iWfnew
 
  return P - M - GetValue(data,DGWs) - GetValue(data,DGWfnew) - GetValue(t,ar)* GetValue(data,DGWfnew);
}




#endif
