#ifndef POPLAR_H
#define POPLAR_H

#include <Lignum.h>

class poplarbud;

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
    :Bud<poplarsegment,poplarbud>(p,d,omega,tree){}
 private:
  //poplar specific bud attributes and structures here
  //initialize in constructor
  LGMdouble pb1;
};

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

#endif
