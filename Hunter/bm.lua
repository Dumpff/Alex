local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
-- on top of the CR
local ui = function(key) return _A.DSL:Get("ui")(_, key) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local keybind = function(key) return _A.DSL:Get("keybind")(_, key) end
-- etc.. for DSLs/Methods that do not require target
local DSL = function(api) return _A.DSL:Get(api) end












-- Lowest enemy
_A.FakeUnits:Add({'lowestenemy', 'loweste', 'le'}, function(num)
    local tempTable = {}
    for _, Obj in pairs(_A.OM:Get('Enemy')) do
        tempTable[#tempTable+1] = {
            key = Obj.key,
            health = Obj.health
        }
    end
    table_sort( tempTable, function(a,b) return a.health < b.health end )
    return tempTable[num] and tempTable[num].key
end)

---------------------------------------------------------Для ханта------------------------------------------------------------------------------

_A.FakeUnits:Add("TS_enraged_magic", function(num)
    local tempTable = {}
    for _, obj in pairs(_A.OM:Get("EnemyCombat")) do
        local prio = 0
        if obj:spellRange("Tranquilizing Shot") then
            if obj:buffType("Enrage") then
                prio=2
            elseif obj:buffType("Magic") then
                prio=1
            end
            if prio>0 then
                tempTable[#tempTable+1] = {
                    key = obj.key,
                    health = obj:healthActual(),
                    prio = prio,
                }
            end
        end
    end
    if #tempTable>1 then
        table.sort( tempTable, function(a,b) return (a.prio > b.prio) or (a.prio == b.prio and a.health > b.health) end )
    end
    return tempTable[num] and tempTable[num].key
end)






---------------------------------------------Для команды Взять----------------------------------------------------------------

_A.DSL:Register("kludge", function(to, id) 
    ids = tonumber(id)
    if not ids then return end
    _A.CastSpellByID(ids, to)
end)
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------

local flagBR = false
_A.DSL:Register("toggle_BR", function()
    if DSL("timeout")("player", "flagBR, 0.5") then
        flagBR = not flagBR
    end
    return true
end)

_A.DSL:Register("BR_state", function()
    return flagBR
end)


local keyT = {}
_A.DSL:Register("key.toggle", function(_, key_time)
    local key, xtime = _A.StrExplode(key_time)
    if not key then
      return _A.print("You must assign a name to the key")
    end
    xtime = tonumber(xtime) or 0.5
    if DSL("timeout")("player", key..","..xtime) then
        keyT[key] = not keyT[key]
    end
end)

_A.DSL:Register("key.on", function(_, key)
    return keyT[key]
end)







-------------------------------Отменить Ауру---------------------------------------------

-- _A.DSL:Register("CancelAura", function(_, id)
--     ids = tonumber(id)
--     if not ids then return end
--     local name = GetSpellInfo(ids);
--     if name then
--         _A.RunMacroText('/cancelaura '..name)  
--     end
-- end)

-------------------------------------Поиск по таблице--------------------------------------

local function find_unit(id)
    local c_table = _A.OM:Get('Friendly')
        for _, data in pairs(c_table) do
            if _A.ObjectExists(data.key) and data.id == id then
                return true
            end
        end
    return false
end

_A.DSL:Register("ObjExist", function(_, id)
    ids = tonumber(id)
    if not ids then return end
    local found = find_unit(ids);
    if found then
        return true    
    end
end)

------------------------------------------------------------------------------------------------------------
------------------------------------------------Босс--------------------------------------------------------

-- _A.DSL:Register({'isBoss', 'boss'}, function(unit)
--     if DSL("exists")(unit) then
--         if IsInInstance() then
--             for _, boss in ipairs(bossNames) do
--                 if boss.alive and boss.name==DSL('name')(unit)then
--                     return true
--                 end
--             end
--         else
--             local estimatedWorldBossHP = DSL("health.max")("player")*3
--             if DSL("isdummy")(unit) or DSL("health.max")(unit)>=estimatedWorldBossHP then
--                 return true
--             end
--         end
--     end
-- end)

