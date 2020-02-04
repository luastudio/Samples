-- Main.lua (WARNING: require internet connection)

--[[Based on:

Real time environment map reflections

Demonstrates:

How to use the CubeReflectionTexture to dynamically render environment maps.
How to use EnvMapMethod to apply the dynamic environment map to a material.
How to use the Elevation extrusions class to create a terrain from a heightmap.

Code by David Lenaerts & Rob Bateman
david.lenaerts@gmail.com
http://www.derschmale.com
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

This code is distributed under the MIT License

Copyright (c) The Away Foundation http://www.theawayfoundation.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
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

--constants for R2D2 movement
MAX_SPEED = 1.0
MAX_ROTATION_SPEED = 10.0
DRAG = .95
ACCELERATION = .5
ROTATION = .5

--navigation variables
move = false
lastPanAngle = 0.0
lastTiltAngle = 0.0
lastMouseX = 0.0
lastMouseY = 0.0

--R2D2 motion variables
--_drag = 0.95
_acceleration = 0.0
--_rotationDrag = 0.95
_rotationAccel = 0.0
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

    desertHeightMap = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/desertHeightMap.jpg")),
    arid = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/arid.jpg")),
    r2d2_diffuse = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/r2d2_diffuse.jpg")),
    R2D2 = Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/R2D2.obj"),
    head = Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/head.obj"),

    sky_posX = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/skybox/sky_posX.jpg")), -- left
    sky_negX = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/skybox/sky_negX.jpg")), -- right
    sky_posY = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/skybox/sky_posY.jpg")), -- top
    sky_negY = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/skybox/sky_negY.jpg")), -- bottom
    sky_posZ = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/skybox/sky_posZ.jpg")), -- back
    sky_negZ = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Intermediate_RealTimeEnvMap/assets/skybox/sky_negZ.jpg"))  -- front

})
]])
    t.sendMessage(Thread.current())
end

function initEngine()
    view = View3D.new()
    view.camera.lens.far = 4000

    stage.addChild(view)

    --setup controller to be used on the camera
    cameraController = HoverController.new(view.camera, nil, 90, 10, 600, 2, 90, nil, nil, 8,  2, false)
    cameraController.lookAtPosition = Geom.Vector3D.new(0, 120, 0, 0)
    cameraController.wrapPanAngle = true

    stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

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

function initLights()
    light = DirectionalLight.new(-1, -2, 1)
    light.color = 0xeedddd
    light.ambient = 1
    light.ambientColor = 0x808090
    view.scene.addChild(light)

    --create global lightpicker
    lightPicker = Materials.LightPickers.StaticLightPicker.new({light})

    --create global fog method
    fogMethod = Materials.Methods.FogMethod.new(500, 2000, 0x5f5e6e)
end

function initReflectionCube()

end

function initMaterials()
    -- create reflection texture with a dimension of 256x256x256
    reflectionTexture = Textures.CubeReflectionTexture.new(256)
    reflectionTexture.farPlaneDistance = 3000
    reflectionTexture.nearPlaneDistance = 50

    -- center the reflection at (0, 100, 0) where our reflective object will be
    reflectionTexture.position = Geom.Vector3D.new(0, 100, 0, 0)

    --setup the skybox texture
    skyboxTexture = Textures.BitmapCubeTexture.new(
            assets.sky_posX, assets.sky_negX,
            assets.sky_posY, assets.sky_negY,
            assets.sky_posZ, assets.sky_negZ
    )

    -- setup desert floor material
    desertMaterial = Materials.TextureMaterial.new(assets.arid, true, false, true, nil)
    desertMaterial.lightPicker = lightPicker
    desertMaterial.addMethod(fogMethod)
    desertMaterial["repeat"] = true
    desertMaterial.gloss = 5
    desertMaterial.specular = 0.1

    --setup R2D2 material
    r2d2Material = Materials.TextureMaterial.new(assets.r2d2_diffuse, true, false, true, nil)
    r2d2Material.lightPicker = lightPicker
    r2d2Material.addMethod(fogMethod)
    r2d2Material.addMethod(Materials.Methods.EnvMapMethod.new(skyboxTexture,.2))

    -- setup fresnel method using our reflective texture in the place of a static environment map
    local fresnelMethod = Materials.Methods.FresnelEnvMapMethod.new(reflectionTexture, 1)
    fresnelMethod.normalReflectance = 0.6
    fresnelMethod.fresnelPower = 2

    --setup the reflective material
    reflectiveMaterial = Materials.ColorMaterial.new(0x000000, 1.0)
    reflectiveMaterial.addMethod(fresnelMethod)
end

