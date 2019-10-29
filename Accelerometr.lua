-- Accelerometr.lua

Accelerometer = Lib.Media.Sensors.Accelerometer
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

local acc1 = Accelerometer.new()
local isSupported = Accelerometer.isSupported

function updateHandler(e)
	text.text = "orientation: "..stage.getOrientation().."\ntimestamp: "..e.timestamp.."\nx: "..e.accelerationX.."\ny: "..e.accelerationY.."\nz: "..e.accelerationZ
end

if (isSupported) then
	print("Accelerometer feature supported")
    acc1.addEventListener(Lib.Media.Events.AccelerometerEvent.UPDATE, updateHandler, false, 0 ,false)
else
	print("Accelerometer feature not supported")
end