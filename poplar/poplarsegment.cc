#include <poplar.h>


//void BroadLeaf<Triangle>::photosynthesis(const LGMdouble& p0)
//{  
//  cout << "poplarleaf photosynthesis "<< endl; 
//    bla.P = p0 *(bla.Qabs);
//}


void BroadLeaf<Triangle>::photosynthesis(const LGMdouble& p0)
{
  // cout << "poplarleaf photosynthesis "<< endl;
    LGMdouble T = 25; //temperature of leaf.
    double Ca=360, Kc=460, Ko=330;
    double Ci=0.7 * Ca * ((1.674-0.061294*T+0.0011688*pow(T,2)-0.0000088741*pow(T,3))/0.73547);
   double Oi=210*((0.047-0.0013087*T+0.000025603*pow(T, 2)-0.00000021441*pow(T,3))/0.026934);
    double Vcmax=57.15;
    double Vomax=0.21*Vcmax;
    double Wc=(Vcmax*Ci)/(Ci+Kc*(1+Oi/Ko));
    double G = (0.5*Vomax*Kc*Oi)/(Vcmax*Ko);

    double Jmax=105;
    double Q=bla.Qabs;
       double a = 0.0551;
       double J =a* Q *pow((1+pow(a, 2)*pow(Q,2)/pow(Jmax, 2)), 0.5);
       double Wj = (J*Ci)/(4.5*Ci+10.5*G);
       KGC Rd=2.21;
       KGC P =(KGC)((1-G/Ci) * min(Wc,Wj));
       KGC A=P-Rd;
       bla.P=A;
	cout << bla.P << "is bla.P" <<endl;  
	// SetValue(bla, P, A);	
}


void PoplarLeafPhotosynthesis::operator()(BroadLeaf<Triangle>* b)
{
  // cout<<"   Hello, I am photosynthesis in leaf"<<endl;
  //You can do it this way: first do your computations (c.f. above) and simply
  //set  the  value:  SetValue(*b,P,RESULT);  Or call  the  method  if
  //interface (argument type) is fine
 b->photosynthesis(1.0);
}

void PoplarLeafRespiration::operator()(BroadLeaf<Triangle>* bl)
{ 
  cout<<"   I am respiration in leaf"<<endl;
  SetValue(*bl, M, 3.0);
}

void poplarsegment::photosynthesis()
{
  // LGMdouble p0=1000;
  LGMdouble T=25;
  //   cout<<"Hello, I am photosynthesis for pop-seg"<<endl;

  // list<BroadLeaf<Triangle>*>& leaves = GetLeafList(*this);
   list<BroadLeaf<Triangle>*> leaves = GetLeafList(*this);
 

  //Use functor to traverse leaf list instead of do-while loops
    for_each(leaves.begin(), leaves.end(), PoplarLeafPhotosynthesis());
  
}

void poplarsegment::respiration()
{
  //cout<<"    I am respiration in segment"<<endl;
  list<BroadLeaf<Triangle>*> leaves=GetLeafList(*this);
  //leaf respiration
  for_each(leaves.begin(), leaves.end(),PoplarLeafRespiration());
  //segment respiration
  SetValue(*this,M,1.0);
}

