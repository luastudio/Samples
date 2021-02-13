-- EReg.lua

ereg = Lib.Sys.EReg.new("('(?:\\\\.|[^\\\\\\n'])*')", "")
text = "123'test1' 456 'test2'end"
len = string.len(text)
if ereg.matchSub(text, 0, len) then
    pos = ereg.matchedPos();
    value = ereg.matched(0);
    print(pos.pos.." "..pos.len)
	print(value)

	if ereg.matchSub(text, pos.pos + pos.len, len - (pos.pos + pos.len)) then
		print(ereg.matched(0))
    end
end