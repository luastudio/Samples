-- Main.lua

--Instruction:
--Click and drag on the stage to rotate camera.
--Picking -----
--Click on the head model to draw on its texture.
--Red objects have triangle picking precision.
--Blue objects have bounds picking precision.
--Gray objects are disabled for picking but occlude picking on other objects.
--Black objects are completely ignored for picking.

-- declarations
Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Scene3D = Away3D.Containers.Scene3D
Mesh = Away3D.Entities.Mesh
SegmentSet = Away3D.Entities.SegmentSet
Materials = Away3D.Materials
Primitives = Away3D.Primitives
Camera3D = Away3D.Cameras.Camera3D
Lenses = Away3D.Cameras.Lenses
PointLight = Away3D.Lights.PointLight
Textures = Away3D.Textures
HoverController = Away3D.Controllers.HoverController
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Geom = Lib.Media.Geom
stage = Display.stage

-- variables
PAINT_TEXTURE_SIZE = 1024
raycastPicker = Away3D.Core.Pick.RaycastPicker.new(false)
move = false
lastPanAngle = 0
lastTiltAngle = 0
lastMouseX = 0
lastMouseY = 0
tiltSpeed = 4
panSpeed = 4
distanceSpeed = 4
tiltIncrement = 0
panIncrement = 0
distanceIncrement = 0


function initEngine()
	view = View3D.new()
	view.forceMouseMove = true
	scene = view.scene
    camera = view.camera
	--view.mousePicker = Away3D.Core.Pick.PickingType.SHADER -- Uses the GPU, considers gpu animations, and suffers from Stage3D's drawToBitmapData()'s bottleneck.
	--view.mousePicker = Away3D.Core.Pick.PickingType.RAYCAST_FIRST_ENCOUNTERED -- Uses the CPU, fast, but might be inaccurate with intersecting objects.
	view.mousePicker = Away3D.Core.Pick.PickingType.RAYCAST_BEST_HIT -- Uses the CPU, guarantees accuracy with a little performance cost.

	--setup the view
	stage.addChild(view)

	cameraController = HoverController.new(camera, nil, 180, 20, 320, 5, 90, nil, nil, 8,  2, false)

	-- stats
	stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

function initLights()
    --create a light for the camera
	pointLight = PointLight.new()
	scene.addChild(pointLight)
	lightPicker = Materials.LightPickers.StaticLightPicker.new({pointLight})
end

function initMaterials()
	-- uv painter
    painter = Display.Sprite.new()
	painter.graphics.beginFill(0xFF0000, 1.0)
	painter.graphics.drawCircle( 0, 0, 10 )
	painter.graphics.endFill()

	-- locator materials
	whiteMaterial = Materials.ColorMaterial.new( 0xFFFFFF, 1 )
	whiteMaterial.lightPicker = lightPicker
	blackMaterial = Materials.ColorMaterial.new( 0x333333, 1 )
	blackMaterial.lightPicker = lightPicker
	grayMaterial = Materials.ColorMaterial.new( 0xCCCCCC, 1 )
	grayMaterial.lightPicker = lightPicker
	blueMaterial = Materials.ColorMaterial.new( 0x0000FF, 1 )
	blueMaterial.lightPicker = lightPicker
	redMaterial = Materials.ColorMaterial.new( 0xFF0000, 1 )
	redMaterial.lightPicker = lightPicker
end

function choseMeshMaterial( mesh )
	if not mesh.mouseEnabled then
		mesh.material = blackMaterial
	else 
		if not mesh.hasEventListener( Away3D.Events.MouseEvent3D.MOUSE_MOVE ) then
			mesh.material = grayMaterial
		else 
			if mesh.pickingCollider ~= Away3D.Core.Pick.PickingColliderType.BOUNDS_ONLY then
				mesh.material = redMaterial
			else 
				mesh.material = blueMaterial
			end
		end
	end
end


