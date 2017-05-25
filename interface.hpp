class RscTitles {
	class bn_freeze_timer {
		idd = 411512;
		duration = 30*60;
		name = "New Freeze Timer";
		onLoad = "uiNamespace setVariable ['bn_freeze_timer_display', _this select 0]";
		onUnload = "hint 'done'";
		
	
		class RscText;
		class RscCheckbox;
		class controlsBackground {
			class RscText_1000: RscText
			{
				idc = 411001;
				text = "";
				x = 0.2 * safezoneW + safezoneX;
				y = 0 * safezoneH + safezoneY;
				w = 0.6 * safezoneW;
				h = 0.05 * safezoneH;
				colorText[] = {1,1,1,0.8};
				colorBackground[] = {0,0,0,0};
				sizeEx = 0.04 * safezoneH;
				type = 0;
				style = 2;
				font = "EtelkaNarrowMediumPro";
			};
			class RscText_1002: RscText_1000
			{
				idc = 411003;
				text = "";
				x = 0.205 * safezoneW + safezoneX;
				y = 0.048 * safezoneH + safezoneY;
				w = 0.1 * safezoneW;
				h = 0.02 * safezoneH;
				colorText[] = {1,0.6,0.6,0.8};
				sizeEx = 0.015 * safezoneH;
				type = 0;
				style = 2;
				font = "TahomaB"
			};
			class RscText_1003: RscText_1000
			{
				idc = 411004;
				text = "";
				x = 0.405 * safezoneW + safezoneX;
				y = 0.048 * safezoneH + safezoneY;
				w = 0.1 * safezoneW;
				h = 0.02 * safezoneH;
				colorText[] = {0.6,0.6,1,0.8};
				sizeEx = 0.015 * safezoneH;
				type = 0;
				style = 2;
				font = "TahomaB"
			};
			class RscText_1004: RscText_1000
			{
				idc = 411005;
				text = "";
				x = 0.605 * safezoneW + safezoneX;
				y = 0.048 * safezoneH + safezoneY;
				w = 0.1 * safezoneW;
				h = 0.02 * safezoneH;
				colorText[] = {0.6,1,0.6,0.8};
				sizeEx = 0.015 * safezoneH;
				type = 0;
				style = 2;
				font = "TahomaB"
			};
		};
	};
};