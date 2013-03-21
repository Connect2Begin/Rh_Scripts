--[[ Calendar - Pern: English ]]--

--------------------------------------------------------------------------------
local Data = {
  ----------------------------------------
  Name = "Pern",
  ["Type.Pernese"] = "Pernese calendar",

  ----------------------------------------
  WeekDay = {
    n = 3,
    [0] = {
      [0] = "<7>",
      "<1>", "<2>", "<3>",
      "<4>", "<5>", "<6>",
    },
    --[[
    [1] = {
      [0] = "7",
      "1", "2", "3",
      "4", "5", "6",
    },
    --]]
    [2] = {
      [0] = "d7",
      "d1", "d2", "d3",
      "d4", "d5", "d6",
    },
    [3] = {
      [0] = "<7>",
      "<1>", "<2>", "<3>",
      "<4>", "<5>", "<6>",
    },
  }, -- WeekDay

  ----------------------------------------
  YearMonth = {
    n = 3,
    [0] = {
      "⟨01⟩", "⟨02⟩", "⟨03⟩",
      "⟨04⟩", "⟨05⟩", "⟨06⟩",
      "⟨07⟩", "⟨08⟩", "⟨09⟩",
      "⟨10⟩", "⟨11⟩", "⟨12⟩",
    },
    --[[
    [1] = {
      "1", "2", "3",
      "4", "5", "6",
      "7", "8", "9",
      "°", "¹", "²",
      --"@", "#", "§",
    },
    --]]
    [2] = {
      "01", "02", "03",
      "04", "05", "06",
      "07", "08", "09",
      "10", "11", "12",
    },
    [3] = {
      "⟨1⟩", "⟨2⟩", "⟨3⟩",
      "⟨4⟩", "⟨5⟩", "⟨6⟩",
      "⟨7⟩", "⟨8⟩", "⟨9⟩",
      "⟨°⟩", "⟨¹⟩", "⟨²⟩",
      --"⟨@⟩", "⟨#⟩", "⟨§⟩",
    },
  }, -- YearMonth

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
