private _vehicle_references = "";
private _group_references = "";
{
	private _veh = _x;
	private _vid = _forEachIndex;
	{
		if (_veh isKindOf _x) exitWith {
			private _displayName = getText (configFile >> "cfgVehicles" >> (typeOf _veh) >> "displayName");
			//params ['_mrkname', '_cx', '_cy', '_size', '_icon', '_color', '_text',['_shape','icon'],['_condition',{true}],['_replay',false]];
			private _veh_marker = [
				"bn_veh_" + (str _vid), 
				getPos _veh select 0,
				getPos _veh select 1,
				1,
				"hd_dot",
				"ColorWhite",
				_displayName
			] call tu_decoration_fnc_create_marker; //todo: check spelling
			_vehicle_references = _vehicle_references + format ["<marker name = '%1'>%2</marker><br />",_veh_marker,_displayName];
			bn_freezetime_trash_markers pushBack _veh_marker;
		};
	} forEach bn_freezetime_vehicle_classes_to_show;
} forEach vehicles;
// todo: add vehicles tab
{
	if (side _x == side player) then {
		private _group_color = "ColorGreen";
		if (player in (units _x)) then {
			_group_color = "ColorRed";
		};
		
		private _groupName = groupID _x;
		
		private _group_marker = [
			"bn_group_" + (str _forEachIndex), 
			(getPos (leader _x)) select 0,
			(getPos (leader _x)) select 1,
			1,
			"hd_start",
			_group_color,
			_groupName
		] call tu_decoration_fnc_create_marker; //todo: check spelling
		private _units_text = "";
		{
			_units_text = _units_text + format ["  %1 (%2)<br />", name _x, roleDescription _x];
		} forEach (units _x);
		_units_text = _units_text + "<br />";
		_group_references = _group_references + format ["<marker name = '%1'>%2</marker><br />%3",_group_marker,_groupName, _units_text];
		bn_freezetime_trash_markers pushBack _group_marker;
	};
} forEach allGroups;

player createDiaryRecord ["diary", ["Отделения",_group_references]];
player createDiaryRecord ["diary", ["Техника",_vehicle_references]];
