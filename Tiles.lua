-- Tiles.lua

Display = Lib.Media.Display
Events = Lib.Media.Events
Geom = Lib.Media.Geom
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap
Sprite = Display.Sprite
Shape = Display.Shape
stage = Display.stage

if type(jit) == 'table' then
   bit32 = bit
end

local Particle = {}
function Particle.new()
    local self = {}

	self.x = 320
	self.y = 240
	self.angle = 0
	self.dx = math.random() * 2.0 - 1.0
	self.dy = math.random() * 2.0 - 1.0
	self.da = math.random() * 0.2 - 0.1
	self.daspect = math.random() * 0.1

	self.aspect = math.random() * 1 + 0.25

	self.red = math.random()
	self.green = math.random()
	self.blue = math.random()
	self.alpha = math.random()

	self.size = math.random() * 1.9 + 0.1

	function self.addSimple(data)
		local len = #data
		data[len + 1] = self.x
		data[len + 2] = self.y
		data[len + 3] = 0
	end

	function self.add(data)
		local len = #data
		data[len + 1] = self.x
		data[len + 2] = self.y
		data[len + 3] = 0
		data[len + 4] = self.size
		data[len + 5] = self.angle
		data[len + 6] = self.red
		data[len + 7] = self.green
		data[len + 8] = self.blue
		data[len + 9] = self.alpha
	end

	function self.addTrans(data)
		local len = #data
		data[len + 1] = self.x
		data[len + 2] = self.y
		data[len + 3] = 0

		local t00 = self.size * math.cos(self.angle)
		local t01 = self.size * math.sin(self.angle)
		local t10 = -t01
		local t11 = t00

		local wobble = 1.0 + math.cos(self.aspect) * 0.75
		data[len + 4] = t00 * wobble
		data[len + 5] = t01 * wobble

		data[len + 6] = t10
		data[len + 7] = t11

		data[len + 8] = self.red
		data[len + 9] = self.green
		data[len + 10] = self.blue
		data[len + 11] = self.alpha
	end

	function self.addColoured(data)
		local len = #data
		data[len + 1] = self.x
		data[len + 2] = self.y
		data[len + 3] = 0	
		data[len + 4] = self.red
		data[len + 5] = self.green
		data[len + 6] = self.blue
		data[len + 7] = self.alpha
	end

	function self.move()
		local rad = 30 * self.size

		self.x = self.x + self.dx
		if self.x < rad then
			self.x = rad
			self.dx = -self.dx
		end	
		if self.x > 640 - rad then
			self.x = 640 - rad
			self.dx = -self.dx
		end

		self.y = self.y + self.dy
		if self.y < rad then
			self.y = rad
			self.dy = -self.dy
		end
		if self.y > 480 - rad then
			self.y = 480 - rad
			self.dy = -self.dy
		end

		self.angle = self.angle + self.da
		self.aspect = self.aspect + self.daspect
	end

    return self
end


shape = Shape.new()
gfx = shape.graphics
gfx.beginFill(0xFFFFFF, 1.0)
gfx.lineStyle(1, 0x000000, 1.0, false, nil, nil, nil, 3)
gfx.drawCircle(32, 32, 30)
gfx.endFill()
gfx.moveTo(32, 32)
gfx.lineTo(62, 62)
bmp = BitmapData.new(64, 64, true, 0x00, nil)
bmp.draw(shape, nil, nil, nil, nil, false)

tilesheet = Display.Tilesheet.new(bmp)
tilesheet.addTileRect(Geom.Rectangle.new(0, 0, 64, 64), Geom.Point.new(32, 32))
tid = 0

particles = {}
for i = 1, 100, 1 do
	particles[i] = Particle.new()
end

stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, 
function(e)
	local data = {}
	local flags = 0
	particles[1].addSimple(data)

	stage.graphics.drawTiles(tilesheet, data, true, flags, -1)

	data = {}
	--[[flags = bit32.bor(Display.Tilesheet.TILE_SCALE, Display.Tilesheet.TILE_ROTATION, Display.Tilesheet.TILE_ALPHA, Display.Tilesheet.TILE_RGB)
	for i = 1, 100, 1 do
		particles[i].move()
		particles[i].add(data)
	end]]--

	--[[flags = bit32.bor(Display.Tilesheet.TILE_ALPHA, Display.Tilesheet.TILE_RGB)
	for i = 1, 100, 1 do
		particles[i].move()
		particles[i].addColoured(data)
	end]]--

	flags = bit32.bor(Display.Tilesheet.TILE_TRANS_2x2, Display.Tilesheet.TILE_ALPHA, Display.Tilesheet.TILE_RGB)
	for i = 1, 100, 1 do
		particles[i].move()
		particles[i].addTrans(data)
	end

	stage.graphics.clear()
	stage.graphics.drawTiles(tilesheet, data, true, flags, -1)
end, false, 0, false)