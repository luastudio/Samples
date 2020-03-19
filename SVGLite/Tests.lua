require("/SVGLite/SVGLite.lua")

Tests = {}
function Tests.new()
    local self = {}

    local printTitle
    local printMsg

    function self.title(title)
        printTitle=title
    end

    function self.yes(a,b,message)
        local msg
        if a==b then msg="." else msg="F("..Lib.Str.string(a).."=="..Lib.Str.string(b)..")" end
        if message~= nil then msg=msg.." - "..message.." " end
        printMsg=printMsg..msg
    end

    function self.no(a,b,message)
        local msg
        if a~=b then msg="." else msg="F("..Lib.Str.string(a).."~="..Lib.Str.string(b)..")"  end
        if message~= nil then msg=msg.." - "..message.." " end
        printMsg=printMsg..msg
    end

    function self.run()
        local test_index = 1
        while test_index<=1000 do
            local name = "Test"..test_index
            if self[name]~=nil then
                printMsg = ""
                printTitle=""
                self[name]()
                print(name..(Lib.Str.length(printTitle)>0 and "("..printTitle..")" or "")..
                    ": "..printMsg)
            end
            test_index = test_index + 1
        end
    end

    return self
end

svg = SVGLite.new()

local t = Tests.new()

function t.Test1()
    t.title("SVG parser")

    local ok, res = pcall(svg.parse, "svg></svg>")
    t.no(ok, true)
    t.yes(res, "Not an XML")

    ok, res = pcall(svg.parse, "<x></x>")
    t.no(ok, true)
    t.yes(res, "Not an SVG")

    local dom = svg.parse("<svg viewBox=\"0 0 174.239 170\"></svg>")
    t.yes(dom.type, "group")

    t.yes(dom.width, svg.defaultSize)
    t.yes(dom.height, svg.defaultSize)
    t.yes(dom.viewBox.x, 0)
    t.yes(dom.viewBox.y, 0)
    t.yes(dom.viewBox.width, 174.239)
    t.yes(dom.viewBox.height, 170)
end

