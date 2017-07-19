###############
Test Automation
###############

Introduction
============

The framework uses the Python interpreted language to perform test automation.  In addition to all the python commands and modules which the user may have installed, there are three commands that drive LabVIEW Test Automation (LTA): ``Lta.__get__``, ``Lta__set__``, and ``lta__run__``.  Several example scripts are provided with PARTF.  On the first run of the program, these are copied into the "PARTF/Scripts" fplder in the user's Documents.  The file named DefaultTest.py is a very simple example of ``__get__`` -ting some PARTF parameter information, acting upon it, ``__set__`` -ting the data in a bus module, then ``__run__`` -ing a test.

Automation Script Structure
===========================

All automation scripts have four main sections.  At the very top are python module import directives, these are required at the top of every script: 

.. code-block:: python
	
	from lta import Lta
	import sys
	from lta_err import Lta_Error

Next is some code that initialized a local-host connection between the Python and PARTF framework.  note that if the network address and ports shown in the example are already in use, other addresses and/or port numbers may be used:

.. code-block:: python

     #------------------- following code must be in all scripts--------------------
	lta = Lta("127.0.0.1",60100)    # all scripts must create  an Lta object
	try:
    	   lta.connect()                   # connect to the Labview Host
    	   lta.s.settimeout(10)

The third section of code is where the user can put the test automaton script.  The beolw is a simple example taken from DefaultTest.py

.. code-block:: python

	#---------------------Script code goes here------------------------------------
    	   EvtCfg=lta.__get__('bus1.event.config')
    	   EvtCfg['clEvtConfig']['Fs'] = 60
    	   error = lta.__set__('bus1.event.config',EvtCfg)
    	   lta.__run__()
           lta.close()

Note that the above is simplified and includes no error-handling.  The PARTF always returns some information to Python for each command.  The information will either be the data or an error message in the case of a ``__get__`` command, an error message (including a "no-error" error message) in the case of ``__set__`` and a "run completion" message or an error in the case of a ``__run__`` command.

the final section of an automation script is the exception handler.  The LTA system returns exceptions occurint in the Python code to the framework for logging and display to the user via the framework's error handling system:

.. code-block:: python

      #------------------all scripts should send their errors to labview------------
	except Exception as ex:
        err = Lta_Error(ex,sys.exc_info())  #format a labview error
        lta.send_error(err,3,'Abort')       #send the error to labview for display
        lta.close()
        print err

Data arguments
==============

Arguments to the ``__get__`` and ``__set__`` specify the origin and destination of the transmitted data.  the ``__get__`` command can additionally be used to ``add`` or ``remove`` a bus.  Arguments are not case sensitive.

	.. include:: LTA_argtable.rst 

XML Data format
===============

Generally, end users will never need to handle the XML data transferred internally between LabVIEW and Python.  This section is for reference in the event that some debugging of the data in transit is needed.

All data transferred between the framework and python is in a LabVIEW XML format.  LabVIEW XML places some limitations upon regular XML:

1.) The order of the data returned to LabVIEW must be in the order expected by the type definition of the data type received.  This is an important concept because Python Dictionaries have a dynamic order which can change during processing.  For this reason, LabVIEW "Clusters" are represented in Python as "OrderedDictionaries" which do not change the data order.

2.) Labview uses static types and python uses dynamic types.  During python processing, the type of a variable may change at any time.  For example, an int32 can become a float at any time.  If LabVIEW expects an int32, and a float is sent, then LabVIEW will throw an error.  For this reason, LabVIEW array are represented in Python as "NUMPY arrays".  Also some type checking is needed to ensure that any data sent to LabVIEW matches the prototype.

Nested clusters (clusters containing clusters), nested arrays (arrays of arrays), clusters of arrays, and arrays of clusters are all handled between LabVIEW and python.

The below example shows the format of the event configuration being transferred between the framework and python.  Note that every data block is labeled by its type definition (DBL,I32,U32,Boolean, etc).

.. code-block:: xml

	<Cluster>
	  <Name>clEvtConfig</Name>
	  <NumElts>5</NumElts>
	  <DBL>
	    <Name>T0(UTC)</Name>
	    <Val>0.0</Val>
	  </DBL>
	  <DBL>
	    <Name>F0</Name>
	    <Val>60.0</Val>
	  </DBL>
	  <I32>
	    <Name>Fs</Name>
	    <Val>60</Val>
	  </I32>
	  <U32>
	    <Name>FSamp</Name>
	    <Val>960</Val>
	  </U32>
	  <Boolean>
	    <Name>bPosSeq</Name>
	    <Val>0</Val>
	  </Boolean>
	</Cluster>

The transmitted message itself is bundled into a command cluster.  The data is wrapped in an XML cluster containing the command specifying what the receiver should do with the data:

