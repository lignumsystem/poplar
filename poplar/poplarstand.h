#ifndef COPYDUMPPOPLARTREE_H
#define COPYDUMPPOPLARTREE_H

#include <Lignum.h>
#include <VoxelSpace.h>

extern double temperature;

//For a sequence (vector) of tree  locations move and dump the tree to
//specified locations in the voxel space.
template <class TS, class BUD>
class CopyDumpPoplarTree{
public:
  CopyDumpPoplarTree(Tree<TS,BUD>& t, VoxelSpace& vs, int n):tree(t),voxel_space(vs),num_parts(n){}
  void operator()(pair<double,double>& p)const{
    //Move the tree to next location 
    const Point& point = GetPoint(tree);
    MoveTree<TS, BUD> move(Point(p.first-point.getX(),
				 p.second-point.getY(),0.0),
			   tree); 
     ForEach(tree, move);
    //dump the poplar tree into the voxelspace
    DumpHwTree(voxel_space,tree); 
   }
private:
  Tree<TS,BUD>& tree;
  VoxelSpace& voxel_space;
  int num_parts;
};

#endif
