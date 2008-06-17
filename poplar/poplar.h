#ifndef POPLAR_H
#define POPLAR_H

#include <Lignum.h>
#include <VoxelSpace.h>
#include <PoplarConstants.h>
using namespace cxxadt;

class poplarbud;
class poplarleaf;
class poplarsegment;
class PoplarBudData;

//PopalrBD=PoplarBudData
//PopalrBRP=PoplarBudRelativePosition
//PoplarD=PoplarData
extern double temperature;
extern float day1, day2;

enum PoplarBD {PoplarBRP,PoplarD};

//enumarations (i.e. names) for the attributes of poplar segment and bud
enum poplar_attributes {P1, Pb1, SUBAGE};
enum PoplarFN {PoplarAD,PoplarBF,PoplarBS,PoplarLN,PoplarLS,PoplarMSL,PoplarPL,PoplarRCE,PoplarVI};


class PoplarBudData{

  friend LGMdouble GetValue(const PoplarBudData& data,LGMAD name);
  friend LGMdouble SetValue(PoplarBudData& data,LGMAD name,LGMdouble value);
  friend LGMdouble GetValue(const PoplarBudData& data,PoplarBD name);
  friend LGMdouble SetValue(PoplarBudData& data,PoplarBD name,LGMdouble value);

  friend PositionVector GetDirection(const PoplarBudData& data);
  friend void SetDirection(PoplarBudData& data,const PositionVector& d);

public:

  PoplarBudData():state(ALIVE), status(1.0), omega(1.0), brp(1.0), x(0.0), y(0.0), z(1.0){}
  PoplarBudData(const PoplarBudData& d):state(d.state), status(d.status), omega(d.omega), brp(d.brp), x(d.x), y(d.y), z(d.z){}
  PoplarBudData(LGMdouble state1,LGMdouble status1,LGMdouble omega1, LGMdouble brp1)
    :state(state1),status(status1),omega(omega1),brp(brp1), x(0.0), y(0.0), z(1.0){}

  PoplarBudData(LGMdouble state1,LGMdouble status1,LGMdouble omega1,
		LGMdouble brp1,const PositionVector& d)
    :state(state1),status(status1),omega(omega1),
     brp(brp1){SetDirection(*this,d);}
  //The assignment
  PoplarBudData& operator=(const PoplarBudData& data)
  {
    state = data.state;
    status = data.status;
    omega = data.omega;
    brp = data.brp;
    x=data.x;
    y=data.y;
    z=data.z;
    return *this;
  }
private:
  LGMdouble state;  //Dead(0), alive(1), dormant(2)
  LGMdouble status; //[0:1] meaning relative leaf size
  LGMdouble omega;  //branching order
  LGMdouble brp;    //[0:1] meaning  the relative position  of the bud in a segment

  //Direction is explicitely three floating point numbers; 
  LGMdouble x;
  LGMdouble y;
  LGMdouble z;

};


inline LGMdouble GetValue(const PoplarBudData& data,LGMAD name)
{
 
  if (name == LGAstate)
    return data.state;
  else if (name == LGAstatus)
    return data.status;
  else if (name == LGAomega)
    return data.omega;
  else{
    cout << "PoplarBudData unknown attribute: " << name << endl;
    return 0.0;
  }
}

inline LGMdouble SetValue(PoplarBudData& data,LGMAD name,LGMdouble value)
{

  LGMdouble old_value = GetValue(data,name);
  if (name == LGAstate)
    data.state = value;
  else if (name == LGAstatus)
    data.status = value;
  else if (name == LGAomega)
    data.omega = value;
  else{
    cout << "PoplarBudData unknown attribute: " << name << endl;
  }
  return old_value;
}


inline LGMdouble GetValue(const PoplarBudData& data,PoplarBD name)
{ 
  if (name == PoplarBRP)
    return data.brp;
  else
    cout << "PoplarBudData GetValue unknown PoplarBD attribute: " << name << endl;
  return data.brp;
}

