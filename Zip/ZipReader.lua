-- ZipReader.lua

bytes = Lib.Project.getBytes("/Zip/assets/sample.zip")
print("Zip file size: "..bytes.length)
bytesInput = Lib.Sys.IO.BytesInput.new(bytes, 0, bytes.length)

entries = Lib.Sys.Zip.Reader.readZip( bytesInput )
bytesInput.close()

function split(str, pat)
	local t = {}  
	local len = #str
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
		if last_end > len then table.insert(t,"") end --include if last
	end
	if last_end <= len then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

for i=1,#entries,1 do
	local fileName = entries[i].fileName
	local firstChar = string.sub(fileName, 1, 1)
	if firstChar ~= "/" and firstChar ~= "\\" and #split(fileName, '%.%.')<=1 then
		local dirs = split(fileName, "[/\\]")
		local file = dirs[#dirs]
		table.remove(dirs, #dirs)
		local path = ""
		for i=1,#dirs,1 do
			path = path..dirs[i].."/"
		end
		if file == "" then --folder
			print("Folder: "..path)
		else -- file
			print("File: "..path..file)
			local dataBytes = Lib.Sys.Zip.Reader.unzip(entries[i])
			local byteArray = Lib.Media.Utils.ByteArray.fromBytes(dataBytes)
			print("length: " .. byteArray.length)
			print("content: "..byteArray.asString())
		end
	end
end