--author:bbbirder


luajson = luajson or {}

--对象转json
function luajson.encode(obj)
	local suffix = ""
	local occurred = {}
	local function encode(v,path)
		local typ = type(v)
		if typ=="string" then
			return '\"' .. v:gsub("[\n\r\t\\\"]",{
				["\n"] = [[\n]],
				["\t"] = [[\t]],
				["\r"] = [[\r]],
				["\\"] = [[\\]],
				["\""] = [[\"]],
			}) .. '\"'
		elseif typ=="number" then
			return tostring(v)
		elseif typ=="boolean" then
			return tostring(v)
		elseif typ=="table" then
			path = path or "root"
			if occurred[v] then
				suffix = suffix..path.."="..occurred[v]..";"
				return "null"
			else
				occurred[v] = path
				local isArr = #v>0
				local tmp = {}
				for k,v in pairs(v) do
					local _kv = isArr and "" or ('\"'..k..'\":')
					_kv = _kv..encode(v,path.."."..k)
					table.insert(tmp,_kv)
				end
				return (isArr and "[" or "{")..
					table.concat(tmp,",")..
					(isArr and "]" or "}")
			end

		else
			return "null"
		end
	end
	return encode(obj),suffix
end

--json转对象
function luajson.decode(s)
	local function retp(...)
		return ...
	end
	local function retv(...)
		local args = {...}
		return function()
			return unpack(args)
		end
	end

	local wordmap = {
		['".-"'] = retp,
		["'.-'"] = retp,
		["%-?[0-9]*%.?[0-9]+e?[0-9]*"] = retp,
		["0x[0-9a-fA-F]+"] = retp,
		[":"] = retv "=",
		[","] = retp,
		["%["] = retv "{",
		["%]"] = retv "}",
		["true"] = retp,
		["false"] = retp,
		["null"] = retv "nil",
		["{"] = retp,
		["}"] = retp,
	}
	-- local sentmap = {
	-- 	[{"string"}] = "value",
	-- 	[{"number"}] = "value",
	-- 	[{"true"}] = "value",
	-- 	[{"false"}] = "value",
	-- 	[{"null"}] = "value",
	-- 	[{"string","is","value"}] = "pair",
	-- 	[{"value"}] = "pair",
	-- 	[{"pair","split","list"}] = "list",
	-- 	[{"arr_start","list","arr_end"}] = "arr",
	-- 	[{"obj_start","list","obj_end"}] = "obj",
	-- }
	--word recognize
	-- local words = {}
	local function checkString(star,ssrc)
		local ccur = star:reverse():match('\"(\\*)')
		if ccur and #ccur%2==1 then
			local ifrom,ito = ssrc:find(".-\"")
			star = star..ssrc:sub(ifrom,ito)
			ssrc = ssrc:sub(ito+1)
			return checkString(star,ssrc)
		end
		return star
	end
	local sout = {}
	while #s>0 do
		local isfound = false
		local ifrom,ito
		for k,v in pairs(wordmap) do
			ifrom,ito = s:find(k)
			if ifrom==1 then
				isfound = true
				-- table.insert(words,{v,s:sub(ifrom,ito)})
				local result = s:sub(ifrom,ito)
				if result==":" then
					sout[#sout] = sout[#sout]:sub(2,-2)
				end
				if k:find("[\"\']") then--is string
					result = checkString(result,s:sub(ito+1))
					ito = #result
				end
				table.insert(sout,v(result))
				-- print(v,result)
				break
			end
		end
		if not isfound then
			print("parse err:\n",s)
			break
		else
			s = s:sub(ito+1)
		end
	end
	sout = table.concat(sout)
	return loadstring("return "..sout)()
end

--对象转json，可循环引用版
function luajson.encode2(obj)
	local json,suffix = luajson.encode(obj)
	return [[{"obj":]]..
		luajson.encode(json)..
		[[,"suffix":"]]..
		suffix..[["}]]
end

--json转对象，可循环引用版
function luajson.decode2(s)
	local tmp = luajson.decode(s)
	local ret = {
		root=luajson.decode(tmp.obj)
	}
	local function fetchTarget(arr)
		local ret = ret;
		for i=1,#arr-1 do
			ret = ret[arr[i]]
		end
		return ret,arr[#arr]
	end
	local function fetchSource(arr)
		local ret = ret;
		for i=1,#arr do
			ret = ret[arr[i]]
		end
		return ret
	end
	for s in tmp.suffix:gmatch("(.-);") do
		local tar,src = s:match("(.*)=(.*)")
		tar = tar:split("%.")
		src = src:split("%.")
		local owner,name = fetchTarget(tar)
		owner[name] = fetchSource(src)
	end
	return ret.root
end