inline LGMdouble SetValue(PoplarBudData& data,PoplarBD name,LGMdouble value)
{ 

  LGMdouble old_value = GetValue(data,name);
  if (name == PoplarBRP)
    data.brp = value;
  return old_value;
}

inline PositionVector GetDirection(const PoplarBudData& data)
{
  return PositionVector(data.x,data.y,data.z);
}


inline void SetDirection(PoplarBudData& data,const PositionVector& d)
{
  data.x = d.getX();
  data.y = d.getY();
  data.z = d.getZ();
}


//poplar tree
class PoplarTree: public Tree<poplarsegment, poplarbud>{
  friend const ParametricCurve& GetFunction(const PoplarTree& t, PoplarFN name){
    switch (name){
    case PoplarAD://Apical Dominance
      return t.apical_dominance;
    case PoplarBF://Bud Flush
      return t.bud_flush;
    case PoplarBS://Bud Size
      return t.bud_size;
    case PoplarLN://Leaf pair Number
      return t.leaf_number; 
    case PoplarLS://Leaf Size
      return t.leaf_size;
    case PoplarMSL://Minimum segment length
      return t.min_segment_length;
    case PoplarPL://Petiole length
      return t.petiole_length;
    case PoplarRCE://Radiation conversion efficiency
      return t.rce;
    case PoplarVI://Vigor index
      return t.vigor_index;
    default:
      cout << "PoplarTree Unknown Function: " << name << endl;
      throw ParametricCurve();
    }
  }
public:
  PoplarTree(const string& leafn, const string& leafs, 
	     const string& budsize, const string& budflush,
	     const string& apicald, const string& vigour,
	     const string& slength, const string& plength,
	     const string& frce,
	     const Point& p, const PositionVector d)
    :Tree<poplarsegment, poplarbud>(p,d),
     leaf_number(leafn),leaf_size(leafs),bud_size(budsize),
     bud_flush(budflush),apical_dominance(apicald),
     vigor_index(vigour),min_segment_length(slength),
     petiole_length(plength),rce(frce){}
private:
  ParametricCurve leaf_number; //f(segment length), domain R, range N0,
			       //number of leaf pairs.
  ParametricCurve leaf_size;   //f(relative   position   in   segment)
			       //domain  [0:1], range  [0:1], relative
			       //leaf size.
  ParametricCurve bud_size;    //f(rel pos  in segment), domain [0:1],
			       //range [0:1], relative bud size.
  ParametricCurve bud_flush;   //f(I)    domain   [0:1],    range   [0:1],
			       //probability a bud to flush.
  ParametricCurve apical_dominance; //f(I)  domain   [0:1],  range  [0:1],
				    //apical dominance.
  ParametricCurve vigor_index; //f(vi),  domain  [0:1],  range  [0:1],
			       //function of vigor index
  ParametricCurve min_segment_length; //The minimum segment length
  ParametricCurve petiole_length; //The  petiole  length  as a  f(Af),
				  //leaf size.
  ParametricCurve rce;           //f(I)   domain   R   range   R,   the
  //photosynthetic    efficiency   i.e.,
  //radiation    conversion   efficency:
  //photosynthesis       divided      by
  //intercepted  radiation  in different
  //light climates  
};




class poplarsegment : public HwTreeSegment<poplarsegment,poplarbud,Triangle>
{  

