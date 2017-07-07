# -*- coding: utf-8 -*-
""" parse LabVIEW(TM) XML to Python dictionary.
        uses lxml.etree, numpy
        
    Note:  Unfortunatly, Labview "Unflatten from XML" requires the order of the XML tags
    to be in the same order at the typedef being unflattened to.  Since Python Dictionaries
    have no concept of order, we must use Ordered Dictionaries instead.    
"""

import sys
from collections import OrderedDict
from lxml import etree
from lta_err import Lta_Error
import numpy as np

def getRootDoc(xml):
    xml = '<item>'+xml+'</item>'
    return etree.fromstring(xml)


def printXML(node):
    print(etree.tostring(node, pretty_print=True))
    print('---')

def parseString(node):
#    printXML(node)
    for ele in node:
        tag = ele.tag;
        if tag == 'Name':
            name = ele.text              
        elif tag == 'Val':
            val = ele.text
            if val is None:
                val = ""
        else:
            assert True,'unhandled XML tag: {0} in parseString'.format(tag)
    return[name,val]
    
def parsePath(node):
    for ele in node:
        tag = ele.tag
        if tag == 'Name':
            name = 'Path'
        elif tag == 'Val':
            val = ele.text
            if val is None:
                val = ""
        else:
             assert True,'unhandled XML tag: {0} in parsePath'.format(tag)
    return[name,val]
        
            
# used by parseNumeric get the numpy type cast method
def XMLType_to_npCast(tag):
    """ returns a pointer to a method to cast a numeric to a python data type"""
    switch = {
        'Boolean' : np.bool_,
        'String'  : str,
        'I8' : np.int8,      
        'I16': np.int16,
        'I32': np.int32, 
        'I64': np.int64,
        'U8' : np.uint8,
        'U16': np.uint16,
        'U32': np.uint32,
        'U64': np.uint64,
        'SGL': np.float16,
        'DBL': np.float32,
        'EXT': np.float64,
        'CSG': np.complex64,
        'CDB': np.complex128,
        'CXT': np.complex128,
    }
    dCast =switch.get(tag);
    assert dCast != None,'Error in XMLType_to_npType: unrecognized XMLType: {0}'.format(tag)
    return dCast
    
def parseNumeric(child):
    dCast = XMLType_to_npCast(child.tag)
    for node in child:
        if node.tag == 'Name':
            name = node.text
        elif node.tag == 'Val':
            val = node.text
            assert val != None,'Empty numeric: {0} in ParseNumeric'.format(name)
            if child.tag == 'Boolean':      # np.bool always returns "True" for strings
                val = int(val)
            if any([child.tag == 'CSG', child.tag == 'CDB', child.tag == 'CXT']):
                val=  val.replace(' i', 'j')                 
                val = val.replace(' +-', '-')
                val = val.replace(' -', '-')
                val=  val.replace(' +', '+')
                val=  complex(val)
            val = dCast(val)
        else:
            assert ('unhandled XML tag: {0} in parseNumeric'.format(child.tag))
    return[name,val]
    


def XMLType_to_npType(XMLType):
    """ Returns the numpy data type for use in creating a nympy array """
    switch = {
        'Boolean' : np.dtype('b'),
        'String'  : np.dtype('S'),
        'i8' : np.dtype('i1'),      
        'I16': np.dtype('i2'),
        'I32': np.dtype('i4'), 
        'I64': np.dtype('i8'),
        'U8' : np.dtype('u1'),
        'U16': np.dtype('u2'),
        'U32': np.dtype('u4'),
        'U64': np.dtype('u8'),
        'SGL': np.dtype('f2'),
        'DBL': np.dtype('f4'),
        'EXT': np.dtype('f8'),
        'CSG': np.dtype('c2'),
        'CDB': np.dtype('c4'),
        'CXT': np.dtype('c8'),
    } 
    npType =switch.get(XMLType)
    assert (npType != None),'Error in XML_to_npType: unrecognized XMLType: {0}'.format(XMLType)
    return npType

