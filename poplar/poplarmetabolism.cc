#include <poplarmetabolism.h>

TreeCompartment<poplarsegment, poplarbud>* ForEachPrintCompartments::operator ()(TreeCompartment<poplarsegment, poplarbud>* tc)const
{

  if(poplarbud* bud=dynamic_cast<poplarbud*>(tc))
    {
      cout<<"hello, Bud"<<endl;
    }

  if(poplarsegment* ps =dynamic_cast<poplarsegment*>(tc))
    {
      cout<<"hello, poplarsegment"<<endl;
    }

  if(Axis<poplarsegment, poplarbud>* axis =dynamic_cast<Axis<poplarsegment, poplarbud>*>(tc))
    {
      cout<<"hello, axis"<<endl;
    }

  if(BranchingPoint<poplarsegment, poplarbud>* bp =dynamic_cast<BranchingPoint<poplarsegment, poplarbud>*>(tc))
    {
      cout<<"hello, branchingpoint"<<endl;
    }
  return tc;
}


TreeCompartment<poplarsegment, poplarbud>* DoPhotosynthesis::operator ()(TreeCompartment<poplarsegment, poplarbud>* tc)const
{
  tc->photosynthesis();
  return tc;
}

TreeCompartment<poplarsegment, poplarbud>* DoRespiration::operator ()(TreeCompartment<poplarsegment, poplarbud>* tc)const
{
  tc->respiration();
  return tc;
}

LGMdouble CollectPhotosynthates::operator ()(LGMdouble& init, TreeCompartment<poplarsegment, poplarbud>* tc)const
{
  if (poplarsegment* ps=dynamic_cast<poplarsegment*> (tc)){
    LGMdouble start = 0.0;
    list<BroadLeaf*> leaves=GetLeafList(*ps);
    init = init + accumulate(leaves.begin(), leaves.end(),start,CollectLeafPhotosynthates());
  }
  return init;
}

LGMdouble& CollectLeafPhotosynthates::operator()(LGMdouble& init, BroadLeaf* l)const
{
  init=init+GetValue(*l,P);
  return init;
}

LGMdouble CollectRespiration::operator()(LGMdouble& init,TreeCompartment<poplarsegment, poplarbud>* tc)const
{
  if (poplarsegment* ps=dynamic_cast<poplarsegment*> (tc)){
    LGMdouble start=0.0;
    list<BroadLeaf*> leaves=GetLeafList(*ps);
    init=init+accumulate(leaves.begin(), leaves.end(), start, CollectLeafRespiration());
    init=init+GetValue(*ps, M);
  }
  return init;
}

LGMdouble& CollectLeafRespiration::operator()(LGMdouble& init, BroadLeaf* l)const
{
  init=init+GetValue(*l,M);
  return init;
}


UnitPM& UnitPM::operator = (UnitPM& upm)
{
  
  p=upm.p;
  m=upm.m;
  return *this;
}


UnitPM& UnitPM::operator += (UnitPM& upm)
{
  p = p + upm.p;
  m=m+upm.m;
  return *this;
}

UnitPM& UnitPM::operator + (UnitPM& upm)
{
  p = p + upm.p;
  m=m+upm.m;
  return *this;
}

UnitPM& CollectPAndM::operator ()(UnitPM& init, TreeCompartment<poplarsegment, poplarbud>* tc)const
{
  if (poplarsegment* ps=dynamic_cast<poplarsegment*> (tc)){
    UnitPM start(0.0, 0.0);
    list<BroadLeaf*> leaves=GetLeafList(*ps);
    init+=accumulate(leaves.begin(), leaves.end(), start, CollectLeafPM());
    start.p=GetValue(*ps, P);
    start.m=GetValue(*ps, M);
    init+=start;
  }
  return init;
}
 

UnitPM& CollectLeafPM::operator()(UnitPM& init, BroadLeaf* l)const
{
  UnitPM pm(0.0, 0.0);
  pm.p=GetValue(*l,P);
  pm.m=GetValue(*l,M);
  init+=pm;
  return init;
}
