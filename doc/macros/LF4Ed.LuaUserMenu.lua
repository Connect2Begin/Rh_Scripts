--[[ Macros with LuaFAR for Editor ]]--

----------------------------------------
--[[ description:
  -- Macros with LuaFAR for Editor plugin.
  -- Макросы с плагином LuaFAR for Editor.
--]]
----------------------------------------
--[[ uses:
  nil.
  -- group: Macros/Plugins.
--]]
--------------------------------------------------------------------------------

----------------------------------------
--local far = far
--local F = far.Flags

--local BlockNoneType = F.BTYPE_NONE

--local editor = editor

--------------------------------------------------------------------------------
--local unit = {}

----------------------------------------
local guids = {}
--unit.guids = guids

local Macro = Macro or function () end
local Plugin = Plugin or {}

--local Async = function () return mmode(3, 1) end

local PluginExist = Plugin.Exist
local PluginMenu = Plugin.Menu
--local PluginMenu, CallPlugin = Plugin.Menu, Plugin.Call

---------------------------------------- 'L' -- LuaFAR for Editor
-- [[
guids.LF4Ed = "6F332978-08B8-4919-847A-EFBB6154C99A"

local Exist = function () return PluginExist(guids.LF4Ed) end

Macro {
  area = "Shell Editor Viewer",
  key = "CtrlL",
  flags = "",
  description = "LF4Ed: Menu",
  condition = Exist,
  action = function ()
    --return CallPlugin(guids.LF4Ed)
    return PluginMenu(guids.LF4Ed)
  end, ---
} ---

Macro {
  area = "Shell Editor Viewer",
  key = "AltShiftF2",
  flags = "",
  description = "LUM: Lua User Menu",
  condition = Exist,
  action = function ()
    if not PluginMenu(guids.LF4Ed) then return end
    return Keys"M"
  end, ---
} ---

Macro {
  area = "Shell Editor Viewer",
  key = "CtrlAltShiftF2",
  flags = "",
  description = "LUM: Tortoise SVN",
  condition = Exist,
  action = function ()
    if not PluginMenu(guids.LF4Ed) then return end
    return Keys"S"
    --return Keys"S T"
  end, ---
} ---

--[=[
Macro {
  area = "Editor",
  key = "CtrlJ",
  flags = "",
  description = "LUM: Template Insert",
  condition = Exist,
  action = function ()
    if not PluginMenu(guids.LF4Ed) then return end
    -- TODO: Добавить проверку наличия окна LUM.
    return Keys"M J"
  end, ---
} ---
--]=]
--]]
--------------------------------------------------------------------------------
