-- Geolocation.lua

Geolocation = Lib.Media.Sensors.Geolocation
Text = Lib.Media.Text
stage = Lib.Media.Display.stage

local fmt = Text.TextFormat.new('_sans', 30, 0x660000, nil, nil, nil)
local text = Text.TextField.new()
text.defaultTextFormat = fmt
text.autoSize = Text.TextFieldAutoSize.LEFT
text.x = 10
text.y = 10
text.width = 400
text.wordWrap = true
stage.addChild(text)

local geo = Geolocation.new()
local isSupported = Geolocation.isSupported

function updateHandler(e)
	text.text = 
		"\ntimestamp: "..e.timestamp..
		"\naltitude: "..e.altitude..
		"\nlatitude: "..e.latitude..
		"\nlongitude: "..e.longitude..
		"\nhorizontalAccuracy: "..e.horizontalAccuracy..
		"\nverticalAccuracy: "..e.verticalAccuracy..
		"\nspeed: "..e.speed..
		"\nheading: "..e.heading..
        (e.provider and "\nprovider: "..e.provider or "")
end

function statusHandler(e)
    Lib.Sys.trace(e)
	if geo.muted then
    	geo.removeEventListener(Lib.Media.Events.GeolocationEvent.UPDATE, updateHandler, false)
    else
    	geo.addEventListener(Lib.Media.Events.GeolocationEvent.UPDATE, updateHandler, false, 0 ,false)
	end
end

if (isSupported) then
	print("Geolocation feature supported")
    geo.locationAlwaysUsePermission = true --for iOS, declared before request permission
    print(Geolocation.permissionStatus)
    geo.requestPermission() -- required on mobile devices 
    geo.addEventListener(Lib.Media.Events.GeolocationEvent.UPDATE, updateHandler, false, 0 ,false)
    geo.addEventListener(Lib.Media.Events.StatusEvent.STATUS, statusHandler, false, 0 ,false)
else
	print("Geolocation feature not supported")
end