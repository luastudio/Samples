-- FTS3.lua

connection = Lib.SQLight.Connection.new(":memory:")

--FTS3
--https://www.sqlite.org/fts3.html
connection.request ([[CREATE VIRTUAL TABLE mail USING fts3(subject, body)]], nil);

connection.request ([[INSERT INTO mail(docid, subject, body) VALUES
  (1, 'software feedback', 'found it too slow'),
  (2, 'software feedback', 'no feedback'),
  (3, 'slow lunch order',  'was a software problem')]], nil);

print("Query 1")
resultSet = connection.request([[SELECT * FROM mail WHERE subject MATCH 'software']], nil) -- Selects rows 1 and 2
while resultSet.hasNext() do 
	row = resultSet.next()
    Lib.Sys.trace(row)
end

print("Query 2")
resultSet = connection.request([[SELECT * FROM mail WHERE body MATCH 'feedback']], nil) -- Selects row 2
while resultSet.hasNext() do 
	row = resultSet.next()
    Lib.Sys.trace(row)
end

print("Query 3")
resultSet = connection.request([[SELECT * FROM mail WHERE mail MATCH 'software']], nil) -- Selects rows 1, 2 and 3
while resultSet.hasNext() do 
	row = resultSet.next()
    Lib.Sys.trace(row)
end

print("Query 4")
resultSet = connection.request([[SELECT * FROM mail WHERE mail MATCH 'slow']], nil) -- Selects rows 1 and 3
while resultSet.hasNext() do 
	row = resultSet.next()
    Lib.Sys.trace(row)
end

connection.close()