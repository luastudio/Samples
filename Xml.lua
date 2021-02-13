-- Xml.lua

function getNodeTypeName(nodeType)
	if nodeType == Lib.Sys.Xml.XmlType.Element then return "Element"
    elseif nodeType == Lib.Sys.Xml.XmlType.PCData then return "PCData"
    elseif nodeType == Lib.Sys.Xml.XmlType.CData then return "CData"
    elseif nodeType == Lib.Sys.Xml.XmlType.Comment then return "Comment"
    elseif nodeType == Lib.Sys.Xml.XmlType.DocType then return "DocType"
    elseif nodeType == Lib.Sys.Xml.XmlType.ProcessingInstruction then return "ProcessingInstruction"
    elseif nodeType == Lib.Sys.Xml.XmlType.Document then return "Document"
    else return "Unknown" end
end

xml = Lib.Sys.Xml.parse("<html><body><a href='#test'>test1</a><div><![CDATA[test2]]></div></body></html>")
html = xml.firstElement()
print(html.nodeName.." "..getNodeTypeName(html.nodeType))
body = html.elements().next()
print(body.nodeName.." "..getNodeTypeName(html.nodeType))
bodyElements = body.elements()
while bodyElements.hasNext() do
    element = bodyElements.next()
    print(element.nodeName.." "..getNodeTypeName(element.nodeType))
    if element.exists("href") then
		attributes = element.attributes()
		while attributes.hasNext() do
			print(attributes.next())
		end
    else
		element.set("width", "10")
    end 
    children = element.iterator()
    while children.hasNext() do
    	child = children.next()
        print(child.nodeValue.." "..getNodeTypeName(child.nodeType))
	end
end

body.addChild(Lib.Sys.Xml.createElement("br"))

xmlText = xml.toString()
print(xmlText)