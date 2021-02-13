-- Clipboard.lua

Display = Lib.Media.Display
Events = Lib.Media.Events
Text = Lib.Media.Text
Capabilities = Lib.Media.Capabilities
stage = Display.stage

stage.scaleX = Capabilities.screenDPI > 120 and Capabilities.screenDPI / 120 or 1
stage.scaleY = stage.scaleX

local input = Text.TextField.new()
input.x = 10
input.y = 10
input.type = Text.TextFieldType.INPUT
input.wordWrap = true
input.multiline = true
input.width = 240
input.height = 100
input.text = "Text for clipboard" 
input.border = true
input.borderColor = 0x000000
input.background = true
input.backgroundColor = 0xffffff
stage.addChild(input)

local clickTxt = Text.TextField.new()
clickTxt.autoSize = Text.TextFieldAutoSize.LEFT
clickTxt.x = 10
clickTxt.y = 120
clickTxt.width = 240
clickTxt.height = 100
clickTxt.text = "Click to copy" 
clickTxt.border = true
clickTxt.borderColor = 0x0000FF
clickTxt.background = true
clickTxt.backgroundColor = 0xf0f0ff
clickTxt.selectable = false
stage.addChild(clickTxt)

local clipboard = Lib.Media.Clipboard.generalClipboard

clickTxt.addEventListener(Events.MouseEvent.CLICK, 
function (e)
	clipboard.setData(Lib.Media.ClipboardFormats.TEXT_FORMAT, input.text, true)	
end, false, 0, false)

local paste = Text.TextField.new()
paste.x = 10
paste.y = 150
paste.wordWrap = true
paste.multiline = true
paste.width = 240
paste.height = 100 
paste.border = true
paste.borderColor = 0x000000
paste.background = true
paste.backgroundColor = 0xffffff
stage.addChild(paste)

local clickTxt2 = Text.TextField.new()
clickTxt2.autoSize = Text.TextFieldAutoSize.LEFT
clickTxt2.x = 10
clickTxt2.y = 260
clickTxt2.width = 240
clickTxt2.height = 100
clickTxt2.text = "Click to paste" 
clickTxt2.border = true
clickTxt2.borderColor = 0x0000FF
clickTxt2.background = true
clickTxt2.backgroundColor = 0xf0f0ff
clickTxt2.selectable = false
stage.addChild(clickTxt2)

clickTxt2.addEventListener(Events.MouseEvent.CLICK, 
function (e)
	if clipboard.hasFormat(Lib.Media.ClipboardFormats.TEXT_FORMAT) then
		paste.text = clipboard.getData(Lib.Media.ClipboardFormats.TEXT_FORMAT, nil)
	end
end, false, 0, false)