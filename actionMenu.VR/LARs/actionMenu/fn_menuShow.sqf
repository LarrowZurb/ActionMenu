
params[ "_vehicle" ];

[ _vehicle ] call LARs_fnc_menuClear;

//Function to strip out actions from current menu depth
_fnc_stripActons = {
	params[ "_menuItems" ];

	private _nextDepth = [];
	//Find child menus not actions
	{
		if !( ( _x select 0 ) isEqualType "" ) then {
			private _nul = _nextDepth pushBack _x;
		};
	}forEach _menuItems;

	_nextDepth
};

//Function to insert code into an actions code param
_addActionCode = {
	params[ "_action", "_code" ];

	private _actionCode = str ( _action select 1 );
	_actionCode = _actionCode select [ 1, ( count _actionCode ) - 2 ];
	_actionCode = compile format [ "%1; %2", _code, _actionCode ];
	_action set [ 1, _actionCode ];

	_action
};

//Function to insert condition into an actions condition param
_addActionCondition = {
	params[ "_action", "_condition" ];

	private _actionCondition = ( _action select 7 );

	_actionCondition = if ( count ( toArray _actionCondition - toArray " " ) isEqualTo 0 ) then {	//Could break
		_condition;
	}else{
		format[ "[ _this, _target ]call{ _target =_this select 1; _this = _this select 0;  %1  } && %2", _actionCondition, _condition ];
	};

	_action set [ 7, _actionCondition ];

	_action
};

//Get whole menu structure
private _newMenu = +( _vehicle getVariable [ "LARs_activeMenu", [] ] ) ;

//Traverse depth array to find current menu
{
	_newmenu = [ _newMenu ] call _fnc_stripActons;
	_newMenu = _newMenu select _x;
}forEach ( _vehicle getVariable [ "LARs_menuDepth", [] ] );

//Get any menuPrefix provided in the description.ext
private _prefix = [ "  >  ", getText( missionConfigFile >> "LARs_actionMenuPrefix" ) ] select isText( missionConfigFile >> "LARs_actionMenuPrefix" );
_prefix = _prefix + "%1";

//Number of child menus in current menu depth
private _childMenus = 0;

//Sort current menu items
{
	//If item is an action
	if ( ( _x select 0 ) isEqualType "" ) then {
		private _newAction = _x;

		//Do we have a child menu?
		//If we are not the last item && the next item is a child menu
		if ( _forEachIndex < (( count _newMenu ) - 1 ) && { (( _newMenu select ( _forEachIndex + 1 )) select 0 ) isEqualType [] } ) then {
			//Insert menuUP into current action
			_newAction = [ _newAction, ( format [ "[ _this select 0, %1 ] call LARs_fnc_menuUP", _childMenus ] ) ] call _addActionCode;
		};

		_newAction set[ 0, format[ _prefix, _newAction select 0 ] ];

		//Insert global distance condition into action
		_newAction = [ _newAction, ( format [ "_this distance _target < %1", _vehicle getVariable "LARs_menuDistance" ] ) ] call _addActionCondition;

		//HideOnUse
		//Expanded functionality for actions hideOnUse param
		_hideOnUse = _newAction select 5;
		//If hiseOnUse is a number
		if ( _hideOnUse isEqualType 0 ) then {
			switch ( _hideOnUse ) do {
				//Hide default action menu and exit menu system
				case ( -1 ) : {
					_newAction set [ 5, true ];
					_newAction = [ _newAction, "[ _this select 0 ] call LARs_fnc_menuExit" ] call _addActionCode;
				};

				//Show default action menu and reset menu system
				case ( 0 ) : {
					_newAction set [ 5, false ];
					_newAction = [ _newAction, "[ _this select 0 ] call LARs_fnc_menuReset" ] call _addActionCode;
				};

				//Hide default action menu and reset menu system
				case ( 1 ) : {
					_newAction set [ 5, true ];
					_newAction = [ _newAction, "[ _this select 0 ] call LARs_fnc_menuReset" ] call _addActionCode;
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
