--[[ LuaUM ]]--

----------------------------------------
--[[ description:
  -- Examples of simple finctions.
  -- Примеры реализации простых функций.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: LUM.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local F = far.Flags

----------------------------------------
--local context = context

----------------------------------------
--local farUt = require "Rh_Scripts.Utils.farUtils"

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------

---------------------------------------- Quick information
local far2u = require "far2.utils"

function LuaFarVersion ()
  local Ver = { '\n',
    "FAR Manager: ", far.AdvControl(F.ACTL_GETFARVERSION), '\n\n',
    "LuaFAR: ", tostring(far.LuafarVersion()), '\n',
    "LuaFAR for Editor: ",
    tostring(far2u and far2u.GetPluginVersion and
             far2u.GetPluginVersion() or -- FAR 3+
             lf4ed and lf4ed.version and lf4ed.version() or -- FAR 2
             "unknown"), '\n\n',
    "Lua dll version: ", tostring(_G._VERSION), '\n\n',
    "Plugin Path:\n",
    far.PluginStartupInfo().ModuleName:match("(.*[/\\])"), '\n',
  } --- Ver
  far.Message(table.concat(Ver), "LuaFAR Version", nil, "l")
end ---- LuaFarVersion

-- Глобальное окружение --
function GlobalVarsData ()
  --logShow(_G, "Non-standard globals", "d0 w _")
  logShow(_G, "Non-standard globals", "d1 w _")
end ---- GlobalVarsData

---------------------------------------- Hello, World!

-- Окно с сообщением --
function HelloWorldMsg (Args, Cfg)
  local Scope = Cfg.Config.Scope
  far.Message("Hello, world!", "Message ("..Scope.Area..")")
end ---- HelloWorldMsg

-- Текст в редактор --
function HelloWorldText (Args, Cfg)
  local Scope = Cfg.Config.Scope
  if Scope.Area == "editor" then
    editor.InsertText(nil, "Hello, world!")
  else
    panel.InsertCmdLine(nil, "Hello, world!")
  end
end ---- HelloWorldText

---------------------------------------- Functions

-- Глобальное окружение --
function GlobalEnvironment ()
  logShow(_G, "Global Environment", "d0 w _/")
  logShow(_G._Plugin, "_Plugin data", "d0 w _f")
  --logShow(_G, "Global Environment", "d1 fts")
end ---- GlobalEnvironment

-- Окружение функции --
function FunctionEnvironment ()
  logShow(getfenv(), "Function Environment", "d2 w _/")
end ---- FunctionEnvironment

--[[
-- Локальная функция --
local function LocalFunction ()
  return "Some Local Function"
end -- LocalFunction
--]]

local CArgs   = "Arguments: %s"
--local CDefCfg = "Default Config: %s"

-- Аргументы функции --
function DefaultArguments (Args, Cfg)
  -- [[
  -- 1. Конфигурация среды
  logShow(Cfg.Item, CArgs:format"Item", 3)
  --logShow(Cfg.Config, CArgs:format("Config"), 3)
  for k, v in pairs(Cfg.Config) do
    logShow(v, CArgs:format("Config: "..k), 2)
  end
  --]]
  -- 2. Проверка __index
  --local DefCfg = getmetatable(Cfg).__index
  --logShow(DefArg, "Default Config", 3)
  --[[
  -- -- Отдельные значения
  for k, v in pairs(DefCfg) do
    if type(v) ~= 'table' then
      logShow(v, CDefCfg:format(tostring(k)), 2)
    end
  end
  --]]
  -- -- Отдельные подзначения:
  --logShow(DefCfg.Config.CfgData, CDefCfg:format"CfgData", 3)
  --logShow(DefCfg.Config.ArgData, CDefCfg:format"ArgData", 3)
end ---- DefaultArguments

-- Аргументы функции --
function FunctionArguments (Args, Cfg)
  local tp = type(Args)
  -- Число аргументов
  local ArgCount = tp == 'table'  and #Args or
                   tp == 'string' and Args:len() or 0
  logShow(Args, CArgs:format("count = "..tostring(ArgCount)), 2)
  --[[
  -- 1. Список аргументов.
  for k = 1, ArgCount do -- Аргументы функции:
    logShow(Args[k], CArgs:format(tostring(k)), 2)
  end
  --]]
  if tp ~= 'table' or ArgCount > 1 then return end
  -- [[
  -- 2. Параметр скрипта.
  local Arg = Args[1]
  if Arg then
    --Arg = Arg()
    logShow(Arg, "Function argument")
  end
  --]]
end ---- FunctionArguments

-- Функция таблицы --
Var = {}
function Var.SubFunction (Args, Cfg)
  local Scope = Cfg.Config.Scope
  far.Message("Table Function", "Message: "..Scope.Area)
end

--logShow({ ... }, "LumScripts", 3)

-- Функция модуля --
module ("LumScripts", package.seeall)

function ModFunction (Args, Cfg)
  local Scope = Cfg.Config.Scope
  far.Message("Module Function", "Message: "..Scope.Area)
end

--------------------------------------------------------------------------------