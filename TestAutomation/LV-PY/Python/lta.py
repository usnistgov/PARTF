# -*- coding: utf-8 -*-
""" LabVIEW Test Automation """
# class lta: Labview Test Automation
from collections import OrderedDict
from lta_parse import Lta_Parse
from lta_unparse import Lta_Unparse
from lta_err import Lta_Error
import socket
import packet
import sys
 
class Lta_Command():
    """ This object is a wrapper dictionary that wraps an Lta "dataStruct" 
    dictionary in a command dictionary ready to be unparsed and sent to LabVIEW

    useage:
    cmdDict = Lta_Command(command, dataStruct)     
    command is the command message string recognized by your LabVIEW Host.
            
    dataStruct is an OrderedDictionary that conforms to the structure that
    LabVIEW is expecting for arriving data.
            
    Note that LabVIEW violates the spirit of XML by requiring tags to be in 
    Order expected by the typedef of the object that is being unflattened.
    That is why we need to use OrderedDictionaries
    """
        
    def __init__(self,command=None,arg=None):
        self.command = command
        self.arg = arg
        if not isinstance(arg,str):
            self.arg = Lta_Unparse(self.arg)
        self.cmdDict = {'CommsData': OrderedDict([('Command',self.command),('XMLData', self.arg)])}
       
    def __str__(self):
        return str(self.cmdDict)
        
    def __len__(self):
        return self.cmdDict.__len__()    
   
          
class Lta():
    """Labview Test Automation class"""
    def __init__(self,host=None,port=None):
        self.host = host
        self.port = port
        self.s = ''
        return

    def connect(self): 
            self.s=socket.create_connection((self.host,self.port))
            self.s.settimeout(0.2)
            
    def close(self):
        try:
            self.s.close()
        except IOError as e:
            print e
        
    def send_error(self,err,pri,sev):
        errDict = Lta_Command('ClientError',err.LvError(pri,sev))
        errXML = Lta_Unparse(errDict.cmdDict)
        packet.SendPacket(self.s,errXML)    

    def __get__(self,arg):
        """ for now, arg is the XML string of the get command """
        try:
            UsrTimeout = self.s.gettimeout()            
            self.s.settimeout(1)
            cmd = Lta_Command('get', arg)
            self.s.settimeout(UsrTimeout)
            xml = Lta_Unparse(cmd.cmdDict)
            packet.SendPacket(self.s,xml)
            CommsData = packet.ReceivePacket(self.s)
            CommsData = Lta_Parse(CommsData)
            CommsData = Lta_Parse(CommsData['CommsData']['XMLData'])
            return CommsData
        except (IOError, Exception) as e:
            raise e
            
    def __set__(self,arg,dataStruct):
        try:
            XMLData = Lta_Unparse({'SetData': OrderedDict([('Arg',arg),('Data',Lta_Unparse(dataStruct))])})
            cmdDict = Lta_Command('set',XMLData).cmdDict
            xml = Lta_Unparse(cmdDict);
            UsrTimeout = self.s.gettimeout()            
            self.s.settimeout(1)            
            packet.SendPacket(self.s,xml)
            self.s.settimeout(UsrTimeout)           
            CommsData = packet.ReceivePacket(self.s)
            CommsData = Lta_Parse(CommsData)
            CommsData = Lta_Parse(CommsData['CommsData']['XMLData'])
            return CommsData
        except (IOError, Exception) as e:
            raise e
    
    def __run__(self):
        try:
            cmdDict = Lta_Command('run',"").cmdDict
            xml = Lta_Unparse(cmdDict);
            packet.SendPacket(self.s, xml)
            CommsData = packet.ReceivePacket(self.s)
            CommsData = Lta_Parse(CommsData); #print CommsData
            assert CommsData['CommsData']['Command']=='LtaRunComplete', "Run was not acknowledged as completed"
        except (IOError, Exception) as e:
            raise e

if __name__=='__main__':
    try:
        execfile(sys.argv[1])
    except Exception as ex:
        lta = Lta("127.0.0.1",60100)
        lta.connect()
        err = Lta_Error(ex,sys.exc_info())
        lta.send_error(err,3,'Abort')
        lta.close()



     
