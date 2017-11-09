--author:bbbirder
local utils = import ".DebugUtils"

LuaDoctor = LuaDoctor or {}
local ws = nil
function initClient()
	ws = cc.WebSocket:create(DEBUG_HOST)
	ws:registerScriptHandler(function()
		print("open")
	end,0)
	ws:registerScriptHandler(function(msg)
		local msg = luajson.decode(msg)
		switch(msg.cmd){
			["lua_string_req"] = function()
				ws:sendString(luajson.encode{
					cmd = "lua_string_resp",
					tag = msg.tag,
					result = loadstring(msg.str)(),
				})
			end,
		}
	end,1)
	ws:registerScriptHandler(function()
		print("close")
		initClient()
	end,2)
	ws:registerScriptHandler(function()
		print("error")
		-- initClient()
	end,3)
end
initClient()

local _print = print
LuaDoctor._print = _print
print = function(...)
	_print(...)
	LuaDoctor.Message(...)
end

function LuaDoctor.Error(...)
	-- local out = io.open("src/err.log","a")
 --    out:write("[ERR]")
 --    out:write(msg)
 --    out:close()
	if ws:getReadyState()~=1 then return end
	local args = {...}
	for i=1,select("#",...) do
		args[i] = tostring(args[i])
	end
	ws:sendString(luajson.encode({
		cmd = "lua_log",
		log = table.concat(args,"\t"),
		stack = luajson.encode(utils.traceback(3)),
		iserr = true
	}))
end

function LuaDoctor.Message(...)
	if ws:getReadyState()~=1 then return end
	local args = {...}
	for i=1,select("#",...) do
		args[i] = tostring(args[i])
	end
	ws:sendString(luajson.encode({
		cmd = "lua_log",
		log = table.concat(args,"\t"),
		stack = luajson.encode(utils.traceback(3)),
		ori = debug.traceback("",3),
		iserr = false
	}))
	-- local out = io.open("src/err.log","a")
 --    out:write("[MSG]"..debug.traceback(1):split("\n")[1])
 --    for k,v in pairs({...}) do
 --    	out:write(tostring(v))
 --    	out:write("\t")
 --    end
 --    out:write("\n")
 --    out:close()
end

function LuaDoctor.BreakPoint()
    cc.Director:getInstance():getScheduler():setTimeScale(0)
    ws:sendString(luajson.encode2{
    	cmd="lua_bp",
    	scoop=utils.dump_env(2)
    })
    LuaDoctor.__CONT = false
    while not LuaDoctor.__CONT do
        cc.Director:getInstance():mainLoop()
    end
    cc.Director:getInstance():getScheduler():setTimeScale(1)
end

