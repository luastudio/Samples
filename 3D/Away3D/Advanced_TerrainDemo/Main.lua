--Main.lua (WARNING: require internet connection and good quality GPU)

--[[Based on:
Terrain creation using height maps and splat maps
Demonstrates:
How to create a 3D terrain out of a hieght map
How to enhance the detail of a material close-up by applying splat maps.
How to create a realistic lake effect.
How to create first-person camera motion using the FirstPersonController.
How to load assets from Web in thread
How to navigate using keyboard and touchscreen
Code by Rob Bateman & David Lenaerts
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
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

--Navigate instruction: Mouse click / Touch and drag - rotate. Cursor keys / WSAD / Screen arrows - move

Display = Lib.Media.Display
Events = Lib.Media.Events
Keyboard = Lib.Media.UI.Keyboard
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Mesh = Away3D.Entities.Mesh
Materials = Away3D.Materials
Primitives = Away3D.Primitives
Extrusions = Away3D.Extrusions
Lenses = Away3D.Cameras.Lenses
Textures = Away3D.Textures
FirstPersonController = Away3D.Controllers.FirstPersonController
DirectionalLight = Away3D.Lights.DirectionalLight
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Geom = Lib.Media.Geom
Sprite = Display.Sprite
stage = Display.stage
Thread = Lib.Sys.VM.Thread

move = false
lastPanAngle = 0
lastTiltAngle = 0
lastMouseX = 0
lastMouseY = 0
moveX = 0
moveY = 0

drag = 0.5
walkIncrement = 2
strafeIncrement = 2
walkSpeed = 0
strafeSpeed = 0
walkAcceleration = 0
strafeAcceleration = 0

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
    beach = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Advanced_TerrainDemo/assets/terrain/beach.jpg")),
    grass = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Advanced_TerrainDemo/assets/terrain/grass.jpg")),
    rock = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Advanced_TerrainDemo/assets/terrain/rock.jpg")),
    terrain_splats = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Advanced_TerrainDemo/assets/terrain/terrain_splats.png")),
    terrain_diffuse = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Advanced_TerrainDemo/assets/terrain/terrain_diffuse.jpg")),
    terrain_normals = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Advanced_TerrainDemo/assets/terrain/terrain_normals.jpg")),
    water_normals = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Advanced_TerrainDemo/assets/water_normals.jpg")),
    terrain_heights = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Advanced_TerrainDemo/assets/terrain/terrain_heights.jpg"))
})
]])
    t.sendMessage(Thread.current())
end

function initEngine()
    --setup the view
    view = View3D.new()
    scene = view.scene
    camera = view.camera

    camera.lens.far = 4000
    camera.lens.near = 1
    camera.y = 300

    --setup controller to be used on the camera
    cameraController = FirstPersonController.new(camera, 180, 0, -80, 80, 8, false)

    stage.addChild(view)

    -- stats
    stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

function initLights()
    sunLight = DirectionalLight.new(-300, -300, -5000)
    sunLight.color = 0xfffdc5
    sunLight.ambient = 1
    scene.addChild(sunLight)

    lightPicker = Materials.LightPickers.StaticLightPicker.new({sunLight})

    --create a global fog method
    fogMethod = Materials.Methods.FogMethod.new(0, 8000, 0xcfd9de)
end

