-- Main.lua

require("/TraceBox/TraceBox.lua")

deque =  Lib.Sys.VM.Deque.new()

trace = function(message) deque.add({type = 2, message = Lib.Str.string(message)}) end

print = function(...)
	local args = { n = select("#", ...); ... }
    local info = debug.getinfo(2)
    local msg = string.format("[print %s]:%d: ", info.source, info.currentline)
    for i = 1, args.n do msg = msg .. (args[i] == nil and 'nil' or tostring(args[i])) .. (i < args.n and '\t' or '') end
	deque.add({type = 1, message = Lib.Str.string(msg)})
end

msgBox = TraceBox.new(deque)


thread = Lib.Sys.VM.Thread.create([[
	deque = Lib.Sys.VM.Thread.readMessage(true)

    trace = function(message) deque.add({type = 2, message = Lib.Str.string(message)}) end

	print = function(...)
		local args = { n = select("#", ...); ... }
	    local info = debug.getinfo(2)
	    local msg = string.format("[print %s]:%d: ", info.source, info.currentline)
	    for i = 1, args.n do msg = msg .. (args[i] == nil and 'nil' or tostring(args[i])) .. (i < args.n and '\t' or '') end
		deque.add({type = 1, message = Lib.Str.string(msg)})
	end

    function safeWrap()
		trace("test3.1")
	    Lib.Sys.sleep(0.5)
	    print("test3.2")
    	error("test thread error")
	end
	local status, res = xpcall(safeWrap, debug.traceback)
	--if not status then
	--    trace(res)
	--end
]])
thread.sendMessage(deque)

function safeWrap()
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

	size = Lib.Media.Capabilities.screenDPI * (14 / 25.4)
	trace("Test2.1 <b>Test2.2</b> <font color='#0000FF' face='Purisa'>Test2.3</font> <font size='"..size.."'>Test2.4</font>")
	print(nil)
    error("test error")
end
local status, res = xpcall(safeWrap, debug.traceback)
--if not status then
--     trace(res)
--end