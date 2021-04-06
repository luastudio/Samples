-- MultiWindow.lua


Display = Lib.Media.Display
Display3D = Lib.Media.Display3D
Window = Lib.Media.Window
Sprite = Display.Sprite
Events = Lib.Media.Events
MouseEvent = Events.MouseEvent
stage = Display.stage

if type(jit) == 'table' then
  bit32 = bit
end

shape = Sprite.new()
stage.addChild(shape)
gfx = shape.graphics
gfx.beginFill(0xff0000, 1.0)
gfx.drawRect(10,10,200,200)
stage.addChild(Display.FPS.new())

childCount = 0
rates = {0, 10, 25, 0, 2}

function createWindow()
    local fps = rates[childCount % #rates + 1]
    childCount = childCount + 1
    local name = "New Window:" .. childCount .. " fps=" .. fps

    local window = Window.createSecondaryWindow(
        500, 600, name,
        bit32.bor(Window.RESIZABLE --[[, Window.ALWAYS_ON_TOP]]),
        0x303030, fps, nil )

    local s = window.stage
    s.addEventListener(Events.Event.BEFORE_CLOSE, function(ev)
		print("Before window close event ["..ev.target.window.title.."]. Use ev.stopPropagation() to prevent window from closing.")
        --ev.stopPropagation()
    end, false, 0, false)
    s.addEventListener(Events.Event.CLOSE, function(ev)
		print("Window close event ["..ev.target.window.title.."].")
    end, false, 0, false)

    --s.name = name
    local shape = Sprite.new()
    s.addChild(shape)
    local gfx = shape.graphics
    gfx.beginFill(0x0000ff, 1.0)
    gfx.drawCircle(100,200,100)
    local fps = Display.FPS.new()
    fps.textColor = 0xFFFFFF
    s.addChild(fps)
    s.addEventListener( MouseEvent.CLICK, function(ev)
		print("onChild:" .. Lib.Str.string(ev.target) .. " from " .. Lib.Str.string(s))
    end, false, 0, false)
    s.addEventListener(Events.Event.ENTER_FRAME, function(ev)
		shape.x = (shape.x+1)%(s.stageWidth/2)
    end, false, 0, false)

	local context3D = nil
	local vertexBuffer = nil
	local indexBuffer = nil
	local program = nil
    local stage3D = s.stage3Ds[1]
	stage3D.addEventListener(Events.Event.CONTEXT3D_CREATE, 
	function(e)
		print("Context 3D created")
		context3D = stage3D.context3D
		context3D.configureBackBuffer(s.stageWidth, s.stageHeight, 4, true)
		context3D.enableErrorChecking = true
		program = createProgram(context3D)

		local vertices = {
	        -0.3, -0.3, 0, 1, 0, 0,
			0, 0.3, 0, 0, 1, 0, 
			0.3, -0.3, 0, 0, 0, 1
		}

		local indices = {0,1,2}

	    vertexBuffer = context3D.createVertexBuffer(3,6)
	    vertexBuffer.uploadFromVector(vertices, 0, 3)

	    indexBuffer = context3D.createIndexBuffer(3)
	    indexBuffer.uploadFromVector(indices, 0, 3)

	    context3D.setRenderMethod(function(rect)
			context3D.setProgram(program)
			context3D.setVertexBufferAt(0, vertexBuffer, 0, Display3D.Context3DVertexBufferFormat.FLOAT_3)
 
			context3D.setVertexBufferAt(1, vertexBuffer, 3, Display3D.Context3DVertexBufferFormat.FLOAT_3)

			context3D.clear(1, 1, 1, 1.0, 1, 0, Display3D.Context3DClearMask.DEPTH)

			context3D.drawTriangles(indexBuffer, 0, -1)
			context3D.present()
		end)
	end, false, 0, false)

	stage3D.addEventListener(Events.ErrorEvent.ERROR, 
	function(e)
		Lib.Sys.trace(e)
	end, false, 0, false)

	stage3D.requestContext3D("")
end

if Window.supportsSecondary then
	stage.addEventListener(MouseEvent.CLICK, 
	function(e)
		createWindow()
	end, false, 0, false)
else
	print("This system does not support secondary windows")
end

function createProgram(context3D)
	local program = context3D.createProgram()

	local assembler = Display3D.Shaders.AGLSL.AGALMiniAssembler.new()

	local code = "mov op, va0\n"
	code = code .. "mov v0, va1\n"
 
	local vertexShader = assembler.assemble(Display3D.Context3DProgramType.VERTEX, code)

	code = "mov oc, v0\n"
    local fragmentShader = assembler.assemble(Display3D.Context3DProgramType.FRAGMENT, code)
 
    program.upload(vertexShader, fragmentShader)
    return program
end