-- BlobSmallSize.lua
--direct blob update/select (use for small size data)

connection = Lib.SQLight.Connection.new(":memory:")

-- create table
connection.request ([[CREATE TABLE IF NOT EXISTS TestBlob (
    fieldInt  INTEGER PRIMARY KEY NOT NULL,
    fieldBlob BLOB 
)]], nil)

imageBytes = Lib.Project.getBytes("/Bunnymark/assets/wabbit_alpha.png")

connection.request ("INSERT INTO TestBlob (fieldInt, fieldBlob) VALUES (?, ?)", {1, imageBytes.getData()})

resultSet = connection.request ("SELECT fieldBlob FROM TestBlob WHERE fieldInt=?", {1})
while resultSet.hasNext() do
	row = resultSet.next()
    imageBlobBytes = Lib.Sys.IO.Bytes.ofData(row.fieldBlob)
end

connection.close()

--Display
Display = Lib.Media.Display
stage = Display.stage
BitmapData = Display.BitmapData
Bitmap = Display.Bitmap

data = BitmapData.loadFromBytes(Lib.Media.Utils.ByteArray.fromBytes(imageBlobBytes), nil)
bmp = Bitmap.new(data, Display.PixelSnapping.AUTO, false)
bmp.x = 10
bmp.y = 10
stage.addChild(bmp)