#ifndef POPLARGROWTHALLOCATOR_H
#define POPLARGROWTHALLOCATOR_H
#include <Lignum.h>
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
    PoplarGrowthAllocatorBase(Tree<TS,BUD>& t)
      :tree(t),P(0.0),M(0.0){}
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
  protected:
    Tree<TS,BUD>& tree;
    double P;//Production of the tree
    double M;//Respiration of the tree
  };

//The data of type T given by the user will be passed up in the tree
//with PropagateUp
template <class TS, class BUD, class F1, class F2, class T>
class PoplarGrowthAllocatorPropagateUp:
  public PoplarGrowthAllocatorBase<TS,BUD>{
public:
  PoplarGrowthAllocatorPropagateUp(Tree<TS,BUD>& t,const T& up1)
    :PoplarGrowthAllocatorBase<TS,BUD>(t),up(up1){}
  double operator()(double l)const;
private:
  const T up;
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
    
  //2. Simulate  diameter  growth  and  collect  sapwood  and  foliage
  //masses.
  data = AccumulateDown(this->tree,data,F2());   
      
  //3. return P-M-G where G = iWs(l) + iWfnew(l) + iWrnew(l)
  //iWs = sapwood mass: new segments + thickening
  //iWfnew = new foliage
  //iWrnew = new roots = ar*iWfnew
  //  return (0.875*(this->P - this->M) - GetValue(data,DGWs) - GetValue(data,DGWfnew)- GetValue(this->tree,LGPar)* GetValue(data,DGWfnew));
  //  return (0.875*(this->P - this->M) - GetValue(data,DGWs) - GetValue(data,DGWfnew)- (0.3*(GetValue(data,DGWs)+GetValue(this->tree, LGAWs))-GetValue((this->tree), TreeWr)));
  return (0.875*(this->P - this->M) - GetValue(data,DGWs) - GetValue(data,DGWfnew)- 0.3 * GetValue(data,DGWs));

}
#endif