-------------------------------------------------------------------------------------------------------------
--------------------------------Для подсчета дебафов нестабильное колдовство---------------------------------

local UAIDs = {"233490", "233496", "233497", "233498", "233499"}
------------------------
_A.DSL:Register("duration_UA", function(target, index)
    return _A.DSL:Get("debuff.duration")(target, UAIDs[tonumber(index)])
end)
------------------------
_A.DSL:Register("CountUAs", function(target)
    local c = 0
    for i=1, #UAIDs do
        if _A.DSL:Get("debuff")(target, UAIDs[i]) then
            c = c + 1
        end
    end
    return c
end)
------------------------
------------------------------------------------------------------------------------------------------------

--------------------------------Для подсчета дебафов для похищения жизни--------------------------------

local HAIDs = {"334320"}
------------------------
_A.DSL:Register("duration_HA", function(target, index)
    return _A.DSL:Get("debuff.duration")(target, HAIDs[tonumber(index)])
end)
------------------------
_A.DSL:Register("CountHAs", function(target)
    local c = 0
    for i=1, #HAIDs do
        if _A.DSL:Get("debuff")(target, HAIDs[i]) then
            c = c + 1
        end
    end
    return c
end)

_A.DSL:Register("total_duration_HA", function(player)
    local t, curr = 0, 0
    for i = 1, #HAIDs do
        curr = _A.DSL:Get("buff.duration")(player, HAIDs[i])
        if curr > t then
            t = curr
        end
    end
    return t
end)

------------------------
------------------------------------------------------------------------------------------------------------

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
------------------------------------------------Инчант оружки------------------------------------------------

_A.DSL:Register("W_Enchant", function(_, id)
    id = tonumber(id)
    if not id then return end
    local _, _, _, mainEnchantId, _, _, _, offEnchantId = GetWeaponEnchantInfo()
    return mainEnchantId==id or offEnchantId==id
    
end)

--local windfurry = W_Enchant(5401)
--local Flametongue = W_Enchant(5400)
--local Earthliving = W_Enchant(6498)

local Bless_List = {
    {key = "1", text = FlexIcon(702, 16, 16, true)},                                        --Проклятие слабости
    {key = "2", text = FlexIcon(334275, 16, 16, true)},                                        --Проклятие изнеможения  
    {key = "3", text = FlexIcon(1714, 16, 16, true)},                                        --Проклятие красноязычия
    {key = "0", text = "Без проклятий"},
}

local Bless = {
    {"702", "ui(blesstype)=1 && !target.debuff && spell.ready && spell.range && los", "target"},                            --Проклятие слабости
    {"334275", "ui(blesstype)=2 && !target.debuff && spell.ready && spell.range && los", "target"},                             --Проклятие изнеможения  
    {"1714", "ui(blesstype)=3 && !target.debuff && spell.ready && spell.range && los", "target"},                            --Проклятие красноязычия
}
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------Роль Танка--------------------------------------------------------------
local Roles = {
    ['TANK'] = 1.2,
    ['HEALER'] = 1,
    ['DAMAGER'] = 1,
    ['NONE'] = 1
}
-- Tank
_A.FakeUnits:Add('tank', function(num)
    local tempTable = {}
    for _, Obj in pairs(_A.OM:Get("Roster")) do
        if Obj.isplayer then
            tempTable[#tempTable+1] = {
                key = Obj.key,
                prio = Obj:healthMax() * Roles[Obj:role()]
            }
        end
    end
    if #tempTable>1 then
        table_sort( tempTable, function(a,b) return a.prio > b.prio end )
    end
    return tempTable[num] and tempTable[num].key
end)

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

------------------------------------------------------------------------------------------------------------------------------------------------
-- Function to handle delayed spell casting

local function DelayedCast(frame, elapsed)
    frame.timeElapsed = frame.timeElapsed + elapsed
    if frame.timeElapsed >= frame.delay then
        if SpellIsTargeting() then
            _A.ClickPosition(frame.px, frame.py, frame.pz)
            frame:Hide()
        end
    end
