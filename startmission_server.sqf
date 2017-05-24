if (count(playableUnits)==0) exitWith {};
SerP_trashArray = [];
SerP_planeList = [];
_bCounter = {
	_briefingTime = (_this select 0);
	SerP_warbegins = 0;publicVariable "SerP_warbegins";
	waitUntil{
		[["SerP_freeztimeCounter",["", format [localize "STR_SerP_freeztimeCounter",_briefingTime]]]] call SerP_notification;
		_waitTime = diag_tickTime + 60;
		waitUntil{sleep 5;diag_tickTime>_waitTime};
		_briefingTime = _briefingTime - 1;
		(_briefingTime<1)||(SerP_warbegins==1)
	};
	SerP_warbegins = 1;publicVariable "SerP_warbegins";
};

switch (SerP_briefingMode) do	{
	case 0:	{
		[3] spawn _bCounter;
	};
	case 1:	{
		[7] spawn _bCounter;
	};
	case 2:	{
		[10] spawn _bCounter;
	};
	case 3:	{
		[15] spawn _bCounter;
	};
};

SerP_warbegins = 0;publicVariable "SerP_warbegins";
SerP_readyArray = [false,false];publicVariable "SerP_readyArray";
//find zones
_getZoneSize = {
	_side = _this;
	switch true do {
		case (_side==SerP_sideREDFOR): {SerP_zoneSizeREDFOR};
		case (_side==SerP_sideBLUEFOR): {SerP_zoneSizeBLUEFOR};
		default {SerP_zoneSizeDefault};
	};
};
"zoneListStart" call SerP_debug;
_zones = _getZoneSize call SerP_getZones;
"zoneListEnd" call SerP_debug;
_objectList = (allMissionObjects "Plane")+(allMissionObjects "LandVehicle")+(allMissionObjects "Helicopter")+(allMissionObjects "Ship")+(allMissionObjects "ReammoBox_F");
//teleportarium
SerP_startSeed = round(random(1000+({isPlayer(_x)} count playableUnits)));
_zoneSelector = {
	_zonesToTeleport = _this;
	switch true do {
		case (count(_zonesToTeleport)==0): {0};
		case (SerP_synchronizedRespawn!=0): {(SerP_startSeed%(count(_zonesToTeleport)+1))};
		case (SerP_synchronizedRespawn==0): {round(random(1000+({isPlayer(_x)} count playableUnits)))%(count(_zonesToTeleport)+1)};
		default {0};
	};
};
"teleportListStart" call SerP_debug;
_res = [_zones, _zoneSelector] call SerP_getTeleportList;
"teleportListEnd" call SerP_debug;
_zones = _res select 0;
_teleportList = _res select 1;

