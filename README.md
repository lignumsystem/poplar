# Cottonwood project

This cottonwood project may contain useful
components like Farquhar photosynthesis model
and short time step weather data (weatherdata,dat).

## To compile type

  qmake -r poplar.pro
  make

## To compile with optimization on 
(faster, no debug) type

  qmake -r "CONFIG+=release" poplar.pro
  make

## To run poplar type

  ./poplar -xml poplar.xml

where poplar.xml is the optional tree output file.

## To remove all compilation work type

  make distclean





