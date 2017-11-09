--author:bbbirder
WebSocket = class("WebSocket")

function WebSocket:ctor(uri)
	--echo.websocket.org
	self.ws = cc.WebSocket:create(uri)
	self.listeners = {}

	local ws = self.ws
	
	ws:registerScriptHandler(function()
		return self.listeners["connect"]
			or self.listeners["connect"](closeEvent)
	end,0)

	ws:registerScriptHandler(function(msg)
	    print("recv:",msg)
		return self.listeners["close"]
			or self.listeners["close"](closeEvent)
	end,1)

	ws:registerScriptHandler(function(closeEvent)
		return self.listeners["close"]
			or self.listeners["close"](closeEvent)
	end,2)

	ws:registerScriptHandler(function(errEvent)
		return self.listeners["error"]
			or self.listeners["error"](closeEvent)
	end,3)
end

function WebSocket:on(eventName,callback)
	ws.listeners[eventName] = callback
end

function WebSocket:close()
	self.ws:close()
end

function WebSocket:send(msg)
	self.ws:sendString(msg)
end
--获取网路连接状态
function WebSocket:getState()
	return ({
		[0] = "connecting",
		[1] = "connected",
		[2] = "closing",
		[3] = "closed",
	})[self.ws:getReadyState()] or "unknown"
end
