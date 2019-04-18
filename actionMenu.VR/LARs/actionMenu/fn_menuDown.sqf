
params[ "_vehicle" ];

//Remove last depth from array
private _depth = _vehicle getVariable [ "LARs_menuDepth", [] ];
_depth deleteAt (( count _depth ) -1 );
_vehicle setVariable [ "LARs_menuDepth", _depth ];

[ _vehicle ] call LARs_fnc_menuShow;
