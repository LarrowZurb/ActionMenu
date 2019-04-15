// [ _menu, _vehicle( player ),  _shared( false ), _menuDistance( 5 ), _controls( HIDE, HOME, BACK, EXIT ) ] call LARs_fnc_menuStart;

// _menu - An array of actions to show, child menu actions follow their parent contained in an array - also supports as STRING the name of a global variable containing a menu structure so a _shared menu does not have to be passed over the network
//	menu = [
//		action,
//		[
//			//child menu
//			action
//		]
//	];

// _vehicle( optional ) - Object to apply menu to ( default player )

// _shared( optional ) - Clients to also show menu for - follows BIS_fnc_MP convention ( obj, side, client etc ) - ( default false )

// _menuDistance( optional ) - Default distance actions will be visible from, applied to ALL actions, overrides default 15m for non player actions ( default 5m )

// _controls( optional ) - An array of booleans on whether to show default menu navigation options ( default [ true, true, true, false ] )



LARs_fnc_menuUP = {
	private [ "_vehicle", "_child", "_depth" ];

	_vehicle = _this select 0;
	_child = _this select 1;

	//Add passed child index to depth array
	_depth = _vehicle getVariable [ "LARs_menuDepth", [] ];
	_depth pushBack _child;
	_vehicle setVariable [ "LARs_menuDepth", _depth ];

	_vehicle call LARs_fnc_showMenu;
};


LARs_fnc_menuDOWN = {
	private [ "_vehicle", "_depth" ];

	_vehicle = _this;

	//Remove last depth from array
	_depth = _vehicle getVariable [ "LARs_menuDepth", [] ];
	_depth deleteAt (( count _depth ) -1 );
	_vehicle setVariable [ "LARs_menuDepth", _depth ];

	_vehicle call LARs_fnc_showMenu;
};


LARs_fnc_showMenu = {
	private [ "_vehicle", "_addActionCode", "_newMenu", "_childMenus", "_newAction", "_hideOnUse" ];

	_vehicle = _this;

	_vehicle call LARs_fnc_clearMenu;

	//Function to strip out actions from current menu depth
	_fnc_stripActons = {
		private [ "_nextDepth", "_menuItems" ];

		_menuItems = _this;

		_nextDepth = [];
		//Find child menus not actions
		{
			if !( typeName ( _x select 0 ) isEqualTo typeName "" ) then {
				_nextDepth pushBack _x;
			};
		}forEach _menuItems;

			_nextDepth
	};

	//Function to insert code into an actions code param
	_addActionCode = {
		private [ "_action", "_code", "_actionCode" ];

		_action = _this select 0;
		_code = _this select 1;

		_actionCode = str ( _action select 1 );
		_actionCode = _actionCode select [ 1, ( count _actionCode ) - 2 ];
		_actionCode = compile format [ "%1; %2", _code, _actionCode ];
		_action set [ 1, _actionCode ];

		_action
	};

	//Function to insert condition into an actions condition param
	_addActionCondition = {
		private [ "_action", "_condition", "_actionCondition" ];

		_action = _this select 0;
		_condition = _this select 1;

		_actionCondition = ( _action select 7 );
		_actionCondition = format [ "%1; %2", _actionCondition, _condition ];
		_action set [ 7, _actionCondition ];

		_action
	};

	//Get whole menu structure
	_newMenu = +( _vehicle getVariable [ "LARs_activeMenu", [] ] ) ;

	//Traverse depth array to find current menu
	{
		_newmenu = _newMenu call _fnc_stripActons;
		_newMenu = _newMenu select _x;
	}forEach ( _vehicle getVariable [ "LARs_menuDepth", [] ] );

	//Number of child menus in current menu depth
	_childMenus = 0;

	//Sort current menu items
	{
		//If item is an action
		if ( typeName ( _x select 0 ) isEqualTo typeName "" ) then {
			_newAction = _x;

			//Do we have a child menu?
			//If we are not the last item && the next item is a child menu
			if ( _forEachIndex < (( count _newMenu ) - 1 ) && { typeName (( _newMenu select ( _forEachIndex + 1 )) select 0 ) isEqualTo typeName [] } ) then {
				//Insert menuUP into current action
				_newAction = [ _newAction, ( format [ "[ _this select 0, %1 ] call LARs_fnc_menuUP", _childMenus ] ) ] call _addActionCode;
			};

			//Insert global distance condition into action
			//_newAction = [ _newAction, ( format [ " && _this distance _target < %1", _vehicle getVariable "LARs_menuDistance" ] ) ] call _addActionCondition;

			//HideOnUse
			//Expanded functionality for actions hideOnUse param
			_hideOnUse = _newAction select 5;
			//If hiseOnUse is a number
			if ( typeName _hideOnUse isEqualTo typeName 0 ) then {
				switch ( _hideOnUse ) do {
					//Hide default action menu and exit menu system
					case ( -1 ) : {
						_newAction set [ 5, true ];
						_newAction = [ _newAction, "_this select 0 call LARs_fnc_menuExit" ] call _addActionCode;
					};

					//Show default action menu and reset menu system
					case ( 0 ) : {
						_newAction set [ 5, false ];
						_newAction = [ _newAction, "_this select 0 call LARs_fnc_menuReset" ] call _addActionCode;
					};

					//Hide default action menu and reset menu system
					case ( 1 ) : {
						_newAction set [ 5, true ];
						_newAction = [ _newAction, "_this select 0 call LARs_fnc_menuReset" ] call _addActionCode;
					};
				};
			};

			//Add action to vehicle
			_newAction = ( _vehicle addAction _newAction );
			//Save action IDs to vehicle
			_vehicle setVariable [ "LARs_currentActions",  ( _vehicle getVariable [ "LARs_currentActions", [] ] ) + [ _newAction ] ];
		}else{
			//Otherwise item was a child menu
			_childMenus = _childMenus + 1;
		};
	}forEach _newMenu;
};


