-- SVGLite.lua

SVGLite = {}
function SVGLite.new()
    local self = {}

    -- declarations
    local Xml = Lib.Sys.Xml; local XmlType = Xml.XmlType
    local Str = Lib.Str; local EReg = Lib.Sys.EReg
    local Display = Lib.Media.Display; local Geom = Lib.Media.Geom
    -- jit compat
    local bit32 = bit32
    if type(jit) == 'table' then
        bit32 = bit
    end

    --config
    self.convertCubics = false
    self.defaultSize = 400

    --PARSE--
    local MoveSegment = {}
    local DrawSegment = {}
    local CubicSegment = {}
    local QuadraticSegment = {}
    local ArcSegment = {}
    local pathParse --path parthing function

    function self.parseProjectFile(path)
		return self.parse(Lib.Project.getText(path))
    end

    function self.parse(svgText)
        local res, xml = pcall(Xml.parse, svgText)
        if not res or xml == nil or xml.nodeType ~= XmlType.Document then
            error("Not an XML", 0)
        end

        local svg = xml.firstElement()
        if svg == nil or (svg.nodeName ~= "svg" and svg.nodeName ~= "svg:svg") then
            error("Not an SVG", 0)
        end

        local trimToFloat = function(value)
            return Str.parseFloat( Str.trim(value) )
        end

        local getFloatAttr = function(element, attrName, default)
            if element.exists(attrName) then
                local value = element.get(attrName)
                return trimToFloat (value)
            end
            return default
        end

        local svgDOM = {}

        local width = getFloatAttr(svg, "width", 0.0)
        local height = getFloatAttr(svg,"height", 0.0)
        if width == 0 and height == 0 then
            width = self.defaultSize;  height = self.defaultSize
        elseif width == 0 then
            width = height
        elseif height == 0 then
            height = width
        end
        svgDOM.width = width; svgDOM.height = height

        if svg.exists("viewBox") then
            local vbox = svg.get("viewBox")
            local params = Str.indexOf(vbox, ",", 0) ~= -1 and Str.split(vbox, ",") or Str.split(vbox, " ")
            svgDOM.viewBox = Geom.Rectangle.new(trimToFloat(params[1]), trimToFloat(params[2]), trimToFloat(params[3]), trimToFloat(params[4]))
        else
            svgDOM.viewBox = Geom.Rectangle.new(0, 0, width, height)
        end

        local getStyle = function(key, node, styles, default)
            if node ~= nil and node.exists(key) then
                return node.get(key)
            end
            if styles ~= nil and styles[key] ~= nil then
                return styles[key]
            end

            return default
        end

        local getFloatStyle = function(key, node, styles, default)
            local s = getStyle(key, node, styles, "")
            if s == "" then
                return default
            end
            return Str.parseFloat(s)
        end

        local parseHex = function(hex)
            -- Support 3-character hex color shorthand
            --  e.g. #RGB -> #RRGGBB
            if Str.length(hex) == 3 then
                hex = Str.substr(hex,0,1) + Str.substr(hex,0,1) +
                        Str.substr(hex,1,1) + Str.substr(hex,1,1) +
                        Str.substr(hex,2,1) + Str.substr(hex,2,1)
            end
            return Str.parseInt("0x"..hex)
        end

        local parseRGBMatch = function(rgbMatch)
            -- CSS2 rgb color definition, matches 0-255 or 0-100%
            -- e.g. rgb(255,127,0) == rgb(100%,50%,0)
            function range(val)
                --constrain to Int 0-255
                if val < 0 then val = 0 end
                if val > 255 then val = 255 end
                return val
            end

            local r = Str.parseFloat(rgbMatch.matched (1))
            if rgbMatch.matched(2)=='%' then r = r * 255 / 100 end

            local g = Str.parseFloat(rgbMatch.matched (3))
            if rgbMatch.matched(4)=='%' then g = g * 255 / 100 end

            local b = Str.parseFloat(rgbMatch.matched (5))
            if rgbMatch.matched(6)=='%' then b = b * 255 / 100 end

            return bit32.bor( bit32.lshift(range(r), 16), bit32.lshift(range(g), 8), range(b) )
        end

        local defaultFill = { Solid = 0x000000 }
        local grads = {}
        local URLMatch = EReg.new("url\\(#(.*)\\)", "")
        local RGBMatch = EReg.new("rgb\\s*\\(\\s*(\\d+)\\s*(%)?\\s*,\\s*(\\d+)\\s*(%)?\\s*,\\s*(\\d+)\\s*(%)?\\s*\\)", "")
        local getFillStyle = function(key, node, styles)
            local s = getStyle(key, node, styles, "")
            if s == "" then
                return defaultFill
            end
            if Str.charAt(s, 0) == '#' then
                return { Solid = parseHex(Str.substr(s, 1, Str.length(s)-1)) }
            end
            if RGBMatch.match(s) then
                return { Solid = parseRGBMatch(RGBMatch) }
            end
            if s == "none" then
                return { }
            end
            if URLMatch.match(s) then
                local url = URLMatch.matched(1)
                if grads[url] ~= nil then
                    return { Grad = grads[url] }
                end
                error ("Unknown url:"..url,0)
            end
            error ("Unknown fill string:"..s,0)
        end

        local getStrokeStyle = function(key, node, styles, default)
            local s = getStyle(key, node, styles, "")

            if s == "" then
                return default
            end
            if RGBMatch.match(s) then
                return parseRGBMatch(RGBMatch)
            end
            if s == "none" then
                return nil
            end
            if Str.charAt(s, 0) == '#' then
                return parseHex(Str.substr(s, 1, Str.length(s)-1))
            end
            return Str.parseInt(s)
        end

        local getColorStyle = function(key, node, styles, default)
            local s = getStyle(key, node, styles, "")
            if s == "" then
                return default
            end
            if Str.charAt(s, 0) == '#' then
                return parseHex(Str.substr(1, Str.length(s) - 1))
            end

            if RGBMatch.match(s) then
                return parseRGBMatch(RGBMatch)
            end
            return Str.parseInt(s)
        end

        local getStyleAndConvert = function(key, node, styles, default, convert)
            local s = getStyle(key, node, styles, "")
            if s == "" or convert[s] == nil then
                return default
            end
            return convert[s]
        end

        local translateMatch = EReg.new("translate\\((.*)[, ](.*)\\)", "")
        local scaleMatch = EReg.new("scale\\((.[^,]*)([, ](.*))?\\)", "")
        local matrixMatch = EReg.new("matrix\\((.*?)[, ]+(.*?)[, ]+(.*?)[, ]+(.*?)[, ]+(.*?)[, ]+(.*?)\\)", "")
        local rotationMatch = EReg.new("rotate\\(([0-9\\.]+)(\\s+([0-9\\.]+)\\s*[, ]\\s*([0-9\\.]+))?\\)", "")
        local applyTransform = function(matrix, transform)
            --local scale = 1.0
            local transformations = Str.split(transform, ")")
            for i = 1,#transformations, 1 do
                local trans = Str.trim(transformations[i])
                if Str.length(trans) > 0 then
                    trans = trans..")"
                    if translateMatch.match(trans) then
                        matrix.tx = matrix.tx + Str.parseFloat(translateMatch.matched (1)) * matrix.a
                        matrix.ty = matrix.ty + Str.parseFloat(translateMatch.matched (2)) * matrix.d
                    elseif scaleMatch.match(trans) then
                        local scaleX = Str.parseFloat (scaleMatch.matched (1))
                        local scaleY = scaleMatch.matched (3) ~= nil and Str.parseFloat (scaleMatch.matched (3)) or scaleX
                        --matrix.scale(scaleX, scaleY)
                        matrix.a = matrix.a * scaleX
                        matrix.d = matrix.d * scaleY
                    elseif matrixMatch.match(trans) then
                        local m = Geom.Matrix.new (
                                Str.parseFloat (matrixMatch.matched (1)),
                                Str.parseFloat (matrixMatch.matched (2)),
                                Str.parseFloat (matrixMatch.matched (3)),
                                Str.parseFloat (matrixMatch.matched (4)),
                                Str.parseFloat (matrixMatch.matched (5)),
                                Str.parseFloat (matrixMatch.matched (6))
                        )

                        m.concat(matrix)

                        matrix.a = m.a
                        matrix.b = m.b
                        matrix.c = m.c
                        matrix.d = m.d
                        matrix.tx = m.tx
                        matrix.ty = m.ty

                        --scale = math.sqrt (matrix.a * matrix.a + matrix.c * matrix.c)
                    elseif rotationMatch.match(trans) then
                        local degrees = Str.parseFloat(rotationMatch.matched(1))
                        local rotationX = Str.parseFloat(rotationMatch.matched(2))
                        if rotationX == nil then
                            rotationX = 0.0
                        end

                        local rotationY = Str.parseFloat(rotationMatch.matched(3))
                        if rotationY == nil then
                            rotationY = 0.0
                        end

                        local radians = degrees * math.pi / 180

                        matrix.translate(-rotationX, -rotationY)
                        matrix.rotate(radians)
                        matrix.translate(rotationX, rotationY)
                    else
                        print("Warning, unknown transform:"..trans)
                    end
                end
            end
        end

        local styleSplit = EReg.new(";", "g")
        local styleValue = EReg.new("\\s*(.*)\\s*:\\s*(.*)\\s*", "")
        local getStyles = function(node, prevStyles)
            if not node.exists("style") then
                return prevStyles
            end

            local styles = {}
            if prevStyles ~= nil then
                for name, value in pairs(prevStyles) do
                    styles[name] = value
                end
            end

            local style = node.get("style")
            local strings = styleSplit.split (style)

            for i = 1,#strings,1 do
                if styleValue.match(strings[i]) then
                    styles[styleValue.matched(1)] = styleValue.matched(2)
                end
            end

            return styles
        end

        local SIN45 = 0.70710678118654752440084436210485
        local TAN22 = 0.4142135623730950488016887242097
        local loadPath = function(node, matrix, prevStyles, isRect, isEllipse, isCircle)
            if node.exists("transform") then
                matrix = matrix.clone()
                applyTransform(matrix, node.get("transform"))
            end

            local styles = getStyles(node, prevStyles)
            local name = node.exists("id") and node.get("id") or ""
            local pathDOM = {}
            pathDOM.type = "path"

            pathDOM.fill = getFillStyle("fill", node, styles)
            pathDOM.alpha = getFloatStyle("opacity", node, styles, 1.0)
            pathDOM.fill_alpha = getFloatStyle("fill-opacity", node, styles, 1.0)
            pathDOM.stroke_alpha = getFloatStyle("stroke-opacity", node, styles, 1.0)
            pathDOM.stroke_colour = getStrokeStyle("stroke", node, styles, nil)
            pathDOM.stroke_width = getFloatStyle("stroke-width", node, styles, 1.0)
            pathDOM.stroke_caps = getStyleAndConvert("stroke-linecap", node, styles, Display.CapsStyle.NONE,
                    {round = Display.CapsStyle.ROUND,
                     square = Display.CapsStyle.SQUARE,
                     butt = Display.CapsStyle.NONE})
            pathDOM.joint_style = getStyleAndConvert("stroke-linejoin", node, styles, Display.JointStyle.MITER,
                    {bevel = Display.JointStyle.BEVEL,
                     round = Display.JointStyle.ROUND,
                     miter = Display.JointStyle.MITER})
            pathDOM.miter_limit = getFloatStyle("stroke-miterlimit", node, styles, 3.0)
            pathDOM.segments = {}
            pathDOM.matrix = matrix
            pathDOM.name = name

            pathDOM.segments = {}
            if isRect then
                local x = node.exists("x") and Str.parseFloat(node.get("x")) or 0
                local y = node.exists("y") and Str.parseFloat(node.get("y")) or 0
                local w = Str.parseFloat(node.get("width"))
                local h = Str.parseFloat(node.get("height"))
                local rx = node.exists("rx") and Str.parseFloat(node.get("rx")) or 0.0
                local ry = node.exists ("ry") and Str.parseFloat(node.get("ry")) or 0.0
                if rx == 0 or ry == 0 then
                    pathDOM.segments[#pathDOM.segments+1] = MoveSegment.new(x, y)
                    pathDOM.segments[#pathDOM.segments+1] = DrawSegment.new(x + w, y)
                    pathDOM.segments[#pathDOM.segments+1] = DrawSegment.new(x + w, y + h)
                    pathDOM.segments[#pathDOM.segments+1] = DrawSegment.new(x, y + h)
                    pathDOM.segments[#pathDOM.segments+1] = DrawSegment.new(x, y)
                else
                    pathDOM.segments[#pathDOM.segments+1] = MoveSegment.new(x, y + ry)

                    -- top-left
                    pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x, y, x + rx, y)
                    pathDOM.segments[#pathDOM.segments+1] = DrawSegment.new(x + w - rx, y)

                    -- top-right
                    pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x + w, y, x + w, y + rx)
                    pathDOM.segments[#pathDOM.segments+1] = DrawSegment.new(x + w, y + h - ry)

                    -- bottom-right
                    pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x + w, y + h, x + w - rx, y + h)
                    pathDOM.segments[#pathDOM.segments+1] = DrawSegment.new(x + rx, y + h)

                    -- bottom-left
                    pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x, y + h, x, y + h - ry)
                    pathDOM.segments[#pathDOM.segments+1] = DrawSegment.new(x, y + ry)
                end
            elseif isEllipse then
                local x = node.exists("cx") and Str.parseFloat(node.get("cx")) or 0
                local y = node.exists("cy") and Str.parseFloat(node.get("cy")) or 0
                local r = isCircle and node.exists("r") and Str.parseFloat(node.get("r")) or 0.0
                local w = isCircle and r or node.exists("rx") and Str.parseFloat(node.get("rx")) or 0.0
                local w_ = w * SIN45
                local cw_ = w * TAN22
                local h = isCircle and r or node.exists("ry") and Str.parseFloat(node.get("ry")) or 0.0
                local h_ = h * SIN45
                local ch_ = h * TAN22

                pathDOM.segments[#pathDOM.segments+1] = MoveSegment.new(x + w, y)
                pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x + w,   y + ch_, x + w_, y + h_)
                pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x + cw_, y + h,   x,      y + h)
                pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x - cw_, y + h,   x - w_, y + h_)
                pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x - w,   y + ch_, x - w,  y)
                pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x - w,   y - ch_, x - w_, y - h_)
                pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x - cw_, y - h,   x,      y - h)
                pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x + cw_, y - h,   x + w_, y - h_)
                pathDOM.segments[#pathDOM.segments+1] = QuadraticSegment.new(x + w,   y - ch_, x + w,  y)
            else
                local d = node.exists("points") and ("M"..node.get("points").."z") or
                        node.exists("x1") and ("M"..node.get("x1")..","..node.get("y1").." "..node.get("x2")..","..node.get("y2").."z") or
                        node.get("d")

                local segments = pathParse(d)
                for i=1,#segments,1 do
                    pathDOM.segments[#pathDOM.segments+1] = segments[i]
                end
            end

            return pathDOM
        end

        local loadGradient = function(gradNode, type, crossLink)
            local name = gradNode.get("id")
            local grad = {}
            grad.type = type
            grad.gradMatrix = Geom.Matrix.new(1,0,0,1,0,0)
            grad.spread = Display.SpreadMethod.REPEAT
            grad.interp = Display.InterpolationMethod.RGB
            grad.focus = 0.0

            if crossLink and gradNode.exists("xlink:href") then
                local xlink = gradNode.get("xlink:href")
                if Str.charAt(xlink, 0) ~= "#" then
                    error ("xlink - unkown syntax : "..xlink,0)
                end

                local base = grads[Str.substr(xlink, 1, Str.length(xlink) - 1)]
                if base ~= nil then
                    grad.colors = base.colors
                    grad.alphas = base.alphas
                    grad.ratios = base.ratios
                    grad.gradMatrix = base.gradMatrix.clone()
                    grad.spread = base.spread
                    grad.interp = base.interp
                    grad.radius = base.radius
                else
                    error ("Unknown xlink : "..xlink,0)
                end
            end

            if gradNode.exists ("x1") then
                grad.x1 = getFloatAttr(gradNode, "x1", 0.0)
                grad.y1 = getFloatAttr(gradNode, "y1", 0.0)
                grad.x2 = getFloatAttr(gradNode, "x2", 0.0)
                grad.y2 = getFloatAttr(gradNode, "y2", 0.0)
            else
                grad.x1 = getFloatAttr(gradNode, "cx", 0.0)
                grad.y1 = getFloatAttr(gradNode, "cy", 0.0)
                grad.x2 = getFloatAttr(gradNode, "fx", grad.x1)
                grad.y2 = getFloatAttr(gradNode, "fy", grad.y1)
            end

            grad.radius = getFloatAttr(gradNode, "r", 0.0)

            if gradNode.exists ("gradientTransform") then
                applyTransform (grad.gradMatrix, gradNode.get("gradientTransform"))
            end

            local stops = gradNode.elements()
            grad.colors = grad.colors == nil and {} or grad.colors
            grad.alphas = grad.alphas == nil and {} or grad.alphas
            grad.ratios = grad.ratios == nil and {} or grad.ratios
            while stops.hasNext() do
                stop = stops.next()
                local styles = getStyles(stop, nil)
                grad.colors[#grad.colors+1] = getColorStyle("stop-color", stop, styles, 0x000000)
                grad.alphas[#grad.alphas+1] = getFloatStyle ("stop-opacity", stop, styles, 1.0)
                local offset = Str.trim(stop.get("offset"))
                if Str.endsWith(offset,"%") then offset=Str.substr(offset,0,Str.length(offset)-1) print("offset % not supported") end
                grad.ratios[#grad.ratios+1] = Str.parseFloat(offset) * 255.0
            end

            grads[name] = grad
        end

        local loadDefs = function(node)
            -- Two passes - to allow forward xlinks
            for pass = 1,2,1 do
                local defs = node.elements()
                while defs.hasNext() do
                    def = defs.next()
                    local name = def.nodeName
                    if Str.substr(name, 0, 4) == "svg:" then
                        name = Str.substr(name, 4, Str.length(name) - 4)
                    end
                    if name == "linearGradient" then
                        loadGradient (def, Display.GradientType.LINEAR, pass == 1)
                    elseif name == "radialGradient" then
                        loadGradient (def, Display.GradientType.RADIAL, pass == 1)
                    end
                end
            end
        end

        local loadText = function(node, matrix, prevStyles)
            if node.exists("transform") then
                matrix = matrix.clone()
                applyTransform (matrix, node.get("transform"))
            end

            local styles = getStyles(node, prevStyles)
            local text = {}
            text.type = "text"

            text.matrix = matrix
            text.name = node.exists("id") and node.get("id") or ""
            text.x = getFloatAttr(node, "x", 0.0)
            text.y = getFloatAttr(node, "y", 0.0)
            text.fill = getFillStyle("fill", node, styles)
            text.fill_alpha = getFloatStyle("fill-opacity", node, styles, 1.0)
            text.stroke_alpha = getFloatStyle("stroke-opacity", node, styles, 1.0)
            text.stroke_colour = getStrokeStyle("stroke", node, styles, null)
            text.stroke_width = getFloatStyle("stroke-width", node, styles, 1.0)
            text.font_family = getStyle("font-family", node, styles, "")
            text.font_size = getFloatStyle("font-size", node, styles, 12)
            text.letter_spacing = getFloatStyle("letter-spacing", node, styles, 0)
            text.kerning = getFloatStyle("kerning", node, styles, 0)
            text.text_align = getStyle("text-align", node, styles, "start")

            local string = "";

            local elements = node.elements()
            while elements.hasNext() do
                local txt = elements.next()
                string = string + txt.toString()
            end

            text.text = string

            return text
        end

        local loadGroup
        loadGroup = function (groupDOM, groupNode, matrix, prevStyles)
            if groupNode.exists("transform") then
                matrix = matrix.clone()
                applyTransform(matrix, group.get("transform"))
            end

            groupDOM.type = "group"
            if groupNode.exists("inkscape:label") then
                groupDOM.name = groupNode.get("inkscape:label")
            elseif groupNode.exists("id") then
                groupDOM.name = groupNode.get("id")
            end

            local styles = getStyles(groupNode, prevStyles)
            if groupNode.exists("opacity") then
                local opacity = groupNode.get("opacity")
                if styles == nil then
                    styles = {}
                end
                if styles["opacity"] ~= nil then
                    opacity = Str.string(Str.parseFloat(opacity) * Str.parseFloat(styles["opacity"]))
                end
                styles["opacity"] = opacity
            end

            local elements = groupNode.elements()
            --if elements.hasNext() then
                groupDOM.children = {}
            --end
            while elements.hasNext() do
                element = elements.next()

                local name = element.nodeName
                if Str.substr(name, 0, 4) == "svg:" then
                    name = Str.substr(name, 4, Str.length(name) - 4)
                end

                if not element.exists("display") or element["display"] ~= "none" then
                    if name == "defs" then
                        loadDefs(element)
                    elseif name == "g" then
                        if not (element.exists("display") and element.get("display") == "none") then
                            groupDOM.children[#groupDOM.children+1]=loadGroup({}, element, matrix, styles)
                        end
                    elseif name == "path" or name == "line" or name == "polyline" then
                        groupDOM.children[#groupDOM.children+1]=loadPath(element, matrix, styles, false, false, false)
                    elseif name == "rect" then
                        groupDOM.children[#groupDOM.children+1]=loadPath(element, matrix, styles, true, false, false)
                    elseif name == "polygon" then
                        groupDOM.children[#groupDOM.children+1]=loadPath(element, matrix, styles, false, false, false)
                    elseif name == "ellipse" then
                        groupDOM.children[#groupDOM.children+1]=loadPath(element, matrix, styles, false, true, false)
                    elseif name == "circle" then
                        groupDOM.children[#groupDOM.children+1]=loadPath(element, matrix, styles, false, true, true)
                    elseif name == "text" then
                        groupDOM.children[#groupDOM.children+1]=loadText(element, matrix, styles)
                    elseif name == "linearGradient" then
                        loadGradient(element, Display.GradientType.LINEAR, true)
                    elseif name == "radialGradient" then
                        loadGradient(element, Display.GradientType.RADIAL, true)
                    else
                        print("Warning: Unknown child "..name)
                    end
                end
            end

            return groupDOM
        end

        return loadGroup(svgDOM, svg, Geom.Matrix.new(1, 0, 0, 1, -svgDOM.viewBox.x, -svgDOM.viewBox.y), nil)
    end

    local MOVE  = Str.charCodeAt("M", 0); local MOVER = Str.charCodeAt("m", 0)
    local LINE  = Str.charCodeAt("L", 0); local LINER = Str.charCodeAt("l", 0)
    local HLINE = Str.charCodeAt("H", 0); local HLINER = Str.charCodeAt("h", 0)
    local VLINE = Str.charCodeAt("V", 0); local VLINER = Str.charCodeAt("v", 0)
    local CUBIC = Str.charCodeAt("C", 0); local CUBICR = Str.charCodeAt("c", 0)
    local SCUBIC = Str.charCodeAt("S", 0); local SCUBICR = Str.charCodeAt("s", 0)
    local QUAD = Str.charCodeAt("Q", 0); local QUADR = Str.charCodeAt("q", 0)
    local SQUAD = Str.charCodeAt("T", 0); local SQUADR = Str.charCodeAt("t", 0)
    local ARC = Str.charCodeAt("A", 0); local ARCR = Str.charCodeAt("a", 0)
    local CLOSE = Str.charCodeAt("Z", 0); local CLOSER = Str.charCodeAt("z", 0)

    local UNKNOWN = -1; local SEPARATOR = -2
    local FLOAT = -3; local FLOAT_SIGN = -4
    local FLOAT_DOT = -5; local FLOAT_EXP = -6

    local sCommandArgs = {}
    pathParse = function (pathToParse)
        if #sCommandArgs == 0 then
            local commandArgs = function(inCode)
                if inCode==10 then return SEPARATOR end

                local str = Str.toUpperCase(Str.fromCharCode(inCode))
                if str>="0" and str<="9" then
                    return FLOAT
                end

                if str == "Z" then return 0
                elseif str == "H" or str == "V" then return 1
                elseif str == "M" or str == "L" or str == "T" then return 2
                elseif str == "S" or str == "Q" then return 4
                elseif str == "C" then return 6
                elseif str == "A" then return 7
                elseif str == "\t" or str == "\n" or str == " " or str == "\r" or str == "," then return SEPARATOR
                elseif str == "-" then return FLOAT_SIGN
                elseif str == "+" then return FLOAT_SIGN
                elseif str == "E" or str == "e" then return FLOAT_EXP
                elseif str == "." then return FLOAT_DOT end

                return UNKNOWN
            end

            for i=1,128,1 do
                sCommandArgs[i] = commandArgs(i-1)
            end
        end

        local lastMoveX = 0
        local lastMoveY = 0
        local pos=0
        local args={}
        local args_index = 1
        local segments = {}
        local segments_index = 1
        local current_command_pos = 0
        local current_command = -1
        local current_args = -1

        local prev
        local len = Str.length(pathToParse)
        local finished = false
        while pos<=len do
            local code = pos==len and 32 or Str.charCodeAt(pathToParse, pos)
            local command = (code>0 and code<128) and sCommandArgs[code+1] or UNKNOWN
            if command==UNKNOWN then
                error("failed parsing path near '"..Str.substr(pathToParse, pos, len - pos).."'",0)
            end

            if command==SEPARATOR then
                pos = pos + 1
            elseif command<=FLOAT then
                local _end = pos+1
                local e_pos = -1
                local seen_dot = command == FLOAT_DOT
                if command==FLOAT_EXP then
                    e_pos = 0
                    seen_dot = true
                end
                while _end<len do
                    local ch = Str.charCodeAt(pathToParse, _end)
                    code = ch<0 or ch>127 and UNKNOWN or sCommandArgs[ch+1]
                    if code>FLOAT then
                        break
                    end
                    if code==FLOAT_DOT then
                        if seen_dot then
                            break
                        else
                            seen_dot = true
                        end
                    end
                    if e_pos>=0 then
                        if code==FLOAT_SIGN then
                            if e_pos~=0 then break end
                        elseif code~=FLOAT then
                            break
                        end
                        e_pos = e_pos+1
                    elseif code==FLOAT_EXP then
                        if e_pos>=0 then break end
                        e_pos = 0
                        seen_dot = true
                    elseif code==FLOAT_SIGN then
                        break
                    end
                    _end = _end + 1
                end
                if current_command<0 then
                    --error("Too many numbers near '"..Str.substr(pathToParse, current_command_pos,len-current_command_pos).."'")
                else
                    local f = Str.parseFloat(Str.substr(pathToParse, pos,_end-pos))
                    args[args_index] = f
                    args_index = args_index + 1
                end
                pos = _end
            else
                current_command = code
                current_args = command
                finished = false
                current_command_pos = pos
                args = {}
                args_index = 1
                pos = pos + 1
            end

            local px = 0.0
            local py = 0.0
            if current_command>=0 then
                if current_args == #args then
                    if self.convertCubics and prev~=nil then
                        px = prev.X
                        py = prev.Y
                    end
                    --prev = createCommand(current_command, args)
                    local prevX = function() return (prev~=nil) and prev.prevX() or 0 end
                    local prevY = function() return (prev~=nil) and prev.prevY() or 0 end
                    local prevCX = function() return (prev~=nil) and prev.prevCX() or 0 end
                    local prevCY = function() return (prev~=nil) and prev.prevCY() or 0 end
                    if current_command == MOVE then
                        lastMoveX = args[1]
                        lastMoveY = args[2]
                        prev = MoveSegment.new(lastMoveX, lastMoveY)
                    elseif current_command == MOVER then
                        lastMoveX = args[1]+prevX()
                        lastMoveY = args[2]+prevY()
                        prev = MoveSegment.new(lastMoveX, lastMoveY)
                    elseif current_command == LINE then
                        prev = DrawSegment.new(args[1], args[2])
                    elseif current_command == LINER then
                        prev = DrawSegment.new(args[1]+prevX(), args[2]+prevY())
                    elseif current_command == HLINE then
                        prev = DrawSegment.new(args[1], prevY())
                    elseif current_command == HLINER then
                        prev = DrawSegment.new(args[1]+prevX(), prevY())
                    elseif current_command == VLINE then
                        prev = DrawSegment.new(prevX(), args[1])
                    elseif current_command == VLINER then
                        prev = DrawSegment.new(prevX(), args[1]+prevY())
                    elseif current_command == CUBIC then
                        prev = CubicSegment.new(args[1], args[2], args[3], args[4], args[5], args[6])
                    elseif current_command == CUBICR then
                        local rx = prevX()
                        local ry = prevY()
                        prev = CubicSegment.new(args[1]+rx, args[2]+ry, args[3]+rx, args[4]+ry, args[5]+rx, args[6]+ry)
                    elseif current_command == SCUBIC then
                        local rx = prevX()
                        local ry = prevY()
                        prev = CubicSegment.new(rx*2-prevCX(), ry*2-prevCY(), args[1], args[2], args[3], args[4])
                    elseif current_command == SCUBICR then
                        local rx = prevX()
                        local ry = prevY()
                        prev = CubicSegment.new(rx*2-prevCX(), ry*2-prevCY(), args[1]+rx, args[2]+ry, args[3]+rx, args[4]+ry)
                    elseif current_command == QUAD then
                        prev = QuadraticSegment.new(args[1], args[2], args[3], args[4])
                    elseif current_command == QUADR then
                        local rx = prevX()
                        local ry = prevY()
                        prev = QuadraticSegment.new(args[1]+rx, args[2]+ry, args[3]+rx, args[4]+ry)
                    elseif current_command == SQUAD then
                        local rx = prevX()
                        local ry = prevY()
                        prev = QuadraticSegment.new(rx*2-prevCX(), ry*2-prevCY(), args[3], args[4])
                    elseif current_command == SQUADR then
                        local rx = prevX()
                        local ry = prevY()
                        prev = QuadraticSegment.new(rx*2-prevCX(), ry*2-prevCY(), args[3]+rx, args[4]+ry)
                    elseif current_command == ARC then
                        prev = ArcSegment.new(prevX(), prevY(), args[1], args[2], args[3], args[4]~=0, args[5]~=0, args[6], args[7])
                    elseif current_command == ARCR then
                        local rx = prevX()
                        local ry = prevY()
                        prev = ArcSegment.new(rx, ry, args[1], args[2], args[3], args[4]~=0, args[5]~=0, args[6]+rx, args[7]+ry)
                    elseif current_command == CLOSE then
                        prev = DrawSegment.new(lastMoveX, lastMoveY)
                    elseif current_command == CLOSER then
                        prev = DrawSegment.new(lastMoveX, lastMoveY)
                    end
                    if prev == nil then
                        error("Unknown command "..Str.fromCharCode(current_command)..
                                " near '"..Str.substr(pathToParse, current_command_pos,len-current_command_pos).."'",0)
                    end
                    if self.convertCubics and prev.type=="CubicSegment" then
                        local cubic = prev
                        local quads = cubic.toQuadratics(px,py)
                        for quads_index=1,#quads,1 do
                            local q = quads[quads_index]
                            segments[segments_index]=q
                            segments_index = segments_index + 1
                        end
                    else
                        segments[segments_index]=prev
                        segments_index = segments_index + 1
                    end

                    finished = true
                    if current_args==0 then
                        current_args = -1
                        current_command = -1
                    elseif current_command==MOVE then
                        current_command = LINE
                    elseif current_command==MOVER then
                        current_command = LINER
                    end
                    current_command_pos = pos
                    args={}
                    args_index = 1
                end
            end
        end

        if current_command>=0 and not finished then
            error("Unfinished command ("..#args.."/"..current_args..
                    ") near '"..Str.substr(pathToParse, current_command_pos, len-current_command_pos).."'",0)
        end

        return segments
    end

    function MoveSegment.new(x, y)
        local moveSegment = {}
        moveSegment.type = "MoveSegment"
        moveSegment.x = x
        moveSegment.y = y
        moveSegment.prevX = function() return moveSegment.x end
        moveSegment.prevY = function() return moveSegment.y end
        moveSegment.prevCX = function() return moveSegment.x end
        moveSegment.prevCY = function() return moveSegment.y end
        moveSegment.toGfx = function(gfx, context)
            context.setLast(moveSegment.x,moveSegment.y)
            context.firstX = context.lastX
            context.firstY = context.lastY
            gfx.moveTo(context.lastX, context.lastY)
        end

        return moveSegment
    end

    function DrawSegment.new(x, y)
        local drawSegment = {}
        drawSegment.type = "DrawSegment"
        drawSegment.x = x
        drawSegment.y = y
        drawSegment.prevX = function() return drawSegment.x end
        drawSegment.prevY = function() return drawSegment.y end
        drawSegment.prevCX = function() return drawSegment.x end
        drawSegment.prevCY = function() return drawSegment.y end
        drawSegment.toGfx = function(gfx, context)
            context.setLast(drawSegment.x,drawSegment.y)
            gfx.lineTo(context.lastX, context.lastY)
        end

        return drawSegment
    end

    function CubicSegment.new(cx1, cy1, cx2, cy2, x, y)
        local cubicSegment = {}
        cubicSegment.type = "CubicSegment"
        cubicSegment.x = x
        cubicSegment.y = y
        cubicSegment.cx1 = cx1
        cubicSegment.cy1 = cy1
        cubicSegment.cx2 = cx2
        cubicSegment.cy2 = cy2
        cubicSegment.prevX = function() return cubicSegment.x end
        cubicSegment.prevY = function() return cubicSegment.y end
        cubicSegment.prevCX = function() return cubicSegment.cx2 end
        cubicSegment.prevCY = function() return cubicSegment.cy2 end

        local Interp = function (a, b, frac)
            return a + (b-a)*frac
        end

        cubicSegment.toGfx = function(gfx, context)
            --Transformed endpoints/controlpoints
            local tx0 = context.lastX
            local ty0 = context.lastY

            local tx1 = context.transX(cubicSegment.cx1,cubicSegment.cy1)
            local ty1 = context.transY(cubicSegment.cx1,cubicSegment.cy1)
            local tx2 = context.transX(cubicSegment.cx2,cubicSegment.cy2)
            local ty2 = context.transY(cubicSegment.cx2,cubicSegment.cy2)

            context.setLast(cubicSegment.x,cubicSegment.y)
            local tx3 = context.lastX
            local ty3 = context.lastY

            -- from http://www.timotheegroleau.com/Flash/articles/cubic_bezier/bezier_lib.as
            local pa_x = Interp(tx0,tx1,0.75)
            local pa_y = Interp(ty0,ty1,0.75)
            local pb_x = Interp(tx3,tx2,0.75)
            local pb_y = Interp(ty3,ty2,0.75)

            -- get 1/16 of the [P3, P0] segment
            local dx = (tx3 - tx0)/16
            local dy = (ty3 - ty0)/16

            -- calculates control point 1
            local pcx_1 = Interp(tx0, tx1, 3/8)
            local pcy_1 = Interp(ty0, ty1, 3/8)

            -- calculates control point 2
            local pcx_2 = Interp(pa_x, pb_x, 3/8) - dx
            local pcy_2 = Interp(pa_y, pb_y, 3/8) - dy

            -- calculates control point 3
            local pcx_3 = Interp(pb_x, pa_x, 3/8) + dx
            local pcy_3 = Interp(pb_y, pa_y, 3/8) + dy

            -- calculates control point 4
            local pcx_4 = Interp(tx3, tx2, 3/8)
            local pcy_4 = Interp(ty3, ty2, 3/8)

            -- calculates the 3 anchor points
            local pax_1 = (pcx_1+pcx_2) * 0.5
            local pay_1 = (pcy_1+pcy_2) * 0.5

            local pax_2 = (pa_x+pb_x) * 0.5
            local pay_2 = (pa_y+pb_y) * 0.5

            local pax_3 = (pcx_3+pcx_4) * 0.5
            local pay_3 = (pcy_3+pcy_4) * 0.5

            -- draw the four quadratic subsegments
            gfx.curveTo(pcx_1, pcy_1, pax_1, pay_1)
            gfx.curveTo(pcx_2, pcy_2, pax_2, pay_2)
            gfx.curveTo(pcx_3, pcy_3, pax_3, pay_3)
            gfx.curveTo(pcx_4, pcy_4, tx3, ty3)
        end

        cubicSegment.toQuadratics = function(tx0,ty0)
            local result = {}
            -- from http://www.timotheegroleau.com/Flash/articles/cubic_bezier/bezier_lib.as

            local pa_x = Interp(tx0,cubicSegment.cx1,0.75)
            local pa_y = Interp(ty0,cubicSegment.cy1,0.75)
            local pb_x = Interp(cubicSegment.x,cubicSegment.cx2,0.75)
            local pb_y = Interp(cubicSegment.y,cubicSegment.cy2,0.75)

            -- get 1/16 of the [P3, P0] segment
            local dx = (cubicSegment.x - tx0)/16
            local dy = (cubicSegment.y - ty0)/16

            -- calculates control point 1
            local pcx_1 = Interp(tx0, cubicSegment.cx1, 3/8)
            local pcy_1 = Interp(ty0, cubicSegment.cy1, 3/8)

            -- calculates control point 2
            local pcx_2 = Interp(pa_x, pb_x, 3/8) - dx
            local pcy_2 = Interp(pa_y, pb_y, 3/8) - dy

            -- calculates control point 3
            local pcx_3 = Interp(pb_x, pa_x, 3/8) + dx
            local pcy_3 = Interp(pb_y, pa_y, 3/8) + dy

            -- calculates control point 4
            local pcx_4 = Interp(cubicSegment.x, cubicSegment.cx2, 3/8)
            local pcy_4 = Interp(cubicSegment.y, cubicSegment.cy2, 3/8)

            -- calculates the 3 anchor points
            local pax_1 = (pcx_1+pcx_2) * 0.5
            local pay_1 = (pcy_1+pcy_2) * 0.5

            local pax_2 = (pa_x+pb_x) * 0.5
            local pay_2 = (pa_y+pb_y) * 0.5

            local pax_3 = (pcx_3+pcx_4) * 0.5
            local pay_3 = (pcy_3+pcy_4) * 0.5

            -- draw the four quadratic subsegments
            result[1] = QuadraticSegment.new(pcx_1, pcy_1, pax_1, pay_1)
            result[2] = QuadraticSegment.new(pcx_2, pcy_2, pax_2, pay_2)
            result[3] = QuadraticSegment.new(pcx_3, pcy_3, pax_3, pay_3)
            result[4] = QuadraticSegment.new(pcx_4, pcy_4, cubicSegment.x, cubicSegment.y)

            return result
        end

        return cubicSegment
    end

    function QuadraticSegment.new(cx, cy, x, y)
        local quadraticSegment = {}
        quadraticSegment.type = "QuadraticSegment"
        quadraticSegment.x = x
        quadraticSegment.y = y
        quadraticSegment.cx = cx
        quadraticSegment.cy = cy
        quadraticSegment.prevX = function() return quadraticSegment.x end
        quadraticSegment.prevY = function() return quadraticSegment.y end
        quadraticSegment.prevCX = function() return quadraticSegment.cx end
        quadraticSegment.prevCY = function() return quadraticSegment.cy end
        quadraticSegment.toGfx = function(gfx, context)
            context.setLast(quadraticSegment.x,quadraticSegment.y)
            gfx.curveTo(context.transX(quadraticSegment.cx,quadraticSegment.cy) ,
                    context.transY(quadraticSegment.cx,quadraticSegment.cy),
                    context.lastX, context.lastY)
        end

        return quadraticSegment
    end

    function ArcSegment.new(x1, y1, rx, ry, rotation, largeArc, sweep, x, y)
        local arcSegment = {}
        arcSegment.type = "ArcSegment"
        arcSegment.x = x
        arcSegment.y = y
        arcSegment.x1 = x1
        arcSegment.y1 = y1
        arcSegment.rx = rx
        arcSegment.ry = ry
        arcSegment.phi = rotation
        arcSegment.fA = largeArc
        arcSegment.fS = sweep
        arcSegment.prevX = function() return arcSegment.x end
        arcSegment.prevY = function() return arcSegment.y end
        arcSegment.prevCX = function() return arcSegment.x end
        arcSegment.prevCY = function() return arcSegment.y end
        arcSegment.toGfx = function(gfx, context)
            if arcSegment.x1==arcSegment.x and arcSegment.y1==arcSegment.y then
                return
            end

            context.setLast(arcSegment.x,arcSegment.y)
            if arcSegment.rx==0 or arcSegment.ry==0 then
                gfx.lineTo(context.lastX, context.lastY)
                return
            end
            if arcSegment.rx<0 then arcSegment.rx = -arcSegment.rx end
            if arcSegment.ry<0 then arcSegment.ry = -arcSegment.ry end

            -- See:  http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
            local p = arcSegment.phi*math.pi/180.0
            local cos = math.cos(p)
            local sin = math.sin(p)

            -- Step 1, compute x', y'
            local dx = (arcSegment.x1-arcSegment.x)*0.5
            local dy = (arcSegment.y1-arcSegment.y)*0.5
            local x1_ = cos*dx + sin*dy
            local y1_ = -sin*dx + cos*dy

            -- Step 2, compute cx', cy'
            local rx2 = arcSegment.rx*arcSegment.rx
            local ry2 = arcSegment.ry*arcSegment.ry
            local x1_2 = x1_*x1_;
            local y1_2 = y1_*y1_;
            local s = (rx2*ry2 - rx2*y1_2 - ry2*x1_2) / (rx2*y1_2 + ry2*x1_2 )
            if s<0 then
                s=0
            elseif arcSegment.fA==arcSegment.fS then
                s = -math.sqrt(s)
            else
                s = math.sqrt(s)
            end

            local cx_ = s*arcSegment.rx*y1_/arcSegment.ry
            local cy_ = -s*arcSegment.ry*x1_/arcSegment.rx

            -- Step 3, compute cx,cy from cx',cy'
            -- Something not quite right here.

            local xm = (arcSegment.x1+arcSegment.x)*0.5
            local ym = (arcSegment.y1+arcSegment.y)*0.5

            local cx = cos*cx_ - sin*cy_ + xm
            local cy = sin*cx_ + cos*cy_ + ym

            local theta = math.atan2( (y1_-cy_)/arcSegment.ry, (x1_-cx_)/arcSegment.rx )
            local dtheta = math.atan2( (-y1_-cy_)/arcSegment.ry, (-x1_-cx_)/arcSegment.rx ) - theta

            if arcSegment.fS and dtheta<0 then
                dtheta = dtheta + 2.0*math.pi
            elseif not arcSegment.fS and dtheta>0 then
                dtheta = dtheta - 2.0*math.pi
            end

            local m = context.matrix
            local Txc = 0.0
            local Txs = 0.0
            local Tx0 = 0.0
            local Tyc = 0.0
            local Tys = 0.0
            local Ty0 = 0.0
            if m~=nil then
                Txc = m.a*arcSegment.rx
                Txs = m.c*arcSegment.ry
                Tx0 = m.a*cx + m.c*cy + m.tx
                Tyc = m.b*arcSegment.rx
                Tys = m.d*arcSegment.ry
                Ty0 = m.b*cx + m.d*cy + m.ty
            else
                Txc = arcSegment.rx
                Txs = 0
                Tx0 = cx+m.tx
                Tyc = 0
                Tys = arcSegment.ry
                Ty0 = cy+m.ty
            end

            local len = math.abs(dtheta)*math.sqrt(Txc*Txc + Txs*Txs + Tyc*Tyc + Tys*Tys)
            -- TODO: Do as series of quadratics ...
            len = len * 5
            local steps = len>=0 and math.floor(len+0.5) or math.ceil(len-0.5)

            if steps>1 then
                dtheta = dtheta / steps
                local i = 1
                while i < steps-1 do
                    local c = math.cos(theta)
                    local _s = math.sin(theta)
                    theta=theta+dtheta
                    gfx.lineTo(Txc*c + Txs*_s + Tx0,   Tyc*c + Tys*_s + Ty0)
                    i = i + 1
                end
            end
            gfx.lineTo(context.lastX, context.lastY)
        end

        return arcSegment
    end

    --RENDER--

    local mMatrix
    local mScaleRect
    local mScaleW
    local mScaleH
    local mGfx

    local RenderContext = {}
    function RenderContext.new(matrix, rect, w, h)
        local renderContext = {}
        renderContext.matrix = matrix
        renderContext.rect = rect
        renderContext.rectW = w~=nil and w or rect~=nil and rect.width or 1
        renderContext.rectH = h~=nil and h or rect~=nil and rect.height or 1
        renderContext.firstX = 0
        renderContext.firstY = 0
        renderContext.lastX = 0
        renderContext.lastY = 0

        function  renderContext.transX(x, y)
            if renderContext.rect~=nil and x>renderContext.rect.x then
                if x>renderContext.rect.right then
                    x = x + renderContext.rectW - renderContext.rect.width
                else
                    x = renderContext.rect.x + renderContext.rectW * (x-renderContext.rect.x)/renderContext.rect.width
                end
            end
            return x*renderContext.matrix.a + y*renderContext.matrix.c + renderContext.matrix.tx
        end

        function  renderContext.transY(x, y)
            if renderContext.rect~=nil and y>renderContext.rect.y then
                if y>renderContext.rect.right then
                    y = y + renderContext.rectH - renderContext.rect.height
                else
                    y = renderContext.rect.y + renderContext.rectH * (y-renderContext.rect.y)/renderContext.rect.height
                end
            end
            return x*renderContext.matrix.b + y*renderContext.matrix.d + renderContext.matrix.ty
        end

        function renderContext.setLast(x, y)
            renderContext.lastX = renderContext.transX(x,y)
            renderContext.lastY = renderContext.transY(x,y)
        end

        return renderContext
    end

    local SQRT2 = math.sqrt(2)
    local iteratePath = function(pathDOM)
        if #pathDOM.segments==0 then return end

        local m  = pathDOM.matrix.clone()
        m.concat(mMatrix)
        local context = RenderContext.new(m,mScaleRect,mScaleW,mScaleH)

        -- Move to avoid the case of:
        --  1. finish drawing line on last path
        --  2. set fill=something
        --  3. move (this draws in the fill)
        --  4. continue with "real" drawing
        pathDOM.segments[1].toGfx(mGfx, context)
        if pathDOM.fill.Solid ~= nil then
            mGfx.beginFill(pathDOM.fill.Solid, pathDOM.fill_alpha*pathDOM.alpha)
        elseif pathDOM.fill.Grad ~= nil then
            local grad = pathDOM.fill.Grad
            --updateMatrix(m)
            local dx = grad.x2-grad.x1
            local dy = grad.y2-grad.y1
            local theta = math.atan2(dy,dx)
            local len = math.sqrt(dx*dx+dy*dy)
            local mtx = Geom.Matrix.new(1,0,0,1,0,0)
            if grad.type==Display.GradientType.LINEAR then
                mtx.createGradientBox(1.0,1.0,0.0,0.0,0.0)
                mtx.scale(len,len)
            else
                if grad.radius~=0.0 then
                    grad.focus = len/grad.radius
                end
                mtx.createGradientBox(1.0,1.0,0.0,0.0,0.0)
                mtx.translate(-0.5,-0.5)
                mtx.scale(grad.radius*2,grad.radius*2)
            end
            mtx.rotate(theta)
            mtx.translate(grad.x1,grad.y1)
            mtx.concat(grad.gradMatrix)
            mtx.concat(m)
            grad.matrix=ntx
            --
            --mGfx.beginGradientFill(grad)
            mGfx.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, grad.matrix, grad.spread,
	            grad.interp, grad.focus)
        end

        if pathDOM.stroke_colour~=nil then
            local scale = math.sqrt(m.a*m.a+m.d*m.d)/SQRT2
            mGfx.lineStyle(pathDOM.stroke_width*scale, pathDOM.stroke_colour,
                    pathDOM.stroke_alpha*pathDOM.alpha, false,
                    Display.LineScaleMode.NORMAL,
                    pathDOM.stroke_caps, pathDOM.joint_style, pathDOM.miter_limit)
        end

        for i=1,#pathDOM.segments,1 do
            local segment = pathDOM.segments[i]
            segment.toGfx(mGfx, context)
        end

        -- endFill automatically close an open path
        -- by putting endLineStyle before endFill, the closing line is not drawn
        -- so an open path in inkscape stay open in openfl
        -- this does not affect closed path
        mGfx.lineStyle(nil,0,1.0,false,nil,nil,nil,3)
        mGfx.endFill()
    end

    local iterateGroup
    iterateGroup = function(groupDOM)
        for i=1,#groupDOM.children,1 do
            local child = groupDOM.children[i]
            if child.type == "path" then
                iteratePath(child)
            elseif child.type == "group" then
                iterateGroup(child)
            elseif child.type == "text" then
                --iterateText(child)
            end
        end
    end

    function self.render(groupDOM, gfx, matrix, scaleRect, scaleW, scaleH)
        if gfx == nil then return end
        if matrix==nil then
            mMatrix = Geom.Matrix.new(1,0,0,1,0,0)
        else
            mMatrix = matrix.clone()
        end

        mScaleRect = scaleRect
        mScaleW = scaleW
        mScaleH = scaleH
        mGfx = gfx

        iterateGroup(groupDOM)
    end

    return self
end