function initMaterials()
    cubeTexture = Textures.BitmapCubeTexture.new(
            Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_positive_x.jpg"), -- left
            Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_negative_x.jpg"), -- right
            Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_positive_y.jpg"), -- top
            Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_negative_y.jpg"), -- bottom
            Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_positive_z.jpg"), -- back
            Cast.bitmapData("/3D/Away3D/Common/assets/skybox/snow_negative_z.jpg")  -- front
    )

    terrainMethod = Materials.Methods.TerrainDiffuseMethod.new(
            {assets.beach, assets.grass, assets.rock}, assets.terrain_splats,
            {1, 50, 150, 100})

    terrainMaterial = Materials.TextureMaterial.new(assets.terrain_diffuse, true, false, true, nil)
    terrainMaterial.diffuseMethod = terrainMethod
    terrainMaterial.normalMap = assets.terrain_normals
    terrainMaterial.lightPicker = lightPicker
    terrainMaterial.ambientColor = 0x303040
    terrainMaterial.ambient = 1
    terrainMaterial.specular = .2
    terrainMaterial.addMethod(fogMethod)

    local waveMap = assets.water_normals
    waterMethod = Materials.Methods.SimpleWaterNormalMethod.new(waveMap, waveMap)
    fresnelMethod = Materials.Methods.FresnelSpecularMethod.new(true, nil)
    fresnelMethod.normalReflectance = .3

    waterMaterial = Materials.TextureMaterial.new(
            Textures.BitmapTexture.new(Display.BitmapData.new(512, 512, true, 0xaa404070, -1 ), true),
            true, false, true, nil)
    waterMaterial.alphaBlending = true
    waterMaterial.lightPicker = lightPicker
    waterMaterial['repeat'] = true
    waterMaterial.normalMethod = waterMethod
    waterMaterial.addMethod(Materials.Methods.EnvMapMethod.new(cubeTexture, 1))
    waterMaterial.specularMethod = fresnelMethod
    waterMaterial.gloss = 100
    waterMaterial.specular = 1
end

function initObjects()
    --create skybox.
    scene.addChild(Primitives.SkyBox.new(cubeTexture))

    --create mountain like terrain
    terrain = Extrusions.Elevation.new(terrainMaterial,
            assets.terrain_heights,
            5000, 1300, 5000, 250, 250, 255, nil, false)
    scene.addChild(terrain)

    --create water
    plane = Mesh.new(Primitives.PlaneGeometry.new(5000, 5000, 1, 1, true, false), waterMaterial)
    plane.geometry.scaleUV(50, 50)
    plane.y = 285
    scene.addChild(plane)
end