LARs_fnc_clearMenu = {
	private [ "_vehicle" ];

	_vehicle = _this;

	//Remove current actions
	{
		_vehicle removeAction _x;
	}forEach ( _vehicle getVariable [ "LARs_currentActions", [] ] );

	//Clear action array
	_vehicle setVariable [ "LARs_currentActions", [] ];
};


LARS_fnc_menuReset = {
	private [ "_vehicle" ];

	_vehicle = _this;

	//Clear depth array
	_vehicle setVariable [ "LARs_menuDepth", [] ];

	_vehicle call LARs_fnc_showMenu;
};


LARs_fnc_menuStart = {
	private [ "_defaultActions", "_error" ];

	//*****************************
	//* Process default variables *
	//*****************************

	_error = false;

	//Check menu
	if !( ( _this select [ 0, 1 ] ) params [
		[ "_menu", [], [ [], "" ] ]
	]) then {
		if ( _menu isEqualTo [] || ( typeName _menu isEqualTo typeName "" && { isNil{ missionNamespace getVariable [ _menu, nil ] } } ) ) then {
			"Supplied menu is invalid" call BIS_fnc_error;
			_error = true;
		};
	};

	//Check vehicle
	if !( ( _this select [ 1, 1 ] ) params [
			[ "_vehicle", player, [ objNull ] ]
		]
	) then {
		if ( isNull _vehicle ) then {
			"Supplied object is invalid" call BIS_fnc_error;
			_error = true;
		};
	};

	if ( _vehicle getVariable [ "LARs_menuSystemActive", false ] ) then {
//		format [ "Supplied object ( %1 ) already has an active menu system", _vehicle ] call BIS_fnc_error;
//		_error = true;
		_vehicle call LARs_fnc_menuExit;
	};

	//Exit if there was an error with _vehicle or _menu
	if ( _error ) exitWith { false };

	//Check optional variables
	( _this select [ 2, 2 ] )  params [
		[ "_shared", false, [ objNull, sideUnknown, grpNull, [], true, 0 ] ],		//clients to apply menu to
		[ "_menuDistance", 5, [ 0 ] ],												//Distance to show menu at
		[ "_controls", [ true, true, true, false ], [ [] ], [ 4 ] ]					//Navigation actions to show
	];

	//Start menu on shared clients
	if ( { typeName _shared isEqualTo typeName _x }count [ objNull, sideUnknown, grpNull, [], 0 ] > 0 || ( typeName _shared isEqualTo typeName true && { _shared } ) ) then {
		[ [ _menu, _vehicle, false, _menuDistance, _controls ], "LARs_fnc_menuStart", _shared, true, false ] call BIS_fnc_MP;
	};

	//Exit if we dont have  UI
	if ( !hasInterface ) exitWith {
		false
	};

	//*********
	//* START *
	//*********

	//Apply default actions for meu navigation
	_defaultActions = [];
	{
		if ( _controls select _forEachIndex ) then {
			_defaultActions pushBack ( _vehicle addAction _x );
		};
	}forEach [
		//MENU HIDE - does nothing but hide actionMenu via true in the hide on use param
		["<t color='#FFC403'>[] MENU HIDE</t>", {}, "", -1, false, true, "", format [ "_this distance _target < %1", _menuDistance ] ],  //Always show if menu system is active
		//MENU HOME - Only show if we are deeper than 1 level
		[ "<t color='#FFC403'><img image='\A3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_sidebar_hide_up.paa' size='0.7' /> MENU HOME</t>", { ( _this select 0 ) call LARs_fnc_menuReset }, "", -1, false, false, "", format [ "count ( _target getvariable [ 'LARs_menuDepth', [] ] ) > 1 && _this distance _target < %1", _menuDistance ] ],
		//MENU BACK - Only show if we are deeper than base menu
		[ "<t color='#FFC403'><img image='\A3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_sidebar_show.paa' size='0.7' /> MENU BACK</t>", { ( _this select 0 ) call LARs_fnc_menuDOWN }, "", -20, false, false, "", format [ "count ( _target getvariable [ 'LARs_menuDepth', [] ] ) > 0 && _this distance _target < %1", _menuDistance ] ],
		//MENU EXIT - Remove menu and clear variables
		["<t color='#FFC403'><img image='\A3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_exit_cross_ca.paa' size='0.7' /> REMOVE MENU</t>", { ( _this select 0 ) call LARs_fnc_menuExit }, "", -20, false, false, "", format [ "_this distance _target < %1", _menuDistance ] ]
	];

	//Save menu variables on object
	_vehicle setVariable [ "LARs_defaultActions", _defaultActions ];
	_vehicle setVariable [ "LARs_currentActions", [] ];
	_vehicle setVariable [ "LARs_menuDepth", [] ];
	_vehicle setVariable [ "LARs_menuSystemActive", true ];
	_vehicle setVariable [ "LARs_activeMenu", _menu ];
	_vehicle setVariable [ "LARs_MenuDistance", _menuDistance ];

	_vehicle call LARs_fnc_showMenu;

	//Return success menu start
	true
};


