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
enum poplar_attributes {P1, Pb1, SUBAGE,ISTERMINAL};
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
  PoplarBudData(const PoplarBudData& d):state(d.state), status(d.status), 
					omega(d.omega), brp(d.brp), x(d.x), y(d.y), z(d.z){}
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

    if (size)
      mean_radiation_index = sum_radiation_index/size;
    else
      mean_radiation_index = 0.0;
    //reset for the next light calculation
    sum_radiation_index = 0.0;
    size = 0;
    //cout << "Set Mean RI " <<  mean_radiation_index << " " << " FM " << GetValue(*this,LGAWf) 
    // <<  " SUBAGE " << GetValue(*this,SUBAGE) << " G " << GetValue(*this,LGAomega) <<endl;
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
  friend bool GetValue(const poplarbud& b, poplar_attributes isterminal)
  {
    if (isterminal == ISTERMINAL)
      return b.terminal;
    else
      cerr << "poplarbud ERROR unknown attribute " << isterminal <<endl;
    return b.terminal;
  }
  friend bool SetValue(poplarbud& b, poplar_attributes isterminal, bool val)
  {
    bool old_val = GetValue(b,isterminal);
    if (isterminal == ISTERMINAL)
      b.terminal = val;
    return old_val;
  }
public:
  poplarbud(const Point& p, const PositionVector& d, const LGMdouble go, 
	    Tree<poplarsegment, poplarbud>* tree)
    :Bud<poplarsegment,poplarbud>(p,d,go,tree), brp(0.0),terminal(true)
  {
    //The main axis bud is always terminal (does not create leaves)
    if (go == 1)
      terminal = true;
    //Ohter buds are created nonterminal (they create a leaf and then become terminal) 
    else
      terminal = false;
  }
private:
  LGMdouble brp; //[0:1] meaning the relative position of the bud in a
		 //segment
  void aging(){SetValue(*this, LGAage, GetValue(*this, LGAage)+1.0);}
  bool terminal;
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
	     const Petiole& petiole, const Triangle& shape): 
    BroadLeaf<Triangle>(sf, tauL, dof, number_of_sectors, petiole, shape), T(25.0){}

  PoplarLeaf(const Triangle& shape, const Petiole& petiole)
  : BroadLeaf<Triangle>(shape, petiole), T(25.0){}

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
	const ParametricCurve& fip = GetFunction(GetTree(*ts),LGMIP);
	double vi=GetValue(*ts, LGAvi);
	if(terminal)   
	  apical=1;
	else
	  {
	    apical = rad_index;  //double(double(qin)/double(B));
	    //  cout<<apical<<" : the value of apical."<<endl;
	  }

	double L_new = l*fip(rad_index)*FGRAVELIUS(GetValue(*ts,LGAomega))*FVIGOUR(vi);  
	//double L_new = l*apical*fip(rad_index)*FVIGOUR(vi);
// 	cout << "Lambda " << l << " apical" << apical << " rad_index " << rad_index << " fip " << fip(rad_index) 
// 	     << " go "<< GetValue(*ts,LGAomega) << " f(go) " 
// 	     <<(1.0/(GetValue(*ts,LGAomega)+1.0)) << " vi " << vi << " f(vi) "<< FVIGOUR(vi) <<endl;;
// 	cout << "L New " << L_new << endl;
	L_new = max(L_new,0.0);
	
	if (L_new<MIN_SEGMENT_LENGTH)  //0.05) //0.006)
	  L_new=0.0;  //0.006;  
	// cout<<"L_new: "<<L_new<<", l: "<<l<<endl;
	SetValue(*ts,LGAL,L_new);
	//Initial radius
	SetValue(*ts,LGAR, INITIAL_LR*L_new);  // SetValue(*ts,LGAR,GetValue(GetTree(*ts),LGPlr)*L_new);0.005*L_new);
	//Reset previous Rh!!!!
	SetValue(*ts,LGARh,0.0);
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
	//Number of future leaves depends on the segment length
	double L = GetValue(*ts,LGAL);
	double nbuds = 0.0;
	if (L < 0.01)
	  nbuds = 0.0;
	else if (L < 0.02)
	  nbuds = 1.0;
	else if (L < 0.04)
	  nbuds = 2.0;
	else if (L < 0.06)
	  nbuds = 3.0;
	else if (L < 0.08)
	  nbuds = 4.0;
	else if (L < 0.10)
	  nbuds = 5.0;
	else if (L < 0.12)
	  nbuds = 6.0;
	else if (L < 0.14)
	  nbuds = 7.0;
	else if (L < 0.16)
	  nbuds = 8.0;
	else if (L < 0.18)
	  nbuds = 9.0;
	else if (L < 0.20)
	  nbuds = 10.0;
	else if (L < 0.22)
	  nbuds = 11.0;
	else if (L < 0.24)
	  nbuds = 12.0;
	else if (L < 0.26)
	  nbuds = 13.0;
	else if (L < 0.28)
	  nbuds = 14.0;
	else if (L < 0.30)
	  nbuds = 15.0;
	else if (L < 0.32)
	  nbuds = 16.0;
	else if (L < 0.34)
	  nbuds = 17.0;
	else if (L < 0.36)
	  nbuds = 18.0;
	else if (L < 0.38)
	  nbuds = 19.0;
	else if (L < 0.40)
	  nbuds = 20.0;
	else if (L < 0.42)
	  nbuds = 21.0;
	else if (L < 0.44)
	  nbuds = 22.0;
	else if (L < 0.46)
	  nbuds = 23.0;
	else  if (L < 0.48)
	  nbuds = 24.0;
	else if (L < 0.50)
	  nbuds = 25.0;
	else if (L < 0.52)
	  nbuds = 26.0;
	else if (L < 0.54)
	  nbuds = 27.0;
	else if (L < 0.56)
	  nbuds = 28.0;
	else if (L < 0.58)
	  nbuds = 29.0;
	else if (L < 0.60)
	  nbuds = 30.0;
	else if (L < 0.62)
	  nbuds = 31.0;
	else if (L < 0.64)
	  nbuds = 32.0;
	else if (L < 0.66)
	  nbuds = 33.0;
	else if (L < 0.68)
	  nbuds = 34.0;
	else if (L < 0.70)
	  nbuds = 35.0;
	else if (L < 0.72)
	  nbuds = 36.0;
	else if (L < 0.74)
	  nbuds = 37.0;
	else if (L < 0.76)
	  nbuds = 38.0;
	else if (L < 0.78)
	  nbuds = 39.0;
	else if (L < 0.80)
	  nbuds = 40.0;
	else if (L < 0.82)
	  nbuds = 41.0;
	else if (L < 0.84)
	  nbuds = 42.0;
	else if (L < 0.86)
	  nbuds = 43.0;
	else if (L < 0.88)
	  nbuds = 44.0;
	else if (L < 0.90)
	  nbuds = 45.0;
	else
	  nbuds = 46.0;
	

 	//The foliage area
	double Af = nbuds*POPLAR_LEAF_AREA;
	double sf = GetValue(GetTree(*ts),LGPsf);
	double yc = GetValue(GetTree(*ts),LGPyc);
	//The foliage mass
	double Wfnew = Af/sf;
	//The sapwood area required by foliage
	double Asf = Af/(sf*yc);
	//Set segment radius
	double Rnew = sqrt(Asf/PI_VALUE);
	SetValue(*ts,LGAR,Rnew);
	SetValue(*ts,LGARh,0.0);

