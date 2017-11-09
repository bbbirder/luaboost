--author:bbbirder

--数值转string
function stringify(val)
	return switch(type(val)){
		["nil"]		= "nil",
		["boolean"]	= tostring(val),
		["number"] 	= val,
		["function"]= function()
			return "function(...)"..
				"return loadstring("..
					stringify(string.dump(val))..
				")(...)"..
			"end"
		end,
		["string"] 	= function()
			local s = "\""
			for c in val:gfind"." do
				s = s.."\\"..c:byte()
			end
			return s.."\""
		end,
		["table"] = function()
			local members = {}
			for k,v in pairs(val) do
				table.insert(members,
					"["..stringify(k).."]="..stringify(v))
			end
			return "{"..table.concat(members,",").."}"
		end,
	} or error("cannot stringify type:"..type(val),2) 
end

--TODO
--内嵌执行string，可访问局部变量
function script(s)
	local prefix,suffix = "",""
	-- local function uvpairs(l)
	-- 	l = l or 2
	-- 	local n = 0
	-- 	local func = debug.getinfo(1).func
	-- 	return function()
	-- 		n = n + 1
	-- 		return n,debug.getupvalue(func,n)
	-- 	end
	-- end
	local function lcpairs(l)
		l = l or 2
		local i = 0
		return function()
			i = i + 1
			local n,v = debug.getlocal(l,i)
			return n and i, n, v
		end
	end
	local function insertvalue(i,n,v)
		prefix = prefix..("local %s = %s\n"):format(n,stringify(v))
		suffix = suffix..("debug.setlocal(2,%s,%s)\n"):format(i,n)
	end
	-- for i,n,v in uvpairs(3) do
	-- 	print(n,v)
	-- end
	for i,n,v in lcpairs(3) do
		insertvalue(i,n,v)
	end
	local codes = prefix..s..suffix
	return loadstring(codes)()
end
