--author:bbbirder

local HTTP = class("HTTP")

function HTTP:Request(method,url,callback,failCallback)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open(method, url)
	local function onResponse()
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	    	-- xhr.response = string.gsub(xhr.response,"\\u(%w%w%w%w)",function(s)
	    	-- 	print "find"
	    	-- 	return "\\u{"..s.."}"
	    	-- end)
	    	if callback then
	    		callback(xhr.response)
	    	end
	    else
	    	if failCallback then failCallback() end
		    print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
	    end
	end
	xhr:registerScriptHandler(onResponse)
	xhr:send()
end



return HTTP