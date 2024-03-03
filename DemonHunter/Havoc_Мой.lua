local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
local DSL = function(api) return _A.DSL:Get(api) end

local GUI = {
    {type = "texture", texture = "Interface\\Addons\\Apofis\\Core\\media\\MyLogo.tga", width = 420, height = 200, offset = 190, y= -90, align = "center"},
    ---- Defensive Abilities
    {type = "spacer", size =10},
    {type = "header", size = 16, text = "Использовать ли скилы                         Колличество",color = "FF3F40", align = "center"},   
    {type = "spacer", size = 10},
    {type = "checkspin", key = "metkey", size = 14, text = _A.Core:GetSpellIcon(191427, 16, 16).."Метаморфоза и колличество противников", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 60, align = "left"},
    {type = "spacer", size = 7},
    {type = "checkspin", key = "chaoskey", size = 14, text = _A.Core:GetSpellIcon(179057, 16, 16).."Кольцо Хаоса и колличество противников", default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 60, align = "left"},
    {type = "spacer", size = 7},
    {type = "checkspin", size = 14, text = _A.Core:GetSpellIcon(198589, 16, 16).."Затуманивание и % жизни", key = "tumankey", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
    {type = "spacer", size = 7},
    {key = "do_interrupt", type = "checkbox", size = 14, text = _A.Core:GetSpellIcon(183752, 16, 16).."Прерывание", default = true, align = "left", check = true,}, 
    {type = "spacer", size = 7},
   -- {key = "Ignore Pain", type = "checkspin", text = "Стойкость к боли", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60},
   -- {type = "spacer", size = 5},
   -- {key = "Victory Rush", type = "checkspin", text = "Победный раж", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60},
   -- {type = "spacer", size = 5},

    {type = "header", size = 16, text = "Настройки зелий",color = "FF3F40", align = "center"},
    {type = "spacer", size = 10},
    {key = "healpotionuse",      type = "checkspin",   text = "[Зелье Здоровья]|r", default = true, spin = 20, min = 1, max = 100, step = 1, shiftStep = 5, width = 70},
    {type = "spacer"},
    {key = "manapotionuse",      type = "checkspin",   text = "[Зелье Маны]|r", default = true, spin = 20, min = 1, max = 100, step = 1, shiftStep = 5, width = 70},
    {type = "spacer"},

    {key = "hs",      type = "checkspin", size = 14, text = _A.Core:GetItemIcon(129196, 16, 16).."[Камень здоровья]|r", default = true, spin = 20, min = 1, max = 100, step = 1, shiftStep = 5, width = 70},
    {type = "spacer"},
   -- {key = "ws",      type = "checkspin",   text = "[Warlock Stone]|r", default = true, spin = 20, min = 1, max = 100, step = 1, shiftStep = 5, width = 70},
   -- {type = "spacer"},
        ---- Defensive Ally Abilities 
   -- {type = "header", text = "Массовые защитные скилы", align = "center", size = "10", offset = 15},
   -- {key = "Rallying Cry", type = "checkspin", text = "Ободряющий клич", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 20},
   -- {type = "spacer", size = 5},

}

local spell_ids = {  
    ["Interr"] = GetSpellInfo(183752), -- Прерывание
    ["DemonBite"] = GetSpellInfo(162243), -- Укус демона
    ["Tuman"] = GetSpellInfo(198589), -- Затуманивание
    ["ChaosStrikeLVL1"] = GetSpellInfo(162794), -- Удар хаоса
    ["ChaosStrikeLVL2"] = GetSpellInfo(320413), -- Удар хаоса
    ["ChaosStrikeLVL3"] = GetSpellInfo(343206), -- Удар хаоса
    ["BladeDanceLVL1"] = GetSpellInfo(188499), -- Танец клинков
    ["BladeDanceLVL2"] = GetSpellInfo(320402), -- Танец клинков
    ["BurningHeatLVL1"] = GetSpellInfo(258920), -- -----------Обжигающий жар------------
    ["BurningHeatLVL2"] = GetSpellInfo(320364), -- -----------Обжигающий жар------------
    ["BurningHeatLVL3"] = GetSpellInfo(320377), -- -----------Обжигающий жар------------
    ["PiercingGazeLVL1"] = GetSpellInfo(198013), -----------Пронзающий взгляд------------
    ["PiercingGazeLVL2"] = GetSpellInfo(320415), -----------Пронзающий взгляд------------
    ["PiercingGazeLVL3"] = GetSpellInfo(343311), -----------Пронзающий взгляд------------    
    ["Sigil of Flame"] = GetSpellInfo(204596),      -- Печать огня

    ["MetamorphosisLVL1"] = GetSpellInfo(191427), -----------Метаморфоза------------
    ["MetamorphosisLVL2"] = GetSpellInfo(320422), -----------Метаморфоза------------
    ["MetamorphosisLVL3"] = GetSpellInfo(320421), -----------Метаморфоза------------
    ["MetamorphosisLVL4"] = GetSpellInfo(320645), -----------Метаморфоза------------
    ["Anigilation"] = GetSpellInfo(201427),         -- Анигиляция
    ["DeathStrike"] = GetSpellInfo(210152),         -- Смертоносный взмах
    
}

 -- Rebuke
 --if ui("do_interrupt") then
 --   if enemy then
 --       if enemy:isCastingAnySpell()
 --       and enemy:SpellRange(spells.Rebuke.name) then
 --           if enemy:Interruptat(_A.RandomNumber(35, 60)) then
 --               return enemy:Cast(spells.Rebuke.name)
 --           end
 --       end
 --   end
--end


local exeOnLoad = function()
    print("Ротация загруженна")    
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
    if count > 3 then
      cache.aoe = true
    end
  end,},
 }
 
 local SelfProtect = {
     {"tumankey", "ui(tumankey_check) && player.health <= ui(tumankey_spin)", "player"},
     --{function()
     --   if _A.DSL:Get("spell.ready")(_, spell_ids["Berserker Rage"]) then
     --        if _A.DSL:Get("state")("player", "fear || incapacitate") then         
     --           _A.CastSpellByName(spell_ids["Berserker Rage"], "Player")
     --        end
     --   end
     --end,},
     --{"&tumankey", "ui(tumankey_check) && player.health <= ui(tumankey_spin)", "player"},
     {"&Victory Rush", "ui(Victory Rush_check) && player.health <= ui(Victory Rush_spin)", "target"},
     {"#5512", "ui(ws_check) && item(5512).usable && item(5512).count>0 && player.health<=UI(ws_spin)", "player"}, --XXX: Warlock Stone	
     {"#191380", "ui(hs_check) && item(191380).usable && item(191380).count>0 && player.health<=UI(hs_spin)", "player"}, --XXX: Health Stone	
 }

 local SelfProtectAlly = {
    {"&Rallying Cry", "ui(Rallying CryTank_check) && lowest.health <= ui(Rallying CryTank_spin) && lowest.hasrole(TANK)", "lowest"},
 }

 local Rotation = { 





    --{{
    --    {"Interr", "spell.range && isCastingAny && interruptible && interruptAt(60) && los", "EnemyCombat"},
   -- }, "toggle(do_interrupt) && spell(183752).ready"},



    {"Прерывание", "spell.ready && range<=5 && ui(do_interrupt_check) && isCastingAny && interruptible && interruptAt(60) && los", "target"},
    {"Tuman", "ui(tumankey_check) & spell.ready && health <= ui(tumankey_spin)", "player"},
   -- {"MetamorphosisLVL1", "spell.ready && range<=38 && player.fury>=10 && area_range(8).combatEnemies>=3", "target.ground"},
    {"Клинок Скверны", "spell.ready && range<=6", "target"},    
    {"Печать огня", "spell.ready && range<=3", "target.ground"},
    {"Обжигающий жар", "spell.ready && range<=4"},

    --{"Кольцо Хаоса", "spell.ready && range<=4 && area_range(8).combatEnemies>=2"},

    {"Метаморфоза", "spell.ready && range<=4 && ui(metkey_check) && player.fury>=70 && area_range(8).combatEnemies>=ui(metkey_spin)", "target.ground"},
    {"Кольцо Хаоса", "spell.ready && range<=4 && ui(chaoskey_check) && player.fury>=30 && area_range(8).combatEnemies>=ui(chaoskey_spin)"},

  --  {"Метаморфоза", "spell.ready && range<=4 && player.fury>=70 && area_range(8).combatEnemies>=3", "target.ground"},
    {"Анигиляция", "spell.ready && range<=3 && player.buff(Метаморфоза)", "target"},
    {"Смертоносный Взмах", "spell.ready && range<=3 && player.buff(Метаморфоза)", "target"},
    {"Пронзающий Взгляд", "spell.ready && range<=18", "target"},
    --{"Укус демона", "spell.ready && range<=3 && player.fury<=70", "target"},
    {"Танец Клинков", "spell.ready && range<=3", "target"},
    {"Удар Хаоса", "spell.ready && range<=3", "target"},
    {"Танец Клинков", "spell.ready && range<=3", "target"},

    {"Клинок Скверны", "spell.ready && range<=6", "target"},

    {"Укус демона", "spell.ready && range<=3 && player.fury<=70", "target"},
    {"Пронзающий Взгляд", "spell.ready && range<=18", "target"},
        
 ----------------Печать огня----------------204598---------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["Sigil of Flame"]) then
 --       if not cache.aoe then    
 --       local Enemy = _A.OM:Get('EnemyCombat')    
 --           if _A.DSL:Get("range")("target") < 3 then                                      
 --               for _,Obj in pairs(Enemy) do 
 --                   if not _A.DSL:Get("debuff")("target", 204598) then
 --                       _A.CastSpellByName(spell_ids["Sigil of Flame"])
 --                       _A.ClickPosition(Obj.key)
 --                   end                                           
 --               end
 --           end
 --       end
 --   end
 --end,},

    -----------Обжигающий жар------------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["BurningHeatLVL1"]) then        
 --       if _A.DSL:Get("range")("target") < 3 then            
 --           _A.CastSpellByName(spell_ids["BurningHeatLVL1"])
 --       end     
 --   end
 --end,},
  
 ------------Метаморфоза--------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["MetamorphosisLVL1"]) then            
 --   local Enemy = _A.OM:Get('EnemyCombat')    
 --       if _A.DSL:Get("range")("target") < 3 then
 --           if _A.DSL:Get("fury")("player") >= 20 then                    
 --               for _,Obj in pairs(Enemy) do
 --                   if not cache.aoe then
 --                       _A.CastSpellByName(spell_ids["MetamorphosisLVL1"])
 --                       _A.ClickPosition("player")                            
 --                   end                    
 --               end
 --           end
 --       end
 --   end
 --end, "ui(Metkey)"},

    ---------------Смертоносный взмах----------------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["DeathStrike"]) then            
 --   local Enemy = _A.OM:Get('EnemyCombat')    
 --       if _A.DSL:Get("range")("target") < 3 then
 --           if _A.DSL:Get("fury")("player") >= 35 then                    
 --               for _,Obj in pairs(Enemy) do
 --                   if not cache.aoe then
  --                      if _A.DSL:Get("buff")("player", 162264) then
 --                           _A.CastSpellByName(spell_ids["DeathStrike"], Obj.key)                                                              
 --                       end    
 --                   end                    
 --               end
 --           end
 --       end
 --   end
 --end,},

 ---------------Анигиляция----------------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["Anigilation"]) then            
 --   local Enemy = _A.OM:Get('EnemyCombat')    
 --       if _A.DSL:Get("range")("target") < 3 then
 --           if _A.DSL:Get("fury")("player") >= 40 then                    
 --               for _,Obj in pairs(Enemy) do
 --                   if not cache.aoe then
 --                       if _A.DSL:Get("buff")("player", 162264) then
 --                           _A.CastSpellByName(spell_ids["Anigilation"], Obj.key)                                                              
 --                       end    
 --                   end                    
 --               end
 --           end
 --       end
 --   end
 --end,},  

 -----------Пронзающий взгляд------------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["PiercingGazeLVL1"]) then
 --   local Enemy = _A.OM:Get('EnemyCombat')        
 --       if _A.DSL:Get("range")("target") < 3 then
 --           if  _A.DSL:Get("fury")("player") >= 30 then
 --               for _,Obj in pairs(Enemy) do
 --                   if not _A.DSL:Get("buff")("player", 162264) then                
 --                       _A.CastSpellByName(spell_ids["PiercingGazeLVL1"], Obj.key)
 --                   end
 --               end                                 
 --           end
 --      end
 --  end
 --end,},

 --------------Танец клинков-----------------

  --  {function()
  --      if _A.DSL:Get("spell.ready")(_, spell_ids["BladeDanceLVL1"]) then
  --      local Enemy = _A.OM:Get('EnemyCombat')        
  --          if _A.DSL:Get("range")("target") < 3 then
  --              if _A.DSL:Get("fury")("player") >= 35 then
  --                  for _,Obj in pairs(Enemy) do
  --                      if not _A.DSL:Get("buff")("player", 162264) then
  --                          _A.CastSpellByName(spell_ids["BladeDanceLVL1"], Obj.key)
  --                      end
  --                  end
  --              end
  --          end
  --      end
  -- end,},

 -------------Удар Хаоса------------_A.ObjectPosition(Obj.key)------

  --  {function()
  --      if _A.DSL:Get("spell.ready")(_, spell_ids["ChaosStrikeLVL1"]) then
  --      local Enemy = _A.OM:Get('EnemyCombat') 
  --          if _A.DSL:Get("fury")("player") >= 40 then
  --              if _A.DSL:Get("range")("target") < 3 then
  --                  for _,Obj in pairs(Enemy) do
  --                      if not _A.DSL:Get("buff")("player", 162264) then
  --                          _A.CastSpellByName(spell_ids["ChaosStrikeLVL1"], Obj.key)
  --                      end
  --                  end
  --              end
  --          end
  --      end
  --  end,},

 --------Укус демона----------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["DemonBite"]) then
 --   local Enemy = _A.OM:Get('EnemyCombat')       
 --       if _A.DSL:Get("range")("target") < 3 then
 --           if _A.DSL:Get("fury")("player") <= 70 then
 --               for _,Obj in pairs(Enemy) do                   
 --                   _A.CastSpellByName(spell_ids["DemonBite"], Obj.key)                    
 --               end
 --           end                 
 --       end
 --   end
 --end,},



    --------------------------------АОЕ--------------------------------------
    -----------------                                       -----------------
    -----------------                АОЕ                    -----------------
    -----------------                                       -----------------
    -----------------                                       -----------------
    --------------------------------АОЕ--------------------------------------

    ------------Метаморфоза--------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["MetamorphosisLVL1"]) then            
  --  local Enemy = _A.OM:Get('EnemyCombat')    
 --      if _A.DSL:Get("range")("target") < 3 then
 --           if _A.DSL:Get("fury")("player") >= 80 then                    
 --               for _,Obj in pairs(Enemy) do
 --                   if cache.aoe then
 --                       _A.CastSpellByName(spell_ids["MetamorphosisLVL1"])
 --                       _A.ClickPosition(_A.ObjectPosition(Obj.key))                            
 --                   end                    
 --               end
 --           end
 --       end
 --   end
 --end,},

    ---------------Смертоносный взмах----------------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["DeathStrike"]) then            
 --       local Enemy = _A.OM:Get('EnemyCombat')    
 --       if _A.DSL:Get("range")("target") < 3 then
 --           if _A.DSL:Get("fury")("player") >= 35 then                    
 --               for _,Obj in pairs(Enemy) do
 --                   if cache.aoe then
 --                       if _A.DSL:Get("buff")("player", 162264) then
 --                           _A.CastSpellByName(spell_ids["DeathStrike"], Obj.key)                                                              
 --                       end    
 --                   end                    
 --               end
 --           end
 --       end
 --   end
 --end,},

 ---------------Анигиляция----------------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["Anigilation"]) then         
 --       local Enemy = _A.OM:Get('EnemyCombat')    
 --       if _A.DSL:Get("range")("target") < 3 then
 --           if _A.DSL:Get("fury")("player") >= 40 then                    
 --               for _,Obj in pairs(Enemy) do
 --                   if cache.aoe then
 --                       if _A.DSL:Get("buff")("player", 162264) then
 --                           _A.CastSpellByName(spell_ids["Anigilation"], Obj.key)                                                              
 --                       end    
 --                   end                    
 --               end
 --           end
 --       end
 --   end
 --end,},

 ------------Затуманивание--------

 --{function()
 --   if _A.DSL:Get("spell.ready")(_, spell_ids["Tuman"]) then            
 --   local Enemy = _A.OM:Get('EnemyCombat')    
 --       if _A.DSL:Get("range")("target") < 3 then                                
 --           for _,Obj in pairs(Enemy) do
 --               if cache.aoe then
 --                   _A.CastSpellByName(spell_ids["Tuman"])                                        
 --               end
 --           end
 --       end
 --   end
 --end,},





    
   
    --------Копье бастиона(Кирии)------
    --{function()
    --    if _A.DSL:Get("spell.ready")(_, spell_ids["Spear of Bastion"]) then
    --        local Enemy = _A.OM:Get('Enemy')
    --        for _,Obj in pairs(Enemy) do
    --            if DSL("range")(Obj.key) < 3 then
    --                if _A.DSL:Get("debuff")("target", 208086) then         
    --                    _A.CastSpellByName(spell_ids["Spear of Bastion"], "target")
    --                    _A.ClickPosition(_A.ObjectPosition(Obj.key))
    --                end
    --            end
    --        end
    --    end
    --end,},
    ----------Удар колосса-------------
    --{function()
    --    if _A.DSL:Get("spell.ready")(_, spell_ids["Colossus Smash"]) then        
    --        if _A.DSL:Get("range")("target") < 3 then
    --            _A.CastSpellByName(spell_ids["Colossus Smash"], "target")
    --        end
    --    end
    --end,},

    --    {function()
    --        if _A.DSL:Get("spell.ready")(_, spell_ids["Mortal Strike"]) then
    --            if _A.DSL:Get("buff")("player", 335458) then         
    --                if _A.DSL:Get("range")("target") < 3 then
    --                    _A.CastSpellByName(spell_ids["Mortal Strike"], "target")
    --                end
    --            end
    --        end
    --    end,},
    ---------Казнь при проке----------
    --{function()
    --    if _A.DSL:Get("spell.ready")(_, spell_ids["Execute"]) then
    --        if _A.DSL:Get("buff")("player", 52437) then         
    --            if _A.DSL:Get("range")("target") < 3 then
    --                _A.CastSpellByName(spell_ids["Execute"], "target")
    --            end
    --        end
    --    end
    --end,},
     
    ---------Чародейский выстрел------------------------
    --{function()
    --    if _A.DSL:Get("spell.ready")(_, spell_ids["Arcaneshot"]) then       
    --        if _A.DSL:Get("range")("target") > 3 then
    --            _A.CastSpellByName(spell_ids["Arcaneshot"], "target")
    --           _A.PetAttack()
    --        end
    --    end
    --end,},

 ---------Верный выстрел------------------------
    --{function()
    --    if _A.DSL:Get("spell.ready")(_, spell_ids["Sureshot"]) then       
    --        if _A.DSL:Get("range")("target") > 3 then
    --            _A.CastSpellByName(spell_ids["Sureshot"], "target")
    --            _A.PetAttack()
	--	         end
    --    end
    --end,},

    ---------Подрезать крылья------------------------
    --{function()
    --    if _A.DSL:Get("spell.ready")(_, spell_ids["Wings"]) then       
    --        if _A.DSL:Get("range")("target") < 3 then
    --            _A.CastSpellByName(spell_ids["Wings"], "target")
    --            _A.PetAttack()
	--	         end
    --    end
    --end,},

    ---------Отрыв------------------------

    --{function()
    --    if _A.DSL:Get("spell.ready")(_, spell_ids["Separation"]) then       
    --        if _A.DSL:Get("range")("target") < 3 then
    --            _A.CastSpellByName(spell_ids["Separation"])
    --            _A.PetAttack()
    --             end
    --    end
    --end, "ui(sepkey)"},

    ---------Метка охотника------------------------

    --{function()
    --  --  if _A.DSL:Get("spell.ready")(_, spell_ids["HunterMark"]) then  
    --        if not _A.DSL:Get("debuff")("target", 257284) then     
    --        if _A.DSL:Get("range")("target") > 3 then
    --           _A.CastSpellByName(spell_ids["HunterMark"], "target")
    --           _A.PetAttack()            
    --           end
    --        end     
    -- -- end
   --end, "ui(markey)"},
 

}