SerP_startMarkers = [];
call SerP_commitMarkers;
//end teleportarium
[_zones,_objectList,_teleportList] spawn {
	_zones = _this select 0;
	_objectList = _this select 1;
	_teleportList = _this select 2;
	sleep .1;
	if (count(_teleportList)>0) then {
		{(_x select 0) setPos (_x select 1)} forEach _teleportList; //move objects
		sleep 1;
	};
	_actionList = [];
	_SerP_startZones = [];
	_exludeCondition = SerP_vehHolderExludeCondition;
	_exludeCondition = if (_exludeCondition == "") then {
		false
	}else{
		compile ("_object = _this select 0;_side = _this select 1;("+_exludeCondition+")")
	};
	{
		_corepos = _x select 0;
		_size = _x select 1;
		_side = _x select 3;
		_core = createVehicle ["FlagChecked_F", [_corepos select 0,_corepos select 1, -3], [], 0, "CAN_COLLIDE"];
		_core setPos [_corepos select 0,_corepos select 1, -3];
		_corepos = getPosASL _core;
		SerP_trashArray set [count SerP_trashArray, _core];
		{
			_objectPos = getPosASL _x;
			_distanceToCore = [_objectPos select 0,_objectPos select 1,0] distance [_corepos select 0,_corepos select 1,0];
			if ((_distanceToCore<SerP_hintzonesize+_size)&&!(_x isKindOf "StaticWeapon")&&!([_x,_side] call _exludeCondition)&&locked(_x)<2) then {
				_unitpos = getPosASL _x;
				_diff = [((_unitpos select 0) - (_corepos select 0)),((_unitpos select 1) - (_corepos select 1)),((_unitpos select 2) - (_corepos select 2))];
				_actionList set [count _actionList,[_x,[_core,[(_diff select 0),(_diff select 1),((_diff select 2) - (((boundingBox _x) select 0) select 2) - 1.5)]],[(vectorDir _x),(vectorUp _x)]]];
			};
		}forEach _objectList;
		_helper = createVehicle ["Sign_arrow_F", _corepos, [], 0, "CAN_COLLIDE"];
		_actionList set [count _actionList,[_helper,[_core,[0,0,-5]],[[1,0,0],[0,0,1]]]];
		SerP_trashArray set [count SerP_trashArray, _helper];
		_SerP_startZones set [count _SerP_startZones,[[_corepos select 0,_corepos select 1,0],_size,_core,_helper]];
	} forEach _zones;
	{
		(_x select 0) attachTo (_x select 1);
		(_x select 0) setVectorDirAndUp (_x select 2);
		(_x select 0) setVelocity [0,0,-100];
		["attach",(_x select 0),typeof(_x select 0)] call SerP_debug;
	} forEach _actionList;
	SerP_startZones = +_SerP_startZones;
	publicVariable "SerP_startZones";publicVariable "SerP_warbegins";publicVariable "SerP_readyArray";

	//control
	_oneSide = ({isPlayer(_x)&&(side(_x)==SerP_sideBLUEFOR)} count playableUnits == 0)||({isPlayer(_x)&&(side(_x)==SerP_sideREDFOR)} count playableUnits == 0);
	waitUntil{sleep 1;((SerP_readyArray select 0)&&(SerP_readyArray select 1))||(((SerP_readyArray select 0)||(SerP_readyArray select 1))&&_oneSide)||(SerP_warbegins==1)};

	{
		call compile format["SerP_markers_%1 = [['all'],[]];",_x];
	} forEach [east,west,resistance,civilian];
	call SerP_commitMarkers;
	SerP_warbegins=1;publicVariable "SerP_warbegins";
	SerP_warbeginsTime=time;publicVariable "SerP_warbeginsTime";
	'logic' createUnit [[0,0,0], createGroup sideLogic,'
		if isServer then {
			{if (!(isPlayer _x)&&!(_x getVariable "SerP_isPlayer")) then {
				_x setPos [30000,0,100];
				deleteVehicle _x;
			}} forEach playableUnits;
		};
		["SerP_warbegins",["", localize "STR_SerP_warBegins"]] call BIS_fnc_showNotification;
		{
			if (local _x) then {
				switch true do {
					case ((_x isKindOf "Plane")&&(((getPos _x) select 2) > 20)): {
						detach _x;
						_x setVelocity [(sin(getDir _x) * 100),(cos(getDir _x) * 100),20];
					};
					case (((_x isKindOf "LandVehicle")&&(!(_x isKindOf "StaticWeapon")))||(_x isKindOf "Air")||(_x isKindOf "Ship")): {
						_pos = getPosATL _x;
						if (surfaceIsWater _pos) then {
							_pos = getPosASL _x;
							detach _x;
							_x setPosASL _pos;
							if (_pos select 2 > 0) then {
								_x setVelocity [0,0,-1];
							};
						} else {
							detach _x;
							_x setPosATL _pos;
							if (_pos select 2 > 0) then {
								_x setVelocity [0,0,-1];
							};
						};
					};
				};
			};
		} forEach ((allMissionObjects "Plane")+(allMissionObjects "LandVehicle")+(allMissionObjects "Helicopter")+(allMissionObjects "Ship"));
		{deleteVehicle _x} forEach SerP_trashArray;
		this spawn {
			sleep 4;
			deleteVehicle _this;
		}
	', 0.6, 'corporal'];
};
