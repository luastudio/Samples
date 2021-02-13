--Main.lua
Away3D = Lib.Away3D
Stereo = Away3D.Stereo
Mesh = Away3D.Entities.Mesh
Materials = Away3D.Materials
Primitives = Away3D.Primitives
Display = Lib.Media.Display
Events = Lib.Media.Events
stage = Display.stage

_camera = Stereo.StereoCamera3D.new(nil)
_camera.stereoOffset = 50

_view = Stereo.StereoView3D.new(nil, nil, nil, nil)
_view.antiAlias = 4
_view.camera = _camera
_view.stereoEnabled = true
_view.stereoRenderMethod = Stereo.Methods.AnaglyphStereoRenderMethod.new()
--_view.stereoRenderMethod = Stereo.Methods.SBSStereoRenderMethod.new()
--_view.stereoRenderMethod = Stereo.Methods.InterleavedStereoRenderMethod.new()
stage.addChild(_view)

_cube = Mesh.new(Primitives.CubeGeometry.new(100, 100, 100, 1, 1, 1, true), Materials.ColorMaterial.new( 0xffcc00, 1 ))
_cube.scale(5)
_view.scene.addChild(_cube)

_view.setRenderCallback(function(rect)
    _cube.rotationY = _cube.rotationY + 2
    _view.render()
end)

onResize = function(e)
        _view.width = stage.stageWidth
        _view.height = stage.stageHeight
end

stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
onResize()