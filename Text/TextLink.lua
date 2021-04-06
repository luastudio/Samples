-- TextLink.lua

Display = Lib.Media.Display
Text = Lib.Media.Text
Capabilities = Lib.Media.Capabilities
stage = Display.stage

stage.scaleX = Capabilities.screenDPI > 120 and Capabilities.screenDPI / 120 or 1
stage.scaleY = stage.scaleX

local fmt = Text.TextFormat.new('_sans', 16, 0x000000, nil, nil, nil)
fmt.align = Text.TextFormatAlign.LEFT
fmt.leftMargin = 4
fmt.rightMargin = 4
fmt.leading = 15

local text = Text.TextField.new()
text.defaultTextFormat = fmt
text.autoSize = Text.TextFieldAutoSize.LEFT
text.x = 10
text.y = 10
text.border = true
text.selectable = false
text.multiline = true
text.wordWrap = false
text.htmlText = [[LuaStudio related links:<br>
1. <u><font color='#0000FF'><a href='https://luastudio.github.io/' target='_blank'>LuaStudio Website</a></font></u><br>
2. <u><font color='#0000FF'><a href='https://luastudio.github.io/doc/html/LuaStudio%20API%20documentation.html' target='_blank'>LuaStudio API documentation</a></font></u><br>
3. <u><font color='#0000FF'><a href='https://www.lua.org' target='_blank'>Lua Website</a></font></u><br>
4. <u><font color='#0000FF'><a href='https://www.lua.org/manual/5.2/' target='_blank'>Lua 5.2 Reference Manual</a></font></u><br>
5. <u><font color='#0000FF'><a href='https://luajit.org/' target='_blank'>Lua JIT Website</a></font></u><br>
6. <u><font color='#0000FF'><a href='https://github.com/luastudio/samples' target='_blank'>Samples on GitHub</a></font></u><br>
7. <u><font color='#0000FF'><a href='event:myEvent'>Custom Link</a></font></u>]]

text.addEventListener(Lib.Media.Events.TextEvent.LINK, function(e)
	Lib.Sys.trace(e)
end, false, 0, false)

stage.addChild(text)