-- Main.lua

--[[
Demonstrates:

How to use the Asset3DLibrary with AssetLoaderContext to load OBJ model and MTL file.
How to map an external assets reference inside a file to an asset.
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

Away3D.Library.Asset3DLibrary.addEventListener(Away3D.Events.Asset3DEvent.ASSET_COMPLETE, function(event)
	if event.asset.assetType == Away3D.Library.Assets.Asset3DType.MESH then
    	local model = event.asset
        model.geometry.scale(150)
        --local material = model.material
        _scene.addChild(model)
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