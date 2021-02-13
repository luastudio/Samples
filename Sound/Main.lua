-- Main.lua

Audio = Lib.Media.Audio
Text = Lib.Media.Text
Events = Lib.Media.Events
Display = Lib.Media.Display
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Geom = Lib.Media.Geom
stage = Display.stage

sysName = Lib.Media.System.systemName()
desktop = true
if sysName == "android" or sysName == "ios" then
	desktop = false
end

function playMusic(path)
	local bytes = Lib.Project.getBytes(path)
	local sound = Audio.Sound.new(nil, nil, false, nil)
	sound.loadCompressedDataFromByteArray(bytes, bytes.length, true, nil)
	channel = sound.play(0, 1, nil)
	if channel == nil then
		print("Could not play '" .. path .. "' on this system.")
	else
		channel.addEventListener(Events.Event.SOUND_COMPLETE, 
			function (e)
				print("Complete - play " .. path)
			end, false, 0, false)
	end
end

local bmp = Bitmap.new(BitmapData.loadFromBytes(Lib.Project.getBytes("/Sound/data/drum_kit.jpg"), nil), Display.PixelSnapping.AUTO, true)
stage.addChild(bmp)

if desktop then
	playMusic("/Sound/data/Party_Gu-Jeremy_S-8250_hifi.ogg")
else
	playMusic("/Sound/data/Party_Gu-Jeremy_S-8250_hifi.mp3")
end