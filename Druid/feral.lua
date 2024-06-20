local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
local DSL = function(api) return _A.DSL:Get(api) end
-- on top of the CR
local ui = function(key) return _A.DSL:Get("ui")(_, key) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local keybind = function(key) return _A.DSL:Get("keybind")(_, key) end
-- etc.. for DSLs/Methods that do not require target
local DSL = function(api) return _A.DSL:Get(api) end


local NoThreatUnits = {
    --[161895] = "Thing From Beyond", -- BFA
    --[120651] = "Explosives", -- Explosive Affix (since Legion)
    --[174773] = "Spiteful Shade", -- Spiteful Affix (BFA)
}   

-- _A.DSL:Register('targetme', function(unit)
--     local tarGUID = _A.UnitTarget(unit)
--     u.MeGUID = u.MeGUID or _A.UnitGUID("player")
--     return u.MeGUID==tarGUID
-- end)


_A.DSL:Register('tagme', function(unit)
    local isSame = UnitIsUnit(unit, "player")
       return isSame
    end)

-- Best candidate for aggro spell

_A.FakeUnits:Add('bestCandidateFor', function(num, spell)
    local tempTable = {}
    for _, Obj in pairs(_A.OM:Get('EnemyCombat')) do
        if _A.UnitExists(Obj.guid) and DSL("spell.range")(Obj.guid, spell) then
            tempTable[#tempTable+1] = {
                guid = Obj.guid,
                threat = select(3, _A.UnitDetailedThreatSituation("player", Obj.gui))
            }
        end
    end
    table.sort( tempTable, function(a,b) return a.threat < b.threat end )
    return tempTable[num] and tempTable[num].guid
end)



_A.FakeUnits:Add("druid_taunt", function(num)
    local tempTable = {}
    for _, Obj in pairs(_A.OM:Get("EnemyCombat")) do
        if not NoThreatUnits[Obj.id] 
           and Obj.distance<=30 
           and _A.DSL:Get("timetodie")(Obj.guid) >=2 then
            if _A.UnitExists(Obj.guid) then
                local isTanking = _A.UnitDetailedThreatSituation("player", Obj.guid)
                if isTanking==false then
                    tempTable[#tempTable+1] = {
                        guid = Obj.guid,
                        health = Obj.healthRaw
                    }
                end
            end
        end
    end 
    if #tempTable<1 then return end
    table.sort( tempTable, function(a, b) return a.health > b.health end )
    return tempTable[num] and tempTable[num].guid         
end)

-------------------------------------Для иконок заклинаний и предметов--------------------------------------

local function FlexItem(itemID, width, height, bool) -- bool true или false, true - с именем, false - просто иконка.
    local itemIcon = GetItemIcon(itemID) 
    local var = " \124T"..(itemIcon)..":"..(height or 25)..":"..(width or 25).."\124t "
    if bool then
        return var .. GetItemInfo(itemID)
    else
        return var
    end
    end
    
    local function FlexIcon(SpellID, width, height, bool) -- bool true или false, true - с именем, false - просто иконка.
        local var = " \124T" .. (select(3, GetSpellInfo(SpellID)) or select(3, GetSpellInfo(24720))) .. ":" .. (height or 25) .. ":" .. (width or 25) .. "\124t ";
        if bool then
            ico = var .. GetSpellInfo(SpellID)
        else
            ico = var
        end
        return ico
    end



    local path = _A.CalculatePath(1129.7, -4223.4, 22.1, false)
for i, point in ipairs(path) do
    local x, y, z = unpack(point)
    print(string.format("Point %d: (%f, %f, %f)", i, x, y, z))
end
    
    -------------------------------------------------------------------------------------------------------------

    local exeOnUnload = function()
    end

    local Bless_List = {
        {key = "1", text = "С себя"},
        {key = "2", text = "С союзников"},    
        {key = "0", text = "Отключено"},
    }