LARs_fnc_menuExit = {
	private [ "_vehicle" ];

	_vehicle = _this;

	_vehicle call LARs_fnc_clearMenu;

	//Clear _vehicle of menu variables
	_vehicle setVariable [ "LARs_menuDepth", nil ];
	_vehicle setVariable [ "LARs_currentActions", nil ];
	_vehicle setVariable [ "LARs_activeMenu", nil ];
	{
		_vehicle removeAction _x;
	}forEach ( _vehicle getVariable [ "LARs_defaultActions", [] ] );
	_vehicle setVariable [ "LARs_defaultActions", nil ];
	_vehicle setVariable [ "LARs_menuSystemActive", nil ];
	_vehicle setVariable [ "LARs_MenuDistance", nil ];
};

LARs_fnc_menuAddItem = {
	private[ "_newMenu", "_find", "_depthX", "_child", "_childMenus", "_nul", "_popped", "_currentDepth" ];

	params[
		[ "_vehicle", objNull, [ objNull ] ],
		[ "_item", [], [ [] ] ],
		[ "_depth", [], [ [] ] ],
		[ "_pos", -1, [ 0 ] ],
		[ "_isGlobal", false, [ false ] ]
	];

	if ( _isGlobal ) then {
		_this set [ 4, false ];
		[ _this, "LARs_fnc_meuAddItem", _isGlobal, false ] call BIS_fnc_MP;
	};

	_newMenu = +( _vehicle getVariable [ "LARs_activeMenu", [] ] );
	_find = _newMenu;

	{
		_depthX = _x;
		_child = -1;
		{
			if ( typeName ( _x select 0 ) isEqualTo typeName [] ) then {
				_child = _child + 1;
				if ( _child isEqualTo _depthX ) exitWith {
					 _find = _x;
				};
			};
		}forEach _find;
	}forEach _depth;

	 _childMenus = 0;
	if ( _pos isEqualTo -1 ) then {
		{
			_nul = _find pushBack _x;
		}forEach _item;
	}else{
		_popped = _find select [ _pos, ( count _find ) -1 ];
		for "_i" from _pos to ( count _find ) -1 do {
			_nul = _find deleteAt _i;
		};
		{
			if !( typeName( _x select 0 ) isEqualTo typeName "" ) then {
				 _childMenus = _childMenus + 1;
			};
			 _find set [ _pos + _forEachIndex, _x ];
		}forEach _item;
		{
			_nul = _find pushBack _x;
		}forEach _popped;
	};

	_currentDepth = _vehicle getVariable [ "LARs_menuDepth", [] ];
	if ( count _currentDepth >= count _depth ) then {
		if (  _childMenus > 0 && { _currentDepth select [ 0, count _depth ] isEqualTo _depth && _currentDepth select ( count _depth ) <= _pos } ) then {
			_currentDepth set [ count _depth, ( _currentDepth select ( count _depth )) +  _childMenus ];
		};
	};

	_vehicle setVariable [ "LARs_activeMenu",  _newMenu ];
	_vehicle call LARs_fnc_showMenu;

	true
};


