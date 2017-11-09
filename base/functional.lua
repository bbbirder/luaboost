functional = functional or {}

local _placeholder = {}

--@Ability:
-- better implement of packfunc
--@Example:
-- local f = bind(print,_1,":my",_1,"is",_2,"!")
-- f("name","leo")
-- f("age",18)
--@What's More:
-- _0 means all params.
function functional.bind(func,...)
    local _argsSuper = {...}
    local _argcnt = select("#",...)
    return function(...)
        local _argsOut = {}
        local _argsInner = {...}
        -- for i,v in pairs(_argsSuper) do
        for i=1,_argcnt do
            local v = _argsSuper[i]
            local iph = _placeholder[v]
            if iph==0 then
                local _argcntInner = select("#",...)
                _argcnt = i + _argcntInner - 1
                for j=1,_argcntInner do
                    _argsOut[i+j-1] = _argsInner[j]
                end
                break
            end
            if iph then
                _argsOut[i] = _argsInner[iph]
            else
                _argsOut[i] = v
            end
        end
        return func(unpack(_argsOut,1,_argcnt))
    end
end
   
--@Ability:
-- linearization nesting calling,just as "f3(f2(f1(...)))",to "procedure{f1,f2,f3}(...)".
--@Example:
-- local function addkv(t,k,v) --add a kv-pair into a table
--     t[k] = v
--     return t
-- end
-- local proc = procedure{
--     bind(addkv,_1,"name","leo"),
--     bind(addkv,_1,"age",18),
--     bind(addkv,_1,"role","warrior"),
-- }
-- dump(proc{
--     type = "player"
-- })
function functional.procedure(_funclist)
    return function(...)
        local ret = ...
        for k,func in pairs(_funclist) do
            ret = func(ret)
        end
        return ret
    end
end

--占位函数（睡着的）
function functional._zZ()
    
end

--起行标记（发呆的）
--三目表达式：(o_o) (result) and succ() or fail()
--简单返回,同x_X：bind(o_o,...)
function functional.o_o(...)
    return ...
end

--返回参数（瞎了眼的）
--(x_x) (2 * 3)() --6
function functional.x_x(...)
    local args = {...}
    return function()
        return unpack(args)
    end
end

--返回函数func（开心的）
-- (n_n) (print) (
--      1)      (2)     (3)
--     "name"  "is"    ("leo","zy")
--     "age"   "is"    ("18","years old")
function functional.n_n(f)
    local function innerfunc(...)
        f(...)
        return innerfunc
    end
    return innerfunc
end

--返回调用者t（悲伤的）
-- (T_T)(Stream)
--     :WriteByte(0)
--     :WriteChar(10)
--     :WriteString("name")
--     :WriteBool(false)
function functional.T_T(self)
    return setmetatable({},{
        __index = function(t,k)
            return function(...)
                self[k](self,select(2,...))
                return t
            end
        end,
    })
end

--返回string对应函数（财迷心窍的）
--不可访问外部变量，如有需要请使用script
-- (s_s) "return arg[1]+arg[2]" (123,100) --223
function functional.s_s(s)
    return loadstring("return function(...)\n"..
        "local arg = {...}\n"..
        s.."\nend")()
end

function functional.S_S(s)
    return s_s("return "..s)
end

--创建一个生命周期内只能被调用一次的函数
function functional.runOnce(func,...)
    local count = 0
    local args = {...}
    local function innerfunc()
        if count == 0 then
            count = count + 1
            return func(unpack(args))
        end
    end
    return innerfunc
end

setmetatable(functional,{
    __index = function(t,k)
        if k:sub(1,1)~="_" then return end
        local i = tonumber(k:sub(2))
        if i then
            rawset(t,k,function()end)
            _placeholder[t[k]] = i
        end
        return rawget(t,k)
    end
});

--preinstall useful placeholders...
(function()end){
    functional._0,
    functional._1,
    functional._2,
    functional._3
}

