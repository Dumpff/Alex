local addonName, _A = ...
local _G = _A._G
local U = _A.Cache.Utils
-- on top of the CR
local ui = function(key) return _A.DSL:Get("ui")(_, key) end
local toggle = function(key) return _A.DSL:Get("toggle")(_, key) end
local keybind = function(key) return _A.DSL:Get("keybind")(_, key) end
-- etc.. for DSLs/Methods that do not require target
local DSL = function(api) return _A.DSL:Get(api) end

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


local GUI = {  
    {type = "checkbox", cw = 15, ch= 15, size = 15, text = "Повернуться, подойти к цели", key = "povorot", default = false},
    {type = "spacer", size = 7},
}

local spell_ids = {
    ["Освежающее лечебное зелье"] = 191378,
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
    ["Исступление"] = 272651, -- петовская
    ["Изнеможение"] = 57723,
    

}

local exeOnLoad = function()
    print("BM was loaded")
    _A.Interface:ShowToggle("Cooldowns", false)
   -- _A.Interface:ShowToggle("aoe", false)
    _A.Interface:AddToggle({key = "AutoTarget", name = "Авто Таргет", text = "Автотаргет когда цель умерла или не существует", icon = "Interface\\Icons\\ability_hunter_snipershot",})
    _A.Interface:AddToggle({key = "AutoLoot", name = "Авто Лут", text = "Автоматически лутает мобов вокруг вас", icon = "Interface\\Icons\\inv_misc_gift_05"})
 
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

    
    {"@myLib.face", "ui(povorot) ", "target"},
    {"Hunter's Mark", "spell.ready && isboss && !debuff && timeout(HMark, 0.2)", "target"},
    --{"Hunter's Mark", "spell.ready && !debuff && timeout(HMark, 0.2)", "Boss1"},
    {"Blood Fury", "spell.ready && isboss", "target"},
    {"Blood Fury", "spell.ready", "Boss1"},
    {"Death Chakram", nil, "Boss1"},--
    {"Death Chakram", "isboss", "target"},
	{"Barbed Shot", nil, "target"},--   
    ---------{"%Разрывающий выстрел", nil, "target"}, 
	-------- {"A Murder of Crows", "talent", "target"},
	-------- {"Stampede", "talent && ttd>24 && {player.buff(Bloodlust) || player.buff(Bestial Wrath) || spell(Bestial Wrath).cooldown<3}", "player"},
	-------- {"Dire Beast", "spell(Bestial Wrath).cooldown>3", "target"},
	-------- {"Dire Frenzy", "talent && {pet.buff(Dire Frenzy).duration<=1.5 || spell(Dire Frenzy).charges>0.8}", "target"},
	-------- {"Chimaera Shot", "talent &&  player.focus<90", "target"},
	{"Bestial Wrath", "pet.exists && !pet.dead", "pet"},--
    {function() _A.CastSpellByID(34026, "target") end, "exists && spell(34026).ready && pet.exists && los", {"target", "pet"}},            --команда взять---
 
	--------{"6603", "pet.exists && spell(34026).ready && kludge(34026)", {"target", "pet"}}, --  at least it do the job :D
    --{function() _A.CastSpellByID(272651, "pet") end, "exists && spell(272651).ready && !player.debuff(Изнеможение) && pet.exists", {"Boss1", "player"}},                          -- умение пета
    {"Исступление", "!player.debuff(57723) && !player.debuff(Изнеможение) && spell.ready && isboss && pet.exists", {"Boss1", "player"}},
	--------{"Kill Command", "spell.ready", "target"},
	{"Cobra Shot", nil, "target"},--
    {"!Kill Shot", nil, "target"},--
	------- {"Concussive Shot", "spell.range && player.focus<40", "target"},
}

local AOE = {
	-- {"A Murder of Crows", "talent", "target"},
	-- {"Barrage", nil, "target"},
     {"Death Chakram", nil, "target"},
	 {"Multi-Shot", "!player.buff(Удар зверя)", "target"},
	 {"Multi-Shot", "pet.buff(Удар зверя).duration<gcd || !pet.buff(Удар зверя)", "target"},
	-- {"Chimaera Shot", "talent &&  player.focus<90", "target"},
	-- {"Kill Command", nil, "target"},
	-- {"Cobra Shot", nil, "target"},
}	


