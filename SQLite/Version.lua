-- Version.lua

connection = Lib.SQLight.Connection.new(":memory:")

resultSet = connection.request ("/SQLite/Version.sql", nil)
while resultSet.hasNext() do
	row = resultSet.next()
	print('SQLite version: '..row.version)
end

connection.close()