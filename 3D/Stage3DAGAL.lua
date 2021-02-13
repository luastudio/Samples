-- Stage3DAGAL.lua

Display = Lib.Media.Display
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

function createProgram()
	-- // // CREATE SHADER PROGRAM // //
	-- When you call the createProgram method you are actually allocating some V-Ram space
	-- for your shader program.
	program = context3D.createProgram();

	-- Create an AGALMiniAssembler.
	-- The MiniAssembler is tool that uses a simple
	-- Assembly-like language to write and compile your shader into bytecode
	local assembler = Display3D.Shaders.AGLSL.AGALMiniAssembler.new()

	-- VERTEX SHADER
	local code = "mov op, va0\n" -- Move the Vertex Attribute 0 (va0), which is our Vertex Coordinate, to the Output Point
	code = code .. "mov v0, va1\n" -- Move the Vertex Attribute 1 (va1), which is our Vertex Color, to the variable register v0
	 -- Variable register are memory space shared between your Vertex Shader and your Fragment Shader
 
	-- Compile our AGAL Code into ByteCode using the MiniAssembler
	local vertexShader = assembler.assemble(Display3D.Context3DProgramType.VERTEX, code)

	code = "mov oc, v0\n" -- Move the Variable register 0 (v0) where we copied our Vertex Color, to the output color
	-- Compile our AGAL Code into Bytecode using the MiniAssembler
    local fragmentShader = assembler.assemble(Display3D.Context3DProgramType.FRAGMENT, code)
 
    program.upload(vertexShader, fragmentShader)
end

function update(rect)
	context3D.setProgram(program)
	-- you will copy in register "0", from the buffer "vertexBuffer, starting from the postion "0" the FLOAT_3 next number
	context3D.setVertexBufferAt(0, vertexBuffer, 0, Display3D.Context3DVertexBufferFormat.FLOAT_3) -- register "0" now contains x,y,z
 
	-- Here, you will copy in register "1" from "vertexBuffer", starting from index "3", the next FLOAT_3 numbers
	context3D.setVertexBufferAt(1, vertexBuffer, 3, Display3D.Context3DVertexBufferFormat.FLOAT_3) -- register 1 now contains r,g,b

	context3D.clear(1, 1, 1, 1.0, 1, 0, Display3D.Context3DClearMask.ALL)
	context3D.drawTriangles(indexBuffer, 0, -1)
	context3D.present()
end

stage3D.addEventListener(Events.Event.CONTEXT3D_CREATE, 
function(e)
	print("Context 3D created")
	context3D = stage3D.context3D
	context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 4, true)
	context3D.enableErrorChecking = true
	createProgram()

	local vertices = {
        -0.3, -0.3, 0, 1, 0, 0, -- 1st vertex x,y,z,r,g,b
		0, 0.3, 0, 0, 1, 0, 	-- 2nd vertex x,y,z,r,g,b
		0.3, -0.3, 0, 0, 0, 1   -- 3rd vertex x,y,z,r,g,b
	}

	local indices = {0,1,2}

    vertexBuffer = context3D.createVertexBuffer(3,6)
    vertexBuffer.uploadFromVector(vertices, 0, 3)

    indexBuffer = context3D.createIndexBuffer(3)
    indexBuffer.uploadFromVector(indices, 0, 3)

    context3D.setRenderMethod(update)
end, false, 0, false)

stage3D.addEventListener(Events.ErrorEvent.ERROR, 
function(e)
	Lib.Sys.trace(e)
end, false, 0, false)

stage3D.requestContext3D("")