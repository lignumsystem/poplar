#ifndef POPLARGROWTHALLOCATOR_H
#define POPLARGROWTHALLOCATOR_H
#include <Lignum.h>
#include <PoplarConstants.h>
  //This exception is thrown from TreeGrowthAllocator::init if P < M.
  class PoplarGrowthAllocatorException{
  public:
    PoplarGrowthAllocatorException(double p, double m)
      :P(p),M(m){}
    double getP()const{return P;}
    double getM()const{return M;}
  private:
    double P;
    double M;
  };

template <class TS, class BUD>
class PoplarGrowthAllocatorBase{
public: 
  PoplarGrowthAllocatorBase(Tree<TS,BUD>& t,double dr,double foliage_growth)
    :tree(t),P(0.0),M(0.0),Dr(dr),iWfgrowth(foliage_growth),root_requirement(0.0){}
  void init();
  double getP()const{return P;}
  double getM()const{return M;}
  //setP updates  photosynthesis. This is done e.g.  if something is
  //taken to carbon pool before allocation
  double setP(double p){
    double old_p=P;
    P=p;
    return old_p;
  }
  double getRootRequirement()const{return root_requirement;}
protected:
  Tree<TS,BUD>& tree;
  double P;//Production of the tree
  double M;//Respiration of the tree
  double Dr;//senescence from the prev�ous growth season N-1
  double iWfgrowth;//Growth of foliage in the short time step
  mutable double root_requirement;//Part of carbon that goes below ground to roots
};

//The data of type T given by the user will be passed up in the tree
//with PropagateUp
template <class TS, class BUD, class F1, class F2, class T>
class PoplarGrowthAllocatorPropagateUp:
  public PoplarGrowthAllocatorBase<TS,BUD>{
public:
  PoplarGrowthAllocatorPropagateUp(Tree<TS,BUD>& t,const T& up1,double dr,double foliage_growth, bool debug = false)
    :PoplarGrowthAllocatorBase<TS,BUD>(t,dr,foliage_growth),up(up1),verbose(debug),header(false){}
  double operator()(double l)const;
private:
  const T up;
  //Verbose debugging 
  bool verbose;
  mutable bool header;
};
//Collect  photosynthates and  respiration once  per  (and obviously
//before) growth allocation. Throw excption if P <= M
template <class TS,class BUD>
void PoplarGrowthAllocatorBase<TS,BUD>::init()
{
  P = GetValue(tree,TreeP);
  M =  GetValue(tree,TreeM);
  if (P-M <= 0.0)
    throw PoplarGrowthAllocatorException(P,M);
} 

//As for PoplarGrowthAllocator the functor is called by some iterative
//method, but instead of ForEach the  data of type T is passed up in
//the tree with PropagateUp
template  <class TS,class BUD,class F1,class F2,class T>
double PoplarGrowthAllocatorPropagateUp<TS,BUD,F1,F2,T>::operator()(double l)const
{
  DiameterGrowthData data;
  //Reinitialize the data to passed up in the tree
  T up_new = up;
  //1.Elongate or shorten segment lengths
  PropagateUp(this->tree,up_new,F1(l));
    
  //cout << "L " << l<<endl;
  //2. Simulate  diameter  growth  and  collect  sapwood  and  foliage
  //masses.
  data = AccumulateDown(this->tree,data,F2());   
      
  //3. return P-M-G where G = iWs(l) + iWfnew(l) + iWrnew(l)
  //iWs = sapwood mass: new segments + thickening
  //iWfnew = new foliage
  //iWGrowth = growth of older leaves
  if (verbose && !header){
    cout << setfill(' ') << setw(4) << "L" 
	 << setw(14) << "P" << setw(14) << "M" << setw(6) << "GA" 
	 << setw(14) << "NET" << setw(14) << "P-M-G" 
	 << setw(14) << "iWs+iWf+iWfg" 
	 << setw(14) << "iWr"
	 << setw(14) << "iWs" << setw(14) << "iWf" 
	 << setw(14) << "iWfg" << setw(16) << "iWs/(iWf+iWfg)" << setw(14) << "Dr" 
	 << setw(14) << "rc" << setw(14) << "Dr*rc"  <<endl;
    header = true;
  }
  if (verbose)
    cout << setfill(' ') << setw(4) << l
	 << setw(14) << this->P
	 << setw(14) << this->M
	 << setw(6)  << GROWTH_ALLOCATION
	 << setw(14) << GROWTH_ALLOCATION*(this->P - this->M)
	 << setw(14) <<  GROWTH_ALLOCATION*(this->P - this->M)
                                      -GetValue(data,DGWs) 
                                      -GetValue(data,DGWfnew)
                                      -this->iWfgrowth
                                      -GetValue(this->tree,LGPar)* (GetValue(data,DGWfnew)+this->iWfgrowth)
                                      -ROOT_COMPENSATION*(this->Dr)
	 << setw(14) << GetValue(data,DGWs)+GetValue(data,DGWfnew)+this->iWfgrowth
	 << setw(14) << GetValue(this->tree,LGPar)* (GetValue(data,DGWfnew)+this->iWfgrowth)
                        + ROOT_COMPENSATION*(this->Dr)
	 << setw(14) << GetValue(data,DGWs) 
	 << setw(14) << GetValue(data,DGWfnew)
	 << setw(14) << this->iWfgrowth
	 << setw(16) << GetValue(data,DGWs)/(GetValue(data,DGWfnew)+ this->iWfgrowth)
	 << setw(14) << this->Dr
	 << setw(14) << ROOT_COMPENSATION
	 << setw(14) << ROOT_COMPENSATION*(this->Dr) <<endl;

  //cout << endl;  
  this->root_requirement =  GetValue(this->tree,LGPar)* (GetValue(data,DGWfnew)+this->iWfgrowth)
    + ROOT_COMPENSATION*(this->Dr);
  return GROWTH_ALLOCATION*(this->P - this->M) 
    - GetValue(data,DGWs) 
    - GetValue(data,DGWfnew)
    - this->iWfgrowth
    - this->root_requirement;

}
#endif
