--author:bbbirder
local ccbrige = nil
local pickClassName = nil
switch(device.platform){
	["android"] = function()
		ccbrige = require("cocos.cocos2d.luaj")
		pickClassName = function(clsname)
			return clsname
		end
	end,
	["ios"] = function()
		ccbrige = require("cocos.cocos2d.luaoc")
		pickClassName = function(clsname)
			local _subStrings = clsname:split("/")
			return _subStrings[#_subStrings]
		end
	end
}

LuaBridge = setmetatable({},{
	__index = function(t,k)
		print(pickClassName(k),"classname")
		return setmetatable({clsname = pickClassName(k)},{
			__index = function(t,k)
				print("getmethod:",t.clsname,k)
				local function _method( ... )
					print("invoke:",t.clsname,k,select(1,...))
					local _inst = ...
					local _params = {select(2,...)}
					local _paramsOut = {}
					if device.platform == "android" then
						_paramsOut = _params
					else
						for i=2,select("#",...) do
							_paramsOut[tostring(i-1)] = _params[i-1]
						end
					end
					local ok,ret = ccbrige.callStaticMethod(t.clsname,k,_paramsOut)
					print(ok,ret)
					return ret,ok
				end
				return _method
			end
		})
	end,
})
