-- Stage3D.lua

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
glslProgram = nil

function createProgram()
	glslProgram = Display3D.Shaders.GLSL.GLSLProgram.new(context3D)

    local vertexShaderSource = [[
        attribute vec3 vertexPosition;

        uniform mat4 mvpMatrix;

        void main(void) {
            gl_Position = mvpMatrix * vec4(vertexPosition, 1.0);
        }
	]]

	local vertexShader = Display3D.Shaders.GLSL.GLSLVertexShader.new(vertexShaderSource, nil)

	local fragmentShaderSource = [[
        void main(void) {
        	gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        }
	]]

    local fragmentShader = Display3D.Shaders.GLSL.GLSLFragmentShader.new(fragmentShaderSource, nil)

    glslProgram.upload(vertexShader, fragmentShader)
end

function update(rect)
	local positionX = stage.stageWidth / 2
	local positionY = stage.stageHeight / 2

	local projectionMatrix = Geom.Matrix3D.createOrtho(0, stage.stageWidth, stage.stageHeight, 0, 1000, -1000)
	local modelViewMatrix = Geom.Matrix3D.create2D(positionX, positionY, 1, 0)
	
	local mvpMatrix = modelViewMatrix.clone()
	mvpMatrix.append(projectionMatrix)

	glslProgram.attach()
	glslProgram.setVertexUniformFromMatrix("mvpMatrix", mvpMatrix, true)
	glslProgram.setVertexBufferAt("vertexPosition", vertexBuffer, 0, Display3D.Context3DVertexBufferFormat.FLOAT_3)

	context3D.clear(0, 0, 0, 1.0, 1, 0, Display3D.Context3DClearMask.ALL)
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
        100, 100, 0,
        -100, 100, 0,
        100, -100, 0,
        -100, -100, 0
	}

	local indices = {0,1,2,2,3,1}

    vertexBuffer = context3D.createVertexBuffer(4,3)
    vertexBuffer.uploadFromVector(vertices, 0, 4)

    indexBuffer = context3D.createIndexBuffer(6)
    indexBuffer.uploadFromVector(indices, 0, 6)

    context3D.setRenderMethod(update)
end, false, 0, false)

stage3D.addEventListener(Events.ErrorEvent.ERROR, 
function(e)
	Lib.Sys.trace(e)
end, false, 0, false)

stage3D.requestContext3D("")