.. code-block:: xml

	"<Cluster>
	  <Name>SetData</Name>
	  <NumElts>2</NumElts>
	  <String>
	    <Name>Arg</Name>
	    <Val>bus1.event.config</Val>
	  </String>
	  <String>
	    <Name>Data</Name>
	    <Val>&lt;Cluster&gt;
	  &lt;Name&gt;clEvtConfig&lt;/Name&gt;
	  &lt;NumElts&gt;5&lt;/NumElts&gt;
	  &lt;DBL&gt;
	    &lt;Name&gt;T0(UTC)&lt;/Name&gt;
	    &lt;Val&gt;0.0&lt;/Val&gt;
	  &lt;/DBL&gt;
	  &lt;DBL&gt;
	    &lt;Name&gt;F0&lt;/Name&gt;
	    &lt;Val&gt;60.0&lt;/Val&gt;
	  &lt;/DBL&gt;
	  &lt;I32&gt;
	    &lt;Name&gt;Fs&lt;/Name&gt;
	    &lt;Val&gt;60&lt;/Val&gt;
	  &lt;/I32&gt;
	  &lt;U32&gt;
	    &lt;Name&gt;FSamp&lt;/Name&gt;
	    &lt;Val&gt;960&lt;/Val&gt;
	  &lt;/U32&gt;
	  &lt;Boolean&gt;
	    &lt;Name&gt;bPosSeq&lt;/Name&gt;
	    &lt;Val&gt;0&lt;/Val&gt;
	  &lt;/Boolean&gt;
	&lt;/Cluster&gt;
	</Val>
	  </String>
	</Cluster>
	"

The data portion is doubly flattened to XML.  In other words: **<DBL>** is flattened even further to **&lt;/DBL&gt**.  The command is *SetData* and the argument shows where the data is to be placed, in this case in *bus1.event.config*


Python Data Format
==================

The format in Python depends on the datatype returned from the ``get`` call.  In general:

Params
-------
Params are 2D arrays of doubles (in python, float32)  Below is the Python representation of:

.. code-block:: python 

	EvtParams =lta.__get__('bus1.event.params')
	print EvtParams	
	>>
	{'dblEventParams': array([[  70.,   70.,   70.,   20.,   20.,   20.],
	       [  60.,   60.,   60.,   60.,   60.,   60.],
	       [   0., -120.,  120.,    0., -120.,  120.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.],
	       [   0.,    0.,    0.,    0.,    0.,    0.]], dtype=float32)}

Config
------
Config data is generally represented by clusters in LabVIEW.  In Python they are represented in a OrderedDictionary because the ordering of the data must remain the same as received from LabVIEW.

.. code-block:: python

	EvtCfg=lta.__get__('bus1.event.config')
	print EvtCfg
	>>
	{'clEvtConfig': OrderedDict([('T0(UTC)', 0.0), ('F0', 60.0), ('Fs', 60), ('FSamp', 960), ('bPosSeq', False)])}

Synchrophasor Reports
---------------------
Synchrophasor reports are represented in Labview as an array of clusters containing arrays of synchrophasors.  The below example is 0.1 seconds at 60 FPS of ideal synchrophasors at 60 Hz.

.. code-block:: python

	lta.__run__()
	EvtRpts = lta.__get__('bus1.event.reports')
	print EvtRpts	
	>>
	{'clEvtReportArray': [
		OrderedDict([('clReportArg', OrderedDict([('Timestamp', 0.0), ('Synx', array([ 70. +0.j, -35.-60.62177826j, -35.+60.62177826j, 20. +0.j, -10.-17.32050808j, -10.+17.32050808j])), ('Freq', 60.0), ('ROCOF', 0.0), ('ID', 1)]))]),
		OrderedDict([('clReportArg', OrderedDict([('Timestamp', 0.016666668), ('Synx', array([ 70. +0.j, -35.-60.62177826j, -35.+60.62177826j, 20. +0.j, -10.-17.32050808j, -10.+17.32050808j])), ('Freq', 60.0), ('ROCOF', 0.0), ('ID', 1)]))]),
		OrderedDict([('clReportArg', OrderedDict([('Timestamp', 0.033333335), ('Synx', array([ 70. +0.j, -35.-60.62177826j, -35.+60.62177826j, 20. +0.j, -10.-17.32050808j, -10.+17.32050808j])), ('Freq', 60.0), ('ROCOF', 0.0), ('ID', 1)]))]),
		OrderedDict([('clReportArg', OrderedDict([('Timestamp', 0.050000001), ('Synx', array([ 70. +0.j, -35.-60.62177826j, -35.+60.62177826j, 20. +0.j, -10.-17.32050808j, -10.+17.32050808j])), ('Freq', 60.0), ('ROCOF', 0.0), ('ID', 1)]))]),
		OrderedDict([('clReportArg', OrderedDict([('Timestamp', 0.06666667), ('Synx', array([ 70. +0.j, -35.-60.62177826j, -35.+60.62177826j, 20. +0.j, -10.-17.32050808j, -10.+17.32050808j])), ('Freq', 60.0), ('ROCOF', 0.0), ('ID', 1)]))]),
		OrderedDict([('clReportArg', OrderedDict([('Timestamp', 0.083333336), ('Synx', array([ 70. +0.j, -35.-60.62177826j, -35.+60.62177826j, 20. +0.j, -10.-17.32050808j, -10.+17.32050808j])), ('Freq', 60.0), ('ROCOF', 0.0), ('ID', 1)]))]), 
		OrderedDict([('clReportArg', OrderedDict([('Timestamp', 0.1), ('Synx', array([ 70. +0.j, -35.-60.62177826j, -35.+60.62177826j, 20. +0.j, -10.-17.32050808j, -10.+17.32050808j])), ('Freq', 60.0), ('ROCOF', 0.0), ('ID', 1)]))])
		]
	}

Complex numbers in LabVIEW use "i" for the imaginary operator where Python uses "j".  the LTA code had some special handling for transporting complex numbers between the two languages. 