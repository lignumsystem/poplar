//Your  L-system will be similar to this. See 
//LEngine README for user caveats, e.g. please do not
//use C++ keywords in comments.
#include <mathsym.h>
#include <Uniform.h>
#include <Gauss.h> 
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
//The declare the modules your need
 const ModuleIdType F_id = 2;
 const ModuleIdType B_id = 3;
 const ModuleIdType Pitch_id = 4;
 const ModuleIdType Turn_id = 5;
 const ModuleIdType Roll_id = 6;

//Define the derivation length
int DerivationLength() { return  15;}

//Define the Start corresponding to the axiom
void Start()
{
  { Produce((ModuleIdType)(B_id));Produce((double)(0.0));Produce((double)(4.0));Produce((double)(0.0));Produce((ModuleIdType)(B_id));}
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
// the symbol rewrites to itself. "produce" denotes
//the rewriting and corresponds to "return" in C++ 
 void _P1(double leaf,double alive,double order)
{
  if (order == 0){
   int seed = 1111111;
   double r = g1(10.0, 1.0, seed);
   double I = g2(36.0, 5.0, seed);
   double A = g3(167.0, 105.0, seed);
  // cout << "r " << r << " I " << I << " A " << A << endl;
   { Produce((ModuleIdType)(F_id));Produce((double)(r/100.0));Produce((ModuleIdType)(F_id)); Produce((ModuleIdType)(SB_id)); Produce((ModuleIdType)(Roll_id));Produce((double)(A*PI_VALUE/180.0));Produce((ModuleIdType)(Roll_id)); Produce((ModuleIdType)(Pitch_id));Produce((double)((90-I)*PI_VALUE/180));Produce((ModuleIdType)(Pitch_id)); Produce((ModuleIdType)(B_id));Produce((double)(1.0));Produce((double)( alive));Produce((double)(order+1.0));Produce((ModuleIdType)(B_id)); Produce((ModuleIdType)(EB_id)); 
           Produce((ModuleIdType)(B_id));Produce((double)(0.0));Produce((double)( alive));Produce((double)(order));Produce((ModuleIdType)(B_id));}
  }
 else if  (order == 1 && alive>0){
   int seed = 1111111;
   double r = g1(10.0, 1.0, seed);
   double A = 180.0*(u(seed)-0.5);
   double I =100.0*(u(seed)-0.5);
  // cout << "r " << r << " I " << I << " A " << A << endl;
   { Produce((ModuleIdType)(F_id));Produce((double)(r/100.0));Produce((ModuleIdType)(F_id));  Produce((ModuleIdType)(SB_id)); Produce((ModuleIdType)(Turn_id));Produce((double)(A*PI_VALUE/180.0));Produce((ModuleIdType)(Turn_id)); Produce((ModuleIdType)(Pitch_id));Produce((double)(I*PI_VALUE/180.0));Produce((ModuleIdType)(Pitch_id)); Produce((ModuleIdType)(B_id));Produce((double)(1.0));Produce((double)( alive));Produce((double)(order+1));Produce((ModuleIdType)(B_id)); Produce((ModuleIdType)(EB_id)); 
           Produce((ModuleIdType)(B_id));Produce((double)(0.0));Produce((double)( alive-1));Produce((double)(order));Produce((ModuleIdType)(B_id));}
  }
 else if  (order == 2 && alive){
   int seed = 1111111;
   double r = g1(10.0, 1.0, seed);
   double A = 180.0*(u(seed)-0.5);
   double I =100.0*(u(seed)-0.5);
  // cout << "r " << r << " I " << I << " A " << A << endl;
   { Produce((ModuleIdType)(F_id));Produce((double)(r/100.0));Produce((ModuleIdType)(F_id));  Produce((ModuleIdType)(SB_id)); Produce((ModuleIdType)(Turn_id));Produce((double)(A*PI_VALUE/180.0));Produce((ModuleIdType)(Turn_id)); Produce((ModuleIdType)(Pitch_id));Produce((double)(I*PI_VALUE/180.0));Produce((ModuleIdType)(Pitch_id)); Produce((ModuleIdType)(B_id));Produce((double)(1.0));Produce((double)( alive));Produce((double)(order+1));Produce((ModuleIdType)(B_id)); Produce((ModuleIdType)(EB_id)); 
           Produce((ModuleIdType)(B_id));Produce((double)(0.0));Produce((double)( alive-1));Produce((double)(order));Produce((ModuleIdType)(B_id));}
  }
 else
   { Produce((ModuleIdType)(B_id));Produce((double)(leaf));Produce((double)( alive));Produce((double)(order));Produce((ModuleIdType)(B_id));}


}

//This is a ToDO for Jari: interpretation typically
//defines the graphical visualization of symbols. But
//we visualize LIGNUM and thus this is practically 
//unnecessary for us. However, "lc2" cannot compile
//L-files unless you have one  interpretation   



 void _I2(double s)
{
  ;
}

//Finally, "close" the "namespace"
 

void _PC1(const CallerData* pCD)
{
const char* pArg;
pArg = pCD->Strct.pArg(0);
double p0;
memcpy(&p0, pArg, sizeof(double));
pArg += sizeof(double);
double p1;
memcpy(&p1, pArg, sizeof(double));
pArg += sizeof(double);
double p2;
memcpy(&p2, pArg, sizeof(double));
_P1(p0,p1,p2);
}


void _IC2(const CallerData* pCD)
{
const char* pArg;
pArg = pCD->Strct.pArg(0);
double p0;
memcpy(&p0, pArg, sizeof(double));
_I2(p0);
}

static const ProductionPrototype proto[] =
{
	{
		{
			{ 0 }, 0
		},
		{
			{ B_id }, 1
		},
		{
			{ 0 }, 0
		},
		_PC1
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
		_IC2
	}
};
static const ModuleData moduleData[] =
{
{ "SB",  0 },
{ "EB",  0 },
{ "F", sizeof(double)},
{ "B", sizeof(double)+sizeof(double)+sizeof(double)},
{ "Pitch", sizeof(double)},
{ "Turn", sizeof(double)},
{ "Roll", sizeof(double)}
};


const ModuleData* GetModuleData(int i)
{ return &(moduleData[i]); }


int NumOfModules()
{ return 7; }

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
int NumOfIgnored() { return 0; }
ModuleIdType GetIgnored(int) { return -1; }
} //closing namespace