function enableMeshMouseListeners( mesh )
	local onMeshMouseMove = function(event)
		-- Show tracers.
		pickingPositionTracer.visible = true
        pickingNormalTracer.visible = true

		-- Update position tracer.
		pickingPositionTracer.position = event.scenePosition

		-- Update normal tracer.
		pickingNormalTracer.position = pickingPositionTracer.position
		local normal = event.sceneNormal.clone() -- Vector3D
		normal.scaleBy( 25 )
		local lineSegment = pickingNormalTracer.getSegment( 0 )
		lineSegment["end"] = normal.clone()
	end

	mesh.addEventListener( Away3D.Events.MouseEvent3D.MOUSE_OVER, 
		function(event)
			local mesh = event.object
			mesh.showBounds = true
			if mesh ~= head then
				mesh.material = whiteMaterial
			end
			pickingPositionTracer.visible = true
			pickingNormalTracer.visible = true
			onMeshMouseMove(event)
		end, false, 0, false )
	mesh.addEventListener( Away3D.Events.MouseEvent3D.MOUSE_OUT,
		function(event)
			local mesh = event.object
			mesh.showBounds = false
			if mesh ~= head then
				choseMeshMaterial( mesh )
			end
			pickingPositionTracer.visible = false
			pickingNormalTracer.visible = false
			pickingPositionTracer.position = Geom.Vector3D.new(0,0,0,0)
		end, false, 0, false )
	mesh.addEventListener( Away3D.Events.MouseEvent3D.MOUSE_MOVE, onMeshMouseMove, false, 0, false )
	mesh.addEventListener( Away3D.Events.MouseEvent3D.MOUSE_DOWN, 
		function(event)
			local mesh = event.object
			-- Paint on the head's material.
			if mesh == head then
				local uv = event.uv --Point
				local textureMaterial = event.object.material --TextureMaterial
				local bmd = textureMaterial.texture.bitmapData --BitmapData
				local x = PAINT_TEXTURE_SIZE * uv.x
				local y = PAINT_TEXTURE_SIZE * uv.y
				local matrix = Geom.Matrix.new(1,0,0,1,0,0) --Matrix
				matrix.translate( x, y )
				bmd.draw( painter, matrix, nil, nil, nil, false )
				textureMaterial.texture.invalidateContent()
			end
		end, false, 0, false )
end

function createSimpleObject()
		local geometry --Geometry
		local bounds = nil --BoundingVolumeBase
		
		-- Chose a random geometry.
		local randGeometry = math.random()
		if randGeometry > 0.75 then
			geometry = cubeGeometry
		elseif randGeometry > 0.5 then
			geometry = sphereGeometry
			bounds = Away3D.Bounds.BoundingSphere.new() -- better on spherical meshes with bound picking colliders
		elseif randGeometry > 0.25 then
			geometry = cylinderGeometry
		else 
			geometry = torusGeometry
		end
		
		local mesh = Mesh.new(geometry, nil)
		
		if bounds ~= nil then
			mesh.bounds = bounds
		end

		-- For shader based picking.
		mesh.shaderPickingDetails = true

		-- Randomly decide if the mesh has a triangle collider.
		local usesTriangleCollider = math.random() > 0.5
		if usesTriangleCollider then
			-- LS triangle pickers for meshes with low poly counts are faster than pixel bender ones.
--				mesh.pickingCollider = Away3D.Core.Pick.PickingColliderType.BOUNDS_ONLY -- this is the default value for all meshes
			mesh.pickingCollider = Away3D.Core.Pick.PickingColliderType.FIRST_ENCOUNTERED
