import sys
import os
import string


#5 Jmax25 and LGPrhoW
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-5.xml','-toFile','Aug-22-5.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-5']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 2
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-5-131.xml','-toFile','Aug-22-5-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-5-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 3
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-5-97.xml','-toFile','Aug-22-5-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-5-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 4
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-5-241.xml','-toFile','Aug-22-5-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-5-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 5
p_file = open("sensitivity.txt","w");
p_file.write(str(110.0125)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-5-333.xml','-toFile','Aug-22-5-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-5-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#6 Jmax25 and LGPrhoW
#Down 1
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-6.xml','-toFile','Aug-22-6.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-6']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 2
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-6-131.xml','-toFile','Aug-22-6-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-6-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 3
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-6-97.xml','-toFile','Aug-22-6-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-6-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 4
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-6-241.xml','-toFile','Aug-22-6-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-6-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 5
p_file = open("sensitivity.txt","w");
p_file.write(str(66.0075)+" "+str(42.12)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-6-333.xml','-toFile','Aug-22-6-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-6-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#7 Vcmax25 and Rd25
#Up 1
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-7.xml','-toFile','Aug-22-7.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-7']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-7-131.xml','-toFile','Aug-22-7-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-7-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-7-97.xml','-toFile','Aug-22-7-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-7-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-7-241.xml','-toFile','Aug-22-7-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-7-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.3625)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-7-333.xml','-toFile','Aug-22-7-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-7-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#8 Vcmax25 and Rd25
#Down 1 
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-8.xml','-toFile','Aug-22-8.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-8']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-8-131.xml','-toFile','Aug-22-8-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-8-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-8-97.xml','-toFile','Aug-22-8-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-8-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-8-241.xml','-toFile','Aug-22-8-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-8-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(0.8175)+" "+str(0.0075)+" "+str(350.0)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-8-333.xml','-toFile','Aug-22-8-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-8-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#9 Vcmax25 and LGPrhoW
#Up 1 
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-9.xml','-toFile','Aug-22-9.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-9']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-9-131.xml','-toFile','Aug-22-9-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-9-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-9-97.xml','-toFile','Aug-22-9-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-9-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-9-241.xml','-toFile','Aug-22-9-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-9-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(52.65)+" "+str(1.09)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-9-333.xml','-toFile','Aug-22-9-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-9-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#10 Vcmax25 and LGPrhoW
#Down 1 
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-10.xml','-toFile','Aug-22-10.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-10']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-10-131.xml','-toFile','Aug-22-10-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-10-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-10-97.xml','-toFile','Aug-22-10-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-10-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-10-241.xml','-toFile','Aug-22-10-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-10-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(31.59)+" "+str(1.09)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-10-333.xml','-toFile','Aug-22-10-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-10-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#11 Rd25 and LGPrhoW
#Up 1 
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-11.xml','-toFile','Aug-22-11.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-11']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-11-131.xml','-toFile','Aug-22-11-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-11-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-11-97.xml','-toFile','Aug-22-11-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-11-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-11-241.xml','-toFile','Aug-22-11-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-11-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Up 5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(1.3625)+" "+str(0.0075)+" "+str(437.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-11-333.xml','-toFile','Aug-22-11-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-11-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#12 Rd25 and LGPrhoW
#Down 1 
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-1))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-12.xml','-toFile','Aug-22-12.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-12']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 2
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-131))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-12-131.xml','-toFile','Aug-22-12-131.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-12-131']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 3
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-97))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-12-97.xml','-toFile','Aug-22-12-97.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-12-97']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 4
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-241))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-12-241.xml','-toFile','Aug-22-12-241.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-12-241']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

#Down 5
p_file = open("sensitivity.txt","w");
p_file.write(str(88.01)+" "+str(42.12)+" "+str(0.8175)+" "+str(0.0075)+" "+str(262.5)+" "+str(30.0)+" "+str(0.5)+" "+str(-333))
p_file.close()

command_line = ['poplar','-iter','4','-xml','Aug-22-12-333.xml','-toFile','Aug-22-12-333.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar",command_line,os.environ)
command_line = ['move-results.sh','Aug-22-12-333']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

