#include <poplar.h>

void PoplarLeafPhotosynthesis::operator()(BroadLeaf<Ellipse>* b)
{
  //cout<<"   Hello, I am photosynthesis in leaf"<<endl;
  SetValue(*b,P,5.0);
}

void PoplarLeafRespiration::operator()(BroadLeaf<Ellipse>* bl)
{ 
  //cout<<"   I am respiration in leaf"<<endl;
  SetValue(*bl, M, 3.0);
}

void poplarsegment::photosynthesis()
{
  // cout<<"Hello, I am a segment photosynthesis"<<endl;
  list<BroadLeaf<Ellipse>*> leaves = GetLeafList(*this);
  for_each(leaves.begin(), leaves.end(), PoplarLeafPhotosynthesis());

}

void poplarsegment::respiration()
{
  //cout<<"    I am respiration in segment"<<endl;
  list<BroadLeaf<Ellipse>*> leaves=GetLeafList(*this);
  //leaf respiration
  for_each(leaves.begin(), leaves.end(),PoplarLeafRespiration());
  //segment respiration
  SetValue(*this,M,1.0);
}