function t.Test2()
    t.title("Rectangle")
    ---@language XML
    local dom = svg.parse([[<svg>
            <rect width="300" height="100" style="fill:rgb(0,0,255);stroke-width:3;stroke:rgb(0,0,0)" />
    </svg>]])

    t.yes(#dom.children, 1)
    local rect = dom.children[1]
    t.yes(rect.type, "path") --rect converted to path
    t.yes(rect.joint_style, Lib.Media.Display.JointStyle.MITER)
    t.yes(rect.alpha, 1)
    t.yes(rect.stroke_width, 3)
    t.yes(rect.stroke_alpha, 1)
    t.yes(rect.stroke_colour, 0)
    t.yes(rect.fill.Solid, 0x0000FF)
    t.yes(rect.fill_alpha, 1)
    t.yes(rect.miter_limit, 3)
    t.yes(rect.stroke_caps, Lib.Media.Display.CapsStyle.NONE)
    t.yes(#rect.segments, 5)

    local s1 = rect.segments[1]
    t.yes(s1.type, "MoveSegment")
    t.yes(s1.x, 0)
    t.yes(s1.y, 0)

    local s2 = rect.segments[2]
    t.yes(s2.type, "DrawSegment")
    t.yes(s2.x, 300)
    t.yes(s2.y, 0)

    local s3 = rect.segments[3]
    t.yes(s3.type, "DrawSegment")
    t.yes(s3.x, 300)
    t.yes(s3.y, 100)

    local s4 = rect.segments[4]
    t.yes(s4.type, "DrawSegment")
    t.yes(s4.x, 0)
    t.yes(s4.y, 100)

    local s5 = rect.segments[5]
    t.yes(s5.type, "DrawSegment")
    t.yes(s5.x, 0)
    t.yes(s5.y, 0)
end

function t.Test3()
    t.title("Circle")
    ---@language XML
    local dom = svg.parse([[
<svg height="100" width="100">
  <circle cx="50" cy="50" r="40" stroke="#000000" stroke-width="3" fill="#FF0000" />
</svg>]])
    t.yes(#dom.children, 1)
    local circle = dom.children[1]

    t.yes(circle.type, "path")
    t.yes(circle.name, "")
    t.yes(circle.joint_style, Lib.Media.Display.JointStyle.MITER)
    t.yes(circle.alpha, 1)
    t.yes(circle.stroke_width, 3)
    t.yes(circle.stroke_alpha, 1)
    t.yes(#circle.segments, 9)

    local s1 = circle.segments[1]
    t.yes(s1.type, "MoveSegment")
    t.yes(s1.x, 50+40)
    t.yes(s1.y, 50)

    local s2 = circle.segments[2]
    t.yes(s2.type, "QuadraticSegment")
    local s3 = circle.segments[3]
    t.yes(s3.type, "QuadraticSegment")
    local s4 = circle.segments[4]
    t.yes(s4.type, "QuadraticSegment")
    local s5 = circle.segments[5]
    t.yes(s5.type, "QuadraticSegment")
    local s6 = circle.segments[6]
    t.yes(s6.type, "QuadraticSegment")
    local s7 = circle.segments[7]
    t.yes(s7.type, "QuadraticSegment")
    local s8 = circle.segments[8]
    t.yes(s8.type, "QuadraticSegment")
    local s9 = circle.segments[9]
    t.yes(s9.type, "QuadraticSegment")
end

function t.Test4()
    t.title("Gradient/Ellipse")
    ---@language XML
    local dom = svg.parse([[
<svg height="150" width="400">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0" style="stop-color:rgb(255,255,0);stop-opacity:1" />
      <stop offset="1" style="stop-color:rgb(255,0,0);stop-opacity:1" />
    </linearGradient>
  </defs>
  <ellipse cx="200" cy="70" rx="85" ry="55" fill="url(#grad1)" />
</svg>]])
    t.yes(#dom.children, 1)
    local ellipse = dom.children[1]
    local grad = ellipse.fill.Grad
    t.yes(ellipse.type, "path")
    t.yes(ellipse.name, "")
    t.yes(ellipse.joint_style, Lib.Media.Display.JointStyle.MITER)
    t.yes(ellipse.alpha, 1)
    t.yes(ellipse.stroke_width, 1)
    t.yes(ellipse.stroke_alpha, 1)

    t.yes(grad.type,  Lib.Media.Display.GradientType.LINEAR)
    t.yes(grad.spread,  Lib.Media.Display.SpreadMethod.REPEAT) --PAD default?
    t.yes(grad.interp,  Lib.Media.Display.InterpolationMethod.RGB)
    t.yes(grad.focus, 0)
    t.yes(grad.radius, 0)
    t.yes(grad.x1, 0)
    t.yes(grad.y1, 0)
    t.yes(grad.x2, 100)
    t.yes(grad.y2, 0)
    t.yes(#grad.ratios, 2)
    t.yes(grad.ratios[1], 0)
    t.yes(grad.ratios[2], 255)
    t.yes(#grad.colors, 2)
    t.yes(grad.colors[1], 0xFFFF00)
    t.yes(grad.colors[2], 0xFF0000)
    t.yes(#grad.alphas, 2)
    t.yes(grad.alphas[1], 1)
    t.yes(grad.alphas[2], 1)

    t.yes(ellipse.fill_alpha, 1)
    t.yes(ellipse.stroke_caps, Lib.Media.Display.CapsStyle.NONE)
    t.yes(#ellipse.segments, 9)

    local s1 = ellipse.segments[1]
    t.yes(s1.type, "MoveSegment")
    t.yes(s1.x, 200 + 85)
    t.yes(s1.y, 70)

    local s2 = ellipse.segments[2]
    t.yes(s2.type, "QuadraticSegment")

    local s3 = ellipse.segments[3]
    t.yes(s3.type, "QuadraticSegment")

    local s4 = ellipse.segments[4]
    t.yes(s4.type, "QuadraticSegment")

    local s5 = ellipse.segments[5]
    t.yes(s5.type, "QuadraticSegment")

    local s6 = ellipse.segments[6]
    t.yes(s6.type, "QuadraticSegment")

    local s7 = ellipse.segments[7]
    t.yes(s7.type, "QuadraticSegment")

    local s8 = ellipse.segments[8]
    t.yes(s8.type, "QuadraticSegment")

    --svg.render(dom, Lib.Media.Display.stage.graphics)
end

function t.Test5()
    t.title("Path parser")
    ---@language XML
    local dom = svg.parse([[<svg>
            <path style="fill:#F4E578;"
                  d="M88.39300054931641,41.262
                     C91.19600054931641,46.29 92.7990005493164,52.081 92.7990005493164,58.248
                     c0,19.299 -15.646,34.944 -34.944,34.944
                     c-6.167,0 -11.958,-1.604 -16.986,-4.407
                     c4.164,17.276 19.712,30.116 38.268,30.116
                     c21.745,0 39.372,-17.628 39.372,-39.372
                     C118.5080005493164,60.974 105.66900054931641,45.426 88.39300054931641,41.262 z" id="svg_4"/>
            </svg>]])
    t.yes(#dom.children, 1)
    local path = dom.children[1]
    t.yes(path.type, "path")
    t.yes(path.name, "svg_4")
    t.yes(path.joint_style, Lib.Media.Display.JointStyle.MITER)
    t.yes(path.alpha, 1)
    t.yes(path.stroke_width, 1)
    t.yes(path.stroke_alpha, 1)
    t.yes(path.fill.Solid, 0xF4E578)
    t.yes(path.fill_alpha, 1)
    t.yes(path.miter_limit, 3)
    t.yes(path.stroke_caps, Lib.Media.Display.CapsStyle.NONE)
    t.yes(#path.segments, 8)

    local s1 = path.segments[1]
    t.yes(s1.type, "MoveSegment")
    t.yes(s1.x, 88.39300054931641)
    t.yes(s1.y, 41.262)

    local s2 = path.segments[2]
    t.yes(s2.type, "CubicSegment")
    t.yes(s2.x, 92.7990005493164)
    t.yes(s2.y, 58.248)
    t.yes(s2.cx1, 91.19600054931641)
    t.yes(s2.cy1, 46.29)
    t.yes(s2.cx2, 92.7990005493164)
    t.yes(s2.cy2, 52.081)

    t.yes(path.segments[3].type, "CubicSegment")
    t.yes(path.segments[4].type, "CubicSegment")
    t.yes(path.segments[5].type, "CubicSegment")
    t.yes(path.segments[6].type, "CubicSegment")
    t.yes(path.segments[7].type, "CubicSegment")

    local s8 = path.segments[8] --closing
    t.yes(s8.type, "DrawSegment")
    t.yes(s8.x, 88.39300054931641)
    t.yes(s8.y, 41.262)

    --svg.render(dom, Lib.Media.Display.stage.graphics)
end

t.run()