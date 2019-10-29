-- WebServer.lua

root = Lib.Media.FileSystem.File.applicationStorageDirectory.nativePath
serverSideLuaFileName = "webservercheck.lua"
path = root.."/"..serverSideLuaFileName

Lib.Sys.IO.File.saveContent(path, 
[[--web response
    Request = Lib.Web.Request
    Response = Lib.Web.Response

    Response.addHeader("Content-Type", "text/html")

    Response.writeString("<html><body>")

    Response.writeString(Request.requestType.."<br/>")
    Response.writeString(Request.url.."<br/>")

    Response.writeString("Headers:<br/>")
    headers = Lib.Reflect.fields(Request.headers)
    for k, v in pairs(headers) do
    Response.writeString(k.." "..v.."="..Lib.Reflect.field(Request.headers, v))
    Response.writeString("<br/>")
    end

    Response.writeString("QueryString:<br/>")
    queryStringFields = Lib.Reflect.fields(Request.queryString)
    for k, v in pairs(queryStringFields) do
    Response.writeString(k.." "..v.."="..Lib.Reflect.field(Request.queryString, v))
    Response.writeString("<br/>")
    end

    Response.writeString("Form:<br/>")
    formFields = Lib.Reflect.fields(Request.form)
    for k, v in pairs(formFields) do
    Response.writeString(k.." "..v.."="..Lib.Reflect.field(Request.form, v))
    Response.writeString("<br/>")
    end

	Response.writeString("</body></html>")
]])
if Lib.Media.System.systemName() == "ios" then
	Lib.Media.FileSystem.File.new(path).preventBackup = true
end

function webTrack(url, code, status)
	print(url.." "..code.." "..status)
end
Lib.WebServer.start("localhost", 2001, root, webTrack)

function frameCheck(e)
	if Lib.WebServer.isStarted("localhost", 2001) then
		print("Server successfully started")
		Lib.Media.Display.stage.removeEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameCheck, false)
		local url = "http://localhost:2001/"..serverSideLuaFileName.."?test=true"
		if Lib.WebView.isSupported() then
			Lib.WebView.open(url, nil, true, nil, nil)
		else
			Lib.Media.System.getURL(Lib.Media.Net.URLRequest.new(url), "_blank")
		end
	end
end

--wait for server to start
Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ENTER_FRAME, frameCheck, false, 0, false)

if Lib.Media.System.systemName() == "ios" then
	Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.DEACTIVATE, 
	function (e)
		print("DEACTIVATED")
		if Lib.WebServer.isStarted("localhost", 2001) then
			Lib.WebServer.stop("localhost", 2001)
		end
	end, false, 0, false)

	Lib.Media.Display.stage.addEventListener(Lib.Media.Events.Event.ACTIVATE, 
	function (e)
		print("ACTIVATED")
		if not Lib.WebServer.isStarted("localhost", 2001) then
			Lib.WebServer.start("localhost", 2001, root, webTrack)
		end
	end, false, 0, false)
end