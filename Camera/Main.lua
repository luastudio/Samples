-- Main.lua

Event = Lib.Media.Events.Event
Display = Lib.Media.Display
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Geom = Lib.Media.Geom
stage = Display.stage
Camera = Lib.Media.Camera

bitmap = nil

function setBmpSize()
  if bitmap ~= nil then
    local sw = stage.stageWidth
    local sh = stage.stageHeight
    local w = bitmap.bitmapData.width
    local h = bitmap.bitmapData.height
    if w*sh > h*sw then
      bitmap.width = sw
      sh = h*sw/w
      bitmap.height = sh
      bitmap.x = 0
      bitmap.y = (stage.stageHeight-sh)*0.5
    else
      bitmap.height = sh
      sw = w*sh/h
      bitmap.width = sw
      bitmap.y = 0
      bitmap.x = (stage.stageWidth-sw)*0.5
    end
  end
end

function onFrame(e)
  print("onFrame! "..camera.width.."x"..camera.height)
  if camera ~= nil then
    camera.removeEventListener(Event.VIDEO_FRAME,onFrame,false)
    bitmap = Bitmap.new( camera.bitmapData, nil, true )
    stage.addChild(bitmap)
    setBmpSize()
  end
end

print("Camera devices:")
names = Camera.names
if names ~= nil then
  for i = 1, #names do
    camera = Camera.getCamera(names[i]) 
    print("camera: "..camera.name.." ["..camera.width.."x"..camera.height.."] position: "..camera.position)
    camera.destroy()--not all devicess can open multiple cameras, destroy previously created before you can get next camera info
  end

  camera = Camera.getCamera(nil) --get default camera 
  if camera ~= nil then
    print("Found default camera: "..camera.name.." ["..camera.width.."x"..camera.height.."] position: "..camera.position)
    camera.addEventListener(Event.VIDEO_FRAME,onFrame,false,0,false)
    stage.addEventListener(Event.RESIZE, function(e) setBmpSize() end, false, 0, false)
    camera.activate()
  end
else
  print("not found")
end