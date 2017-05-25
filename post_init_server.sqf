//TODO: timer and stuff
SerP_warBegins = 0;
publicVariable "SerP_warBegins";
[] call bn_fnc_establish_side_leaders;
bn_freezetime_countdown_minutes_left = switch (SerP_briefingMode) do	{
	case 0:	{3};
	case 1:	{7};
	case 2:	{10};
	case 3:	{15};
	default {10};
};
sleep 0.1;
bn_freezetime_countdown_end = diag_tickTime + bn_freezetime_countdown_minutes_left * 60;

bn_freezetime_last_tick = bn_freezetime_countdown_minutes_left + 1;
waitUntil {
	bn_freezetime_countdown_minutes_left = ceil ((bn_freezetime_countdown_end - diag_tickTime) / 60);
	if (bn_freezetime_countdown_minutes_left < bn_freezetime_last_tick) then {
		publicVariable "bn_freezetime_countdown_minutes_left";
		if (!isDedicated) then {
			[] call bn_freezetime_fnc_update_timer;
			[] call bn_freezetime_fnc_update_ready_status;
		};
	};
	sleep 3;
	bn_freezetime_countdown_minutes_left <= 0
};

[] call bn_freezetime_over;