local GUI = {
    {type = "ruler"},
    {type = "header", text = "Настройки", align = "center", size = "16", offset = 15},
    {type = "ruler"},
    {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(8921, 16, 16, true), key = "kach", default = false},                            --Кач                       
    {type = "spacer", size = 7},
    {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(5215, 16, 16, true), key = "ten", default = false},                            --Крадущийся зверь                       
    {type = "spacer", size = 7},
    {type = "dropdown", width = 180, size = 14, text = FlexIcon(2782, 16, 16, true), key = "blesstype", list = Bless_List, default = "1"},
    {type = "spacer", size = 7},
    {type = "ruler"},
    {type = "header", text = "Профессии", align = "center", size = "16", offset = 15},
    {type = "ruler"},
    {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(13262, 16, 16, true), key = "Disenchant", default = false},                            --Кач                       
    {type = "spacer", size = 7},
    -- {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(5487, 16, 16, false).."Автоформа", key = "form", default = false},                            --Автоформа                       
    -- {type = "spacer", size = 7},
    -- {type = "input", cw = 15, ch= 15, size = 15, text = FlexIcon(20484, 16, 16, true), key = "ress", width = 65, default = "R"},
    -- {type = "spacer", size = 7},
}

local spell_ids = {

    ["Облик медведя"] = 5487,
    ["Дубовая кожа"] = 22812,
    ["Размах"] = 213771,
    ["Взбучка"] = 77758,
    ["Увечье"] = 33917,
    ["Трепка"] = 6807,
    ["Лунный огонь"] = 8921,
    ["Железный мех"] = 192081,
    ["Неистовое восстановление"] = 22842,
    ["Восстановление"] = 8936,
    ["Growl"] = 6795,
    ["Знак дикой природы"] = 1126,
    ["Водный облик"] = 783,
    ["Инстинкты выживания"] = 61336,
    ["Умиротворение"] = 2908,
    ["Лобовая атака"] = 106839,
    ["Созыв духов"] = 391528,
    ["Обновление"] = 108238,
    ["Смести"] = 400254,
    ["Берсерк"] = 26297,
    ["Крадущийся зверь"] = 5215,
    ["Озарение"] = 29166,
    ["Снятие порчи"] = 2782,






    ["Disenchant"] = 13262, -- распыление

}


local proffesions = {    

}



local exeOnLoad = function()     
    
    print("Погнали НАХУЙ!") -- Напишите своё      
    _A.Interface:ShowToggle("Cooldowns", false)   
    _A.Interface:AddToggle({key = "AutoTarget", name = "Авто Таргет", text = "Автотаргет когда цель умерла или не существует", icon = "Interface\\Icons\\ability_hunter_snipershot",})
    _A.Interface:AddToggle({key = "AutoLoot", name = "Авто Лут", text = "Автоматически лутает мобов вокруг вас", icon = "Interface\\Icons\\inv_misc_gift_05"})
    -- _A.Interface:AddToggle({key="taunt", icon=132270, name="Авто Агро", text= "|rАвто "..GetSpellLink(6795).." Работает только в групповых подземельях, на врагов которые в бою с членами группы"}) 
    -- _A.Interface:AddToggle({key="Burst", display=false}) 
    -- _A.Interface:ShowToggle("Burst", false)
  --  _A.Interface:AddToggle({key = "convokeKey", name = "Convoke", text = "Enabled/Disable Convoke the Spirits", icon = "Interface\\Icons\\ability_ardenweald_druid",})
end



-- local SelfProtect = {
--     {"Неистовое восстановление", "buff(5487) && incdmg(3) > health.max * 0.33","player"},
--     {"Восстановление","buff(372152)","player"},

     
-- }
local SelfProtectAlly = {
}

local Forms ={

    -- {"Облик медведя","ui(form) && spell.ready && !buff(5487) && !mounted to(BearForm, 0.3)", "player"}, 
}

