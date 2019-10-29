-- Json.lua

json = Lib.Sys.Json.parse([[{
    "glossary": {
        "title": "example glossary",
		"GlossDiv": {
            "title": "S",
			"GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
					"SortAs": "SGML",
					"GlossTerm": "Standard Generalized Markup Language",
					"Acronym": "SGML",
					"Abbrev": "ISO 8879:1986",
					"GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
						"GlossSeeAlso": ["GML", "XML"]
                    },
					"GlossSee": "markup"
                }
            }
        }
    }
}]])

fields = Lib.Reflect.fields(json)
Lib.Sys.trace(fields)
if #fields > 0 then Lib.Sys.trace(Lib.Reflect.fields(json[fields[1]])) end

print(json.glossary.title)
print(json.glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[1])
print(Lib.Sys.Json.stringify( json, nil, ' ' ))
