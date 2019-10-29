-- Main.lua

Text = Lib.Media.Text
Font = Text.Font

font = Font.new("Purisa", Text.FontStyle.REGULAR, Text.FontType.EMBEDDED)
bytes = Lib.Project.getBytes("/Font/assets/Purisa.ttf")

nativeFontData = Font.loadBytes(bytes)
print("has kerning: "..(nativeFontData.has_kerning and "yes" or "not"))
print("has glyph names: "..(nativeFontData.has_glyph_names and "yes" or "not"))
print("is italic: "..(nativeFontData.is_italic and "yes" or "not"))
print("is bold: "..(nativeFontData.is_bold and "yes" or "not"))
print("num glyphs: "..nativeFontData.num_glyphs)
print("family name: "..nativeFontData.family_name)
print("style name: "..nativeFontData.style_name)
print("em size: "..nativeFontData.em_size)
print("ascend: "..nativeFontData.ascend)
print("descend: "..nativeFontData.descend)
print("height: "..nativeFontData.height)
if #nativeFontData.glyphs >= 65 then
	print("char code: "..nativeFontData.glyphs[65].char_code)
	print("advance: "..nativeFontData.glyphs[65].advance)
	print("min_x: "..nativeFontData.glyphs[65].min_x)
	print("max_x: "..nativeFontData.glyphs[65].max_x)
	print("min_y: "..nativeFontData.glyphs[65].min_y)
	print("max_y: "..nativeFontData.glyphs[65].max_y)
	print("points count: "..#nativeFontData.glyphs[65].points)--integer values array
end
if nativeFontData.has_kerning then
	print("kernings count: "..#nativeFontData.kerning)-- array of objects with fields: left_glyph, right_glyph, x, y
end

Font.registerFontData(font, bytes)
bytes = nil
fonts = Font.enumerateFonts(false)
for i=1, #fonts, 1 do
	print(fonts[i].toString())
end

textFormat = Text.TextFormat.new("Purisa", 24, 0, false, false, false)
textField = Text.TextField.new()
textField.defaultTextFormat = textFormat
textField.border = true
textField.text = "Test"

Lib.Media.Display.stage.addChild(textField)

--self destruct
i = 3
print("Self destruct in:")
timer = Lib.Media.Utils.Timer.new(1000,4)
timer.addEventListener(Lib.Media.Events.TimerEvent.TIMER, function(e)
    print(i)
    if i == 0 then
		Lib.Media.Display.stage.removeChild(textField)
		textField = nil
		textFormat = nil
		Lib.Media.Text.Font.unregisterFontData(font)
		collectgarbage("collect")
	end
    i = i - 1  
end, false, 0 ,false)
timer.start()