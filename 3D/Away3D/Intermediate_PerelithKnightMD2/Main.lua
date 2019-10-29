--Main.lua (WARNING: require internet connection)

--[[Based on:

Vertex animation example in Away3d using the MD2 format

Demonstrates:

How to use the AssetLibrary object to load an embedded internal md2 model.
How to clone an asset from the AssetLibrary and apply different mateirals.
How to load animations into an animation set and apply to individual meshes.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

Perelith Knight, by James Green (no email given)

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

--http://tfc.duke.free.fr/old/models/md2.htm
--http://tfc.duke.free.fr/coding/md2-specs-en.html

Display = Lib.Media.Display
Sprite = Display.Sprite
Events = Lib.Media.Events
Geom = Lib.Media.Geom
Keyboard = Lib.Media.UI.Keyboard
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
Materials = Away3D.Materials
Animators = Away3D.Animators
Asset3DLibrary = Away3D.Library.Asset3DLibrary
Cast = Away3D.Utils.Cast
Primitives = Away3D.Primitives
HoverController = Away3D.Controllers.HoverController
DirectionalLight = Away3D.Lights.DirectionalLight
Mesh = Away3D.Entities.Mesh
Debug = Away3D.Debug
stage = Display.stage
Thread = Lib.Sys.VM.Thread

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
    pknight = Assets.Web.getBytes("/3D/Away3D/Intermediate_PerelithKnightMD2/assets/pknight/pknight.md2"),
    floor_diffuse = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_PerelithKnightMD2/assets/floor_diffuse.jpg")),
    pknight1 = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_PerelithKnightMD2/assets/pknight/pknight1.png")),
    pknight2 = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_PerelithKnightMD2/assets/pknight/pknight2.png")),
    pknight3 = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_PerelithKnightMD2/assets/pknight/pknight3.png")),
    pknight4 = Cast.bitmapTexture(Assets.Web.getBytes("/3D/Away3D/Intermediate_PerelithKnightMD2/assets/pknight/pknight4.png"))
})
]])
    t.sendMessage(Thread.current())
end

--navigation variables
_move = false --Bool
_lastPanAngle = 0.0 --Float
_lastTiltAngle = 0.0 --Float
_lastMouseX = 0.0 --Float
_moveX = 0.0 --Float
_moveY = 0.0 --Float
_lastMouseY = 0.0 --Float
_keyUp = false --Bool
_keyDown = false --Bool
_keyLeft = false --Bool
_keyRight = false --Bool
_lookAtPosition = Geom.Vector3D.new(0, 0, 0, 0)
_animationSet = {} --VertexAnimationSet

_view = View3D.new()
stage.addChild(_view)

--setup the camera for optimal rendering
_view.camera.lens.far = 5000

--setup controller to be used on the camera
_cameraController = HoverController.new(_view.camera, nil, 45, 20, 2000, 5, 90, nil, nil, 8,  2, false)

--setup the lights for the scene
_light = DirectionalLight.new(-0.5, -1, -1)
_light.ambient = 0.4
_lightPicker = Materials.LightPickers.StaticLightPicker.new({_light})
_view.scene.addChild(_light)

loadAssetsFromWebInThread()

