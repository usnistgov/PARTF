# -*- coding: utf-8 -*-
from lta import Lta
import sys
from lta_err import Lta_Error

#------------------- following code must be in all scripts--------------------
lta = Lta("127.0.0.1",60100)    # all scripts must create  an Lta object
try:
    lta.connect()                   # connect to the Labview Host
#---------------------Script code goes here------------------------------------
    EvtCfg=lta.__get__('bus1.event.config')
    EvtCfg['clEvtConfig']['Fs'] = 60
    lta.__set__('bus1.event.config',EvtCfg)
    lta.__run__()
    EvtCfg=lta.__get__('bus1.event.config')
    EvtCfg['clEvtConfig']['Fs'] = 30
    lta.__set__('bus1.event.config',EvtCfg)
    lta.__run__()
    EvtCfg=lta.__get__('bus1.event.config')
    EvtCfg['clEvtConfig']['Fs'] = 20
    lta.__set__('bus1.event.config',EvtCfg)
    lta.__run__()

#------------------all scripts should send their errors to labview------------
except Exception as ex:
    err = Lta_Error(ex,sys.exc_info())  #format a labview error
    lta.send_error(err,3,'Abort')       #send the error to labview for display
    lta.close()
    print err