def parseArray(node):
    dimSizes = []
    tempList = []
    created = False    # will be set to true when the array is created
    arrayOfClusters = False
    for ele in node:
        tag = ele.tag
        if tag == 'Name':
            name = ele.text
        elif tag == 'Dimsize':
            dimSizes.append(int(ele.text)) 
        elif tag == 'Cluster':
            arrayOfClusters = True
            tempList.append(parseCluster(ele))
        else:                                   # after the <Name> and <Dimsize> elements, there should only be data remaining
            if created == False:                # the first data element
                XMLType = tag
                dType = XMLType_to_npCast(XMLType)
                created = True
            assert (tag == XMLType),'XMLType: {0} does not equal Data Type: {1}'.format(XMLType, tag)  #They should all be the same type or there is an error
            for item in ele:
                if item.tag == 'Val':
                    var= item.text
                    if any([XMLType == 'CSG', XMLType == 'CDB', XMLType == 'CXT']):
                        item.text =  item.text.replace(' i', 'j') 
                        item.text=  item.text.replace(' +-', '-')
                        item.text = item.text.replace(' -', '-')
                        item.text = item.text.replace(' +', '+')
                        var = complex(item.text)                  
                    tempList.append(var)
                   
    if arrayOfClusters == True:
        return [name, tempList]               
    tempArray = np.reshape(np.asarray(tempList,dType),tuple(dimSizes))    # build the numpy array here  
  
    return [name,tempArray]

def parseCluster(child):
    try:
#        retVal = {}              # need to used OrderedDict
        retVal = OrderedDict()
        for node in child:
            tag = node.tag
            if tag == 'Name':
                name = node.text
#                retVal[name] = {}
                retVal[name] = OrderedDict()  #need to use OrderedDict
            elif node.tag == 'NumElts':
               pass
            elif node.tag == 'String':
                strList = parseString(node)
                retVal[name][strList[0]]=strList[1]
            elif node.tag == 'Path':
                strList = parseString(node)
                retVal[name][strList[0]]=strList[1]
            elif node.tag == 'Array':
                arrayList = parseArray(node)
                retVal[name][arrayList[0]]=arrayList[1]
            elif node.tag == 'Cluster':   # Nested Clusters
                for subName, subVal in parseCluster(node).iteritems():
                    retVal[name][subName]=subVal
            else:
                dataList = parseNumeric(node)
                retVal[name][dataList[0]]=dataList[1]
                
        return retVal   

    except Exception as e:
        a=Lta_Error(e,sys.exc_info())
        print a  
        raise e
 
def parseData(child):
    retVal = {}
    if child.tag == 'String':
        strList = parseString(child) 
        retVal[strList[0]]=strList[1]
    elif child.tag == 'Path':
        strList = parsePath(child)
        retVal[strList[0]]=strList[1]
    else:
        numList = parseNumeric(child)
        retVal[numList[0]]=numList[1]
    return retVal
            
    
def Lta_Parse(xml):
    topDict = {}

    try:
        root = getRootDoc(xml)      
        # for each top level element, determine the data type and create
        # a container in the op level dictionary
        for child in root:
            tag = child.tag;
            if tag == 'Cluster':
                val = parseCluster(child)
                topDict.update(val)
            elif tag == 'Array':
                val = parseArray(child)
                val = {val[0]: val[1]}
            else:                           # data that is not in a string or array
                val = parseData(child)
            topDict.update(val)         
        return   topDict     

    except Exception as e:
        err = Lta_Error(e,sys.exc_info())
        raise err
        
if __name__=='__main__':
    # Test the parser
    import os
 
    fileRelPath = 'nested.xml'   # has 2 nested clusters    
#    fileRelPath = 'err.xml'     #LabVIEW formatted error messege
#    fileRelPath = 'clData.xml'  # Cluster Data
#    fileRelPath = 'arData.xml'  # Array Data
#    fileRelPath = 'stData.xml'  # Just Data
#    fileRelPath = '..\..\..\Plugins\Plugin_B\Plugin.B.xml'
    try:
        thisDir = os.getcwd();
        fileDir = os.path.join(thisDir,fileRelPath)  
        xml = open(fileDir).read()
        dataStruct = Lta_Parse(xml)
        print dataStruct
        
    except Exception as e:
        a=Lta_Error(e,sys.exc_info())
        print a  
            
         
       