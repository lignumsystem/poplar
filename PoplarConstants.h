#ifndef POPLARCONSTANTS_H
#define POPLARCONSTANTS_H
const int AZIMUTH = 36;
const int INCLINATION = 18;
const double MIN_SEGMENT_LENGTH = 0.01;
const double LEAF_GROWTH = 0.0000055;
const double MAX_LEAF =    0.007;
const double POPLAR_SAPWOOD_ADDITIONAL_RESPIRATION = 1.0;
const double POPLAR_LEAF_AREA = MAX_LEAF; //0.1*0.01;
const double PETIOLE_LENGTH = 0.04;
const double LEAF_BASE = 0.01;
const double LEAF_HEIGHT = 0.01;
const double INITIAL_LR = 0.008;
const double QIN_TO_QABS_CONVERSION_EFFICIENCY = 0.8;
const double GROWTH_RESPIRATION = 12.5/100.0;//12.5/100.0;
const double GROWTH_ALLOCATION = 1.0-GROWTH_RESPIRATION;//0.875
const double PIPE_MODEL_CONSTANT = 1.0;
const double ROOT_SAPWOOD_REQUIREMENT = 0.5;
const double ROOT_TURNOVER = 0.25;//medium time step allocation
const double ROOT_COMPENSATION = 0.25;//Check LGPsr in Tree.txt!!! 
//Four structure updates per growing season
const double NUMBER_OF_STRUCTURE_UPDATES = 4.0; 
//LGPsr = 0.3 root senescence annual time step

//FGRAVELIUS an FVIGOUR in SetSegmentLength (poplar.h)
inline double FGRAVELIUS(double go)
{
  if (go == 0.0){
    cout << "FGRAVELIUS ERROR: main axis must 1 " << go <<endl; 
  }
  return 1.0-log10(go);
}
inline double FVIGOUR(double vi)
{ //0.18 + 0.82*vi
  return 0.7 + 0.3*vi;
}


#endif
