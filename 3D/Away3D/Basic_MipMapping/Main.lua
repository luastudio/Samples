-- Main.lua

--[[Based on:

3D Mip-mapping example in Away3d

Demonstrates:

How to enable/disable mip-mapping and the effect on textures

Code by Greg Caldwell
greg@geepers.co.uk
http://www.geepers.co.uk
http://www.geepersinteractive.co.uk

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
Mesh = Away3D.Entities.Mesh
Debug = Away3D.Debug
TextureMaterial = Away3D.Materials.TextureMaterial
BitmapTexture = Away3D.Textures.BitmapTexture
PlaneGeometry = Away3D.Primitives.PlaneGeometry
Cast = Away3D.Utils.Cast
Geom = Lib.Media.Geom
Text = Lib.Media.Text
stage = Display.stage

_lastTimer = Lib.Sys.getTime()
_state = "NO_MIPMAPPING"

--setup the view
_view = View3D.new()
stage.addChild(_view)

_view.camera.z = 0
_view.camera.y = 25
_view.camera.lookAt(Geom.Vector3D.new(0, -500, 2000, 0), nil)

_planeTex = BitmapTexture.new(Display.BitmapData.loadFromBytes(Lib.Project.getBytes("/3D/Away3D/Common/assets/floor/floor_diffuse.jpg"), nil), true)

_planeMat = TextureMaterial.new(_planeTex, true, false, true, nil)
_planeMat['repeat'] = true
_planeMat.mipmap = false
_planeMat.anisotropy = Away3D.Textures.Anisotropy.NONE

_planeGeom = PlaneGeometry.new(20000, 20000, 1, 1, true, false)
_planeGeom.scaleUV(150, 150)

_plane = Mesh.new(_planeGeom, _planeMat)
_view.scene.addChild(_plane)

_view.setRenderCallback(function(e)
	local delta = Lib.Sys.getTime() - _lastTimer
	_plane.rotationY = _plane.rotationY + delta / 50
		
	_lastTimer = Lib.Sys.getTime()
		
	_view.render()
end)

onResize = function(e)
	_view.width = stage.stageWidth
	_view.height = stage.stageHeight
end
stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
onResize()

stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))

clickText = Text.TextField.new()
clickText.x = 300
clickText.y = 50
clickText.defaultTextFormat = Text.TextFormat.new("_sans", 32, 0xffffff, nil, nil, nil)
clickText.width = stage.stageWidth - 200
clickText.text = "Click anywhere to change"
stage.addChild(clickText)

_text = Text.TextField.new()
_text.x = 300
_text.y = 100
_text.defaultTextFormat = Text.TextFormat.new("_sans", 24, 0x2222ff, nil, nil, nil)
_text.width = stage.stageWidth - 200
_text.text = "No Mip-mapping"
stage.addChild(_text)

stage.addEventListener( Events.MouseEvent.CLICK, function(e)
	if _state == "NO_MIPMAPPING" then
		_state = "MIPMAPPING"
		_planeMat.mipmap = true
		_planeMat.anisotropy = Away3D.Textures.Anisotropy.NONE
		_text.text = "Mip-mapping with no anisotropic filtering"
	elseif _state == "MIPMAPPING" then
		_state = "MIPMAPPING_WITH_ANISOTROPIC_2"
		_planeMat.mipmap = true
		_planeMat.anisotropy = Away3D.Textures.Anisotropy.ANISOTROPIC2X
		_text.text = "Mip-mapping with 2X anisotropic filtering"
	elseif _state == "MIPMAPPING_WITH_ANISOTROPIC_2" then
		_state = "MIPMAPPING_WITH_ANISOTROPIC_4"
		_planeMat.mipmap = true
		_planeMat.anisotropy = Away3D.Textures.Anisotropy.ANISOTROPIC4X
		_text.text = "Mip-mapping with 4X anisotropic filtering"
	elseif _state == "MIPMAPPING_WITH_ANISOTROPIC_4" then
		_state = "MIPMAPPING_WITH_ANISOTROPIC_8"
		_planeMat.mipmap = true
		_planeMat.anisotropy = Away3D.Textures.Anisotropy.ANISOTROPIC8X
		_text.text = "Mip-mapping with 8X anisotropic filtering"
	elseif _state == "MIPMAPPING_WITH_ANISOTROPIC_8" then
		_state = "MIPMAPPING_WITH_ANISOTROPIC_16"
		_planeMat.mipmap = true
		_planeMat.anisotropy = Away3D.Textures.Anisotropy.ANISOTROPIC16X
		_text.text = "Mip-mapping with 16X anisotropic filtering"
	elseif _state == "MIPMAPPING_WITH_ANISOTROPIC_16" then
		_state = "NO_MIPMAPPING"
		_planeMat.mipmap = false
		_planeMat.anisotropy = Away3D.Textures.Anisotropy.NONE
		_text.text = "No Mip-mapping"
	end
end, false, 0, false)