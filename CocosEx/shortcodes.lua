--author:bbbirder

--cc.Node
    local Node = cc.Node
    
    --USAGE:
    --node:run{action1,action2,...} or
    --node:run(action)
    function Node:run(actions)
        if type(actions)=="table" then
            self:runAction(cc.Sequence:create(actions))
        else
            self:runAction(actions)
        end
        return self
    end

    -- function Node:run(actions)
    --     local function packAction(_actions)
    --         if type(_actions)~="table" then return _actions end
    --         for k,act in pairs(_actions) do
    --             if k=="loop" then
    --                 local loopAct = cc.RepeatForever:create(packAction(act)):retain()
    --                 table.insert(
    --                     _actions,
    --                     cc.CallFunc:create(function( )
    --                         self:runAction(loopAct)
    --                     end)
    --                 )
    --                 _actions.loop = nil
    --             elseif type(act)=="table" then
    --                 _actions[k] = cc.Spawn:create(unpack(act))
    --             end
    --         end
    --         return cc.Sequence:create(_actions)
    --     end
    --     self:runAction(packAction(actions))
    --     return self
    -- end

    --USAGE:
    --node:runEx{
    --      action0,
    --     {action1,action2},
    --     {action3,action4,action5},
    --     ,...,
    --      loop = {
    --          actions...
    --      }
    -- }
    function Node:runEx(actions)
        for k,act in pairs(actions) do
            if type(act)=="table" then
                actions[k] = cc.Spawn:create(act)
            end
            if k=="loop" then
                actions["loop"] = nil
                local _actions = {}
                for k,_act in pairs(act) do
                    if type(_act)=="table" then
                        _actions[k] = cc.Spawn:create(_act)
                    end
                end
                _actions[#_actions+1] = cc.CallFunc:create(function()
                    self:run(cc.Sequence:create(_actions))
                end)
                actions[#actions+1] = (cc.Sequence:create(_actions))
            end
        end
        return self:run(actions)
    end
    
    function Node:scaleToSize(w,h)
        if not h then
            h = w[1] or w["width"]
            w = w[2] or w["height"]
        end
        local sz = self:size()
        self:scale(w/sz.width,h/sz.height)
        return self
    end

    function Node:runLoop(actions)
        self:runAction(cc.RepeatForever:create(cc.Sequence:create(actions)))
        return self
    end

    function Node:child(children)
        if children then
            assert(type(children) == "table")
            for k,v in pairs(children) do
                if not cc.Node.isnull(v) then
                    self[k] = v:addTo(self)
                end
            end
            return self
        end
        return self:getChildren()
    end

    function Node:wpos(x,y)
        if not y then
            if not x then
                return self:getParent():convertToWorldSpace(cc.p(self:pos()))
            end
            y = x.y
            x = x.x
        end
        self:pos(self:getParent():convertToNodeSpace(cc.p(x,y)))
        return self
    end

    function Node:center()
        local size = self:getParent():size()
        return self:pos(size.width/2,size.height/2)
    end

    function Node:pspos(x,y)
        if not y then
            y = x.y
            x = x.x
        end
        y = display.height - y
        return self:wpos(x,y)
    end

    function Node:isnull()
        return not self or tolua.isnull(self)
    end

    function Node:safeRemove()
        if not cc.Node.isnull(self) then
            return self:removeSelf()
        end
    end

    function Node:anchor(x,y)
        if not y then
            if not x then
                return self:getAnchorPoint()
            end
            y = x.y
            x = x.x
        end
        self:setAnchorPoint(x,y)
        return self
    end    
    function Node:getAnchorX()
        return self:getAnchorPoint().x
    end
    function Node:setAnchorX(x)
        self:setAnchorPoint(x,self:anchor().y)
        return self
    end

    function Node:getAnchorY()
        return self:getAnchorPoint().y
    end
    function Node:setAnchorY(y)
        self:setAnchorPoint(y,self:anchor().x)
        return self
    end

    function Node:color(r,g,b,a)
        local color = r
        if not g then
            if not r then
                return self:getColor()
            else
                a = r.a
                b = r.b
                g = r.g
                r = r.r
            end
        end
        if a then
            color = cc.c4b(r,g,b,a)
        else
            color = cc.c3b(r,g,b)
        end
        self:setColor(color)
        return self
    end

    -- function Node:dumpTree()
    --     print("dump",self)
    --     for k,v in pairs(self) do
    --         print(k,v)
    --     end
    --     for i,v in ipairs(self:getChildren()) do
    --         v:dumpTree()
    --     end
    -- end
    function Node:wscale()
        local parent = self:getParent()
        if parent then
            return self:scale() * parent:wscale()
        end
        return self:scale()
    end

    function cc.Node:shake(waves,strength,rate,onComplete)
        self:stopAllActions()
        local px,py = self:getPosition()
        local al = {}
        for i=0,waves do
            local alti = strength^((waves-i)/waves)
            al[#al+1] = cc.MoveTo:create(rate,cc.p(px+math.sin(math.random(0,math.pi*2))*alti,py+math.cos(math.random(0,math.pi*2))*alti))
        end
        al[#al+1] = cc.MoveTo:create(rate,cc.p(px,py))
        transition.execute(self,transition.sequence(al),{onComplete = onComplete})
    end

    function Node:clone()
        local _copy = display.newSprite()
        _copy:pos(self:pos())
        _copy:anchor(self:anchor())
        _copy:scale(self:wscale())
        _copy:rotate(self:getRotation())
        _copy:size(self:size())
        _copy:visible(self:visible())
        _copy:zorder(self:zorder())
        for i,v in ipairs(self:getChildren()) do
            Node.clone(v):addTo(_copy)
        end
        if self.getRendererNormal then self = self:getRendererNormal() end
        if self.getSprite then self = self:getSprite() end
        if self.getTexture then 
            _copy:setTexture(self:getTexture()) 
        end
        if self.getSpriteFrame then 
            _copy:setSpriteFrame(self:getSpriteFrame()) 
        end
        return _copy
    end

    function Node:visible(b)
        if b == nil then
            return self:isVisible()
        end
        self:setVisible(b)
        return self
    end

    function Node:size(width,height)
        if height then
            self:setContentSize(width,height)
        else
            if not width then
                return self:getContentSize()
            end
            self:setContentSize(width)
        end
        return self
    end

    function Node:pos(x,y)
        if y then
            self:setPosition(x,y)
        else
            if x then
                self:setPosition(x)
            else
                return self:getPosition()
            end
        end
        return self
    end

    function Node:posX(v)
        if v then
            self:setPositionX(v)
            return self
        end
        return self:getPositionX()
    end

    function Node:posY(v)
        if v then
            self:setPositionY(v)
            return self
        end
        return self:getPositionY()
    end

    function Node:name(_name)
        if not _name then return self:getName() end
        self:setName(_name)
        return self
    end

    function Node:find(...)
        local node = self
        local args = {...}
        for i,v in ipairs(args) do
            node = node:getChildByName(v)
            if not node then 
                print("not found:",v)
                return 
            end
        end
        return node
    end

    function Node:zorder(zorder)
        if zorder then
            self:setLocalZOrder(zorder)
            return self
        else
            return self:getLocalZOrder()
        end
    end

    function Node:scale(scale,sy)
        if sy then 
            self:setScaleX(scale)
            self:setScaleY(sy)
        else
            if scale then
                self:setScale(scale)
            else
                return self:getScale()
            end
        end
        return self
    end

    function Node:delayTo(t,listener)
        transition.execute(self,nil,
            {delay = t,
            onComplete = listener})
        return self
    end

--ListView
    function ccui.ListView:removeItemWithAction(index)
        local timeDevided = 0.1
        local item = self:getItem(index)
        transition.execute(
            item, 
            {
                transition.moveTo(item, {time=timeDevided, x=-1000, y=item:getPositionY()})
            },
            {delay=timeDevided*2, onComplete = function()
                self:removeItem(index)
                self:forceDoLayout()
            end}
        )
    end

--TODO:
    function Node:gzorder(zorder)
        if not zorder then
            return self:getGlobalZOrder()
        end
        self:setGlobalZOrder(zorder)
        return self
    end

    function Node:exist(t)
        self:delayTo(t,function()
            if self.remove then
                self:remove()
            else
                self:safeRemove()
            end
        end)
        return self
    end

    function Node:tint(from,to,time)
        self:setColor(from)
        self:runAction(cc.TintTo:create(time,to.r,to.g,to.b))
        return self
    end

    function Node:polar(angle,length)
        self:move(math.cos(angle)*length,math.sin(angle)*length)
        return self
    end

    function cc.Node:doCoroutine(key,callback,params)
        self._coNode = self._coNode or {}
        if self._coNode[key] == "removed" then 
            self._coNode[key] = nil
            return
        end 
        self._coNode[key] = self._coNode[key] or display.newNode():addTo(self):onUpdate(function()
            if callback and callback(params) then
                self._coNode[key]:removeSelf()
                self._coNode[key] = "removed"
            end
        end)
    end
    -- function Node:onTouch(listener)
    --  self:setTouchEnabled(true)
    --  self:addNodeEventListener(cc.NODE_TOUCH_EVENT, listener)
    --  return self
    -- end

--Touch
    function cc.Node:hitTest(p,y)
        if y then
            p = cc.p(p,y)
        end
        local nsp = self:convertToNodeSpace(p)
        local bb = cc.rect(0,0,self:getContentSize().width,self:getContentSize().height)
        if (cc.rectContainsPoint(bb,nsp)) then
            return true
        end
        return false
    end
    function cc.Node:isVisibleInTree()
        if not self:isVisible() then
            return false
        end
        local parent = self:getParent()
        if parent then
            return parent:isVisibleInTree()
        end
        return true
    end
    function cc.Node:clippingHitTest(point)
        local parent = self:getParent()
        while parent do
            if iskindof(parent,"cc.ClippingRectangleNode") then
                return cc.rectContainsPoint(parent:getClippingRegion(),parent:convertToNodeSpace(point))
            end
            if iskindof(parent,"ccui.ListView") then
                return cc.rectContainsPoint(parent:size(),parent:convertToNodeSpace(point))
            end
            parent = parent:getParent()
        end
        return true
    end

    function cc.Node:onTouch(callback,swallowTouches,isMultiTouches)
        local isMultiCancelled = true
        local function isInRegion(x,y)
            if not y then
                y = x.y
                x = x.x
            end
            local p = cc.p(x,y)
            return self:hitTest(p)
        end
        local function isTouchable(x,y)
            if not y then
                y = x.y
                x = x.x
            end
            local p = cc.p(x,y)
            return self:clippingHitTest(p) and self:isVisibleInTree()
        end
        self.__touchNode = display.newLayer():addTo(self)
        self.__touchNode:setContentSize(self:getContentSize())
        self.__touchNode:onTouch(function(event)
            if not isTouchable(event) then return false end
            if isInRegion(event) or event.name ~= "began" then
                if event.name == "began" then
                    event.prevX = event.x
                    event.prevY = event.y
                else
                    event.prevX = self.__touchNode.__prevX
                    event.prevY = self.__touchNode.__prevY
                end
                self.__touchNode.__prevX = event.x
                self.__touchNode.__prevY = event.y
                return callback(event)
            end
        end,isMultiTouches, swallowTouches)
        return self
    end
    function cc.Node:setEnabled(bEnabled)
        self.__touchNode:setTouchEnabled(bEnabled)
        return self    
    end
        function cc.Node:onTouch2(callback,swallowTouches,isMultiTouches)
            cc.Node.__touchNode2 = display.newLayer(iif(DEBUG_TOUCH,cc.c4b(255,0,0,128),nil)):addTo(self,1)
            cc.Node.__touchNode2:setContentSize(self:getContentSize())
            cc.Node.__touchNode2:onTouch(function(event)
                if self:hitTest(cc.p(event.x,event.y)) or event.name ~= "began" then
                    if event.name == "began" then
                        event.prevX = event.x
                        event.prevY = event.y
                    else
                        event.prevX = self.__touchNode2.__prevX
                        event.prevY = self.__touchNode2.__prevY
                    end
                    callback(event)
                    self.__touchNode2.__prevX = event.x
                    self.__touchNode2.__prevY = event.y
                    return true
                end
            end,isMultiTouches, swallowTouches)
            return self
        end
        
        function cc.Sprite:onClick(callback)
            self:onTouch(function(event)
                if event.name == "began" then
                    self._shouldCallback = true
                elseif event.name == "ended" then
                    if self:hitTest(event) and self._shouldCallback and callback then callback(event) end
                    self._shouldCallback = false
                end
                return true
            end,true)
            return self
        end
--display
    function display.loadplist(filename)
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/"..filename..".plist")
    end

    function display.newAnimSprite(image,ifrom,ito,isrepeat,interval,timeFrom)
        local sprite = display.newSprite(nil,lat,lng)
        local frames = display.newFrames(image,ifrom,ito)
        local animation = display.newAnimation(frames, interval or 0.1)
        local action = cc.Animate:create(animation)
        if timeFrom then action:setDuration(timeFrom) end
        if isrepeat then
            sprite:runAction(cc.RepeatForever:create(action))
        else
            sprite:runAction(cc.Sequence:create(
                action,
                cc.CallFunc:create(function()
                    --sprite:removeSelf()
                end)
            ))
        end
        return sprite
    end

    function display.enterScene(sceneName)
        print("enterScene:",sceneName)
        display.sceneName = sceneName
        if display.currentScene and display.currentScene.onExit then
            display.currentScene:onExit()
        end
        display.currentScene = require("app.views."..sceneName).new()
        cc.Director:getInstance():replaceScene(display.currentScene)
        -- if nextScene.onEnter then
        --     nextScene:onEnter()
        -- end
    end

    function display.createLabel(text, color, size, fontSize)
        local label = cc.Label:createWithSystemFont(tostring(text or ""),"Arial", fontSize or 30, size or cc.size(0,0))
        label:setAnchorPoint(cc.p(0, 0.5))
        if color then label:setColor(color) end
        return label
    end

    function display.newFlash(image,ifrom,ito,callback,interval)
        local sprite = display.newSprite()
        local frames = display.newFrames(image,ifrom,ito-ifrom+1)
        local animation = display.newAnimation(frames, interval or 1/30)
        local action = cc.Animate:create(animation)
        sprite:runAction(transition.create(action,{removeSelf = true,onComplete = callback}))
        return sprite
    end
    
    function display.newAnimationFromFile(image,ifrom,ito,callback,interval)
        local anim = cc.Animation:create()
        for i=ifrom,ito do
            anim:addSpriteFrameWithFile(image:format(i))
        end
        anim:setDelayPerUnit(interval or 1/10)
        anim:setRestoreOriginalFrame(true)
        -- anim:retain()
        return cc.Animate:create(anim)
    end

    function display.newGif(image,ifrom,ito,interval)
        local sprite = display.newSprite()
        local frames = display.newFrames(image,ifrom,ito-ifrom+1)
        local animation = display.newAnimation(frames, interval or 1/30)
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        action:setTag(100)
        sprite:runAction(action)
        return sprite
    end

    function cc.Sprite:playGif(image,ifrom,ito,interval)
        local frames = display.newFrames(image,ifrom,ito-ifrom+1)
        local animation = display.newAnimation(frames, interval or 1/30)
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        self:stopActionByTag(100)
        action:setTag(100)
        self:runAction(action)
        return self
    end

    -- function cc.Scale9Sprite:insets(x,y)
    --     local size = self:size()
    --     self:setCapInsets(cc.rect(size-size.width*x/2,0.5-size.height*y/2,size.width*x/2,size.height*y/2))
    --     return self
    -- end

-- function isRunning(sceneName)
-- 	local scene = cc.Director:getInstance():getRunningScene()
-- 	print("scene:"..type(scene))
-- 	if scene then
-- 		return iskindof(scene,sceneName)
-- 	end
-- end

    function cc.Scale9Sprite:fillCapInset()
        self:setCapInsets(cc.rect(0,0,self:size().width,self:size().height))
        return self
    end
    function cc.Node:setUrl(url)
        local succeedCallback,failCallback
        function download()
            local url = url--release upvalue:url
            loadTextureFromUrl(url,succeedCallback,failCallback)
        end
        function succeedCallback(filepath)
            if cc.Node.isnull(self) then return end
            local sz = newp(self:size().width*self:getScaleX(),self:size().height*self:getScaleY())
            self:scale(1)
            self:setTexture(filepath)
            self:scaleToSize(sz.x,sz.y)
        end
        function failCallback()
            if cc.Node.isnull(self) then return end
            download()
        end
        if #url==0 then return self end
        download()
        return self
    end

    function loadTextureFromUrl(url,callback,failCallback)
        -- print("download from",url)
        local strArray = string.split(url,"/")
        local filepath = device.writablePath .. "/" .. strArray[#strArray-1]
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
        xhr:open("GET", url)
        local function onResponse()
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                -- xhr.response = string.gsub(xhr.response,"\\u(%w%w%w%w)",function(s)
                --  print "find"
                --  return "\\u{"..s.."}"
                -- end)
                local file = io.open(filepath,"wb")
                file:write(xhr.response)
                file:close()
                if callback then
                    -- print("load from",filepath)
                    callback(filepath)
                end
            else
                if failCallback then failCallback() end
                -- print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
            end
        end
        xhr:registerScriptHandler(onResponse)
        xhr:send()
    end
scheduler = cc.Director:getInstance():getScheduler()
