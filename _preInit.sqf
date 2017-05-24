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
	} forEach [east, west, resistance, civilian];
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
		SerP_warbegins=1;
		publicVariable "SerP_warbegins";
	};
	
	publicVariable "bn_freezetime_side_ready_array";
};

bn_freezetime_draw_ellipse = {
	params ["_position","_radius"];
	_cx = _position select 0;
	_cy = _position select 1;
	private _ellipse = createMarkerLocal [format ["ellipse_%1_%2_%3",_cx, _cy,floor(time)], [_cx, _cy]];
	_ellipse setMarkerSizeLocal [_radius, _radius];
	_ellipse setMarkerShapeLocal "ELLIPSE";
	_ellipse setMarkerColorLocal "ColorGreen";
	_ellipse setMarkerAlphaLocal 0.5;
	_ellipse
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
	SerP_warbegins=1;
	publicVariable "SerP_warbegins";
};
["End briefong(Admin)", 0, _endBriefingAdmin, _isEndBriefingAdminAvailable, _isEndBriefingAdminAvailable] call SerP_addToMenu;
// up to here