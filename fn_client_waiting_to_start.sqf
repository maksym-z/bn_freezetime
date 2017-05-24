

_firedEH = player addEventHandler ["firedMan", {deleteVehicle (_this select 6)}]; // Спасибо товарищам бисам за удобный ивентхендлер

waitUntil {
	// check if player is within the freeze zone, or punish them
	// display clock
	(missionNamespace getVariable ["SerP_warBegins", 0]) == 1
};

// cleanup shit: remove markers, remove clock, remove firing limitations

player removeEventHandler ["firedMan", _firedEH];
[] call bn_freezetime_cleanup_code;
{deleteMarkerLocal _x} forEach bn_freezetime_trash_markers;