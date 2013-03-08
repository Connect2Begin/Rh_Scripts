--[[ Calendar ]]--

----------------------------------------
--[[ description:
  -- Menu based simple calendar.
  -- Простой календарь на основе меню.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  LF context,
  Rh Utils.
  -- group: Common.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local type = type
local pairs = pairs
local setmetatable = setmetatable

----------------------------------------
local useprofiler = false
--local useprofiler = true

if useprofiler then
  require "profiler" -- Lua Profiler
  profiler.start("Calendar.log")
end

----------------------------------------
--local win = win
--local win, far = win, far

----------------------------------------
--local context = context
local logShow = context.ShowInfo

--local utils = require 'context.utils.useUtils'
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'
local tables = require 'context.utils.useTables'
local datas = require 'context.utils.useDatas'
local locale = require 'context.utils.useLocale'

local divf = numbers.divf

local Null = tables.Null
local addNewData = tables.extend

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

local datim = require "Rh_Scripts.Utils.DateTime"

----------------------------------------
local keyUt = require "Rh_Scripts.Utils.Keys"

local IsModCtrl, IsModAlt = keyUt.IsModCtrl, keyUt.IsModAlt
local IsModCtrlAlt = keyUt.IsModCtrlAlt

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Main data
--unit.FileName   = "DateTime"
--unit.FilePath   = "scripts\\Rh_Scripts\\Common\\"
unit.ScriptName = "Calendar"
unit.ScriptPath = "scripts\\Rh_Scripts\\Common\\"

local usercall = farUt.usercall
unit.RunMenu = usercall(nil, require, "Rh_Scripts.RectMenu.RectMenu")

---------------------------------------- ---- Custom
unit.DefCustom = {
  name = unit.ScriptName,
  path = unit.ScriptPath,

  label = unit.ScriptName,

  help   = { topic = unit.ScriptName, },
  locale = {
    kind = 'load',
    --file = unit.FileName,
    --path = unit.FilePath,
  }, --
} -- DefCustom

----------------------------------------
unit.DefOptions = {
  BaseDir  = "Rh_Scripts.Common."..unit.ScriptName..".",
} -- DefOptions

--[[
local L, e1, e2 = locale.localize(nil, unit.DefCustom)
if L == nil then
  return locale.showError(e1, e2)
end

logShow(L, "L", "wM")
--]]
---------------------------------------- ---- Config
unit.DefCfgData = { -- Конфигурация по умолчанию:
} -- DefCfgData

---------------------------------------- ---- Types
--unit.DlgTypes = { -- Типы элементов диалога:
--} -- DlgTypes

---------------------------------------- Configure

---------------------------------------- Main class
local TMain = {
  Guid       = win.Uuid("1b26647b-44b0-4ac6-984d-45cba59568d0"),
  ConfigGuid = win.Uuid("1b537bfd-e907-4836-beff-5ac000823a5b"),
}
local MMain = { __index = TMain }

-- Создание объекта основного класса.
local function CreateMain (ArgData)

  local self = {
    ArgData   = addNewData(ArgData, unit.DefCfgData),

    Custom    = false,
    Options   = false,
    History   = false,
    CfgData   = false,
    --DlgTypes  = unit.DlgTypes,
    LocData   = false,
    L         = false,

    -- Текущее состояние:
    DT_Cfg    = false,    -- Конфигурация даты+времени
    Date      = false,    -- Дата
    Time      = false,    -- Время

    World     = false,    -- Мир
    Type      = false,    -- Тип календаря
    wL        = false,    -- Локализация конфигурации

    YearMin   = false,    -- Минимально допустимый год
    YearMax   = false,    -- Максимально допустимый год
    WeekMax   = false,    -- Максимальное число недель в месяце

    Fetes     = false,    -- Даты событий

    --Error     = false,    -- Текст ошибки
    --Menu      = false,    -- CfgData.Menu or {}

    Items     = false,    -- Список пунктов меню
    Props     = false,    -- Свойства меню

    ActItem   = false,    -- Выбранный пункт меню
    ItemPos   = false,    -- Позиция выбранного пункта меню
    --Action    = false,    -- Выбранное действие
    --Effect    = false,    -- Выбранный эффект
  } --- self

  self.ArgData.Custom = self.ArgData.Custom or {} -- MAYBE: addNewData with deep?!
  --logShow(self.ArgData, "ArgData", "wA d2")
  self.Custom = datas.customize(self.ArgData.Custom, unit.DefCustom)
  self.Options = addNewData(self.ArgData.Options, unit.DefOptions)

  self.History = datas.newHistory(self.Custom.history.full)
  self.CfgData = self.History:field(self.Custom.history.field)

  local CfgData = self.CfgData
  --self.Menu = CfgData.Menu or {}
  --self.Menu.CompleteKeys = self.Menu.CompleteKeys or unit.CompleteKeys
  --self.Menu.LocalUseKeys = self.Menu.LocalUseKeys or unit.LocalUseKeys

  setmetatable(self.CfgData, { __index = self.ArgData })
  --logShow(self.CfgData, "CfgData", "w")

  self.DT_cfg = datim.newConfig(CfgData.Config)
  --logShow(self.DT_cfg, "DT_cfg", "wA d2")

  locale.customize(self.Custom)
  --logShow(self.Custom, "Custom")

  return setmetatable(self, MMain)
end -- CreateMain

---------------------------------------- Dialog

---------------------------------------- Main making

---------------------------------------- ---- Init
do
-- Инициализация календаря.
function TMain:InitData ()
  local self = self
  local CfgData = self.CfgData
  --logShow(CfgData, "CfgData")

  local DT_cfg = self.DT_cfg
  --logShow(DT_cfg, "DT_cfg", "w d3")

  local dt = CfgData.dt or os.date("*t")
  self.Date = CfgData.Date and CfgData.Date:copy() or
              datim.newDate(dt.year, dt.month, dt.day, DT_cfg)
  self.Time = CfgData.Time and CfgData.Time:copy() or
              datim.newTime(dt.hour, dt.min, dt.sec, DT_cfg)
  --logShow(self.Date, "Default Date", "w d1")

  self.World    = DT_cfg.World
  self.Type     = DT_cfg.Type
  self.wL       = DT_cfg.LocData

  --self.YearMin = CfgData.YearMin or 1
  self.YearMin  = CfgData.YearMin or -9998
  self.YearMax  = CfgData.YearMax or  9999
  self.WeekMax  = DT_cfg.MonthDays.WeekMax

  return true
end ---- InitData

  local prequire = farUt.prequire

function TMain:InitFetes ()
  local self = self
  local Options = self.Options

  Options.FeteName = self.World

  self.Fetes = prequire(Options.BaseDir..Options.FeteName) or {}
  --logShow(self.Fetes, "Fetes", "w d3")

  return true
end ---- InitFetes

end -- do
---------------------------------------- ---- Prepare
do
-- Localize data.
-- Локализация данных.
function TMain:Localize ()
  local self = self

  self.LocData = locale.getData(self.Custom)
  -- TODO: Нужно выдавать ошибку об отсутствии файла сообщений!!!
  if not self.LocData then return end

  self.L = locale.make(self.Custom, self.LocData)

  return self.L
end ---- Localize

function TMain:MakeLocLen () --> (bool)
  local self = self

  local wL = self.wL
  if not wL then return end

  --logShow(L, self.World, "w d2")

  do -- Названия дней недели
    local WeekDay = wL.WeekDay[0]

    local MaxLen = WeekDay[0]:len()
    for k = 1, #WeekDay do
      local Len = WeekDay[k]:len()
      if MaxLen < Len then MaxLen = Len end
    end

    WeekDay.MaxLen = MaxLen
  end

  do -- Названия месяцев года
    local YearMonth = wL.YearMonth[0]

    local MaxLen = YearMonth[1]:len()
    for k = 2, #YearMonth do
      local Len = YearMonth[k]:len()
      if MaxLen < Len then MaxLen = Len end
    end

    YearMonth.MaxLen = MaxLen
  end

  return true
end ---- MakeLocLen

function TMain:MakeColors ()

  local menUt = require "Rh_Scripts.Utils.Menu"
  local colors = require 'context.utils.useColors'
  local basics = colors.BaseColors
  local make = colors.make

  local Colors = menUt.MenuColors()
  local t = Colors
  -- Обычный день
  local v = Colors.COL_MENUTEXT
  t = menUt.ChangeColors(t,
                         colors.getFG(v),   colors.getBG(v),
                         basics.black,      basics.silver)
  -- Выделенный день
  v = Colors.COL_MENUSELECTEDTEXT
  t.COL_MENUSELECTEDTEXT = make(basics.blue, colors.getBG(v), type(v))
  -- Выходной день
  v = Colors.COL_MENUMARKTEXT
  t.COL_MENUMARKTEXT = make(basics.maroon, colors.getBG(v), type(v))
  v = Colors.COL_MENUSELECTEDMARKTEXT
  t.COL_MENUSELECTEDMARKTEXT = make(basics.maroon, colors.getBG(v), type(v))
  t = menUt.ChangeColors(t,
                         nil, colors.getBG(Colors.COL_MENUSELECTEDTEXT),
                         nil, basics.white)
  self.UsualColors = t

  t = tables.copy(t, false, pairs, true)
  t = menUt.ChangeColors(t,
                         basics.black,      nil,
                         basics.white,      basics.gray)
  self.FixedColors = t

  return true
end ---- MakeColors

function TMain:MakeFetes ()
  --local self = self
  --local Custom = self.Custom

  return true
end ---- MakeFetes

  local max = math.max

function TMain:MakeProps ()
  local self = self

  -- Свойства меню:
  local Props = self.CfgData.Props or {}
  self.Props = Props

  Props.Id = Props.Id or self.Guid
  Props.HelpTopic = self.Custom.help.tlink

  local L = self.LocData
  Props.Title  = L.Calendar

  local wL = self.wL
  local DT_cfg = self.DT_cfg

  Props.Bottom = wL[DT_cfg.Type]
  --logShow(Props.Bottom, DT_cfg.Type, "wM d1")

  self.TextMax = max(DT_cfg.Formats.DateLen,-- Date length
                     DT_cfg.Formats.TimeLen,-- Time length
                     wL.Name:len() + 2,     -- World name
                     wL.WeekDay[0].MaxLen,  -- WeekDay max
                     wL.YearMonth[0].MaxLen -- YearMonth max
                    )

  self.RowCount = 1 + DT_cfg.DayPerWeek + 1
  self.ColCount = 3 + self.WeekMax + 1

  -- Свойства RectMenu:
  local RM_Props = {
    Order = "V",
    Rows = self.RowCount,
    --Cols = self.ColCount,
    Fixed = {
      HeadRows = 1,
      FootRows = 1,
      HeadCols = 3,
      FootCols = 1,
    },

    --MenuEdge = 2,
    MenuAlign = "CM",

    textMax = {
      [2] = self.TextMax,
    }, -- textMax

    Colors = self.UsualColors,
    FixedColors = self.FixedColors,

  } --- RM_Props
  Props.RectMenu = RM_Props

  return true
end ---- MakeProps

local Msgs = {
  NoLocale      = "No localization",
  NoWorldLocale = 'No localization for world "%s"',
} ---

-- Подготовка.
-- Preparing.
function TMain:Prepare ()

  self:InitData()
  self:InitFetes()

  if not self:Localize() then
    self.Error = Msgs.NoLocale
    return
  end
  if not self:MakeLocLen() then
    self.Error = Msgs.NoWorldLocale:format(self.World or "Unknown")
    return
  end

  self:MakeFetes()

  self:MakeColors()

  return self:MakeProps()
end ---- Prepare

end -- do
---------------------------------------- ---- Menu
do
  local spaces = strings.spaces
  -- Центрирование выводимого текста. -- TEMP: До реализации в RectMenu!
  local function CenterText (Text, Max) --> (string)
    local Text = Text or ""
    local Len = Text:len()
    if Len >= Max then return Text end

    local sp = spaces[divf(Max - Len, 2)]

    return sp..Text
  end -- CenterText

-- Заполнение информационной части.
function TMain:FillInfoPart () --> (bool)
  local self = self
  
  local Date = self.Date
  local Time = self.Time
  --local World = self.World
  local DT_cfg = self.DT_cfg

  --local DayPerWeek = DT_cfg.DayPerWeek
  --local WeekMax = self.WeekMax

  local RowCount = self.RowCount
  local ItemNames = {
    World     = RowCount + 1,
    Year      = RowCount + 3,
    Month     = RowCount + 4,
    Date      = RowCount + 6,
    Time      = RowCount + 9,
    WeekDay   = RowCount + 7,

    YearDay   = RowCount * 0 + 7,
    YearWeek  = RowCount * 2 + 7,

    PrevYear  =                3,
    NextYear  = RowCount * 2 + 3,
    PrevMonth =                4,
    NextMonth = RowCount * 2 + 4,

    Separators = {
                     2,                5,                8, -- 1
      RowCount     + 2, RowCount     + 5, RowCount     + 8, -- 2
      RowCount * 2 + 2, RowCount * 2 + 5, RowCount * 2 + 8, -- 3
                     1,                                  9, -- 1*
      RowCount * 2 + 1,                   RowCount * 2 + 9, -- 3*
    }, --

  } -- ItemNames

  local Formats = DT_cfg.Formats
  local L, Null = self.LocData, Null
  --logShow(L, "L", "wM")
  local wL = self.wL
  local WeekDayNames   = (wL or Null).WeekDay or Null
  local YearMonthNames = (wL or Null).YearMonth or Null

  -- TODO: Реализовать свойство в TDate!
  local y = Date.y > 0 and Date.y or Date.y - 1

  local ItemDatas = {
    World     = self.World ~= "Terra" and
                Formats.World:format(wL.Name) or "",
    Year      = Formats.Year:format(y),
    Month     = (YearMonthNames[0] or Null)[Date.m],
    Date      = Formats.Date:format(y, Date.m, Date.d),
    Time      = Time and Formats.Time:format(Time.h, Time.n, Time.s) or "",
    WeekDay   = (WeekDayNames[0] or Null)[Date:getWeekDay()],

    YearDay   = Formats.YearDay:format(Date:getYearDay()),
    YearWeek  = Formats.YearWeek:format(Date:getYearWeek()),

    --[[
    PrevYear  = "<==",
    NextYear  = "==>",
    PrevMonth = "<--",
    NextMonth = "-->",
    --]]
  } --- ItemDatas

  --[[
  local ItemHints = {
    World     = Formats.Type:format(wL[DT_cfg.Type]),
  } --- ItemHints
  --]]

  local t = self.Items

  -- Текущая информация:
  local TextMax = self.TextMax
  for k, v in pairs(ItemDatas) do
    local pos = ItemNames[k]
    if pos then
      if pos < RowCount or pos > RowCount * 2 then
        t[pos].text = v
      else
        t[pos].text = CenterText(v, TextMax)
      end

      --[[
      local hint = ItemHints[k]
      if hint then t[pos].Hint = hint end
      --]]
    end
  end --

  local Separators = ItemNames.Separators
  for k = 1, #Separators do
    local v = Separators[k]
    t[v].separator = true
  end

  return true
end ---- FillInfoPart

-- Заполнение основной части.
function TMain:FillMainPart () --> (bool)
  local self = self

  local Date = self.Date
  local WeekMax = self.WeekMax

  local DT_cfg = Date.config
  local Formats = DT_cfg.Formats
  local DayPerWeek = DT_cfg.DayPerWeek
  
  --local CurrentDay = Date.d
  local Start = Date:copy()
  Start.d = 1
  --logShow(Start, Date.d, "w d2")
  local MonthDays = Start:getMonthDays()
  --logShow(Start, MonthDays, "w d2")
  local StartYearWeek = Start:getYearWeek()

  local YearWeekCount = Start:getYearWeeks()
  local MonthWeekCount = Start:getMonthWeeks()

  local StartWeekDay, StartWeekShift = Start:getWeekDay(), 0
  if StartWeekDay == 0 then
    StartWeekDay = DayPerWeek
  elseif StartWeekDay < divf(DayPerWeek, 2) then
    StartWeekShift = 1
    StartWeekDay = StartWeekDay + DayPerWeek
  end
  --t[RowCount * 3 - 1].text = ("%1d"):format(StartWeekDay) -- DEBUG

  local Prev = Start:copy()
  Prev:shd(-StartWeekDay)
  --logShow({ Prev, Start }, StartWeekDay, "w d2")
  local Next = Start:copy()
  Next:shd(MonthDays)

  local MonthDayFmt = Formats.MonthDay

  -- Дни месяца:
  local t = self.Items
  local d = 0       -- День текущего месяца
  local p = Prev.d  -- День предыдущего месяца
  local q = 0       -- День следующего месяца
  local SelIndex    -- Индекс пункта с текущей датой

  local k = self.FirstDayIndex - 1
  for i = 1, WeekMax do
    -- Номер недели месяца:
    local week = i - StartWeekShift

    k = k + 1
    t[k].text = week > 0 and week <= MonthWeekCount and
                Formats.MonthWeek:format(week) or ""

    -- Дни недели:
    for j = 1, DayPerWeek do
      local State = 0
      if i < 3 then
        if (i - 1) * DayPerWeek + j < StartWeekDay then
          if p > 0 then p = p + 1 end
          State = -1
        end
      elseif d >= MonthDays then
        p = false
        q = q + 1
        State = 1
      end

      local Text = ""
      if State == 0 then
        d = d + 1
        Text = MonthDayFmt:format(d)

        if not SelIndex and d == Date.d then
          SelIndex = k + 1
        end

      else
        local day = p and p <= 0 and 0 or p or q
        Text = day > 0 and MonthDayFmt:format(day) or ""
      end

      k = k + 1
      local u = t[k]

      u.text = Text
      u.grayed = (State ~= 0)
      u.RectMenu = {
        TextMark = DT_cfg.RestWeekDays[j % DayPerWeek],
      } --
      u.Data = {
        r = j,
        c = i,
        State = State,
        [-1] = Prev,
        [ 0] = Date,
        [ 1] = Next,
        Start = Start,
        d = (State == 0 and d or
             p and p <= 0 and 0 or p or q),
      } --
    end

    -- Номер недели года:
    week = StartYearWeek + i - 1 - StartWeekShift

    k = k + 1
    t[k].text = week > 0 and week <= YearWeekCount and
                Formats.YearWeek:format(week) or ""
  end -- for

  self.Props.SelectIndex = SelIndex

  return true
end ---- FillMainPart

-- Заполнение пояснительной части.
function TMain:FillNotePart () --> (bool)
  local self = self

  local DT_cfg = self.Date.config
  local Formats = DT_cfg.Formats
  local DayPerWeek = DT_cfg.DayPerWeek

  local L, Null = self.LocData, Null
  --logShow(L, "L", "wM")
  local wL = self.wL
  local WeekDayNames = (wL or Null).WeekDay or Null
  local WeekDayShort = WeekDayNames[2] or WeekDayNames[3] or Null

  local WeekDayFmt = Formats.WeekDay

  -- Дни недели:
  local t = self.Items
  local k = self.FirstWeekIndex
  t[k].separator = true
  for w = 1, DayPerWeek do
    k = k + 1
    local u = t[k]

    u.text = WeekDayShort[w % DayPerWeek] or WeekDayFmt:format(w)
    u.RectMenu = {
      TextMark = DT_cfg.RestWeekDays[w % DayPerWeek],
    } --
  end
  k = k + 1
  t[k].separator = true

  return true
end ---- FillNotePart

-- Формирование меню.
function TMain:MakeMenu () --> (table)
  local self = self

  -- TODO: Отвязать от привязки к DayPerWeek.
  -- 1. Прописать минимум 7 + 2 строки.
  -- 2. При DayPerWeek > 7 учесть в выводе информации.
  -- 3. При DayPerWeek < 7 фиксировать лишние строки.
  local RowCount = self.RowCount
  -- Запоминание позиций для заполнения:
  self.FirstDayIndex  = RowCount * 3 + 1
  self.FirstWeekIndex = RowCount * (3 + self.WeekMax) + 1

  local t = {}
  self.Items = t

  -- Формирование пунктов:
  for _ = 1, 3 + self.WeekMax + 1 do
    for _ = 1, RowCount do
      t[#t+1] = {
        text = "",
        Label = true,
      } --
    end
  end --

  self:FillInfoPart() -- Информация
  self:FillMainPart() -- Календарь
  self:FillNotePart() -- Пояснение

  return true
end -- MakeMenu

-- Формирование календаря.
function TMain:MakeCalendar () --> (table)

  self.Items = false -- Сброс меню (!)

  return self:MakeMenu()
end -- MakeCalendar

end -- do
---------------------------------------- ---- Utils
-- Limit date.
-- Ограничение даты.
function TMain:LimitDate (Date)
  if Date.y < self.YearMin then
    Date.y = self.YearMin
    Date.m = 1
    Date.d = 1
  
  elseif Date.y > self.YearMax then
    Date.y = self.YearMax
    Date.m = Date:getYearMonths()
    Date.d = Date:getMonthDays()
  end

  return Date
end ---- LimitDate
---------------------------------------- ---- Input
do
  local tonumber = tonumber
  local InputFmtY   = "^(%d+)"
  local InputFmtYM  = "^(%d+)%-(%d+)"
  local InputFmtYMD = "^(%d+)%-(%d+)%-(%d+)"

function TMain:ParseInput ()
  local self = self
  local Date = self.Date:copy()

  local Input = self.Input or ""
  local _, Count = Input:gsub("-", "")

  if Count == 0 then
    local y = Input:match(InputFmtY)
    y = tonumber(y) or 1
    Date.y, Date.m, Date.d = y, 1, 1
  elseif Count == 1 then
    local y, m = Input:match(InputFmtYM)
    y, m = tonumber(y) or 1, tonumber(m) or 1
    Date.y, Date.m, Date.d = y, m, 1
  else
    local y, m, d = Input:match(InputFmtYMD)
    y, m, d = tonumber(y) or 1, tonumber(m) or 1, tonumber(d) or 1
    --logShow({ Count, y, m, d }, Input)
    Date.y, Date.m, Date.d = y, m, d
  end

  return Date:fixMonth():fixDay()
end ---- ParseInput

function TMain:StartInput (Date)
  local self = self
  local L = self.LocData

  self.Input = ""
  self.Props.Bottom = L.Date
  self.IsInput = true
end ---- StartInput

function TMain:StopInput (Date)
  local self = self

  self.IsInput = false
  self.Props.Bottom = ""
  self.Date = self:ParseInput() or Date
end ---- StopInput

function TMain:EditInput (SKey)
  local self = self

  local Input = self.Input
  if SKey == "BS" then
    if Input ~= "" then Input = Input:sub(1, -2) end
  else
    if SKey == "Subtract" then SKey = "-" end

    Input = Input..SKey
  end

  self.Input = Input
  self.Props.Bottom = Input
end ---- EditInput

end -- do
---------------------------------------- ---- Events
do
  local CloseFlag  = { isClose = true }
  local CancelFlag = { isCancel = true }
  local CompleteFlags = { isRedraw = false, isRedrawAll = true }

  local DateActions = {
    AltLeft     = "dec_m",
    AltRight    = "inc_m",
    AltUp       = "dec_y",
    AltDown     = "inc_y",
  } -- DateActions

  local InputActions = {
    ["1"] = true,
    ["2"] = true,
    ["3"] = true,
    ["4"] = true,
    ["5"] = true,
    ["6"] = true,
    ["7"] = true,
    ["8"] = true,
    ["9"] = true,
    ["0"] = true,
    ["-"] = true,
    ["BS"] = true,
    ["Subtract"] = true,
  } --- InputActions

function TMain:AssignEvents () --> (bool | nil)
  local self = self

  local function MakeUpdate () -- Обновление!
    farUt.RedrawAll()
    self:MakeCalendar()
    --logShow(self.Items, "MakeUpdate")
    if not self.Items then return nil, CloseFlag end
    --logShow(ItemPos, hex(FKey))
    return { self.Props, self.Items, self.Keys }, CompleteFlags
  end -- MakeUpdate

  -- Обработчик нажатия клавиш.
  local function KeyPress (VirKey, ItemPos)
    local SKey = VirKey.Name --or InputRecordToName(VirKey)
    if SKey == "Esc" then return nil, CancelFlag end
    --logShow(SKey, "SKey")

    --local DT_cfg = self.DT_cfg
    local Data = self.Items[ItemPos].Data
    if not Data then return end

    local Date = Data[Data.State]
    if Data.d <= 0 then return end
    Date.d = Data.d

    local isUpdate = true
    local Action = DateActions[SKey]
    if Action then
      Date[Action](Date)

    elseif SKey == "Divide" then
      if self.IsInput then
        self:StopInput(Date)
        return MakeUpdate()
      else
        self:StartInput(Date)
      end

    elseif self.IsInput and InputActions[SKey] then
      self:EditInput(SKey)

    else
      isUpdate = false
    end

    self.Time = false

    if isUpdate then
      --self.Date = Date
      self.Date = self:LimitDate(Date)
      return MakeUpdate()
    end

    return
  end -- KeyPress

  -- Обработчик нажатия клавиш навигации.
  local function NavKeyPress (AKey, VMod, ItemPos)
    local AKey, VMod = AKey, VMod

    local DT_cfg = self.DT_cfg
    local Data = self.Items[ItemPos].Data
    if not Data then return end

    local State = Data.State
    local Date = Data[State]
    if Data.d <= 0 then return end
    Date.d = Data.d
    --logShow({ AKey, VMod, Data }, ItemPos, "w d2")

    local isUpdate = true
    if VMod == 0 then
      --logShow({ AKey, VMod, Date }, ItemPos, "w d2")
      if AKey == "Clear" or AKey == "Multiply" then
        self:InitData()
        return MakeUpdate()
      elseif AKey == "Left"  and Data.c == 1 then
        if State == 0 then Date:shd(-DT_cfg.DayPerWeek) end
      elseif AKey == "Right" and Data.c == self.WeekMax then
        if State == 0 then Date:shd(DT_cfg.DayPerWeek) end
      elseif AKey == "Up"    and Data.r == 1 then
         Date:dec_d()
      elseif AKey == "Down"  and Data.r == DT_cfg.DayPerWeek then
        --logShow({ Date, Date:inc_d() }, AKey)
         --logShow(Date:inc_d(), AKey)
         Date:inc_d()
      else
        isUpdate = false
      end

    elseif IsModCtrl(VMod) then -- CTRL
      if AKey == "Clear" or AKey == "Multiply" then
        self:InitData()
        return MakeUpdate()
      elseif AKey == "PgUp" then
        Date.y = (divf(Date.y, 10) - 1) * 10 + 1
        Date.m = 1
        Date.d = 1
      elseif AKey == "PgDn" then
        Date.y = (divf(Date.y, 10) + 1) * 10
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      elseif AKey == "Home" then
        Date.y = (divf(Date.y, 100) - 1) * 100 + 1
        Date.m = 1
        Date.d = 1
      elseif AKey == "End" then
        Date.y = (divf(Date.y, 100) + 1) * 100
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      else
        isUpdate = false
      end

    elseif IsModAlt(VMod) then -- ALT
      if AKey == "Clear" or AKey == "Multiply" then
        self:InitData()
        return MakeUpdate()
      elseif AKey == "PgUp" then
        Date.d = 1
      elseif AKey == "PgDn" then
        Date.d = Date:getMonthDays()
      elseif AKey == "Home" then
        if Date.m == 1 and Date.d == 1 then
          Date.y = Date.y - 1
        end
        Date.m = 1
        Date.d = 1
      elseif AKey == "End" then
        if Date.m == Date:getYearMonths() and
           Date.d == Date:getMonthDays() then
          Date.y = Date.y + 1
        end
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      else
        isUpdate = false
      end

    elseif IsModCtrlAlt(VMod) then -- ALT+CTRL
      if AKey == "Clear" or AKey == "Multiply" then
        if Date.y == 1 and Date.m == 1 and Date.d == 1 then
          Date.y = 1
          Date.m = Date:getYearMonths()
          Date.d = Date:getMonthDays()
        else
          Date.y = 1
          Date.m = 1
          Date.d = 1
        end
      elseif AKey == "PgUp" then
        Date.y = (divf(Date.y, 1000) - 1) * 1000 + 1
        Date.m = 1
        Date.d = 1
      elseif AKey == "PgDn" then
        Date.y = (divf(Date.y, 1000) + 1) * 1000
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      elseif AKey == "Home" then
        Date.y = -9998
        Date.m = 1
        Date.d = 1
      elseif AKey == "End" then
        Date.y = 9999
        Date.m = Date:getYearMonths()
        Date.d = Date:getMonthDays()
      else
        isUpdate = false
      end

    else
      isUpdate = false
    end

    self.Time = false

    if isUpdate then
      self.Date = self:LimitDate(Date)
      return MakeUpdate()
    end

    return
  end -- NavKeyPress

  -- Обработчик выделения пункта.
  local function SelectItem (Kind, ItemPos)
    local Data = self.Items[ItemPos].Data
    --logShow(Data, ItemPos, "w d2")
    if not Data then return end

    self.Date = Data[Data.State]
    if Data.d <= 0 then return end
    self.Date.d = Data.d

    return self:FillInfoPart()
  end -- SelectItem

  -- Обработчик выбора пункта.
  local function ChooseItem (Kind, ItemPos)
    local Data = self.Items[ItemPos].Data
    if not Data then return end

    if self.IsInput and Kind == "Enter" then
      local Date = Data[Data.State]
      self:StopInput(Date)

      return MakeUpdate()
    end

    return nil, CloseFlag
  end -- ChooseItem

  -- Назначение обработчиков:
  local RM_Props = self.Props.RectMenu
  RM_Props.OnKeyPress = KeyPress
  RM_Props.OnNavKeyPress = NavKeyPress
  RM_Props.OnSelectItem = SelectItem
  RM_Props.OnChooseItem = ChooseItem
end -- AssignEvents

end --

---------------------------------------- ---- Show
-- Показ меню заданного вида.
function TMain:ShowMenu () --> (item, pos)
  return usercall(nil, unit.RunMenu, self.Props, self.Items, self.Keys)
end ---- ShowMenu

-- Вывод календаря.
function TMain:Show () --> (bool | nil)

  --local Cfg = self.CfgData

  self:MakeCalendar()
  if self.Error then return nil, self.Error end

  if useprofiler then profiler.stop() end

  self.ActItem, self.ItemPos = self:ShowMenu()

  return true
end -- Show

---------------------------------------- ---- Run
function TMain:Run () --> (bool | nil)

  self:AssignEvents()

  return self:Show()
end -- Run

---------------------------------------- main

function unit.Execute (Data) --> (bool | nil)

  --logShow(Data, "Data", "w d2")

  local _Main = CreateMain(Data)
  if not _Main then return end

  --logShow(Data, "Data", "w d2")
  --logShow(_Main, "Config", "w _d2")
  --logShow(_Main.CfgData, "CfgData", "w d2")
  --if not _Main.CfgData.Enabled then return end

  _Main:Prepare()
  if _Main.Error then return nil, _Main.Error end

  return _Main:Run()
end ---- Execute

--------------------------------------------------------------------------------
return unit
--return unit.Execute()
--------------------------------------------------------------------------------
