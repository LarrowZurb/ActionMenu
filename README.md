The actionMenu system provides a useable multi depth menu in the form of addActions. It has a simple structure of addAction parameters in the form of a multidimension array.

An action is the same as the full parameter list used in an Arma3 addAction command. [title, script, arguments, priority, showWindow, hideOnUse, shortcut, condition] See https://community.bistudio.com/wiki/addAction for further details. An actions code MUST be in the form of code {} not string.

To use simple copy the LARs folder from this test mission into yours and copy the CfgFunctions from the description.ext into yours. If you already have a CfgFunctions just add my #include 'LARs\actionMenu.cpp'.

Further info can also be found in LARs\actionMenu\info.txt
