diag_log "bn freezetime client post init";
SerP_trashArray = [];
bn_freezetime_trash_markers = [];
[] call bn_fnc_establish_side_leaders;
bn_freezetime_can_move_condition = {};
bn_freezetime_cleanup_code = {};


if (isNil 'bn_freezetime_zone_array') then {
	bn_freezetime_zone_array = [];  // Redefine this before init for custom zone settings
	// ["player inclusion condition", "player can move condition", "startup code", "cleanup code"]
};

if ([side player, SerP_sideREDFOR] call BIS_fnc_sideIsFriendly) then {
	bn_freeze_zone_radius = SerP_zoneSizeREDFOR; //TODO: check spelling
} else {
	bn_freeze_zone_radius = SerP_zoneSizeBLUEFOR;
};

//default condition, if none of the prior conditions were met:
bn_freezetime_zone_array pushBack [
	"true",
	"_vehicle distance bn_freeze_start_pos < bn_freeze_zone_radius",
	"bn_freeze_start_pos = getPos player; bn_freezetime_trash_markers pushBack ([getPos player, bn_freeze_zone_radius] call bn_freezetime_draw_ellipse);"
]; 
//TODO: Ensure this is only run in absence of other conditions through exitWith!

waitUntil{player==player};
setViewDistance SerP_viewDistance;
if (count(playableUnits)==0||!alive(player)) exitWith {};//костыль для запуска в синглплеерном редакторе

[] call bn_freezetime_fnc_local_markers;

// select the first matching condition
{
	_x params ["_include_condition","_can_move_condition",["_init_code",""],["_cleanup_code",""]];
	if ([] call compile _include_condition) exitWith {
		bn_freezetime_can_move_condition = compile ("params [['_vehicle', player]];" + _can_move_condition);
		[] call compile _init_code; // TODO: need any params?
		bn_freezetime_cleanup_code = compile _cleanup_code;
	};
} forEach bn_freezetime_zone_array;


// BRIEFING ENDS HERE
sleep .1; 

player setVariable ["SerP_isPlayer",true,true];

[] spawn bn_freezetime_fnc_client_waiting_to_start;

/*
["SerP_alarm",["", localize "STR_SerP_outOfZone"]] call BIS_fnc_showNotification;
(vehicle player) setVelocity [0,0,0];
sleep 3;