#include <cmath>
#include <iostream>
#include <iomanip>
using namespace std;
int main()
{
  double const T = 25.0; //temperature of leaf.l
  double Q = 0.0; //Absorbed radiation

  double const Ca =380.0;  //MS: Table 2 (350) 360.0
  double const Dj = 200.0e3;//MS: A3-10
  double const Jmax25 = 88.01; //(86.75);//MS: Table 2
  double const Kc = 460.0;//MS: Table 2
  double const Ko = 330.0;//MS: Table 2
  double const Oa = 210.0;//MS: Table 2
  double const Q10 = 1.78;//MS: A3-12
  double const Rd25 = 1.09; //(2.21); //MS: Table 2
  double const R = 8.314; //MS: A3-5
  double const Sj = 650.0; //MS: A3-10
  double const Vcmax25 = 42.12; //MS: Table 2 (30.83)
  
//   cout << left << setw(6) << setfill(' ')  << "T" 
//        << setw(6) << "Q" 
//        << setw(12) << "Rd"
//        << setw(16) << "P, (1-G/Ci)Vc"
//        << setw(14)  << "Al, P-Rd" 
//        << endl;

  for (Q = 0.0; Q <= 800; Q = Q + 1.0){
    //Implementing Appendix 3 in the manuscript
    double Ci = 0.7*Ca*((1.6740-6.1294e-2*T+1.1688e-3*pow(T,2.0)-8.8741e-6*pow(T,3.0))/0.73547);//MS: A3-2
    double Oi = Oa*((4.700e-2-1.3087e-3*T+2.5603e-5*pow(T,2.0)-2.1441e-7*pow(T,3.0))/2.6934e-2); //MS: A3-4
    double Vcmax = Vcmax25*exp((T-25.0)*68000.0/(R*298.0*(273.0+T))); //MS: A3-5
    double Wc = (Ci*Vcmax)/(Ci+Kc*(1.0+Oi/Ko)); //MS: A3-7
    double exp1 = exp(((T-25.0)*65330.0)/(298.0*R*(T+273.0)));
    double exp2 = exp((298.0*Sj-Dj)/(298.0*R));
    double exp3 = exp(((T+273.0)*Sj-Dj)/(R*(T+273.0)));
    double Jmax = Jmax25*exp1*((1.0+exp2)/(1.0+exp3));//MS: A3-10
    double J = (Jmax*Q)/(Q+2.1*Jmax); //MS: A3-9
    double Vomax = 0.21*Vcmax; //MS: A3-6
    double G = (0.5*Vomax*Kc*Oi)/(Vcmax*Ko);//MS: A3-3
    double Wj = J/(4.5+(10.5*G/Ci)); //MS: A3-8
    double Rd = Rd25*pow(Q10,(T-25.0)/10.0); //MS: A3-12
    double Vc = min(Wc,Wj); //MS: A3-11
    double AlGross = (1-G/Ci)*Vc;
    double Al = (1-G/Ci)*Vc-Rd; //MS: A3-1
//     cout << left << setw(6) << setfill(' ') << T
// 	 << setw(6) << Q
// 	 << setw(12) << Rd
// 	 << setw(16) << AlGross
// 	 << setw(14) << Al
// 	 << endl;
  }
   for (Q = 0.0; Q <= 800; Q = Q + 1.0){
    //Implementing Appendix 3 in the manuscript
    double Ci = 0.7*Ca*((1.6740-6.1294e-2*T+1.1688e-3*pow(T,2.0)-8.8741e-6*pow(T,3.0))/0.73547);//MS: A3-2
    double Oi = Oa*((4.700e-2-1.3087e-3*T+2.5603e-5*pow(T,2.0)-2.1441e-7*pow(T,3.0))/2.6934e-2); //MS: A3-4
    double Vcmax = Vcmax25*exp((T-25.0)*68000.0/(R*298.0*(273.0+T))); //MS: A3-5
    double Wc = (Ci*Vcmax)/(Ci+Kc*(1.0+Oi/Ko)); //MS: A3-7
    double exp1 = exp(((T-25.0)*65330.0)/(298.0*R*(T+273.0)));
    double exp2 = exp((298.0*Sj-Dj)/(298.0*R));
    double exp3 = exp(((T+273.0)*Sj-Dj)/(R*(T+273.0)));
    double Jmax = Jmax25*exp1*((1.0+exp2)/(1.0+exp3));//MS: A3-10
    double J = (Jmax*Q)/(Q+2.1*Jmax); //MS: A3-9
    double Vomax = 0.21*Vcmax; //MS: A3-6
    double G = (0.5*Vomax*Kc*Oi)/(Vcmax*Ko);//MS: A3-3
    double Wj = J/(4.5+(10.5*G/Ci)); //MS: A3-8
    double Rd = Rd25*pow(Q10,(T-25.0)/10.0); //MS: A3-12
    double Vc = min(Wc,Wj); //MS: A3-11
    double AlGross = (1-G/Ci)*Vc;
    double Al = (1-G/Ci)*Vc-Rd; //MS: A3-1
    cout << left << setw(6) << setfill(' ') << Q
	 << setw(12) << Al/8.61435
	 << endl;
  }

}  
