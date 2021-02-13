--Main.lua (WARNING: require internet connection)

--[[Based on:

Real time planar reflections

Demonstrates:

How to use the PlanarReflectionTexture to render dynamic planar reflections
How to use EnvMapMethod to apply the dynamic environment map to a material

Code by David Lenaerts
david.lenaerts@gmail.com
http://www.derschmale.com

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
Sprite = Display.Sprite
Events = Lib.Media.Events
Geom = Lib.Media.Geom
Keyboard = Lib.Media.UI.Keyboard
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Materials = Away3D.Materials
Extrusions = Away3D.Extrusions
DirectionalLight = Away3D.Lights.DirectionalLight
Asset3DLibrary = Away3D.Library.Asset3DLibrary
Cast = Away3D.Utils.Cast
Primitives = Away3D.Primitives
HoverController = Away3D.Controllers.HoverController
Mesh = Away3D.Entities.Mesh
Textures = Away3D.Textures
Debug = Away3D.Debug
stage = Display.stage
Thread = Lib.Sys.VM.Thread

MAX_SPEED = 1.0
MAX_ROTATION_SPEED = 10.0
ACCELERATION = .5
ROTATION = .5

move = false
lastPanAngle = 0.0
lastTiltAngle = 0.0
lastMouseX = 0.0
lastMouseY = 0.0
_rotationAccel = 0.0
_acceleration = 0.0
_speed = 0.0
_rotationSpeed = 0.0


function loadAssetsFromWebInThread()
    local t = Thread.create([[
Thread = Lib.Sys.VM.Thread
Cast = Lib.Away3D.Utils.Cast
require("/Common/Utils.lua")
Assets.Web.log = true
--Assets.Web.cache = true
--get ref to main
local main = Thread.readMessage(true)
main.sendMessage({

    desertHeightMap = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/desertHeightMap.jpg")),
    desertsand = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/desertsand.jpg")),
    r2d2_diffuse = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/r2d2_diffuse.jpg")),
    R2D2 = Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/R2D2.obj"),

    space_posX = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_posX.jpg")), -- left
    space_negX = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_negX.jpg")), -- right
    space_posY = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_posY.jpg")), -- top
    space_negY = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_negY.jpg")), -- bottom
    space_posZ = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_posZ.jpg")), -- back
    space_negZ = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_PlanarReflection/assets/skybox/space_negZ.jpg"))  -- front

})
]])
    t.sendMessage(Thread.current())
end

function initEngine()
    view = View3D.new()

    scene = view.scene
    camera = view.camera
    camera.lens.far = 4000

    --setup controller to be used on the camera
    cameraController = HoverController.new(camera, nil, 45, 10, 400, 10, 90, nil, nil, 8,  2, false)

    stage.addChild(view)

    stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

function initLights()
    light = DirectionalLight.new(-1, -2, 1)
    light.color = 0xeedddd
    light.ambient = 1
    light.ambientColor = 0x808090
    scene.addChild(light)
end

function initReflectionTexture()
    reflectionTexture = Textures.PlanarReflectionTexture.new()
end

function initSkyBox()
    skyboxTexture = Textures.BitmapCubeTexture.new(
            assets.space_posX, assets.space_negX,
            assets.space_posY, assets.space_negY,
            assets.space_posZ, assets.space_negZ
    )

    scene.addChild(Primitives.SkyBox.new(skyboxTexture))
end

function initMaterials()
    local desertTexture = assets.desertsand
    lightPicker = Materials.LightPickers.StaticLightPicker.new({light})
    fogMethod = Materials.Methods.FogMethod.new(0, 2000, 0x100215)

    floorMaterial = Materials.TextureMaterial.new(desertTexture, true, false, true, nil)
    floorMaterial.lightPicker = lightPicker
    floorMaterial.addMethod(fogMethod)
    floorMaterial['repeat'] = true
    floorMaterial.gloss = 5
    floorMaterial.specular = .1

    desertMaterial = Materials.TextureMaterial.new(desertTexture, true, false, true, nil)
    desertMaterial.lightPicker = lightPicker
    desertMaterial.addMethod(fogMethod)
    desertMaterial['repeat'] = true
    desertMaterial.gloss = 5
    desertMaterial.specular = .1

    r2d2Material = Materials.TextureMaterial.new(assets.r2d2_diffuse, true, false, true, nil)
    r2d2Material.lightPicker = lightPicker
    r2d2Material.addMethod(fogMethod)
    r2d2Material.addMethod(Materials.Methods.EnvMapMethod.new(skyboxTexture,.2))

    -- create a PlanarReflectionMethod
    local reflectionMethod = Materials.Methods.PlanarReflectionMethod.new(reflectionTexture, 1)
    reflectiveMaterial = Materials.ColorMaterial.new(0x000000,.9)
    reflectiveMaterial.addMethod(reflectionMethod)
end

function initDesert()
    local desert = Extrusions.Elevation.new(desertMaterial, assets.desertHeightMap, 5000, 600, 5000, 75, 75, 255, nil, false)

    desert.y = -3
    desert.geometry.scaleUV(25, 25)
    scene.addChild(desert)

    -- small desert patch that can receive shadows
    local floor = Mesh.new(Primitives.PlaneGeometry.new(800, 800, 1, 1, true, false), floorMaterial)
    floor.geometry.scaleUV(800 / 5000 * 25, 800 / 5000 * 25)	-- match uv coords with that of the desert
    scene.addChild(floor)
end

function initMirror()
    local geometry = Primitives.PlaneGeometry.new(400, 200, 1, 1, false, false)
    local mesh = Mesh.new(geometry, reflectiveMaterial)
    mesh.y = mesh.maxY
    mesh.z = -200
    mesh.rotationY = 180
    scene.addChild(mesh)

    -- need to apply plane's transform to the reflection, compatible with PlaneGeometry created in this manner
    -- other ways is to set reflectionTexture.plane = Plane3D.new(...)
	reflectionTexture.applyTransform(mesh.sceneTransform)
end

function initObjects()
    initDesert()
    initMirror()

    Away3D.Library.Asset3DLibrary.addEventListener(Away3D.Events.Asset3DEvent.ASSET_COMPLETE,
            function(event)
                if event.asset.assetType == Away3D.Library.Assets.Asset3DType.MESH then
                    r2d2 = event.asset
                    r2d2.scale(5)
                    r2d2.material = r2d2Material
                    r2d2.x = 200
                    r2d2.y = 30
                    r2d2.z = 0
                    scene.addChild(r2d2)

                    stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
                        if e.target.name == "up" then
                            _acceleration = ACCELERATION
                        elseif e.target.name == "down" then
                            _acceleration = -ACCELERATION
                        elseif e.target.name == "left" then
                            _rotationAccel = -ROTATION
                        elseif e.target.name == "right" then
                            _rotationAccel = ROTATION
                        else
                            lastPanAngle = cameraController.panAngle
                            lastTiltAngle = cameraController.tiltAngle
                            lastMouseX = stage.mouseX
                            lastMouseY = stage.mouseY
                            move = true
                        end
                    end, false, 0, false)
                    stage.addEventListener(Events.MouseEvent.MOUSE_UP, function(e)
                        if e.target.name == "up" or e.target.name == "down" then
                            _acceleration = 0
                        elseif e.target.name == "left" or e.target.name == "right" then
                            _rotationAccel = 0
                        else
                            move = false
                        end
                    end, false, 0, false)
                end
            end, false, 0, false)
    Away3D.Library.Asset3DLibrary.loadData(assets.R2D2, nil, nil, nil)
end

function onResize()
    view.width = stage.stageWidth
    view.height = stage.stageHeight
    spriteNavigation.x = 20
    spriteNavigation.y = stage.stageHeight - spriteNavigation.height - 20
end

function updateR2D2()
    _speed = _speed *.95
    _speed = _speed +_acceleration
    if _speed > MAX_SPEED then _speed = MAX_SPEED
    elseif _speed < -MAX_SPEED then _speed = -MAX_SPEED end

    _rotationSpeed = _rotationSpeed + _rotationAccel
    _rotationSpeed = _rotationSpeed * .9
    if _rotationSpeed > MAX_ROTATION_SPEED then _rotationSpeed = MAX_ROTATION_SPEED
    elseif _rotationSpeed < -MAX_ROTATION_SPEED then _rotationSpeed = -MAX_ROTATION_SPEED end

    r2d2.moveForward(_speed)
    r2d2.rotationY = r2d2.rotationY + _rotationSpeed
end

function initListeners()
    view.setRenderCallback(function(rect)
        if move then
            cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle
            cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle
        end

        if r2d2 ~= nil then
            updateR2D2()
        end

        cameraController.update(true)

        -- render the view's scene to the reflection texture (view is required to use the correct stage3DProxy)
		reflectionTexture.render(view)
		view.render()
    end)

    stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
    stage.addEventListener(Events.KeyboardEvent.KEY_DOWN,
            function(e)
                if e.keyCode == Keyboard.W or e.keyCode == Keyboard.UP then
                    _acceleration = ACCELERATION
                elseif e.keyCode == Keyboard.S or e.keyCode == Keyboard.DOWN then
                    _acceleration = -ACCELERATION
                elseif e.keyCode == Keyboard.A or e.keyCode == Keyboard.LEFT then
                    _rotationAccel = -ROTATION
                elseif e.keyCode == Keyboard.D or e.keyCode == Keyboard.RIGHT then
                    _rotationAccel = ROTATION
                end
            end, false, 0, false)
    stage.addEventListener(Events.KeyboardEvent.KEY_UP,
            function(e)
                if e.keyCode == Keyboard.W or e.keyCode == Keyboard.S or e.keyCode == Keyboard.UP or e.keyCode == Keyboard.DOWN then
                    _acceleration = 0
                elseif e.keyCode == Keyboard.A or e.keyCode == Keyboard.D or e.keyCode == Keyboard.LEFT or e.keyCode == Keyboard.RIGHT then
                    _rotationAccel = 0
                end
            end, false, 0, false)
    onResize()
end

--navigation
function initNavigation()
    size = (stage.stageWidth > stage.stageHeight and stage.stageWidth or stage.stageHeight)  / 6

    spriteNavigation = Sprite.new()
    stage.addChild(spriteNavigation)

    local sprite = Sprite.new()
    sprite.name = "up"
    sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
    sprite.graphics.beginFill(0xFFFF00, 1.0)
    sprite.graphics.moveTo(0 + size / 2, 0)
    sprite.graphics.lineTo(0 + size / 3, 0 + size / 3)
    sprite.graphics.lineTo(0 + 2 * size / 3, 0 + size / 3)
    sprite.graphics.lineTo(0 + size / 2,0)
    sprite.graphics.endFill()
    sprite.buttonMode = true
    spriteNavigation.addChild(sprite)

    sprite = Sprite.new()
    sprite.name = "left"
    sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
    sprite.graphics.beginFill(0xFFFF00, 1.0)
    sprite.graphics.moveTo(0, 0 + size / 2)
    sprite.graphics.lineTo(0 + size / 3, 0 + size / 3)
    sprite.graphics.lineTo(0 + size / 3, 0 + 2 * size / 3)
    sprite.graphics.lineTo(0, 0 + size / 2)
    sprite.graphics.endFill()
    sprite.buttonMode = true
    spriteNavigation.addChild(sprite)

    sprite = Sprite.new()
    sprite.name = "down"
    sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
    sprite.graphics.beginFill(0xFFFF00, 1.0)
    sprite.graphics.moveTo(0 + size / 2, 0 + size)
    sprite.graphics.lineTo(0 + size / 3, 0 + 2 * size / 3)
    sprite.graphics.lineTo(0 + 2 * size / 3, 0 + 2 * size / 3)
    sprite.graphics.lineTo(0 + size / 2, 0 + size)
    sprite.graphics.endFill()
    sprite.buttonMode = true
    spriteNavigation.addChild(sprite)

    sprite = Sprite.new()
    sprite.name = "right"
    sprite.graphics.lineStyle(2, 0x00FF00, 1.0, false, nil, nil, nil, 3)
    sprite.graphics.beginFill(0xFFFF00, 1.0)
    sprite.graphics.moveTo(0 + size, 0 + size / 2)
    sprite.graphics.lineTo(0 + 2 * size / 3, 0 + size / 3)
    sprite.graphics.lineTo(0 + 2 * size / 3, 0 + 2 * size / 3)
    sprite.graphics.lineTo(0 + size, 0 + size / 2)
    sprite.graphics.endFill()
    sprite.buttonMode = true
    spriteNavigation.addChild(sprite)
end

loadAssetsFromWebInThread()
initEngine()
initLights()
initReflectionTexture()

function processModel()
    initSkyBox()
    initMaterials()
    initObjects()
    initNavigation()
    initListeners()
end

function frameEvent(e)
    assets = Thread.readMessage(false)
    if assets ~= nil then
        Lib.Media.Display.stage.removeEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false)

        processModel()
    end
end

--wait for thread to finish
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false, 0, false)