local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
local DSL = function(api) return _A.DSL:Get(api) end

--Для иконок заклинаний и предметов--

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

------------------------



local Bless_List = {
    {key = "1", text = FlexIcon(318038, 16, 16, true)},                                        --Оружие языка пламени
    {key = "2", text = FlexIcon(33757, 16, 16, true)},                                            --Оружие неистовства ветра  
    {key = "3", text = FlexIcon(382021, 16, 16, true)},                                        --Оружие жизни земли
    {key = "0", text = "Отключено"},
}

local Bless = {
    {"318038", "ui(blesstype)=1 && !W_Enchant(5400) && spell.ready"},                            --Оружие языка пламени
    {"33757", "ui(blesstype)=2 && !W_Enchant(5401) && spell.ready"},                             --Оружие неистовства ветра  
    {"382021", "ui(blesstype)=3 && !W_Enchant(6498) && spell.ready"},                            --Оружие жизни земли
}

_A.DSL:Register("W_Enchant", function(_, id)
    id = tonumber(id)
    if not id then return end
    local _, _, _, mainEnchantId, _, _, _, offEnchantId = GetWeaponEnchantInfo()
    return mainEnchantId==id or offEnchantId==id
    
end)

--local windfurry = W_Enchant(5401)
--local Flametongue = W_Enchant(5400)
--local Earthliving = W_Enchant(6498)



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





