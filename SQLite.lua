-- SQLite.lua

connection = Lib.SQLight.Connection.new(":memory:")

resultSet = connection.request ([[SELECT sqlite_version() as version]], nil)
while resultSet.hasNext() do
	row = resultSet.next()
	print('SQLite version: '..row.version)
end

connection.request ([[CREATE TABLE IF NOT EXISTS Test (
    field1 INTEGER PRIMARY KEY NOT NULL,
    field2 TEXT,
    field3 BLOB 
)]], nil);

connection.request ("INSERT INTO Test (field1, field2) VALUES (?, ?)", {1, "test1 utf8:ὕαλον"})
connection.request ("INSERT INTO Test (field1, field2) VALUES (?, ?)", {2, "test2"})

resultSet = connection.request ("SELECT field1, field2 FROM Test", nil)
while resultSet.hasNext() do
	row = resultSet.next()
	print(row.field1.." "..row.field2)
end

--REGEXP
--https://sqlite.org/src/file?name=ext/misc/regexp.c&ci=trunk
resultSet = connection.request ("SELECT field1, field2 FROM Test WHERE field2 REGEXP '.*ὕαλον+'", nil)
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



connection = Lib.SQLight.Connection.new(":memory:")

--math functions
resultSet = connection.request ([[select pi() as pi, floor(1.8) as floor, ceil(1.3) as ceil, sqrt(4) as sqrt, mod(7,2) as mod]], nil)
while resultSet.hasNext() do
	row = resultSet.next()
	print('Math: pi(): '..row.pi..' floor(1.8): '..row.floor..' ceil(1.3): '..row.ceil..' sqrt(4): '..row.sqrt..' mod(7,2): '..row.mod)
end

--json
resultSet = connection.request('SELECT json_object(\'ex\',\'[52,3.14159]\') jobject, json_array_length(\'[1,2,3,4]\') jlen, json_insert(\'[1,[2,3],4]\',\'$[1][#]\',99) jinsert', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

--uuid
--https://sqlite.org/src/file?name=ext/misc/uuid.c&ci=trunk
resultSet = connection.request('SELECT uuid(), uuid_str(uuid()), uuid_blob(uuid())', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

--totype
--https://sqlite.org/src/file?name=ext/misc/totype.c&ci=trunk
resultSet = connection.request('SELECT tointeger("3"), toreal("7.2"), toreal("error")', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

--eval
--https://sqlite.org/src/file?name=ext/misc/eval.c&ci=trunk
resultSet = connection.request('SELECT eval("select 1,2,eval(""select 3,4"",""|"")", ",")', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

--sha3
--https://sqlite.org/src/file?name=ext/misc/shathree.c&ci=trunk
--SIZE is included it must be one of the integers 224, 256, 384, or 512
resultSet = connection.request('SELECT sha3(10, 224), sha3_query("select 10")', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

--R*Tree
--https://sqlite.org/rtree.html
connection.request ([[CREATE VIRTUAL TABLE demo_index USING rtree(
   id,              -- Integer primary key
   minX, maxX,      -- Minimum and maximum X coordinate
   minY, maxY       -- Minimum and maximum Y coordinate
)]], nil);


connection.request ([[INSERT INTO demo_index VALUES
  (28215, -80.781227, -80.604706, 35.208813, 35.297367),
  (28216, -80.957283, -80.840599, 35.235920, 35.367825),
  (28217, -80.960869, -80.869431, 35.133682, 35.208233),
  (28226, -80.878983, -80.778275, 35.060287, 35.154446),
  (28227, -80.745544, -80.555382, 35.130215, 35.236916),
  (28244, -80.844208, -80.841988, 35.223728, 35.225471),
  (28262, -80.809074, -80.682938, 35.276207, 35.377747),
  (28269, -80.851471, -80.735718, 35.272560, 35.407925),
  (28270, -80.794983, -80.728966, 35.059872, 35.161823),
  (28273, -80.994766, -80.875259, 35.074734, 35.172836),
  (28277, -80.876793, -80.767586, 35.001709, 35.101063),
  (28278, -81.058029, -80.956375, 35.044701, 35.223812),
  (28280, -80.844208, -80.841972, 35.225468, 35.227203),
  (28282, -80.846382, -80.844193, 35.223972, 35.225655)]], nil);

resultSet = connection.request([[SELECT A.id FROM demo_index AS A, demo_index AS B
 WHERE A.maxX>=B.minX AND A.minX<=B.maxX
   AND A.maxY>=B.minY AND A.minY<=B.maxY
   AND B.id=28269]], nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

connection.close()