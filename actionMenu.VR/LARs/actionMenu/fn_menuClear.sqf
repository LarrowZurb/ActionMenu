
params[ "_vehicle" ];

//Remove current actions
{
	_vehicle removeAction _x;
}forEach ( _vehicle getVariable [ "LARs_currentActions", [] ] );

//Clear action array
_vehicle setVariable [ "LARs_currentActions", [] ];
