################
First Time setup
################

When setting up a PC to run the PARTF for the first time, several important steps must be performed.  If these are not performed properly, you will get an error message.  At the end of this section is a trouble shooting guide to help with error messages common to incomplete first-time setup. to begin with make sure MATLAB and Python have been installed on the PC.  PARTF has only been tested with Python 2.7 an it is recommended to use the 2.7 version of Python because Python 3.x has incomplete support at the time of the PARTF development.

Matlab Path
===========

The PARTF When the PARTF is loaded, a MATLAB command window is opened in the background.  the Matlab icon appears in your taskbar.  The MATLAB command window path must be set up.  The command window does not use the same MATLAB path as the MATLAB IDE so it must be set up from within the command window using the pathtool command.  Select ''Add with Subfolders'' and browse to \<your PARTF Location\>\\Modules\\Matlab and select the folder.  Note that you can use the matlab command ''which \-all'' pathdef to locate the pathdef.m file.  There should only be one pathdef file in the list, usually located at <matlab location>\\toolbox\\\local\\pathdef.m

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

	

