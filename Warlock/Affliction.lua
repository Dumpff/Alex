local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
-- on top of the CR
local ui = function(key) return _A.DSL:Get("ui")(_, key) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local keybind = function(key) return _A.DSL:Get("keybind")(_, key) end
-- etc.. for DSLs/Methods that do not require target
local DSL = function(api) return _A.DSL:Get(api) end

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
--------------------------------Для подсчета дебафов нестабильное колдовство--------------------------------

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
    --{key = "2", text = FlexIcon(980, 16, 16, true)},                                        --Проклятие агонии  
    --{key = "3", text = FlexIcon(382021, 16, 16, true)},                                        --Оружие жизни земли
    {key = "0", text = "Disable"},
}

local Bless = {
    {"702", "ui(blesstype)=1 && !target.debuff && spell.ready && spell.range", "target"},                            --Проклятие слабости
    --{"980", "ui(blesstype)=2 && !target.debuff && spell.ready && spell.range", "target"},                             --Проклятие агонии  
    --{"382021", "ui(blesstype)=3 && !W_Enchant(6498) && spell.ready"},                            --Оружие жизни земли
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
    --{key = "3", text = FlexIcon(382021, 16, 16, true)},                                        --Оружие жизни земли
    {key = "0", text = "Без пета"},
}

local pet_choice = {
    {"/run PetDismiss()", "ui(pettype)=0 && pet.exists", "pet"},
    {"688", "ui(pettype)=1 && !lastCast(688).succeed && spell.ready && !ObjExist(416) && !player.moving && !pet"},                            --Бес
    {"697", "ui(pettype)=2 && !lastCast(697).succeed && spell.ready && !ObjExist(1860) && !player.moving && !pet"},                           --Синяк  
   -- {"382021", "ui(blesstype)=3 && !W_Enchant(6498) && spell.ready"},                            --Оружие жизни земли
}









