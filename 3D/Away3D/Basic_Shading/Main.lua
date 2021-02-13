-- Main.lua

--[[Based on:

Shading example in Away3d

Demonstrates:

How to create multiple lightsources in a scene.
How to apply specular maps, normals maps and diffuse texture maps to a material.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

This code is distributed under the MIT License

Copyright (c) The Away Foundation http://www.theawayfoundation.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

-- declarations
Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Scene3D = Away3D.Containers.Scene3D
Mesh = Away3D.Entities.Mesh
Materials = Away3D.Materials
Primitives = Away3D.Primitives
Camera3D = Away3D.Cameras.Camera3D
Lenses = Away3D.Cameras.Lenses
DirectionalLight = Away3D.Lights.DirectionalLight
Textures = Away3D.Textures
HoverController = Away3D.Controllers.HoverController
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Geom = Lib.Media.Geom
stage = Display.stage

-- variables
move = false
lastPanAngle = 0
lastTiltAngle = 0
lastMouseX = 0
lastMouseY = 0

function initEngine()
	scene = Scene3D.new()
	camera = Camera3D.new(nil)

	--setup the view
	view = View3D.new()
	view.antiAlias = 4
	view.scene = scene
	view.camera = camera
	stage.addChild(view)

	cameraController = HoverController.new(camera, nil, 0, 90, 1000, -90, 90, nil, nil, 8,  2, false)
	cameraController.distance = 1000
	cameraController.minTiltAngle = 0
	cameraController.maxTiltAngle = 90
	cameraController.panAngle = 45
	cameraController.tiltAngle = 20

	-- stats
	stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

function initLights()
	light1 = DirectionalLight.new(0, -1, 1)
    light1.direction = Geom.Vector3D.new(0, -1, 0, 0)
    light1.ambient = 0.1
    light1.diffuse = 0.7

	scene.addChild(light1)

	light2 = DirectionalLight.new(0, -1, 1)
    light2.direction = Geom.Vector3D.new(0, -1, 0, 0)
    light2.ambient = 0.1
    light2.diffuse = 0.7

	scene.addChild(light2)

	lightPicker = Materials.LightPickers.StaticLightPicker.new({light1  , light2})
end

function initMaterials()
	planeMaterial = Materials.TextureMaterial.new(Cast.bitmapTexture("/3D/Away3D/Common/assets/floor/floor_diffuse.jpg"), true, false, true, nil)
	planeMaterial.specularMap = Cast.bitmapTexture("/3D/Away3D/Common/assets/floor/floor_specular.jpg")
	planeMaterial.normalMap = Cast.bitmapTexture("/3D/Away3D/Common/assets/floor/floor_normal.jpg")
	planeMaterial.lightPicker = lightPicker
	planeMaterial["repeat"] = true

	sphereMaterial = Materials.TextureMaterial.new(Cast.bitmapTexture("/3D/Away3D/Basic_Shading/assets/beachball_diffuse.jpg"), true, false, true, nil)
	sphereMaterial.specularMap = Cast.bitmapTexture("/3D/Away3D/Basic_Shading/assets/beachball_specular.jpg")
	sphereMaterial.lightPicker = lightPicker

	cubeMaterial = Materials.TextureMaterial.new(Cast.bitmapTexture("/3D/Away3D/Basic_Shading/assets/trinket_diffuse.jpg"), true, false, true, nil)
	cubeMaterial.specularMap = Cast.bitmapTexture("/3D/Away3D/Basic_Shading/assets/trinket_specular.jpg")
	cubeMaterial.normalMap = Cast.bitmapTexture("/3D/Away3D/Basic_Shading/assets/trinket_normal.jpg")
	cubeMaterial.lightPicker = lightPicker
	cubeMaterial.mipmap = false

	local weaveDiffuseTexture = Cast.bitmapTexture("/3D/Away3D/Basic_Shading/assets/weave_diffuse.jpg")
	torusMaterial = Materials.TextureMaterial.new(weaveDiffuseTexture, true, false, true, nil)
	torusMaterial.specularMap = weaveDiffuseTexture
	torusMaterial.normalMap = Cast.bitmapTexture("/3D/Away3D/Basic_Shading/assets/weave_normal.jpg")
	torusMaterial.lightPicker = lightPicker
	torusMaterial["repeat"] = true
end

function initObjects()
	plane = Mesh.new(
		Primitives.PlaneGeometry.new(1000, 1000, 1, 1, true, false), planeMaterial)
	plane.geometry.scaleUV(2, 2)
	plane.y = -20

	scene.addChild(plane)

	sphere = Mesh.new(
		Primitives.SphereGeometry.new(150, 40, 20, true), sphereMaterial)
	sphere.x = 300
	sphere.y = 160
	sphere.z = 300

	scene.addChild(sphere)

	cube = Mesh.new(
		Primitives.CubeGeometry.new(200, 200, 200, 1, 1, 1, false), cubeMaterial)
	cube.x = 300
	cube.y = 160
	cube.z = -250

	scene.addChild(cube)

	torus = Mesh.new(
		Primitives.TorusGeometry.new(150, 60, 40, 20, true), torusMaterial)
	torus.geometry.scaleUV(10, 5)
	torus.x = -250
	torus.y = 160
	torus.z = -250

	scene.addChild(torus)
end

function initListeners()
	view.setRenderCallback(function(rect)
		if move then
			cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle
			cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle
		end
		light1.direction = Geom.Vector3D.new(math.sin(Lib.Sys.getTime()/10000)*150000, 1000, math.cos(Lib.Sys.getTime()/10000)*150000, 0)

		view.render()
	end)

	stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
		lastPanAngle = cameraController.panAngle
		lastTiltAngle = cameraController.tiltAngle
		lastMouseX = stage.mouseX
		lastMouseY = stage.mouseY
		move = true
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