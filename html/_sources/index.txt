.. PARTF documentation master file, created by
   sphinx-quickstart on Wed Jul 05 16:15:53 2017.

PMU APPLICATIONS REQUIREMENTS TEST FRAMEWORK
********************************************
PARTF Reference Document

Abstract:
=========
The PARTF is highly conformable software designed to simulate or play back sensor measurements at one or more buses on bulk electrical power systems, to simulate impairments to the measurements due to error of the measurement itself, errors in network transmission and timing, and errors in the status information carried by the measurement transmission system, and to provide those impaired measurements to applications which use those measurements.

The framework is capable of running user created test automation scripts to perform multiple test runs, saving application input, application input The PARTF is highly conformable software designed to simulate or play back sensor measurements at one or more buses on bulk electrical power systems, to simulate impairments to the measurements due to error of the measurement itself, errors in network transmission and timing, and errors in the status information carried by the measurement transmission system, and to provide those impaired measurements to applications which use those measurements error, and application output data to files for analysis and supporting user-defined visualization tools for analyzing the data.

The framework uses a software plug-in system so that users may create their own simulated or played-back bus measurements, sensor impairments, network impairment, status impairments, and applications without the need to create entire test frameworks


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
   python

.. toctree::
   moduleAppendix

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