local GUI = {        
        --{type = "texture", texture = "Interface\\Addons\\Apofis\\Core\\media\\MyLogo.tga", width = 420, height = 200, offset = 190, y= -90, align = "center"},
        
        ---Лечебные скилы
    
        {type = "ruler"},
        {type = "header", text = "Атакующие скилы", align = "center", size = "16"},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "checkbox", cw = 15, ch= 15, size = 15, text = "Повернуться, подойти к цели", key = "povorot", default = false},
        {type = "spacer", size = 7},
        {type = "dropdown", width = 180, size = 14, text = "Выбор пета", key = "pettype", list = pet, default = "0"},
        {type = "spacer", size = 7},
        {type = "dropdown", width = 180, size = 14, text = "Выбор проклятия", key = "blesstype", list = Bless_List, default = "0"},
        {type = "spacer", size = 7},
        {type = "checkbox", cw = 15, ch= 15, size = 14, text = FlexIcon(172, 16, 16, false).."Мультидотинг", key = "porkey", default = true},           --мультифлтинг
        {type = "spacer", size = 7},
        {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(686, 16, 16, true), key = "strela", default = true},                            --стрела тьмы                       
        {type = "spacer", size = 7},
        {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(316099, 16, 16, true), key = "nestab", default = true},                            --нестабильное колдовство                       
        {type = "spacer", size = 7},
        --{type = "dropdown", width = 180, size = 14, text = "Enchant offhand", key = "blesstype", list = Bless_List, default = "0"},
        --{type = "spacer", size = 7},     
        {type = "checkspin", cw = 15, ch= 15, key = "PWkey", size = 14, text = FlexIcon(234153, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"}, --похищение жизни
        {type = "spacer", size = 7},
        

        {type = "ruler"},
        {type = "header", text = "АОЕ", align = "center", size = "16"},
        {type = "ruler"},
        {type = "spacer", size = 10},

        {type = "checkspin", cw = 15, ch= 15, key = "semkey", size = 14, text = FlexIcon(27243, 16, 16, true), default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 3, align = "left"},  --семя порчи
        {type = "spacer", size = 7}, 
        {type = "checkspin", cw = 15, ch= 15, key = "pagkey", size = 14, text = FlexIcon(324536, 16, 16, true), default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 3, align = "left"},  --пагубный восторг
        {type = "spacer", size = 7},
        -- {type = "checkspin", key = "Bkey", size = 14, text = FlexIcon(61295, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        -- {type = "spacer", size = 7},
        -- {type = "checkspin", key = "healkey", size = 14, text = FlexIcon(8004, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        -- {type = "spacer", size = 7},
        -- {type = "checkspin", key = "cepkey", size = 14, text = FlexIcon(1064, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        -- {type = "spacer", size = 7},
        -- {type = "checkspin", key = "blagkey", size = 14, text = FlexIcon(79206, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        -- {type = "spacer", size = 7},

        ---- Тотемы
    
        -- {type = "ruler"},
        -- {type = "header", text = "Totems", align = "center", size = "16"},
        -- {type = "ruler"},
        -- {type = "spacer", size = 10},
        -- {type = "checkspin", key = "tothkey", size = 14, text = FlexIcon(5394, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        -- {type = "spacer", size = 7},
        -- {type = "checkspin", key = "totthkey", size = 14, text = FlexIcon(108280, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        -- {type = "spacer", size = 7},
    
        ---- Диспелы
    
        -- {type = "ruler"},
        -- {type = "header", text = "Dispels", align = "center", size = "16"},
        -- {type = "ruler"},
        -- {type = "spacer", size = 10},
        -- {key = "purgekey", type = "checkbox", size = 14, text = FlexIcon(370, 16, 16, true), default = true, align = "left", check = true,}, 
        -- {type = "spacer", size = 7},
        -- {key = "vozkey", type = "checkbox", size = 14, text = FlexIcon(77130, 16, 16, true), default = true, align = "left", check = true,}, 
        -- {type = "spacer", size = 7},
    
            ---- Defensive Ally Abilities 
    
        {type = "ruler"},
        {type = "header", text = "Защитные скилы", align = "center", size = "16", offset = 15},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(20707, 16, 16, true), key = "ss_enable", default = true},                            --Камень души                       
        {type = "spacer", size = 7},
        {type = "checkspin", cw = 15, ch= 15, key = "HWkey", size = 14, text = FlexIcon(6201, 16, 16, false).."Камень здоровья", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", cw = 15, ch= 15, key = "reshkey", size = 14, text = FlexIcon(104773, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},

        -----При нажатии кнопки---------
        {type = "ruler"},
        {type = "header", text = "Нажатие кнопок", align = "center", size = "16", offset = 15},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "input", size = 14, text = FlexIcon(5782, 16, 16, true), key = "fearkey_key", width = 65, default = "R"},
        {type = "spacer", size = 7},
        {type = "input", size = 14, text = FlexIcon(755, 16, 16, true), key = "kanal_key", width = 65, default = "Alt"},
        {type = "spacer", size = 7},
        


        -- {key = "Astral Shift", type = "checkspin", size = 14, text = FlexIcon(108271, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60},
        -- {type = "spacer"},
        -- {type = "checkspin", key = "predkkey", size = 14, text = FlexIcon(108281, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        -- {type = "spacer", size = 7},
        -- {type = "checkspin", key = "perkey", size = 14, text = FlexIcon(114052, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        -- {type = "spacer", size = 7},
}
local spell_ids = {
    ["Создание камня здоровья"] = 6201,
    ["Порча"] = 172,
    ["Агония"] = 980,
    ["Стрела Тьмы"] = 686,
    ["Твердая решимость"] = 104773,
    ["Похищение жизни"] = 234153,
    ["Страх"] = 5782,
    ["Пагубный восторг"] = 324536,
    ["Камень души"] = 20707,
    ["Семя порчи"] = 27243,
    ["Нестабильное колдовство"] = 316099,
    ["Канал здоровья"] = 755,
    ["Бесконечное дыхание"] = 5697,
}

local exeOnLoad = function()
    print("Afflication was loaded")

    _A.Interface:AddToggle({key = "AutoTarget", name = "Авто Таргет", text = "Автотаргет когда цель умерла или не существует", icon = "Interface\\Icons\\ability_hunter_snipershot",})
    _A.Interface:AddToggle({key = "AutoLoot", name = "Авто Лут", text = "Автоматически лутает мобов вокруг вас", icon = "Interface\\Icons\\inv_misc_gift_05"})


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
    {"#Камень здоровья", "player.health <=ui(HWkey_spin) && item(Камень здоровья).count>0 && item(Камень здоровья).usable", "player"},
    {"Твердая решимость", "ui(reshkey_check) && player.health <=ui(reshkey_spin) && spell.ready", "player"},
    {"Страх", "keybind({ui(fearkey_key)}) && spell.ready && spell.range && los && !moving", "target"},
    {"Канал здоровья", "keybind({ui(kanal_key)}) && spell.ready && spell.range && los && !moving", "pet"},
    {"Бесконечное дыхание", "spell.ready && spell.range && los(player) && !player.buff && timeout(Бесконечное дыхание,0.2) && player.swimming", "player"},

   --{"Astral Shift", "ui(Astral Shift_check) && player.health <= ui(Astral Shift_spin)", "player"},
   -- {"&Spirit Walk", "ui(Spirit Walk_check) && player.state(root)", "player"},
   -- {"Исцеляющий всплеск", "spell.ready && ui(healkey_check) && player.health <=ui(healkey_spin)", "player"},
   -- {"Элементаль огня", "ui(Fire Elemental_check) && area_range(8).combatEnemies >=ui(Fire Elemental_spin)", "player"},
}
local SelfProtectAlly = {

    
   -- {"&Ancestral Guidance", "ui(Ancestral GuidanceTank_check) && lowest.health <= ui(Ancestral GuidanceTank_spin) && lowest.hasrole(TANK)", "lowest"},
   -- {"&Earth Elemental", "ui(Earth ElementalTank_check) && lowest.health <= ui(Earth ElementalTank_spin) && lowest.hasrole(TANK)", "lowest"},
}

local Rotation = {

    {"@myLib.face", "ui(povorot) ", "target"},
    {"Порча", "ui(porkey) && spell.ready && los(player) && !debuff", "EnemiesCombat"},
    {"Порча", "spell.ready && spell.range && los(player) && !target.debuff && timeout(Порча,0.2)", "target"},
    {"Агония", "spell.ready && spell.range && los(player) && !target.debuff && timeout(Агония,0.2)", "target"},
    {"Похищение жизни", "ui(PWkey_check) && player.health <=ui(PWkey_spin) && spell.ready && spell.range && !player.moving && los(player)", "target"},
    {"Семя порчи", "spell.ready && spell.range && los && ui(semkey_check) && player.soulshards>=2 && area_range(10).combatEnemies>=ui(semkey_spin) && !target.debuff && !player.moving && !lastCast(27243).succeed", "target"},
    {"Пагубный восторг", "spell.ready && ui(pagkey_check) && player.soulshards>=2 && area_range(10).combatEnemies>=ui(pagkey_spin) && !player.moving", "target"},
    --{"Пагубный восторг", "spell.ready && spell.range && ui(pagkey_check) && los && area_range(10).combatEnemies>=ui(pagkey_spin) && count(Порча).enemies.debuffs>=ui(pagkey_spin) && soulshards >= 3", "target"},
    {"!Стрела Тьмы", "spell.ready && spell.range && los(player) && !player.moving && player.buff(264571)", "target"},
    {"Нестабильное колдовство", "ui(nestab) && spell.range && ttd>6 && player.soulshards>=2 && CountUAs<2 && !player.moving && los(player) && !debuff && !lastCast(316099).succeed", "target"},
    {"Стрела Тьмы", "ui(strela) && spell.ready && spell.range && los(player) && !player.moving", "target"},



    
    {{
        {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(1)"},
        {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(2)"},
        {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(3)"},
        {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(4)"},
        {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(5)"},
    }, "noGCD && player.buff(Tormented Souls).count>1"},
    
}

local Interrupts = {    
}
local Cooldowns = {
}

local inCombat = {
    {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"}, --автотаргет    
    {Bless},    
    {SelfProtectAlly},
    {SelfProtect},
    {RotationCache},
    {Rotation},
}
local outOfCombat = {
    {"Камень души", "UI(ss_enable) && !buff && spell.ready && spell.range && los && !player.moving", {"focus", "player"}},    
    {"Создание камня здоровья", "ui(HWkey_check) && spell.ready && !player.moving && item(Камень здоровья).count<1"},
    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<7", "dead"},
   -- {"Быстрина", "health <=ui(Bkey_spin) && spell.ready && spell.range && los && !buff", "roster"},     
    {SelfProtect},
    {pet_choice},
}

_A.CR:Add(265, {
    name = "[AfflicationGit]",
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
