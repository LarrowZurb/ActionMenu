
params[
	[ "_vehicle", objNull, [ objNull ] ],
	[ "_depth", [], [ [] ] ],
	[ "_pos", -1, [ 0 ] ],
	[ "_isGlobal", false, [ false ] ]
];

if ( isNull _vehicle ) exitWith { false };

if ( _isGlobal isEqualTypeAny [ objNull, sideUnknown, grpNull, [], 0 ] || ( _isGlobal isEqualType true && { _isGlobal } ) ) then {
	_this set [ 3, false ];
	if( _isGlobal isEqualType true ) then {
		_isGlobal = [ 0, -2 ] select isDedicated;
	};
	_this remoteExec[ "LARs_fnc_menuAddItem", _isGlobal, false ];
	//[ _this, "LARs_fnc_menuAddItem", _isGlobal, false ] call BIS_fnc_MP;
};

private _newMenu = +( _vehicle getVariable [ "LARs_activeMenu", [] ] );
private _find = _newMenu;

{
	private _depthX = _x;
	private _child = -1;
	{
		if ( ( _x select 0 ) isEqualType [] ) then {
			_child = _child + 1;
			if ( _child isEqualTo _depthX ) exitWith {
				 _find = _x;
			};
		};
	}forEach _find;
}forEach _depth;

private _childMenu = false;
if ( _pos >= 0 ) then {
	if ( (( count _find ) -1 ) >= _pos ) then {
		if ( (( count _find ) -1 ) > _pos && { ( _find select ( _pos + 1 ) select 0 ) isEqualType [] } ) then {
			private _nul = _find deleteAt ( _pos + 1 );
			_childMenu = true;
		};
		_find deleteAt _pos;
	};
}else{
	if ( (( _find select (( count _find ) -1 )) select 0 ) isEqualType [] ) then {
		private _nul = _find deleteAt (( count _find ) -1 );
		_childMenu = true;
	};
	private _nul = _find deleteAt (( count _find ) -1 );
};

private _currentDepth = _vehicle getVariable [ "LARs_menuDepth", [] ];
if (  _childMenu && { ( _currentDepth select [ 0, count _depth ] ) isEqualTo _depth } ) then {
	_currentDepth = _depth;
};
_vehicle setVariable [ "LARs_menuDepth", _currentDepth ];

_vehicle setVariable [ "LARs_activeMenu",  _newMenu ];

if ( !isNull player && { isNil { player getVariable [ "LARs_remoteMenu", nil ] } } ) then {
	[ _vehicle ] call LARs_fnc_menuShow;
};

true
