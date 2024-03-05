local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
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
    {key = "1", text = FlexIcon(318038, 16, 16, true)},                                        --Оружие языка пламени
    {key = "2", text = FlexIcon(33757, 16, 16, true)},                                         --Оружие неистовства ветра  
    {key = "3", text = FlexIcon(382021, 16, 16, true)},                                        --Оружие жизни земли
    {key = "0", text = "Disable"},
}

local Bless = {
    {"318038", "ui(blesstype)=1 && !W_Enchant(5400) && spell.ready"},                            --Оружие языка пламени
    {"33757", "ui(blesstype)=2 && !W_Enchant(5401) && spell.ready"},                             --Оружие неистовства ветра  
    {"382021", "ui(blesstype)=3 && !W_Enchant(6498) && spell.ready"},                            --Оружие жизни земли
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

local GUI = {        
        --{type = "texture", texture = "Interface\\Addons\\Apofis\\Core\\media\\MyLogo.tga", width = 420, height = 200, offset = 190, y= -90, align = "center"},
        
        ---Лечебные скилы
    
        {type = "ruler"},
        {type = "header", text = "Healing skills", align = "center", size = "16"},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {type = "dropdown", width = 180, size = 14, text = "Enchant mainhand", key = "blesstype", list = Bless_List, default = "0"},
        {type = "spacer", size = 7},
        --{type = "dropdown", width = 180, size = 14, text = "Enchant offhand", key = "blesstype", list = Bless_List, default = "0"},
        --{type = "spacer", size = 7},
        {type = "checkspin", key = "HWkey", size = 14, text = FlexIcon(77472, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "PWkey", size = 14, text = FlexIcon(375982, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "Bkey", size = 14, text = FlexIcon(61295, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "healkey", size = 14, text = FlexIcon(8004, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "cepkey", size = 14, text = FlexIcon(1064, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "blagkey", size = 14, text = FlexIcon(79206, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
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
        {type = "header", text = "Defense skills", align = "center", size = "16", offset = 15},
        {type = "ruler"},
        {type = "spacer", size = 10},
        {key = "Astral Shift", type = "checkspin", size = 14, text = FlexIcon(108271, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60},
        {type = "spacer"},
        {type = "checkspin", key = "predkkey", size = 14, text = FlexIcon(108281, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
        {type = "checkspin", key = "perkey", size = 14, text = FlexIcon(114052, 16, 16, true), default = true, min = 1, max = 100, step = 1, shiftStep = 5, spin = 60, align = "left"},
        {type = "spacer", size = 7},
}
local spell_ids = {
    ["Bloodlust"] = 2825, -- Жажда крови   
    ["Lava Burst"] = 51505, -- Выброс лавы (талант)
    ["Frost Shock"] = 196840, -- Ледяной шок(талант)
    ["Thunderstorm"] = 51490, -- гром и молния (талант)
    ["Lightning Bolt"] = 188196, -- Молния    
    ["Flame Shock"] = 188389, -- Огненный шок
    ["Flametongue Weapon"] = 318038, -- Оружие языка пламени
    ["Spirit Walk"] = 58875, -- Поступь духа
    ["Capacitor Totem"] = 192058, -- Тотем конденсации
    ["Wind Shear"] = 57994, -- Пронзающий ветер(Талант)
    ["Chain Lightning"] = 188443, -- Цепная молния    
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
    ["Healing Wawe"] = 77472,
    ["Первозданная волна"] = 375982,    
    ["Primordial Wave"] = 375982, -- Первозданная волна
    ["Быстрина"] = 61295,
    ["Riptide"] = 61295,
    ["Исцеляющий всплеск"] = 8004,
    ["Chain Heal"] = 1064,
    ["Цепное исцеление"] = 1064,
    ["Благосклонность предков"] = 79206,
    
    ["Тотем исцеляющего потока"] = 5394,
    ["Healing Stream Totem"] = 5394,
    ["Тотем целительного прилива"] = 108280,
    ["Healing Tide Totem"] = 108280,
    
    ["Развеивание магии"] = 370,
    ["Возрождение духа"] = 77130,
    
    ["Щит земли"] = 974,
    ["Водный щит"] = 52127,
    ["Water Shield"] = 52127,
    ["Lightning Shield"] = 192106, -- Щит молний
    
    
    ["Astral Shift"] = 108271, -- Астральный сдвиг (Талант)    
    ["Перерождение"] = 114052,
    ["Regrowth"] = 114052, 
    ["Наставления предков"] = 108281,
    ["Ancestral Guidance"] = 108281, -- Наставление предков(Талант)
}

local exeOnLoad = function()
    print("Restoration was loaded")

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
   -- {"&Spirit Walk", "ui(Spirit Walk_check) && player.state(root)", "player"},
   -- {"Исцеляющий всплеск", "spell.ready && ui(healkey_check) && player.health <=ui(healkey_spin)", "player"},
   -- {"Элементаль огня", "ui(Fire Elemental_check) && area_range(8).combatEnemies >=ui(Fire Elemental_spin)", "player"},
}
local SelfProtectAlly = {
   -- {"&Ancestral Guidance", "ui(Ancestral GuidanceTank_check) && lowest.health <= ui(Ancestral GuidanceTank_spin) && lowest.hasrole(TANK)", "lowest"},
   -- {"&Earth Elemental", "ui(Earth ElementalTank_check) && lowest.health <= ui(Earth ElementalTank_spin) && lowest.hasrole(TANK)", "lowest"},
   }

local Rotation = {
    {"Wind Shear", "spell.ready && spell.range && isCastingAny && interruptible && interruptAt(60) && los", "EnemyCombat"},
    {"Развеивание магии", "ui(purgekey_check) && spell.ready && spell.range", "EnemyCombat"},
    {"Возрождение духа", "ui(vozkey_check) && spell.ready && spell.range", "roster"},    
    
    {"Водный щит", "spell.ready && !player.buff"},    
    {"Lightning Shield", "spell.ready && !player.buff"},
    {"Перерождение", "ui(perkey_check) && roster.health <=ui(perkey_spin) && spell.ready && roster.distance <=35"},    
    {"Наставления предков", "roster.health <=ui(predkkey_spin) && ui(predkkey_check) && spell.ready"},    
    -------{">Тотем исцеляющего потока", "ui(tothkey_check) && lowest.health <=ui(tothkey_spin) && !exists || exists && distance >10 && spell.ready && lowest.range <=20", "totemID(3527)"}, 
    {"Тотем исцеляющего потока", "ui(tothkey_check) && lowest.health <=ui(tothkey_spin) && !ObjExist(3527) && spell.ready && lowest.range <=20", "roster"},
    --{"Тотем исцеляющего потока", "spell.ready && lowest.range<= 20 && ui(tothkey_check) && lowest.health<=ui(tothkey_spin)", "roster"},
    {"Тотем целительного прилива", "spell.ready && lowest.range<= 20 && ui(totthkey_check) && lowest.health<=ui(totthkey_spin)", "roster"},
    {"Благосклонность предков", "spell.ready && ui(blagkey_check) && roster.health <=ui(blagkey_spin)"},
    {"Первозданная волна", "ui(PWkey_check) && spell.ready && spell.range && health <=ui(PWkey_spin) && los", "lowest"},
    {"Быстрина", "ui(Bkey_check) && health <=ui(Bkey_spin) && spell.ready && spell.range && los && !buff", "roster"},   
    {"Волна исцеления", "ui(HWkey_check) && health <=ui(HWkey_spin) && spell.ready && spell.range && !moving && los", "lowest"},
    --{"Цепное исцеление", "health <=ui(cepkey_spin) && !moving && spell.ready && spell.range && los", "roster"},
    {"Цепное исцеление", "ui(cepkey_check) && roster.health <=ui(cepkey_spin) && !moving && spell.ready && spell.range", "lowest"},    
    {"Исцеляющий всплеск", "spell.ready && spell.range && !moving && ui(healkey_check) && health <=ui(healkey_spin)", "lowest"},
    
}

local Interrupts = {    
}
local Cooldowns = {
}
local Tank = {
    {"Быстрина", "health <=ui(Bkey_spin) && spell.ready && spell.range && los && !buff", "roster"},
    {"Щит земли", "!IsSolo && spell.ready && hasRole(tank) && spell.range && !buff", "realTank"},
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
    {Tank},
    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<7", "dead"},
         
   -- {Rotation}, 
    {SelfProtect},         
    {Bless},    
}

_A.CR:Add(264, {
    name = "[RestorationGit]",
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