end

function CastPredictedPos(unit, spell, distance)
    local py, pz, px = predictedPos(unit, distance)

    _A.CastSpellByName(spell) --spell cast

    -- Create a frame for handling the delay
    local castFrame = CreateFrame("Frame")
    castFrame.timeElapsed = 0
    castFrame.delay = 0.5 -- Delay in seconds
    castFrame.px, castFrame.py, castFrame.pz = px, py, pz

    castFrame:SetScript("OnUpdate", DelayedCast)
    castFrame:Show()
end



local pet = {    

    {key = "1", text = FlexIcon(688, 16, 16, true)},                                           --Бес
    {key = "2", text = FlexIcon(697, 16, 16, true)},                                           --Синяк  
    {key = "3", text = FlexIcon(366222, 16, 16, true)},                                        --Сайаад
    {key = "4", text = FlexIcon(691, 16, 16, true)},                                           --Охотник скверны
    {key = "0", text = "Без пета"},
}

local pet_choice = {        
  
    --{"/petdismiss", "ui(pettype)=0 && exists && timeout(sfsdfr, 5)", "pet"}, 
    {"688", "ui(pettype)=1 && && timeout(sfsdfr, 7) && spell.ready && !player.moving && !pet.exists && !player.buff(196099)"},                            --Бес
    {"697", "ui(pettype)=2 && && timeout(sfsdfr, 7) && spell.ready && !player.moving && !pet.exists && !player.buff(196099)"}, 
    {"366222", "ui(pettype)=3 && && timeout(sfsdfr, 7) && spell.ready && !player.moving && !pet.exists && !player.buff(196099)"}, 
    {"691", "ui(pettype)=4 && && timeout(sfsdfr, 7) && spell.ready && !player.moving && !pet.exists && !player.buff(196099)"}, 
    
   -- {"688", "ui(pettype)=1 && !lastCast(688).succeed && spell.ready && !ObjExist(416) && !player.moving && !pet"},                            --Бес
   -- {"697", "ui(pettype)=2 && !lastCast(697).succeed && spell.ready && !ObjExist(1860) && !player.moving && !pet"},                           --Синяк  
   -- {"366222", "ui(pettype)=3 && !lastCast(366222).succeed && spell.ready && !ObjExist(1863) && !player.moving && !pet"},                     --Сайаад
   -- {"691", "ui(pettype)=4 && !lastCast(691).succeed && spell.ready && !ObjExist(417) && !player.moving && !pet"},                           -- Охотник скверны    
}

    ------------------------Набор талантов---------------------------

local talent_row1 = 'BkQAAAAAAAAAAAAAAAAAAAAAAAHIJJRSCkmCkWSSIlAAAAANAAAAAAASEtQkkIJSaJRAAJ'   --рейд
local talent_row2 = 'BkQA+63P9mnDJYMkogOeTUhr8iQSSkkAppAplkESJAAAAQJNAAAAAAAR0IJRikkolEBAkA'  --мифик

                    

------------------------------------------------------------------------------------------------------------






local GUI = {        
        
}
local spell_ids = {
	["Mend Pet"] = 136,
	["Kill Command"] = 34026,
	["Cobra Shot"] = 193455,
	["Kill Shot"] = 53351,
	["Живость"] = 109304,
	["Multi-Shot"] = 2643,
	["Barbed Shot"] = 217200,
	["Counter Shot"] = 147362,
	["Survival of the Fittest"] = 264735,
	["Tranquilizing Shot"] = 19801,
	["Bestial Wrath"] = 19574,
	["Hunter's Mark"] = 257284,
    ["ResPet"] = 982,
    ["Устрашение"] = 19577,
    ["Шакран смерти"] = 375891,
    ["Кровавое неистовство"] = 20572, --рассовая орк
    

}

