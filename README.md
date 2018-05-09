<!-- use: GFM -->
# luaboost
<!-- ![](./banner.jpg) -->
lua development frameworks.  

syntax: Github Flavor Markdown.  
valid tool: Markdown Plus.Browse [online](http://mdp.tylingsoft.com),and Copy & Paste in the left editing DOM.  
author:     bbbirder  
last edit:  18/5/7

---

<!-- ##catalogue: -->

<!-- [TOC] -->

# catalogue:

[toc]


---

## global environment
the following varients will be defined in **global** env. see **prefix.lua**

### enum

>*a.k.a* C-style-enum

**params**:

>`firstindex`,*number* : index from,can be nil,default 1

**return**:

>*table*, an enum structure

eg:
```lua
local Thursday="a good day"
local week = enum(0){
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
}
print(Thursday)      --a good day
print(week.Thursday) --4
```

### using

>using a namespace to short code

**params**:

>`src`:what to use.  
*table type*: using it directly.  
*string type*: it's a file to import & use.

eg:
```lua
-- mod.lua
return {
    parse = function() end,
    encoding = "utf-8",
}


-- main.lua
using "mod"
using {
    name = "leo",
    age  = 18
}

print(encoding) -- utf-8
print(name)     -- leo
```


### import

>require a lua file by relative path

**params**:

>`moduleName`:relative path to target file. begin with '.' to nav parent dir.  
`level`:use it just when you want to call import in a function block. Otherwise, ignore it.

**return**:

>*same as require*

eg:
```lua
local path = import "path"

for k,v in pairs(path) do
    print(k,v)
end
```

### import_redir

>*specify a short path to a module file*

**params**:

>`newpath`:be able to [using](#using) or [import](#import) a lua file by the new name from now on.  
`oldpath`:where it really located

eg:
```lua
-- init.lua
import_redir "foo" ".test.foo"

-- modules\test.lua,in other file
using "foo"
```


### iif

**params**:

>`exp`:expression to judge  
`yesval`:returns this if `exp` is *true*  
`noval`:returns this if `exp` is *false*


**NOTE:** yesval and noval will be **evaled before judgement**

eg:
```lua
local v = iif (1) "A" "B"
print(v) -- A

--print will be evaled first
iif(2) (print"X") (print"Y") -- X   Y
```


### script

>*def a function by string,can access varient in current scope ,tail call disabled*

**params**:

>`args`,*string* :arguments,same as normal function  
`body`,*string* :block body,same as normal function



**return**:

>*same as normal fuction*

eg:
```lua
local a = 1
local t = {}
t.n = 1
local f = script "x,y" [[
    a   = x
    t.n = y
]]
f(13,13)
print(a,t.n)  -- 13    13

print(script'x' [[x+1]] (3) ) -- 4
```


### switch & default

>*a.k.a C-stype-switch*

eg:
```lua
-- [[eg1:different type of v]]
local a = switch(3){
  [1] = "one",
  [2] = "two",
  [3] = function return "three" end
}
print(a) -- three
--function & thread type: call & return automaticly,
--other type: just return

-- [[eg2:when k is a function]]
local i = 3
local ret = switch(i){
    [script''[[i<10]]] = "<10",
    [script''[[i>10]]] = ">10",
}
print(ret) -- <10

-- [[eg3:default case]]
local ret = switch(2){
    [1] = "one",
    [3] = "three",
    [default] = "other"
}
print(ret) -- other
--default is a global varient,dont override it.
```

### NIL_ALWAYS_VAL
> if `NIL_ALWAYS_VAR_ENABLED == true`(located in **config.lua**) this feature will work.  
varient `_` will always be nil.
### lualibs


---

## modules
the following modules can be loaded by [using](#using).

### 1.functional
something like functional module in STDC++,see **functional.lua**

#### functional.bind & functional.\_%d

> a.k.a functional::bind in STDC++  
\_%d is a placeholder,where %d is zero or positive number,eg: `_0` , `_3`  
\_0 means all params

eg:
```lua
using "functional"

local f = bind(print,_1,":my",_1,"is",_2,"!")
f("name","leo") -- name :my name is leo
f("age",18) -- age :my age is 18
```


#### functional.procedure

>*linearization nesting calling,for an example:*

```lua
DoSomethingA(DoSomethingB(DoSomethingC(...)))
```

>*can be changed to this form:*
```lua
procedure{
    DoSomethingA,
    DoSomethingB,
    DoSomethingC,
}(...)
```

eg:
```lua
using "functional"

local function addkv(t,k,v) --add a kv-pair into a table
    t[k] = v
    return t
end

local proc = procedure{
    bind(addkv,_1,"name","leo"),
    bind(addkv,_1,"age",18),
    bind(addkv,_1,"role","warrior"),
}

local player = proc{
    type = "player"
}

for k,v in pairs(player) do
    print(k,v)
end
```

#### functional.Y

>Y Fixed-point Combinator,for anonymous recursive function
```lua
using "functional"

local sum = Y(function(f) return function(i)
    return i>0 and i+f(i-1) or 0 -- recursive function without name
end end)
sum(10) --55
```

#### functional.runOnce
>create a function which can only be called once
eg:
```lua
using "functional"
function showName()
    print("leo")
end
local onceShowName = runOnce(showName)
onceShowName() -- logout: leo
onceShowName() -- nothing happened
onceShowName() -- nothing happened
```

#### functional.p_p
> return param,can access const table or string in expression without`()`

eg:
```lua
using "functional"
local age = p_p{
    leo = 18,
    lee = 23,
    woo = 60,
}["leo"]

print(p_p"age:%d":format(age)) --18
```
#### functional.x_x
> return a function which returns param

#### functional.o_o
> return caller

#### functional.f_f
> return function

### 2.lambda
> python-stype-lambda expression in lua,**dont** use it too much.you may consider [script](#script) instead.  
here comes lua lambda function, a bit like which in Python(arithmetic only).  
you can def a func in this way:  
`local newfunc = lambda()(x){x*2+3}`  
a little slower  

>next version of lambda-impl will be able to code like this:  
`local newfunc = (x)=>{x*2+3}`  
this will be a bit like which in JavaScript(real arrow func)

>this is an old version of lambda-impl,there are some limits,you are NOT that suggested to use this ver too much.    
these codes WONT work in lambda body:   
>> **X** reserved keywords: `local`, `and`, `or`, `function`, `if`, `do`, `end`, ...  
**X** const only:        `lambda()(){12}`   
**X** define table:    `lambda()(){{12}}`  
**X** value assign:      `lambda()(){a=12}`

>Why different?

>1.this version is based on Abstract Syntax Tree(**AST**)  
next version will be based on Reverse Polish Notation(**RPN**)  
so, const value only returnning **wont** work in AST,but in RPN.  
eg:
>>this ver:`lambda()(){12}` is bad, returns nil  
this ver:`lambda()(){a}`  is good,returns value of a  
next ver:`()=>{12}`       is good,returns 12

>2.this version only record metamethods,so you can just write arithmetic codes.  
either `lambda()(){{12}}` or `lambda()(){a=12}` cant be recorded.

usage:
```lua
using "lambda"

local n = 2
local f

f = lambda()(x,y){2*(x-y)+n}
print(f(3,2)) --4

f = lambda()(){print("log")} --print wont be called here
f() --log
f() --log
```
### 3.memory

### 4.SourceString
* script
* stringify

### 5.json
* basic json
* cir-ref supported version

### 6.sheet

### 7.vector2d


### 8.metatable
### 9.device
### 10.debug
## for Unity


## Tools

[back to top](#luaboost)