  friend LGMdouble GetValue(const poplarsegment& ps, LGMAD name);
  friend LGMdouble SetValue(poplarsegment& ps, LGMAD name, LGMdouble value);
  friend LGMdouble SetValue(poplarsegment& ps, poplar_attributes name, 
			    LGMdouble value){
    LGMdouble tmp = GetValue(ps,name);
    if (name == P1)
      ps.p1 = value;
    else if (name==SUBAGE)
      ps.subAge = value;
    else
      cerr << "Poplar segment Set Value Unknown attribute: " << name << endl; 
    return tmp;
  }
  friend LGMdouble GetValue(const poplarsegment& ps, poplar_attributes name){
    if (name == P1)
      return ps.p1;
    else if (name == SUBAGE)
      return ps.subAge;
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
    :HwTreeSegment<poplarsegment,poplarbud,Triangle>(p,d,go,l,r,rn,t), subAge(0.0), 
     sum_radiation_index(0.0),mean_radiation_index(0.0),size(0){}
  virtual void photosynthesis(); 
  virtual void respiration();
  TcData& diameterGrowth(TcData& data);

  //sum qabs during the short time step
  void addRadiationIndex(double val){
    sum_radiation_index = sum_radiation_index + val;
    size = size + 1;
  }
  void setMeanRadiationIndex(){
    //cout << "Set Mean RI " <<  sum_radiation_index << " " << size<< endl;
    if (size)
      mean_radiation_index = sum_radiation_index/size;
    else
      mean_radiation_index = 0.0;
    //reset for the next light calculation
    sum_radiation_index = 0.0;
    size = 0;
  }
  //index can be queried after setMeanRadiationIndex
  double getMeanRadiationIndex(){
    return mean_radiation_index;
  }
  double r_segment;
  double segment_length;
  double subAge;

private:
  LGMdouble qin;
  //poplar specific segment attributes and structures here
  //initialize in constructor. p1 is just an example.
  LGMdouble p1;
  double sum_radiation_index;
  double mean_radiation_index;
  double size;
};


inline LGMdouble GetValue(const poplarsegment& ts, LGMAD name)
{
  if (name == LGAQin){
    //The Qin is ts.qin if a newly created segment
    //    (GetValue(dynamic_cast<const HwTreeSegment<poplarsegment, poplarbud>&>(ts),LGAage) == 0)
    if(GetValue(ts, SUBAGE)== 0.0)
      {
	return ts.qin;
      }
    else{//return Qin as a sum of Qin of leaves
      return GetValue(dynamic_cast<const HwTreeSegment<poplarsegment,
		      poplarbud, Triangle>& >(ts),name);
    }
  }
  else{//fall down to GetValue for HwTreeSegments
    return GetValue(dynamic_cast<const HwTreeSegment<poplarsegment, poplarbud, Triangle>& >(ts),name);
  }
 
}

inline LGMdouble SetValue(poplarsegment& ts, LGMAD name, LGMdouble value)
{
  LGMdouble old_value = GetValue(ts,name);
  if (name == LGAQin){
    //The Qin is ts.qin if a newly created segment
    if(GetValue(ts, SUBAGE)== 0.0){
      ts.qin = value;
    }
    else{
      LGMMessage("SetValue(smts,LGAQin) not meaningful for leaves");
    }
  }
  else{//Fall down to SetValue for HwTreeSegment
    old_value = SetValue(dynamic_cast<HwTreeSegment<poplarsegment,
                         poplarbud, Triangle> & >(ts),name,value);
  }
  return old_value;
}



class poplarbud : public Bud<poplarsegment, poplarbud>
{
  friend PoplarBudData SetValue(poplarbud& b,PoplarBD name,const PoplarBudData& d);
  friend PoplarBudData GetValue(const poplarbud& b,PoplarBD name);
public:
  poplarbud(const Point& p, const PositionVector& d, const LGMdouble omege, 
	    Tree<poplarsegment, poplarbud>* tree)
    :Bud<poplarsegment,poplarbud>(p,d,LGAomega,tree), brp(0.0){}
private:
  LGMdouble brp; //[0:1] meaning the relative position of the bud in a
		 //segment
  void aging(){SetValue(*this, LGAage, GetValue(*this, LGAage)+1.0);}

};

//SetValue and GetValue for the structure PoplarBudData in L-systems
inline PoplarBudData SetValue(poplarbud& b, PoplarBD name, const PoplarBudData& data)
{
  PoplarBudData old_data = GetValue(b,name);
  if (name == PoplarD){
    SetValue(b,LGAstate,GetValue(data,LGAstate));
    SetValue(b,LGAstatus,GetValue(data,LGAstatus));
    SetValue(b,LGAomega,GetValue(data,LGAomega));
    b.brp = GetValue(data,PoplarBRP);
    //Do not  update the direction, if  you do, you  will override the
    //work of the turtle.
  }
  else{
    cout << "Poplar Bud SetValue error, no structure: " 
	 << name << endl;
  }
  return old_data;
}

inline PoplarBudData GetValue(const poplarbud& b, PoplarBD name)
{
  PoplarBudData data(ALIVE,0.0,0.0,0.0); 

  if (name == PoplarD){
    SetValue(data,LGAstate,GetValue(b,LGAstate));
    SetValue(data,LGAstatus,GetValue(b,LGAstatus));
    SetValue(data,LGAomega,GetValue(b,LGAomega));
    SetValue(data,PoplarBRP,b.brp);
    SetDirection(data,GetDirection(b));
  }
  else{
    cout << "Poplar Bud GetValue error, no structure: " 
	 << name << endl;
  }
  return data;
}



class PoplarLeaf:public BroadLeaf<Triangle>{

public:

