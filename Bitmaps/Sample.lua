-- Sample.lua

Sample = {}

function Sample.new(image1, image2, image3)
    local self = {}

	function self.run()
		stage.addChild(Bitmap.new(image1, Display.PixelSnapping.AUTO, false))

		local shape = Display.Shape.new()
		stage.addChild(shape)

		local copy = image1.clone()
		local bytes = copy.getPixels(Geom.Rectangle.new(100, 100, 100, 100))
		bytes.position = 0
		local dest = Display.BitmapData.new(100, 100, true, 0, nil)
		dest.setPixels(Geom.Rectangle.new(0, 0, 100, 100), bytes)
		for y = 0, 99, 1 do 
			for x = 0, 49, 1 do
				dest.setPixel32(x, y, dest.getPixel32(99-x, y))
			end
		end
		local col = 0xffff0000
		for i = 0, 99, 1 do
			dest.setPixel32(i, i, col)
		end
		stage.addChild(Bitmap.new(dest, Display.PixelSnapping.AUTO, false))

		local data = Display.BitmapData.loadFromBytes(Lib.Project.getBytes("/Bitmaps/assets/Image.jpg"), nil)
		local bmp = Bitmap.new(data, Display.PixelSnapping.AUTO, false) 
		stage.addChild(bmp)
		bmp.scaleX = 0.1
		bmp.scaleY = 0.1
		bmp.x = 100
		bmp.y = 300

		local gfx = shape.graphics
        gfx.lineStyle(1, 0x000000, 1.0, false, nil, nil, nil, 3)
		local mtx = Geom.Matrix.new(1, 0, 0, 1, 0, 0)
		gfx.beginBitmapFill(image1, mtx, true, true)
        gfx.drawRect(0,0,image1.width,image1.height)

		local mtx = Geom.Matrix.new(1, 0, 0, 1, 0, 0)
		mtx.translate(-200, -100)
		mtx.scale(5, 5)
		gfx.beginBitmapFill(image1, mtx, false, false)
        gfx.drawRect(100,100,200,200)

		shape.x = 100
		shape.y = 100

		local mtx = Geom.Matrix.new(1, 0, 0, 1, 0, 0)
		mtx.translate(-50, -50)
		gfx.beginBitmapFill(image2, mtx, true, true)
		gfx.drawRect(-50, -50, image2.width, image2.height)

		local shape2 = Display.Shape.new()
		stage.addChild(shape2)
		local gfx = shape2.graphics
		local mtx = Geom.Matrix.new(1, 0, 0, 1, 0, 0)
		gfx.beginBitmapFill(image3, mtx, true, true)
		gfx.drawRect(0, 0, image3.width, image3.height)
		shape2.x = 200
		shape2.y = 200

		local phase = 0
		stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, 
		function(e)
			if phase < 10 then
				dest.scroll(1, 0)
			elseif phase < 20 then
				dest.scroll(1, 1)
			elseif phase < 30 then
				dest.scroll(0, 1)
			elseif phase < 40 then
				dest.scroll(-1, 1)
			elseif phase < 50 then
				dest.scroll(-1, 0)
			elseif phase < 60 then
				dest.scroll(-1, -1)
			elseif phase < 70 then
				dest.scroll(0, -1)
			elseif phase < 80 then
				dest.scroll(1, -1)
			end
			phase = phase + 1
			if phase >= 80 then
				phase = 0
			end
			shape.rotation = shape.rotation + 0.01
		end, false, 0, false)
    end

	return self
end