local Survival = {
    {"#Освежающее лечебное зелье", "player.health<=25 && item(Освежающее лечебное зелье).count>0 && item(Освежающее лечебное зелье).usable", "player"},
	{"Exhilaration", "spell.ready && health<=40", "player"},
	{"Mend Pet", "health<=75 && !pet.dead && pet.exists && timeout(Mend, 0.2)", "pet"},
    {"ResPet", "pet.dead && timeout(ResPet, 0.2) && pet.exists", "pet"},
    {"Survival of the Fittest", "!lastcast(Exhilaration) && spell.ready && incdmg(3)>=health.max*0.4", "player"},    
  }

  local Trini = {

    {"#trinket1", "equipped(197960) && item(197960).usable", "player"},
    {"#trinket1", "equipped(193757) && item(193757).usable && los", "target"},
    {"#trinket1", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable && los", "target.ground"},
    {"#trinket1", "equipped(193769) && item(193769).usable && los", "target.ground"},
    {"#trinket1", "equipped(Giant Ornamental Pearl) && item(Giant Ornamental Pearl).usable", "player"},
    {"#trinket1", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},

    {"#trinket2", "equipped(197960) && item(197960).usable", "player"},
    {"#trinket2", "equipped(193757) && item(193757).usable && los", "target"},
    {"#trinket2", "equipped(Взрывающийся фрагмент копья) && item(Взрывающийся фрагмент копья).usable && los", "target.ground"},
    {"#trinket1", "equipped(193769) && item(193769).usable && los", "target.ground"},
    {"#trinket2", "equipped(Talisman of the Cragshaper) && item(Talisman of the Cragshaper).usable", "player"},
    {"#trinket2", "equipped(Coagulated Nightwell Residue) && item(Coagulated Nightwell Residue).usable && buff(Nightwell Energy).count>=8", "player"},
  }

local Interrupts = {
	{"Tranquilizing Shot", "target.buff(Magic).type", "target"},
	{"Tranquilizing Shot", "target.buff(Enrage).type", "target"},
	 --{"Counter Shot", nil, "EnemyCombat"},

    --  {{
    --     {"Tranquilizing Shot", "spell.range && {buff(Enrage).type || buff(Magic).type}", "enemycombat"},---------
    -- }, "talent(Tranquilizing Shot) && spell(Tranquilizing Shot).ready && !isRaid"},
     
    -- {{
    --     {"Tranquilizing Shot", "exists", "TS_enraged_magic"},
    -- }, "talent(Tranquilizing Shot) && spell(Tranquilizing Shot).ready"},

    {{
        {"*Counter Shot", "isCastingAny && interruptible && interruptAt(10) && los", "EnemyCombat"},
    }, "toggle(Interrupts) && spell(Counter Shot).ready"}, 
    
    {{
        {"Intimidation", "pet.exists && !pet.dead && isCastingAny && !immune", "EnemyCombat"},
    }, "toggle(Interrupts) && spell(Intimidation).ready &&  spell(Counter Shot).cooldown > 3"},
 }
local Cooldowns = {
}


local Validate = {
    {Trini},
   -- {'/startattack', '!auto.shoot'},	
    {Interrupts, "toggle(Interrupts)"},    
    {AOE, "area(15).enemies>=2 && toggle(aoe)"},
    {Rotation},
      
}

local inCombat = {   
    {"%pause", "player_lost_control"},
    {Survival},	
    {Validate}, 


     
    {"%target", "toggle(AutoTarget) && {!target.exists || target.dead}", "nearEnemyCb"}, --автотаргет    
    
}
local outOfCombat = { 
     
	{Survival},    
    {"@Utils.AutoLoot", "toggle(AutoLoot) && bagSpace>0 && hasLoot && distance<7", "dead"},      
 
}

_A.CR:Add(253, {
    name = "[BM]",
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
