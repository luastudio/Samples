-- Main.lua

--[[Based on:

Basic GPU-based particle animation example in Away3d

Demonstrates:

How to use the ParticleAnimationSet to define static particle behaviour.
How to create particle geometry using the ParticleGeometryHelper class.
How to apply a particle animation to a particle geometry set using ParticleAnimator.
How to create a random spray of particles eminating from a central point.

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
View3D = Away3D.Containers.View3D
Mesh = Away3D.Entities.Mesh
Debug = Away3D.Debug
TextureMaterial = Away3D.Materials.TextureMaterial
PlaneGeometry = Away3D.Primitives.PlaneGeometry
HoverController = Away3D.Controllers.HoverController
Animators = Away3D.Animators
Cast = Away3D.Utils.Cast
Helpers = Away3D.Tools.Helpers
Geom = Lib.Media.Geom
stage = Display.stage

_move = false
_lastPanAngle = 0
_lastTiltAngle = 0
_lastMouseX = 0
_lastMouseY = 0

--setup the view
_view = View3D.new()
stage.addChild(_view)

_cameraController = HoverController.new(_view.camera, nil, 45, 2, 1000, -90, 90, nil, nil, 8,  2, false)

plane = PlaneGeometry.new(10, 10, 1, 1, false, false)
geometrySet = {}
for i = 1,20000,1 do
	geometrySet[i] = plane
end

_particleAnimationSet = Animators.ParticleAnimationSet.new(true, true, false)
_particleAnimationSet.addAnimation(Animators.Nodes.ParticleBillboardNode.new(nil))
_particleAnimationSet.addAnimation(Animators.Nodes.ParticleVelocityNode.new(Animators.Data.ParticlePropertiesMode.LOCAL_STATIC, nil))
_particleAnimationSet.initParticleFunc = function (prop)
	prop.startTime = math.random()*5 - 5
	prop.duration = 5;
	local degree1 = math.random() * math.pi
	local degree2 = math.random() * math.pi * 2
	local r = math.random() * 50 + 400
	prop.nodes.set(Animators.Nodes.ParticleVelocityNode.VELOCITY_VECTOR3D, Geom.Vector3D.new(r * math.sin(degree1) * math.cos(degree2), r * math.cos(degree1) * math.cos(degree2), r * math.sin(degree2), 0))
end

material = TextureMaterial.new(Cast.bitmapTexture("/3D/Away3D/Common/assets/particles/blue.png"), true, false, true, nil)
material.blendMode = Display.BlendMode.ADD

_particleAnimator = Animators.ParticleAnimator.new(_particleAnimationSet)

_particleMesh = Mesh.new(Helpers.ParticleGeometryHelper.generateGeometry(geometrySet, nil), material)
_particleMesh.animator = _particleAnimator
_view.scene.addChild(_particleMesh)

_particleAnimator.start()

_view.setRenderCallback(function(e)
	if _move then
		_cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle
		_cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle
	end
	_view.render()
end)

stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
	_lastPanAngle = _cameraController.panAngle
	_lastTiltAngle = _cameraController.tiltAngle
	_lastMouseX = stage.mouseX
	_lastMouseY = stage.mouseY
	_move = true
end, false, 0, false)

stage.addEventListener(Events.MouseEvent.MOUSE_UP, function(e)
	_move = false
end, false, 0, false)

onResize = function(e)
	_view.width = stage.stageWidth
	_view.height = stage.stageHeight
end
stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
onResize()

stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))