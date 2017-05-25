diag_log "bn freezetime pre init";
[] call compile preprocessFileLineNumbers "SerP\bn_freezetime\_params.sqf";

bn_freezetime_fnc_client_waiting_to_start = compile preprocessFileLineNumbers "SerP\bn_freezetime\fn_client_waiting_to_start.sqf";
bn_freezetime_fnc_local_markers = compile preprocessFileLineNumbers "SerP\bn_freezetime\fn_local_markers.sqf";

bn_leaders_array = [];

bn_fnc_establish_side_leaders = {
	bn_leaders_array = [];
	if (isNil 'bn_freezetime_side_ready_array') then {
		bn_freezetime_side_ready_array = [];
	};
	{
		private _current_side = _x;
		{
			if (side _x == _current_side) exitWith {
				bn_leaders_array pushBack _x;
				_x setVariable ["bn_side_leader",_current_side];
			};
		} forEach playableUnits;
	} forEach [east, west, resistance];
};

SerP_toggleReady = {
	if !(player in bn_leaders_array) exitWith {};
	[player] remoteExec ["bn_toggleReady_srv",2];
};

bn_toggleReady_srv = {
	params ["_caller"];
	if (SerP_warbegins != 0) exitWith {};
	if (_caller in bn_leaders_array) then {
		private _reporting_side = side _caller;
		if (_reporting_side in bn_freezetime_side_ready_array) then {
			bn_freezetime_side_ready_array deleteAt (bn_freezetime_side_ready_array find _reporting_side);
		} else {
			bn_freezetime_side_ready_array pushBack _reporting_side;
		};
	};
	if (count bn_leaders_array == count bn_freezetime_side_ready_array) then {
		[] call bn_freezetime_over;
	};
	
	publicVariable "bn_freezetime_side_ready_array";
};

bn_freezetime_draw_ellipse = {
	params ["_position","_radius"];
	private _cx = _position select 0;
	private _cy = _position select 1;
	private _ellipse = createMarkerLocal [format ["ellipse_%1_%2_%3",_cx, _cy,floor(time)], [_cx, _cy]];
	_ellipse setMarkerSizeLocal [_radius, _radius];
	_ellipse setMarkerShapeLocal "ELLIPSE";
	_ellipse setMarkerColorLocal "ColorGreen";
	_ellipse setMarkerAlphaLocal 0.5;
	_ellipse
};

bn_freezetime_fnc_update_timer = {
	disableSerialization;
	private _minutes_str = str (bn_freezetime_countdown_minutes_left);
	private _formatMinutes = "минут";
	private _display = uiNamespace getVariable ['bn_freeze_timer_display', displayNull];
	if ((bn_freezetime_countdown_minutes_left < 5) or (bn_freezetime_countdown_minutes_left > 20)) then {
		switch (bn_freezetime_countdown_minutes_left % 10) do {
			case 1: {_formatMinutes = "минута"};
			case 2;
			case 3; 
			case 4: {_formatMinutes = "минуты"};
		};
	};
	diag_log _display;
	diag_log (str _display);
	if !(isNull _display) then {
		(_display displayCtrl 411001) ctrlSetText (format ["До старта %1 %2.",bn_freezetime_countdown_minutes_left,_formatMinutes]);
	};
};

bn_freezetime_fnc_update_ready_status = {
	disableSerialization;
	private _display = uiNamespace getVariable ['bn_freeze_timer_display', displayNull];
	private _controls = [411003, 411004, 411005];
	private _sides = [east, west, resistance];
	private _side_descriptions = ["Красные","Синие","Зеленые"];
	private _ignore_side = civilian;
	if !(isNull _display) then {
		if (player in bn_leaders_array && !((side player) in bn_freezetime_side_ready_array)) then {
			_ignore_side = side player;
			private _ctrl_index = _sides find (side player);
			if (_ctrl_index > -1) then {
				(_display displayCtrl (_controls select _ctrl_index)) ctrlSetText "Готов? Правый Ctrl + меню";
			};
		} else {	
			_ignore_side = civilian;
		};
		{
			if (_x != _ignore_side) then {
				if (_x in bn_freezetime_side_ready_array) then {
					(_display displayCtrl (_controls select _forEachIndex)) ctrlSetText (format ["%1 готовы",_side_descriptions select _forEachIndex]);
				} else {
					(_display displayCtrl (_controls select _forEachIndex)) ctrlSetText "";
				};
			};
		} forEach _sides;
	};
};

bn_freezetime_over = {
	SerP_warbegins=1;
	publicVariable "SerP_warbegins";
	{
		if (!(isPlayer _x)&&!(_x getVariable ["SerP_isPlayer",false])) then {
			_x setPos [30000,0,100];
			deleteVehicle _x;
		};
	} forEach playableUnits;
};

// TODO: stick this all into a function
call SerP_addSeparatorToMenu;
_isEndBriefingCommanderAvailable = {
	((player in bn_leaders_array) && SerP_warbegins == 0)
};
["End briefing", 0, {call SerP_toggleReady}, _isEndBriefingCommanderAvailable, _isEndBriefingCommanderAvailable] call SerP_addToMenu;
call SerP_addSeparatorToMenu;
_isEndBriefingAdminAvailable = {
	(((serverCommandAvailable "#kick")||isServer) && SerP_warbegins == 0)
};
_endBriefingAdmin = {
	["All ready ("+name player+")"] call SerP_msg;
	[] remoteExec ["bn_freezetime_over",2];
};
["End briefong(Admin)", 0, _endBriefingAdmin, _isEndBriefingAdminAvailable, _isEndBriefingAdminAvailable] call SerP_addToMenu;
// up to here