local Survival = {
    
    -- {"Знак дикой природы","!buff", "player"}, 
    -- {"Знак дикой природы","!buff && indungeon", "roster"},


    -- {function()
    --     local px, py, pz = _A.ObjectPosition("player")
    --     print(px, py, pz)
    --     end},

    {"#Камень здоровья", "player.health <=60 && item(Камень здоровья).count>0 && item(Камень здоровья).usable", "player"},
    {"#Освежающее лечебное зелье", "player.health<=25 && item(Освежающее лечебное зелье).count>0 && item(Освежающее лечебное зелье).usable", "player"},
    {"!Восстановление","spell.proc && health <= 90","player"},
    {"Озарение", "exists && spell.ready && spell.range && hasrole(Healer) && mana <=50", "roster"},

    {"%dispelself", "spell(Снятие порчи).ready", "player"},
    {"%dispelall", "spell(Снятие порчи).ready && spell.range", "roster"},

    {{
        {"Снятие порчи", "exists && spell.range", "friendlyID(204773)"},
    }, "spell(Снятие порчи).ready"},

    -- {"Снятие порчи", "ui(blesstype)=1 && spell.ready && debuff(Poison).type ", "player"},
    -- {"Снятие порчи", "ui(blesstype)=1 && spell.ready && debuff(Curse).type ", "player"},
    -- {"Снятие порчи", "ui(blesstype)=2 && exists && spell.ready && spell.range && debuff(Poison).type ", "roster"},
    -- {"Снятие порчи", "ui(blesstype)=2 && exists && spell.ready && spell.range && debuff(Curse).type ", "roster"},
    {"Лунный огонь", "ui(kach) && spell.ready && spell.range && !debuff", "Enemies"},
    {"Умиротворение", "spell.ready && buff(Enrage).type", "enemycombat"},
--     {"Возрождение", "keybind({ui(ress)}) && spell.ready && spell.range && dead", "roster"},
--    {"Обновление", "spell.ready && health<=65", "player"},
--    {"Инстинкты выживания", "spell.ready && health<=40", "player"},
   
--    {"Знак дикой природы","!buff", {"player", "roster"}},
--    {"Восстановление","buff(372152)","player"},
--    {"Неистовое восстановление", "spell.ready && health<=67 && !lastcast(Неистовое восстановление)","player"},
--    --{"Неистовое восстановление", "spell.ready && buff(5487) && !buff && incdmg(3) > health.max * 0.5","player"},
--    {"Восстановление", "spell.ready && health<=25", "player"},
}

-- local Rotation = {

    

--     --{"Rejuvenation", "!buff && health<=25", "player"},
--     {"Growl", "exists && toggle(taunt) && spell.ready && indungeon", "druid_taunt"}, -- 
--     --{"Growl", "spell.ready && !targetme && !fleeing", "nearEnemyCb"},
--     {"Железный мех", "rage >= 40 && buff.stack < 3 && buff(5487) && exists","player"},
--     --{"!Увечье","spell.range && spell.ready && spell.proc","target"},
--     --{"Железный мех", "buff.stack == 3 && buff.duration < gcd + 0.5 && rage >= 40","player"},
--     --{"Лунный огонь","exists && !debuff && spell.range", "enemiesCombat"},
--     {"Лунный огонь", "spell.proc && spell.range", "target"},
--     {"Трепка","range < 8 && spell.proc","target"},--range < 8
--     {"Взбучка","range < 8 && spell.ready","target"},--range < 8
--     {"Увечье","range < 8 && spell.ready","target"},--range < 8
--     {"Размах","spell.ready && && spell(Увечье).range && !spell(Взбучка).ready && !spell(Увечье).ready","target"},--range < 8 && !spell(Взбучка).ready && !spell(Увечье).ready
--     {"Дубовая кожа","spell.ready && !player.buff && incdmg(3) > health.max * 0.5"},

-- }

