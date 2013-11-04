--[[ LUM menus: Russian ]]--
--[[ LUM--меню: русский ]]--

--------------------------------------------------------------------------------
local Data = {
  -- basic
  Separator         = "Разделитель",

  MainMenu          = "Меню LUM",

  ----------------------------------------
  -- Bottom
  EscToQuit         = "Для выхода из меню нажмите Esc",

  ----------------------------------------
  -- No menu
  UserMenu          = "Пользовательское меню",
  NoUserMenu            = "Нет пользовательского меню",

  ----------------------------------------
  -- Config
  ConfigMenu        = "Конфигурация",

  ConfigItem        = "&C - Конфигурация",
    ConfigSep           = "Настройка",
    ConfigBasic         = "&B - Основные параметры",
    ConfigFiles         = "&F - Имена файлов и пути",
    ConfigUMenu         = "&U - Пользовательское меню",

  ----------------------------------------
  -- LuaFAR macros
  LuaFarMacros      = "&` - Макросы LuaFAR",
    LuaFarMacros_Load   = "&` - Загрузить макросы",
    LuaFarMacros_Save   = "&S - Сохранить макросы",

  ----------------------------------------
  -- Character kits
  CharacterKits     = "Наборы символов",
  ChsKitItem        = "&H - Наборы символов",
  
  ChsCharacterMap   = "Таблица символов",

  ChsChars          = "Буквы",
    ChsChars_Greeks     = "Греческие буквы",
    ChsChars_Cyrils     = "Буквы кириллицы",
  ChsMaths          = "Математика",
    ChsMathsScripts     = "Основные индексы",
    --ChsMathsIndexes     = "Остальные индексы",
  ChsPunct          = "Пунктуация",
    ChsPunctSymbols     = "Символы",
    ChsPunct_Spaces     = "Пробел и черта",
  ChsTechs          = "Технология",
    ChsTechs_Arrows     = "Стрелки",
  ChsDraws          = "Рисование",
    ChsDraws_Boxing     = "Рамки",

  ----------------------------------------
  -- Addon scripts
  AddonScripts      = "&A - Дополнения",

  AdnCharactersMap  = "&H - Символы",

  AdnCalendars      = "&K - Календари",
    AdnCalendarTerra    = "&C - Календарь",
    AdnCalendarMillo    = "&M - Календарь тысячелетий",
    AdnCalendarHekso    = "&H - 16-ричный календарь",
    AdnCalendarMinimum  = "&I - Проект-минимум календаря",
    AdnCalendarPern     = "&P - Пернский календарь",

  ----------------------------------------
  -- Other scripts
  OtherScripts      = "&O - Разные скрипты",

  OthQuickInfo      = "&I - Общая информация",
    OthQInfoVers        = "&V - Используемые версии",
    OthQInfoGlobal      = "&G - Глобальные данные",
    OthQInfoPackage     = "&P - Содержимое package",

  OthLFcontext      = "&X - Применение LF context",
    OthLFcDetectType    = "&Y - Определение типа",
    OthLFcOpenFiles     = "&F - Список открытых файлов",
    OthLFcSepInfo       = "LF context Data",
    OthLFcBriefInfo     = "&B - Краткая информация",
    OthLFcDetailedInfo  = "&D - Подробная информация",
    OthLFcTypesTable    = "&C - Конфигурация типов",
    OthLFcTypesInfo     = "&I - Информация о типах",
    OthLFcTestDetType   = "&T - Тест определения типов",

  OthHelloWorld     = "&H - Пример Hello, world!",
    OthHelloWorldMsg    = "&M - Показ сообщения",
    OthHelloWorldText   = "&I - Вставка текста",

  ----------------------------------------
  -- Command samples
  CommandSamples    = "&M - Примеры команд",

  CmdShowFarDesc    = "Показать FAR description",
    CmdFarDescExec      = "— по команде ОС",
    CmdFarDescProg      = "— как подпроцесс",
    CmdFarDescLine      = "— из командной строки",

  ----------------------------------------
} --- Data

return Data
--------------------------------------------------------------------------------
