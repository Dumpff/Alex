local addonName, _A = ...
local DSL = function(api) return _A.DSL:Get(api) end

local looting = false
local function loot()
    looting = true
    for i=1, _A.GetNumLootItems() do
        if _A.LootSlotHasItem(i) then
            _A.LootSlot(i)
        end
    end
    _A.C_Timer.After(1, function()
        _A.CloseLoot()
        looting = false
    end)
end    

_A.Library:Add("Utils", {
    -- AutoLoot
    AutoLoot = function(target)
        if LootFrame:IsShown() then
            if not looting then
                loot()
            end
        else
            _A.InteractUnit(target)
        end
    end,
})
------------------------------------------------------------

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
end,})
------------------------------------------------------------
