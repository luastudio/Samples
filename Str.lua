-- Str.lua

str = "word1|word2|word3"
strt = Lib.Str.split(str, "|")
Lib.Sys.trace(strt)
print(Lib.Str.join(strt, "|"))
print(Lib.Str.substr(str,0,5))

encode = Lib.Str.urlEncode("test1 test2")
print(encode)
print(Lib.Str.urlDecode(encode))

if(Lib.Str.startsWith(str, "word1"))then print("yes1") else print("no1") end
if(Lib.Str.endsWith(str, "word3"))then print("yes3") else print("no3") end

print(Lib.Str.replace(str, "word", "x"))
print(Lib.Str.hex(15, 7))
print(Lib.Str.string(Lib.Project))

print(Lib.Str.parseInt("88"))
print(Lib.Str.parseInt("?88"))

print(Lib.Str.parseFloat("1.7"))
print(Lib.Str.parseFloat("?1.7"))

url = Lib.Str.parseUrl("https://www.w3.org/test.php?par1=val1&par2=val2")
Lib.Sys.trace(url)