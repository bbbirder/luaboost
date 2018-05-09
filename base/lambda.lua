--author:bbbirder

--README:

--here comes lua lambda function, a bit like which in Python(arithmetic only).
--you can def a func in this way:
--    'local newfunc = lambda()(x){x*2+3}'
--a little slower

--next version of lambda-impl will be able to code like this:
--    'local newfunc = (x)=>{x*2+3}'
--this will be a bit like which in JavaScript(real arrow func)

--You are NOT that suggested to use this too much.
--this is an old version of lambda-impl,so there are some limits.
--these codes WONT work in lambda body: 
--    reserved keywords: local, and, or, function, if, do, end, ...
--    const only:        'lambda()(){12}'   --but this will work:   'lambda()(){a}'
--    directly table:    'lambda()(){{12}}' --but this will work:   'lambda()(){foo{}}'
--    value assign:      'lambda()(){a=12}'

--Why different?
--1.this version is based on Abstract Syntax Tree(AST)
--next version will be based on Reverse Polish Notation(RPN)
--so, const value only returnning wont work in AST,but in RPN.
--    eg: this ver:'lambda()(){12}' --bad, returns nil
--        this ver:'lambda()(){a}'  --good,returns value of a
--        next ver:'()=>{12}'       --good,returns 12
--2.this version only record metamethods,so you can just write arithmetic codes.
--either 'lambda()(){{12}}' or 'lambda()(){a=12}' cant be recorded.

--SLIDE BOTTOM TO VIEW THE FULL EXAMPLE

import "memory"

local op = {
	"add",	"sub",
	"mul",	"div",
	"mod",	"pow",
	"unm",	"idiv",
	"band",	"bor",
	"bxor",	"bnot",
	"shl",	"shr",
	"concat","len",
	"eq","lt","le",
	"index","newindex",
	"call"
}

local function doInvoke(ast,vals,regs)
	function invoke(ast)
		if type(ast)~="table" then return ast end
		if vals[ast] then return regs[ast] end
		local cmd,a,b,c = table.unpack(ast)
		if     cmd=="add" then return invoke(a)+invoke(b)
		elseif cmd=="sub" then return invoke(a)-invoke(b)
		elseif cmd=="mul" then return invoke(a)*invoke(b)
		elseif cmd=="div" then return invoke(a)/invoke(b)
		elseif cmd=="mod" then return invoke(a)%invoke(b)
		elseif cmd=="pow" then return invoke(a)^invoke(b)
		elseif cmd=="unm" then return -invoke(a)
		elseif cmd=="idiv"then return invoke(a)//invoke(b)
		elseif cmd=="band"then return invoke(a)&invoke(b)
		elseif cmd=="bor" then return invoke(a)|invoke(b)
		elseif cmd=="bxor"then return invoke(a)~invoke(b)
		elseif cmd=="bnot"then return ~invoke(a)
		elseif cmd=="shl" then return invoke(a)<<invoke(b)
		elseif cmd=="shr" then return invoke(a)>>invoke(b)
		elseif cmd=="concat"then return invoke(a)..invoke(b)
		elseif cmd=="len" then return #invoke(a)
		elseif cmd=="eq"  then return invoke(a)==invoke(b)
		elseif cmd=="lt"  then return invoke(a)<invoke(b)
		elseif cmd=="le"  then return invoke(a)<=invoke(b)
		elseif cmd=="index"then return invoke(a)[invoke(b)]
		elseif cmd=="newindex"then invoke(a)[invoke(b)] = invoke(c)
		elseif cmd=="call"then 
			local args = {}
			for i,v in pairs(ast) do if i>2 then
				args[i-2] = invoke(v)
			end end
			return (invoke(a))(table.unpack(args))
		end
	end
	return invoke(ast)
end

local function lambda()
	-- local __innerVarients = {
	-- 	print = print,
	-- 	newregval = newregval,
	-- 	findvar = findvar,
	-- 	setmetatable = setmetatable,
	-- 	ipairs = ipairs,
	-- 	table = table
	-- }
	local mt = {}
	local refs = {}
	local vals = {} --varname register
	local regs = {} --save values
	function newregval(v,n)
		local ret = setmetatable({},mt)
		refs[n]   = ret
		vals[ret] = true
		regs[ret] = v
		return ret
	end

	local asttmp = {}--ast cache
	local ast = {}
	-- fill metatable
	for k,v in pairs(op) do
		mt["__"..v] = function(...)
			local r = setmetatable({},mt)
			ast = {v}
			for i,v in ipairs({...}) do
				ast[#ast+1] = asttmp[v] or v
			end
			asttmp[r] = ast
			return r
		end
	end

	local blindScope,brightScope = genScopeOperator(2,
		{"newregval","findvar","setmetatable","ipairs"})
	
	blindScope(2)
	return function(...)
		brightScope(2)
		local args = {}
		for i,v in ipairs({...}) do
			args[i] = newregval(nil,v)
		end
		blindScope(2,function(k)
			return refs[k] or (newregval(findvar(k,4),k))
		end)

		return function(t)
			brightScope(2)
			return function(...)
				for i,v in ipairs(args) do
					regs[v] = ({...})[i]
				end
				for k,v in pairs(ast) do
					return doInvoke(ast,vals,regs)
				end
				return regs[t[1]]
			end
		end
	end

end






--test lambda
;(function()
	do return end --comment this line to run test
	local f

	local a = 2
	local t = {n = 1}


	f = lambda()(){print "asd"}
	f() --asd


	f = lambda()(x){
		a*x + (t.n<<1)
	}
	print(f(a)) --6



	local function sum(...)
		print("this msg will only be logged when lambda called")
		local ret = 0
		for k,v in pairs({...}) do
			ret = ret + v
		end
		return ret
	end
	f = lambda()(x,y){ sum(x,y)^a } -- msg wont be logged
	print(f(2,3))  -- 25.0


	function dummy() end
	f = lambda()(x,y){dummy(
		print("start insert"),
		table.insert(t,x),
		table.insert(t,y),
		print("end insert"),
		nil
	)}
	f("a new field","another field")
	print(t[1],t[2])

end)()


return {lambda = lambda}