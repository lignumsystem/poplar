import sys
import os
import string

command_line = ['poplar-Aug-17-1','-iter','10','-xml',' Aug-17-1.xml','-toFile','Aug-17-1.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar-Aug-17-1",command_line,os.environ)
command_line = ['move-results.sh','Aug-17-1']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

command_line = ['poplar-Aug-17-2','-iter','10','-xml',' Aug-17-2.xml','-toFile','Aug-17-2.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar-Aug-17-2",command_line,os.environ)
command_line = ['move-results.sh','Aug-17-2']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

command_line = ['poplar-Aug-17-3','-iter','10','-xml',' Aug-17-3.xml','-toFile','Aug-17-3.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar-Aug-17-3",command_line,os.environ)
command_line = ['move-results.sh','Aug-17-3']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

command_line = ['poplar-Aug-17-4','-iter','10','-xml',' Aug-17-4.xml','-toFile','Aug-17-4.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar-Aug-17-4",command_line,os.environ)
command_line = ['move-results.sh','Aug-17-4']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)

command_line = ['poplar-Aug-17-5','-iter','10','-xml',' Aug-17-5.xml','-toFile','Aug-17-5.txt','-writeInterval','1']
result = os.spawnvpe(os.P_WAIT,"./poplar-Aug-17-5",command_line,os.environ)
command_line = ['move-results.sh','Aug-17-5']
result = os.spawnvpe(os.P_WAIT,"./move-results.sh", command_line,os.environ)
