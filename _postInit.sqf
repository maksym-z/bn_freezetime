if (isServer) then {
	[] spawn compile preprocessFileLineNumbers "SerP\bn_freezetime\post_init_server.sqf";
};

if (!isDedicated) then {
	[] spawn compile preprocessFileLineNumbers "SerP\bn_freezetime\post_init_client.sqf";
};