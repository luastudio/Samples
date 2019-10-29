-- Main.lua

--[[Based on:

Particle explosions in Away3D using the Lua and LuaStudio logos

Demonstrates:

How to split images into particles.
How to share particle geometries and animation sets between meshes and animators.
How to manually update the playhead of a particle animator using the update() function.

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

-- declarations
Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Scene3D = Away3D.Containers.Scene3D
Animators = Away3D.Animators
Mesh = Away3D.Entities.Mesh
SegmentSet = Away3D.Entities.SegmentSet
Materials = Away3D.Materials
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

if type(jit) == 'table' then
    bit32 = bit
end

PARTICLE_SIZE = 3
NUM_ANIMATORS = 2

angle = 0
move = false
lastPanAngle = 0
lastTiltAngle = 0
lastMouseX = 0
lastMouseY = 0

whitePoints = {}
bluePoints = {}

function initEngine()
    scene = Scene3D.new()
    view = View3D.new()
    camera = Camera3D.new(nil)

    view.scene = scene
    view.camera = camera

    --setup controller to be used on the camera
    cameraController = HoverController.new(camera, nil, 225, 10, 1000, 5, 90, nil, nil, 8,  2, false)

    stage.addChild(view)

    -- stats
    stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

function initLights()
    --create a green point light
    greenLight = PointLight.new()
    greenLight.color = 0x00FF00
    greenLight.ambient = 1
    greenLight.fallOff = 600
    greenLight.radius = 100
    greenLight.specular = 2
    scene.addChild(greenLight)

    --create a blue pointlight
    orangeLight = PointLight.new()
    orangeLight.color = 0xFF9900
    orangeLight.fallOff = 600
    orangeLight.radius = 100
    orangeLight.specular = 2
    scene.addChild(orangeLight)

    --create a lightpicker for the green and blue light
    lightPicker = Materials.LightPickers.StaticLightPicker.new({greenLight, orangeLight})
end

function initMaterials()
    --setup the blue particle material
    blueMaterial = Materials.ColorMaterial.new(0x000080, 1)
    blueMaterial.alphaPremultiplied = true
    blueMaterial.bothSides = true
    blueMaterial.lightPicker = lightPicker

    --setup the white particle material
    whiteMaterial = Materials.ColorMaterial.new(0xFFFFFF, 0.2)
    whiteMaterial.alphaPremultiplied = true
    whiteMaterial.bothSides = true
    whiteMaterial.lightPicker = lightPicker
end

function initParticles()
    local bitmapData = Cast.bitmapData("/3D/Away3D/Intermediate_ParticleExplosions/assets/Lua.png")

    --define where one logo stops and another starts
    whiteSeparation = 0
    blueSeparation = 0

    for i = 0, bitmapData.width - 1, 1 do
        for j = 0, bitmapData.height - 1, 1 do
            point = Geom.Vector3D.new(PARTICLE_SIZE*(i - bitmapData.width / 2 - 100), PARTICLE_SIZE*( -j + bitmapData.height / 2), 0, 0)
            if bit32.band(bit32.rshift(bitmapData.getPixel32(i, j), 24), 0xff) == 0 then
                whiteSeparation = whiteSeparation + 1 whitePoints[whiteSeparation] = point
            else
                blueSeparation = blueSeparation + 1 bluePoints[blueSeparation] = point
            end
        end
    end

    --create blue and white point vectors for the LuaStudio image
    bitmapData = Cast.bitmapData("/3D/Away3D/Intermediate_ParticleExplosions/assets/LuaStudio.png")

    --define where one logo stops and another starts
    local numBlue = blueSeparation
    local numWhite = whiteSeparation

    for i = 0, bitmapData.width - 1, 1 do
        for j = 0, bitmapData.height - 1, 1 do
            point = Geom.Vector3D.new(PARTICLE_SIZE*(i - bitmapData.width / 2 + 100), PARTICLE_SIZE*( -j + bitmapData.height / 2), 0, 0)
            if bit32.band(bit32.rshift(bitmapData.getPixel32(i, j), 24), 0xff) == 0 then
                numWhite = numWhite + 1  whitePoints[numWhite] = point
            else
                numBlue = numBlue + 1  bluePoints[numBlue] = point
            end
        end
    end

    local plane = Primitives.PlaneGeometry.new(PARTICLE_SIZE, PARTICLE_SIZE, 1, 1, false, false)

    --combine them into a table
    local blueGeometrySet = {}
    for i = 1, numBlue, 1 do
        blueGeometrySet[i] = plane
    end

    local whiteGeometrySet = {}
    for i = 1, numWhite, 1 do
        whiteGeometrySet[i] = plane
    end

    --generate the particle geometries
    blueGeometry = Helpers.ParticleGeometryHelper.generateGeometry(blueGeometrySet, nil)
    whiteGeometry = Helpers.ParticleGeometryHelper.generateGeometry(whiteGeometrySet, nil)

    --define the blue particle animations and init function
    blueAnimationSet = Animators.ParticleAnimationSet.new(true, true, false)
    blueAnimationSet.addAnimation(Animators.Nodes.ParticleBillboardNode.new(nil))
    blueAnimationSet.addAnimation(Animators.Nodes.ParticleBezierCurveNode.new(Animators.Data.ParticlePropertiesMode.LOCAL_STATIC, nil, nil))
    blueAnimationSet.addAnimation(Animators.Nodes.ParticlePositionNode.new(Animators.Data.ParticlePropertiesMode.LOCAL_STATIC, nil))
    blueAnimationSet.initParticleFunc = function (properties)
        properties.startTime = 0
        properties.duration = 1
        local degree1 = math.random() * math.pi * 2
        local degree2 = math.random() * math.pi * 2
        local r = 500

        if properties.index < blueSeparation then
            properties.nodes.set(Animators.Nodes.ParticleBezierCurveNode.BEZIER_END_VECTOR3D, Geom.Vector3D.new(200*PARTICLE_SIZE, 0, 0, 0))
        else
            properties.nodes.set(Animators.Nodes.ParticleBezierCurveNode.BEZIER_END_VECTOR3D, Geom.Vector3D.new(-200*PARTICLE_SIZE, 0, 0, 0))
        end

        properties.nodes.set(Animators.Nodes.ParticleBezierCurveNode.BEZIER_CONTROL_VECTOR3D, Geom.Vector3D.new(r * math.sin(degree1) * math.cos(degree2), r * math.cos(degree1) * math.cos(degree2), 2*r * math.sin(degree2), 0))
        properties.nodes.set(Animators.Nodes.ParticlePositionNode.POSITION_VECTOR3D, bluePoints[properties.index + 1])
    end

    --define the white particle animations and init function
    whiteAnimationSet = Animators.ParticleAnimationSet.new(true, true, false)
    whiteAnimationSet.addAnimation(Animators.Nodes.ParticleBillboardNode.new(nil))
    whiteAnimationSet.addAnimation(Animators.Nodes.ParticleBezierCurveNode.new(Animators.Data.ParticlePropertiesMode.LOCAL_STATIC, nil, nil))
    whiteAnimationSet.addAnimation(Animators.Nodes.ParticlePositionNode.new(Animators.Data.ParticlePropertiesMode.LOCAL_STATIC, nil))
    whiteAnimationSet.initParticleFunc = function (properties)
        properties.duration = 1
        local degree1 = math.random() * math.pi * 2
        local degree2 = math.random() * math.pi * 2
        local r = 500

        if properties.index < whiteSeparation then
            properties.nodes.set(Animators.Nodes.ParticleBezierCurveNode.BEZIER_END_VECTOR3D, Geom.Vector3D.new(200*PARTICLE_SIZE, 0, 0, 0))
        else
            properties.nodes.set(Animators.Nodes.ParticleBezierCurveNode.BEZIER_END_VECTOR3D, Geom.Vector3D.new(-200*PARTICLE_SIZE, 0, 0, 0))
        end

        properties.nodes.set(Animators.Nodes.ParticleBezierCurveNode.BEZIER_CONTROL_VECTOR3D, Geom.Vector3D.new(r * math.sin(degree1) * math.cos(degree2), r * math.cos(degree1) * math.cos(degree2), r * math.sin(degree2), 0))
        properties.nodes.set(Animators.Nodes.ParticlePositionNode.POSITION_VECTOR3D, whitePoints[properties.index + 1])
    end
end

function initObjects()
    --initialise animators vectors
    blueAnimators = {}
    whiteAnimators = {}

    --create the blue particle mesh
    blueParticleMesh = Mesh.new(blueGeometry, blueMaterial)

    --create the white particle mesh
    whiteParticleMesh = Mesh.new(whiteGeometry, whiteMaterial)

    for i = 0, NUM_ANIMATORS - 1, 1 do
        --clone the blue particle mesh
        blueParticleMesh = blueParticleMesh.clone()
        blueParticleMesh.rotationY = 45*(i-1)
        scene.addChild(blueParticleMesh)

        --clone the white particle mesh
        whiteParticleMesh = whiteParticleMesh.clone()
        whiteParticleMesh.rotationY = 45*(i-1)
        scene.addChild(whiteParticleMesh)

        --create and start the blue particle animator
        blueAnimators[i+1] = Animators.ParticleAnimator.new(blueAnimationSet)
        blueParticleMesh.animator = blueAnimators[i+1]
        scene.addChild(blueParticleMesh)

        --create and start the white particle animator
        whiteAnimators[i+1] = Animators.ParticleAnimator.new(whiteAnimationSet)
        whiteParticleMesh.animator = whiteAnimators[i+1]
        scene.addChild(whiteParticleMesh)
    end
end

function initListeners()
    view.setRenderCallback(function(rect)
        --update the camera position
        cameraController.panAngle = cameraController.panAngle + 0.2

        --update the particle animator playhead positions
        local time
        for i = 0, NUM_ANIMATORS - 1, 1 do
            time = math.floor(1000*(math.sin(Lib.Sys.getTime()/5000 + math.pi*i/4) + 1))
            blueAnimators[i+1].update(time)
            whiteAnimators[i+1].update(time)
        end

        if move then
            cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle
            cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle
        end

        --update the light positions
        angle = angle + math.pi / 180
        greenLight.x = math.sin(angle) * 600
        greenLight.z = math.cos(angle) * 600
        orangeLight.x = math.sin(angle+math.pi) * 600
        orangeLight.z = math.cos(angle+math.pi) * 600

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