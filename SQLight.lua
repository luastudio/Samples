-- SQLight.lua

connection = Lib.SQLight.Connection.new(":memory:")

connection.request ([[CREATE TABLE IF NOT EXISTS Test (
    field1 INTEGER PRIMARY KEY NOT NULL,
    field2 TEXT,
    field3 BLOB 
)]], nil);

connection.request ("INSERT INTO Test (field1, field2) VALUES (?, ?)", {1, "test1"})
connection.request ("INSERT INTO Test (field1, field2) VALUES (?, ?)", {2, "test2"})

resultSet = connection.request ("SELECT field1, field2 FROM Test", nil)
while resultSet.hasNext() do
	row = resultSet.next()
	print(row.field1.." "..row.field2)
end


--direct blob update/select (use for small size data)

imageBytes = Lib.Project.getBytes("/Bunnymark/assets/wabbit_alpha.png")
connection.request ("UPDATE Test SET field3 = ? WHERE field1=?", {imageBytes.getData(), 1})
resultSet = connection.request ("SELECT field3 FROM Test WHERE field1=?", {1})
while resultSet.hasNext() do
	row = resultSet.next()
    imageBlobBytes2 = Lib.Sys.IO.Bytes.ofData(row.field3)
end

--BLOB field should be not NULL or it will crash with error "cannot open value of type null"
--also we need to pre allocate blob field size before we can write image in chunks
imageBytes = Lib.Project.getBytes("/Bunnymark/assets/pirate.png")
print("Expected image size: "..imageBytes.length)

blobInfo = {zeroBlobSize = imageBytes.length} --zeroBlobSize - reserved object field name for blob field size initialization
connection.request ("UPDATE Test SET field3 = ? WHERE field1=?", {blobInfo, 2}) --pre allocate size

blob = connection.blobOpen("Test", "field3", 2) 
print("BLOB size: "..blob.size())

--write
pos = 0
chunkSize = 100 --100 bytes limit
while pos < imageBytes.length do
  if pos + chunkSize > imageBytes.length then chunkSize = imageBytes.length - pos end
  blob.write(imageBytes, chunkSize, pos, pos)
  pos = pos + chunkSize
end

--read
pos = 0
chunkSize = 100 --100 bytes limit
imageBlobBytes = Lib.Sys.IO.Bytes.alloc(imageBytes.length)
while pos < imageBytes.length do
  if pos + chunkSize > imageBytes.length then chunkSize = imageBytes.length - pos end
  blob.read(imageBlobBytes, chunkSize, pos, pos)
  pos = pos + chunkSize
end

blob.close()

connection.close()


--Display
Display = Lib.Media.Display
stage = Display.stage
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap

data = BitmapData.loadFromBytes(Lib.Media.Utils.ByteArray.fromBytes(imageBlobBytes), nil)
bmp = Bitmap.new(data, Display.PixelSnapping.AUTO, false)
bmp.x = 50
bmp.y = 50
stage.addChild(bmp)

data = BitmapData.loadFromBytes(Lib.Media.Utils.ByteArray.fromBytes(imageBlobBytes2), nil)
bmp = Bitmap.new(data, Display.PixelSnapping.AUTO, false)
bmp.x = 10
bmp.y = 10
stage.addChild(bmp)