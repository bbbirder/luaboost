local DebugUtils = {}
function DebugUtils.traceback(level)
	local ret = {}
	local s = debug.traceback("",level+1)
	-- for sub in s:match(".-stack traceback:\n(.*)"):gmatch("(.-)\n") do
	for i,sub in pairs(s:sub(18):split("\n")) do
		local path,line,func = sub:match("\t*(.-):(.-):(.*)")
		table.insert(ret,{path=path,line=line,func=func})
	end
	return ret
end
local function uvpairs(l)
	l = l and (l+1) or 2
	local i = 0
	local func = debug.getinfo(l).func
	return function()
		i = i + 1
		local n,v = debug.getupvalue(func,i)
		-- for k,v in pairs(func) do
		-- 	print(k,v)
		-- end
		return n, v
	end
end
local function lcpairs(l)
	l = l and (l+1) or 2
	local i = 0
	return function()
		i = i + 1
		local n,v = debug.getlocal(l,i)
		return n, v
	end
end
local nc = 2
function DebugUtils.dump_env(level)
	level = level and (level + 1) or 2
	local ret = {
		childs = {
			{
				childs = {},
				name = "局部变量",
			},
			{
				childs = {},
				name = "upvalue",
			}
		},
	}
	for n,v in lcpairs(level) do
		if n:match("[a-zA-Z0-9]*")==n then
			table.insert(ret.childs[1].childs,{name=n,val=v})
		end
	end
	for n,v,f in uvpairs(level) do
		table.insert(ret.childs[2].childs,{name=n,val=v})
		-- print(n,v,f)
	end
	return ret
end

return DebugUtils