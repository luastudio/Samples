-- Main.lua

--[[Based on:

Terrain Lines in Away3D

Demonstrates:

Using the SegementSet and LineSegments this demo modifies the position of segments to match 
a simplex noise generated terrain which continually scrolls to give the effect of moving 
over the terrain. Three wire frame sphere are positioned and rotated to give
the appearance that they are rolling across the scrolling surface. 

Code by Greg Caldwell
greg.caldwell@geepersinteractive.co.uk
http://www.geepers.co.uk
http://www.geepersinteractive.co.uk

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
Scene3D = Away3D.Containers.Scene3D
Mesh = Away3D.Entities.Mesh
SegmentSet = Away3D.Entities.SegmentSet
Materials = Away3D.Materials
Primitives = Away3D.Primitives
Animators = Away3D.Animators
Camera3D = Away3D.Cameras.Camera3D
Lenses = Away3D.Cameras.Lenses
PointLight = Away3D.Lights.PointLight
Textures = Away3D.Textures
ObjectContainer3D = Away3D.Containers.ObjectContainer3D
HoverController = Away3D.Controllers.HoverController
Helpers = Away3D.Tools.Helpers
Cast = Away3D.Utils.Cast
Debug = Away3D.Debug
Geom = Lib.Media.Geom
stage = Display.stage

if type(jit) == 'table' then
    bit32 = bit
end

sysName = Lib.Media.System.systemName()
desktop = true
if sysName == "android" or sysName == "ios" then
	desktop = false
end

Simplex = {

    -- The gradients are the midpoints of the vertices of a cube.
    grad3 = {
        { 1, 1, 0 }, { -1, 1, 0 }, { 1, -1, 0 }, { -1, -1, 0 },
        { 1, 0, 1 }, { -1, 0, 1 }, { 1, 0, -1 }, { -1, 0, -1 },
        { 0, 1, 1 }, { 0, -1, 1 }, { 0, 1, -1 }, { 0, -1, -1 }
    },

    -- Permutation table.  The same list is repeated twice.
    perm = {
        151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142,
        8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117,
        35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71,
        134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41,
        55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89,
        18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226,
        250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182,
        189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
        172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97,
        228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239,
        107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
        138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180,

        151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142,
        8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117,
        35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71,
        134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41,
        55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89,
        18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226,
        250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182,
        189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
        172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97,
        228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239,
        107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254,
        138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
    },

    --octaves = 4, persistence = 0.5, scale = 1
    noise2D = function(x, y, octaves, persistence, scale)
        local total = 0.0
        local frequency = scale
        local amplitude = 1.0

        -- We have to keep track of the largest possible amplitude,
        -- because each octave adds more, and we need a value in [-1, 1].
        local maxAmplitude = 0.0

        for i = 0, octaves - 1, 1 do
            total = total + Simplex.raw_noise_2d(x * frequency, y * frequency) * amplitude

            frequency = frequency * 2
            maxAmplitude = maxAmplitude + amplitude
            amplitude = amplitude * persistence
        end

        return math.floor(((total / maxAmplitude) + 1) * 128)
    end,

    raw_noise_2d = function(x, y)
        -- Noise contributions from the three corners
        local n0, n1, n2

        -- Skew the input space to determine which simplex cell we're in
        local F2 = 0.5 * (math.sqrt(3.0) - 1.0)

        -- Hairy factor for 2D
        local s = (x + y) * F2
        local i = Simplex.fastfloor(x + s)
        local j = Simplex.fastfloor(y + s)

        local G2 = (3.0 - math.sqrt(3.0)) / 6.0
        local t = (i + j) * G2

        -- Unskew the cell origin back to (x,y) space
        local X0 = i - t
        local Y0 = j - t

        -- The x,y distances from the cell origin
        local x0 = x - X0
        local y0 = y - Y0

        -- For the 2D case, the simplex shape is an equilateral triangle.
        -- Determine which simplex we are in.
        local i1, j1 -- Offsets for second (middle) corner of simplex in (i,j) coords
        if x0 > y0 then
            i1 = 1
            j1 = 0  -- lower triangle, XY order: (0,0)->(1,0)->(1,1)
        else
            i1 = 0
            j1 = 1
        end -- upper triangle, YX order: (0,0)->(0,1)->(1,1)

        -- A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
        -- a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
        -- c = (3-sqrt(3))/6
        local x1 = x0 - i1 + G2 -- Offsets for middle corner in (x,y) unskewed coords
        local y1 = y0 - j1 + G2
        local x2 = x0 - 1.0 + 2.0 * G2 -- Offsets for last corner in (x,y) unskewed coords
        local y2 = y0 - 1.0 + 2.0 * G2

        -- Work out the hashed gradient indices of the three simplex corners
        local ii = bit32.band(i, 255)
        local jj = bit32.band(j, 255)
        local perm = Simplex.perm
        local gi0 = Simplex.modulo(perm[ii+perm[jj+1]+1], 12)
        local gi1 = Simplex.modulo(perm[ii+i1+perm[jj+j1+1]+1], 12)
        local gi2 = Simplex.modulo(perm[ii+1+perm[jj+1+1]+1], 12)

        local grad3 = Simplex.grad3
        -- Calculate the contribution from the three corners
        local t0 = 0.5 - x0*x0-y0*y0
        if t0<0 then
            n0 = 0.0
        else
            t0 = t0 * t0
            n0 = t0 * t0 * Simplex.dot(grad3[gi0+1], x0, y0) -- (x,y) of grad3 used for 2D gradient
        end

        local t1 = 0.5 - x1*x1-y1*y1
        if t1<0 then
            n1 = 0.0
        else
            t1 = t1 * t1
            n1 = t1 * t1 * Simplex.dot(grad3[gi1+1], x1, y1)
        end

        local t2 = 0.5 - x2*x2-y2*y2
        if t2<0 then
            n2 = 0.0
        else
            t2 = t2 * t2
            n2 = t2 * t2 * Simplex.dot(grad3[gi2+1], x2, y2)
        end

        -- Add contributions from each corner to get the final noise value.
        -- The result is scaled to return values in the interval [-1,1].
        return 70.0 * (n0 + n1 + n2)
    end,

    fastfloor = function(x)
        return x > 0 and math.floor(x) or math.floor(x - 1)
    end,

    dot = function(g, x, y)
        return g[1] * x + g[2] * y
    end,

    modulo = function(a,b)
        return a - math.floor(a/b)*b
    end
}


function initEngine()
        --setup the view
        _view = View3D.new()
        stage.addChild(_view)

        --setup the camera
        _view.camera.z = -4000
        _view.camera.lookAt(Geom.Vector3D.new(0,0,0,0), nil)
        _view.camera.lens.far = 50000
end

function initScene()
        -- Define the grid size and the grid steps
        _wid = 6000
        _hgt = 8000
        _stepsX = desktop and 25 or 10 --Try to increase for faster CPU
        _stepsY = desktop and 25 or 10 --Try to increase for faster CPU
        _rot = math.floor(720/_stepsY)

        _heightScale = 10

        -- Create the segment set container
        _gridContainer = ObjectContainer3D.new()
        _view.scene.addChild(_gridContainer)

        -- Create the vector of segment sets.
        _grid = SegmentSet.new()
        _gridContainer.addChild(_grid)

        -- Setup some vars for reuse
        local wBy2 = _wid * 0.5
        local hBy2 = _hgt * 0.5
        local wGap = _wid / (_stepsX - 1)
        local hGap = _hgt / _stepsY

        local ctr=0
        for gY = 0, _stepsY - 1, 1 do
            -- Populate the segment sets with line segments across the grid
            local last = Geom.Vector3D.new(-wBy2, 0, -hBy2 + (gY * hGap), 0 )
            local next = Geom.Vector3D.new(0,0,0,0)

            local col = bit32.lshift(math.floor(0xA0 - (gY/_stepsY * 0xA0)), 8)
            for gX = 0, _stepsX - 1, 1 do
                next = Geom.Vector3D.new(-wBy2 + (gX * wGap), 0, -hBy2 + (gY * hGap), 0 )
                _grid.addSegment(Primitives.LineSegment.new(last, next, col, col, 0.75))
                ctr = ctr + 1
                last = next
            end
        end

        -- Add rolling spheres
        _sphere1 = Primitives.WireframeSphere.new(200, 16, 12, 0xffffff, 0.5)
        _sphere1.x = -wBy2 * 0.4 -- Off to the left a bit
        _sphere1.z = -hBy2 * 0.5
        _gridContainer.addChild(_sphere1)

        _sphere2 = Primitives.WireframeSphere.new(200, 16, 12, 0xff0000, 0.5)
        _sphere2.x = wBy2 * 0.4 -- Off to the right a bit
        _sphere2.z = -hBy2 * 0.5
        _gridContainer.addChild(_sphere2)

        _sphere3 = Primitives.WireframeSphere.new(100, 16, 12, 0x0000ff, 0.5)
        _sphere3.z = -hBy2 * 0.5 -- Off to the left a bit
        _gridContainer.addChild(_sphere3)

        -- Setup scrolling offset
        _offset = Geom.Point.new(0, 0)

        --stats
        stage.addChild(Debug.AwayFPS.new(_view, 10, 10, 0xffffff, 3))
end

function initParticles()
        --setup the particle geometry
        local plane = Primitives.PlaneGeometry.new(50, 50, 1, 1, false, false)
        local geometrySet = {}
        for i = 1, 500, 1 do
            geometrySet[i] = plane
        end

        --setup the particle animation set
        _particleAnimationSet = Animators.ParticleAnimationSet.new(true, true, false)
        _particleAnimationSet.addAnimation(Animators.Nodes.ParticleBillboardNode.new(nil))
        _particleAnimationSet.addAnimation(
                Animators.Nodes.ParticleVelocityNode.new(
                        Animators.Data.ParticlePropertiesMode.LOCAL_STATIC, nil))
        _particleAnimationSet.addAnimation(
                Animators.Nodes.ParticleColorNode.new(
                    Animators.Data.ParticlePropertiesMode.GLOBAL, true, false, false, false,
                        Geom.ColorTransform.new(0, 0, 0, 1, 0, 0, 0, 0),
                        Geom.ColorTransform.new(1, 1, 1, 1, 0, 0, 0, 0), 1, 0))
        _particleAnimationSet.initParticleFunc = initParticleFunc

        --setup the particle material
        local material = Materials.TextureMaterial.new(
                Cast.bitmapTexture("/3D/Away3D/Common/assets/particles/blue.png"), true, false, true, nil)
        material.blendMode = Display.BlendMode.ADD

        --setup the particle animator and mesh
        _particleAnimator = Animators.ParticleAnimator.new(_particleAnimationSet)
        _particleMesh = Mesh.new(Helpers.ParticleGeometryHelper.generateGeometry(geometrySet, nil), material)
        _particleMesh.animator = _particleAnimator
        _particleMesh.y = 1000
        _particleMesh.z = 5000
        _view.scene.addChild(_particleMesh)

        --start the animation
        _particleAnimator.start()
end

--Initialiser function for particle properties
function initParticleFunc(prop)
        prop.startTime = math.random()*10 - 10
        prop.duration = 10
        local degree1 = math.pi * -0.5 + (math.random() * math.pi)
        local degree2 = math.pi * -0.2 + math.random() * math.pi * -0.2
        local r = math.random() * 500 + 500
        prop.nodes.set(Animators.Nodes.ParticleVelocityNode.VELOCITY_VECTOR3D,
            Geom.Vector3D.new(
                r * math.sin(degree1) * math.cos(degree2), r * math.cos(degree1) * math.cos(degree2), r * math.sin(degree2), 0
            )
        )
end

function initListeners()
        _view.setRenderCallback(function(rect)
            -- Scroll the landscape
            _offset.y = _offset.y + 1

            -- Update the camera's horizontal positioning and rotation
            local camPos = math.sin(_offset.y * 0.05)
            _view.camera.x = camPos * _wid * 0.25
            _view.camera.rotationY = camPos * -25

            -- Extract all pixel Y coords and map to line segments
            local gX = 0
            local gY = 0
            local lastY = 0.0
            local nextY = 0.0
            local lS --Segment
            local scale = 128.0

            while gY < _stepsY do

                gX = 1
                lastY = Simplex.noise2D(0, (gY+_offset.y)/scale, 7, 0.5, 1) * _heightScale

                while gX < _stepsX do

                    -- Lookup line segment
                    local pos = gY * _stepsX + gX
                    lS = _grid.getSegment(pos)

                    nextY = Simplex.noise2D(gX/scale, (gY+_offset.y)/scale, 7, 0.5, 1) * _heightScale

                    -- Assign the heights for the beginning and end of the segment
                    lS.start.y = lastY
                    lS["end"].y = nextY

                    -- Update the current segment
                    _grid.updateSegment(lS)

                    -- Store previous height for next line segment
                    lastY = nextY

                    -- Increment across the line segments
                    gX = gX + 1
                end

                -- Increment across the rows
                gY = gY + 1
            end

            -- Update sphere positions
            gY = math.floor(_stepsY*0.25) * _stepsX
            lS = _grid.getSegment(gY + math.floor(_stepsX*0.3))
            _sphere1.y = lS["end"].y + 200
            _sphere1.rotationX = _sphere1.rotationX + _rot

            lS = _grid.getSegment(gY + math.floor(_stepsX*0.7))
            _sphere2.y = lS["end"].y + 200
            _sphere2.rotationX = _sphere2.rotationX + _rot

            lS = _grid.getSegment(gY + math.floor(_stepsX*0.5))
            _sphere3.y = lS["end"].y + 100
            _sphere3.rotationX = _sphere3.rotationX + _rot * 1.5

            -- Update camera height
            lS = _grid.getSegment(math.floor( _stepsX * (0.5 + camPos * 0.25)))
            _view.camera.y = lS["end"].y + 100

            -- Render 3D.
            _view.render()
        end)
end

initEngine()
initScene()
initParticles()
initListeners()