
params[ "_vehicle", "_child" ];

//Add passed child index to depth array
private _depth = _vehicle getVariable [ "LARs_menuDepth", [] ];
_depth pushBack _child;
_vehicle setVariable [ "LARs_menuDepth", _depth ];

[ _vehicle ] call LARs_fnc_menuShow;
