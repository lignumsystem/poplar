#include <poplar.h>
#include <poplarmetabolism.h>

// declared in poplar.h poplarsegment class.

TcData& poplarsegment::diameterGrowth(TcData& data)
{
  //New segment (age == 0) is iteratively set. 
  if (GetValue(*this, SUBAGE) > 0.0){
    const ParametricCurve& fm = GetFunction(GetTree(*this),LGMFM);
    LGMdouble Asu = GetValue(data,LGAAs); //sapwood area from above
    LGMdouble Ahown  = GetValue(*this,LGAAh);//own heartwood
    //Sapwood  requirement  of  remaining  foliage,  assume  fm  returns
    //proportion initial  foliage present, declining function  from 1 to
    //0.
    LGMdouble Asr = fm(GetValue(*this,LGAage))*GetValue(*this,LGAAs0);
    // cout<<GetValue(*this,LGAage)<<": the value of age and As0:"<<GetValue(*this,LGAAs0)<<endl; 
    //**cout<<"the value of Asr:"<<Asr<<endl;
    //possible new radius
    LGMdouble Rnew = sqrt((Asu + Ahown + Asr)/PI_VALUE);
    //compare Rnew to R, choose max
    Rnew = max(Rnew, GetValue(*this,LGAR));
    //New wood radius
    //**cout<<Rnew<<": the value of new radius"<<endl;
    SetValue(*this,LGAR, Rnew);
  } 
  //Pass down sapwood area requirement
  SetValue(data,LGAAs,GetValue(*this,LGAAs));   
  return data;
}



/*
template<>
void BroadLeaf<Triangle>::photosynthesis(const LGMdouble& p0)
{
}
*/

int PoplarLeaf::photosynthesis()
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
     double Q=GetValue((*this), LGAQabs);  //(*this).bla.Q_in;   //abs;    //Qabs-absorbed radiation
     cout<<"Qabs of leaves: "<<Q<<endl; 
     //double Q=200;  //1200;
    double a = 0.0551;
       double J =a* Q *pow((1+pow(a, 2)*pow(Q,2)/pow(Jmax, 2)), 0.5);
       double Wj = (J*Ci)/(4.5*Ci+10.5*G);
       KGC Rd=2.21;
       KGC Photo =(KGC)((1-G/Ci) * min(Wc,Wj));
       KGC A=Photo*0.000001*0.01*12*0.001*28*24*3600;  //photo * (0.000001 mol)* (0.01 m-2)*12*0.001(kg)*24*3600*days
       // KGC A=Photo-Rd;//  Rd is (umolm-2s-1), so all photosynthesishave to multifilied by leaf area (0.01m-2) and time.
         //   bla.P=A;
         (*this).bla.P=3*A;
       //  SetValue(*this, P, A);
	 //** cout <<"print the photosynthesis of segment: "<<GetValue(*this, LGAP)<<endl; 
  
  return 1;
}

void PoplarLeafPhotosynthesis::operator()(BroadLeaf<Triangle>* b)
{
  //  cout<<"   Hello, I am photosynthesis in leaf"<<endl;
  //You can do it this way: first do your computations (c.f. above) and simply
  //set  the  value:  SetValue(*b,P,RESULT);  Or call  the  method  if
  //interface (argument type) is fine
   ((PoplarLeaf*)b)->photosynthesis();
   //**  b->photosynthesis(1);
  
}

void PoplarLeafRespiration::operator()(BroadLeaf<Triangle>* bl)
{ 
  //** cout<<"   I am respiration in leaf"<<endl;
  SetValue(*bl, LGAM, 0.2*GetValue(*bl, LGAWf));
}

void poplarsegment::photosynthesis()
{
  // LGMdouble p0=1000;
  LGMdouble T=25;
  //cout<<"Hello, I am photosynthesis for pop-seg"<<endl;

  //   list<BroadLeaf<Triangle>*> leaves = GetLeafList(*this);
  list<BroadLeaf<Triangle> *> leaves = GetLeafList(*this);

  //Use functor to traverse leaf list instead of do-while loops
    for_each(leaves.begin(), leaves.end(), PoplarLeafPhotosynthesis());
  
}

void poplarsegment::respiration()
{
  LGMdouble m_hw = 0.0;
  LGMdouble init = 0.0;

  Tree<poplarsegment, poplarbud>& t = dynamic_cast<Tree<poplarsegment, poplarbud>&>(GetTree(*this));
  //cout<<"    I am respiration in segment"<<endl;
  list<BroadLeaf<Triangle>*> leaves=GetLeafList(*this);
  //leaf respiration
   for_each(leaves.begin(), leaves.end(),PoplarLeafRespiration());
   m_hw += accumulate(leaves.begin(), leaves.end(), init, CollectLeafRespiration());
  //segment respiration
  //*SetValue(*this,LGAM,1.0);
  //**ms-- maintenance respiration rate of sapwood
  //**ws--  mass of sapwood
   //** cout<<"LGPms and LGAWs:"<<GetValue(t,LGPms)<<", "<<GetValue(*this,LGAWs)<<endl;
   m_hw += GetValue(t,LGPms)*GetValue(*this,LGAWs);
   SetValue(*this,LGAM, m_hw);
}

