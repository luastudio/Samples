--Main.lua

--[[Based on:

Particle trails in Away3D

Demonstrates:

How to create a complex static particle behaviour
How to reuse a particle animation set and particle geometry in multiple animators and meshes
How to create a particle trail

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
Scene3D = Away3D.Containers.Scene3D
Animators = Away3D.Animators
Mesh = Away3D.Entities.Mesh
SegmentSet = Away3D.Entities.SegmentSet
Materials = Away3D.Materials
TextureMaterial = Materials.TextureMaterial
Primitives = Away3D.Primitives
Camera3D = Away3D.Cameras.Camera3D
Lenses = Away3D.Cameras.Lenses
PointLight = Away3D.Lights.PointLight
Textures = Away3D.Textures
HoverController = Away3D.Controllers.HoverController
Helpers = Away3D.Tools.Helpers
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Geom = Lib.Media.Geom
stage = Display.stage

move = false
angle = 0
lastPanAngle = 0
lastTiltAngle = 0

function initEngine()
    scene = Scene3D.new()
    camera = Camera3D.new(nil)
    view = View3D.new()

    view.antiAlias = 4
    view.scene = scene
    view.camera = camera

    --setup controller to be used on the camera
    cameraController = HoverController.new(camera, nil, 45, 20, 1000, 5, 90, nil, nil, 8,  2, false)

    stage.addChild(view)

    -- stats
    stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

function initMaterials()
    --setup particle material
    particleMaterial = TextureMaterial.new(Cast.bitmapTexture("/3D/Away3D/Intermediate_ParticleTrails/assets/cards_suit.png"), true, false, true, nil)
    particleMaterial.blendMode = Display.BlendMode.ADD
end

function initParticles()
    local plane = Primitives.PlaneGeometry.new(30, 30, 1, 1, false, false)

    --create the particle geometry
    local geometrySet = {}
    local setTransforms = {}
    for i = 1, 1000, 1 do
        geometrySet[i] = plane
        particleTransform = Helpers.Data.ParticleGeometryTransform.new()
        uvTransform = Geom.Matrix.new(1,0,0,1,0,0)
        uvTransform.scale(0.5, 0.5)
        uvTransform.translate(math.floor(math.random() * 2) / 2, math.floor(math.random() * 2) / 2)
        particleTransform.UVTransform = uvTransform
        setTransforms[i] = particleTransform
    end

    particleGeometry = Helpers.ParticleGeometryHelper.generateGeometry(geometrySet, setTransforms)


    --create the particle animation set
    particleAnimationSet = Animators.ParticleAnimationSet.new(true, true, true)

    --define the particle animations and init function
    particleAnimationSet.addAnimation(Animators.Nodes.ParticleBillboardNode.new(nil))
    particleAnimationSet.addAnimation(Animators.Nodes.ParticleVelocityNode.new(Animators.Data.ParticlePropertiesMode.LOCAL_STATIC, nil))
    particleAnimationSet.addAnimation(Animators.Nodes.ParticleColorNode.new(Animators.Data.ParticlePropertiesMode.GLOBAL,
            true, false, false, false, Geom.ColorTransform.new(1, 1, 1, 1, 0, 0, 0, 0), Geom.ColorTransform.new(1, 1, 1, 0, 0, 0, 0, 0), 1, 0))
    particleFollowNode = Animators.Nodes.ParticleFollowNode.new(true, false, false)
    particleAnimationSet.addAnimation(particleFollowNode)
    particleAnimationSet.initParticleFunc = function (properties)
        properties.startTime = math.random()*4.1
        properties.duration = 4
        properties.nodes.set(Animators.Nodes.ParticleVelocityNode.VELOCITY_VECTOR3D,
                Geom.Vector3D.new(math.random() * 100 - 50, math.random() * 100 - 200, math.random() * 100 - 50, 0))
    end
end

function initObjects()
    --create follow targets
    followTarget1 = Away3D.Core.Base.Object3D.new()
    followTarget2 = Away3D.Core.Base.Object3D.new()

    --create the particle meshes
    particleMesh1 = Mesh.new(particleGeometry, particleMaterial)
    particleMesh1.y = 300
    scene.addChild(particleMesh1)

    particleMesh2 = particleMesh1.clone()
    particleMesh2.y = 300
    scene.addChild(particleMesh2)

    --create and start the particle animators
    animator1 = Animators.ParticleAnimator.new(particleAnimationSet)
    particleMesh1.animator = animator1
    animator1.start()
    particleFollowNode.getAnimationState(animator1).followTarget = followTarget1

    animator2 = Animators.ParticleAnimator.new(particleAnimationSet)
    particleMesh2.animator = animator2
    animator2.start()
    particleFollowNode.getAnimationState(animator2).followTarget = followTarget2
end

function initListeners()
    view.setRenderCallback(function(rect)
        if move then
            cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle
            cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle
        end

        angle = angle + 0.04
        followTarget1.x = math.cos(angle) * 500
        followTarget1.z = math.sin(angle) * 500
        followTarget2.x = math.sin(angle) * 500

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
initMaterials()
initParticles()
initObjects()
initListeners()