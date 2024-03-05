local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
local DSL = function(api) return _A.DSL:Get(api) end


local GUI = {
        {type = "texture", texture = "Interface\\Addons\\Apofis\\Core\\media\\MyLogo.tga", width = 420, height = 200, offset = 190, y= -90, align = "center"},
        ---Атакующие скилы
        {type = "header", text = "Атакующие скилы", align = "center", size = "16"},
        {type = "spacer", size = 10},
        {type = "checkspin", key = "zemkey", size = 14, text = _A.Core:GetSpellIcon(61882, 16, 16).."Землетрясение и колличество противников", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 5, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "cepkey", size = 14, text = _A.Core:GetSpellIcon(188443, 16, 16).."Цепнпя молния и колличество противников", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 3, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkbox", key = "zhokey", size = 14, text = _A.Core:GetSpellIcon(8042, 16, 16).."Земной шок", default = true, align = "left", check = true},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "blagkey", size = 14, text = _A.Core:GetSpellIcon(79206, 16, 16).."Благосклонность предков", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 3, align = "left"},
        {type = "spacer", size = 7},
        ---- Defensive Abilities
        {type = "header", text = "Защитные скилы", align = "center", size = "10"},
        {type = "spacer", size = 10},
        {type = "checkspin", key = "healkey", size = 14, text = _A.Core:GetSpellIcon(8004, 16, 16).."Исцеляющий всплеск", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "tothkey", size = 14, text = _A.Core:GetSpellIcon(5394, 16, 16).."Тотоем исцеляющего потока", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "predkkey", size = 14, text = _A.Core:GetSpellIcon(108281, 16, 16).."Наставления предков", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 3, align = "left"},
        {type = "spacer", size = 7},
        {key = "Astral Shift", type = "checkspin", text = "Астральный сдвиг", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60},
        {type = "spacer"},
            ---- Defensive Ally Abilities 
        {type = "header", text = "Массовые защитные скилы", align = "center", size = "10", offset = 15},
        {key = "Ancestral Guidance", type = "checkspin", text = "Наставление предков", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 3},
        {type = "spacer", size = 5},
        {key = "Earth Elemental", type = "checkspin", text = "Элементаль земли", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 3},
        {type = "spacer", size = 5},
        {key = "Fire Elemental", type = "checkspin", size = 14, text = _A.Core:GetSpellIcon(198067, 16, 16).."Элементаль огня", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 3},
        {type = "spacer", size = 5},
}
local spell_ids = {
    ["Bloodlust"] = 2825, -- Жажда крови
    ["Astral Shift"] = 108271, -- Астральный сдвиг (Талант)
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
    ["Earth Elemental"] = 198103, -- Элементаль земли(талант)
    ["Lava Lash"] = 60103, -- Вскипание лавы
    ["Crash Lightning"] = 187874, -- Сокрушающая молния
    ["Feral Spirit"] = 51533, -- дух дикого зверя
    ["Windfury Totem"] = 8512, -- Тотем неистовства ветра
    ["Ice Strike"] = 342240, -- Ледяной клинок
    ["Stormstrike"] = 17364, -- Удар бури
    ["Windfury Weapon"] = 33757, -- Оружие неистовства ветра
    ["Primordial Wave"] = 375982, -- Первозданная волна
    ["Sundering"] = 197214, -- Раскол
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
    {"Исцеляющий всплеск", "spell.ready && ui(healkey_check) && player.health <=ui(healkey_spin)", "player"},
    {"Элементаль огня", "ui(Fire Elemental_check) && area_range(8).combatEnemies >=ui(Fire Elemental_spin)", "player"},
}
local SelfProtectAlly = {
    {"&Ancestral Guidance", "ui(Ancestral GuidanceTank_check) && lowest.health <= ui(Ancestral GuidanceTank_spin) && lowest.hasrole(TANK)", "lowest"},
    {"&Earth Elemental", "ui(Earth ElementalTank_check) && lowest.health <= ui(Earth ElementalTank_spin) && lowest.hasrole(TANK)", "lowest"},
   
}
local Rotation = {
    
    
    {"Wind Shear", "spell.ready && spell.range && isCastingAny && interruptible && interruptAt(60) && los", "EnemyCombat"},
    {"Хранитель бурь", "spell.ready && player.mana>=35 && !player.buff(191634)"},
    {"Первозданная волна", "spell.ready && spell.range && los", "target"},

    {"Наставления предков", "spell.ready && ui(predkkey_check) && lowest.health <=ui(predkkey_spin)"},
    {"Тотем исцеляющего потока", "spell.ready && ui(tothkey_check) && player.health <=ui(tothkey_spin)"},
    {"Благосклонность предков", "spell.ready && ui(blagkey_check) && los && roster.health <=ui(blagkey_spin)", "roster"},
    {"Lightning Shield", "spell.ready && player.mana>=35 && !player.buff(192106)"},    
    {"Lava Burst", "spell.ready && player.mana>=35 && player.buff(77762) & los", "target"},
    {"Flame Shock", "spell.ready && spell.range && los && !target.debuff(188389) & los", "target"},
    {"Земной шок", "spell.ready && spell.range && (infront || lookAt) && los", "target"},
    {"Поток лавы", "spell.ready && player.mana>=35 && player.buff(114050) & los", "target"},
    {"Chain Lightning", "spell.ready && spell.range && ui(cepkey_check) && los && area_range(8).combatEnemies>=ui(cepkey_spin)", "target"},
    {"Землетрясение", "spell.ready && spell.range && ui(zemkey_check) && player.maelstrom >=60 && los && area_range(8).combatEnemies>=ui(zemkey_spin)", "target.ground"},
    {"Молния", "spell.ready && spell.range && (infront || lookAt) && los", "target"},
    
   
    

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
local inCombat = {
    --{"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<4", "dead"},


    



    {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"},
    {SelfProtectAlly},
    {SelfProtect},
    {RotationCache},
    {Rotation},
}
local outOfCombat = {

    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<7", "dead"},

    {"Lightning Shield", "spell.ready && player.mana>=35 && !player.buff(192106)"},

}

_A.CR:Add(262, {
    name = "[ElementalGit]",
    load = function()
        print("Load function executed")
        exeOnLoad()
    end,
    gui = GUI,
    gui_st = {title="Стихии by Алексей", color="1EFF0C", width="400", height="500"},
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
