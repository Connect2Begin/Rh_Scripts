--[[ Subtitles' Date+Time ]]--

----------------------------------------
--[[ description:
  -- Date and time values handler.
  -- Обработчик значений даты и времени.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Subtitles, DateTime.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local unpack = unpack
local setmetatable = setmetatable

local modf = math.modf
local floor = math.floor

local format = string.format

----------------------------------------
--local bit = bit64

----------------------------------------
--local far = far
--local F = far.Flags

----------------------------------------
--local context = context

----------------------------------------
local Datim = require "Rh_Scripts.Utils.DateTime"
local newTime = Datim.newTime

----------------------------------------
-- [[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- information
local TplKit = { -- Информация о шаблонах:
  sub_default = {
    -- Позиции захвата времени в линии:
    start = 0, -- для начального времени
    stop  = 0, -- для конечного  времени
    -- форматы и шаблоны:
    timefmt = "", -- формат времени для вывода
    timecap = "", -- шаблон времени с захватами
    timepat = "", -- шаблон времени без захватов
    linefmt = "", -- формат линии с временами
    linecap = "", -- шаблон линии с захватами времён

    -- функции преобразования:
    parse = false,  -- разбор строки со временем в класс-время
    spell = false,  -- сбор строки со временем из класса-времени
    },
  sub_assa  = {
    start = 2,
    stop  = 4,

    timefmt = "%1d:%02d:%02d.%02d",
    timecap = "(%d+)%:(%d%d)%:(%d%d)%.(%d%d)",      --  ч:нн:сс.зз
    timepat = false,
    linefmt = "%s%s%s%s%s",
    linecap = false,

    parse = false,
    spell = false,
    },
  sub_srt   = {
    start = 1,
    stop  = 3,

    timefmt = "%02d:%02d:%02d,%03d",
    timecap = "(%d%d)%:(%d%d)%:(%d%d)%,(%d%d%d)",   -- чч:нн:сс,ззз
    timepat = false,
    linefmt = "%s%s%s",
    linecap = false,

    parse = false,
    spell = false,
  },
} ---
unit.TplKit = TplKit

do
  -- Автоформирование шаблонов времени без захватов.
  for _, v in pairs(TplKit) do
    v.timepat = v.timecap:gsub("[%(%)]", "")
  end

  local s2n = tonumber

  -- Формирование шаблонов линий с захватами времён.
  -- Формирование функций разбора / сбора строки со временем.

    -- ASSA
  local sub = TplKit.sub_assa
  sub.linecap = format("^%s(%s)%s(%s)%s$",
                       "(.-%: %d%,)",
                       sub.timepat, --"(.-)",
                       "(%,)",
                       sub.timepat, --"(.-)",
                       "(%,.*)")
  --sub.linecap = "^(.-%,)(.-)(%,)(.-)(%,.*)$", -- (нч,)(вр1)(,)(вр2)(,кц)

  sub.parse = function (s) --> (time)
    local h, n, s, cz = s:match(sub.timecap)
    return newTime(s2n(h), s2n(n), s2n(s), (s2n(cz) or 0) * 10)
  end
  sub.spell = function (time) --> (string)
    return format(sub.timefmt, time.h, time.n, time.s, time:cz())
  end

    -- SRT
  local sub = TplKit.sub_srt
  sub.linecap = format("^(%s)%s(%s)%s$",
                       sub.timepat, --"(.-)",
                       "( %-%-%> )",
                       sub.timepat, --"(.-)",
                       "(.*)")
  --sub.linecap = "^(.-)( %-%-%> )(.-)(%s.*)$", -- (вр1)( --> )(вр2)( кц)

  sub.parse = function (s) --> (time)
    local h, n, s, z = s:match(sub.timecap)
    return newTime(s2n(h), s2n(n), s2n(s), s2n(z))
  end
  sub.spell = function (time) --> (string)
    return format(sub.timefmt, time.h, time.n, time.s, time.z)
  end

end -- do

--[[
-- Получение информации о шаблонах.
function unit.getKitInfo (tp) --> (table | nil)
  return TplKit[tp]
end ----
--]]

---------------------------------------- parse & store
-- Разбор времени.
function unit.parseTime (s, tp) --> (time | nil)
  return TplKit[tp].parse(s)
end ----

-- Заполнение времени.
function unit.spellTime (time, tp) --> (string)
  return TplKit[tp].spell(time)
end ----

-- Разбор линии.
function unit.parseLine (s, tp) --> (data | nil)
  tp = tp or "sub_assa"

  -- Разбор линии на части.
  local t = { s:match(TplKit[tp].linecap) }
  --logShow(t, tp)
  if t[1] == nil then return end

  t.type = tp

  -- Разбор времён на части.
  local info = TplKit[tp]
  t.start = unit.parseTime(t[info.start], tp)
  t.stop  = unit.parseTime(t[info.stop], tp)

  return t
end ---- parseLine

-- Заполнение линии.
function unit.spellLine (data) --> (string)
  -- Заполнение времён.
  local tp = data.type
  local info = TplKit[tp]
  t[info.start] = unit.spellTime(t.start, tp)
  t[info.stop]  = unit.spellTime(t.stop, tp)

  -- Заполнение линии.
  local s = format(TplKit[tp].linefmt, unpack(t))

  return s
end ---- spellLine

---------------------------------------- make
local context, ctxdata = context, ctxdata
local configType = context.detect.use.configType

-- Получение поддерживаемого типа файла субтитров.
function unit.getFileType () --> (string)
  local ctype = ctxdata.editors.current.type -- current editor file type
  return configType(ctype, TplKit) -- existing config type for ctype
end ----

do
  local EditorGetStr = editor.GetString

-- Получение данных по линии файла (по умолчанию).
local function DefGetLineData (tp, line, shift) --> (data)
  local line = (line or 0) + (shift and 0 or -1)
  local shift = shift or 1
  local data
  repeat
    line = line + shift
    if line < 0 then break end

    local s = EditorGetStr(nil, line, 2)
    if s == nil then break end

    --logShow({ line, shift, s })
    data = unit.parseLine(s, tp)
  until data

  if data then
    data.line = line

    return data
  end
end -- DefGetLineData

-- Функции получения данных по линии:
local GetLineData = {
  sub_assa  = function (line, shift) --> (data)
    return DefGetLineData("sub_assa", line, shift)
  end,

  sub_srt   = function (line, shift) --> (data)
    return DefGetLineData("sub_srt", line, shift)
  end,
} --- GetLineData

-- Получение данных по линии файла.
function unit.getLineData (tp, line, shift) --> (number)
  local Info = editor.GetInfo()
  if not Info then return end

  local data = GetLineData[tp](line or Info.CurLine, shift)

  editor.SetPosition(nil, Info) -- Restore cursor pos!

  return data
end ----

end -- do

-- Получение длины отрезка времени на линии файла.
function unit.getClauseLen (tp) --> (number | nil)
  local data = unit.getLineData(tp)
  if not data then return end

  return data.stop:diff(data.start)
end ----

-- Получение длины паузы перед отрезком времени на линии файла.
function unit.getClauseGap (tp) --> (number | nil)
  local curr = unit.getLineData(tp)
  if not curr then return end

  local prev = unit.getLineData(tp, curr.line, -1)
  if not prev or curr.line == prev.line then
    return curr.start:to_z()
  end

  return curr.start:diff(prev.stop)
end ----

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------