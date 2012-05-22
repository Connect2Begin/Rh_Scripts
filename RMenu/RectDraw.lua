--[[ RectMenu ]]--

----------------------------------------
--[[ description:
  -- RectMenu: Drawing a menu.
  -- RectMenu: ��ᮢ���� ����.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: RectMenu.
--]]
--------------------------------------------------------------------------------
local _G = _G

local luaUt = require "Rh_Scripts.Utils.luaUtils"
local farUt = require "Rh_Scripts.Utils.farUtils"

local type = type
local require = require
local setmetatable = setmetatable

local U = unicode.utf8.char

----------------------------------------
local bit = bit64
local bshr = bit.rshift

----------------------------------------
local far_Text, farVText = far.Text, farUt.VText

----------------------------------------
local context = context

local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'

local Null = tables.Null

local max2, min2 = numbers.max2, numbers.min2
--local divf = numbers.divf

----------------------------------------
local menUt = require "Rh_Scripts.Utils.menUtils"

local checkedChar = menUt.checkedChar

----------------------------------------
--local logMsg = (require "Rh_Scripts.Utils.Logging").Message

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Draw

-- �뢮� ⥪�� � ��࠭�祭��� �� �����.
local function LineText (Rect, Color, Text) --> (number)
  local Len = min2(Text:len(), Rect.w)
  far_Text(Rect.x, Rect.y, Color, Text:sub(1, Len) or "")
  return Len -- ����� �뢥������� ⥪��
end ---- LineText
unit.LineText = LineText

-- �뢮� ⥪�� � ����������� �� �����.
function unit.LineFill (Rect, Color, Text, Options) --> (bool)
  local Len = LineText(Rect, Color, Text)
  if Len >= Rect.w then return false end
  far_Text(Rect.x + Len, Rect.y, Color,
           Options.Filler:sub(1, Rect.w - Len + 1) or "")
  return true -- ����� �뢥������� ⥪��
end ---- LineFill

-- [[
-- ��ᮢ���� ⥪�� �� �㭪� ����.
function unit.DrawClearItemText (Rect, Color, Clear)
  -- TODO: MultiLine. -- TODO No one Line but Rect!!!
  return LineText(Rect, Color, Clear) -- ���⮥ ����
end ---- DrawClearItemText
--]]

local Separ = U(0x2500):rep(255) -- �����-ࠧ����⥫�
--logMsg(Separ, U(0x2500)..": # = "..tostring( Separ:len() ))

-- ��ᮢ���� ⥪�� �㭪�-ࠧ����⥫�.
function unit.DrawSeparItemText (Rect, Color, Text)
  local Width = Rect.w
  local Separ = Separ:sub(1, Width) -- ��ப�-ࠧ����⥫�

  -- TODO: MultiLine with text & line alignment.
  if Text and Text ~= "" then
    local Len = Text:len() -- �������⥫� � ⥪�⮬:
    local SepLen = bshr(Width - Len, 1)
    --local SepLen = divf(Width - Len, 2)
    LineText(Rect, Color, Separ:sub(1, SepLen)..Text..
                          Separ:sub(1, Width - SepLen - Len))
  else
    LineText(Rect, Color, Separ) -- �������⥫� �����
  end
end ---- DrawSeparItemText

---------------------------------------- Parse

