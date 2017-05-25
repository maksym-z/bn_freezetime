

bn_freezetime_firedEH = player addEventHandler ["firedMan", {deleteVehicle (_this select 6)}]; // Спасибо товарищам бисам за удобный ивентхендлер

cutRsc ["bn_freeze_timer","PLAIN"];
"bn_freezetime_countdown_minutes_left" addPublicVariableEventHandler {[] call bn_freezetime_fnc_update_timer};
"bn_freezetime_side_ready_array" addPublicVariableEventHandler {[] call bn_freezetime_fnc_update_ready_status};
bn_freezetime_last_legal_position = getPos player;
bn_freezetime_warnings = 0;

waitUntil {
	// check if player is within the freeze zone, or punish them
	// display clock
	if !([] call bn_freezetime_can_move_condition) then {
		bn_freezetime_warnings = bn_freezetime_warnings + 1;
		["SerP_alarm",["", localize "STR_SerP_outOfZone"]] call BIS_fnc_showNotification;
		(vehicle player) setVelocity ((velocity vehicle player) vectorMultiply -1);
		sleep 1;
		if (bn_freezetime_warnings > 3) then {
			player setPos bn_freezetime_last_legal_position;
			bn_freezetime_warnings = 0;
		};
	} else {
		bn_freezetime_last_legal_position = getPos vehicle player;
		bn_freezetime_warnings = (bn_freezetime_warnings - 1) max 0;
	};
	
	sleep 1;
	(missionNamespace getVariable ["SerP_warBegins", 0]) == 1
};
["Серьезные игры на Тушино",localize "STR_SerP_missionname", localize "STR_SerP_author"] spawn BIS_fnc_infoText;
// cleanup shit: remove markers, remove clock, remove firing limitations

player removeEventHandler ["firedMan", bn_freezetime_firedEH];
cutText ["","PLAIN"];
["Начали!"] call SerP_msg;
[] call bn_freezetime_cleanup_code;
{deleteMarkerLocal _x} forEach bn_freezetime_trash_markers;