  PoplarLeaf(LGMdouble sf,LGMdouble tauL,LGMdouble dof,int number_of_sectors,
	     const Petiole& petiole, const PositionVector& leaf_normal,
	     const Triangle& shap): BroadLeaf<Triangle>(sf, tauL, dof, number_of_sectors, petiole, shap), T(25.0){}

  PoplarLeaf(const Triangle& shape, const Petiole& petiole, 
	     const PositionVector& leaf_normal): BroadLeaf<Triangle>(shape, petiole), T(25.0){}

  int photosynthesis();
  void respiration();

private:
  LGMdouble T; //tempreature
  //  BroadLeafAttributes<Triangle> bla;
};


class PoplarLeafPhotosynthesis
{
public:
  // void operator()(PoplarLeaf* bl);
  void operator()(BroadLeaf<Triangle>* bl);
};

class PoplarLeafRespiration
{
public:
  void operator()(BroadLeaf<Triangle>* bl);
};


//template <class TS,class BUD>
class SetSegmentLength{
public:
  SetSegmentLength(double lamda):l(lamda),apical(1.0){}
  SetSegmentLength& operator=(const SetSegmentLength& sl){
    l = sl.l;
    terminal=sl.terminal;
    apical = sl.apical;
    return *this;
  }
  //TreeCompartment<TS,BUD>* operator()(TreeCompartment<TS,BUD>* tc)const
  double& operator()(double& rad_index, TreeCompartment<poplarsegment, poplarbud>* tc)const
  {
    // cout<<"set Segment Length here"<<endl;
    if (poplarsegment* ts = dynamic_cast<poplarsegment*>(tc)){
      if (GetValue(*ts, SUBAGE) > 0.5){  //SUBAGE
	//qin=GetValue(*ts, LGAQin);//Take the Qin, it will be passed to segment in front
	// cout<<"qin from old segment: "<<qin<<endl;
	rad_index=ts->getMeanRadiationIndex();
      }
      else {
	//SetValue(*ts, LGAQin, qin);
	Firmament& f = GetFirmament(GetTree(*ts));
	//double B = f.diffuseBallSensor();
	vector<double> direct_direction(3);
	vector<double> diffuse_direction(3);
	//double B = f.directRadiation(direct_direction)+f.diffuseRadiationSum(diffuse_direction);
	//cout<<"qin of segment: "<<qin<<" B: "<<B<<" and the ratio: "<<qin/B<<endl;
	const ParametricCurve& fip = GetFunction(GetTree(*ts),LGMIP);
	//Omega starts from 1 
	//TreeQinMax should work also for open trees: TreeQinMax should then equal to 
	//Ball sensor reading
	//Open grown branching effect
	//double Lq = 1.0-(GetValue(*ts,LGAomega)-1.0)*GetValue(GetTree(*ts),q);
	
	double vi=GetValue(*ts, LGAvi);
	// cout<<"vi: "<<vi<<endl;
	//In Tree Physiology for side branches fp is for example as follows: Lq = apical*(0.15+0.85*Lq);
	//experimental forest grown
	//** double Lq = pow(1.0 - GetValue(GetTree(*ts),q),GetValue(*ts,LGAomega)-1);
	//relative light, if TreeQinMax is ball sensor reading, it is as for open grown pine
	// B = GetValue(GetTree(*ts),TreeQinMax); // because don't know what is TreeQinMax
	// B=1200;
 
	// cout<<"terminal: "<<terminal<<endl;
	if(terminal)   
	  apical=1;
	else
	  {
	    apical = rad_index;  //double(double(qin)/double(B));
	    //  cout<<apical<<" : the value of apical."<<endl;
	  }

	double L_new=l * apical *fip(rad_index) *(1/(GetValue(*ts,LGAomega)+1)) * FVIGOUR(vi);  
	cout << "apical" << apical << " rad_index " << rad_index << " fip " << fip(rad_index) 
	     << " go "<< GetValue(*ts,LGAomega) << " f(go) " 
	     <<(1.0/(GetValue(*ts,LGAomega)+1.0)) << " vi " << vi << " f(vi) "<< FVIGOUR(vi) <<endl;;
	cout << "L New " << L_new << endl;
	L_new = max(L_new,0.0);
	
	if (L_new<0.05)  //0.05) //0.006)
	  L_new=0.0;  //0.006;  
	// cout<<"L_new: "<<L_new<<", l: "<<l<<endl;
	SetValue(*ts,LGAL,L_new);
	
	double af=0.01; 
	SetValue(*ts, LGARTop, af);
	double asf=af/(GetValue(GetTree(*ts), LGPsf)*GetValue(GetTree(*ts), LGPyc));
	double atot=asf;
	// cout<<"mass LGAWs1: "<<GetValue(*ts, LGAWs)<<endl;
	//Initial radius
	//SetValue(*ts,LGAR, 0.0015*sqrt(L_new));   //0.0015*sqrt(L_new));  0.005*L_new
	SetValue(*ts,LGAR, INITIAL_LR*L_new);  // SetValue(*ts,LGAR,GetValue(GetTree(*ts),LGPlr)*L_new);0.005*L_new);
	//Reset previous Rh!!!!
	SetValue(*ts,LGARh,0.0);
	//Initial heartwood
	//*** SetValue(*ts,LGARh,sqrt((GetValue(GetTree(*ts),LGPxi)*GetValue(*ts,LGAAs))/PI_VALUE));
	//cout<<"mass LGAWs2: "<<GetValue(*ts, LGAWs)<<endl;
	//Initial foliage
	//NOTE: HwTree does not have SetValue for LGAWf!!!
	// SetValue(*ts,LGAWf,GetValue(GetTree(*ts),LGPaf)*GetValue(*ts,LGASa));
	//Remember original sapwood area As0

	//NOTE: HwTree does not have LGAAs0!!!!!
	SetValue(*ts,LGAAs0,GetValue(*ts,LGAAs));   
	//* cout<<GetValue(*ts, LGAAs)<<"check radius of segment................"<<GetValue(*ts, LGAR)<<endl;
	ts->r_segment = GetValue(*ts, LGAR);
	ts->segment_length = GetValue(*ts, LGAL);
	//cout<<"mass LGAWs3: "<<GetValue(*ts, LGAWs)<<endl;
      }
    }//segment

    else if (Axis<poplarsegment, poplarbud>* axis = dynamic_cast<Axis<poplarsegment, poplarbud>*>(tc)){
      list<TreeCompartment<poplarsegment, poplarbud>*> & ls = GetTreeCompartmentList(*axis);
      //new brancing [TS,BP,B]
      if (ls.size() == 3)   //==3 in suger maple, but 2 in poplar??
	{
	  terminal = false;
	  //apical = 0.8;
	}
      //old branch
      else
	terminal = true;
    }
    return rad_index;
  }
private:
  double l;//Lamda to iterate segment lengths
  mutable double apical; //Apical dominance, 1 or less, e.g. 0.8
  mutable double terminal;
};

//This  is must be  the same  as diameterGrowth  method, but  we can't
//change the segment's dimensions.
//template <class TS,class BUD>
class TryDiameterGrowth{
public:
  DiameterGrowthData& operator()(DiameterGrowthData& data, TreeCompartment<poplarsegment, poplarbud>* tc)const
  { 
    if (poplarsegment* ts = dynamic_cast<poplarsegment*>(tc)){ 
      if (GetValue(*ts, SUBAGE) < 0.5){   //SUBAGE
	//Collect the masses
	//***SetValue(data,DGWfnew,GetValue(*ts,DGWfnew));
	//***SetValue(data,DGWf,GetValue(*ts,DGWf));
	//***SetValue(data,DGWs,GetValue(*ts,DGWs));
	//Sapwood requirement
	//**SetValue(data,LGAAs,GetValue(*ts,LGAAs));

	LGMdouble As=GetValue(*ts, LGAAs);
	LGMdouble Af=As*20*10;
	LGMdouble Wf = Af/20;//LGMdouble Wf =GetValue(*ts, LGAL)/2000; 
	//cout<<"mass in try diametergrowth: "<<As<<" "<<Af<<" "<<Wf<<" "<<GetValue(*ts, LGAWs)<<endl;
	//  cout<<"mass LGAWs4: "<<GetValue(*ts, LGAWs)<<endl;
	SetValue(data, DGWfnew, Wf);
	SetValue(data, DGWf, Wf);
	//cout<<"setValue of DGWfnew is: "<<GetValue(data,DGWfnew)<<"or "<<Wf<<endl;
	SetValue(data, DGWs, GetValue(*ts, LGAWs));
	//  cout<<"setValue of DGWs is: "<<GetValue(*ts, LGAWs)<<" LGAAs: "<<GetValue(*ts, LGAAs)<<endl;
	SetValue(data, LGAAs, GetValue(*ts, LGAAs));  //Wf/10);   //GetValue(*ts, LGAAs));
        //cout<<"DGWs: "<<GetValue(data,DGWs)<<" DGWfnew: "<<GetValue(data,DGWfnew)<<"DGWf: "<<GetValue(data, DGWf)<<endl;

      }
      else{//old segment
	//**const ParametricCurve& fm = GetFunction(GetTree(*ts),LGMFM);
	//Sapwood requirement of  remaining foliage, assume fm returns
	//proportion of initial foliage present, declining function of
	//age from 1 to 0.
	//*LGMdouble Asr = fm(GetValue(*ts,LGAage))*GetValue(*ts,LGAAs0);
	//sapwood area from above
	//cout<<"LGAAs-Asu: "<<GetValue(data,LGAAs)<<" Ahown: "<<GetValue(*ts,LGAA)<<endl;
	LGMdouble Asu = GetValue(data,LGAAs); 
	//own heartwood, assume aging has done
	LGMdouble Ahown  =GetValue(*ts,LGAAh); //GetValue(*ts,LGAAh);
	//requirement for new radius: sapwood above + own heartwood + own foliage 
	//***LGMdouble Rnew = sqrt((Asu + Ahown + Asr)/PI_VALUE);
        LGMdouble Rnew = sqrt((Asu + Ahown)/PI_VALUE);
	//compare Rnew to R, choose max
	//cout<<"Rnew: "<<Rnew<<" GetValue(*ts,LGAR): "<< GetValue(*ts,LGAR)<<endl;
	Rnew = max(Rnew, GetValue(*ts,LGAR));
	//New sapwood requirement, thickness growth
	double Asnew =PI_VALUE*pow(Rnew,2.0) -  GetValue(*ts,LGAA); 
	//cout<<"Asnew: "<<Asnew<<endl;
	//Mass of the new sapwood 
	double Wsnew = GetValue(GetTree(*ts),LGPrhoW)*Asnew*GetValue(*ts,LGAL); 
        //cout<<"FOR Wsnew: "<<Wsnew<<" Asnew: "<<Asnew<<" LGAL: "<<GetValue(*ts,LGAL)<<endl;

	//Down goes new plus existing sapwood area 
	//cout<<"set data LGAAs: "<<Asnew+GetValue(*ts,LGAAs)<<endl;
	SetValue(data,LGAAs,Asnew+GetValue(*ts,LGAAs)); 
	//cout<<"get data LGAAs: "<<GetValue(data,LGAAs)<<endl;  

	//Mass of sapwood used in diamater growth
	/*cout<<"setValue of DGWs is: "<<GetValue(data,DGWs)+Wsnew<<endl;
	  cout<<"setValue of old DGWs is: "<<GetValue(data,DGWs)<<endl;
	  cout<<"setValue of Wsnew is: "<<Wsnew<<endl; */
	SetValue(data,DGWs,GetValue(data,DGWs)+Wsnew);
	//Total foliage
	SetValue(data,DGWf,GetValue(data,DGWf)+GetValue(*ts,LGAWf));
      }
    }
    return data;
  }
};


class CreatePoplarLeaves{
public:
  CreatePoplarLeaves(METER l, METER b, METER h):pl(l),base(b),height(h), rlsize(0.0){}
  vector<PositionVector>& operator()(vector<PositionVector>& v,
				     TreeCompartment<poplarsegment, poplarbud>* tc)const;
  METER pl;//Petiole length
  METER base; //base length
  METER height; //height of the triangle
  mutable double rlsize; //Relative leaf size (LGAstatus)
};



template <class TS,class BUD>
class KillPoplarBuds{
public:
  double&  operator()(double& length,TreeCompartment<TS, BUD>* tc)const{
    if (TS* ts = dynamic_cast<TS*>(tc)){
      length = GetValue(*ts,LGAL);
    }
    else if (BUD* b = dynamic_cast<BUD*>(tc)){
      if(length == 0) {   //0.005 || GetValue(*b, LGAomega)>5){    //original(length ==0)
	SetValue(*b,LGAstate,DEAD);   //***SetValue(*b,LGAstate,DORMANT);             
      }
    }
    return length;
  }
};

template <class TS,class BUD>
class WakeupPoplarBuds{
public:
  double  operator()(TreeCompartment<TS, BUD>* tc)const{
    if (BUD* b = dynamic_cast<BUD*>(tc)){
      // cout<<"Dormant: "<<DORMANT<<" and Value: "<<GetValue(*b, LGAstate)<<endl;
      if (GetValue(*b, LGAstate) == DORMANT){
	//   cout<<"WakeUPPoplarBuds"<<endl;
	if(GetValue(*b, LGAage)==1)
	  {
	    // cout<<GetValue(*b, LGAage)<<" : the value of bud age"<<endl;
	    SetValue(*b,LGAstate, ALIVE); 
	  }  
	else 
	  SetValue(*b,LGAstate, DEAD); //  SetValue(*b,LGAstate, DORMANT); 
      }
    }
    return 0;
  }
};

template <class TS, class BUD>
class SubAging{
public:
  void operator()(TreeCompartment<TS, BUD>* tc)const{
    if (TS* ts = dynamic_cast<TS*>(tc)){
      SetValue(*ts, SUBAGE, GetValue(*ts, SUBAGE)+1.0);         
    }
    if (BUD* b = dynamic_cast<BUD*>(tc)){
      //SetValue(*b, SUBAGE, GetValue(*b, SUBAGE)+1.0); 
      SetValue(*b,LGAstatus, GetValue(*b, LGAstatus)+ 0.1);
    }
  }
};



//This propagates the  Radius of the first part  of the split segments
//to the rest of the  segments in the sequence maintaining the sapwood
//allocated.
/*
  class ForwardR0{
  public:
  double& operator()(double& r0,
  TreeCompartment<poplarsegment, poplarbud>* tc)const
  {
  if (poplarsegment* ts = dynamic_cast<poplarsegment*>(tc)){
  //Ages are zero
  if (GetValue(*ts,LGAage) == 0.0){
  //If the r0 is not set
  if (r0 == 0.0)
  //This is the first part of the split segment
  r0 = GetValue(*ts,LGAR);
  else
  //These are the other segments resulting from the split
  SetValue(*ts,LGAR,r0);
  }
  }
  return r0;
  }
  };
*/

class ForwardR0Qin{
public:
  pair<double, double>& operator()(pair<double, double>& r0qin,
				   TreeCompartment<poplarsegment, poplarbud>* tc)const
  {
    if (poplarsegment* ts = dynamic_cast<poplarsegment*>(tc)){
      //Ages are zero
      if (GetValue(*ts,SUBAGE) == 0.0){   //SUBAGE
	//If the r0 is not set
	if (r0qin.first == 0.0)
	  {
	    //This is the first part of the split segment
	    r0qin.first = GetValue(*ts,LGAR);
	    r0qin.second = GetValue(*ts, LGAQin);
	  }
	else
	  {
	    //These are the other segments resulting from the split
	    SetValue(*ts,LGAR,r0qin.first);
	    SetValue(*ts,LGAQin,r0qin.second);
	  }
      }
    }
    return r0qin;
  }
};

template <class TS, class BUD, class SHAPE>
class SetPoplarSegmentQabsFunctor{
public:
  SetPoplarSegmentQabsFunctor(VoxelSpace& s, const ParametricCurve& ri):voxel_space(s), rad_index(ri){}
  TreeCompartment<TS,BUD>* operator ()(TreeCompartment<TS,BUD>* tc)const;
  VoxelSpace& voxel_space;
private:
  const ParametricCurve& rad_index;
};

template <class TS, class BUD, class SHAPE>
void SetPoplarQabs(VoxelSpace &s, Tree<TS, BUD> &tree, const ParametricCurve& rad_index)
    {
      SetPoplarSegmentQabsFunctor<TS,BUD,SHAPE> f(s,rad_index);
      ForEach(tree, f);
    }

template <class TS, class SHAPE>
void SetPoplarSegmentQabs(VoxelSpace &space,TS& ts, const ParametricCurve& rad_index)
    {
      Point p;
      LGMdouble la, bQin, lQabs;
      VoxelBox box;
      list<BroadLeaf<SHAPE>*>& leaf_list = GetLeafList(ts);
      typename list<BroadLeaf<SHAPE>*>::iterator I;
      for(I = leaf_list.begin(); I != leaf_list.end(); I++) {
	p = GetCenterPoint(**I);
	box = space.getVoxelBox(p);
	bQin = box.getQin();
	//80% absorbed
	lQabs =QIN_TO_QABS_CONVERSION_EFFICIENCY * bQin ;
	//	cout<<"Qin: "<<bQin<<" Qabs: "<<lQabs<<endl;
	SetValue(**I, LGAQabs, lQabs);
	SetValue(**I, LGAQin, bQin);
	//radiation index book  keeping, note that rad_index(Qabs) can
	//be less  than 0,  radiation index of  a segment will  be the
	//mean of the radiaton indices of the leaves attached to it
	ts.addRadiationIndex(max(rad_index(lQabs),0.0));
      }
    }

template <class TS, class BUD,class SHAPE>
TreeCompartment<TS,BUD>* SetPoplarSegmentQabsFunctor<TS,BUD,SHAPE>::operator ()(TreeCompartment<TS,BUD>* tc)const
    {
      if (TS* hwts =  dynamic_cast<TS*>(tc))
	{
	  SetPoplarSegmentQabs<TS,SHAPE>(voxel_space, *hwts,rad_index);
	} 
      return tc;
    }

template <class TS, class BUD,class SHAPE>
class SetMeanRadiationIndex{
public:
  TreeCompartment<TS,BUD>* operator ()(TreeCompartment<TS,BUD>* tc)const
    {
      if (TS* hwts =  dynamic_cast<TS*>(tc))
	{
	  hwts->setMeanRadiationIndex();
	} 
      return tc;
    }
};

template <class TS, class BUD,class SHAPE>
class CheckMeanRadiationIndex{
public:
  TreeCompartment<TS,BUD>* operator ()(TreeCompartment<TS,BUD>* tc)const
    {
      if (TS* hwts =  dynamic_cast<TS*>(tc))
	{
	  cout << "Check " << hwts->getMeanRadiationIndex()<<endl;
	} 
      return tc;
    }
};
#endif
