-- author: bbbirder

--[[getter/setter扩展]]
function access(remoteTable)
    local assistTable = {remote = remoteTable}
    assistTable.rawset = function(k,v)
        remoteTable[k] = v
    end
    assistTable.rawget = function(k)
        return remoteTable[k]
    end
    assistTable.localization = function(t)
        for k,v in pairs(t) do
        	rawset(assistTable,k,v)
        end
    end  
    setmetatable(assistTable,{
        __index = function(t,k)
            if type(remoteTable[k]) == "table" and remoteTable[k].get then
                return remoteTable[k].get(remoteTable,k)
            else
                return remoteTable[k]-- or getmetatable(assistTable) and getmetatable(assistTable)[k]
            end
        end,
        __newindex = function(t,k,v)
            if type(remoteTable[k]) == "table" and remoteTable[k].set then
                remoteTable[k].set(remoteTable,k,v)
            else
                remoteTable[k] = v
            end
        end
    })
    return assistTable
end

--factory of access
function Accessor(t)
	local function innerFunc()
		local assistTable = access(clone(t))
		assistTable.localization {
			getter = getmetatable(assistTable).__index,
			setter = getmetatable(assistTable).__newindex
		}
		return assistTable
	end
	return innerFunc
end

--[[基础OOP]]
function class(clsname,super)
	local cls = {__name = clsname,ctor = function() end}
	local superType = type(super)
	if superType == "table" then
		cls.super = super
		cls.__create = function(...)
			if super.new then
				return super.new(...)
			else
				return {}
			end
		end
		setmetatable(cls,{__index = super})
	elseif superType == "function" then
		cls.__create = function(...)
			local inst = super(...)
			if inst.class then
				cls.super = inst.class
				setmetatable(cls,{__index = cls.super})
			end
			return inst
		end
	elseif super == nil then
		cls.__create = function()
			return {}
		end
	else
		error("bad class type:"..superType)
	end

	cls.new = function(...)
		local instance = cls.__create(...)
		rawset(instance,"class",cls)
		local mt = getmetatable(instance) or {}
		mt.__index = function(t,k)
			return cls[k] or rawget(t,"getter") and rawget(t,"getter")(t,k)
		end
		setmetatable(instance,mt)
		instance:ctor(...)
		return instance
	end

	return cls
end


--[[AOP扩展]]
--prefix: 兼容低版本lua
local unpack = unpack or table.unpack
--控制标识
ADVICE_SIGNAL_ENDALL = {}--结束过程
ADVICE_SIGNAL_AFTER  = {}--跳转到后置增强
ADVICE_SIGNAL_BEFORE = {}--跳转到前置增强
ADVICE_SIGNAL_TRUNK  = {}--跳转到主函数

--前置增强
function BeforeAdvice(tar,bsrc)
    return function(...)
	    local res
    	::before::
    	res = {bsrc(...)}
        if res[1]==ADVICE_SIGNAL_ENDALL then
        	goto endall
    	elseif res[1]==ADVICE_SIGNAL_AFTER then
    		goto after
		elseif res[1]==ADVICE_SIGNAL_BEFORE then 
			goto before
		elseif res[1]==ADVICE_SIGNAL_TRUNK then 
			goto trunk
        end
        ::trunk::
        res = {tar(...)}
        ::after::

        ::endall::
        return select(2,unpack(res))
    end
end

--后置增强
function AfterAdvice(tar,asrc)
    return function(...)
	    local res
    	::before::
        ::trunk::
        res = {tar(...)}
        ::after::
        res = {asrc(...)}
        if res[1]==ADVICE_SIGNAL_ENDALL then
        	goto endall
    	elseif res[1]==ADVICE_SIGNAL_AFTER then
    		goto after
		elseif res[1]==ADVICE_SIGNAL_BEFORE then 
			goto before
		elseif res[1]==ADVICE_SIGNAL_TRUNK then 
			goto trunk
        end
        ::endall::
        return select(2,unpack(res))
    end
end

--环绕增强
function AroundAdvice(tar,bsrc,asrc)
    return function(...)
	    local res
    	::before::
    	res = {bsrc(...)}
        if res[1]==ADVICE_SIGNAL_ENDALL then
        	goto endall
    	elseif res[1]==ADVICE_SIGNAL_AFTER then
    		goto after
		elseif res[1]==ADVICE_SIGNAL_BEFORE then 
			goto before
		elseif res[1]==ADVICE_SIGNAL_TRUNK then 
			goto trunk
        end
        ::trunk::
        res = {tar(...)}
        ::after::
        res = {asrc(...)}
        if res[1]==ADVICE_SIGNAL_ENDALL then
        	goto endall
    	elseif res[1]==ADVICE_SIGNAL_AFTER then
    		goto after
		elseif res[1]==ADVICE_SIGNAL_BEFORE then 
			goto before
		elseif res[1]==ADVICE_SIGNAL_TRUNK then 
			goto trunk
        end
        ::endall::
        return select(2,unpack(res))
    end
end

--增强某个类
function EnhanceClass(cls,enhanceFunc)
	for k,v in pairs(cls) do
		if type(v)~="function" then goto continue end
		local result = enhanceFunc(k,v)
		if type(result)=="function" then cls[k] = result end
		::continue::
	end
end

--AOP test
do return end
local Foo = {}
function Foo:meet(name)
    print("talking with "..name.."...")
end
function Foo:play(name)
    print("playing with "..name.."...")
end

EnhanceClass(Foo,function(k,method)
	if k=="meet" then
		return AroundAdvice(method,function(inst,name)
		    print("we meet",name)
		    return ADVICE_SIGNAL_TRUNK
		end,function(inst,name)
		    print("bye",name)
		end)
	elseif k=="play" then
		return AfterAdvice(method,function(inst,name)
			print("see u tmr,"..name)
		end)
	end
end)


Foo:meet "leo"
Foo:play "leo"