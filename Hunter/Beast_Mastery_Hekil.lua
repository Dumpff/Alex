local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
-- on top of the CR
local ui = function(key) return _A.DSL:Get("ui")(_, key) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local keybind = function(key) return _A.DSL:Get("keybind")(_, key) end
-- etc.. for DSLs/Methods that do not require target
local DSL = function(api) return _A.DSL:Get(api) end



local tanksIds = {
    [250] = "DK Blood",
    [581] = "DH Vengeance",
    [104] = "Druid Guardian",
    [268] = "Monk Brewmaster",
    [66] = "Paladin Protection",
    [73] = "Warrior Protection",
}
-- Tank
_A.FakeUnits:Add('realTank', function(num)
    local tempTable = {}
    for _, Obj in pairs(_A.OM:Get("Roster")) do
        if Obj.isplayer and tanksIds[Obj:spec() or 0] then
            tempTable[#tempTable+1] = {
                key = Obj.key,
                prio = Obj:healthMax()
            }
        end
    end
    if #tempTable>1 then
        table_sort( tempTable, function(a,b) return a.prio > b.prio end )
    end
    return tempTable[num] and tempTable[num].key
end)



----------------------------
_A.DSL:Register("InstanceType", function(_, name)
    local itype = U.InstanceType or select(2, IsInInstance())
    if not name then
        return itype
    end    
    return itype:lower() == name:lower()
end)
-----------------------------
_A.DSL:Register("pvpzone", function()
    local iType = DSL("InstanceType")()
    return iType=="arena" or iType=="pvp"
end)
-----------------------------
_A.DSL:Register("indungeon", function()
    local iType = DSL("InstanceType")()
    return iType == "party" or iType == "raid"
end)
-----------------------------


---------------------------------------------Для команды Взять----------------------------------------------------------------

_A.DSL:Register("kludge", function(to, id) 
    ids = tonumber(id)
    if not ids then return end
    _A.CastSpellByID(ids, to)
end)
------------------------------------------------------------------------------------------------------------------------------------------------

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
    
    -------------------------------------------------------------------------------------------------------------




local GUI = {  
    {type = "checkbox", cw = 15, ch= 15, size = 15, text = "Повернуться, подойти к цели", key = "povorot", default = false},
    {type = "spacer", size = 7},
    {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(187698, 16, 16, true), key = "smola", default = false},           --мультидотинг
    {type = "spacer", size = 7},
    {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(187650, 16, 16, true), key = "moroz", default = false},           --мультидотинг
    {type = "spacer", size = 7},
    }   

local spell_ids = {
    ["auto.shoot"] = 75,
   -- ["Освежающее лечебное зелье"] = 191378,
	["Mend Pet"] = 136,
	["Kill Command"] = 34026,
	["Cobra Shot"] = 193455,
	["Kill Shot"] = 53351,
	["Exhilaration"] = 109304,
	["Multi-Shot"] = 2643,
	["Barbed Shot"] = 217200,
	["Counter Shot"] = 147362,
	["Survival of the Fittest"] = 264735,
	["Tranquilizing Shot"] = 19801,
	["Bestial Wrath"] = 19574,
	["Hunter's Mark"] = 257284,
    ["ResPet"] = 982,
    ["Intimidation"] = 19577,
    ["Death Chakram"] = 375891,    
    ["Blood Fury"] = 20572, --рассовая орк
    ["Исступление"] = 272678, -- петовская
    ["Изнеможение"] = 57723,
    ["Стенающая стрела"] = 392060,
    ["Дух черепахи"] = 186265,
    ["Выносливость медведя"] = 272679,    
    ["Связующий выстрел"] = 109248,
    ["Перенаправление"] = 34477,
    ["Команда \"Взять!\""] = 34026,
    ["Замораживающая ловушка"] = 187650,
    ["Смоляная ловушка"] = 187698,

}

local exeOnLoad = function()
    print("BM was loaded")
    _A.Interface:ShowToggle("Cooldowns", false)
   -- _A.Interface:ShowToggle("aoe", false)
    _A.Interface:AddToggle({key = "AutoTarget", name = "Авто Таргет", text = "Автотаргет когда цель умерла или не существует", icon = "Interface\\Icons\\ability_hunter_snipershot",})
    _A.Interface:AddToggle({key = "AutoLoot", name = "Авто Лут", text = "Автоматически лутает мобов вокруг вас", icon = "Interface\\Icons\\inv_misc_gift_05"})
    -- _A.Interface:AddToggle({key="Burst", display=false}) 
    -- _A.Interface:ShowToggle("Burst", false)
 
    ------------------------------------------------------------
    _A.Library:Add("myLib", {
        -- face target
        face = function()
            if not _A.UnitIsFacing("player", "target", 180) then
                _A.FaceTarget()
                return true
            end
        end,
    })
    ------------------------------------------------------------


end

local exeOnUnload = function()
end