function initListeners()
    view.setRenderCallback(function(rect)
        --set the camera height based on the terrain (with smoothing)
        camera.y = camera.y + 0.2*(terrain.getHeightAt(camera.x, camera.z) + 20 - camera.y)

        if move then 
            cameraController.panAngle = 0.3*(moveX - lastMouseX) + lastPanAngle
            cameraController.tiltAngle = 0.3*(moveY - lastMouseY) + lastTiltAngle
        end

        if walkSpeed ~= 0 or walkAcceleration ~= 0 then
            walkSpeed = (walkSpeed + walkAcceleration)*drag
            if math.abs(walkSpeed) < 0.01 then
                walkSpeed = 0
            end
            cameraController.incrementWalk(walkSpeed)
        end

        if strafeSpeed ~= 0 or strafeAcceleration ~= 0 then
            strafeSpeed = (strafeSpeed + strafeAcceleration)*drag
            if math.abs(strafeSpeed) < 0.01 then
                strafeSpeed = 0
            end
            cameraController.incrementStrafe(strafeSpeed);
        end

        --animate our lake material
        waterMethod.water1OffsetX = waterMethod.water1OffsetX + .005
        waterMethod.water1OffsetY = waterMethod.water1OffsetY + .007
        waterMethod.water2OffsetX = waterMethod.water2OffsetX + .003
        waterMethod.water2OffsetY = waterMethod.water2OffsetY + .004

        view.render()
    end)

    if Lib.Media.UI.Multitouch.supportsTouchEvents then
      primaryTouch = nil
      stage.addEventListener(Events.TouchEvent.TOUCH_BEGIN, function(e)      
        if e.target.name == "up" then
            walkAcceleration = walkIncrement
        elseif e.target.name == "down" then
            walkAcceleration = -walkIncrement
        elseif e.target.name == "left" then
            strafeAcceleration = -strafeIncrement
        elseif e.target.name == "right" then
            strafeAcceleration = strafeIncrement
        elseif primaryTouch == nil then
            primaryTouch = e.touchPointID
            move = true  
            lastPanAngle = cameraController.panAngle
            lastTiltAngle = cameraController.tiltAngle
            lastMouseX = e.stageX
            lastMouseY = e.stageY
            moveX = lastMouseX
            moveY = lastMouseY
        end
      end, false, 0, false)

      stage.addEventListener(Events.TouchEvent.TOUCH_MOVE, function(e) 
        if e.touchPointID == primaryTouch then 
          moveX = e.stageX
          moveY = e.stageY
        end
      end, false, 0, false)

      stage.addEventListener(Events.TouchEvent.TOUCH_END, function(e)        
        if e.touchPointID == primaryTouch then 
           move = false 
           primaryTouch = nil
        else
          if e.target.name == "up" or e.target.name == "down" then
            walkAcceleration = 0
          elseif e.target.name == "left" or e.target.name == "right" then
            strafeAcceleration = 0
          else
            walkAcceleration = 0
            strafeAcceleration = 0
          end
        end
      end, false, 0, false)
    else
      stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
        if e.target.name == "up" then
            walkAcceleration = walkIncrement
        elseif e.target.name == "down" then
            walkAcceleration = -walkIncrement
        elseif e.target.name == "left" then
            strafeAcceleration = -strafeIncrement
        elseif e.target.name == "right" then
            strafeAcceleration = strafeIncrement
        else
            move = true  
            lastPanAngle = cameraController.panAngle
            lastTiltAngle = cameraController.tiltAngle
            lastMouseX = e.stageX
            lastMouseY = e.stageY
            moveX = lastMouseX
            moveY = lastMouseY
        end
      end, false, 0, false)

      stage.addEventListener(Events.MouseEvent.MOUSE_MOVE, function(e)
        if move then
          moveX = e.stageX
          moveY = e.stageY
        end
      end, false, 0, false)

      stage.addEventListener(Events.MouseEvent.MOUSE_UP, function(e)
        if e.target.name == "up" or e.target.name == "down" then
            walkAcceleration = 0
        elseif e.target.name == "left" or e.target.name == "right" then
            strafeAcceleration = 0
        else
            walkAcceleration = 0
            strafeAcceleration = 0
        end
        move = false 
      end, false, 0, false)
    end

    stage.addEventListener(Events.KeyboardEvent.KEY_DOWN, function(event)
        if event.keyCode == Keyboard.UP or event.keyCode == Keyboard.W then
            walkAcceleration = walkIncrement
        elseif event.keyCode == Keyboard.DOWN or event.keyCode == Keyboard.S then
            walkAcceleration = -walkIncrement
        elseif event.keyCode == Keyboard.LEFT or event.keyCode == Keyboard.A then
            strafeAcceleration = -strafeIncrement
        elseif event.keyCode == Keyboard.RIGHT or event.keyCode == Keyboard.D then
            strafeAcceleration = strafeIncrement
        end
    end, false, 0, false)

    stage.addEventListener(Events.KeyboardEvent.KEY_UP, function(event)
        if event.keyCode == Keyboard.UP or event.keyCode == Keyboard.W or
                event.keyCode == Keyboard.DOWN or event.keyCode == Keyboard.S then
            walkAcceleration = 0
        elseif event.keyCode == Keyboard.LEFT or event.keyCode == Keyboard.A or
                event.keyCode == Keyboard.RIGHT or event.keyCode == Keyboard.D then
            strafeAcceleration = 0
        end
    end, false, 0, false)

    local onResize = function(e)
        view.width = stage.stageWidth
        view.height = stage.stageHeight
        spriteNavigation.x = 20
        spriteNavigation.y = stage.stageHeight - spriteNavigation.height - 20
    end

    stage.addEventListener(Events.RESIZE, onResize, false, 0, false)
    onResize()
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

loadAssetsFromWebInThread()
initEngine()
initLights()

function frameEvent(e)
    assets = Thread.readMessage(false)
    if assets ~= nil then
        Lib.Media.Display.stage.removeEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false)
        initMaterials()
        initObjects()
        initNavigation()
        initListeners()
    end
end

--wait for thread to finish
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false, 0, false)
