-- CacheAsBitmap.lua

Display = Lib.Media.Display
Sprite = Display.Sprite
stage = Display.stage

circle = Sprite.new()
gfx = circle.graphics

colours = {0xff0000, 0x000000}
alphas = {1.0, 1.0}
ratios = {0, 255}
mtx = Lib.Media.Geom.Matrix.new(1, 0, 0, 1, 0, 0)
focal = -0.9
mtx.createGradientBox(100,100, 0, 0,0)
gfx.beginGradientFill(Display.GradientType.RADIAL,
                       colours, alphas, ratios, mtx, Display.SpreadMethod.REPEAT,
                       Display.InterpolationMethod.LINEAR_RGB,
                       focal )
gfx.drawRect(0,0,100,100)
stage.addChild(circle)

circle.cacheAsBitmap = true
circle.x = 200
circle.y = 200
f = {Lib.Media.Filters.DropShadowFilter.new(4.0, 45.0, 0, 1.0, 4.0, 4.0, 1.0, 1, false, false, false)}
circle.filters = f

shape = Display.Shape.new()
gfx = shape.graphics
gfx.lineStyle(3, 0x0000ff, 1.0, false, nil, nil, nil, 3)
gfx.moveTo(5, 5)
gfx.lineTo(25, 25)
bmp = Display.BitmapData.new(32, 32, true, 0, nil)
bmp.draw(shape, nil, nil, nil, nil, false)
bitmap = Display.Bitmap.new(bmp, nil, false)

bitmap.x = 50
bitmap.y = 50
stage.addChild(bitmap)

combined = Display.BitmapData.new(200, 200, true, 0, nil)
matrix = Lib.Media.Geom.Matrix.new(1, 0, 0, 1, 0, 0)
for x = 0, 4, 1 do
	for y = 0, 4, 1 do
		matrix.tx = x * 20
		matrix.ty = y * 20
	combined.draw(bmp, matrix, nil, nil, nil, false)
	end
end
bitmap = Display.Bitmap.new(combined, nil, false)
bitmap.x = 150
bitmap.y = 50
stage.addChild(bitmap)

function CreateStrip(inMethod)
	local shape = Sprite.new()
	local gfx = shape.graphics

	local mtx = Lib.Media.Geom.Matrix.new(1, 0, 0, 1, 0, 0)
	mtx.createGradientBox(250, 50, 0, 0, 0)

	local colours = {0xff0000, 0x00ff00, 0x0000ff}
	local alphas = {1.0, 1.0, 1.0}
	local ratios = {0, 128, 255}

	gfx.beginGradientFill(Display.GradientType.LINEAR,
                       colours, alphas, ratios, mtx, Display.SpreadMethod.REPEAT,
                       inMethod, -0.9)	

	gfx.drawRect(0, 0, 250, 50)
	shape.addEventListener(Lib.Media.Events.MouseEvent.CLICK, 
		function(e)
		    print("click")
		end, false, 0, false)

	return shape
end

strip = CreateStrip(Display.InterpolationMethod.LINEAR_RGB)
strip.x = 20
strip.y = 300
stage.addChild(strip)

strip = CreateStrip(Display.InterpolationMethod.RGB)
strip.x = 20
strip.y = 400
stage.addChild(strip)

stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, 
	function(e)
		circle.rotation = circle.rotation + 1
	end, false, 0, false)