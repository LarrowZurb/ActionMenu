//Nothing in this file is needed for the actionMenu system to work
//This is here as an example

hint format[ "There are two items in your action menu as examples of adding and removing items from the actionMenu\n\n
The green one will insert an option in the menu in Menu 1-0 call 'Inserted Option'\n\n
The red one will remove an item in Menu 1-0 at position 1\n\n
Both the player and the ammo crate infront of you have an actionMenu applied to them\n
Bringing up the actionMenu and looking at the crate will temporarily disable the players menu and show you the crates menu.
" ];


menu = [
	[ "Menu 0", {}, [], -1, false, false, "", "" ],
	[
		[ "Option 0", {hint "This is option 0 of sub menu 0"}, [], -1, false, false, "", "" ],
		[ "Option 1", {hint "This is option 1 of sub menu 0"}, [], -1, false, false, "", "" ]
	],
	[ "Menu 1", {}, [], -1, false, false, "", "" ],
	[
		[ "Option 0", {hint "This is option 0 of sub menu 1"}, [], -1, false, false, "", "" ],
		[ "Option 1", {hint "This is option 1 of sub menu 1"}, [], -1, false, false, "", "" ],
		[ "Menu 1-0", {}, [], -1, false, false, "", "" ],
		[
			[ "Option 0", {hint "This is option 0 of sub menu 1-0"}, [], -1, false, false, "", "" ],
			[ "Option 1", {hint "This is option 1 of sub menu 1-0"}, [], -1, false, false, "", "" ]
		]
	]
];
[ menu, player, false, 5, [ true, true, true, false ] ] call LARs_fnc_menuStart;

player addAction [ "<t color='#00ff00'>Insert menu item</t>", {
	hint format[ "An option has been inserted in the actionMenu at\nMenu 1-0\nUse the Remove action to delete it" ];
	newMenu = [
		[ "Inseted Option", {hint "This option was inserted into Menu 1-0"}, [], -1, false, false, "", "" ]
	];
	[ player, newMenu, [ 1, 0 ], 1 ] call LARs_fnc_menuAddItem;
}, [], -25, false, false, "", "" ];

player addAction [ "<t color='#ff0000'>Remove menu item</t>", {
	hint format[ "The item inserted in\nMenu 1-0\nhas been removed" ];
	[ player, [ 1, 0 ], 1 ] call LARs_fnc_menuRemoveItem;
}, [], -25, false, false, "", "" ];