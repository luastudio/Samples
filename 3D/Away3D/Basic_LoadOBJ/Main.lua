-- Main.lua

--[[
Demonstrates:

How to use the Asset3DLibrary with AssetLoaderContext to load OBJ model and MTL file.
How to map an external assets reference inside a file to an asset.
How to make texture from SVG file and replace it dynamically
]]--

-- declarations
Display = Lib.Media.Display
Events = Lib.Media.Events
Away3D = Lib.Away3D
View3D = Away3D.Containers.View3D
HoverController = Away3D.Controllers.HoverController
Cast = Away3D.Utils.Cast
stage = Display.stage


--setup the view
_view = View3D.new()
_view.backgroundColor = 0x4e6a54
_scene = _view.scene
stage.addChild(_view)

--setup controller to be used on the camera
_cameraController = HoverController.new(_view.camera, nil, 45, 10, 300, 10, 90, nil, nil, 8,  2, false)

--setup the url map for MTL file and textures in  this file
assetLoaderContext = Away3D.Loaders.Misc.AssetLoaderContext.new(true, nil)
assetLoaderContext.mapUrlToData("cube.mtl", Lib.Project.getText("/3D/Away3D/Basic_LoadOBJ/assets/cube.mtl"))
assetLoaderContext.mapUrlToData("cube.png", Cast.bitmapData(Lib.Project.getBytes("/3D/Away3D/Intermediate_ParticleTrails/assets/cards_suit.png")))

_model = nil
_material = nil

Away3D.Library.Asset3DLibrary.addEventListener(Away3D.Events.Asset3DEvent.ASSET_COMPLETE, function(event)
	if event.asset.assetType == Away3D.Library.Assets.Asset3DType.MESH then
    	_model = event.asset
        _material = _model.material
        _model.geometry.scale(150)
        
        _scene.addChild(_model)
    end
end, false, nil, false)
Away3D.Library.Asset3DLibrary.loadData(Lib.Project.getBytes("/3D/Away3D/Basic_LoadOBJ/assets/cube.obj"), assetLoaderContext, nil, nil)

--navigation variables
_move = false
_lastPanAngle = 0.0
_lastTiltAngle = 0.0
_lastMouseX = 0.0
_lastMouseY = 0.0

_view.setRenderCallback(function(rect)
	if _move then
    	_cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle
        _cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle
    end

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

--SVG

require("/SVGLite/SVGLite.lua")

svg = SVGLite.new()

--https://www.flaticon.com/free-icon/coffee_187455
--Icon made by Pixel perfect from www.flaticon.com
local dom = svg.parseProjectFile("/SVGLite/coffee_187455.svg")

sprite = Display.Sprite.new()
scale = 256 / dom.viewBox.width
svg.render(dom, sprite.graphics, Lib.Media.Geom.Matrix.new(scale,0,0,scale,0,0))

bdt = Display.BitmapData.new(256, 256, false, 0, Lib.Media.Image.PixelFormat.pfNone)
bdt.draw(sprite, nil, nil, Lib.Media.Display.BlendMode.NORMAL, nil, true)

texture = Cast.bitmapTexture(bdt)
newMaterial = Away3D.Materials.TextureMaterial.new(texture, true, false, true, nil)

require("/Common/Switch.lua")
switch = Switch.new("from SVG", 0xFFFF00, 100, 50, false, function(status)
	if(status)then
		_model.material = newMaterial
    else
		_model.material = _material
    end
    _view.render()
end)
local switchSprite = switch.getSprite()
switchSprite.x = 10
switchSprite.y = 10
stage.addChild(switchSprite)