--author:bbbirder

function genStrictCodes(newenv,enterFunc,leaveFunc)
	return function()
		local oldf = debug.getinfo(2).func
		local oldenv,olduv,oldlc = getfenv(oldf),{},{}
		for i,k,v in lcpairs(2) do
			oldlc[i] = v
			debug.setlocal(2,i,k)
		end
		for i,k,v in uvpairs(2) do
			olduv[i] = v
			if k~="_ENV" then debug.setupvalue(oldf,i,k) end
		end
		setfenv(oldf,setmetatable({},{__index = function(t,k)return k end}))
		return function(--[[strict codes...]]t)
			setfenv(oldf,oldenv)
			for i,k,v in uvpairs(2) do
				if k~="_ENV" then debug.setupvalue(oldf,i,olduv[i]) end
			end
			for i,k,v in lcpairs(2) do
				debug.setlocal(2,i,oldlc[i])
			end
			ret = {}
			local i = 1
			for k,v in pairs(t) do
				-- local isiv = tonumber(k)
				-- ret [isiv and v         or  k] = 
				-- 	(isiv and {_ENV[v]} or {v})[1]
				ret[v] = i
				i=i+1		
			end
			return ret
		end
	end
end

-- varname = genxfunc(
-- 	function(t,k)
-- 		return "var "..k
-- 	end,
-- 	function(old,new)

-- 	end,
-- 	function(old,new,k)
-- 		return k
-- 	end
-- )
function lcpairs(level)
	level = level and level+1 or 2
	local i = 0
	return function()
		i = i + 1
		local k,v = debug.getlocal(level,i)
		if k then return i,k,v end
	end
end

function uvpairs(level)
	level = level and level+1 or 2
	local i = 0
	local upfunc = debug.getinfo(level).func
	function inner()
		i = i + 1
		local k,v = debug.getupvalue(upfunc,i)
		if k=="_ENV" then return inner() end
		if k then return i,k,v end
	end
	return inner
end

-- get a var with name in local stack only
function findlocal(name,level)
	level = level and level+1 or 2
	for i,k,v in lcpairs(level) do
		if k==name then return v,i end
	end
end

-- get a var with name in upvalue stack only
function findupval(name,level)
	level = level and level+1 or 2
	for i,k,v in uvpairs(level) do
		if k==name then return v,i end
	end
end

-- get a var with name :local -> upvalue -> global
function findvar(name,level)
	level = level and level+1 or 2
	local v,i
	v,i = findlocal(name,level)
	if i then return v,i,"lc" end
	v,i = findupval(name,level)
	if i then return v,i,"uv" end
	v   = _ENV[name]
	if v then return v,0,"env"end
end

_LC = setmetatable({},{
	-- __index = function(t,k,v) return (findlocal(k,2)) end,
	__call  = function(t,i,v,l) l=l and l+1 or 2; debug.setlocal(l,i,v) end,
	})
_UV = setmetatable({},{
	-- __index = function(t,k,v) return (findupval(k,2)) end,
	__call  = function(t,i,v,l) l=l and l+1 or 2; debug.setupvalue(debug.getinfo(l).func,i,v) end
	})

function setvar(name,val,l)
	l = l and l+1 or 2
	local v,i,wh = findvar(name,l)
	local _ = ({
		env = setmetatable({},{__call=function(t,k,v) _ENV[name]=v end}),
		lc  = _LC,
		uv  = _UV
	})[wh](i,val,l)
end

function copyscope(l)
	l = l and l+1 or 2

	local oldf = debug.getinfo(l).func
	local newscope = setmetatable({},{__index=debug.getfenv(oldf)})

	local alluv = {}
	for i,k,v in uvpairs(l) do
		alluv[k] = v
	end
	newscope = setmetatable(alluv,{__index=newscope})

	local alllc = {}
	for i,k,v in lcpairs(l) do
		alllc[k] = v
	end
	newscope = setmetatable(alllc,{__index=newscope})
	newscope = setmetatable({},{__index=newscope,
		__newindex=function(t,k,v) return (setvar(k,v,l)) end})

	return newscope
end

function genScopeOperator(l,ignores)
	l=l and l+1 or 2
	ignores = ignores or {}
	ignoresenv = {}
	for k,v in pairs(ignores) do
		ignoresenv[v] = getfenv(debug.getinfo(l).func)[v]
	end
	for k,v in pairs(ignores) do
		ignores[v] = k
	end
	local oldenv,olduv,oldlc
	local oldf = debug.getinfo(l).func
	local oldenv,olduv,oldlc = getfenv(oldf),{},{}
	function blindScope(l,f)
		f = f or function(...) return ... end
		l=l and l+1 or 2
		for i,k,v in lcpairs(l) do if not ignores[k] then
			oldlc[i] = v
			debug.setlocal(l,i,f(k))
		end end
		for i,k,v in uvpairs(l) do if not ignores[k] then
			olduv[i] = v
			debug.setupvalue(oldf,i,f(k))
		end end
		setfenv(oldf,setmetatable(ignoresenv,{__index = function(t,k)return (f(k)) end}))
	end
	function brightScope(l)
		l=l and l+1 or 2
		setfenv(oldf,oldenv)
		for i,k,v in uvpairs(l) do
			debug.setupvalue(oldf,i,olduv[i])
		end
		for i,k,v in lcpairs(l) do
			debug.setlocal(l,i,oldlc[i])
		end
	end
	return blindScope,brightScope
end
-- function refcall(func,...)
-- 	for i=1,select("#",...) do
-- 		print(i)
-- 	end
-- end

-- function ref(name)
-- 	function newref(v,i,wh)
-- 		return setmetatable({},{
-- 			__index = function(t,k)
-- 				return findvar(k,3)
-- 			end,
-- 			__newindex = function(t,k,v)
-- 				;({
-- 					env = setmetatable({},{__call=function(t,k,v) _ENV[name]=v end}),
-- 					lc  = _LC,
-- 					uv  = _UV
-- 				})[wh](i,v)
-- 			end
-- 		})
-- 	end
-- 	level = level and level+1 or 2
-- 	local v,i
-- 	v,i = findlocal(name,level)
-- 	if i then return v,i,"lc" end
-- 	v,i = findupval(name,level)
-- 	if i then return v,i,"uv" end
-- 	v   = _ENV[name]
-- 	if v then return v,0,"env"end
-- 	error("ref to nil",2)
-- end