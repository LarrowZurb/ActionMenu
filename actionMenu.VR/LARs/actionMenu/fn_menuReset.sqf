
params[ "_vehicle" ];

//Clear depth array
_vehicle setVariable [ "LARs_menuDepth", [] ];

[ _vehicle ] call LARs_fnc_menuShow;