local potions = {
    {{ -- Fel Healthstones
        {"#36892", "item(36892).count>0 && item(36892).usable", "player"},
        {"#36893", "item(36893).count>0 && item(36893).usable", "player"},
        {"#36894", "item(36894).count>0 && item(36894).usable", "player"},
    }, "player.health<ui(healthstoneuse)"},
    {{ -- Healing Potions
        {"#33447", "item(33447).count>0 && item(33447).usable", "player"},
        {"#43569", "item(43569).count>0 && item(43569).usable", "player"},
        {"#40087", "item(40087).count>0 && item(40087).usable", "player"},
        {"#41166", "item(41166).count>0 && item(41166).usable", "player"},
        {"#40067", "item(40067).count>0 && item(40067).usable", "player"},
    }, "player.health<ui(healpotionuse)"},
    {{ -- Mana Potions
        {"#33448", "item(33448).count>0 && item(33448).usable", "player"},
        {"#43570", "item(43570).count>0 && item(43570).usable", "player"},
        {"#40087", "item(40087).count>0 && item(40087).usable", "player"},
        {"#41166", "item(42545).count>0 && item(42545).usable", "player"},
        {"#40067", "item(39671).count>0 && item(39671).usable", "player"},
    }, "player.mana<ui(manapotionuse)"},
}