local Rotation = {  
--     {"%pause", "lost.control"},    
--     {"@myLib.face", "ui(povorot) ", "target"},
--     {"Kill Shot", "spell.ready && los && !target.dead", "target"},
--     {"Hunter's Mark", "spell.ready && isboss && !debuff && timeout(HMark, 0.2)", "target"},
--     --{"Blood Fury", "spell.ready && isboss", "target"},
--     {"Blood Fury", "spell.ready"},
--     {"Death Chakram", "spell.ready && los && !target.dead", "target"},--
    -- {"Перенаправление", "spell.ready && spell.range && indungeon", "realTank"},
    -- {"Перенаправление", "spell.ready && spell.range && pet.exists && !indungeon", "pet"},--
 	{"!Barbed Shot", "spell.ready && spell.range && los && !debuff", "enemycombat"},--   
--     ---------{"%Разрывающий выстрел", nil, "target"}, 
-- 	-------- {"A Murder of Crows", "talent", "target"},
-- 	-------- {"Stampede", "talent && ttd>24 && {player.buff(Bloodlust) || player.buff(Bestial Wrath) || spell(Bestial Wrath).cooldown<3}", "player"},
-- 	-------- {"Dire Beast", "spell(Bestial Wrath).cooldown>3", "target"},
-- 	-------- {"Dire Frenzy", "talent && {pet.buff(Dire Frenzy).duration<=1.5 || spell(Dire Frenzy).charges>0.8}", "target"},
-- 	-------- {"Chimaera Shot", "talent &&  player.focus<90", "target"},
-- 	{"Bestial Wrath", "spell.ready && pet.exists && !pet.dead", "pet"},--



-- {"Команда \"Взять!\"", nil, "target"},
-- {"34026", nil, "target"},



-- {function(t)
--   --  _A.SpellStopCasting()
--     _A.CastSpellByID(34026, t)
--   end, "exists && spell(34026).ready && pet.exists && los", "target"},



  {function(t)
    -- _A.SpellStopCasting()
     _A.CastSpellByID(34026, t)
   end, "spell(34026).ready && pet.exists && !pet.dead", "target"},


--     {function() _A.CastSpellByID(34026, "target", true) end, "spell(34026).ready && los", "target"},            --команда взять---
 
-- {"6603", "spell(34026).ready && kludge(34026)", "target"}, --  at least it do the job :D
--     --{function() _A.CastSpellByID(272651, "pet") end, "exists && spell(272651).ready && !player.debuff(Изнеможение) && pet.exists", {"Boss1", "player"}},                          -- умение пета

 --    {"Исступление", "!player.debuff(57723) && !player.debuff(Изнеможение) && spell.ready && isboss && pet.exists && timeout(Исступление,1.5)", "target"},


    
-- 	--------{"Kill Command", "spell.ready", "target"},
--    -- {"Стенающая стрела", "spell.ready && spell.range", "target"},
-- 	{"Cobra Shot", "spell.ready && los && player.focus>30 && !target.dead", "target"},--
    --
	------- {"Concussive Shot", "spell.range && player.focus<40", "target"},
}

local AOE = {
	-- {"A Murder of Crows", "talent", "target"},
	-- {"Barrage", nil, "target"},   
    {"Связующий выстрел", "spell.ready && los && area(5).enemies>2 && !debuff(135299)", "target.ground"}, --117405
    {"Смоляная ловушка", "ui(smola) && spell.ready && los && area(8).enemies>2 && !debuff(117405) && spell(Связующий выстрел).cooldown > 3", "target.ground"}, --135299
	--  {"Multi-Shot", "spell.ready && !player.buff(Удар зверя) && los && !target.dead", "target"},
	--  {"Multi-Shot", "spell.ready && los && pet.buff(Удар зверя).duration<3 || !pet.buff(Удар зверя) && !target.dead", "target"},
	-- {"Chimaera Shot", "talent &&  player.focus<90", "target"},
	-- {"Kill Command", nil, "target"},
	-- {"Cobra Shot", nil, "target"},
}	


