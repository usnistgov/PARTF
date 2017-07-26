###############
Introduction
###############
The PARTF framework is software designed to perform standardized benchmarking of applications which use power system sensor (e.g. PMU) data as an input.  Benchmarking is defined as testing an application many times using many datasets with known errors relative to a clean dataset(s), effectively creating a multi-dimensional PMU data error analysis. Benchmarking allows determination of how different errors affect an applications performance. 

The P.A.R.T. Framework is software consisting of:

1. A "Main" framework (Figure 1)

2. Configuration using test files

3. Test automation using Python scripting

4. A set of stand-alone modules which work together to create one or more power system "buses":

	a)	Event Module simulates or plays from a file, the power system measurements on a single bus (node) of the bulk electrical power system.

	b)	Transformer Module (under development) simulates the signal impairment of voltage and current transformers or transducers

	c)	Sensor Module simulates measurement impairment due to sensor (such as PMU) measurement error.

	d)	Network Module simulates network timing and data loss/corruption error.

	e)	Status Module simulates impairments of the sensor data transmission protocol status data.

	f)	Application Module supports the PMU or other sensor data application under test.

	g)	Output To File Module outputs application input and sensor data error data to a variety of data file formats such as comma separated vaolu (CSV), Comtrade (under development) and other user definable formats.

.. image:: figures/Frontpanel.png
Figure 1: PARTF Front Panel

Modules support user-designed software "plug-ins" which can be written in Matlab, Labview, Python, any of the C variants, or most other software languages.  The plug-in performs the primary function of the module.  Users can focus their effort on developing sensor, applications, and impairment simulation without the need to work on the underlying testing structure. Modules work as a collection to simulate a single power system bus or node, Multiple collections of modules can be created to form multiple bus input to a single application.  The limit of the number of buses that can be supported depends on the memory of the computer hosting the framework.

A single test run can be performed, or the user can create test automation "scripts" to perform "Monte Carlo" style analysis test runs.  The script has access to any and all of the parameters and configuration settings of all of the modules. Typically, the script will ``get`` configuration or parameter information from one or more modules, modify the information and ``set`` the modified information back into the module then ``run`` a test and repeat the process until script completion.

This document is a detailed reference of the framework.  It is designed for users who will be creating plug-ins, scripts and developing code that uses or modifies the PARTF software.

