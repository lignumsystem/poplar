//Your  L-system will be similar to this. See 
//LEngine README for user caveats, e.g. please do not
//use C++ keywords in comments.
#include <mathsym.h>
#include <Uniform.h>
#include <Gauss.h> 
#include <Bernoulli.h>
#include <poplar.h>
using namespace cxxadt;

//First include lengine.h file for some necessary 
//declarations and definitions 
#include <lengine.h>

//Then wrap your L-system into a "namespace" so that you
//can have several tree sepecies in a program 
 namespace poplar{ 


//lsys.h impelemnts the rewriting
#include <lsys.h>

//Then comes the model. This file is compiled to C++ so 
//you can first have some C++ declarations and definitions 

Uniform u(-1);
Gauss g1(-1);
Gauss g2(-1);
Gauss g3(-1); 
Bernoulli ber( -1);


//main stem branching angle
const double ba=60.0 * PI_VALUE/180.0;
const double bendUp=10.0* PI_VALUE/180.0;
const double maxIncl = 8.0; 



//The declare the modules your need
  const ModuleIdType F_id = 2;
 const ModuleIdType B_id = 3;
 const ModuleIdType Pitch_id = 4;
 const ModuleIdType Turn_id = 5;
 const ModuleIdType Roll_id = 6;
 const ModuleIdType Split_id = 7;
static const ModuleIdType __ignoreArr[] = {  Roll_id, Pitch_id, Turn_id,0 };
int NumOfIgnored()
{ return sizeof(__ignoreArr)/sizeof(__ignoreArr[0])-1; }
ModuleIdType GetIgnored(int i)
{ return __ignoreArr[i]; }


//Define the derivation length
int DerivationLength() { return  30;}

//Define the Start corresponding to the axiom
void Start()
{ 
  int seed=time(0);
  srand(seed);
  PoplarBudData d(ALIVE, 1.0, 0.0, 1.0);   
  { Produce((ModuleIdType)(F_id));Produce((double)(0.8));Produce((int)( 0));Produce((ModuleIdType)(F_id)); Produce((ModuleIdType)(B_id));Produce((PoplarBudData)(d));Produce((ModuleIdType)(B_id));}          
}

//You can optionally have the following modules:
//StartEach is evaluated before each derivation and 
//typically e.g. initializes some variables  
void StartEach()
{
}

//EndEach is similar to StartEach but is evaluated 
//after each derivation
void EndEach()
{
}

//End is evaluated after the last derivation and
//typically does some clean up work e.g. deletes
//dynamically created variables. 
void End()
{
}

//Here are the rewritings. If there is no rewriting 
//the symbol rewrites to itself. "produce" denotes
//the rewriting and corresponds to "return" in C++

   void _P1(double s,int od,PoplarBudData d)
{
  PoplarBudData dead(DEAD, 1.0, GetValue(d, LGAomega), 1.0);
  PoplarBudData dorm(DORMANT, 1.0, GetValue(d, LGAomega), 1.0);
  PoplarBudData d1(GetValue(d, LGAstate), 1.0, GetValue(d, LGAomega), 1.0);
  PoplarBudData d2(GetValue(d, LGAstate), 1.0, GetValue(d, LGAomega)+1, 1.0);

  LGMdouble o=GetValue(d, LGAomega);
  LGMdouble st = GetValue(d, LGAstate);

//Bend branches upwards

  PositionVector direct = GetDirection(d);
  direct.normalize();
  double fac = 0.0;
  if(asin(direct.getZ())<maxIncl)
  {
    PositionVector up(0.0, 0.0, 1.0);
    PositionVector cr = Cross(up, direct);
    fac = cr.length();
    fac *= bendUp;
  }

 if (GetValue(d, LGAstate)==DEAD)
      { Produce((ModuleIdType)(B_id));Produce((PoplarBudData)(dead));Produce((ModuleIdType)(B_id));}
  else if (GetValue(d, LGAstate)==DORMANT)
      { Produce((ModuleIdType)(B_id));Produce((PoplarBudData)(dorm));Produce((ModuleIdType)(B_id));}
  else {
    int seed = time(NULL);
   double r = g1(5.5, 3.0, seed);  //for trees in Alley Cropping
   double I = g2(36.0, 5.0, seed); //  double I = g2(45.0, 21.0, seed);

   { Produce((ModuleIdType)(F_id));Produce((double)(r/10.0));Produce((int)( o));Produce((ModuleIdType)(F_id)); Produce((ModuleIdType)(Split_id)); Produce((ModuleIdType)(B_id));Produce((PoplarBudData)(d1));Produce((ModuleIdType)(B_id));}

  }

}


   void _P2(double s,int o)
{
   PoplarBudData dorm(DORMANT, 1.0, o+1, 1.0);
   PoplarBudData d1(1.0, 1.0, o+1, 1.0);
   PoplarBudData d2(1.0, 1.0, o+1, 1.0);

   double A  = rand()%360;  //360.0*(u(seed++)-0.5);
   double A1 = rand()%360;  //360.0*(u(seed++)-0.5);
   double A2 = rand()%360;   //45-90;  //360.0*(u(seed++)-0.5);
   double A3 = rand()%360;   //45-90;  //360.0*(u(seed++)-0.5);

   double I  = rand()%30+30;  //100.0*(u(seed++)-0.5);
   double I1 = rand()%30+30;  //100.0*(u(seed++)-0.5);
   double I2 = rand()%75;  //-180;  //100.0*(u(seed++)-0.5);
   double I3 = rand()%75;   //-180;  //100.0*(u(seed++)-0.5);

  if (s<0.05){
    { Produce((ModuleIdType)(F_id));Produce((double)(s));Produce((int)( o));Produce((ModuleIdType)(F_id));}
}
else if (0.05<=s<0.1)
{
  cout<<s<<" :value of s(o=0)"<<endl;
  { Produce((ModuleIdType)(F_id));Produce((double)(s/2));Produce((int)( o));Produce((ModuleIdType)(F_id)); Produce((ModuleIdType)(SB_id)); Produce((ModuleIdType)(Roll_id));Produce((double)(A*PI_VALUE/180.0));Produce((ModuleIdType)(Roll_id)); Produce((ModuleIdType)(Pitch_id));Produce((double)(I*PI_VALUE/180));Produce((ModuleIdType)(Pitch_id)); Produce((ModuleIdType)(B_id));Produce((PoplarBudData)(dorm));Produce((ModuleIdType)(B_id)); Produce((ModuleIdType)(EB_id));
        Produce((ModuleIdType)(F_id));Produce((double)(s/2));Produce((int)( o));Produce((ModuleIdType)(F_id)); }
}
else
{
{ Produce((ModuleIdType)(F_id));Produce((double)(s/3));Produce((int)( o));Produce((ModuleIdType)(F_id)); Produce((ModuleIdType)(SB_id)); Produce((ModuleIdType)(Roll_id));Produce((double)(A*PI_VALUE/180.0));Produce((ModuleIdType)(Roll_id)); Produce((ModuleIdType)(Pitch_id));Produce((double)(I*PI_VALUE/180));Produce((ModuleIdType)(Pitch_id)); Produce((ModuleIdType)(B_id));Produce((PoplarBudData)(dorm));Produce((ModuleIdType)(B_id)); Produce((ModuleIdType)(EB_id));
        Produce((ModuleIdType)(F_id));Produce((double)(s/3));Produce((int)( o));Produce((ModuleIdType)(F_id)); Produce((ModuleIdType)(SB_id)); Produce((ModuleIdType)(Roll_id));Produce((double)(A1*PI_VALUE/180.0));Produce((ModuleIdType)(Roll_id)); Produce((ModuleIdType)(Pitch_id));Produce((double)(I1*PI_VALUE/180));Produce((ModuleIdType)(Pitch_id)); Produce((ModuleIdType)(B_id));Produce((PoplarBudData)(dorm));Produce((ModuleIdType)(B_id)); Produce((ModuleIdType)(EB_id));
        Produce((ModuleIdType)(F_id));Produce((double)(s/3));Produce((int)( o));Produce((ModuleIdType)(F_id)); }
}

}


void _P3()
{
  { }
}

 void _P4(double s,int o)
{
  { Produce((ModuleIdType)(F_id));Produce((double)(s));Produce((int)( o));Produce((ModuleIdType)(F_id));}
}

//This is a ToDO for Jari: interpretation typically
//defines the graphical visualization of symbols. But
//we visualize LIGNUM and thus this is practically 
//unnecessary for us. However, "lc2" cannot compile
//L-files unless you have one  interpretation   



  void _I5(double s,int o)
{
  ;
}

//Finally, "close" the "namespace"
 



void _PC1(const CallerData* pCD)
{
const char* pArg;
pArg = pCD->LCntxt.pArg(0);
double p0;
memcpy(&p0, pArg, sizeof(double));
pArg += sizeof(double);
int p1;
memcpy(&p1, pArg, sizeof(int));
pArg = pCD->Strct.pArg(0);
PoplarBudData p2;
memcpy(&p2, pArg, sizeof(PoplarBudData));
_P1(p0,p1,p2);
}


void _PC2(const CallerData* pCD)
{
const char* pArg;
pArg = pCD->Strct.pArg(0);
double p0;
memcpy(&p0, pArg, sizeof(double));
pArg += sizeof(double);
int p1;
memcpy(&p1, pArg, sizeof(int));
_P2(p0,p1);
}


void _PC3(const CallerData* pCD)
{
_P3();
}


void _PC4(const CallerData* pCD)
{
const char* pArg;
pArg = pCD->Strct.pArg(0);
double p0;
memcpy(&p0, pArg, sizeof(double));
pArg += sizeof(double);
int p1;
memcpy(&p1, pArg, sizeof(int));
_P4(p0,p1);
}


void _IC5(const CallerData* pCD)
{
const char* pArg;
pArg = pCD->Strct.pArg(0);
double p0;
memcpy(&p0, pArg, sizeof(double));
pArg += sizeof(double);
int p1;
memcpy(&p1, pArg, sizeof(int));
_I5(p0,p1);
}

static const ProductionPrototype proto[] =
{
	{
		{
			{ F_id }, 1
		},
		{
			{ B_id }, 1
		},
		{
			{ 0 }, 0
		},
		_PC1
	},
	{
		{
			{ 0 }, 0
		},
		{
			{ F_id }, 1
		},
		{
			{ Split_id }, 1
		},
		_PC2
	},
	{
		{
			{ 0 }, 0
		},
		{
			{ Split_id }, 1
		},
		{
			{ 0 }, 0
		},
		_PC3
	},
	{
		{
			{ 0 }, 0
		},
		{
			{ F_id }, 1
		},
		{
			{ 0 }, 0
		},
		_PC4
	}
};
static const ProductionPrototype iproto[] =
{
	{
		{
			{ 0 }, 0
		},
		{
			{ F_id }, 1
		},
		{
			{ 0 }, 0
		},
		_IC5
	}
};
static const ModuleData moduleData[] =
{
{ "SB",  0 },
{ "EB",  0 },
{ "F", sizeof(double)+sizeof(int)},
{ "B", sizeof(PoplarBudData)},
{ "Pitch", sizeof(double)},
{ "Turn", sizeof(double)},
{ "Roll", sizeof(double)},
{ "Split",  0 }
};


const ModuleData* GetModuleData(int i)
{ return &(moduleData[i]); }


int NumOfModules()
{ return 8; }

int NumOfProductions()
{ return sizeof(proto)/sizeof(proto[0]); }
const ProductionPrototype& GetProductionPrototype(int i)
{ return proto[i]; }

int NumOfIProductions()
{ return sizeof(iproto)/sizeof(iproto[0]); }
const ProductionPrototype& GetIProductionPrototype(int i)
{ return iproto[i]; }
int NumOfConsidered() { return 0; }
ModuleIdType GetConsidered(int) { return -1; }
} //closing namespace
