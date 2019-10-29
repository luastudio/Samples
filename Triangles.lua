-- Triangles.lua

Display = Lib.Media.Display
BitmapData = Display.BitmapData
Sprite = Display.Sprite
stage = Display.stage

s0 = Sprite.new()
stage.addChild(s0)
s1 = Sprite.new()
stage.addChild(s1)
s2 = Sprite.new()
stage.addChild(s2)
s3 = Sprite.new()
stage.addChild(s3)

s0.scaleX = 0.5
s0.scaleY = 0.5
s1.scaleX = 0.5
s1.scaleY = 0.5
s2.scaleX = 0.5
s2.scaleY = 0.5
s3.scaleX = 0.5
s3.scaleY = 0.5

s1.x = 550 / 2
s3.x = s1.x
s2.y = 400 / 2
s3.y = s2.y

t0 = Lib.Sys.getTime() / 1000
data = BitmapData.loadFromBytes(Lib.Project.getBytes("/Bitmaps/assets/Image.jpg"), nil)

function drawTriangles(inGfx, verts, indices, tex, cull, cols)
	inGfx.drawTriangles(verts, indices, tex, cull, cols, 0)
end

function doUpdate()
	local sx = 1.0 / data.width
	local sy = 1.0 / data.height

	local theta = Lib.Sys.getTime() / 1000 - t0
	local cos = math.cos(theta)
	local sin = math.sin(theta)
	local z = sin * 100
	local w0 = 150.0 / (200.0 + z)
	local w1 = 150.0 / (200.0 - z)

	local x0 = 200
	local y0 = 200

	local vertices = {}
	vertices[1] = x0 + 100 * cos * w0
	vertices[2] = y0 - 100 * w0
	
	vertices[3] = x0 + 100 * cos * w0
	vertices[4] = y0 + 100 * w0

	vertices[5] = x0 - 100 * cos * w1
	vertices[6] = y0 + 100 * w1

	vertices[7] = x0 - 100 * cos * w1
	vertices[8] = y0 - 100 * w1

	local indices = {0, 1, 2, 2, 3, 0}

	local tex_uv = {100.0*sx, 0.0,
        100.0*sx, 200.0*sy,
        300.0*sx, 200.0*sy,
        300.0*sx, 0.0}

	local tex_uvt = {100.0*sx, 0.0, w0,
        100.0*sx, 200.0*sy, w0,
        300.0*sx, 200.0*sy, w1,
        300.0*sx, 0.0, w1}

	local cols = {0xffff0000,
                  0xff00ff00,
                  0xff0000ff,
                  0xffffffff}

	local gfx = s0.graphics
	gfx.clear()
	gfx.beginBitmapFill(data, nil, true, false)
	gfx.lineStyle(4, 0x0000ff, 1.0, false, nil, nil, nil, 3)
	drawTriangles(gfx, vertices, indices, tex_uvt, nil, nil)

	local gfx = s1.graphics
	gfx.clear()
	gfx.beginBitmapFill(data, nil, true, false)
	gfx.lineStyle(4, 0x0000ff, 1.0, false, nil, nil, nil, 3)
	drawTriangles(gfx, vertices, indices, tex_uv, nil, nil)

	local gfx = s2.graphics
	gfx.clear()
	gfx.beginBitmapFill(data, nil, true, false)
	gfx.lineStyle(4, 0x808080, 1.0, false, nil, nil, nil, 3)
	drawTriangles(gfx, vertices, indices, tex_uv, nil, cols)

	local gfx = s3.graphics
	gfx.clear()
	gfx.beginBitmapFill(data, nil, true, false)
	gfx.lineStyle(4, 0x808080, 1.0, false, nil, nil, nil, 3)
	drawTriangles(gfx, vertices, indices, tex_uvt, nil, cols)
end

stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, 
function(e)
	doUpdate()	
end, false, 0, false)