--				mesh.pickingCollider = Away3D.Core.Pick.PickingColliderType.BEST_HIT -- slower and more accurate, best for meshes with folds
--				mesh.pickingCollider = Away3D.Core.Pick.PickingColliderType.AUTO_FIRST_ENCOUNTERED -- automatically decides when to use pixel bender or actionscript
		end

		-- Enable mouse interactivity?
		local isMouseEnabled = math.random() > 0.25
		mesh.mouseEnabled = isMouseEnabled
		mesh.mouseChildren = isMouseEnabled

		-- Enable mouse listeners?
		local listensToMouseEvents = math.random() > 0.25
		if isMouseEnabled and listensToMouseEvents then
			enableMeshMouseListeners( mesh )
		end

		-- Apply material according to the random setup of the object.
		choseMeshMaterial( mesh )

		-- Add to scene and store.
		view.scene.addChild( mesh )

		return mesh
end

function initObjects()
    -- To trace mouse hit position.
	pickingPositionTracer = Mesh.new( Primitives.SphereGeometry.new( 2, 16, 12, true ), Materials.ColorMaterial.new( 0x00FF00, 0.5 ) )
	pickingPositionTracer.visible = false
	pickingPositionTracer.mouseEnabled = false
	pickingPositionTracer.mouseChildren = false
	scene.addChild(pickingPositionTracer)
		
	scenePositionTracer = Mesh.new( Primitives.SphereGeometry.new( 2, 16, 12, true ), Materials.ColorMaterial.new( 0x0000FF, 0.5 ) )
	scenePositionTracer.visible = false
	scenePositionTracer.mouseEnabled = false
	scene.addChild(scenePositionTracer)
		
		
	-- To trace picking normals.
	pickingNormalTracer = SegmentSet.new()
	pickingNormalTracer.mouseEnabled = false
	pickingNormalTracer.mouseChildren = false
	local lineSegment1 = Primitives.LineSegment.new( Geom.Vector3D.new(0,0,0,0), Geom.Vector3D.new(0,0,0,0), 0xFFFFFF, 0xFFFFFF, 3 )
	pickingNormalTracer.addSegment( lineSegment1 )
	pickingNormalTracer.visible = false
	view.scene.addChild( pickingNormalTracer )
		
	sceneNormalTracer = SegmentSet.new()
	sceneNormalTracer.mouseEnabled = false
	sceneNormalTracer.mouseChildren = false
	local lineSegment2 = Primitives.LineSegment.new( Geom.Vector3D.new(0,0,0,0), Geom.Vector3D.new(0,0,0,0), 0xFFFFFF, 0xFFFFFF, 3 )
	sceneNormalTracer.addSegment( lineSegment2 )
	sceneNormalTracer.visible = false
	view.scene.addChild( sceneNormalTracer )
		
		
	-- Load a head model that we will be able to paint on on mouse down.
	local parser = Away3D.Loaders.Parsers.OBJParser.new( 25 )
	parser.addEventListener( Away3D.Events.Asset3DEvent.ASSET_COMPLETE, 
		function(event)
			if event.asset.assetType == Away3D.Library.Assets.Asset3DType.MESH then
				head = event.asset

				-- Apply a bitmap material that can be painted on.
				local bmd = Display.BitmapData.new( PAINT_TEXTURE_SIZE, PAINT_TEXTURE_SIZE, false, 0xFF0000, -1 )
				--bmd.perlinNoise( 50, 50, 8, 1, false, true, 7, true )
				local bitmapTexture = Textures.BitmapTexture.new( bmd, true )
				local textureMaterial = Materials.TextureMaterial.new( bitmapTexture, true, false, true, nil )
				textureMaterial.lightPicker = lightPicker
				head.material = textureMaterial

				-- Set up a ray picking collider.
				-- The head model has quite a lot of triangles, so its best to use pixel bender for ray picking calculations.
				-- NOTE: Pixel bender will not produce faster results on devices with only one cpu core, and will not work on iOS.
				head.pickingCollider = Away3D.Core.Pick.PickingColliderType.BEST_HIT
				-- model.pickingCollider = Away3D.Core.Pick.PickingColliderType.FIRST_ENCOUNTERED -- is faster, but causes weirdness around the eyes

				-- Apply mouse interactivity.
				head.mouseEnabled = true
				head.mouseChildren = true
				head.shaderPickingDetails = true
				enableMeshMouseListeners( head )

				view.scene.addChild( head )
			end
		end, false, 0, false )
	parser.parseAsync( Lib.Project.getBytes("/3D/Away3D/Intermediate_MouseInteraction/assets/head.obj"), 30 )

	-- Produce a bunch of objects to be around the scene.
	-- createABunchOfObjects
	cubeGeometry = Primitives.CubeGeometry.new( 25, 25, 25, 1, 1, 1, true )
	sphereGeometry = Primitives.SphereGeometry.new( 12, 16, 12, true )
	cylinderGeometry = Primitives.CylinderGeometry.new( 12, 12, 25, 16, 1, true, true, true, true )
	torusGeometry = Primitives.TorusGeometry.new( 12, 12, 16, 8, true )

    for i = 0, 40, 1 do
		-- Create object.
		local object = createSimpleObject()

		-- Random orientation.
		object.rotationX = 360 * math.random()
		object.rotationY = 360 * math.random()
		object.rotationZ = 360 * math.random()

		-- Random position.
		local r = 200 + 100 * math.random()
		local azimuth = 2 * math.pi * math.random()
		local elevation = 0.25 * math.pi * math.random()
		object.x = r * math.cos(elevation) * math.sin(azimuth)
		object.y = r * math.sin(elevation)
		object.z = r * math.cos(elevation) * math.cos(azimuth)
	end
		
	raycastPicker.setIgnoreList({sceneNormalTracer, scenePositionTracer})
	raycastPicker.onlyMouseEnabled = false
