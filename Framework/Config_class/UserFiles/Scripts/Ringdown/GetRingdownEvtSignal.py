# -*- coding: utf-8 -*-
"""
Created on Thu Jul 20 11:26:27 2017

@author: pgm1
"""

# -*- coding: utf-8 -*-
from lta import Lta
import sys
from lta_err import Lta_Error
import pickle
from scipy.io import savemat
import numpy as np
import time

start_time = time.time()
dfile='data_{}'.format(int(time.time()))


#------------------- following code myst be in all scripts--------------------
lta = Lta("127.0.0.1",60100)    # all scripts must create  an Lta object
try:
    lta.connect()                   # connect to the Labview Host
    lta.s.settimeout(30) 

#---------------------Script code goes here------------------------------------
#-------------------  Create output files -------------------------------------    
    Settings = lta.__get__('settings')
    out_dir = Settings['Directories']['RootDir']+'\\'+Settings['Directories']['OutDir']+'\\'
    output_python_path = ( out_dir + dfile + '.pkl')
    output_matlab_path = ( out_dir + dfile + '.mat')
    output_python = open(output_python_path, 'wb')
    output_matlab = open(output_matlab_path, 'wb') 
 #-----------------------  Set Evt Config -------------------------------------
    EventInput = lta.__get__('bus1.event.reports')
    data_size=len(EventInput['clEvtReportArray'])
    EventTime_arr = np.zeros((data_size,), dtype=np.object)
    for h in range(data_size):
        EventTime_arr[h]= EventInput['clEvtReportArray'][h]['clReportArg']['Timestamp']
    EventParams=lta.__get__('bus1.event.params')
               
#----------------------  Save the results -------------------------------------  
    pickle.dump({'EventInput': EventInput,'EventTime': EventTime_arr,'EventParams': EventParams}, output_python)
    savemat(output_matlab, mdict={'EventInput': EventInput,'EventTime': EventTime_arr,'EventParams': EventParams})   
    output_python.close()
    output_matlab.close()
#----------------------  Print time of process  -------------------------------    
    elapsed_time = time.time() - start_time
    final_msg = '\n'+ 'Elapsed Time:  ' + str(elapsed_time) +'\n'
    print final_msg
    
#------------------all scripts should send their errors to labview------------
except Exception as ex:
    err = Lta_Error(ex,sys.exc_info())  #format a labview error
    lta.send_error(err,3,'Abort')       #send the error to labview for display
    lta.close()
    print err