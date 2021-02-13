-- Main.lua

Display = Lib.Media.Display
Bitmap = Display.Bitmap
BitmapData = Display.BitmapData
Display3D = Lib.Media.Display3D
Events = Lib.Media.Events
Geom = Lib.Media.Geom
Sprite = Display.Sprite
stage = Display.stage

stage3D = stage.stage3Ds[1]
context3D = nil

vertexBuffer = nil
indexBuffer = nil
program = nil
texture = nil

function createProgram()
	program = context3D.createProgram();

	local assembler = Display3D.Shaders.AGLSL.AGALMiniAssembler.new()

	local code = "m44 op, va0, vc0\n" 
	code = code .. "mov v0, va1" 
	local vertexShader = assembler.assemble(Display3D.Context3DProgramType.VERTEX, code)

	code = "tex ft1, v0, fs0 <2d,linear, nomip>;\n"
	code = code .. "mov oc, ft1"
    local fragmentShader = assembler.assemble(Display3D.Context3DProgramType.FRAGMENT, code)
 
    program.upload(vertexShader, fragmentShader)
end

function update(rect)
	context3D.clear(1, 1, 1, 1.0, 1, 0, Display3D.Context3DClearMask.ALL)

	context3D.setProgram(program)

	context3D.setVertexBufferAt(0, vertexBuffer, 0, Display3D.Context3DVertexBufferFormat.FLOAT_3) 
 
	context3D.setVertexBufferAt(1, vertexBuffer, 3, Display3D.Context3DVertexBufferFormat.FLOAT_2) 

	context3D.setTextureAt( 0, texture )

	local m = Geom.Matrix3D.new(nil)
	m.appendRotation(Lib.Sys.getTime()/50, Geom.Vector3D.Z_AXIS, nil)
	context3D.setProgramConstantsFromMatrix(Display3D.Context3DProgramType.VERTEX, 0, m, true)

	context3D.drawTriangles(indexBuffer, 0, -1)
	context3D.present()
end

stage3D.addEventListener(Events.Event.CONTEXT3D_CREATE, 
function(e)
	print("Context 3D created")
	context3D = stage3D.context3D
	context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false)
	context3D.enableErrorChecking = true
	createProgram()

	local vertices = {
		-0.5,-0.5,0, 0, 0, -- x, y, z, u, v
		-0.5, 0.5, 0, 0, 1,
		0.5, 0.5, 0, 1, 1,
		0.5, -0.5, 0, 1, 0
	}

	local indices = {0, 1, 2, 2, 3, 0}

    vertexBuffer = context3D.createVertexBuffer(4, 5)
    vertexBuffer.uploadFromVector(vertices, 0, 4)

    indexBuffer = context3D.createIndexBuffer(6)
    indexBuffer.uploadFromVector(indices, 0, 6)

	local bitmap = Bitmap.new(BitmapData.loadFromBytes(Lib.Project.getBytes("/3D/SquareTexture/RockSmooth.jpg"), nil), Display.PixelSnapping.AUTO, true)
    print("texture: " .. bitmap.bitmapData.width .. "x" .. bitmap.bitmapData.height)
	texture = context3D.createTexture(bitmap.bitmapData.width, bitmap.bitmapData.height, Display3D.Context3DTextureFormat.BGRA, false, 0)

	texture.uploadFromBitmapData(bitmap.bitmapData, 0)

    context3D.setRenderMethod(update)
end, false, 0, false)

stage3D.addEventListener(Events.ErrorEvent.ERROR, 
function(e)
	Lib.Sys.trace(e)
end, false, 0, false)

stage3D.requestContext3D("")