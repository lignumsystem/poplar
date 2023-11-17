import sys
import os
import string

#Jmax25
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-1.xml','-toFile','Aug-21-1.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-1']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-1-131.xml','-toFile','Aug-21-1-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-1-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-1-97.xml','-toFile','Aug-21-1-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-1-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-1-241.xml','-toFile','Aug-21-1-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-1-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-1-333.xml','-toFile','Aug-21-1-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-1-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 1
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-2.xml','-toFile','Aug-21-2.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-2']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-2-131.xml','-toFile','Aug-21-2-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-2-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-2-97.xml','-toFile','Aug-21-2-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-2-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-2-241.xml','-toFile','Aug-21-2-97-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-2-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-2-333.xml','-toFile','Aug-21-2-97-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-2-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#VcMax25 
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-3.xml','-toFile','Aug-21-3.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-3']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-3-131.xml','-toFile','Aug-21-3-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-3-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-3-97.xml','-toFile','Aug-21-3-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-3-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-3-241.xml','-toFile','Aug-21-3-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-3-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-3-333.xml','-toFile','Aug-21-3-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-3-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-4.xml','-toFile','Aug-21-4.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-4']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-4-131.xml','-toFile','Aug-21-4-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-4-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-4-97.xml','-toFile','Aug-21-4-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-4-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-4-241.xml','-toFile','Aug-21-4-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-4-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-4-333.xml','-toFile','Aug-21-4-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-4-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)


#Rd25
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-5.xml','-toFile','Aug-21-5.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-5']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-5-131.xml','-toFile','Aug-21-5-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-5-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-5-97.xml','-toFile','Aug-21-5-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-5-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-5-241.xml','-toFile','Aug-21-5-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-5-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-5-333.xml','-toFile','Aug-21-5-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-5-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-6.xml','-toFile','Aug-21-6.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-6']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-6-131.xml','-toFile','Aug-21-6-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-6-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-6-97.xml','-toFile','Aug-21-6-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-6-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-6-241.xml','-toFile','Aug-21-6-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-6-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-6-333.xml','-toFile','Aug-21-6-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-6-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#LGPms
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.009375)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-7.xml','-toFile','Aug-21-7.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-7']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.009375)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-7-131.xml','-toFile','Aug-21-7-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-7-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.009375)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-7-97.xml','-toFile','Aug-21-7-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-7-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.009375)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-7-241.xml','-toFile','Aug-21-7-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-7-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.009375)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-7-333.xml','-toFile','Aug-21-7-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-7-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.005625)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-8.xml','-toFile','Aug-21-8.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-8']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.005625)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-8-131.xml','-toFile','Aug-21-8-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-8-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.005625)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-8-97.xml','-toFile','Aug-21-8-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-8-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.005625)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-8-241.xml','-toFile','Aug-21-8-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-8-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.005625)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-8-333.xml','-toFile','Aug-21-8-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-8-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#LGPrhoW
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-9.xml','-toFile','Aug-21-9.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-9']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-9-131.xml','-toFile','Aug-21-9-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-9-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-9-97.xml','-toFile','Aug-21-9-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-9-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-9-241.xml','-toFile','Aug-21-9-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-9-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-9-333.xml','-toFile','Aug-21-9-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-9-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-10.xml','-toFile','Aug-21-10.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-10']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-10-131.xml','-toFile','Aug-21-10-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-10-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-10-97.xml','-toFile','Aug-21-10-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-10-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-10-241.xml','-toFile','Aug-21-10-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-10-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-10-333.xml','-toFile','Aug-21-10-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-10-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#LGPsf
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(37.5)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-11.xml','-toFile','Aug-21-11.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-11']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(37.5)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-11-131.xml','-toFile','Aug-21-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-11-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(37.5)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-11-97.xml','-toFile','Aug-21-11-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-11-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(37.5)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-11-241.xml','-toFile','Aug-21-11-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-11-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(37.5)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-11-333.xml','-toFile','Aug-21-11-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-11-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(22.5)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-12.xml','-toFile','Aug-21-12.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-12']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(22.5)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-12-131.xml','-toFile','Aug-21-12-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-12-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(22.5)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-12-97.xml','-toFile','Aug-21-12-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-12-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(22.5)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-12-241.xml','-toFile','Aug-21-12-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-12-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(22.5)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-12-333.xml','-toFile','Aug-21-12-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-12-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#LGPar
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.625)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-13.xml','-toFile','Aug-21-13.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-13']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.625)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-13-131.xml','-toFile','Aug-21-13-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-13-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.625)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-13-97.xml','-toFile','Aug-21-13-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-13-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.625)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-13-241.xml','-toFile','Aug-21-13-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-13-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.625)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-13-333.xml','-toFile','Aug-21-13-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-13-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.375)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-14.xml','-toFile','Aug-21-14.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-14']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.375)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-14-131.xml','-toFile','Aug-21-14-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-14-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.375)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-14-97.xml','-toFile','Aug-21-14-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-14-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.375)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-14-241.xml','-toFile','Aug-21-14-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-14-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.375)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-21-14-333.xml','-toFile','Aug-21-14-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-21-14-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)
