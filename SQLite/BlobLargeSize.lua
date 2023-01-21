-- BlobLargeSize.lua

connection = Lib.SQLight.Connection.new(":memory:")

-- create table
connection.request ([[CREATE TABLE IF NOT EXISTS TestBlob (
    fieldInt  INTEGER PRIMARY KEY NOT NULL,
    fieldBlob BLOB 
)]], nil)


--BLOB field should be not NULL or it will crash with error "cannot open value of type null"
--also we need to pre allocate blob field size before we can write image in chunks
imageBytes = Lib.Project.getBytes("/Bunnymark/assets/pirate.png")
print("Expected image size: "..imageBytes.length)

blobInfo = {zeroBlobSize = imageBytes.length} --zeroBlobSize - reserved object field name for blob field size initialization
connection.request ("INSERT INTO TestBlob (fieldInt, fieldBlob) VALUES (?, ?)", {1, blobInfo}) --pre allocate size

blob = connection.blobOpen("TestBlob", "fieldBlob", 1) 
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