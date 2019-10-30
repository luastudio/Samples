-- SimpleText.lua

Display = Lib.Media.Display
Text = Lib.Media.Text
Capabilities = Lib.Media.Capabilities
stage = Display.stage

if type(jit) == 'table' then
  bit32 = bit
end

stage.scaleX = Capabilities.screenDPI > 120 and Capabilities.screenDPI / 120 or 1
stage.scaleY = stage.scaleX

gfx = stage.graphics
gfx.beginFill(0x000000, 1.0)
gfx.drawRect(120, 0, 120, 320)

for side = 0, 1, 1 do
    local col_a = 0xFF + side * 0xFF
    local col_b = 0xFFFFFF
	local col =  col_a - math.floor(col_a/col_b)*col_b--modulo

	local text = Text.TextField.new()
	text.x = 10 + side * 120
	text.y = 10
	text.textColor = col
	text.width = 100
	text.wordWrap = true
	text.text = "Hello !\nFrom this multi-line, wordwrapped"..(side==1 and ", outlined" or "")..", centred text box!"

	local fmt = Text.TextFormat.new('_sans', 12, 0x969696, nil, nil, nil)
	fmt.align = Text.TextFormatAlign.CENTER
    fmt.outline = side==1 and 0.3 or 0
    --fmt.outlineFlags = bit32.bor(Text.TextFormat.OUTLINE_END_SQUARE, Text.TextFormat.OUTLINE_EDGE_MITER) --OUTLINE_END_SQUARE, OUTLINE_EDGE_BEVEL, OUTLINE_EDGE_MITER
    --fmt.outlineMiterLimit = 0.5
	text.setTextFormat(fmt, 0, text.textLength) 
	
    fmt = Text.TextFormat.new('_sans', 12, 0x660000, nil, nil, nil)
    text.setTextFormat(fmt, 6, 12)

    fmt.color = 0xFF00FF
    text.setTextFormat(fmt, 18, 19)

	stage.addChild(text)

	-- HTML text fields
	local text = Text.TextField.new()
	text.x = 10 + side * 120
	text.y = 120
	text.textColor = col
	text.htmlText = "<font size='16'>Hello !</font>"
	stage.addChild(text)

	local text = Text.TextField.new()
	text.x = 10 + side * 120
	text.y = 170
	text.textColor = col
	text.htmlText = "<font size='24'>Hello !</font>"
	stage.addChild(text)

	local text = Text.TextField.new()
	text.x = 10 + side * 120
	text.y = 220
	text.textColor = col
	text.htmlText = "<font size='36'>Hello !</font>"
	stage.addChild(text)
end

local input = Text.TextField.new()
input.x = 20 + 2 * 120
input.y = 10
input.type = Text.TextFieldType.INPUT
input.wordWrap = true
input.multiline = true
input.width = 240
input.height = 300
input.htmlText = "Input <u>underline</u> <sup>superscript</sup> <s>strikethrough</s> <sub>subscript</sub> <b><i>bold italic</i></b> <font size='24' color='#0000FF' face='_sans'>blue 24</font>" 
input.border = true
input.borderColor = 0x000000
input.background = true
input.backgroundColor = 0xf0f0ff
input.softKeyboard = Lib.Media.Text.SoftKeyboardType.DEFAULT
stage.addChild(input)
print(input.htmlText)

textRuns = input.getTextRuns(0, 7)
for i = 1, #textRuns, 1 do
    textRun = textRuns[i]
    textFormat = textRun.textFormat
    print("begin index: "..textRun.beginIndex.." end index: "..textRun.endIndex.." underline: "..(textFormat.underline and "true" or "false"))
end

stage.addEventListener(Lib.Media.Events.FocusEvent.MOUSE_FOCUS_CHANGE, 
function(e)
    Lib.Sys.trace(e.relatedObject)
end, false, 0, false)

stage.addEventListener(Lib.Media.Events.SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, 
function(e)
	print("SOFT KEYBOARD ACTIVATE "..stage.softKeyboardRect.height)
end, false, 0, false)

stage.addEventListener(Lib.Media.Events.SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, function(e)
	print("SOFT KEYBOARD DEACTIVATE "..stage.softKeyboardRect.height)
end, false, 0, false)