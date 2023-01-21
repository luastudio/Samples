-- UUID.lua

connection = Lib.SQLight.Connection.new(":memory:")

--uuid
--https://sqlite.org/src/file?name=ext/misc/uuid.c&ci=trunk
resultSet = connection.request('SELECT uuid(), uuid_str(uuid()), uuid_blob(uuid())', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

connection.close()