LARs_fnc_menuRemoveItem = {
	private[ "_newMenu", "_find", "_depthX", "_child", "_childMenu", "_currentDepth" ];

	params[
		[ "_vehicle", objNull, [ objNull ] ],
		[ "_depth", [], [ [] ] ],
		[ "_pos", -1, [ 0 ] ],
		[ "_isGlobal", false, [ false ] ]
	];

	if ( _isGlobal ) then {
		_this set [ 3, false ];
		[ _this, "LARs_fnc_meuAddItem", _isGlobal, false ] call BIS_fnc_MP;
	};

	_newMenu = +( _vehicle getVariable [ "LARs_activeMenu", [] ] );
	_find = _newMenu;

	{
		_depthX = _x;
		_child = -1;
		{
			if ( typeName ( _x select 0 ) isEqualTo typeName [] ) then {
				_child = _child + 1;
				if ( _child isEqualTo _depthX ) exitWith {
					 _find = _x;
				};
			};
		}forEach _find;
	}forEach _depth;

	 _childMenu = false;
	 if ( (( count _find ) -1 ) >= _pos ) then {
	 	if ( (( count _find ) -1 ) > _pos && { typeName( _find select ( _pos + 1 ) select 0 ) isEqualTo typeName [] } ) then {
	 		_nul = _find deleteAt ( _pos + 1 );
	 		 _childMenu = true;
	 	};
	 	_find deleteAt _pos;
	};


	_currentDepth = _vehicle getVariable [ "LARs_menuDepth", [] ];
	if (  _childMenu && { ( _currentDepth select [ 0, count _depth ] ) isEqualTo _depth } ) then {
		_currentDepth = _depth;
	};
	_vehicle setVariable [ "LARs_menuDepth", _currentDepth ];

	_vehicle setVariable [ "LARs_activeMenu",  _newMenu ];

	_vehicle call LARs_fnc_showMenu;

	true
};

LARs_menuSystemInit = true;