-- Main.lua

--[[Based on:

Creating fire effects with particles in Away3D

Demonstrates:

How to setup a particle geometry and particle animationset in order to simulate fire.
How to stagger particle animation instances with different animator objects running on different timers.
How to apply fire lighting to a floor mesh using a multipass material.

Code by Rob Bateman & Liao Cheng
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
liaocheng210@126.com

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

Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
Animators = Away3D.Animators
View3D = Away3D.Containers.View3D
Scene3D = Away3D.Containers.Scene3D
Mesh = Away3D.Entities.Mesh
Materials = Away3D.Materials
Primitives = Away3D.Primitives
Camera3D = Away3D.Cameras.Camera3D
Lenses = Away3D.Cameras.Lenses
DirectionalLight = Away3D.Lights.DirectionalLight
PointLight = Away3D.Lights.PointLight
Textures = Away3D.Textures
HoverController = Away3D.Controllers.HoverController
Helpers = Away3D.Tools.Helpers
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Geom = Lib.Media.Geom
stage = Display.stage

move = false
lastPanAngle = 0
lastTiltAngle = 0
lastMouseX = 0
lastMouseY = 0
NUM_FIRES = 10

local FireVO = {}
function FireVO.new(mesh, animator)
    local self = {}

    self.mesh = mesh
    self.animator = animator
    self.light = nil
    self.strength = 0

    return self
end

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
	directionalLight = DirectionalLight.new(0, -1, 1)
	directionalLight.castsShadows = false
	directionalLight.color = 0xeedddd
	directionalLight.diffuse = 0.5
	directionalLight.ambient = 0.5
	directionalLight.specular = 0
	directionalLight.ambientColor = 0x808090

	view.scene.addChild(directionalLight)

	lightPicker = Materials.LightPickers.StaticLightPicker.new({directionalLight})
end

function initMaterials()
	planeMaterial = Materials.TextureMultiPassMaterial.new(Cast.bitmapTexture("/3D/Away3D/Common/assets/floor/floor_diffuse.jpg"), true, false, true, nil)
	planeMaterial.specularMap = Cast.bitmapTexture("/3D/Away3D/Common/assets/floor/floor_specular.jpg")
	planeMaterial.normalMap = Cast.bitmapTexture("/3D/Away3D/Common/assets/floor/floor_normal.jpg")
	planeMaterial.lightPicker = lightPicker
	planeMaterial["repeat"] = true
	planeMaterial.mipmap = false
	planeMaterial.specular = 10

	particleMaterial = Materials.TextureMaterial.new(Cast.bitmapTexture("/3D/Away3D/Common/assets/particles/blue.png"), true, false, true, nil)
	particleMaterial.blendMode = Display.BlendMode.ADD
end

function initParticles()
	--create the particle animation set
	fireAnimationSet = Animators.ParticleAnimationSet.new(true, true, false)

	--add some animations which can control the particles:
	--the global animations can be set directly, because they influence all the particles with the same factor
	fireAnimationSet.addAnimation(Animators.Nodes.ParticleBillboardNode.new(nil))
	fireAnimationSet.addAnimation(Animators.Nodes.ParticleScaleNode.new(Animators.Data.ParticlePropertiesMode.GLOBAL, false, false, 2.5, 0.5, 1, 0))
	fireAnimationSet.addAnimation(Animators.Nodes.ParticleVelocityNode.new(Animators.Data.ParticlePropertiesMode.GLOBAL, Geom.Vector3D.new(0, 80, 0, 0)))
	fireAnimationSet.addAnimation(Animators.Nodes.ParticleColorNode.new(Animators.Data.ParticlePropertiesMode.GLOBAL, true, true, false, false, Geom.ColorTransform.new(0, 0, 0, 1, 0xFF, 0x33, 0x01, 0), Geom.ColorTransform.new(0, 0, 0, 1, 0x99, 0, 0, 0), 1, 0))

	--no need to set the local animations here, because they influence all the particle with different factors.
	fireAnimationSet.addAnimation(Animators.Nodes.ParticleVelocityNode.new(Animators.Data.ParticlePropertiesMode.LOCAL_STATIC, nil))

	--set the initParticleFunc. It will be invoked for the local static property initialization of every particle
	fireAnimationSet.initParticleFunc = function (prop)
		prop.startTime = math.random() * 5
		prop.duration = math.random() * 4 + 0.1

		local degree1 = math.random() * math.pi * 2
		local degree2 = math.random() * math.pi * 2
		local r = 15
		prop.nodes.set(Animators.Nodes.ParticleVelocityNode.VELOCITY_VECTOR3D, Geom.Vector3D.new(r * math.sin(degree1) * math.cos(degree2), r * math.cos(degree1) * math.cos(degree2), r * math.sin(degree2), 0))
	end

	--create the original particle geometry
	local particle = Primitives.PlaneGeometry.new(10, 10, 1, 1, false, false)
	local geometrySet = {}
	for i = 1, 500, 1 do
		geometrySet[i] = particle
	end

	particleGeometry = Helpers.ParticleGeometryHelper.generateGeometry(geometrySet, nil)
end

function initObjects()
	fireObjects = {}

	plane = Mesh.new(
		Primitives.PlaneGeometry.new(1000, 1000, 1, 1, true, false), planeMaterial)
	plane.geometry.scaleUV(2, 2)
	plane.y = -20

	scene.addChild(plane)

	for i = 1, NUM_FIRES, 1 do
		local particleMesh = Mesh.new(particleGeometry, particleMaterial)
		local animator = Animators.ParticleAnimator.new(fireAnimationSet)
		particleMesh.animator = animator

		--position the mesh
		local degree = (i - 1) / NUM_FIRES * math.pi * 2
		particleMesh.x = math.sin(degree) * 400
		particleMesh.z = math.cos(degree) * 400
		particleMesh.y = 5

		fireObjects[i] = FireVO.new(particleMesh, animator)
		view.scene.addChild(particleMesh)
	end
	
	timer = Lib.Media.Utils.Timer.new(1000, #fireObjects)
	timer.addEventListener(Events.TimerEvent.TIMER, function(e)
		local fireObject = fireObjects[timer.currentCount]

		--start the animator
		fireObject.animator.start()
		
		--create the lightsource
		local light = PointLight.new()
		light.color = 0xFF3301
		light.diffuse = 0
		light.specular = 0
		light.position = fireObject.mesh.position
		
		--add the lightsource to the fire object
		fireObject.light = light
		
		--update the lightpicker
		local lights = {}
		lights[1] = directionalLight
		for i = 1,#fireObjects, 1 do
			local fireVO = fireObjects[i]
			if fireVO.light ~= nil then
				lights[#lights + 1] = fireVO.light
			end
		end
		lightPicker.lights = lights
	end, false, 0 ,false)
	timer.start()
end

function initListeners()
	view.setRenderCallback(function(rect)
		if move then
			cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle
			cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle
		end

		for i = 1, #fireObjects, 1 do
			fireVO = fireObjects[i]
			local light = fireVO.light
			if light ~= nil then
				if fireVO.strength < 1 then
					fireVO.strength = fireVO.strength + 0.1
				end
			
				light.fallOff = 380 + math.random() * 20
				light.radius = 200 + math.random() * 30
				light.diffuse = fireVO.strength + math.random() * 0.2
				light.specular = light.diffuse
			end
		end

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
initParticles()
initObjects()
initListeners()