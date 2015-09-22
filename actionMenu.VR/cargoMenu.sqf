_menu = [];
{
	_type = _x select 1;
	_contents = _this call compile format[ "%1Cargo _this", _type ];
	if !( _contents isEqualTo [] ) then {
		//title, script, arguments, priority, showWindow, hideOnUse, shortcut, condition
		_menu pushBack [ "   " + ( _x select 0 ) , {}, [], -1, false, false, "", "" ];
		_child = [];
		_baseCfg = _x select 2;
		{
			_child pushBack [ "   " + getText( _baseCfg >> _x >> "displayname" ) , compile format[ "player add%1 %2", _type, str _x  ], [], -1, false, false, "", "" ]
		}forEach _contents;
		_menu pushBack _child;
	};
}forEach [
	[ "weapons", "weapon", configFile >> "CfgWeapons" ],
	[ "magazines", "magazine", configFile >> "CfgMagazines" ],
	[ "items", "item", configFile >> "CfgVehicles" ],
	[ "backpacks", "backpack", configFile >> "CfgVehicles" ]
];


//[ _menu, _vehicle( player ), _shared( false ), _menuDistance( 5 ), _controls( HIDE, HOME, BACK, EXIT ) ] call LARs_fnc_menuStart;
[ _menu, _this, true ] call LARs_fnc_menuStart;
