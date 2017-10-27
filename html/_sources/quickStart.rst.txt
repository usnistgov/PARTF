.. _`quickStart`:

################
First Time setup
################

When setting up a PC to run the PARTF for the first time, several important steps must be performed.  If these are not performed properly, you will get an error message.  At the end of this section is a trouble shooting guide to help with error messages common to incomplete first-time setup. to begin with make sure MATLAB and Python have been installed on the PC.  PARTF has only been tested with Python 2.7 an it is recommended to use the 2.7 version of Python because Python 3.x has incomplete support at the time of the PARTF development.

Labview Dependencies
====================
A number of Labview packages are needed to run the PARTF.  You can download them and install them with `VI Package Manager (VIPM)`_ (which comes bundled with labview after 2014).

	.. _`VI Package Manager (VIPM)`: https://vipm.jki.net/get

(note: for the below, x.x.x.x refers to the latest version available)

NISTErrorLib
++++++++++++
Download and install NISTErrorLib_.

	.. _NISTErrorLib: https://github.com/usnistgov/LV_Packages/blob/master/packages/nist_lib_nisterrorlib/nist_lib_nisterrorlib-x.x.x.x.vip

The NISTErrorLib builds on the native LabVIEW error handler and allows for muttiple errors to be carried in an error array, adds error priority, error severity, logging, ability to cleanly exit the program on Critical and Fatal Errors and a uniform error dialog.  Once the NISTErrorLib package is installed, you can find an example of how to use it in in the ErrorLib pallette: "Producer Consumer Design Pattern (Events).vi, labeled "Test Errors"

BaseClasses Library
+++++++++++++++++++
Download and install BaseClasses_.

	.. _BaseClasses: https://github.com/usnistgov/LV_Packages/blob/master/packages/nist_lib_nistbaseclasses/nist_lib_nistbaseclasses-x.x.x.x.vip

All classes in PARTF inheret from the BaseObject class.  All Plugin classes inheret from BasePlugin class.  All of the Plugin modules have a Base Plugin class for that module which all the plugin classes inheret from.

ModuleAdmin Library
+++++++++++++++++++
Download and install ModuleAdmin_.

	.. _ModuleAdmin: https://github.com/usnistgov/LV_Packages/blob/master/packages/nist_lib_nistmoduleadminlib/nist_lib_nistmoduleadminlib-x.x.x.x.vip

The administrative library and classes for the Cloneable, Pluggable modules used in the PARTF.  Provides a ModuleAdmin class for maintining module properties.  CloneRegistration providing properties and methods for adding, removing and accounting for instantiated clones, and VIs for synchronizing module clones and their calling applications.

Socket API Class
++++++++++++++++
Download and install SocketAPI_.

	.. _SocketAPI: https://github.com/usnistgov/LV_Packages/blob/master/packages/nist_lib_nisterrorlib/nist_lib_nisterrorlib-x.x.x.x.vip
	
The Socket class provides an API and some middleware for  TCP and UDP point to point and multicast communications.  Once installed, useage examples can be found using the labview Example Finder.  Look under the task "Networking/TCP & UDP" for the examples beginning with the word "Socket."  	

OpenG Variant Configuration File Library
++++++++++++++++++++++++++++++++++++++++
Download and install either from the VI Package Network using VIPM by going to the the `OpenG Variant Configuration Library`_

	.. _`OpenG Variant Configuration Library`: https://vipm.jki.net/package/oglib_variantconfig
		
The OpenG Variant Configuration File Library package contains tools for writing and reading variant data to and from INI files.  Installing this package requires a free account with JKI Software  During installation, the package will automatically download some other OpenG dependencies.

Matlab Path
===========

The PARTF When the PARTF is loaded, a MATLAB command window is opened in the background.  the Matlab icon appears in your taskbar.  The MATLAB command window path must be set up.  The command window does not use the same MATLAB path as the MATLAB IDE so it must be set up from within the command window using the ``pathtool`` command.  Select ``Add with Subfolders`` and browse to ..\\<your PARTF Location\>\\Modules\\Matlab and select the folder.  Note that you can use the matlab command ``which \-all pathdef`` to locate the pathdef.m file.  There should only be one pathdef file in the list, usually located at <matlab location>\\toolbox\\\local\\pathdef.m

.. _`MatlabToolbox`:

Matlab Libraries used by LSE Application Example
=================================================

The Linear State Estimation Example Application uses two Matlab toolboxes that need to be downloaded:

	* Go to the `PSERC MatPower Page`_ and click ``Download Now``.

		.. _`PSERC MatPower Page`: http://www.pserc.cornell.edu/matpower/

	* Unzip the downloaded file into your `Documents\\MATLAB\\Toolbox folder`.
	* Add the path to MatPower to the Matlab Path using the instructions in the Matlab ``pathtool`` similar to the Matlab Path section above.
	* PARTF requires some of the .m files in MatPower to be modified. Find the following folder: `<partf install path)\Modules\\MATLAB\\Events\\IEEEBus\\IEEE cases`, copy the nine 'case##.m' files and copy them to the matpower main folder, replacing the files that were there. The most part of the files are the same, but little modifications were made to save the reference voltages of the IEEE systems.

The LSE Application Example also includes Dynamic Events.  These examples require the Matlab Power System Toolbox available from The Royal Institute of Technology in Stockholm, Sweden.  

	* Download `PSTV3`_, `PST Data`_, and the `Manual`_ 

		.. _`PSTV3`: http://www.eps.ee.kth.se/personal/vanfretti/pst/download_updates/pstv3.zip
		.. _`PST Data`: http://www.eps.ee.kth.se/personal/vanfretti/pst/download_updates/pstdat.zip
		.. _`Manual`: http://www.eps.ee.kth.se/personal/vanfretti/pst/download_updates/PSTMan.zip
	
	* You will need to `register and get a password`_
	
		.. _`register and get a password`: http://www.eps.ee.kth.se/personal/vanfretti/pst/Power_System_Toolbox_Webpage/Software_Request.html

	* As with the MatPower toolbox, unzip these into your `Documents\\MATLAB\\Toolbox` folder and set up the Matlab Path

Note that the Power System Toolbox is not open source software and cannot be redistributed.

Python Path
===========

Troubleshooting
===============

+-----------------------------------+----------------------------------------------------------------------+
| ISSUE                             | EXPLANATION                                                          |
+===================================+======================================================================+
|Error 1050 occurred at LabVIEW:    | The Matlab path is not set correctly.  In the matlab command window, |
|Error occurred while executing     | type ''pathtool''. The search path should include a set of folders   |
|script.  Error messege from        | under ...\Modules\Matlab\... If it does, then check the path to the  | 
|server: ??? Undefined function     | pathdef.m folder using which -all pathdef, there should be only one  |
|"<name>" ...                       | pathdef.m file listed.                                               |
|	                            |                                                                      |
+-----------------------------------+----------------------------------------------------------------------+

	

