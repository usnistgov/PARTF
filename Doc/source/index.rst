.. PARTF documentation master file, created by
   sphinx-quickstart on Wed Jul 05 16:15:53 2017.

PMU APPLICATIONS REQUIREMENTS TEST FRAMEWORK
********************************************
PARTF Reference Document

Abstract:
=========
The goal of the PMU Application Requirements Test Framework is to provide an open source, standard automated platform for the testing of applications that receive power system sensor data and act upon it.  This platform should enable users to focus on their applications and not on building a test framework around it.  Libraries of power system signals and different types of sensors and sensor and communication system impairments will be available and can be added to as a community of users and contributors develops. 

The framework is capable of running user created test automation scripts to perform multiple test runs and saving application input, output and analysis. The PARTF is highly conformable software designed to simulate or play back sensor measurements at one or more buses on bulk electrical power systems, to simulate impairments to the measurements due to error of the measurement itself, errors in network transmission and timing, and errors in the status information carried by the measurement transmission system, and to provide those impaired measurements to applications which use those measurements.

The framework uses a software plug-in system so that users may create their own simulated or played-back bus measurements, sensor impairments, network impairment, status impairments, and applications without the need to create entire test frameworks.  Besides testing applications, the PARTF can be used to test PMU and other sensor estimation algorithms.

A short note about the beta process
===================================
PARTF is in closed beta at this time.  There is still lots to do but the framework is useful at this time for doing some analysis of the effects of PMU measurement impairment on applications.  We are happy to get more collaborators on the project to work on their own applications while helping us flesh out the features of the framework.  Please contact allen.goldstein@nist.gov if you would like to collaborate.  Feel free to send a *detailed* ``pull request`` if you think you have something of value to add from your fork.

During this beta period, there will be frequent commits to the master branch.  Make sure to follow the changes. 

Contents:
=========

.. toctree::
   :maxdepth: 2
   :numbered:

   intro
   License
   definitions
   usecase
   quickStart
   buses
   framework
   busclass
   moduleRef
   testAutomation	

.. toctree::
   exampleAppRingdown
   exampleAppLSE
   exampleAppGMV
   moduleAppendix


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`