function initObjects()
    --create the skybox
    view.scene.addChild(Primitives.SkyBox.new(skyboxTexture))

    --create the desert ground
    local desert = Extrusions.Elevation.new(desertMaterial, assets.desertHeightMap,
            5000, 300, 5000, 250, 250, 255, nil, false)
    desert.y = -3
    desert.geometry.scaleUV(25, 25)
    view.scene.addChild(desert)

    -- load model data
    Away3D.Library.Asset3DLibrary.addEventListener(Away3D.Events.Asset3DEvent.ASSET_COMPLETE,
            function(event)
                if event.asset.assetType == Away3D.Library.Assets.Asset3DType.MESH then
                    if event.asset.name == "g0" then -- Head
                        head = event.asset
                        head.scale(60)
                        head.y = 180
                        head.rotationY = -90
                        head.material = reflectiveMaterial
                        view.scene.addChild(head)
                    else -- R2D2
                        r2d2 = event.asset
                        r2d2.scale( 5 )
                        r2d2.material = r2d2Material
                        r2d2.x = 200
                        r2d2.y = 30
                        r2d2.z = 0.1 --initial not 0 for better panAngle calculation
                        view.scene.addChild(r2d2)
                    end
                end
            end, false, 0, false)
    Away3D.Library.Asset3DLibrary.loadData(assets.head, nil, nil, nil)
    Away3D.Library.Asset3DLibrary.loadData(assets.R2D2, nil, nil, nil)
end

function onResize()
    view.width = stage.stageWidth
    view.height = stage.stageHeight
    spriteNavigation.x = 20
    spriteNavigation.y = stage.stageHeight - spriteNavigation.height - 20
end

function initListeners()
    view.setRenderCallback(function(rect)
        if move then
            cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle
            cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle
        end

        if r2d2 ~= nil then
            --drag
            _speed = _speed * DRAG

            --acceleration
            _speed = _speed + _acceleration

            --speed bounds
            if _speed > MAX_SPEED then
                _speed = MAX_SPEED
            elseif _speed < -MAX_SPEED then
                _speed = -MAX_SPEED
            end

            --rotational drag
            _rotationSpeed = _rotationSpeed * DRAG

            --rotational acceleration
            _rotationSpeed = _rotationSpeed + _rotationAccel

            --rotational speed bounds
            if _rotationSpeed > MAX_ROTATION_SPEED then
                _rotationSpeed = MAX_ROTATION_SPEED
            elseif _rotationSpeed < -MAX_ROTATION_SPEED then
                _rotationSpeed = -MAX_ROTATION_SPEED
            end

            --apply motion to R2D2
            r2d2.moveForward(_speed)
            r2d2.rotationY = r2d2.rotationY + _rotationSpeed

            --keep R2D2 within max and min radius
            local radius = math.sqrt(r2d2.x*r2d2.x + r2d2.z*r2d2.z)
            if radius < 200 then
                r2d2.x = 200*r2d2.x/radius
                r2d2.z = 200*r2d2.z/radius
            elseif radius > 500 then
                r2d2.x = 500*r2d2.x/radius
                r2d2.z = 500*r2d2.z/radius
            end

            --pan angle overridden by R2D2 position
            cameraController.panAngle = 90 - 180 * math.atan2(r2d2.z, r2d2.x)/math.pi
        end

        -- render the view's scene to the reflection texture (view is required to use the correct stage3DProxy)
		reflectionTexture.render(view)
        view.render()
    end)

    stage.addEventListener(Events.MouseEvent.MOUSE_DOWN,
            function(e)
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
    stage.addEventListener(Events.MouseEvent.MOUSE_UP,
            function(e)
                _acceleration = 0
                _rotationAccel = 0

                move = false
            end, false, 0, false)
    stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
    stage.addEventListener(Events.KeyboardEvent.KEY_DOWN,
            function(event)
                if event.keyCode == Keyboard.W or event.keyCode == Keyboard.UP then
                    _acceleration = ACCELERATION
                elseif event.keyCode == Keyboard.S or event.keyCode == Keyboard.DOWN then
                    _acceleration = -ACCELERATION
                elseif event.keyCode == Keyboard.A or event.keyCode == Keyboard.LEFT then
                    _rotationAccel = -ROTATION
                elseif event.keyCode == Keyboard.D or event.keyCode == Keyboard.RIGHT then
                    _rotationAccel = ROTATION
                end
            end, false, 0, false)
    stage.addEventListener(Events.KeyboardEvent.KEY_UP,
            function(event)
                if event.keyCode == Keyboard.W or event.keyCode == Keyboard.S or
                   event.keyCode == Keyboard.UP or event.keyCode == Keyboard.DOWN then
                    _acceleration = 0
                elseif event.keyCode == Keyboard.A or event.keyCode == Keyboard.D or
                       event.keyCode == Keyboard.LEFT or event.keyCode == Keyboard.RIGHT then
                    _rotationAccel = 0
                end
            end, false, 0, false)
    onResize()
end

loadAssetsFromWebInThread()
initEngine()
initLights()
initReflectionCube()

function processModel()
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