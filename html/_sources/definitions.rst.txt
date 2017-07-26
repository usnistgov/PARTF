###########
Definitions
###########

Module
======

A module is a software structure which is designed to be launched by an application framework then run independently of the launching application.  Modules receive "requests" from the launching application and transmit "broadcasts" which may be received by any application or other modules which have registered to receive the broadcasts.  Collectively the requests and broadcasts are considered to be the module's application programming interface (API)

Multiple modules of the same type may run concurrently.  Each instance of a concurrently running module is called a "clone" of that module.  Modules are documented in detail in the "Pluggable Modules Specification" document.

Plug-in
=======

The core functionality of any module is defined by a plug-in.  Modules accept "plug-ins" at runtime and plug-ins may be changed during run-time.  Plug-ins are custom software which inherit from a module's base plug-in class.  They allow for custom interfacing and/or internal processing within the module. Plug-ins may be written in MATLAB, LabVIEW, Python, Any of the C variants, and other software languages supported by the host computer.  The host computer must have the supporting software installed, for examples plug-ins written in MATLAB must be supported by a MATLAB installation on the host computer.

Each plugin must have a text ".ini" file with certain required fields.  within the .ini file is a set of instructions called a "scriptlet".  When a test is run, the scriptlets from each module within a bus are concatenated together to form a script which is executed by a bus controller. the .ini file also carries default configuration and parameter values for the module as well as the plugin "type" which is displayed by the framework.

Event
=====

A finite time domain signal, or set of signals, represented by a mathematical function of time (t) or by a data set saved to a computer file.  These signals represent ideal measurements of single or multi-phase power system voltages and currents and on a single bus in an electrical substation to which a sensor such as a PMU may be making measurements.  Power System Events may be continuous in time such as steady state signals or smooth transitions between steady state and changing frequencies, or discontinuous in time such as steps in signal magnitude and/or phase.  The impairment framework can support multiple events, each representing the signal at a single bus in the electrical power system.  Events in the framework are determined by plug-ins

Impairment
==========

In general, impairment refers to differences between ideal information and information with errors.  The errors may be due to transformer and transducer error, measurement inaccuracy, data transmission latency and error, and issues with the status, flags, and other metadata.

Visualization
=============

The PARTF provides for data visualization and analysis tools to listen to broadcasts from any module and present graphical or tabular information to the user.
