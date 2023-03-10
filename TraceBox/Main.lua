-- Main.lua

require("/TraceBox/TraceBox.lua")

main = Lib.Sys.VM.Thread.current()

trace = function(message) main.sendMessage({type = 2, message = Lib.Str.string(message)}) end

print = function(...)
	local args = { n = select("#", ...); ... }
    local info = debug.getinfo(2)
    local msg = string.format("[print %s]:%d: ", info.source, info.currentline)
    for i = 1, args.n do msg = msg .. (args[i] == nil and 'nil' or tostring(args[i])) .. (i < args.n and '\t' or '') end
	main.sendMessage({type = 1, message = Lib.Str.string(msg)})
end

msgBox = TraceBox.new()


thread = Lib.Sys.VM.Thread.create([[
	main = Lib.Sys.VM.Thread.readMessage(true)

    trace = function(message) main.sendMessage({type = 2, message = Lib.Str.string(message)}) end

	print = function(...)
		local args = { n = select("#", ...); ... }
	    local info = debug.getinfo(2)
	    local msg = string.format("[print %s]:%d: ", info.source, info.currentline)
	    for i = 1, args.n do msg = msg .. (args[i] == nil and 'nil' or tostring(args[i])) .. (i < args.n and '\t' or '') end
		main.sendMessage({type = 1, message = Lib.Str.string(msg)})
	end

	trace("test3.1")
    Lib.Sys.sleep(0.5)
    print("test3.2")
]])
thread.sendMessage(main)

print("test1.1", "test1.2")
tbl = {a=1,b=2}
trace(tbl)
print(tbl)

-- Load new font
Text = Lib.Media.Text
Font = Text.Font

font = Font.new("Purisa", Text.FontStyle.REGULAR, Text.FontType.EMBEDDED)
bytes = Lib.Project.getBytes("/Font/assets/Purisa.ttf")
Font.registerFontData(font, bytes)

size = Lib.Media.Capabilities.screenDPI * (7 * 2 / 25.4)
trace("Test2.1 <b>Test2.2</b> <font color='#0000FF' face='Purisa'>Test2.3</font> <font size='"..size.."'>Test2.4</font>")
print(nil)