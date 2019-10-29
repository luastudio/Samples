-- Utf8.lua

Utf8 = Lib.Sys.Utf8

local s = "ὕαλον"
print(s)
print(string.len(s))
print(Lib.Str.length(s))

print(Utf8.validate(s))
print(Utf8.compare(s, "ὕαλον"))
print(Utf8.length(s))

Utf8.iter(s, function(char)
    print(char)
end)

print(Utf8.charCodeAt(s, 0))
print(Utf8.sub(s, 1, 2))

local utf8 = Lib.Sys.Utf8.new(nil)
utf8.addChar(8021)
utf8.addChar(955)
print(utf8.toString())