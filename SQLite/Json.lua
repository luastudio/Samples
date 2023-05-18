-- Json.lua

connection = Lib.SQLight.Connection.new(":memory:")

--json
resultSet = connection.request('SELECT json_object(\'ex\',\'[52,3.14159]\') jobject, json_array_length(\'[1,2,3,4]\') jlen, json_insert(\'[1,[2,3],4]\',\'$[1][#]\',99) jinsert', nil)
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row)
end

--json5
json5 = [[{
  // comments
  /* multiline
     comments */
  unquoted: 'and you can quote me on that',
  singleQuotes: 'I can use "double quotes" here',
  lineBreaks: "Look, Mom! \
No \\n's!",
  hexadecimal: 0xdecaf,
  leadingDecimalPoint: .8675309, andTrailing: 8675309.,
  positiveSign: +1,
  trailingComma: 'in objects', andIn: ['arrays',],
  "backwardsCompatible": "with JSON",
}]]

resultSet = connection.request("SELECT json_valid(?) v1, json(?) v2, json_extract(?, '$.hexadecimal') v3", {json5, json5, json5})
while resultSet.hasNext() do
	row = resultSet.next()
    Lib.Sys.trace(row.v1)
    Lib.Sys.trace(row.v2)
    Lib.Sys.trace(row.v3)
end


connection.close()