// 	cout << "TRY1 R old " << GetValue(*ts,LGAR) << " R new " << Rnew 
// 	     << " Asu " << GetValue(data,LGAAs) << " Asf " << Asf << " Ah " <<  GetValue(*ts,LGARh)
// 	     << " As " << GetValue(*ts,LGAAs) << " AsDown " << GetValue(*ts,LGAAs) 
// 	     <<  " Wsu " << GetValue(data,DGWs) << " Wsnew " << GetValue(*ts,LGAWs) << " Wsdown " 
// 	     << GetValue(*ts,LGAWs) << " L " << GetValue(*ts,LGAL) 
// 	     << " G " << GetValue(*ts,LGAomega) << endl; 
	SetValue(data, DGWfnew, Wfnew);
	SetValue(data, DGWf, Wfnew);
	SetValue(data, DGWs, GetValue(*ts, LGAWs));
	SetValue(data, LGAAs, GetValue(*ts, LGAAs));  
      }
      else{//old segment
	//Sapwood from above
	double Asu = PIPE_MODEL_CONSTANT*GetValue(data,LGAAs); 
	//New sapwood requirement
	//requirement for new radius: sapwood above + own foliage + own heartwood  
        double Rnew = sqrt(Asu/PI_VALUE);
	//compare Rnew to R, choose max
	Rnew = max(Rnew, GetValue(*ts,LGAR));
	//New sapwood requirement, thickness growth
	//cout<<"Asnew: "<<Asnew<<endl;
	//Mass of the new sapwood 
	double Asnew = PI_VALUE*pow(Rnew,2.0)- GetValue(*ts,LGAA);
	
	double Wsnew = GetValue(GetTree(*ts),LGPrhoW)*Asnew*GetValue(*ts,LGAL); 
// 	cout << "TRY2 R old " << GetValue(*ts,LGAR) << " R new " << Rnew 
// 	     << " Asu " << GetValue(data,LGAAs) << " Asnew " << Asnew 
// 	     << " As " << GetValue(*ts,LGAAs) << " AsDown " << GetValue(*ts,LGAAs) + Asnew
// 	     <<  " Wsu " << GetValue(data,DGWs) << " Wsnew " << Wsnew  << " Wsdown " 
// 	     << GetValue(data,DGWs)+Wsnew << " L " << GetValue(*ts,LGAL) 
// 	     << " G " << GetValue(*ts,LGAomega) << endl;
	
        //cout<<"FOR Wsnew: "<<Wsnew<<" Asnew: "<<Asnew<<" LGAL: "<<GetValue(*ts,LGAL)<<endl;
	//Down goes new plus existing sapwood area 
	//cout<<"set data LGAAs: "<<Asnew+GetValue(*ts,LGAAs)<<endl;
	SetValue(data,LGAAs,Asnew+GetValue(*ts,LGAAs)); 
	//cout<<"get data LGAAs: "<<GetValue(data,LGAAs)<<endl;  
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

template <class TS, class BUD,class SHAPE>
class DisplaySegmentData{
public:
  TreeCompartment<TS,BUD>* operator ()(TreeCompartment<TS,BUD>* tc)const
    {
      if (TS* hwts =  dynamic_cast<TS*>(tc))
	{
	  cout << setfill(' ') << setw(7) << "SubAge" << setw(6) << GetValue(*hwts,SUBAGE)
	       << setw(3) << "G" << setw(6) << GetValue(*hwts,LGAomega)
	       << setw(3) << "L" << setw(13) << GetValue(*hwts,LGAL) 
	       << setw(3) << "R" << setw(13) << GetValue(*hwts,LGAR)
	       << setw(3) << "Wf" << setw(13) << GetValue(*hwts,LGAWf) 
	       << setw(3) << "Af" << setw(13) << GetValue(*hwts,LGAAf) <<endl;
	} 
      return tc;
    }
};


#endif