local exeOnLoad = function()
    print("Afflication was loaded")

    _A.Interface:ShowToggle("Cooldowns", false)
   -- _A.Interface:ShowToggle("aoe", false)

    _A.Interface:AddToggle({key = "AutoTarget", name = "Авто Таргет", text = "Автотаргет когда цель умерла или не существует", icon = "Interface\\Icons\\ability_hunter_snipershot",})
    _A.Interface:AddToggle({key = "AutoLoot", name = "Авто Лут", text = "Автоматически лутает мобов вокруг вас", icon = "Interface\\Icons\\inv_misc_gift_05"})

    --_A.Interface:AddToggle({key = "toggle_BR", name = "Бег", text = "Бег", icon = "Interface\\Icons\\Spell_fire_burningspeed"})


    _A.DSL:Register({'face', 'lookAt'}, function(target) -- 'face' and 'lookAt' do the same
        _A.FaceDirection("target", true)
        return true
    end)

    


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

local cache = {
    aoe = false,
  }

  local RotationCache = {
  {function()
    cache.aoe = false
    local count = 0
    local enemy = _A.OM:Get('EnemyCombat')
    for _,Obj in pairs(enemy) do
      if DSL("range")(Obj.key) < 5 then
        count = count + 1
      end
    end
    if count > 1 then
      cache.aoe = true
    end
  end,},
}
local SelfProtect = {


    -- {{
    --     {"Канал здоровья", "lastcast(Горящая душа)"},
    --     {"Горящая душа", "keybind({ui(kanal_key)})"},
    --   }, "spell(Горящая душа).ready && spell(Канал здоровья).ready && spell(Канал здоровья).range && !player.moving && los", "pet"},


    --   {{
    --     {"Канал здоровья", "lastcast(Горящая душа)"},
    --     {"Горящая душа", "ui(kanall_check)"},
    --   }, "spell(Горящая душа).ready && spell(Канал здоровья).ready && spell(Канал здоровья).range && player.health>=50 && !player.moving && los && pet.health <=ui(kanall_spin)", "pet"},


    {{
        {"Burning Rush", "!BR_state && buff", 'player'},
        {"Burning Rush", "lastmoved>=1 && buff", 'player'},
    }, "spell(Burning Rush).ready"},
    {"Burning Rush", "BR_state && spell.ready && health>70 && movingfor>=0.25 && !buff", 'player'},
    
    {"%null", "keybind({ui(beg)}) && toggle_BR"},


    -- {{
    --     {"Burning Rush", "spell.ready && buff && {!key({ui(beg)}).on || lastmoved>=1 || health<15}", "player"},
    --     {"Burning Rush", "key({ui(beg)}).on && spell.ready && !buff && movingfor>=0.25 && health>70", "player"},
    --     {"%null", "keybind({ui(beg)}) && key({ui(beg)}, 1).toggle"},
    -- }, "talent(Burning Rush)"},


   -- --   {function()
   -- --     _A.Cast("Горящая душа", "player")
   -- --     _A.Cast("Канал здоровья", "pet")
   -- -- end, "keybind({ui(kanal_key)}) && spell(Горящая душа).ready && spell(Канал здоровья).ready && spell(Канал здоровья).range && !player.moving && los", "pet"},



   -- -- {function()
   -- --     _A.Cast("Горящая душа", "player")
   -- --     _A.Cast("Канал здоровья", "pet")
   -- -- end, "ui(kanall_check) && spell(Горящая душа).ready && spell(Канал здоровья).ready && spell(Канал здоровья).range && !player.moving player.health>=50 && pet.health <=ui(kanall_spin) && los", "pet"},


    -- off
--{"111400", "!keybind({ui(beg)}) && spell.ready && player.buff(111400)", "player"},

-- on
--{"111400", "keybind({ui(beg)}) && spell.ready && !player.buff(111400)", "player"},

      
--    {{
--     {"!111400", "buff(111400) && CancelAura(111400)", "player"},
--     {"111400", "!buff && spell.ready && timeout(111400,9)", "player"},
--   }, "keybind({ui(beg)})" },


    {"Похищение жизни", "ui(PWkey_check) && player.health <=ui(PWkey_spin) && spell.ready && spell.range && !player.moving && los(player)", "target"},
    {"Лик тлена", "ui(tlen_check) && player.health <=ui(tlen_spin) && spell.ready && spell.range", "target"},
    {"#Камень здоровья", "player.health <=ui(HWkey_spin) && item(Камень здоровья).count>0 && item(Камень здоровья).usable", "player"},
    {"Твердая решимость", "ui(reshkey_check) && player.health <=ui(reshkey_spin) && spell.ready", "player"},
    {"Страх", "keybind({ui(fearkey_key)}) && spell.ready && spell.range && los && !moving", {"focus", "target"}},
    {"Гримуар жертвоприношения", "keybind({ui(grimuar)}) && spell.ready && spell.range && los", "pet"},
    --{"Стремительный бег", "keybind({ui(beg)}) && spell.ready", "player"},
    {"Канал здоровья", "ui(kanall_check) && pet.health <=ui(kanall_spin) && spell.ready && player.health>=50 && exists", "pet"},
    {"Канал здоровья", "keybind({ui(kanal_key)}) && spell.ready && spell.range && los && !moving && exists", "pet"},
    {"Бесконечное дыхание", "spell.ready && spell.range && los(player) && !player.buff && player.swimming", "player"},
}
local SelfProtectAlly = {

    
   -- {"&Ancestral Guidance", "ui(Ancestral GuidanceTank_check) && lowest.health <= ui(Ancestral GuidanceTank_spin) && lowest.hasrole(TANK)", "lowest"},
   -- {"&Earth Elemental", "ui(Earth ElementalTank_check) && lowest.health <= ui(Earth ElementalTank_spin) && lowest.hasrole(TANK)", "lowest"}, 334320 урон похищение жизни Неизбежная гибель
}

