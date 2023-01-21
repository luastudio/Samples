-- BasicTable.lua

connection = Lib.SQLight.Connection.new(":memory:")

-- create table
connection.request ([[
CREATE TABLE IF NOT EXISTS Test (
    field1 INTEGER PRIMARY KEY NOT NULL,
    field2 TEXT,
    field3 BLOB 
)
]], nil)

-- insert test data
connection.request ("INSERT INTO Test (field1, field2) VALUES (?, ?)", {1, "test1 utf8:ὕαλον"})
connection.request ("INSERT INTO Test (field1, field2) VALUES (?, ?)", {2, "test2"})

-- read data from table
resultSet = connection.request ("SELECT field1, field2 FROM Test", nil)
while resultSet.hasNext() do
	row = resultSet.next()
	print(row.field1.." "..row.field2)
end

connection.close()