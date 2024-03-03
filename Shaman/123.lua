local addonName, _A = ...

local body = [[
local addonName, _A = ...
local U = _A.Cache.Utils;
local DSL = function(api) return _A.DSL:Get(api) end

local inCombat = {}
local outCombat = {}

_A.CR:Add(264, {
    name = "Cloud",
    ic = inCombat,
    ooc = outCombat,
    wow_ver = "10.1.7",
    apep_ver = "1.1",
    load = exeOnLoad,
    unload = exeOnUnload,
_A.Interface:ResetCRs(),
})
]]

local Name = "Cloud"
_A.print("|cffFACC2E"..Name.." loaded.|r")
_A.CR:Set(GetSpecializationInfo(GetSpecialization()), Name, true) ---> 3rd parameter (true -> from the net)
_A.Interface:ResetCRs()

local func, errorMessage = loadstring(body, "DrunkMate")
if func then
    func(addonName, _A)
else
    message("|cFFff0000loadstring error|r\n\n"..errorMessage)
end