-- ������ ⥪�� �� 梥⮢� �ࠣ����� � ���⮬ ��ન஢��.
local function MakeParseText (Item, Color, TextB, TextH, TextE) --> (table)
  local Mark = Item.RectMenu.TextMark or Null -- No change!
  --if #Mark > 0 then logMsg(Mark, "Mark info") end
  local MarkB, MarkE
  if type(Mark[1]) == 'string' then
    if Mark[1] ~= "" then
      MarkB, MarkE = (TextB..TextH..TextE):cfind(Mark[1], Mark[2], Mark[3])
    end
  else
    MarkB, MarkE = Mark[1], Mark[2]
  end
  --if MarkB then logMsg(Mark, "Mark info") end
  MarkB, MarkE = MarkB or 0, MarkE or 0
  if MarkB <= 0 or MarkB > MarkE then
    return { 0,
             { text = TextB, color = Color.normal },
             { text = TextH, color = Color.hlight },
             { text = TextE, color = Color.normal }, }
  end -- if
  local t = { 0,
    { text = "", color = Color.normal },
    { text = "", color = Color.marked },
    { text = "", color = Color.normal },
    { text = TextH, color = Color.hlight },
    { text = "", color = Color.normal },
    { text = "", color = Color.marked },
    { text = "", color = Color.normal },
  } --- t
  local LenB, LenH, LenE = TextB:len(), TextH:len(), TextE:len()
  -- ������ �����ப� ��। &:
  if TextB ~= "" and MarkB <= LenB then
    if MarkB > 1 then
    t[2].text = TextB:sub(1, MarkB-1) end
    Mark = min2(MarkE, LenB)
    t[3].text = TextB:sub(MarkB, Mark)
    if Mark < LenB then
    t[4].text = TextB:sub(Mark+1, -1) end
  else
    t[2].text = TextB
  end -- if
  Mark = LenB + LenH
  -- ������ �����ப� ��᫥ &:
  if TextE ~= "" and MarkE > Mark then
    MarkB = max2(MarkB - Mark, 1)
    if MarkB > 1 then
    t[6].text = TextE:sub(1, MarkB-1) end
    Mark = min2(MarkE - Mark, LenE)
    t[7].text = TextE:sub(MarkB, Mark)
    if Mark < LenE then
    t[8].text = TextE:sub(Mark+1, -1) end
  else
    t[8].text = TextE
  end -- if
  --logMsg(t, 'Parse Item Text')
  return t
end-- function MakeParseText

-- ������ ⥪�� �� �⤥��� ����� �� ᨬ���� ����� ��ப�.
local function LineParseText (Rect, Color, Parse, Item, Options)
  local t = {}
  local k, n = 1, 1
  while k <= #Parse do
    t[n] = Parse[k]
    n = n + 1
  end -- while
  return t
end --function LineParseText

-- ��ᮢ���� ࠧ��࠭���� ⥪�� ��� ����� 梥⮢�� �ࠣ���⮢.
local function DrawParseText (Rect, Item, Parse) --> (table)
  local text, len
  local ARect = { __index = Rect }; setmetatable(ARect, ARect)
  --logMsg({ Rect, Parse }, 'Parse Item Text')
  -- TODO: MultiLine with text & line alignment -- make LineParseText!!!

  local v
  for k = Parse.m, Parse.n do
    v = Parse[k]
    text = v.text

    if v.newline then -- ����� �����:
      ARect.x, ARect.w = nil, nil
      ARect.y = ARect.y + 1
      ARect.h = ARect.h - 1
      if ARect.h < 0 then break end
    end

    if text and text ~= "" then -- �뢮�:
      len = LineText(ARect, v.color, text)
      ARect.x = ARect.x + len
      ARect.w = ARect.w - len
      if ARect.w <= 0 then break end
    end
  end -- for

  return ARect
end --function DrawParseText

---------------------------------------- Draw
local ParseHotText = farUt.ParseHotText

-- ��ᮢ���� ⥪�� ���筮�� �㭪�.
function unit.DrawItemText (Rect, Color, Item, Options)
  --if not Color.marked then logMsg({ Item, Rect, Options }, "No color item") end
  local RM = Options.Props
  --local RM, RI_Props = Options.Props, Item.RectMenu
  -- ������ ⥪�� �� ��� �� ����祩 �㪢�:
  local TextB, TextH, TextE = nil, nil, Item.text
  if Options.isHot then
    TextB, TextH, TextE = ParseHotText(Item.text, '&')
  end
  TextB, TextH = TextB or "", TextH or ""
  local Len = TextB:len() + TextH:len() + TextE:len() -- ����쭠� �����
  --logMsg(TextB..TextH..TextE, Len)
  -- ������ ⥪�� � ���⮬ ��ન஢��:
  local Parse = MakeParseText(Item, Color, TextB, TextH, TextE)
  local Most = RM.CompactText and "" or " "
  -- ��ࠢ������� ���� ���⪨ ����:
  local Clear = Rect.w - Len - Most:len() * 2
  Clear = Options.Filler:sub(1, max2(0, Clear)) or ""
  -- ���� ��砫��� � ������� ᨬ�����:
  Parse.m, Parse.n = 1, #Parse + 1
  TextB = Most
  if Options.checked then
    TextB = checkedChar(Item.checked, RM.CheckedChar, RM.NocheckChar)..TextB
  end
  Parse[1] = { text = TextB, color = Color.normal, }
  Parse[Parse.n] = { text = Clear..Most, color = Color.normal, }

  DrawParseText(Rect, Item, Parse) -- ��ᮢ���� ࠧ��࠭���� ⥪��
end ---- DrawItemText

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