local Rotation = {

    

    --{"Rejuvenation", "!buff && health<=25", "player"},
    -- {"Созыв духов","spell.ready && isboss", "target"},

     --{"Созыв духов", "spell.ready && {isboss || toggle(Burst)}", "target"},
    --  {"Созыв духов", "spell.ready && {toggle(Burst) || isboss}", "target"},
     --{"Созыв духов", "spell.ready && toggle(Burst)", "target"},
     --{"Созыв духов", "spell.ready && isboss", "target"},
    


    -- {function()
    --     if _A.DSL:Get("spell.ready")(_, spell_ids["Созыв духов"]) then                  
    --     local Enemy = _A.OM:Get('EnemyCombat')    
    --         if _A.DSL:Get("isboss")("target")
    --         or _A.DSL:Get("toggle")(_, "Burst") then
    --             _A.CastSpellByID(spell_ids["Созыв духов"])                              
    --         end 
    --     end
    -- end,},



    -- {{
    --     {"*Созыв духов", "isboss", "target"},
    -- }, "toggle(taunt) && spell(Созыв духов).ready"},


--     {"Лунный огонь","exists && spell.range && !immune && target.debuff(164812).duration.any<= 3", "target"},
--     {"Смести","spell.ready", "target"},
--     {"!Смести","spell.ready && spell.proc", "target"},
--     {"!Увечье","spell.range && spell.ready && spell.proc","target"},
--    -- {"Growl", "exists && !tagme && toggle(taunt) && spell.ready && indungeon", "bestCandidateFor(Growl)"}, -- 
--    {"Growl", "toggle(taunt) && spell.ready && !targetme", "bestCandidateFor(Growl)"},
--    --{"Growl", "toggle(taunt) && spell.ready && !targetme", "enemycombat"},
--     --{"Growl", "spell.ready && !targetme && !fleeing", "nearEnemyCb"},
--     {"Железный мех", "rage >= 40 && buff.stack < 3 && buff(5487) && exists","player"},
--     --{"!Увечье","spell.range && spell.ready && spell.proc","target"},
--     --{"Железный мех", "buff.stack == 3 && buff.duration < gcd + 0.5 && rage >= 40","player"},
--     --{"Лунный огонь","exists && !debuff && spell.range", "target"},
--     {"Лунный огонь", "spell.proc && spell.range", "target"},
--     {"Трепка","spell(Увечье).range && spell.proc","target"},--range < 8
--     {"Взбучка","spell(Увечье).range && spell.ready","target"},--range < 8
--     {"Увечье","spell.range && spell.ready","target"},--range < 8
--     {"Размах","spell.ready && && spell(Увечье).range && !spell(Взбучка).ready && !spell(Увечье).ready","target"},--range < 8 && !spell(Взбучка).ready && !spell(Увечье).ready
     {"&Дубовая кожа","spell.ready && !player.buff && incdmg(3) > health.max * 0.5"},

}

local AOE = {
    -- {"Созыв духов","spell.ready"},    
}

local Interrupts = {

    
    {"&Лобовая атака", "toggle(Interrupts) && spell.ready && isCastingAny && interruptible && los", "EnemyCombat"},
    

    -- {{
    --     {"Лобовая атака", "isCastingAny && interruptible && interruptAt(10) && los", "EnemyCombat"},
    -- }, "toggle(Interrupts) && spell(Лобовая атака).ready"}, 

}

