-- Sample.lua

Events = Lib.Media.Events
Display = Lib.Media.Display
Sprite = Display.Sprite
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Capabilities = Lib.Media.Capabilities
stage = Display.stage

stage.scaleX = Capabilities.screenDPI > 120 and Capabilities.screenDPI / 120 or 1
stage.scaleY = stage.scaleX

stage.addChild(Display.FPS.new())

sp = Sprite.new()
sp.graphics.beginFill(0,1)
sp.graphics.drawCircle(50,50,50)
sp.graphics.endFill()

stage.frameRate = 60

bd = BitmapData.new(100,100,true,0xcccccccc,nil)
bd.draw(sp, nil, nil, nil, nil, false)

bm = Bitmap.new(bd, nil, false)
stage.addChild(bm)
bm.x = 100

shape = Sprite.new()
gfx = shape.graphics
gfx.lineStyle(1, 0xff0000, 1.0, false, nil, nil, nil, 3)
gfx.beginFill(0xffffff, 1.0)
gfx.drawRect(0,0,20,40)
shape.x = 100
shape.y = 100
shape.rotation = 10
stage.addChild(shape)

stage.addEventListener(Events.Event.ENTER_FRAME, 
function(e)
	shape.rotation = shape.rotation + 360/60/60
end, false, 0, false)

stage.addEventListener(Events.MouseEvent.MOUSE_MOVE, 
function(e)
	print("Hit : "..e.stageX..","..e.stageY.." : "..(shape.hitTestPoint( e.stageX, e.stageY, false ) and "true" or "false"))
end, false, 0, false)