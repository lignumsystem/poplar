POPLARSRC = poplarmain.cc poplarmetabolism.cc poplarsegment.cc
POPLAROBJ = ${POPLARSRC:.cc=.o}

LSYS = poplar.L ErythrinaRoots.L
SRC = ${LSYS:.L=.cpp}
OBJ = ${SRC:.cpp=.o}

CCC = g++

#OPTIMIZE = -Ofast=ip28 -IPA
OPTIMIZE   = -g 

AR =  $(CCC) -ar  
ARFLAGS = -o 

SUPPRESS = #-w 1155 -w 1183

CCCFLAGS = -c  #-prelink -ptused   -ptv  #  -fullwarn 

INCLUDE = -I../c++adt/include -I../Firmament/include \
          -I../stl-lignum/include  -I../LEngine/include \
          -I../Graphics -I/usr/freeware/include -I/usr/X11R6/include \
          -I/sw/include -I.

LIBD=lib64
LIBFLAGS = -L../c++adt/lib -L../stl-lignum/lib -L../Firmament/lib \
           -L. -L../LEngine/lib -L../Graphics \
           -L/usr/freeware/$(LIBD) -L/usr/X11R6/lib -L/sw/lib

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

.SUFFIXES: .L .cpp .o .cc  .o .cpp 

all: gnupoplar

sinclude Makedepend

gnupoplar: 
	make "CCC=g++" "CCCFLAGS=-c" "OPTIMIZE=-g" \
              "AR=ar"  "ARFLAGS=rvs"  "LSYS=$(LSYS)" "LIBD=lib32" poplar

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

$(LIB6): $(SRC) $(OBJ)
	$(AR) $(ARFLAGS) $(@) $(OBJ)    

.L.cpp:
	../LEngine/bin/l2c  $< $@
	$(CCC) $(CCCFLAGS) $(OPTIMIZE) $(INCLUDE)  $@
	rm -f *.c

.cpp.o:
	$(CCC) $(OPTIMIZE) $(CCCFLAGS) $(INCLUDE)  $< -o $@	

.cc.o: 
	$(CCC) $(OPTIMIZE) $(CCCFLAGS) $(INCLUDE)  $< -o $@

html:
	enscript -E --color -Whtml --toc -p$(PROGFILES) ./include/*.h ./*/*.cc
changelog:
	rm -rf ChangeLog
	rcs2log . > ChangeLog
clean:
	rm -rf *.o  *.cpp Makedepend liblsys.a core ii_files
distclean: clean
	rm -rf  $(LIB4) Makedepend
	(cd ../Graphics; make distclean)
	(cd ../LEngine/L2C; make distclean)
depend:
	(cd ../Graphics; make "CCC=$(CCC)"  depend)
	(cd ../LEngine/L2C; make "CCC=$(CCC)"  depend)
	$(CCC) -M $(INCLUDE) $(POPLARSRC)   > Makedepend
