-- Masks.lua

Sprite = Lib.Media.Display.Sprite
Text = Lib.Media.Text
Geom = Lib.Media.Geom
Shape = Lib.Media.Display.Shape
Filters = Lib.Media.Filters
Events = Lib.Media.Events
stage = Lib.Media.Display.stage

window = Sprite.new()
stage.addChild(window)

require("/Common/Scrollbar.lua")

scrollbarObj = Scrollbar.new(20, 404, 1024-400, 404*400/1024)
scrollbar = scrollbarObj.getSprite()
scrollbar.x = 76
scrollbar.y = 38
stage.addChild(scrollbar)
window.scrollRect = Geom.Rectangle.new(0, 0, 440, 400)
scrollbarObj.scrolled = function(inTo)
	window.scrollRect = Geom.Rectangle.new(0, inTo, 440, 400)
end

gfx = stage.graphics
gfx.lineStyle(1, 0x000000, 1.0, false, nil, nil, nil, 3)
gfx.drawRect(98,38,444,404)
window.x = 100
window.y = 40

bg = Sprite.new()
gfx = bg.graphics
gfx.beginFill(0x808080, 1)
gfx.drawRect(0,0,1024,1024)
window.addChild(bg)

line = Sprite.new()
gfx = line.graphics
gfx.lineStyle(20, 0xffffff, 1.0, false, nil, nil, nil, 3)
gfx.moveTo(20,20)
gfx.lineTo(250,250)
window.addChild(line)
glow = Filters.GlowFilter.new(0x00ff00, 1.0, 3, 3, 1, 1, false, false)
line.filters = {glow}

line = Sprite.new()
gfx = line.graphics
gfx.lineStyle(5, 0x000000, 1.0, false, nil, nil, nil, 3)
gfx.moveTo(5,5)
gfx.lineTo(250,250)
window.addChild(line)

tf = Text.TextField.new()
tf.text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, " ..
"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
tf.selectable = false
tf.wordWrap = true
tf.width = 150
tf.name = "text1"
tf.cacheAsBitmap = true --required if using mask over text
window.addChild(tf)

mask_obj = Sprite.new()
mask_obj.graphics.beginFill(0xFF0000, 1)
mask_obj.graphics.drawCircle(0,0,40)
mask_obj.graphics.endFill()
mask_obj.name = "mask_obj"
window.addChild(mask_obj)

mask_child = Shape.new()
gfx = mask_child.graphics
gfx.beginFill(0x00ff00, 1)
gfx.drawRect(-60,-10,120,20)
mask_obj.addChild(mask_child)

window.mask = mask_obj

window.addEventListener(Events.MouseEvent.MOUSE_DOWN, 
function (e)
	mask_obj.startDrag(false, nil)
end, false, 0, false)

window.addEventListener(Events.MouseEvent.MOUSE_UP, 
function (e)
	mask_obj.stopDrag()
end, false, 0, false)

tf.x = 100
tf.y = 100
mask_obj.x = 100
mask_obj.y = 100
