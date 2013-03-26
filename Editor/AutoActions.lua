--[[ Auto actions ]]--

----------------------------------------
--[[ description:
  -- Auto actions.
  -- Авто-действия.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  LF context,
  Text Templates,
  Word Completion.
  -- areas: editor.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local logShow = context.ShowInfo

local editors = ctxdata.editors

--------------------------------------------------------------------------------
-- AutoTemplates -- АвтоШаблоны:
local TT = require "Rh_Scripts.Editor.TextTemplate"
local TT_Execute = TT.Execute
local TT_CfgData = TT.AutoCfgData

-- AutoCompletion -- АвтоЗавершение:
local WC = require "Rh_Scripts.Editor.WordComplete"
local WC_Execute = WC.Execute
local WC_CfgData = WC.AutoCfgData

-- Using AutoTemplates on Word Completion.
-- Использование АвтоШаблонов при Завершении слов.
local function TT_CharPress (FarKey, Char)
  return TT_Execute(TT_CfgData)
end --
WC_CfgData.OnCharPress = TT_CharPress

---------------------------------------- Process
local F = far.Flags
local KEY_EVENT = F.KEY_EVENT

local k = 0x00

--far.Message(tostring(KEY_EVENT), "AutoActions")
--local dbg  = require "context.utils.useDebugs"
--local flog = dbg.open("AC_test.log", "a", "")

function ProcessEditorInput (rec) --> (bool)
  if rec.EventType == KEY_EVENT then
    --flog:logtab(rec, "rec", "xv4")
    if rec.KeyDown then
      --k = rec.VirtualKeyCode
      k = (rec.UnicodeChar or " "):byte() or 0x00
      --flog:logln(hex(k), "c1", "xv4")
    elseif k > 0x20 and k ~= 0x7F then
      --flog:logln(hex(k), "c2", "xv4")
      k = 0x00
      --logShow(rec, "rec", "xv4")
      --flog:logtab(rec, "rec", "xv4")
      TT_CfgData.FileType = editors.current.type
      --logShow(TT_CfgData, "TT_CfgData", 1)
      --TextTemplate(TT_CfgData)
      if not TT_Execute(TT_CfgData) then
        WC_Execute(WC_CfgData)
      end
    end
  end -- if

  return false
end ---- ProcessEditorInput
--------------------------------------------------------------------------------
