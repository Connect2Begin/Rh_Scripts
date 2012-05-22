--[[ Action run functions ]]--
--[[ �㭪樨 �믮������ ����⢨� ]]--

--[[ uses:
  LuaFAR.
     group: Utils.
--]]
--------------------------------------------------------------------------------
local _G = _G

----------------------------------------
local far = far
local F = far.Flags

local farAdvControl = far.AdvControl

----------------------------------------
--local logMsg = (require "Rh_Scripts.Utils.Logging").Message

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- run
do
  local popen = io.popen

-- Execute program and return its output.
-- �믮������ �ணࠬ�� � �����饭�� ��� �뢮��.
function unit.runProcess (program) --> (string)
  local h = popen(program)
  if not h then return end
  local out = h:read("*a")
  h:close()
  return out -- console output
end ----

end -- do

do
  local MacroPost = far.MacroPost

-- Run FAR macrosequence.
-- ����� ���ய�᫥����⥫쭮�� FAR.
function unit.runSequence (Sequence, Flags, AKey) --> (bool)
  return MacroPost(Sequence, Flags, AKey)
end ----

end -- do

do
  local execute = os.execute

-- Run command from OS shell.
-- ����� ������� �� �����窨 ��.
function unit.runCommand (Command) --> (ErrorLevel)
  return execute(Command)
end ----

end -- do

do
  local CmdFlags = F.KMFLAGS_DISABLEOUTPUT
  --far.Message(CmdFlags, "CmdFlags")

-- Run command from FAR command line.
-- ����� ������� �� ��������� ��ப� FAR.
function unit.runCmdLine (Command) --> (integer)
  if panel.SetCmdLine(-1, Command) then
    return unit.runSequence("Enter", CmdFlags)
  end
end ----

end -- do

---------------------------------------- lua
-- Split to name and arguments.
-- ��������� �� ��� � ��㬥���.
--[[
  -- @params:
  Name    (string) - ��� � (��������) ��㬥��� � ᪮����.
  DefArgs (string) - ��㬥���, �ᯮ��㥬� �� 㬮�砭��.
  -- @notes: �ਬ�� ���祭�� Name:
  "TableName.FunctionName(Arg1, 'Arg2', { Arg3_1, Arg3_2 })"
--]]
function unit.splitNameArgs (Name, DefArgs) --> (string, string, boolean)
  if type(Name) == 'string' and
     Name:find("(", 1, true) and Name:sub(-1) == ")" then
    return Name:match("^([^%(]+)%((.+)%)$")
    --return Name:match("([^%(]+)"), Name:match("^[^%(]+%((.+)%)$"), false
  end
  return Name, DefArgs, true
end ----

do
  local loadstring = loadstring
  local format = string.format
  local ArgsFmt = "return { %s }" -- ascii string only

-- Getting arguments.
-- ����祭�� ��㬥�⮢.
function unit.getArguments (Args) --> (table | Args)
  if type(Args) ~= 'string' then return Args end

  -- ����㧪� ��ப� ��� ���樨.
  local Args, SError = loadstring(format(ArgsFmt, Args))
  if not Args then return nil, SError end

  Args = Args() -- ����祭�� ⠡����
  --logMsg(Args, "User Args")
  if not Args then return nil, SError end

  return Args
end ----

end -- do

---------------------------------------- actions:
---------------------------------------- -- Text/Macro
-- Execute: label action.
-- �믮������: ����⢨�-��⪠.
function unit.Label () --> (true)
  return true -- Nothing to do
end ----

-- Execute: Far macrosequence.
-- �믮������: ���ய�᫥����⥫쭮��� FAR.
function unit.FarSeq (Value, Flags) --> (true | nil, error)
  -- WARN: Use Result for future run changes.
  local Result = unit.runSequence(Value, Flags)
  if Result == 0 then return nil, "" end
  return true
end ----

-- Execute: insert plain text.
-- �믮������: ��⠢�� ���筮�� ⥪��.
function unit.Plain (Value, Insert, ...) --> (true | nil, error)
  local Result = Insert(Value, ...)
  if Result == nil then return nil, "" end
  return true
end ----

do
  local macUt = require "Rh_Scripts.Utils.macUtils"

-- Execute: macro-template.
-- �믮������: ����-蠡���.
function unit.Macro (Value) --> (true | nil, error)
  local Result, SError = macUt.RunMacro(Value)
  if Result == nil then return nil, SError end
  return true
end ----

end -- do

---------------------------------------- -- Command
-- Execute: program as process.
-- �믮������: �ணࠬ�� ��� �����.
function unit.Program (Value) --> (string | nil, error)
  local Result = unit.runProcess(Value)
  if Result == nil then return nil, "" end
  return Result
end ----

-- Execute: command from OS shell.
-- �믮������: ������� �� �����窨 ��.
function unit.Command (Value, Format) --> (true | nil, error)
  local Result = unit.runCommand(Value)
  if Result ~= 0 then return nil, Format:format(Result) end
  return true
end ----

-- Execute: command from command line.
-- �믮������: ������� �� ��������� ��ப�.
function unit.CmdLine (Value, Error) --> (integer | nil, error)
  local Result = unit.runCmdLine(Value)
  if Result == nil then return nil, Error end
  return Result
end ----

---------------------------------------- -- Lua script
do
  local luaUt = require "Rh_Scripts.Utils.luaUtils"

-- Execute: lua function.
-- �믮������: lua-�㭪��.
function unit.Function (Value, Args, ...) --> (res [, error])
  if type(Value) ~= 'function' then return end
  return luaUt.fcall(Value, Args, ...) -- MAYBE: pfcall
end ----

-- Execute: lua script (chunk/function).
-- �믮������: lua-�ਯ� (�����/�㭪��).
function unit.Script (Chunk, Function, ChunkArgs, Args, ...) --> (res [, error])
  --logMsg({ Function, ChunkArgs, FuncArgs, ... }, Chunk)

  if Chunk == nil then -- �믮������ �㭪樨.
    return unit.Function(Function, Args, ...)
  end

  -- ����㧪� ���樨 �ਯ�.
  local f, SError = loadfile(Chunk)
  if not f then return nil, SError end

  local Env, Result = { __index = _G }; setmetatable(Env, Env)
  --logMsg(Chunk, Function)
  ChunkArgs = ChunkArgs or Function
  --logMsg(ChunkArgs, Chunk)

  -- �믮������ ���樨 �ਯ�.
  Result, SError = setfenv(f, Env)(ChunkArgs, ...)
  --logMsg(ChunkArgs, f)
  if not Function or (Result or SError) then
    return Result, Result == nil and SError
  end

  -- ����祭�� �㭪樨 �ਯ�.
  f, SError = luaUt.ffind(Env, Function)
  --logMsg(Function, f)
  if not f then return nil, SError end

  -- �믮������ �㭪樨 �ਯ�.
  return unit.Function(f, Args, ...)
end ----

end -- do

--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
