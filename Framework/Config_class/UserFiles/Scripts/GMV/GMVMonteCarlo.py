# -*- coding: utf-8 -*-
"""
Created on Tue Sep 15 11:33:43 2017

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
import os

start_time = time.time()
strTime = time.strftime("%Y" "%m" "%d" "%H" "%M" "%S", time.gmtime())


iterations=10
NoiseVariances=np.float32([1e-1, 0.5e-1, 1e-2, 0.5e-2, 1e-3, 0.5e-3])


dfile='ModelGenValidation_{}'.format(strTime)

AppOutput=[]

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
    AppOut_arr = np.zeros((len(NoiseVariances)*iterations,), dtype=np.object)
#-----------------------  Get App Config -------------------------------------    
    AppCfg = lta.__get__('app.config')
    AppCfg['ModelValidationConfig']['NoiseVariance']=NoiseVariances[0]
    lta.__set__('app.config',AppCfg) 
 #-----------------------  Set Impairments ------------------------------------  
#    EventConfig = lta.__get__('bus1.event.config')
#    EventConfig['clEvtConfig']['bPosSeq']= bool(0)
#    lta.__set__('bus1.event.config',EventConfig)
#---------------------  Set PMU impairment ------------------------------------  
    impair_string= 'C37BehaviourPlugin' 
    ImpairPath=lta.__get__('bus1.PMUImpairment.PathToPlugin')
    ImpairPluginPath = os.path.split(ImpairPath['Path'])
    ImpairPluginPath = os.path.split(ImpairPluginPath[0])
    ImpairPluginPath = os.path.join(ImpairPluginPath[0],impair_string)
    ImpairPluginPath = os.path.join(ImpairPluginPath,impair_string+'.ini')
    ImpairPath['Path']=ImpairPluginPath
    lta.__set__('bus1.PMUImpairment.PathToPlugin',ImpairPath)
    bus_impair_string='bus1.pmuimpairment.config'
    PMUImpCfg=lta.__get__(bus_impair_string)
    PMUImpCfg['clImpairConfig']['FilterType'] = 'Blackman'
    lta.__set__(bus_impair_string,PMUImpCfg)
#-------------------  Get events params ---------------------------------------      
    EventInput = lta.__get__('bus1.event.reports')
    data_size=len(EventInput['clEvtReportArray'])
    EventTime_arr = np.zeros((data_size,), dtype=np.object)
    for h in range(data_size):
        EventTime_arr[h]= EventInput['clEvtReportArray'][h]['clReportArg']['Timestamp']
    EventParams=lta.__get__('bus1.event.params')
#--------------------  Perform several runs -----------------------------------
    j=0;
    #print (num_pmus-1)*iterations
    for i in range(len(NoiseVariances)*iterations):
        if (not(i%iterations) and i>0):        
            AppCfg_in= AppCfg
            AppCfg_in['ModelValidationConfig']['NoiseVariance']=NoiseVariances[j+1]
            lta.__set__('app.config',AppCfg_in)
            j=j+1
        string_msg='progress: '+ str((i+1)*100/iterations/len(NoiseVariances))+' %'
        print string_msg
        lta.__run__()
        AppOutput.append(lta.__get__('app.output'))
        AppOut_arr[i] = AppOutput[i]
                
#----------------------  Save the results -------------------------------------  
    pickle.dump({'AppOutput': AppOut_arr,'EventTime': EventTime_arr,'EventParams': EventParams}, output_python)
    savemat(output_matlab, mdict={'AppOutput': AppOut_arr,'EventTime': EventTime_arr,'EventParams': EventParams,'AppCfg':AppCfg,'NoiseVariances':NoiseVariances})   
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
