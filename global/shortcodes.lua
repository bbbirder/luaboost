--author:bbbirder

--[[
	此模块用于简化CS相关代码。
	makeMutable:
		由于XLUA导出配置，CS对象push入lua环境后，不能自定义字段、
		不能访问不存在字段。使用此方法可以返回一个自由访问的代理
		对象。
		参数：
			isdeep 用于指示子字段是否也可自由访问
		例子：
			local luaobj = makeMutable(CS.MyMono.Instance.gameObject)
			luaobj.nickname = "modified in lua env" --nickname变得有值
			luaobj.name = "new go name"             --gameObject名字被修改
			luaobj:SetActive(false)                 --与原CS对象效果一样

	FindObject:
		从根节点获取子节点中的某个Component实例。
		参数：
			三个递归参数分表表示：根节点、子节点路径、组件名称。传空表示跳过。
		例子：
			local txt = FindObject(myNode) "Btn/Label" "UILabel" .text
			local act = FindObject(myNode) "Btn/Label" ()        .activeSelf
	csarr:
		遍历一个来自CS的数组或List对象,每步返回下标和对应成员，下标从0开始。
		如果参数是transfrom,则遍历直属子物体。
		for i,v in csarr(go) do
			v:SetActive(false)
		end
]]
local GameObject = CS.UnityEngine.GameObject

--freely modify obj pushed from cs
function makeMutable(csobj,isdeep)
	if type(csobj)~="userdata" then return csobj end

	return setmetatable({__ref=csobj},{
		__index    = function(t,k)
			function __getter(k) return csobj[k] end
			local b,r = pcall(__getter,k)
			r = ({
				[true] = isdeep and makeMutable(r,true) or r,
				[false]= nil,
			})[not not b]
			return type(r)=="function" 
			and    function(_,...) return r(csobj,...) end 
			or     r
		end,
		__newindex = function(t,k,v)
			function __setter(k,v) csobj[k] = v end
			return pcall(__setter,k,v) or rawset(t,k,v)
		end
	})
end

function FindGameObject(go,...)
	for _,v in pairs({...}) do
		go = go.transform[({
			string="Find",
			number="GetChild",
		})[type(v)]](go.transform,v)
	end
	return go.gameObject
end

