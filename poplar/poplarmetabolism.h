#ifndef POPLARPHOTO_H
#define POPLARPHOTO_H
#include <poplar.h>

//Demonstrate the use of dynamic_cast (see poplar_photosynthesis.cc)
class ForEachPrintCompartments
{
 public:
  TreeCompartment<poplarsegment, poplarbud>* operator ()(TreeCompartment<poplarsegment, poplarbud>* ts)const;

};

//The photosynthesis
class DoPhotosynthesis
{
 public:
  TreeCompartment<poplarsegment, poplarbud>* operator ()(TreeCompartment<poplarsegment, poplarbud>* ts)const;

};

class DoRespiration
{
 public:
  TreeCompartment<poplarsegment, poplarbud>* operator ()(TreeCompartment<poplarsegment, poplarbud>* ts)const;

};  

class CollectPhotosynthates
{
 public:
  LGMdouble operator ()(LGMdouble& init, TreeCompartment<poplarsegment, poplarbud>* ts)const;
};

class CollectLeafPhotosynthates
{
 public:
  LGMdouble& operator ()(LGMdouble& init, BroadLeaf<>* l)const;  
};

class CollectRespiration
{
 public:
  LGMdouble operator ()(LGMdouble& init, TreeCompartment<poplarsegment, poplarbud>* ts)const;
};

class CollectLeafRespiration
{
 public:
  LGMdouble& operator ()(LGMdouble& init, BroadLeaf<>* l)const; 
};

//UnitPM demonstrates the use of structures or classes with Accumulate
//To  collect  (i.e. accumulate)  data  to  a  class you  must  define
//assignment  (=)  and  add-assign   (+=)  operators  for  the  class.
//Add-assign operator is called  in each branching point by Accumulate
//summing up  results from the branches. Add-assign  is predefined for
//integral (numeric) fundamental types in C++.
class UnitPM
{
  //friend UnitPM& operator = (UnitPM& upm1, UnitPM& upm2);
 public:
  UnitPM(LGMdouble pp,LGMdouble mm):p(pp),m(mm){}
  UnitPM& operator = (const UnitPM& upm);
  UnitPM& operator += (const UnitPM& upm);
  UnitPM& operator + (const UnitPM& upm);
  LGMdouble p;
  LGMdouble m;
};

class CollectPAndM
{
 public:
  UnitPM& operator ()(UnitPM& init, TreeCompartment<poplarsegment, poplarbud>* tc)const;
};

class CollectLeafPM
{
 public:
  UnitPM& operator ()(UnitPM& init, BroadLeaf<>* l)const;
};



#endif
