-- Main.lua

--[[Based on:

Basic View example in Away3d

Demonstrates:

How to create a 3D environment for your objects
How to add a new textured object to your world
How to rotate an object in your world

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

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
PlaneGeometry = Away3D.Primitives.PlaneGeometry
Cast = Away3D.Utils.Cast
Geom = Lib.Media.Geom
stage = Display.stage

--setup the view
_view = View3D.new()
stage.addChild(_view)

--setup the camera
_view.camera.z = -600
_view.camera.y = 200
_view.camera.lookAt(Geom.Vector3D.new(0, 0, 0, 0), nil)

--setup the scene
_plane = Mesh.new(
	PlaneGeometry.new(700, 700, 1, 1, true, false),
	TextureMaterial.new(
		Cast.bitmapTexture("/3D/Away3D/Common/assets/floor/floor_diffuse.jpg"), true, false, true, nil))
_view.scene.addChild(_plane)
		
--setup the render loop
_view.setRenderCallback(function(e)
	_plane.rotationY = _plane.rotationY + 1

	_view.render()
end)
		
function onResize(e)
	_view.width = stage.stageWidth
	_view.height = stage.stageHeight
end

stage.addEventListener(Events.Event.RESIZE, onResize, false, 0, false)
onResize(nil)

--stats
stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xFFFFFF, 3))