local Survival = {
    {"#Камень здоровья", "player.health <=60 && item(Камень здоровья).count>0 && item(Камень здоровья).usable", "player"},
    {"#Освежающее лечебное зелье", "player.health<=25 && item(Освежающее лечебное зелье).count>0 && item(Освежающее лечебное зелье).usable", "player"},
    {"Выносливость медведя", "exists && spell.ready && player.health <=60 && pet.exists", "player"},
    {"Дух черепахи", "spell.ready && health<=27", "player"},

    {"%cancelbuff(Дух черепахи)", "buff(Дух черепахи) && health >=50", "player"},

    
	{"Exhilaration", "spell.ready && health<=40", "player"},
	{"Mend Pet", "spell.ready && health<=75 && !pet.dead && pet.exists && timeout(Mend, 0.2)", "pet"},
    {"ResPet", "pet.dead && timeout(ResPet, 0.2) && pet.exists", "pet"},
    {"Survival of the Fittest", "!lastcast(Exhilaration) && spell.ready && health <=50", "player"},  


    {"/petautocastoff Рык", "!isSolo && spell(Рык).AutocastEnabled"},
    {"/petautocaston Рык", "isSolo && !spell(Рык).AutocastEnabled"},

    --  {"/petautocastoff Рык", "!issolo", "pet"},
    --  {"/petautocaston Рык", "issolo", "pet"},



    -- {"/petautocastoff Рык", "!issolo", "pet"},
    -- {"/petautocaston Рык", "issolo", "pet"},

    -- {"/petautocastoff Рык", "roster.hasrole(TANK)", "pet"}, --indungeon


    -- {"/petautocastoff Рык", "indungeon", "pet"},
    -- {"/petautocaston Рык", "!indungeon", "pet"},
    
    
    -- {"Survival of the Fittest", "!lastcast(Exhilaration) && spell.ready && incdmg(3)>=health.max*0.4", "player"},    
  }

  local Trini = {
    
    -- {"#trinket1", "equipped(197960) && item(197960).usable", "player"},
    -- {"#trinket1", "equipped(193757) && item(193757).usable && los", "target"},
    -- {"#trinket1", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable && los", "target.ground"},
    -- {"#trinket1", "equipped(193769) && item(193769).usable && los", "target.ground"},
    -- {"#trinket1", "equipped(Giant Ornamental Pearl) && item(Giant Ornamental Pearl).usable", "player"},
    -- {"#trinket1", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},
    
    -- {"#trinket2", "equipped(197960) && item(197960).usable", "player"},
    -- {"#trinket2", "equipped(193757) && item(193757).usable && los", "target"},
    -- {"#trinket2", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable && los", "target.ground"},
    -- {"#trinket1", "equipped(193769) && item(193769).usable && los", "target.ground"},
    -- {"#trinket2", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},
    -- {"#trinket2", "equipped(Coagulated Nightwell Residue) && item(Coagulated Nightwell Residue).usable && buff(Nightwell Energy).count>=8", "player"},

    -- {"#133642", "equipped(133642) && item(133642).usable", "player"},
    -- {"#193701", "equipped(193701) && item(193701).usable", "player"},
  }

local Interrupts = {        
	-- {"*Tranquilizing Shot", "spell.ready && target.buff(Magic).type", "target"},
	-- {"*Tranquilizing Shot", "spell.ready && target.buff(Enrage).type", "target"},

    {"Tranquilizing Shot", "spell.ready && buff(Magic).type && los", "enemycombat"},
	{"Tranquilizing Shot", "spell.ready && buff(Enrage).type && los", "enemycombat"},
	 --{"Counter Shot", nil, "EnemyCombat"},

    --  {{
    --     {"*Tranquilizing Shot", "spell.range && {buff(Enrage).type || buff(Magic).type}", "enemycombat"},---------
    -- }, "spell.ready"},
     
    -- {{
    --     {"Tranquilizing Shot", "exists", "TS_enraged_magic", "enemycombat"},
    -- }, "talent(Tranquilizing Shot) && spell(Tranquilizing Shot).ready"},

    {{
        {"Counter Shot", "isCastingAny && interruptible && interruptAt(10) && los", "EnemyCombat"},
    }, "toggle(Interrupts) && spell(Counter Shot).ready"}, 
    
    {{
        {"Intimidation", "pet.exists && !pet.dead && isCastingAny && !immune", "EnemyCombat"},
    }, "toggle(Interrupts) && spell(Intimidation).ready &&  spell(Counter Shot).cooldown > 3"},

    {{
        {"Замораживающая ловушка", "exists && isCastingAny && interruptible && interruptAt(10) && !immune", "enemycombat.ground"},
    }, "toggle(Interrupts) && ui(moroz) && spell(Замораживающая ловушка).ready &&  spell(Counter Shot).cooldown > 3 && && spell(Intimidation).cooldown > 3 && !lastcast(147362)"},
 }
local Cooldowns = {
}

local Keybinds = {
    -- {function() _A.Interface:toggleToggle("AoE") end, "keybind(shift) && timeout(tAoE, 0.5)"},
    -- {function() _A.Interface:toggleToggle("Burst") end, "keybind(LCtrl) && timeout(tBurst, 0.5)"},
}


local Validate = {
  --  {'/startattack', '!auto.shoot'},   
    {Trini},		
    {Interrupts, "toggle(Interrupts)"},    
	{AOE, "area(15).enemies>=2 && toggle(aoe)"},
	{Rotation},
      
}

local inCombat = {
    {"%pause", "lost.control"},
    {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"}, --автотаргет
    {Keybinds},
    {Survival},	
    {Validate},
}
local outOfCombat = {  
    {Keybinds},
	{Survival},    
    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<7", "dead"},
    -- {"/petautocastoff Рык", "!issolo", "pet"},
    -- {"/petautocaston Рык", "issolo", "pet"},
}

_A.CR:Add(253, {
    name = "[BM_Хекли_Комп]",
    load = function()
        print("Load function executed")
        exeOnLoad()
    end,
    gui = GUI,
    gui_st = {title="BM by Алексей", color="1EFF0C", width="400", height="500"},
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