-- Regexp.lua
-- https://sqlite.org/src/file?name=ext/misc/regexp.c&ci=trunk

connection = Lib.SQLight.Connection.new(":memory:")

resultSet = connection.request ("SELECT '--- ὕαλον ---' as test WHERE test REGEXP '.*ὕαλον+'", nil)
while resultSet.hasNext() do
	row = resultSet.next()
	print(row.test)
end

connection.close()