local Interrupts = {

    {"Interr", "spell.ready && spell.range && isCastingAny && interruptible && interruptAt(60) && los", "EnemyCombat"},
 
    



 --{function()
 --   local Player = Object("player")
 --   local do_interrupt = ui("do_interrupt")
 --   if do_interrupt and Player:SpellReady(Spells.Rebuke.name) then
 --       for _, Obj in pairs(_A.OM:Get('EnemyCombat')) do
 --           if Obj:isCasting() and Obj:Interruptat(80) and Obj:Range() <= 4 then
 --               return Obj:Cast(Spells.Rebuke.name)
 --           end
 --       end
 --   end
 --end,},

 --Interrupt = {
 --   function()
 --   local Enemy = Object("EnemyCombat")
 --   local Player = Object("player")
 --   local do_interrupt = ui("do_interrupt")
 --   if do_interrupt and Enemy and Player:SpellReady(Spells.Rebuke.name) and Enemy:Los() and Enemy:Interruptat(60) and Enemy:Range() <= 5 then
 --       return Enemy:Cast(Spells.Rebuke.name)
 --   end
 --end,
 --}

}
local Cooldowns = {
}



--local Pause = {
--    {"%pause", "player.casting"},
--    {"%pause", "player.channeling"},
--    {"%pause", "player.dead || target.dead || player_lost_control || player.iscasting"},
--}



local inCombat = {  
    {"tumankey", "ui(tumankey_check) && player.health <= ui(tumankey_spin)", "player"},  
    --{Pause},
    {SelfProtectAlly},
    {SelfProtect},
    {RotationCache},
    {Rotation},
    {Interrupts},
}
local outOfCombat = {
    --{Pause},
    {SelfProtect},
}



_A.CR:Add(577, {
    name = "[Havoc]",
    load = function()
        print("Load function executed")
        exeOnLoad()
    end,
    gui = GUI,
    gui_st = {title="Истребление by Алексей", color="1EFF0C", width="400", height="500"},
    ids = spell_ids,
    ic = inCombat,
    ooc = outOfCombat,
    blacklist = blacklist,    
    wow_ver = "10.1.7",
    apep_ver = "1.1",
    unload = function()
        print("Unload function executed")
        exeOnUnload()
    end
})