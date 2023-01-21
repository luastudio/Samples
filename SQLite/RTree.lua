-- RTree.lua

connection = Lib.SQLight.Connection.new(":memory:")

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