#For single tree, just add *.cc files you need
POPLARSRC = poplarmain.cc poplarmetabolism.cc poplarsegment.cc 
POPLAROBJ = ${POPLARSRC:.cc=.o}

#For stand, just as above add *.cc files you need
POPLARSTANDSRC = poplarstand.cc poplarmetabolism.cc poplarsegment.cc 
POPLARSTANDOBJ = ${POPLARSTANDSRC:.cc=.o}

#LSystem
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
	-I../stl-voxelspace/include \
	-I../Graphics -I/usr/freeware/include -I/usr/X11R6/include \
	-I../Graphics -I../stl-voxelspace/include \
	-I../ScotsPine/include -I/usr/freeware/include -I/usr/X11R6/include \
          -I/sw/include -I.	


LIBD=lib64
LIBFLAGS =  -L../c++adt/lib -L../stl-lignum/lib -L../Firmament/lib \
	-L. -L../LEngine/lib -L../Graphics \
	   -L../stl-voxelspace/lib \
           -L. -L../LEngine/lib -L../Graphics -L../stl-voxelspace/lib\
           -L/usr/freeware/$(LIBD) -L/usr/X11R6/lib -L/sw/lib

#The actual libraries (files) to be created
LIB1   = libc++adt.a
LIB2   = libLGM.a
LIB3   = libsky.a
LIB4   = libL.a
LIB5   = libVisual.a
LIB6   = liblsys.a
LIB7   = libvoxel.a

#Compiler flags to link the libraries above 
LIBADT = -lc++adt
LIBLGM = -lLGM
LIBSKY = -lsky
LIBL   = -lL
LIBMATH  = -lm 
LIBVISUAL = -lVisual
LIBLSYS = -llsys
LIBVOX = -lvoxel
LIBOGL =  -lglut -lGLU -lGL -lXmu -lXext -lX11

LIBS     =  $(LIBVISUAL) $(LIBLSYS) $(LIBL)  $(LIBVOX) $(LIBLGM) \
            $(LIBSKY) $(LIBADT) $(LIBOGL) $(LIBMATH)

#implicit rules: *.L files compile to *.cpp; *.cc and *.cpp files compile to *.o
.SUFFIXES: .L .cpp .o .cc  .o .cpp 

all: sgipoplar

sinclude Makedepend

#Set compiler and archive tool for g++ (Linux)
gnupoplar: 
	(cd ../LEngine; make "CCC=$(CCC)" "CCCFLAGS=-c" "OPTIMIZE=$(OPTIMIZE)" \
                             "AR=ar" "ARFLAGS=rvs" lengine)
	make "CCC=$(CCC)" "CCCFLAGS=-c" "OPTIMIZE=$(OPTIMIZE)" \
              "AR=ar"  "ARFLAGS=rvs"  "LSYS=$(LSYS)" "LIBD=lib32" poplar
#Set compiler and archive tool for g++ (Linux)
gnupoplarstand: 
	(cd ../LEngine; make "CCC=$(CCC)" "CCCFLAGS=-c" "OPTIMIZE=$(OPTIMIZE)" \
                             "AR=ar" "ARFLAGS=rvs" lengine)
	make "CCC=$(CCC)" "CCCFLAGS=-c" "OPTIMIZE=$(OPTIMIZE)" \
              "AR=ar"  "ARFLAGS=rvs"  "LSYS=$(LSYS)" "LIBD=lib32" poplarstand
#Set compiler and archive tool for CC (SGI CC)
sgipoplar: 
	(cd ../LEngine; make "CCC=CC -64 -LANG:std"  "CCCFLAGS=-c"  "OPTIMIZE=$(OPTIMIZE)" \
                             "AR=CC -64 -LANG:std -ar" "ARFLAGS=$(ARFLAGS)" lengine)
	make "CCC=CC -64 -LANG:std" "CCCFLAGS=-c" "OPTIMIZE=$(OPTIMIZE)" \
             "AR=CC -64 -LANG:std -ar"  "ARFLAGS=-o"  "LSYS=$(LSYS)" "LIBD=lib64" poplar
#Set compiler and archive tool for CC (SGI CC)
sgipoplarstand:
	(cd ../LEngine; make "CCC=CC -64 -LANG:std"  "CCCFLAGS=-c"  "OPTIMIZE=$(OPTIMIZE)" \
                             "AR=CC -64 -LANG:std -ar" "ARFLAGS=$(ARFLAGS)" lengine)
	make "CCC=CC -64 -LANG:std" "CCCFLAGS=-c" "OPTIMIZE=$(OPTIMIZE)" \
             "AR=CC -64 -LANG:std -ar"  "ARFLAGS=-o"  "LSYS=$(LSYS)" "LIBD=lib64" poplarstand

#Compile single poplar, use either 'gnupoplar' or 'sgipoplar' to set
#compiler and archive tool
poplar: $(POPLAROBJ) $(LIB1) $(LIB2) $(LIB3)  $(LIB5) $(LIB6)  $(LIB7) 
	$(CCC)  -o $@ $(INCLUDE) $(OPTIMIZE) $(POPLAROBJ) $(LIBFLAGS) $(LIBS)

#Compile poplar stand, use either 'gnupoplarstand' or 'sgipoplarstand'
#to set compiler and archive tool
poplarstand: $(POPLARSTANDOBJ) $(LIB1) $(LIB2) $(LIB3)  $(LIB5) $(LIB6)  $(LIB7) 
	$(CCC)  -o $@ $(INCLUDE) $(OPTIMIZE) $(POPLARSTANDOBJ) $(LIBFLAGS) $(LIBS)

l2c:	
	(cd ../LEngine; make "CCC=$(CCC)" "CCCFLAGS=$(CCCFLAGS)" \
                             "OPTIMIZE=$(OPTIMIZE)" "AR=$(AR)" "ARFLAGS=$(ARFLAGS) gnu)
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
	(cd ../LEngine; make "CCC=$(CCC)" "CCCFLAGS=$(CCCFLAGS)" \
                             "OPTIMIZE=$(OPTIMIZE)" "AR=$(AR)" "ARFLAGS=$(ARFLAGS)" gnu) 

$(LIB5):
	(cd ../Graphics; make "CCC=$(CCC)" "CCCFLAGS=$(CCCFLAGS)" \
         "OPTIMIZE=$(OPTIMIZE)"  "AR=$(AR)"  "ARFLAGS = $(ARFLAGS)" $@)

$(LIB6): $(SRC) $(OBJ)
	$(AR) $(ARFLAGS) $(@) $(OBJ)   

$(LIB7):
	(cd ../stl-voxelspace; make "CCC=$(CCC)" "CCCFLAGS=$(CCCFLAGS)" \
         "OPTIMIZE=$(OPTIMIZE)"  "AR=$(AR)"  "ARFLAGS = $(ARFLAGS)" $@) 

#Compilation of L-system file to cpp file
.L.cpp:
	../LEngine/bin/l2c  $< $@
	$(CCC) $(CCCFLAGS) $(OPTIMIZE) $(INCLUDE)  $@
	rm -f *.c

#Compilation of *.cpp files to *.o files
.cpp.o:
	$(CCC) $(OPTIMIZE) $(CCCFLAGS) $(INCLUDE)  $< -o $@	

#Compilations of *.cc files to *.o files
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
	(cd ../LEngine; make distclean)
depend:
	(cd ../Graphics; make "CCC=$(CCC)"  depend)
	(cd ../LEngine/L2C; make "CCC=$(CCC)"  depend)
	$(CCC) -M $(INCLUDE) $(POPLARSRC)   > Makedepend