function processModel()
    --setup parser to be used on AssetLibrary
    PKnightModel = assets.pknight

    Asset3DLibrary.loadData(PKnightModel, nil, nil, Away3D.Loaders.Parsers.MD2Parser.new("jpg", true))
    --Listener function for asset complete event on loader
    Asset3DLibrary.addEventListener(Away3D.Events.Asset3DEvent.ASSET_COMPLETE, function(event)
        if event.asset.assetType == Away3D.Library.Assets.Asset3DType.MESH then
            _mesh = event.asset

            --adjust the ogre mesh
            _mesh.y = 120
            _mesh.scale(5)
        elseif event.asset.assetType == Away3D.Library.Assets.Asset3DType.ANIMATION_SET then
            _animationSet = event.asset
        end
    end , false, 0, false)
    --Listener function for resource complete event on loader
    Asset3DLibrary.addEventListener(Away3D.Events.LoaderEvent.RESOURCE_COMPLETE, function(e)
        --create 20 x 20 different clones of the ogre
        local numWide = 20 --Int
        local numDeep = 20 --Int
        local k = 0 --Int
        for i=0, numWide - 1, 1 do
            for j=0, numDeep - 1, 1 do
                --clone mesh
                local clone = _mesh.clone()
                clone.x = (i-(numWide-1)/2)*5000/numWide
                clone.z = (j-(numDeep-1)/2)*5000/numDeep
                --clone.castsShadows = true; not supported
                clone.material = _pKnightMaterials[math.floor(math.random()*#_pKnightMaterials)]
                _view.scene.addChild(clone)

                --create animator
                local vertexAnimator = Animators.VertexAnimator.new(_animationSet)

                --play specified state
                vertexAnimator.play(_animationSet.animationNames[math.floor(math.random()*#_animationSet.animationNames)], nil, math.floor(math.random()*1000))
                clone.animator = vertexAnimator
                k = k + 1
            end
        end
    end , false, 0, false)

    --create a global shadow map method
    --_shadowMapMethod = FilteredShadowMapMethod.new(_light) not supported

    --setup floor material
    _floorMaterial = Materials.TextureMaterial.new(assets.floor_diffuse, true, false, true, nil)
    _floorMaterial.lightPicker = _lightPicker
    _floorMaterial.specular = 0
    _floorMaterial.ambient = 1
    --_floorMaterial.shadowMethod = _shadowMapMethod
    _floorMaterial['repeat'] = true

    _pKnightMaterials = {}

    for i=1, 4, 1 do
        local knightMaterial = Materials.TextureMaterial.new(assets["pknight"..i], true, false, true, nil)
        --knightMaterial.normalMap = Cast.bitmapTexture(BitmapFilterEffects.normalMap(bitmapData))
        --knightMaterial.specularMap = Cast.bitmapTexture(BitmapFilterEffects.outline(bitmapData))
        knightMaterial.lightPicker = _lightPicker
        knightMaterial.gloss = 30
        knightMaterial.specular = 1
        knightMaterial.ambient = 1
        --knightMaterial.shadowMethod = _shadowMapMethod
        _pKnightMaterials[i] = knightMaterial
    end

    --setup the floor
    _floor = Mesh.new(Primitives.PlaneGeometry.new(5000, 5000, 1, 1, true, false), _floorMaterial)
    _floor.geometry.scaleUV(5, 5)

    --setup the scene
    _view.scene.addChild(_floor)

    stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))

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

    --add listeners
    _view.setRenderCallback(function(rect)
        if _move then
            _cameraController.panAngle = 0.3*(_moveX - _lastMouseX) + _lastPanAngle
            _cameraController.tiltAngle = 0.3*(_moveY - _lastMouseY) + _lastTiltAngle
        end

        if _keyUp then
            _lookAtPosition.x = _lookAtPosition.x - 10
        end
        if _keyDown then
            _lookAtPosition.x = _lookAtPosition.x + 10
        end
        if _keyLeft then
            _lookAtPosition.z = _lookAtPosition.z - 10
        end
        if _keyRight then
            _lookAtPosition.z = _lookAtPosition.z + 10
        end

        _cameraController.lookAtPosition = _lookAtPosition

        _view.render()
    end)

    stage.addEventListener(Events.KeyboardEvent.KEY_UP, function(event)
        if event.keyCode == Keyboard.UP or event.keyCode == Keyboard.W or event.keyCode == Keyboard.Z then
            _keyUp = false
        elseif event.keyCode == Keyboard.DOWN or event.keyCode == Keyboard.S then
            _keyDown = false
        elseif event.keyCode == Keyboard.LEFT or event.keyCode == Keyboard.A or event.keyCode == Keyboard.Q then
            _keyLeft = false
        elseif event.keyCode == Keyboard.RIGHT or event.keyCode == Keyboard.D then
            _keyRight = false
        end
    end, false, 0, false)
    stage.addEventListener(Events.KeyboardEvent.KEY_DOWN, function(event)
        if event.keyCode == Keyboard.UP or event.keyCode == Keyboard.W or event.keyCode == Keyboard.Z then
            _keyUp = true
        elseif event.keyCode == Keyboard.DOWN or event.keyCode == Keyboard.S then
            _keyDown = true
        elseif event.keyCode == Keyboard.LEFT or event.keyCode == Keyboard.A or event.keyCode == Keyboard.Q then
            _keyLeft = true
        elseif event.keyCode == Keyboard.RIGHT or event.keyCode == Keyboard.D then
            _keyRight = true
        end
    end, false, 0, false)

    if Lib.Media.UI.Multitouch.supportsTouchEvents then
        primaryTouch = nil
        stage.addEventListener(Events.TouchEvent.TOUCH_BEGIN, function(e)
            if e.target.name == "up" then
                _keyUp = true
            elseif e.target.name == "down" then
                _keyDown = true
            elseif e.target.name == "left" then
                _keyLeft = true
            elseif e.target.name == "right" then
                _keyRight = true
            elseif primaryTouch == nil then
                primaryTouch = e.touchPointID
                _lastPanAngle = _cameraController.panAngle
                _lastTiltAngle = _cameraController.tiltAngle
                _lastMouseX = e.stageX
                _lastMouseY = e.stageY
                _moveX = _lastMouseX
                _moveY = _lastMouseY
                _move = true
            end
        end, false, 0, false)

        stage.addEventListener(Events.TouchEvent.TOUCH_MOVE, function(e) 
            if e.touchPointID == primaryTouch then 
              _moveX = e.stageX
              _moveY = e.stageY
             end
        end, false, 0, false)

        stage.addEventListener(Events.TouchEvent.TOUCH_END, function(e)
            if e.touchPointID == primaryTouch then
                _move = false
                primaryTouch = nil
            else
                --if e.target.name == "up" then
                _keyUp = false
                --elseif e.target.name == "down" then
                _keyDown = false
                --elseif e.target.name == "left" then
                _keyLeft = false
                --elseif e.target.name == "right" then
                _keyRight = false
                --end
            end
        end, false, 0, false)
    else
        stage.addEventListener(Events.MouseEvent.MOUSE_DOWN, function(e)
            if e.target.name == "up" then
                _keyUp = true
            elseif e.target.name == "down" then
                _keyDown = true
            elseif e.target.name == "left" then
                _keyLeft = true
            elseif e.target.name == "right" then
                _keyRight = true
            else
                _lastPanAngle = _cameraController.panAngle
                _lastTiltAngle = _cameraController.tiltAngle
                _lastMouseX = e.stageX
                _lastMouseY = e.stageY
                _moveX = _lastMouseX
                _moveY = _lastMouseY
                _move = true
            end
        end, false, 0, false)

        stage.addEventListener(Events.MouseEvent.MOUSE_MOVE, function(e)
            if _move then
              _moveX = e.stageX
              _moveY = e.stageY
            end
         end, false, 0, false)

        stage.addEventListener(Events.MouseEvent.MOUSE_UP, function(e)
            --if e.target.name == "up" then
            _keyUp = false
            --elseif e.target.name == "down" then
            _keyDown = false
            --elseif e.target.name == "left" then
            _keyLeft = false
            --elseif e.target.name == "right" then
            _keyRight = false
            --end
            _move = false
        end, false, 0, false)

        stage.addEventListener(Events.MouseEvent.MOUSE_WHEEL, function(event)
            _cameraController.distance = _cameraController.distance - event.delta * 5

            if _cameraController.distance < 100 then
                _cameraController.distance = 100
            elseif _cameraController.distance > 2000 then
                _cameraController.distance = 2000
            end
        end, false, 0, false)
    end

    local onResize = function(e)
        _view.width = stage.stageWidth
        _view.height = stage.stageHeight
        spriteNavigation.x = 20
        spriteNavigation.y = stage.stageHeight - spriteNavigation.height - 20
    end
    stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)

    initNavigation()
    onResize()
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
