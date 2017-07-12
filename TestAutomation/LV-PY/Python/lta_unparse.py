# -*- coding: utf-8 -*-
from collections import OrderedDict
import sys
from lxml import etree
from lta_err import Lta_Error
from lta_parse import Lta_Parse
import numpy as np

def npType_to_XMLType(npType):
    """ returns a string representing the data type.  String is used as the XML tag by LabVIEW """
    switch = {
        np.bool :'Boolean',
        np.bool_ : 'Boolean',
        np.dtype('S') :'String',
        str     : 'String',  
        np.string_ : 'String',
        np.int8 :'I8',      
        np.int16 :'I16',
        np.int32 :'I32', 
        int      :'I32',        
        np.int64 :'I64',
        np.uint8 :'U8',
        np.uint16 :'U16',
        np.uint32 :'U32',
        np.uint64 :'U64',
        np.float16 :'SGL',
        np.float32 :'DBL',
        np.float64 :'EXT',
        np.complex64 :'CDB',
        np.complex128 :'CXT',       
    }
    XMLType = switch.get(npType);# print npType
    assert XMLType != None,'Error in npType_to_XMLType: unrecognized npType: {0}'.format(npType)
    return XMLType

def __uParseNum(element,item,tag):
    XMLType = npType_to_XMLType(type(item[tag]))
    subEl = etree.SubElement(element,XMLType)
    Name = etree.SubElement(subEl,'Name')
    Name.text = tag
    Val = etree.SubElement(subEl,'Val')
    # Labview wants Booleans to be integer 1 or 0
    if isinstance(item[tag],np.bool_):
        Val.text = str(item[tag].astype(int))
    elif isinstance(item[tag],np.bool):
        Val.text = str(int(item[tag]))
        
    else:
        Val.text = str(item[tag])
        if any([XMLType == 'CDB', XMLType == 'CXT', XMLType == 'CSG']):        
            Val.text =  Val.text.replace('j', ' i') 
            Val.text =  Val.text.replace('+', ' +')
            Val.text =  Val.text.replace('-', ' -')
            Val.text =  Val.text.replace ('(','')
            Val.text =  Val.text.replace (')','')
        

def __uParseList(element,item,tag):
# if it is a list, it must be an an array type other than numpy
    Array = etree.SubElement(element, 'Array')
    Name = etree.SubElement(Array,'Name')
    Name.text = tag
    try:
        dim = item[tag].__len__()   # TODO one dimensional only.  If more than 1-D will need to revise
        Dimsize = etree.SubElement(Array,'Dimsize')
        Dimsize.text = str(dim)
        for ele in item[tag]:
            for item in ele:
                uParse = __uParseType(type(ele[item]))
                uParse(Array,ele,item)                
        
    except Exception as e:
        raise e        

def __uParseClust(element,dictItem,tag):
    Clust = etree.SubElement(element,'Cluster')
    Name = etree.SubElement(Clust,'Name')
    Name.text = tag
    NumElts = etree.SubElement(Clust,'NumElts')
    NumElts.text = str(dictItem[tag].__len__())
    for item in dictItem[tag]:
        uParse = __uParseType(type(dictItem[tag][item]))
        uParse(Clust,dictItem[tag],item)
            
   
def __uParseArray(element,item,tag):
    Array = etree.SubElement(element,'Array')
    Name = etree.SubElement(Array,'Name')
    Name.text = tag
    try:
        for dim in item[tag].shape:
            DimSize = etree.SubElement(Array,'Dimsize')
            DimSize.text = str(dim)
        for index, x in np.ndenumerate(item[tag]):
            XMLType = npType_to_XMLType(type(x))
            NumType = etree.SubElement(Array,XMLType)
            NumName = etree.SubElement(NumType,'Name')
            if isinstance(x, str):
                typ = 'String'
            else:
                typ = 'Numeric'
            NumName.text = typ    # Labview array elements should not have individual names
            NumVal = etree.SubElement(NumType, 'Val')
            NumVal.text = str(x)
            if NumVal.text == 'None':
                NumVal.text = ''
            if any([XMLType == 'CDB', XMLType == 'CXT', XMLType == 'CSG']):        
                NumVal.text=  NumVal.text.replace('j', ' i') 
                NumVal.text=  NumVal.text.replace('+', ' +')
                NumVal.text =  NumVal.text.replace('-', ' -')
                NumVal.text = NumVal.text.replace ('(','')
                NumVal.text = NumVal.text.replace (')','')
                
    except Exception as e:
        raise e
        
    
def __uParseType(item):
    """ retruns a reference to the method that unparses the element type """
    switch = {
        dict       : __uParseClust,
        OrderedDict : __uParseClust,
        np.ndarray : __uParseArray,
        list       : __uParseList,
    } 
    uParse = switch.get(item);# print item
    if uParse == None:
        uParse = __uParseNum
    return uParse

def Lta_Unparse(topDict):    
    root = etree.Element("root")
    root_doc = etree.SubElement(root, "doc")
    try:
        for tag in topDict: 
            uParse = __uParseType(type(topDict[tag]))
            uParse(root_doc,topDict,tag)

    except Exception as e:
        a=Lta_Error(e,sys.exc_info())
        print a 
        raise e        
        
    retVal = ''
    for child in root_doc:
        retVal = retVal + (etree.tostring(child, pretty_print=True))  
#    parser = etree.XMLParser(remove_blank_text=True)
#    retVal = etree.tostring(etree.XML(retVal, parser=parser))
    return retVal        
    
    
if __name__=='__main__':
    import os

    fileRelPath = 'TestCluster.xml'
#    fileRelPath = 'err.xml'  #LabVIEW formatted error cluster
#    fileRelPath = 'clData.xml'  # Cluster Data
#    fileRelPath = 'arData.xml'  # Array Data
#    fileRelPath = 'stData.xml'  # Just Data
#    fileRelPath = '..\..\..\Plugins\Plugin_B\Plugin.B.xml'
    try:
        thisDir = os.getcwd();
        fileDir = os.path.join(thisDir,fileRelPath)  
        xml = open(fileDir).read()
        dataStruct = Lta_Parse(xml)
        dataStruct = Lta_Parse(dataStruct['CommsData']['XMLData'])
        print dataStruct, '\n'
        
        parsed = Lta_Unparse (dataStruct)
        print parsed
        
    except Exception as e:
        a=Lta_Error(e,sys.exc_info())
        print a     