local Rotation = {    

    -- {"@myLib.face", "ui(povorot) ", "target"},
	{"Kill Shot", nil, "target"},
    --{"Hunter's Mark", "!debuff(257284) && los && spell.ready && spell.range", "Boss"},
	--{"Hunter's Mark", "isboss && spell.ready && !debuff", "target"},


    {"Hunter's Mark", "spell.ready && spell.range && isboss && !debuff && timeout(HMark, 0.2)", "target"},
    {"Кровавое неистовство", "spell.ready && isboss", "target"},
    {"Шакран смерти", "sptll.ready && spell.range", "Boss1"},
    {"Шакран смерти", "sptll.ready && spell.range && isboss", "target"},



	{"Barbed Shot", nil, "target"},
	-- {"A Murder of Crows", "talent", "target"},
	-- {"Stampede", "talent && ttd>24 && {player.buff(Bloodlust) || player.buff(Bestial Wrath) || spell(Bestial Wrath).cooldown<3}", "player"},
	-- {"Dire Beast", "spell(Bestial Wrath).cooldown>3", "target"},
	-- {"Dire Frenzy", "talent && {pet.buff(Dire Frenzy).duration<=1.5 || spell(Dire Frenzy).charges>0.8}", "target"},
	-- {"Chimaera Shot", "talent &&  player.focus<90", "target"},
	{"Bestial Wrath", nil, "pet"},
    {function() _A.CastSpellByID(34026, "target") end, "exists && spell(34026).ready && pet.exists", {"target", "pet"}},            --команда взять---982
	--{"6603", "pet.exists && spell(34026).ready && kludge(34026)", {"target", "pet"}}, --  at least it do the job :D
    {function() _A.CastSpellByID(272651, "pet") end, "exists && spell(272651).ready && !debuff", "Boss1"},                          -- умение пета
	--{"Kill Command", "spell.ready", "target"},
	{"Cobra Shot", nil, "target"},
	--{"Cobra Shot", nil, "target"},
	-- {"Concussive Shot", "spell.range && player.focus<40", "target"},
}

