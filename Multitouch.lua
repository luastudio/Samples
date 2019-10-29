-- Multitouch.lua

Events = Lib.Media.Events
Display = Lib.Media.Display
Sprite = Display.Sprite
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Capabilities = Lib.Media.Capabilities
stage = Display.stage

radius = 50

sp = Sprite.new()
sp.graphics.beginFill(0x00FF00,1)
sp.graphics.drawCircle(radius,radius,radius)
sp.graphics.endFill()
sp.cacheAsBitmap = true

sp2 = Sprite.new()
sp2.graphics.beginFill(0x0000FF,1)
sp2.graphics.drawCircle(radius,radius,radius)
sp2.graphics.endFill()
sp2.cacheAsBitmap = true

if Lib.Media.UI.Multitouch.supportsTouchEvents then
  Lib.Sys.trace(Lib.Media.UI.Multitouch.inputMode)
  print(Lib.Media.UI.Multitouch.maxTouchPoints)

  stage.addChild(sp)
  stage.addChild(sp2)

  primaryTouch = nil

  function updatePosition(e)
      if e.touchPointID == primaryTouch then
	    sp.x = e.stageX - radius  
        sp.y = e.stageY - radius
      else
        sp2.x = e.stageX - radius  
        sp2.y = e.stageY - radius
      end
  end

  stage.addEventListener(Events.TouchEvent.TOUCH_BEGIN, 
    function(e)
      if primaryTouch == nil then primaryTouch = e.touchPointID end
      updatePosition(e)
    end, false, 0, false)
  stage.addEventListener(Events.TouchEvent.TOUCH_MOVE, 
    function(e)
      updatePosition(e)
    end, false, 0, false)
  stage.addEventListener(Events.TouchEvent.TOUCH_END, 
    function(e)
      if e.touchPointID == primaryTouch then primaryTouch = nil end
    end, false, 0, false)
else
  print("Multitouch not supported on this device")

  stage.addChild(sp)
  stage.addEventListener(Events.MouseEvent.MOUSE_MOVE, 
    function(e)
	  sp.x = e.stageX - radius  
      sp.y = e.stageY - radius
    end, false, 0, false)
end