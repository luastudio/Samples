-- Json.lua

connection = Lib.SQLight.Connection.new(":memory:")

--json
resultSet = connection.request('SELECT json_object(\'ex\',\'[52,3.14159]\') jobject, json_array_length(\'[1,2,3,4]\') jlen, json_insert(\'[1,[2,3],4]\',\'$[1][#]\',99) jinsert', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

connection.close()