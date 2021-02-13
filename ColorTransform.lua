-- ColorTransform.lua

Display = Lib.Media.Display
Events = Lib.Media.Events
Geom = Lib.Media.Geom
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Sprite = Display.Sprite
Shape = Display.Shape
stage = Display.stage

function draw(sprite)
	local red = 0xFF0000
	local green = 0x00FF00
	local blue = 0x0000FF
	local size = 100.0

	sprite.graphics.beginGradientFill(Display.GradientType.LINEAR, {red, blue, green}, {1, 0.5, 1}, {0.0, 200, 255}, nil, nil, nil, 0.0)
	sprite.graphics.drawRect(0, 0, 100, 100)
	sprite.graphics.beginFill(0x808080, 1.0)
	sprite.graphics.drawRect(80, 80, 100, 100)
end

target = Sprite.new()
draw(target)
stage.addChild(target)

data = BitmapData.loadFromBytes(Lib.Project.getBytes("/Bitmaps/assets/Image.jpg"), nil)
bmp = Bitmap.new(data, Display.PixelSnapping.AUTO, false)
bmp.alpha = 0.5
bmp.x = 50
bmp.y = 50
target.addChild(bmp)
target.alpha = 0.5

box = Sprite.new()
box.alpha = 0.2
draw(box)
box.x = 160
box.y = 160
stage.addChild(box)

data = BitmapData.new(100, 100, true, 0x00, nil)
s = Shape.new()
s.graphics.beginFill(0x00FF00, 1) 
s.graphics.drawCircle(0, 0, 100)
data.draw(s, nil, nil, nil, nil, false)

data2 = BitmapData.new(100, 100, true, 0x00, nil)
data2.draw(Bitmap.new(data, Display.PixelSnapping.AUTO, false), nil, Geom.ColorTransform.new(0,0,0,-1,0,0,0,255), nil, nil, false)

bmp2 = Bitmap.new(data2, Display.PixelSnapping.AUTO, false)
bmp2.x = 200
stage.addChild(bmp2)

target.addEventListener(Events.MouseEvent.CLICK, 
function (e)
	local d = stage
	local t = d.transform
	local rOffset = t.colorTransform.redOffset + 25
	local bOffset = t.colorTransform.redOffset - 25
	local a = d.alpha
	t.colorTransform = Geom.ColorTransform.new(1, 1, 1, a*0.9, rOffset, 0, bOffset, 0)
end, false, 0, false)