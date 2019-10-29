-- Main.lua (WARNING: require internet connection)

Audio = Lib.Media.Audio
Display = Lib.Media.Display
Events = Lib.Media.Events
Sprite = Display.Sprite
Geom = Lib.Media.Geom
Net = Lib.Media.Net
stage = Display.stage

BACK = 0
PLAY = 1
PAUSE = 2
STOP = 3
NEXT = 4

PROGRESS_SIZE = 30

playing = true
metaData = nil
duration = 0
volume = 0.5
videoWidth = 0
videoHeight = 0

buttonData = Display.BitmapData.loadFromBytes(Lib.Project.getBytes("/Video/assets/buttons.png"), nil)
button = Sprite.new()
button.addEventListener(Events.MouseEvent.CLICK,
function (e)
	playing = not playing
	if playing then
         setButton(PAUSE)
         stream.resume()
	else
         setButton(PLAY)
         stream.pause()
	end
end, false, 0, false)

function setButton(inMode)
	buttonAction = inMode

	local gfx = button.graphics
	gfx.clear()
	mtx = Geom.Matrix.new(1, 0, 0, 1, 0, 0)
	mtx.translate( -inMode*60, 0 )
	gfx.beginBitmapFill( buttonData, mtx, true, false )
	gfx.drawRect(0,0,60,52)
	button.x = (stage.stageWidth-60)* 0.5
	button.y = (stage.stageHeight-52)* 0.5
end

setButton(PAUSE)
stage.addChild(button)

progress = Sprite.new()
stage.addChild(progress)
progress.addEventListener(Events.MouseEvent.MOUSE_DOWN,
function (e)
	stage.addEventListener(Events.MouseEvent.MOUSE_MOVE, onSeek, false, 0, false)
	stage.addEventListener(Events.MouseEvent.MOUSE_UP, endSeek, false, 0, false)
end, false, 0, false)

function onSeek(evt)
	local fraction = evt.stageX / stage.stageWidth
	stream.seek(fraction * duration)
end

function updateProgress()
	local w = stage.stageWidth
	progress.y = stage.stageHeight - PROGRESS_SIZE
	local gfx = progress.graphics
	gfx.clear()

	if duration > 0 then
		local t = stream.time
		local total = stream.bytesTotal
		local loaded = stream.bytesLoaded

		gfx.lineStyle(1, 0xffffff, 1.0, false, nil, nil, nil, 3)
		gfx.beginFill(0x808080, 0.5)
		gfx.drawRect(0.5, 0.5, w-1, PROGRESS_SIZE-1)
		gfx.lineStyle(nil, 0, 1.0, false, nil, nil, nil, 3)

		if total > 0 then
			gfx.beginFill(0x5050ff, 1.0)
			gfx.drawRect(2, 2, (w-4)*loaded/total, PROGRESS_SIZE-4)
		end
		gfx.beginFill(0x8080ff, 1.0)
		gfx.drawRect(2, 2, (w-4)*t/duration, PROGRESS_SIZE-4)
	else
		gfx.beginFill(0x808080, 0.5)
		gfx.drawRect(0.5, 0.5, w-1, PROGRESS_SIZE-1)
	end
end

stage.addEventListener(Events.Event.ENTER_FRAME, 
function (e)
	updateProgress()
end, false, 0, false)

volumeControl = Sprite.new()
stage.addChild(volumeControl)
function updateVolume()
	local gfx = volumeControl.graphics
	gfx.clear()
	gfx.lineStyle(1, 0xffffff, 1.0, false, nil, nil, nil, 3)
	gfx.beginFill(0x00ff00, 0.3)
	gfx.drawRect(0.5, 0.5, 20, 100)
      
	gfx.lineStyle(nil, 0, 1.0, false, nil, nil, nil, 3)
	gfx.beginFill(0x00ff00, 1.0)
	gfx.drawRect(1.5, (1-volume)*100, 18, volume*100)
end
function onVolume(evt)
	local pos = volumeControl.globalToLocal( Geom.Point.new(evt.stageX, evt.stageY) )
	volume = 1.0 - pos.y * 0.01
	if volume < 0 then
		volume = 0.0
	end
	if volume>1 then
		volume = 1.0
	end
	updateVolume()

	stream.soundTransform = Audio.SoundTransform.new(volume, 0.0)
end
function endVolume(evt)
	stage.removeEventListener(Events.MouseEvent.MOUSE_MOVE, onVolume, false)
	stage.removeEventListener(Events.MouseEvent.MOUSE_UP, endVolume, false)
end
volumeControl.addEventListener(Events.MouseEvent.MOUSE_DOWN,
function (e)
	stage.addEventListener(Events.MouseEvent.MOUSE_MOVE, onVolume, false, 0, false)
	stage.addEventListener(Events.MouseEvent.MOUSE_UP, endVolume, false, 0, false)
end, false, 0, false)
volumeControl.x = 10
volumeControl.y = (stage.stageHeight-100) * 0.5
updateVolume()

function centreVideo()
	local video = stage.stageVideos[1]
	if videoWidth < 1 or videoHeight < 1 or video == nil then
		return
	end

	local sx = stage.stageWidth / videoWidth
	local sy = stage.stageHeight / videoHeight
	local scale = sx < sy and sx or sy

	video.viewPort = Geom.Rectangle.new((stage.stageWidth - videoWidth*scale) / 2,
                (stage.stageHeight - videoHeight*scale) / 2,
                videoWidth*scale,
                videoHeight*scale) 
end

function netStatusHandler(event)
	print("Net status: ")
    Lib.Sys.trace( event.info )
	local code = event.info.code
	if code == "NetConnection.Connect.Success" then
		print("You've connected successfully")
	elseif code == "NetStream.Publish.BadName" then
		print("Please check the name of the publishing stream")
	elseif code == "NetStream.Seek.Notify" then
		print("Seek complete")
	end
end

if #stage.stageVideos < 1 or stage.stageVideos[1] == nil then
	print("No video available")
else
	local video = stage.stageVideos[1]
	local nc = Net.NetConnection.new()
	nc.connect(nil, nil, nil, nil,nil, nil)
	nc.addEventListener(Events.NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, false)

	stream = Net.NetStream.new(nc, nil)
	local client = {}
	client.onMetaData = function(data)
		metaData = data
		duration = metaData.duration
		print("metaData "..data.width..","..data.height.." for "..duration)
		videoWidth = data.width
		videoHeight = data.height
		centreVideo()
	end
	client.onPlayStatus = function(item)
		print("onPlayStatus "..item)
	end
	stream.client = client
	stream.addEventListener(Events.AsyncErrorEvent.ASYNC_ERROR,
	function (e)
		print("asyncErrorHandler " .. event)
	end, false, 0, false)
	stream.addEventListener(Events.NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, false)

	--video.viewPort = new nme.geom.Rectangle(0,0,500,500)
	video.addEventListener(Events.StageVideoEvent.RENDER_STATE, 
	function (ev)
		trace(ev.status)
	end, false, 0, false)
	video.attachNetStream(stream)
	stream.play("https://media.w3.org/2010/05/sintel/trailer.mp4", 0.0, -1, nil, nil)

	--stage.addEventListener(Events.Event.ENTER_FRAME, 
	--function(e) 
		--print(stream.bytesLoaded)
	--end, false, 0, false)
	stage.addEventListener(Events.Event.RESIZE, function(e) 
		setButton(buttonAction)
		updateVolume()
		updateProgress()
		centreVideo()
	end, false, 0, false)
end
