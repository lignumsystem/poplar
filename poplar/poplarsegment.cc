#include <poplar.h>


template<>
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
    // double Q=bla.Qabs;    //Qabs-absorbed radiation
    double Q=1200;
    double a = 0.0551;
       double J =a* Q *pow((1+pow(a, 2)*pow(Q,2)/pow(Jmax, 2)), 0.5);
       double Wj = (J*Ci)/(4.5*Ci+10.5*G);
       KGC Rd=2.21;
       KGC Photo =(KGC)((1-G/Ci) * min(Wc,Wj));
       KGC A=Photo;
       // KGC A=Photo-Rd;//  Rd is (umolm-2s-1), so all photosynthesishave to multifilied by leaf area and time.
         bla.P=A;
	 // SetValue(*this, P, A);
	 // cout <<Q<<"for Q"<< bla.P << "is bla.P______________" <<endl; 
}


void PoplarLeafPhotosynthesis::operator()(BroadLeaf<Triangle>* b)
{
   cout<<"   Hello, I am photosynthesis in leaf"<<endl;
  //You can do it this way: first do your computations (c.f. above) and simply
  //set  the  value:  SetValue(*b,P,RESULT);  Or call  the  method  if
  //interface (argument type) is fine
  b->photosynthesis(1.0);
}

void PoplarLeafRespiration::operator()(BroadLeaf<Triangle>* bl)
{ 
  cout<<"   I am respiration in leaf"<<endl;
  SetValue(*bl,LGAM, 3.0);
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
  LGMdouble m_hw = 0.0;

  Tree<poplarsegment, poplarbud>& tt = dynamic_cast<Tree<poplarsegment, poplarbud>&>(GetTree(*this));
  Tree<poplarsegment, poplarbud>& t = dynamic_cast<Tree<poplarsegment, poplarbud>&>(GetTree(*this));
  //cout<<"    I am respiration in segment"<<endl;
  list<BroadLeaf<Triangle>*> leaves=GetLeafList(*this);
  //leaf respiration
  // for_each(leaves.begin(), leaves.end(),PoplarLeafRespiration());
  //segment respiration
  // SetValue(*this,LGAM,1.0);


  //**ms-- maintenance respiration rate of sapwood
  //**ws--  mass of sapwood
   m_hw += GetValue(t,ms)*GetValue(*this,LGAWs);
   SetValue(*this,LGAM, m_hw);
   // cout<<"  "<< GetValue(t,ms)*GetValue(*this,Ws)<<endl;
}

