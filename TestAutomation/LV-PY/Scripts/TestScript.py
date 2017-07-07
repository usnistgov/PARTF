  # -*- coding: utf-8 -*-
from lta import Lta
import sys
import numpy as np
from lta_err import Lta_Error

#------------------- following code myst be in all scripts--------------------
lta = Lta("127.0.0.1",60100)    # all scripts must create  an Lta object
lta.connect()                   # connect to the Labview Host
#-----------------------------------------------------------------------------
try:
    #--------------- here is where your code goes-----------------------------      
    CommsData = lta.__get__('TestCluster')
    CommsData['TestCluster']['EmbeddedCl_2']['TrueOrFalse'] = not CommsData['TestCluster']['EmbeddedCl_2']['TrueOrFalse']
    CommsData['TestCluster']['EmbeddedCl_1']['NumDbl'] += np.float32(1)
    CommsData['TestCluster']['DoeADeer'][0][0]='WRITTEN'
    lta.__set__('TestCluster',CommsData)
    lta.close()
    #-------------------------------------------------------------------------

#------------------all scripts should send their errors to labview------------
except Exception as ex:
    err = Lta_Error(ex,sys.exc_info())  #format a labview error
    lta.send_error(err,3,'Abort')       #send the error to labview for display
    lta.close()