local AOE = {
	-- {"A Murder of Crows", "talent", "target"},
	-- {"Barrage", nil, "target"},
     {"Шакран смерти", "sptll.ready && spell.range", "target"},
	 {"Multi-Shot", "!player.buff(Удар зверя)", "target"},
	 {"Multi-Shot", "pet.buff(Удар зверя).duration<gcd || !pet.buff(Удар зверя)", "target"},
	-- {"Chimaera Shot", "talent &&  player.focus<90", "target"},
	-- {"Kill Command", nil, "target"},
	-- {"Cobra Shot", nil, "target"},
}	


local Survival = {
	{"Живость", "spell.ready && health<=40", "player"},
	{"Mend Pet", "health<=75 && distancefrom(pet) <= 40 && los && !pet.dead", "pet"},
    {"ResPet", "pet.dead && timeout(ResPet, 0.2)", "pet"},
    {"Survival of the Fittest", "talent && !lastcast(Живость) && spell.ready && !buff(Живость) && incdmg(3)>=health.max*0.4", "player"},    
  }

  local Trini = {

    {"#trinket1", "equipped(197960) && item(197960).usable", "player"},
    {"#trinket1", "equipped(193757) && item(193757).usable", "target"},
    {"!#trinket1", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable", "target.ground"},
    {"!#trinket1", "equipped(193769) && item(193769).usable", "target.ground"},
    {"#trinket1", "equipped(Giant Ornamental Pearl) && item(Giant Ornamental Pearl).usable", "player"},
    {"#trinket1", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},

    {"#trinket2", "equipped(197960) && item(197960).usable", "player"},
    {"#trinket2", "equipped(193757) && item(193757).usable", "target"},
    {"!#trinket2", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable", "target.ground"},
    {"!#trinket1", "equipped(193769) && item(193769).usable", "target.ground"},
    {"#trinket2", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},
    {"#trinket2", "equipped(Coagulated Nightwell Residue) && item(Coagulated Nightwell Residue).usable && buff(Nightwell Energy).count>=8", "player"},
  }

local Interrupts = {
	-- {"Tranquilizing Shot", "target.buff(Magic).type", "target"},
	-- {"Tranquilizing Shot", "target.buff(Enrage).type", "target"},
	 --{"Counter Shot", nil, "EnemyCombat"},

    --  {{
    --     {"Tranquilizing Shot", "spell.range && {buff(Enrage).type || buff(Magic).type}", "enemycombat"},---------
    -- }, "talent(Tranquilizing Shot) && spell(Tranquilizing Shot).ready && !isRaid"},
     
     {{
        {"Tranquilizing Shot", "exists", "TS_enraged_magic"},
    }, "talent(Tranquilizing Shot) && spell(Tranquilizing Shot).ready && !isRaid"}, 

    {{
        {"*Counter Shot", "spell.range && isCastingAny && interruptible && interruptAt(10) && los", "EnemyCombat"},
    }, "toggle(Interrupts) && spell(Counter Shot).ready"}, 
    
    {{
        {"Устрашение", "exists && isCastingAny && los && !immune", "EnemyCombat"},
    }, "toggle(Interrupts) && spell(Устрашение).ready &&  spell(Counter Shot).cooldown > 3"},
 }
local Cooldowns = {
}


local Validate = {

    {Trini},
	{'/startattack', '!auto.shoot'},
	--{Interrupts, "toggle(Interrupts)", "EnemyCombat"},
    {Interrupts, "toggle(Interrupts)"},
    
	{AOE, "area(15).enemies>2 && toggle(aoe)", "target"},
	{Rotation},
}

local inCombat = {
   -- {Interrupts},
    {Survival},
	--{Validate, "infront(player) && enemy", "target"},	
    {Validate},
    --{Trini},
    {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"}, --автотаргет    
    --{Bless},    
    --{SelfProtectAlly},
    --{SelfProtect},
    --{RotationCache},
    --{Rotation},
}
local outOfCombat = {    
	{Survival}, 
    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<3.9", "dead"}, 

      
}

_A.CR:Add(253, {
    name = "[BMGit]",
    load = function()
        print("Load function executed")
        exeOnLoad()
    end,
    gui = GUI,
    gui_st = {title="Колдовство by Алексей", color="1EFF0C", width="400", height="500"},
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

-- SummonPet = function()
--     local Player = Object("player")
--     local Pet = Object("pet")
--     local pet_choice = tonumber(ui("pet_choice"))
  
--     if pet_choice == 0 then
--       return
--     end
  
--     if Pet and Pet:exists() then
--       return
--     end
  
--     if not Player:Buff(Spells.GrimoireofSacrifice.name) then
--       local summonSpells = {
--         Spells.SummonImp.name,        
--         Spells.SummonVoidwalker.name,
--         Spells.SummonSuccubus.name,
--         Spells.SummonFelhunter.name
--       }
  
--       local summonSpell = summonSpells[pet_choice]
  
--       if Player:lastCast(summonSpell) or Player:isCasting(summonSpell) then
--         return
--       end
  
--       if not Player:Moving() and Player:SpellReady(Spells.FelDomination.name) and Player:SpellReady(Spells.SummonFelhunter.name) and Player:Combat() then
--         return Player:Cast(Spells.FelDomination.name)
--       end
  
--       if not Player:Moving() and (not Player:Combat() or Player:Buff(Spells.FelDomination.name)) and Player:SpellReady(Spells.SummonFelhunter.name) then
--         return Player:Cast(summonSpell)
--       end
--     end 
-- end


-- SummonPet = function()
--     local Player = Object("player")
--     local Pet = Object("pet")
--     local pet_choice = tonumber(ui("pet_choice"))
    
--     if pet_choice == 0 then
--         return
--     end
    
--     if Pet and Pet:exists() then
--         return
--     end
    
--     if not Player:Buff(Spells.GrimoireofSacrifice.name) then
--         local summonSpells = {
--         Spells.SummonImp.name,
--         Spells.SummonVoidwalker.name,
--         Spells.SummonSuccubus.name,
--         Spells.SummonFelhunter.name
--         }
    
--         local summonSpell = summonSpells[pet_choice]
            
--         if Player:lastCast(summonSpell) or Player:isCasting(summonSpell) then
--             return
--         end
            
--         if not Player:Moving() and Player:SpellReady(Spells.FelDomination.name) and Player:SpellReady(Spells.SummonFelhunter.name) and Player:Combat() then
--             return Player:Cast(Spells.FelDomination.name)
--         end
            
--         if not Player:Moving() and (not Player:Combat() or Player:Buff(Spells.FelDomination.name)) and Player:SpellReady(Spells.SummonFelhunter.name) then
--             return Player:Cast(summonSpell)
--         end
--     end
-- end,

-- 

-- {"/use Fel Healthstone", "item(Fel Healthstone).count>0 && item(Fel Healthstone).usable", "player"},
-- {"/use Demonic Healthstone", "item(Demonic Healthstone).count>0 && item(Demonic Healthstone).usable", "player"},

-- {"#Fel Healthstone", "item(Fel Healthstone).count>0 && item(Fel Healthstone).usable", "player"},
-- {"#Demonic Healthstone", "item(Demonic Healthstone).count>0 && item(Demonic Healthstone).usable", "player"},
-- {"#Master Healthstone", "item(Master Healthstone).count>0 && item(Master Healthstone).usable", "player"},
-- {"#Major Healthstone", "item(Major Healthstone).count>0 && item(Major Healthstone).usable", "player"},
-- {"#Greater Healthstone", "item(Greater Healthstone).count>0 && item(Greater Healthstone).usable", "player"},
-- {"#Healthstone", "item(Healthstone).count>0 && item(Healthstone).usable", "player"},
-- {"#Lesser Healthstone", "item(Lesser Healthstone).count>0 && item(Lesser Healthstone).usable", "player"},
-- {"#Minor Healthstone", "item(Minor Healthstone).count>0 && item(Minor Healthstone).usable", "player"},