end

function initListeners()
	view.setRenderCallback(function(rect)
		if move then
			cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle
			cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle
		end
		cameraController.panAngle = cameraController.panAngle + panIncrement
		cameraController.tiltAngle = cameraController.tiltAngle + tiltIncrement
		cameraController.distance = cameraController.distance + distanceIncrement

		-- Move light with camera.
		pointLight.position = camera.position

		local collidingObject = raycastPicker.getSceneCollision(camera.position, view.camera.forwardVector, view.scene) --PickingCollisionVO
		--local mesh
		
		if previoiusCollidingObject ~= nil and previoiusCollidingObject ~= collidingObject then --equivalent to mouse out
			scenePositionTracer.visible = false
			sceneNormalTracer.visible = false
			scenePositionTracer.position = Geom.Vector3D.new(0,0,0,0)
		end
		
		if collidingObject ~= nil then
			-- Show tracers.
			scenePositionTracer.visible = true
			sceneNormalTracer.visible = true
			
			-- Update position tracer.
			scenePositionTracer.position = collidingObject.entity.sceneTransform.transformVector(collidingObject.localPosition)
			
			-- Update normal tracer.
			sceneNormalTracer.position = scenePositionTracer.position
			local normal = collidingObject.entity.sceneTransform.deltaTransformVector(collidingObject.localNormal) --Vector3D
			normal.normalize()
			normal.scaleBy( 25 )
			local lineSegment = sceneNormalTracer.getSegment( 0 ) --LineSegment
			lineSegment["end"] = normal.clone()
		end
		
		previoiusCollidingObject = collidingObject

		-- Render 3D.
		view.render()
	end)

	stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
		move = true
		lastPanAngle = cameraController.panAngle
		lastTiltAngle = cameraController.tiltAngle
		lastMouseX = stage.mouseX
		lastMouseY = stage.mouseY
	end, false, 0, false)

	stage.addEventListener(Events.MouseEvent.MOUSE_UP, function(e)
		move = false
	end, false, 0, false)

	local onResize = function(e)
		view.width = stage.stageWidth
		view.height = stage.stageHeight
	end

	stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
	onResize()
end

initEngine()
initLights()
initMaterials()
initObjects()
initListeners()