-- --FindObject (go) (childPath) (Component)
-- local eventnodes = {}
-- --Deprecated, FindObject2 is better
-- function FindObject(go)
-- 	go = go.transform
-- 	return function(path)
-- 		local _type = type(path)
-- 		assert(_type~="number" or path//1==path)
-- 		local _method = ({
-- 			number = "GetChild",
-- 			string = "Find",
-- 		})    [_type]
-- 		go = path and go[_method](go,path).gameObject or go.gameObject
-- 		return function(name)
-- 			if not name then return go end
-- 			local comp =name=="UIEvent" 
-- 					and CS.UIEventListener.Get(go) 
-- 					or  go:GetComponent(name)
-- 			if name=="UIEvent" then table.insert(eventnodes,go) end
-- 			return comp
-- 		end
-- 	end
-- end

-- function ReleaseAllEvents()
-- 	for k,v in pairs(eventnodes) do
-- 		CS.UIEventListener.Get(v).onClick = nil
-- 	end
-- 	toyManager = FindObject (mainfenv.Game3D) "GameManager" "ZWW_ToyManager" :ClearAllTimers()
-- 	if PrizeNode then
-- 		PrizeNode.Destroy()
-- 		PrizeNode = nil
-- 	end
-- end

-- the following will completely replace FindObject  in future
			local __LuaEventsHolder = {
				__uievents  = {},
				BindUIEvent = function(t,go,eventname,func)
					CS.UIEventListener.Get(go)[eventname] = func 
					t.__uievents[go] = t.__uievents[go] or {}
					t.__uievents[go][eventname] = t.__uievents[go][eventname] or true
					return 1
				end,
				BindTimerEvent = function(t,go,interval,isloop,func)
					go:SetTimer(interval,isloop,func)
					t.__uievents[go] = t.__uievents[go] or {}
					t.__uievents[go]["timer"] = t.__uievents[go]["timer"] or func
					return 1
				end,
				ReleaseAllEvents = function(t)
					for go,events in pairs(t.__uievents) do for en,func in pairs(events) do
						--released objects
						print(("auto release event: [%s] of [%s]"):format(tostring(en),tostring(go)))
						if tostring(go)=="<invalid c# object>" or tostring(go):sub(1,5)=="null:" then
							print"ignore released obj"
							goto continue 
						end
						if   en=="timer"
						then go:ClearTimer(func)
							 go:UpdateTimers()
						else CS.UIEventListener.Get(go)[en] = nil 
						end
						::continue::
					end end

					for k,v in pairs(Timer.__allTimers) do
						v:ClearAllTimers()
					end
					
					--FIX ME: release prize node
						if PrizeNode then
							PrizeNode.Destroy()
							PrizeNode = nil
						end
				end,
			}
			function ReleaseAllEvents()
				__LuaEventsHolder:ReleaseAllEvents()
			end
			function GetAnyEvent(go)
				
				local  __index = function(t,k)
					if k=="SetTimer" then return function(_,func,interval)--Depracated
						local comp = go:GetComponent"ShinobiMono"

						return comp
						   and __LuaEventsHolder:BindTimerEvent(comp,interval,true,func)
							or error("no ShinobiMono attacked on "..tostring(go).."!",2)
					end end
					return CS.UIEventListener.Get(go)[k]
				end

				local  __newindex = function(_,k,v) 
					return (false				or  k=="onTooltip"
						or  k=="onSubmit"		or  k=="onClick"
						or  k=="onDoubleClick"	or  k=="onHover"
						or  k=="onPress"		or  k=="onSelect"
						or  k=="onScroll"		or  k=="onDragStart"
						or  k=="onDrag"			or  k=="onDragOver"
						or  k=="onDragOut"		or  k=="onDragEnd"
						or  k=="onDrop"			or  k=="onKey"  )
						and __LuaEventsHolder:BindUIEvent(go,k,v) 
						or   error("no event named "..k.."!",2)
				end

				return setmetatable({},{
					__index    = __index,
					__newindex = __newindex,
				})
			end
			-- better than FindObject
			function FindObject(go)
				local _typ = type(go)
				if _typ~="table" and _typ~="userdata" then
					error("root go is not a valid type:".._typ,2)
				end
				if not go.transform then
					error("root go does not have transform",2)
				end

				
				go = go.transform

				return function(path)
					local _type = type(path)
					assert(_type~="number" or path//1==path)

					local _method = ({
						number = "GetChild",
						string = "Find",
					})   [_type]

					go = path 
					and  go[_method](go,path).gameObject
					or   go.gameObject

					return function(comp)
						return false
							or comp == "AnyEvent"
						   and GetAnyEvent(go)
							or comp
						   and go:GetComponent(comp)
							or go
					end

				end

			end
			
--get an instance of a specific script in CSharp
function InstOf(scriptName)
	return CS[scriptName].Instance
		or CS[scriptName].self
end

-- function SetEvent(go)
-- 	return UIEventListener.Get(go.gameObject)
-- end

client,PacketUtils = (function(t) return t,t end){
	Send = function(msg,body)
	    local req = CS.ProtoClass[msg]()
	    req.token = CS.BY_GlobalData.myData.token
	    for k,v in pairs(body or {}) do
	    	if type(v)=="table" then
	    		for i,v in ipairs(v) do
	    			req[k]:Add(v)
	    		end
	    	else
	    		req[k] = v
	    	end
	    end
	    CS.XLuaUtils.SendProtoBuf(req)
	    return true
	end
}

function ShowTipsView(tips)
	local view = GameObject.Instantiate(InstOf("CatchDollView"):GetView("Tips"))
	FindObject (view) "Label" "UILabel" .text = tips
	view.transform:SetParent(InstOf("CatchDollView").transform,false)
end

function csarr(arr)
	-- index from 0
	--[[]]arr = makeMutable(arr)
	local function arr_getter(arr,i)
		return arr[i]
	end
	local function trans_getter(arr,i)
		return arr.transform:GetChild(i)
	end

	local getter,len
	len = arr.Length or arr.Count
	if len then
		getter = arr_getter
	else
		len = arr.transform.childCount
		if len then
			getter = trans_getter
		end
	end

	local i   = ~0
	return function()
		i = -~i
		if i>=len then return end
		return i,getter(arr,i)
	end
end

function cstree(arr)
	local function dump(t)
		for k,v in csarr(t) do
			coroutine.yield(k,v)
			if v.Length or v.Count or v.childCount then dump(v) end
		end
	end
	local co = coroutine.create(function() dump(arr) end)
	return function()
		return select(2,coroutine.resume(co))
	end
end

function cslen(arr)
	arr = makeMutable(arr)
	return arr.Length or arr.Count or arr.childCount or #arr
end

function SetIconURL(tex,url)
	local imgId = tonumber(url)
	InstOf("MyRoot"):SetWXIcon(
		imgId and 1 or 2, 
		imgId or  0, 
		tostring(url),
		tex
	)
end