local GUI = {
        {type = "ruler"},
        {type = "texture", texture = "Interface\\Addons\\Apofis\\Core\\media\\MyLogo.tga", width = 420, height = 200, offset = 190, y= -90, align = "center"},
        
        ---Лечебные скилы
        {type = "ruler"},
        {type = "header", text = "Healing skills", align = "center", size = "16"},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "dropdown", width = 180, size = 14, text = "Enchant mainhand", key = "blesstype", list = Bless_List, default = "0"},
        {type = "spacer", size = 7},
       -- {type = "dropdown", width = 180, size = 14, text = "Enchant offhand", key = "blesstype", list = Bless_List, default = "0"},
       -- {type = "spacer", size = 7},
        {type = "checkspin", key = "HWkey", size = 14, text = FlexIcon(77472, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        --{type = "checkspin", key = "HWkey", size = 14, text = _A.Core:GetSpellIcon(77472, 16, 16).."Волна исцеления", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "PWkey", size = 14, text = FlexIcon(375982, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "Bkey", size = 14, text = FlexIcon(61295, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "healkey", size = 14, text = FlexIcon(8004, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "cepkey", size = 14, text = FlexIcon(1064, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "blagkey", size = 14, text = FlexIcon(79206, 16, 16, true), default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},

        ---- Тотемы
        {type = "ruler"},
        {type = "header", text = "Totems", align = "center", size = "16"},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "checkspin", key = "tothkey", size = 14, text = FlexIcon(5394, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "totthkey", size = 14, text = FlexIcon(108280, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},

        ---- Диспелы
    
        {type = "ruler"},
        {type = "header", text = "Dispels", align = "center", size = "16"},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {key = "purgekey", type = "checkbox", size = 14, text = FlexIcon(370, 16, 16, true), default = true, align = "left", check = true,}, 
        {type = "spacer", size = 7},
        {key = "vozkey", type = "checkbox", size = 14, text = FlexIcon(77130, 16, 16, true), default = true, align = "left", check = true,}, 
        {type = "spacer", size = 7},
        
        
        
        

            ---- Defensive Ally Abilities 
        {type = "ruler"},
        {type = "header", text = "Массовые защитные скилы", align = "center", size = "16", offset = 15},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {key = "Astral Shift", type = "checkspin", size = 14, text = FlexIcon(108271, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60},
        {type = "spacer"},
        {type = "checkspin", key = "predkkey", size = 14, text = _A.Core:GetSpellIcon(108281, 16, 16).."Наставления предков", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "perkey", size = 14, text = _A.Core:GetSpellIcon(114052, 16, 16).."Перерождение", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
       -- {key = "Earth Elemental", type = "checkspin", text = "Элементаль земли", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 20},
       -- {type = "spacer", size = 5},
       -- {key = "Fire Elemental", type = "checkspin", size = 14, text = _A.Core:GetSpellIcon(198067, 16, 16).."Элементаль огня", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 20},
       -- {type = "spacer", size = 5},
}
local spell_ids = {
    ["Bloodlust"] = 2825, -- Жажда крови
   
    ["Lava Burst"] = 51505, -- Выброс лавы (талант)
    ["Frost Shock"] = 196840, -- Ледяной шок(талант)
    ["Thunderstorm"] = 51490, -- гром и молния (талант)
    ["Lightning Bolt"] = 188196, -- Молния
    ["Ancestral Guidance"] = 108281, -- Наставление предков(Талант)
    ["Flame Shock"] = 188389, -- Огненный шок
    ["Flametongue Weapon"] = 318038, -- Оружие языка пламени
    ["Spirit Walk"] = 58875, -- Поступь духа
    ["Capacitor Totem"] = 192058, -- Тотем конденсации
    ["Wind Shear"] = 57994, -- Пронзающий ветер(Талант)
    ["Chain Lightning"] = 188443, -- Цепная молния
    ["Lightning Shield"] = 192106, -- Щит молний
    ["Водный щит"] = 52127,
    ["Water Shield"] = 52127,
    ["Earth Elemental"] = 198103, -- Элементаль земли(талант)
    ["Lava Lash"] = 60103, -- Вскипание лавы
    ["Crash Lightning"] = 187874, -- Сокрушающая молния
    ["Feral Spirit"] = 51533, -- дух дикого зверя
    ["Windfury Totem"] = 8512, -- Тотем неистовства ветра
    ["Ice Strike"] = 342240, -- Ледяной клинок
    ["Stormstrike"] = 17364, -- Удар бури
    ["Windfury Weapon"] = 33757, -- Оружие неистовства ветра
    ["Sundering"] = 197214, -- Раскол 
    

    ["Волна исцеления"] = 77472,
    ["Первозданная волна"] = 375982,    
    ["Primordial Wave"] = 375982, -- Первозданная волна
    ["Быстрина"] = 61295,
    ["Исцеляющий всплеск"] = 8004,
    ["Chain Heal"] = 1064,
    ["Цепное исцеление"] = 1054,
    ["Благосклонность предков"] = 79206,
    
    ["Тотем исцеляющего потока"] = 5394,
    ["Тотем целительного прилива"] = 108280,
    
    ["Развеивание магии"] = 370,
    ["Возрождение духа"] = 77130,
    
    ["Щит земли"] = 974,
    
    
    ["Astral Shift"] = 108271, -- Астральный сдвиг (Талант)
    ["Regrowth"] = 114052, 
    ["Перерождение"] = 114052,
    ["Наставления предков"] = 108281,
    

    
    
}

local exeOnLoad = function()
    print("Ротация загружена")

    _A.Interface:AddToggle({key = "AutoTarget", name = "Auto Target", text = "Automatically target enemy when target dies or does not exist", icon = "Interface\\Icons\\ability_hunter_snipershot",})
    _A.Interface:AddToggle({key = "AutoLoot", name = "Auto Loot", text = "Automatically loot units around you", icon = "Interface\\Icons\\inv_misc_gift_05"})


    _A.DSL:Register({'face', 'lookAt'}, function(unit) -- 'face' and 'lookAt' do the same
        _A.FaceDirection(unit, true)
        return true
    end) 


    
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
    {"Astral Shift", "ui(Astral Shift_check) && player.health <= ui(Astral Shift_spin)", "player"},
    {"&Spirit Walk", "ui(Spirit Walk_check) && player.state(root)", "player"},
   -- {"Исцеляющий всплеск", "spell.ready && ui(healkey_check) && player.health <=ui(healkey_spin)", "player"},
    {"Элементаль огня", "ui(Fire Elemental_check) && area_range(8).combatEnemies >=ui(Fire Elemental_spin)", "player"},
}
local SelfProtectAlly = {
    {"&Ancestral Guidance", "ui(Ancestral GuidanceTank_check) && lowest.health <= ui(Ancestral GuidanceTank_spin) && lowest.hasrole(TANK)", "lowest"},
    {"&Earth Elemental", "ui(Earth ElementalTank_check) && lowest.health <= ui(Earth ElementalTank_spin) && lowest.hasrole(TANK)", "lowest"},
   
}

local Rotation = { 

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    {"Wind Shear", "spell.ready && spell.range && isCastingAny && interruptible && interruptAt(60) && los", "EnemyCombat"},
    {"Развеивание магии", "ui(purgekey_check) && spell.ready && spell.range && los && buff(Magic).type", "EnemyCombat"},
    {"Возрождение духа", "ui(vozkey_check) && spell.ready && spell.range && debuff(Magic).type", "roster"},
    
    {"Щит земли", "!IsSolo && spell.ready && hasRole(tank) && spell.range && !buff", "realTank"},
    {"Водный щит", "spell.ready && !player.buff"},
    {"Lightning Shield", "spell.ready && !player.buff"},


    {"Перерождение", "ui(perkey_check) && spell.ready && count(3).hp <=ui(perkey_spin) && count(3).distance <=35", "roster"},

   
    {">Healing Stream Totem", "!exists || exists && distance>10", "totemID(3527)"},
    
    {"Наставления предков", "spell.ready && ui(predkkey_check) && lowest.health <= ui(predkkey_spin)"},
   -- {"Тотем исцеляющего потока", "!exists && spell.ready && lowest.range <= 40 && ui(tothkey_check) && lowest.health <= ui(tothkey_spin)"},
    {">Тотем исцеляющего потока", "lowest.health <= ui(tothkey_spin) && !exists || exists && distance >10 && spell.ready && lowest.range <=20 && ui(tothkey_check) ", "totemID(3527)"}, 
   -- {"Тотем исцеляющего потока", "spell.ready && lowest.range<= 20 && ui(tothkey_check) && lowest.health<=ui(tothkey_spin)", "roster"},
    {"108280", "spell.ready && lowest.range <=20 && ui(totthkey_check) && lowest.health <=ui(totthkey_spin)", "roster"},
    {"Благосклонность предков", "spell.ready && ui(blagkey_check) && los && group.health >=ui(blagkey_spin)"},


    {"Первозданная волна", "spell.ready && spell.range && health <=ui(PWkey_spin) && los", "lowest"},
    {"Быстрина", "health <=ui(Bkey_spin) && spell.ready && spell.range && los && !buff", "roster"},
    {"Волна исцеления", "health <=ui(HWkey_spin) && spell.ready && spell.range && !moving && los", "lowest"},
    --{"Цепное исцеление", "health <=ui(cepkey_spin) && !moving && spell.ready && spell.range && los", "roster"},
    {"Цепное исцеление", "group.health <=ui(cepkey_spin) && !moving && spell.ready && spell.range && los", "lowest"},
    
    {"Исцеляющий всплеск", "spell.ready && spell.range && !moving && ui(healkey_check) && player.health <=ui(healkey_spin)", "lowest"},




   -- {"Цепное исцеление", "(cepkey_check) && count(3).Hp<=(cepkey_spin) && count(3).distance<=35 && !moving", "roster"},




        

    -----------------------------Наставление предков-----------------------------

    -- {function()
    --     if _A.DSL:Get("spell.ready")(_, spell_ids["Ancestral Guidance"]) and _A.DSL:Get("ui(predkkey_check)") and #_A.OM:Get('Roster') >= 1 then
    --     local Roster = _A.OM:Get('Roster')
    --     local lowestHealth = 100
        
    --     -- Check if at least 3 group members have health less than or equal to the specified value and are not dead
    --     local count = 0
    --     for _,Obj in pairs(Roster) do
    --     if _A.DSL:Get("alive")(Obj.key) and _A.DSL:Get("health")(Obj.key) <= _A.DSL:Get("ui(predkkey_spin)") and _A.DSL:Get("distance")(Obj.key) <= 35 then
    --     count = count + 1
    --     end
    --     end
        
    --     -- Cast Ancestral Guidance if the above condition is met
    --     if count >= 1 then
    --     _A.CastSpellByID(spell_ids["Ancestral Guidance"])
    --     end
    --     end
    -- end,},


    -- {function()
    --     if _A.DSL:Get("spell.ready")(_, spell_ids[""]) and _A.DSL:Get("ui(predkey_check)") and #_A.OM:Get('Roster') >= 2 then
    --     local Roster = _A.OM:Get('Roster')
    --     local count = 0
        
    --     for _,Obj in pairs(Roster) do
    --     if _A.DSL:Get("los")(Obj.key) and _A.DSL:Get("alive")(Obj.key) and _A.DSL:Get("health")(Obj.key) <= _A.DSL:Get("ui(predkey_spin)") and _A.DSL:Get("distance")(Obj.key) <= 25 then
    --     count = count + 1
    --     end
    --     end
        
    --     if count >= 2 then
    --     _A.CastSpellByID(spell_ids["Ancestral Guidance"], nil)
    --     end
    --     end
    -- end,},

    -- -----------------------------Перерождение-----------------------------

    -- {function()
    --     if _A.DSL:Get("spell.ready")(_, spell_ids["Regrowth"]) and _A.DSL:Get("ui(perkey_check)") and #_A.OM:Get('Roster') >= 2 then
    --     local Roster = _A.OM:Get('Roster')
    --     local count = 0
        
    --     for _,Obj in pairs(Roster) do
    --     if _A.DSL:Get("los")(Obj.key) and _A.DSL:Get("alive")(Obj.key) and _A.DSL:Get("health")(Obj.key) <= _A.DSL:Get("ui(perkey_spin)") and _A.DSL:Get("distance")(Obj.key) <= 25 then
    --     count = count + 1
    --     end
    --     end
        
    --     if count >= 2 then
    --     _A.CastSpellByID(spell_ids["Regrowth"], nil)
    --     end
    --     end
    -- end,},

--     -----------------------------Водный щит-----------------------------

--    {function()
--         if _A.DSL:Get("spell.ready")(_, spell_ids["Water Shield"]) and not _A.DSL:Get("player.buff") then
--             _A.CastSpellByID(spell_ids["Water Shield"])
--         end
--     end,},

--     -----------------------------Щит молний-----------------------------

--    {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Lightning Shield"]) and not _A.DSL:Get("player.buff") then
--         _A.CastSpellByID(spell_ids["Lightning Shield"])
--     end
--    end,},

   -----------------------------Цепное исцеление-----------------------------
    --   {function()
    --     local Roster = _A.OM:Get('Roster')
    --     if _A.DSL:Get("spell.ready")(_, spell_ids["Chain Heal"]) and Roster and #Roster:Filter(function(Obj)
    --       return _A.DSL:Get("health")(Obj.key) <= _A.DSL:Get("ui(cepkey_spin)") and _A.DSL:Get("alive")(Obj.key)
    --     end) >= 3 then
    --       local lowestTarget = nil
    --       local lowestHealth = 100
      
    --       -- Find the friendly target with the lowest health
    --       for _, Obj in pairs(Roster) do
    --         if _A.DSL:Get("los")(Obj.key) and _A.DSL:Get("alive")(Obj.key) then
    --           local health = _A.DSL:Get("health")(Obj.key)
    --           if health < lowestHealth then
    --             lowestHealth = health
    --             lowestTarget = Obj.key
    --           end
    --         end
    --       end
      
    --       -- Cast Chain Heal on the target with the lowest health
    --       if lowestTarget and lowestHealth <= _A.DSL:Get("ui(cepkey_spin)") then
    --         _A.CastSpellByID(spell_ids["Chain Heal"], lowestTarget)
    --       end
    --     end
    --   end,},


    
--  {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Chain Heal"]) then
--       local Roster = _A.OM:Get('Roster')
--       local lowestTarget = nil
--       local lowestHealth = 100
  
--       -- Find the friendly target with the lowest health
--       for _,Obj in pairs(Roster) do
--             if _A.DSL:Get("los")(Obj.key) and _A.DSL:Get("alive")(Obj.key) then
--             local health = _A.DSL:Get("health")(Obj.key)
--                 if health < lowestHealth then
--                     lowestHealth = health
--                     lowestTarget = Obj.key
--                 end
--             end
--         end
        
--       -- Cast Chain Heal on the target with the lowest health if their health is less than or equal to the specified value and there are at least 3 friendly targets with less than or equal to the specified health 
--       if lowestTarget and lowestHealth <= _A.DSL:Get("ui(cepkey_spin)") and #_A.OM:Get('Roster'):Filter(function(Obj) return _A.DSL:Get("health")(Obj.key) <= _A.DSL:Get("ui(cepkey_spin)") and _A.DSL:Get("alive")(Obj.key) end) >= 3 then
--             _A.CastSpellByID(spell_ids["Chain Heal"], lowestTarget)           
--         end
--     end    
--  end,},

--------------------------------------------------------------------------------------------------------------------------------------------------------------------


    --Solo gpt






    
   -- {"Хранитель бурь", "spell.ready && player.mana>=35 && !player.buff(191634)"},
    

   
    
    
    
   -- {"Lava Burst", "spell.ready && player.mana>=35 && player.buff(77762) & los", "target"},
   -- {"Flame Shock", "spell.ready && spell.range && los && !target.debuff(188389) & los", "target"},
   -- {"Земной шок", "spell.ready && spell.range && (infront || lookAt) && los", "target"},    
   -- {"Chain Lightning", "spell.ready && spell.range && ui(cepkey_check) && los && area_range(8).combatEnemies>=ui(cepkey_spin)", "target"},
   -- {"Землетрясение", "spell.ready && spell.range && ui(zemkey_check) && player.maelstrom >=60 && los && area_range(8).combatEnemies>=ui(zemkey_spin)", "target.ground"},
   -- {"Молния", "spell.ready && spell.range && (infront || lookAt) && los", "target"},
    
   
    

--     ----------АоE------------
--     --------Первозданная волна--    поток лавы--268609--    114050-
--     {function()
--        if _A.DSL:Get("spell.ready")(_, spell_ids["Primordial Wave"]) then
--            local Enemy = _A.OM:Get('EnemyCombat')
--            for _,Obj in pairs(Enemy) do            
--                if _A.DSL:Get("los")(Obj.key) then 
--                    if cache.aoe then              
--                        if _A.DSL:Get("range")(Obj.key) < 3 then
--                            _A.CastSpellByID(spell_ids["Primordial Wave"], Obj.key)
--                        end
--                    end
--                end 
--            end
--        end
--     end,},
--     ------------Дух дикого зверя----------------
--     {function()
--         if _A.DSL:Get("spell.ready")(_, spell_ids["Feral Spirit"]) then            
--             local Enemy = _A.OM:Get('EnemyCombat')
--             for _,Obj in pairs(Enemy) do                    
--                 if _A.DSL:Get("los")(Obj.key) then 
--                     if cache.aoe then              
--                         if _A.DSL:Get("range")(Obj.key) < 3 then
--                             _A.CastSpellByID(spell_ids["Feral Spirit"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end,},
--     --------Вскипание лавы-----------
--     {function()
--         if _A.DSL:Get("spell.ready")(_, spell_ids["Lava Lash"]) then            
--             local Enemy = _A.OM:Get('EnemyCombat')
--             for _,Obj in pairs(Enemy) do                    
--                 if _A.DSL:Get("los")(Obj.key) then 
--                     if cache.aoe then             
--                         if _A.DSL:Get("range")(Obj.key) < 3 then
--                             _A.CastSpellByID(spell_ids["Lava Lash"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end,},
--     ---------Огненный шок------------
--     {function()
--         if _A.DSL:Get("spell.ready")(_, spell_ids["Flame Shock"]) then            
--             local Enemy = _A.OM:Get('EnemyCombat')
--             for _,Obj in pairs(Enemy) do                    
--                 if _A.DSL:Get("los")(Obj.key) then 
--                     if not _A.DSL:Get("debuff")(Obj.key, spell_ids["Flame Shock"]) then
--                         if cache.aoe then            
--                             if _A.DSL:Get("range")(Obj.key) < 39 then
--                                 _A.CastSpellByID(spell_ids["Flame Shock"], Obj.key)
--                             end
--                         end
--                     end
--                 end
--             end
--         end
--     end,},
--     -----------Расскол-----------
--     {function()
--         if _A.DSL:Get("spell.ready")(_, spell_ids["Sundering"]) then            
--             local Enemy = _A.OM:Get('EnemyCombat')
--             for _,Obj in pairs(Enemy) do                    
--                 if _A.DSL:Get("los")(Obj.key) then 
--                     if cache.aoe then              
--                         if _A.DSL:Get("range")(Obj.key) < 3 then
--                             _A.CastSpellByID(spell_ids["Sundering"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end,},
--  -------------Молния------------
--  {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Lightning Bolt"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then 
--                 if _A.DSL:Get("buff")("player", 375986) then
--                     if _A.DSL:Get("buff.stack")("player", 344179) > 9 then
--                         if cache.aoe then             
--                             if _A.DSL:Get("range")(Obj.key) < 39 then
--                                 _A.CastSpellByID(spell_ids["Lightning Bolt"], Obj.key)
--                             end
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ---------Цепная молния------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Chain Lightning"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then 
--                 if _A.DSL:Get("buff.stack")("player", 344179) > 9 then
--                     if cache.aoe then             
--                         if _A.DSL:Get("range")(Obj.key) < 39 then
--                             _A.CastSpellByID(spell_ids["Chain Lightning"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ---------Тотем неистовства ветра----------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Windfury Totem"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then 
--                 if not _A.DSL:Get("buff")("player", 327942) then
--                     if cache.aoe then           
--                         if _A.DSL:Get("range")(Obj.key) < 3 then
--                             _A.CastSpellByID(spell_ids["Windfury Totem"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ------------Сокрушающая молния--------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Crash Lightning"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then 
--                 if cache.aoe then              
--                     if _A.DSL:Get("range")(Obj.key) < 3 then
--                         _A.CastSpellByID(spell_ids["Crash Lightning"], Obj.key)
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ------------ Ледяной клинок---------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Ice Strike"]) then
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then 
--                 if cache.aoe then         
--                     if _A.DSL:Get("range")(Obj.key) < 39 then
--                         _A.CastSpellByID(spell_ids["Ice Strike"], Obj.key)
--                     end
--                 end
--             end 
--         end
--     end
-- end,},
-- -------------Ледяной шок------------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Frost Shock"]) then
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then 
--                 if _A.DSL:Get("buff.stack")("player", 334196) > 9 then                  
--                     if _A.DSL:Get("los")(Obj.key) then 
--                         if cache.aoe then         
--                             if _A.DSL:Get("range")(Obj.key) < 39 then
--                                 _A.CastSpellByID(spell_ids["Frost Shock"], Obj.key)
--                             end
--                         end
--                     end
--                 end
--             end 
--         end
--     end
-- end,},
-- ---------Удар бури-------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Stormstrike"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then             
--                 if _A.DSL:Get("range")(Obj.key) < 3 then
--                     if cache.aoe then
--                         _A.CastSpellByID(spell_ids["Stormstrike"], Obj.key)
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ---------Цепная молния(5 стаков водоворота)------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Chain Lightning"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then 
--                 if _A.DSL:Get("buff.stack")("player", 344179) > 5 then
--                     if cache.aoe then              
--                         if _A.DSL:Get("range")(Obj.key) < 3 then
--                             _A.CastSpellByID(spell_ids["Chain Lightning"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ---------------------------------------------------------------------------------------------------
-- -----------------------Соло цель ротация-----------------------------
-- -----------------------Первозданная волна----------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Stormstrike"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then
--                 if _A.DSL:Get("buff")("player", 201184) then            
--                     if _A.DSL:Get("range")(Obj.key) < 3 then
--                         if not cache.aoe then 
--                             _A.CastSpellByID(spell_ids["Stormstrike"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- {function()
--    if _A.DSL:Get("spell.ready")(_, spell_ids["Primordial Wave"]) then
--        local Enemy = _A.OM:Get('EnemyCombat')
--        for _,Obj in pairs(Enemy) do            
--            if _A.DSL:Get("los")(Obj.key) then 
--                if not cache.aoe then      
--                    if _A.DSL:Get("range")(Obj.key) <= 39 then
--                        _A.CastSpellByID(spell_ids["Primordial Wave"], Obj.key)
--                    end
--                end
--            end 
--        end
--    end
-- end,},
-- --------------------Огненный шок---------------------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Flame Shock"]) then
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then
--                 if not _A.DSL:Get("debuff")(Obj.key, spell_ids["Flame Shock"]) then          
--                     if _A.DSL:Get("spell.range")(Obj.key, spell_ids["Flame Shock"]) then
--                         if not cache.aoe then 
--                             _A.CastSpellByID(spell_ids["Flame Shock"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ------------------Дух дикого волка---------------------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Feral Spirit"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then             
--                 if _A.DSL:Get("range")(Obj.key) < 3 then
--                     if not cache.aoe then 
--                         _A.CastSpellByID(spell_ids["Feral Spirit"], Obj.key)
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ----------------Тотем нистовства ветра-------------------------
--     {function()
--         if _A.DSL:Get("spell.ready")(_, spell_ids["Windfury Totem"]) then            
--             local Enemy = _A.OM:Get('EnemyCombat')
--             for _,Obj in pairs(Enemy) do                    
--                 if _A.DSL:Get("los")(Obj.key) then
--                     if not _A.DSL:Get("buff")("player", 327942) then            
--                         if _A.DSL:Get("range")(Obj.key) < 3 then
--                             if not cache.aoe then 
--                                 _A.CastSpellByID(spell_ids["Windfury Totem"], Obj.key)
--                             end
--                         end
--                     end
--                 end
--             end
--         end
--     end,},
-- ---------------Расскол----------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Sundering"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then            
--                 if _A.DSL:Get("range")(Obj.key) < 3 then
--                     if not cache.aoe then 
--                         _A.CastSpellByID(spell_ids["Sundering"], Obj.key)
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ---------Вскипание лавы(прок Горячая рука)-----------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Lava Lash"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then 
--                 if _A.DSL:Get("buff")("player", 215785) then           
--                     if _A.DSL:Get("range")(Obj.key) < 3 then
--                         if not cache.aoe then 
--                             _A.CastSpellByID(spell_ids["Lava Lash"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ------------Выброс лавы-----------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Lava Burst"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then
--                 if _A.DSL:Get("buff.stack")("player", 344179) > 9 then            
--                     if _A.DSL:Get("range")(Obj.key) < 39 then
--                         if not cache.aoe then 
--                             _A.CastSpellByID(spell_ids["Lava Burst"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- -----------Молния----------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Lightning Bolt"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then
--                 if _A.DSL:Get("buff.stack")("player", 344179) > 4 then           
--                     if _A.DSL:Get("range")(Obj.key) < 39 then
--                         if not cache.aoe then 
--                             _A.CastSpellByID(spell_ids["Lightning Bolt"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- -----------Ледяной клинок----------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Ice Strike"]) then
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then       
--                 if _A.DSL:Get("range")(Obj.key) < 39 then
--                     if not cache.aoe then 
--                         _A.CastSpellByID(spell_ids["Ice Strike"], Obj.key)
--                     end
--                 end
--             end 
--         end
--     end
-- end,},
-- -----------Вскипание лавы---------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Lava Lash"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then        
--                 if _A.DSL:Get("range")(Obj.key) < 3 then
--                     if not cache.aoe then 
--                         _A.CastSpellByID(spell_ids["Lava Lash"], Obj.key)
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ---------Ледяной шок------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Frost Shock"]) then
--         if _A.DSL:Get("buff.stack")("player", 334196) > 9 then
--             local Enemy = _A.OM:Get('EnemyCombat')
--             for _,Obj in pairs(Enemy) do                    
--                 if _A.DSL:Get("los")(Obj.key) then      
--                     if _A.DSL:Get("range")(Obj.key) < 39 then
--                         if not cache.aoe then 
--                             _A.CastSpellByID(spell_ids["Frost Shock"], Obj.key)
--                         end
--                     end
--                 end
--             end 
--         end
--     end
-- end,},
-- ------------Сокрушающая молния--------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Crash Lightning"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then
--                 if cache.aoe then              
--                     if _A.DSL:Get("range")(Obj.key) < 3 then
--                         if not cache.aoe then 
--                             _A.CastSpellByID(spell_ids["Crash Lightning"], Obj.key)
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end,},
-- ---------Удар бури-------------
-- {function()
--     if _A.DSL:Get("spell.ready")(_, spell_ids["Stormstrike"]) then            
--         local Enemy = _A.OM:Get('EnemyCombat')
--         for _,Obj in pairs(Enemy) do                    
--             if _A.DSL:Get("los")(Obj.key) then          
--                     if _A.DSL:Get("range")(Obj.key) < 3 then
--                         if not cache.aoe then 
--                         _A.UseAction(C_ActionBar.FindSpellActionButtons(spell_ids["Stormstrike"])[1])
--                     end
--                 end
--             end
--         end
--     end
-- end,},
------------------------------------------------------------
}

local Interrupts = {

    {{
        {"Wind Shear", "spell.range && isCastingAny && interruptible && interruptAt(60) && los", "EnemyCombat"},
    }, "spell(Пронизывающий ветер).ready"},


    ---{function()
       -- local Player = Object("player")
        --local do_interrupt = ui("do_interrupt")
       -- if do_interrupt and Player:SpellReady(Spells.Rebuke.name) then
          --  for _, Obj in pairs(_A.OM:Get('EnemyCombat')) do
              --  if Obj:isCasting() and Obj:Interruptat(80) and Obj:Range() <= 9 then
                 --   return Obj:Cast(Spells.Rebuke.name)
           --     end
        --    end
    ---    end
    ---end,},
}
local Cooldowns = {
}

local Tank = {    

    --{"Жажда крови", "spell.ready && spell.range && boss && los", "target"}, 
    {"Быстрина", "health <=ui(Bkey_spin) && spell.ready && spell.range && los && !buff", "roster"},
   -- {"Щит земли", "spell.ready && exists && spell.range && !buff", "Tank"},
   

    {"Возрождение духа", "ui(vozkey_check) && spell.ready && spell.range && debuff(Magic)", "roster"},

   --{{
   --    {"Щит земли", "spell.ready && spell.range && !buff", "TANK"},
   -- }, "exists"},

    
        {"Возрождение духа", "ui(vozkey_check) && spell.ready && spell.range && debuff(Magic)", "roster"},
    
    
}


local inCombat = {

    {Tank},
    {Bless},
    
    --{"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<4", "dead"},


    



    {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"},
    {SelfProtectAlly},
    {SelfProtect},
    {RotationCache},
    {Rotation},
}
local outOfCombat = {

    {Rotation},


    
    --{"Перерождение", "ui(perkey_check) && count(3).hp<=ui(perkey_spin) && count(3).distance<=35", "roster"},

    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<7", "dead"},

    {"Lightning Shield", "spell.ready && player.mana>=35 && !player.buff(192106)"},
    
    {Tank},  
        
    {Bless},
    --{"Щит земли", "exists && spell.range && spell.ready && !buff(974)", "tank"},
    {"Водный щит", "spell.ready && !player.buff(52127)"},

}

_A.CR:Add(264, {
    name = "[RestorationGit(test)]",
    load = function()
        print("Load function executed")
        exeOnLoad()
    end,
    gui = GUI,
    gui_st = {title="Healing by Alex", color="1EFF0C", width="400", height="500"},
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
