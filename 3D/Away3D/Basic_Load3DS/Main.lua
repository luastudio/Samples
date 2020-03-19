--Main.lua (WARNING: require internet connection)

--[[Based on:

3ds file loading example in Away3d

Demonstrates:

How to use the Loader3D object to load 3ds model.
How to map an external asset reference inside a file to an asset.
How to extract material data and use it to set custom material properties on a model.

Code by Rob Bateman
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


-- declarations
Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Mesh = Away3D.Entities.Mesh
Materials = Away3D.Materials
TextureMaterial = Materials.TextureMaterial
PlaneGeometry = Away3D.Primitives.PlaneGeometry
DirectionalLight = Away3D.Lights.DirectionalLight
Textures = Away3D.Textures
HoverController = Away3D.Controllers.HoverController
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Geom = Lib.Media.Geom
stage = Display.stage
Thread = Lib.Sys.VM.Thread

--For mobile devices AGAL shader fragment precision set to medium by default.
--High value can slow down rendering speed on some devicess or may not support it at all. 
--This sample require high fragment precision. Option will be deprecated when most devices can work with high precision properly and we can change default value to high. 
Away3D.Config.OpenGL_ES.FRAGMENT_PRECISION_HIGH = true

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
    soldier_ant_3ds = Assets.Web.getBytes("/3D/Away3D/Basic_Load3DS/assets/soldier_ant.3ds"),
    CoarseRedSand_jpg = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Basic_Load3DS/assets/CoarseRedSand.jpg")),
    soldier_ant_jpg = Cast.bitmapData(Assets.Web.getBytes("/3D/Away3D/Basic_Load3DS/assets/soldier_ant.jpg"))
})
]])
    t.sendMessage(Thread.current())
end

function processModel()
    --navigation variables
    _move = false
    _lastPanAngle = 0.0
    _lastTiltAngle = 0.0
    _lastMouseX = 0.0
    _lastMouseY = 0.0

    --setup the view
    _view = View3D.new()
    stage.addChild(_view)

    --setup the camera for optimal shadow rendering
    _view.camera.lens.far = 2100

    --setup controller to be used on the camera
    _cameraController = HoverController.new(_view.camera, nil, 45, 20, 1000, 10, 90, nil, nil, 8,  2, false)

    --setup the lights for the scene
    _light = DirectionalLight.new(-1, -1, 1)
    --_light.shadowMapper = Away3D.Lights.ShadowMaps.NearDirectionalShadowMapper.new(.05)
    _direction = Geom.Vector3D.new(-1, -1, 1, 0)
    _lightPicker = Materials.LightPickers.StaticLightPicker.new({_light})
    _view.scene.addChild(_light)

    --setup the url map for textures in the 3ds file
    assetLoaderContext = Away3D.Loaders.Misc.AssetLoaderContext.new(true, nil)
    assetLoaderContext.mapUrlToData("texture.jpg", assets.soldier_ant_jpg)

    --setup materials
    _groundMaterial = TextureMaterial.new(assets.CoarseRedSand_jpg, true, false, true, nil)
    _groundMaterial.shadowMethod = Materials.Methods.FilteredShadowMapMethod.new(_light)
    --_groundMaterial.shadowMethod = Materials.Methods.SoftShadowMapMethod.new(_light, 2, 2)
    --_groundMaterial.shadowMethod = Materials.Methods.HardShadowMapMethod.new(_light)
    _groundMaterial.shadowMethod.epsilon = 0.1
    _groundMaterial.lightPicker = _lightPicker
    _groundMaterial.specular = 0
    _ground = Mesh.new(PlaneGeometry.new(1000, 1000, 1, 1, true, false), _groundMaterial)
    --_ground.scale(0.1)
    _view.scene.addChild(_ground)

    --setup the scene
    _loader = Away3D.Loaders.Loader3D.new(true, nil)
    _loader.scale(300)--25
    _loader.z = -200--15
    _loader.addEventListener(Away3D.Events.Asset3DEvent.ASSET_COMPLETE, function(event)
        if event.asset.assetType == Away3D.Library.Assets.Asset3DType.MESH then
            local mesh = event.asset
            mesh.castsShadows = true
        elseif event.asset.assetType == Away3D.Library.Assets.Asset3DType.MATERIAL then
            local material = event.asset
            material.shadowMethod = Materials.Methods.FilteredShadowMapMethod.new(_light)
            material.lightPicker = _lightPicker
            material.gloss = 30
            material.specular = 1
            material.ambientColor = 0x303040
            material.ambient = 1
        end
    end,  false, 0, false)
    _loader.loadData(assets.soldier_ant_3ds,
            assetLoaderContext, nil, Away3D.Loaders.Parsers.Max3DSParser.new(false))
    _view.scene.addChild(_loader)

    -- stats
    stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))

    _view.setRenderCallback(function(rect)
        if _move then
            _cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle
            _cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle
        end

        _direction.x = -math.sin(Lib.Sys.getTime()/4000)
        _direction.z = -math.cos(Lib.Sys.getTime()/4000)
        _light.direction = _direction

        _view.render()
    end)

    function onResize()
        _view.width = stage.stageWidth
        _view.height = stage.stageHeight
    end

    stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
        _lastPanAngle = _cameraController.panAngle
        _lastTiltAngle = _cameraController.tiltAngle
        _lastMouseX = stage.mouseX
        _lastMouseY = stage.mouseY
        _move = true
    end ,  false, 0, false)
    stage.addEventListener(Events.MouseEvent.MOUSE_UP, function(e)
        _move = false
    end ,  false, 0, false)
    stage.addEventListener(Events.Event.RESIZE, onResize,  false, 0, false)
    onResize()
end

function frameEvent(e)
    assets = Thread.readMessage(false)
    if assets ~= nil then
        Lib.Media.Display.stage.removeEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false)

        processModel()
    end
end

loadAssetsFromWebInThread()
--wait for thread to finish
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameEvent, false, 0, false)