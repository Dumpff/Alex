local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
-- on top of the CR
local ui = function(key) return _A.DSL:Get("ui")(_, key) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local keybind = function(key) return _A.DSL:Get("keybind")(_, key) end
-- etc.. for DSLs/Methods that do not require target
local DSL = function(api) return _A.DSL:Get(api) end





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

_A.DSL:Register("CancelAura", function(_, id)
    ids = tonumber(id)
    if not ids then return end
    local name = GetSpellInfo(ids);
    if name then
        _A.RunMacroText('/cancelaura '..name)  
    end
end)

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

_A.DSL:Register({'isBoss', 'boss'}, function(unit)
    if DSL("exists")(unit) then
        if IsInInstance() then
            for _, boss in ipairs(bossNames) do
                if boss.alive and boss.name==DSL('name')(unit)then
                    return true
                end
            end
        else
            local estimatedWorldBossHP = DSL("health.max")("player")*3
            if DSL("isdummy")(unit) or DSL("health.max")(unit)>=estimatedWorldBossHP then
                return true
            end
        end
    end
end)

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
  
    {"/petdismiss", "ui(pettype)=0 && exists && timeout(sfsdfr, 5)", "pet"}, 
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
        --{type = "texture", texture = "Interface\\Addons\\Apofis\\Core\\media\\MyLogo.tga", width = 420, height = 200, offset = 190, y= -90, align = "center"},
        
        ---Атакубщие скилы
    
        {type = "ruler"},
        {type = "header", text = "Атакующие скилы", align = "center", size = "16"},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "checkbox", cw = 15, ch= 15, size = 15, text = "Повернуться, подойти к цели", key = "povorot", default = false},
        {type = "spacer", size = 7},
        {type = "dropdown", width = 250, size = 14, text = "Выбор пета", key = "pettype", list = pet, default = "0"},
        {type = "spacer", size = 7},
        {type = "dropdown", width = 250, size = 14, text = "Выбор проклятия", key = "blesstype", list = Bless_List, default = "0"},
        {type = "spacer", size = 7},
        {type = "checkbox", cw = 15, ch= 15, size = 14, text = FlexIcon(172, 16, 16, false).."Мультидотинг", key = "porkey", default = false},           --мультидотинг
        {type = "spacer", size = 7},
        --{type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(686, 16, 16, true), key = "strela", default = true},                            --стрела тьмы                       
        --{type = "spacer", size = 7},
        -- {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(198590, 16, 16, true), key = "dusa", default = true},                            --похищение души                      
        -- {type = "spacer", size = 7},
        -- {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(316099, 16, 16, true), key = "nestab", default = true},                            --нестабильное колдовство                       
        -- {type = "spacer", size = 7},

       
        ----------АОЕ

        {type = "ruler"},
        {type = "header", text = "АОЕ", align = "center", size = "16"},
        {type = "ruler"},        
        {type = "spacer", size = 10},

        {type = "checkspin", cw = 15, ch= 15, key = "semkey", size = 14, text = FlexIcon(27243, 16, 16, true), default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 2, align = "left"},  --семя порчи
        {type = "spacer", size = 7}, 
        {type = "checkspin", cw = 15, ch= 15, key = "pagkey", size = 14, text = FlexIcon(324536, 16, 16, true), default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 1, align = "left"},  --пагубный восторг
        {type = "spacer", size = 7},
        {type = "checkspin", cw = 15, ch= 15, key = "sozer", size = 14, text = FlexIcon(205180, 16, 16, true), default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 1, align = "left"},  -- Призыв созерцателя тьмы
        {type = "spacer", size = 7},
        -- {type = "checkspin", cw = 15, ch= 15, key = "singul", size = 14, text = FlexIcon(205179, 16, 16, true), default = true, min = 1, max = 10, step = 1, shiftStep = 5, spin = 1, align = "left"}, --Призрачная сингулярность
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
    
            ---- Защитные скилы 
    
        {type = "ruler"},
        {type = "header", text = "Защитные скилы", align = "center", size = "16", offset = 15},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "checkbox", cw = 15, ch= 15, size = 15, text = FlexIcon(20707, 16, 16, true), key = "ss_enable", default = true},                            --Камень души                       
        {type = "spacer", size = 7},
        {type = "checkspin", cw = 15, ch= 15, key = "HWkey", size = 14, text = FlexIcon(6201, 16, 16, false).."Камень здоровья", default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 45, align = "left"},   -- Камень здоровья
        {type = "spacer", size = 7},
        {type = "checkspin", cw = 15, ch= 15, key = "PWkey", size = 14, text = FlexIcon(234153, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 50, align = "left"}, --похищение жизни
        {type = "spacer", size = 7},
        {type = "checkspin", cw = 15, ch= 15, key = "reshkey", size = 14, text = FlexIcon(104773, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 40, align = "left"},                   -- Твердая решимость
        {type = "spacer", size = 7},
        {type = "checkspin", cw = 15, ch= 15, key = "tlen", size = 14, text = FlexIcon(6789, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 30, align = "left"},                        -- Лик тлена
        {type = "spacer", size = 7},
        {type = "checkspin", cw = 15, ch= 15, key = "kanall", size = 14, text = FlexIcon(755, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 30, align = "left"},                        -- Лик тлена
        {type = "spacer", size = 7},

        -----При нажатии кнопки---------
        {type = "ruler"},
        {type = "header", text = "Нажатие кнопок", align = "center", size = "16", offset = 15},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "input", size = 14, text = FlexIcon(5782, 16, 16, true), key = "fearkey_key", width = 65, default = "T"},
        {type = "spacer", size = 7},
        {type = "input", size = 14, text = FlexIcon(755, 16, 16, true), key = "kanal_key", width = 65, default = "Alt"},
        {type = "spacer", size = 7},

        {type = "input", size = 14, text = FlexIcon(108503, 16, 16, true), key = "grimuar", width = 65, default = "G"},
        {type = "spacer", size = 7},
        {type = "input", size = 14, text = FlexIcon(111400, 16, 16, true), key = "beg", width = 65, default = "R"},
        {type = "spacer", size = 7},

        
        -----Набор талантов---------
        {type = "ruler"},
        {type = "header", text = "Набор талантов", align = "center", size = "16", offset = 15},
        {type = "ruler"},
        {type = "spacer", size = 10},

       -- { type = "spacer", size = 12 }, -- !!!!!
        {type = "text", text = "Afflication Warlock Raid Build:", align = "left", size = "14", offset = 15},
        { type = "spacer", size = 10 },
        { type = "button", size = 15, text = "Click to copy!", width = 300, height = "20", callback = function() _A.CopyToClipboard(talent_row1)  end, align = 'CENTER' },
        { type = "spacer", size = 10 },
        {type = "text", text = "Afflication Warlock M+ Build:", align = "left", size = "14", offset = 15},
        { type = "spacer", size = 10 },
        { type = "button", size = 15, text = "Click to copy!", width = 300, height = "20", callback = function() _A.CopyToClipboard(talent_row2)  end, align = 'CENTER' },
        --{ type = "spacer", size = 10 },
        


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
    ["Похищение души"] = 198590,
    ["Лик тлена"] = 6789,
    ["Запрет чар"] = 119910,
    ["Призрачная сингулярность"] = 205179,
    ["Вытягивание жизни"] = 63106,
    ["Пагуба"] = 278350,
    ["Обмен душами"] = 386951,
    ["Блуждающий дух"] = 48181,
    ["Гниение души"] = 386997,
    ["Горящая душа"] = 385899,
    ["Призыв созерцателя тьмы"] = 205180,
    ["Гримуар жертвоприношения"] = 108503,
    ["Стремительный бег"] = 111400,
    ["Burning Rush"] = 111400,
    ["Темный пакт"] = 108416,
    ["Dark Pact"] = 108416,

}

local exeOnLoad = function()
    print("Afflication was loaded")

    _A.Interface:ShowToggle("Cooldowns", false)
    _A.Interface:ShowToggle("aoe", false)

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

    {"@myLib.face", "ui(povorot) ", "target"},
    {"Порча", "ui(porkey) && spell.ready && !debuff && los", "EnemiesCombat"},
    --{"#trinket1", "item.usable", {"target.ground", "target"}},
    --{"#trinket2", "item.usable", {"target.ground", "target"}},
    {"1714", "spell.ready && spell.range && !debuff && los && boss", "target"},
    {"Гниение души", "spell.ready && spell(Агония).range && !target.debuff && los && player.soulshards>=1 && area_range(10).combatEnemies>=2 && !player.moving", "target"},
    {"Призыв созерцателя тьмы", "ui(sozer_check) && spell.ready && player.mana>=50 && area_range(10).combatEnemies>=ui(sozer_spin) && !player.moving", "target"},
    {"Пагуба", "spell.ready && spell(Агония).range && !target.debuff && los && player.soulshards>=2 && area_range(10).combatEnemies>=2 && !player.moving", "target.ground"},
    
    
    {"Семя порчи", "spell.ready && spell.range && los(player) && ui(semkey_check) && player.soulshards>=1 && area_range(10).combatEnemies>=ui(semkey_spin) && !target.debuff && !player.moving", "target"}, -- && !lastCast(27243).succeed
    {"Блуждающий дух", "spell.ready && spell.range && !target.debuff && los && !player.moving", "target"},
    
    {"Похищение жизни", "spell.ready && spell.range && los(player) && !player.moving && player.buff(334320).count>= 30", "target"},
             
    {"Порча", "spell.ready && spell.range && !target.debuff && los", "target"},
    {"Агония", "spell.ready && spell.range && !target.debuff", "target"}, 

    {"Нестабильное колдовство", "ui(nestab) && spell.range && !player.moving && los(player) && !debuff && !lastCast(316099).succeed", "target"},
    {"Вытягивание жизни", "spell.ready && spell.range && !target.debuff && los", "target"},
    {"Пагубный восторг", "spell.ready && ui(pagkey_check) && player.soulshards>=3 && area_range(10).combatEnemies>=ui(pagkey_spin) && !player.moving", "target"},
    {"Призрачная сингулярность", "spell.ready && spell.range && ui(singul_check) && area_range(10).combatEnemies>=ui(singul_spin) && los", "target"},
    
    
    --{"Пагубный восторг", "spell.ready && spell.range && ui(pagkey_check) && los && area_range(10).combatEnemies>=ui(pagkey_spin) && count(Порча).enemies.debuffs>=ui(pagkey_spin) && soulshards >= 3", "target"},
    {"Стрела Тьмы", "spell.ready && spell.range && los(player) && !player.moving && player.buff(264571)", "target"},       
    {"Обмен душами", "spell.ready && spell.range && !target.debuff && los && !player.moving", "target"},
    {"Стрела Тьмы", "spell.ready && spell.range && los(player) && !player.moving", "target"},
    {"Похищение души", "ui(dusa) && spell.ready && spell(Агония).range && los(player) && !player.moving", "target"},
    {"Похищение души", "spell.ready && spell(Агония).range && los(player) && !player.moving && player.buff(264571)", "target"},


    
    -- {{
    --     {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(1)"},
    --     {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(2)"},
    --     {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(3)"},
    --     {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(4)"},
    --     {"*Reap Souls", "player.buff(Deadwind Harvester).duration<duration_UA(5)"},
    -- }, "noGCD && player.buff(Tormented Souls).count>1"},
    
}

local Survival = {
    {"Dark Pact", "talent && !lastcast(Unending Resolve) && spell.ready && !buff(Unending Resolve) && incdmg(3)>=health.max*0.4", "player"},    
  }

  local Trini = {

    {"#trinket1", "equipped(197960) && item(197960).usable", "player"},
    {"#trinket1", "equipped(193757) && item(193757).usable", "target"},
    {"#trinket1", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable", "target.ground"},
    {"#trinket1", "equipped(Giant Ornamental Pearl) && item(Giant Ornamental Pearl).usable", "player"},
    {"#trinket1", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},

    {"#trinket2", "equipped(197960) && item(197960).usable", "player"},
    {"#trinket2", "equipped(193757) && item(193757).usable", "target"},
    {"#trinket2", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable", "target.ground"},
    {"#trinket2", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},
    {"#trinket2", "equipped(Coagulated Nightwell Residue) && item(Coagulated Nightwell Residue).usable && buff(Nightwell Energy).count>=8", "player"},
  }

local Interrupts = {

    -- {{
    --     {"*Запрет чар", "spell.range && isCastingAny && interruptible && interruptAt(60) && los", "EnemyCombat"},
    -- }, "toggle(do_interrupt) && spell(Запрет чар).ready"},

    {{
        {"*Запрет чар", "spell.range && isCastingAny && interruptible && interruptAt(60) && los", "EnemyCombat"},
    }, "toggle(Interrupts) && spell(Запрет чар).ready"},    
 }
local Cooldowns = {
}

local inCombat = {
    {Interrupts},
    {Survival},
    {Trini},
    {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"}, --автотаргет    
    {Bless},    
    {SelfProtectAlly},
    {SelfProtect},
    {RotationCache},
    {Rotation},
}
local outOfCombat = {
    -- {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"}, --автотаргет    
    -- {"Порча", "spell.ready && spell.range && los(player) && !target.debuff && timeout(Порча,0.2)", "target"},
    -- {"Порча", "ui(porkey) && spell.ready && los(player) && !debuff", "EnemiesCombat"},

    {pet_choice},
    {"Камень души", "UI(ss_enable) && !buff && spell.ready && spell.range && los && !player.moving", {"focus", "player"}},    
    {"Создание камня здоровья", "ui(HWkey_check) && spell.ready && !player.moving && item(Камень здоровья).count==0 && !lastCast(6201).succeed"},
    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<7", "dead"},
   -- {"Быстрина", "health <=ui(Bkey_spin) && spell.ready && spell.range && los && !buff", "roster"},     
    {SelfProtect},
    {pet_choice},
}

_A.CR:Add(265, {
    name = "[Afflication]",
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
