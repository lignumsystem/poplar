POPLARSRC = poplarmain.cc poplarmetabolism.cc poplarsegment.cc
POPLAROBJ = ${POPLARSRC:.cc=.o}

LSYS = poplar.L
LSYSSRC = poplar.cpp
LSYSOBJ = poplar.o

CCC = g++

#OPTIMIZE = -Ofast=ip28 -IPA
OPTIMIZE   = -g 

AR =  $(CCC) -ar  
ARFLAGS = -o 

SUPPRESS = #-w 1155 -w 1183

CCCFLAGS = -c  #-prelink -ptused   -ptv  #  -fullwarn 

INCLUDE = -I../c++adt/include -I../Firmament/include \
          -I../stl-lignum/include  -I../LEngine/include \
          -I../Graphics -I/usr/freeware/include -I.


LIBFLAGS = -L../c++adt/lib -L../stl-lignum/lib -L../Firmament/lib \
           -L. -L../LEngine/lib -L../Graphics -L/usr/X11R6/lib

LIB1   = libc++adt.a
LIB2   = libLGM.a
LIB3   = libsky.a
LIB4   = libL.a
LIB5   = libVisual.a
LIB6   = liblsys.a

LIBADT = -lc++adt
LIBLGM = -lLGM
LIBSKY = -lsky
LIBL   = -lL
LIBMATH  = -lm 
LIBVISUAL = -lVisual
LIBLSYS = -llsys

LIBOGL =  -lglut -lGL -lGLU -lX11 -lXext -lXmu 

LIBS     =  $(LIBVISUAL) $(LIBLSYS) $(LIBL) $(LIBLGM) $(LIBSKY) $(LIBADT) $(LIBOGL) \
            $(LIBMATH)

.SUFFIXES: .o .cc

sinclude Makedepend

gnupoplar: 
	make "CCC=g++" "CCCFLAGS=-c" "OPTIMIZE=-g" \
              "AR=ar"  "ARFLAGS=rv"  "LSYS=poplar.L" poplar

poplar: l2c $(POPLAROBJ) $(LIB1) $(LIB2) $(LIB3)  $(LIB4) $(LIB5) $(LIB6)  
	$(CCC)  -o $@ $(INCLUDE) $(OPTIMIZE) $(POPLAROBJ) $(LIBFLAGS) $(LIBS)

l2c:	
	(cd ../LEngine; make gnu)
$(LIB1):
	(cd ../c++adt; make "CCC=$(CCC)" "CCCFLAGS=$(CCCFLAGS)" \
                            "OPTIMIZE=$(OPTIMIZE)" "AR=$(AR)" "ARFLAGS=$(ARFLAGS)" $@)
$(LIB2):
	(cd ../stl-lignum; make "CCC=$(CCC)" "CCCFLAGS=$(CCCFLAGS)" \
                                "OPTIMIZE=$(OPTIMIZE)" "AR=$(AR)" "ARFLAGS = $(ARFLAGS)" $@)
$(LIB3):
	(cd ../Firmament; make "CCC=$(CCC)" "CCCFLAGS=$(CCCFLAGS)" \
         "OPTIMIZE=$(OPTIMIZE)"  "AR=$(AR)"  "ARFLAGS = $(ARFLAGS)" $@)

$(LIB4):
	(cd ../LEngine; make gnu) 

$(LIB5):
	(cd ../Graphics; make "CCC=$(CCC)" "CCCFLAGS=$(CCCFLAGS)" \
         "OPTIMIZE=$(OPTIMIZE)"  "AR=$(AR)"  "ARFLAGS = $(ARFLAGS)" $@)

$(LIB6):
	../LEngine/bin/l2c  $(LSYS) $(LSYSSRC) 
	$(CCC) $(CCCFLAGS) $(OPTIMIZE) $(INCLUDE)  $(LSYSSRC) 
	$(AR) $(ARFLAGS) $(@) $(LSYSOBJ)    

.cc.o: 
	$(CCC) $(OPTIMIZE) $(CCCFLAGS) $(INCLUDE)  $< -o $@

html:
	enscript -E --color -Whtml --toc -p$(PROGFILES) ./include/*.h ./*/*.cc
changelog:
	rm -rf ChangeLog
	rcs2log . > ChangeLog
clean:
	rm -rf *.o  Makedepend liblsys.a core ii_files
distclean: clean
	rm -rf  sym2d $(LIB4) Makedepend
	(cd ../Graphics; make distclean)
	(cd ../LEngine/L2C; make distclean)

depend:
	(cd ../Graphics; make "CCC=$(CCC)"  depend)
	(cd ../LEngine/L2C; make "CCC=$(CCC)"  depend)
	$(CCC) -M $(INCLUDE) $(SYM2DSRC)   > Makedepend