local Trini = {
    
    
    {function() _A.CastSpellByID(26297, "player") end, "exists && spell(26297).ready", "player"},

    {"#trinket1", "equipped(197960) && item(197960).usable", "player"},
    {"#trinket1", "equipped(200552) && item(200552).usable", "player"},
    {"#trinket1", "equipped(193757) && item(193757).usable && los", "target"},
    {"#trinket1", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable && los", "target.ground"},
    {"#trinket1", "equipped(193769) && item(193769).usable && los", "target.ground"},
    {"#trinket1", "equipped(Giant Ornamental Pearl) && item(Giant Ornamental Pearl).usable", "player"},
    {"#trinket1", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},

    {"#trinket2", "equipped(197960) && item(197960).usable", "player"},
    {"#trinket1", "equipped(200552) && item(200552).usable", "player"},
    {"#trinket2", "equipped(193757) && item(193757).usable && los", "target"},
    {"#trinket2", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable && los", "target.ground"},
    {"#trinket1", "equipped(193769) && item(193769).usable && los", "target.ground"},
    {"#trinket2", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},
    {"#trinket2", "equipped(Coagulated Nightwell Residue) && item(Coagulated Nightwell Residue).usable && buff(Nightwell Energy).count>=8", "player"},

    {"#133642", "equipped(133642) && item(133642).usable", "player"},
    {"#200552", "equipped(200552) && item(200552).usable", "player"},
    {"#193701", "equipped(193701) && item(193701).usable", "player"},
  }

local Cooldowns = {
}
local Keybinds = {
    --  {function() _A.Interface:toggleToggle("AoE") end, "keybind(shift) && timeout(tAoE, 0.5)"},
    --  {function() _A.Interface:toggleToggle("Burst") end, "keybind(LCtrl) && timeout(tBurst, 0.5)"},

   -- {"toggle(AoE)", "keybind(lshift)"},
    --{function ()
        --local CBon = _A.DSL:Get("combat")("player")
        --local Bear = _A.DSL:Get("form")() == 1
        --_A.print(CBon, Bear)
       -- if CBon then
           -- if Bear then
               -- _A.CastShapeshiftForm(2) --Кот
                --_A.CastShapeshiftForm(1) --Мишка
            --else
               -- _A.CastShapeshiftForm(1) --Мишка
            --end
       -- else
            --if not _A.DSL:Get("indoors")() then
                --_A.CastShapeshiftForm(3)
            --end
        --end
   -- end,"keybind(lalt)"},
}

-- local keyboardframe = CreateFrame("Frame")
-- keyboardframe:SetPropagateKeyboardInput(true)
-- local function testkeys(self, key)
--     if key=="F1" then
--         if not _A.DSL:Get("toggle")(_,"MasterToggle") then
--             _A.Interface:toggleToggle("mastertoggle", true)
--             --_A._G.print("\124cffFFC300Feral Bear Alex \124cff00ff00Включено")
--             _A.DSL:Get("TextOnCenter")(_,"\124cff00ff00Feral Bear Alex")
--         else
--             _A.Interface:toggleToggle("mastertoggle", false)
--             --_A._G.print("\124cffFFC300Feral Bear Alex \124cffff0000Выключено")
--             _A.DSL:Get("TextOnCenter")(_,"\124cffff0000Feral Bear Alex")
--         end
--     end
-- end
-- keyboardframe:SetScript("OnKeyDown", testkeys)


local inCombat = { 
    {"%pause", "lost.control"},   
    {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"}, --автотаргет    
    {Survival},
  --  {Forms},
    {Keybinds},
    {Trini},
    {Interrupts, "toggle(Interrupts)"},
    {AOE, "area(15).enemies>=2 && toggle(aoe)"},
    {Rotation},
    --{Interrupts, "toggle(Interrupts)"},
   --{SelfProtect},
}
local outOfCombat = {
    {Survival},    
    {"&Крадущийся зверь","ui(ten) && spell.ready && !buff", "player"},
    {"Водный облик", "spell.ready && !buff(783) && player.swimming && to(WaterForm, 0.2)", "player"},   
    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<7", "dead"},
    {Keybinds}
}

_A.CR:Add(103, {
    name = "[Кот_Git]",
    load = function()
        print("Load function executed")
        exeOnLoad()
    end,
    gui = GUI,
    gui_st = {title="Кот by Алексей", color="1EFF0C", width="400", height="500"},
    ids = spell_ids,
    ic = inCombat,
    ooc = outOfCombat,
    blacklist = blacklist,
    --unload = exeOnUnload,
    wow_ver = "10.1.7",
    apep_ver = "1.1",
    unload = function()
        print("Unload function executed")
        exeOnUnload()
    end
})

