import sys
import os
import string

#Jmax25
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-1.xml','-toFile','Aug-20-1.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar-Aug-20-1",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-1']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-2.xml','-toFile','Aug-20-2.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-2']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#VcMax25
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-3.xml','-toFile','Aug-20-3.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-3']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-4.xml','-toFile','Aug-20-4.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-4']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Rd25
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-5.xml','-toFile','Aug-20-5.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-5']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-6.xml','-toFile','Aug-20-6.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-6']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#LGPms
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.009375)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-7.xml','-toFile','Aug-20-7.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-7']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.005625)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-8.xml','-toFile','Aug-20-8.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-8']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#LGPrhoW
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-9.xml','-toFile','Aug-20-9.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-9']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-10.xml','-toFile','Aug-20-10.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-10']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#LGPsf
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(37.5)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-11.xml','-toFile','Aug-20-11.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-11']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(22.5)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-12.xml','-toFile','Aug-20-12.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-12']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#LGPar
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.625)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-13.xml','-toFile','Aug-20-13.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-13']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.375)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','10','-xml','Aug-20-14.xml','-toFile','Aug-20-14.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-20-14']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)



