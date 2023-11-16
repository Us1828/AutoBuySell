__name__ = 'AutoBuySell'
__version__ = '1.0'
__author__ = 'Kline'

require 'lib.moonloader'
local sampev = require('lib.samp.events')
local imgui = require('imgui')
local key = require('vkeys')
local encoding = require('encoding')
local inicfg = require('inicfg')

local IniFilename = 'AutoBuySell\\AbsSettings'
local ini = inicfg.load({
  main = {
    delaysell = '100',
    delaybuy = '100',
    button = key.VK_Z,
    command = 'abs',
    autobuy = false,
    autosell = false,
  }
}, IniFilename)
inicfg.save(ini, IniFilename)

local json_file_choicebuyarray = getWorkingDirectory()..'\\config\\AutoBuySell\\choicebuy.json'
local json_file_mybuyarray = getWorkingDirectory()..'\\config\\AutoBuySell\\mybuy.json'
local json_file_choicesellarray = getWorkingDirectory()..'\\config\\AutoBuySell\\choicesell.json'
local json_file_mysellarray = getWorkingDirectory()..'\\config\\AutoBuySell\\mysell.json'
local result = createDirectory(getWorkingDirectory()..'\\config\\AutoBuySell')

function jsonSave(jsonFilePath, t)
  file = io.open(jsonFilePath, "w")
  file:write(encodeJson(t))
  file:flush()
  file:close()
end

function jsonRead(jsonFilePath)
  local file = io.open(jsonFilePath, "r+")
  local jsonInString = file:read("*a")
  file:close()
  local jsonTable = decodeJson(jsonInString)
  return jsonTable
end

local russian_characters = {
  [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
local bufferSearch = {imgui.ImBuffer(128), imgui.ImBuffer(128), imgui.ImBuffer(128), imgui.ImBuffer(128)}
local choiceBuyArray = {}
local myBuyArray = {}
local choiceSellArray = {}
local mySellArray = {}
local menu = 2
local mode = 0
local imyBuyArray = 1
local num = 0
local pagesell = 0
local tab = 1
local tab1 = 0
local tab2 = 0

encoding.default = 'CP1251'
u8 = encoding.UTF8

local window = imgui.ImBool(false)
function imgui.OnDrawFrame()
  if window.v then
    local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw / 1.6, sh / 1.5), imgui.Cond.FirstUseEver)
    imgui.Begin(u8(__name__..' by '..__author__), window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)

    imgui.BeginGroup()
      imgui.BeginChild('question', imgui.ImVec2(sw / 16, sh / 1.62), true)
        if imgui.ButtonActivated(tab == 1, u8('Скуп'), imgui.ImVec2(sw / 21.2, sh / 15)) then menu = 2 tab = 1 end
        if imgui.ButtonActivated(tab == 2, u8('Продажа'), imgui.ImVec2(sw / 21.2, sh / 15)) then menu = 3 tab = 2 end
        if imgui.ButtonActivated(tab == 3, u8('Настройки'), imgui.ImVec2(sw / 21.2, sh / 15)) then menu = 4 tab = 3 end
        imgui.Separator()
        if imgui.Button(u8('Выход'), imgui.ImVec2(sw / 21.2, sh / 15)) then window.v = not window.v end
      imgui.EndChild()
    imgui.EndGroup()

    imgui.SameLine()

    if menu ~= 4 then
      imgui.BeginGroup()
        imgui.BeginChild('choiceMain', imgui.ImVec2(sw / 3.73, sh / 1.62), true)

          if menu == 2 then
            imgui.BeginGroup()
              imgui.BeginChild('choiceBuyMain', imgui.ImVec2(sw / 3.96, sh / 12), true)

                if imgui.Button(u8('Обновить список товаров'), imgui.ImVec2(sw / 4.23, sh / 40)) then
                  sms('Для того, чтобы начать обновлять список товаров на скуп - нажмите alt у лавки и ждите')
                  mode = 1
                end
                if imgui.Button(u8('Обновить средние цены'), imgui.ImVec2(sw / 4.23, sh / 40)) then

                end
              imgui.EndChild()
              imgui.BeginChild('choiceBuy', imgui.ImVec2(sw / 3.96, sh / 2), true)
                local choiceBuy = imgui.InputTextWithHint("## buffer", u8"Название", bufferSearch[1])
                imgui.Text(u8('В списке предметов: %s'):format(#choiceBuyArray))
                imgui.Separator()
                if bufferSearch[1].v == "" then
                  for i, f in ipairs(choiceBuyArray) do
                    funcchoicebuy(i, f, sw, sh)
                  end
                else
                  for i, f in ipairs(choiceBuyArray) do
                    local pat1 = string.rlower(f)
                    local pat2 = string.rlower(u8:decode(bufferSearch[1].v))
                    if pat1:find(pat2, 0, true) then
                      funcchoicebuy(i, f, sw, sh)
                    end
                  end
                end
              imgui.EndChild()
            imgui.EndGroup()
          end

          if menu == 3 then
            imgui.BeginGroup()
              imgui.BeginChild('choiceSellMain', imgui.ImVec2(sw / 3.96, sh / 12), true)
                if imgui.Button(u8('Обновить список товаров'), imgui.ImVec2(sw / 4.23, sh / 40)) then
                  sms('Для того, чтобы начать обновлять список товаров на продажу - нажмите alt у лавки и ждите')
                  mode = 6
                end
                if imgui.Button(u8('Обновить средние цены'), imgui.ImVec2(sw / 4.23, sh / 40)) then
                  
                end
              imgui.EndChild()
              imgui.BeginChild('choiceSell', imgui.ImVec2(sw / 3.96, sh / 2), true)
                local choiceSell = imgui.InputTextWithHint("## buffer", u8"Название", bufferSearch[2])
                imgui.Text(u8('В списке предметов: %s'):format(#choiceSellArray))
                imgui.Separator()
                if bufferSearch[2].v == "" then
                  for i,data in pairs(choiceSellArray) do
                    funcchoicesell(i, data, sw, sh)
                  end
                else
                  for i, data in ipairs(choiceSellArray) do
                    local pat5 = string.rlower(data[1])
                    local pat6 = string.rlower(u8:decode(bufferSearch[2].v))
                    if pat5:find(pat6, 0, true) then
                      funcchoicesell(i, data, sw, sh)
                    end
                  end
                end
              imgui.EndChild()
            imgui.EndGroup()

          end

        imgui.EndChild()

        imgui.SameLine()

        imgui.BeginChild('myMain', imgui.ImVec2(sw / 3.73, sh / 1.62), true)

          if menu == 2 then
            imgui.BeginGroup()
              imgui.BeginChild('myBuyMain', imgui.ImVec2(sw / 3.96, sh / 12), true)
                if imgui.Button(u8('Основной'), imgui.ImVec2(sw / 4.23, sh / 40)) then
                  
                end
                if imgui.Button(u8('По остатку'), imgui.ImVec2(sw / 13.4, sh / 40)) then
                  
                end
                imgui.SameLine()
                if imgui.Button(u8('Снять'), imgui.ImVec2(sw / 13.4, sh / 40)) then
                  sms('Для того, чтобы начать снимать товар со скупа - нажмите alt у лавки и ждите')
                  mode = 4
                end
                imgui.SameLine()
                if imgui.Button(u8('Выставить'), imgui.ImVec2(sw / 13.4, sh / 40)) then
                  sms('Для того, чтобы начать выставлять товар на скуп - нажмите alt у лавки и ждите')
                  mode = 3
                end
              imgui.EndChild()
              imgui.BeginChild('myBuy', imgui.ImVec2(sw / 3.96, sh / 2), true)
                local myBuy = imgui.InputTextWithHint("## buffer", u8"Название", bufferSearch[3])
                imgui.Text(u8('В списке предметов: %s'):format(#myBuyArray))
                imgui.SameLine()
                calcPriceBuy()
                imgui.Separator()
                if bufferSearch[3].v == "" then
                  for i, data in ipairs(myBuyArray) do
                    funcmybuy(i, data, sw, sh)
                  end
                else
                  for i, data in ipairs(myBuyArray) do
                    local pat3 = string.rlower(data[1])
                    local pat4 = string.rlower(u8:decode(bufferSearch[3].v))  
                    if pat3:find(pat4, 0, true) then
                      funcmybuy(i, data, sw, sh)
                    end
                  end
                end
              imgui.EndChild()
            imgui.EndGroup()
          end

          if menu == 3 then
            imgui.BeginGroup()
              imgui.BeginChild('mySellMain', imgui.ImVec2(sw / 3.96, sh / 12), true)
                if imgui.Button(u8('Основной'), imgui.ImVec2(sw / 4.23, sh / 40)) then
                  
                end
                if imgui.Button(u8('По остатку'), imgui.ImVec2(sw / 13.4, sh / 40)) then
                  
                end
                imgui.SameLine()
                if imgui.Button(u8('Снять'), imgui.ImVec2(sw / 13.4, sh / 40)) then
                  sms('Для того, чтобы начать снимать товар с продажи - нажмите alt у лавки и ждите')
                  mode = 20
                end
                imgui.SameLine()
                if imgui.Button(u8('Выставить'), imgui.ImVec2(sw / 13.4, sh / 40)) then
                  sms('Для того, чтобы начать выставлять товар на продажу - нажмите alt у лавки и ждите')
                  pagesell = 1
                  mode = 8
                end
              imgui.EndChild()
              imgui.BeginChild('mySell', imgui.ImVec2(sw / 3.96, sh / 2), true)
                local mySell = imgui.InputTextWithHint("## buffer", u8"Название", bufferSearch[4])
                imgui.Text(u8('В списке предметов: %s'):format(#mySellArray))
                imgui.SameLine()
                calcPriceSell()
                imgui.Separator()
                if bufferSearch[4].v == "" then
                  for i, data in ipairs(mySellArray) do
                    funcmysell(i, data, sw, sh)
                  end
                else
                  for i, data in ipairs(mySellArray) do
                    local pat7 = string.rlower(data[1])
                    local pat8 = string.rlower(u8:decode(bufferSearch[4].v))
                    if pat7:find(pat8, 0, true) then
                      funcmysell(i, data, sw, sh)
                    end
                  end
                end
              imgui.EndChild()
            imgui.EndGroup()
          end

          imgui.EndChild()
        imgui.EndGroup()
    end

    if menu == 4 then
      imgui.BeginGroup()
        imgui.BeginChild('settings', imgui.ImVec2(sw / 1.845, sh / 1.62), true)
          imgui.Text(u8('Название: %s\nВерсия: %s\nАвтор: %s\n\nКоманда для открытия скрипта: %s'):format(__name__, __version__, u8(__author__), u8('/'..ini.main.command)))
          imgui.Text(u8('moonloader // config // AutoBuySell - путь настроек.\nmybuy.json - скуп предметов (1: название, 2: количество, 3: цена, 4: активировано ли)\nchoicebuy.json - выбор предмета на скуп (1: название)\nmysell.json - продажа предметов (1: название, 2: количество, 3: цена, 4: активировано ли)\nchoicesell.json - выбор предмета для продажу (1: название, количество)\nAbsSettings.ini - настройки (1: название, 2: значение)'))
          imgui.Text(' ')
          settingsmaincmd()
          kdmaincmd()
          autosellbuy()
        imgui.EndChild()
      imgui.EndGroup()
    end

    imgui.End()
  end
end

function main()

  if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(200) end

  sms('Author Kline.' .. ' Активация /' .. ini.main.command)

  if not doesFileExist(json_file_choicebuyarray) then jsonSave(json_file_choicebuyarray, {}) end
  if not doesFileExist(json_file_mybuyarray) then jsonSave(json_file_mybuyarray, {}) end
  if not doesFileExist(json_file_choicesellarray) then jsonSave(json_file_choicesellarray, {}) end
  if not doesFileExist(json_file_mysellarray) then jsonSave(json_file_mysellarray, {}) end

  choiceBuyArray = jsonRead(json_file_choicebuyarray)
  myBuyArray = jsonRead(json_file_mybuyarray)
  choiceSellArray = jsonRead(json_file_choicesellarray)
  mySellArray = jsonRead(json_file_mysellarray)

  sampRegisterChatCommand((ini.main.command), function() window.v = not window.v end)

  themesDark()

  while true do wait(0)
    if wasKeyPressed(ini.main.button) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
      window.v = not window.v
    end
    imgui.Process = window.v
  end

end

function sampev.onServerMessage(color, text)
  lua_thread.create(function ()
    if text:find("Используйте клавишу: 'Действия' для управления товарами!") and text:find('[Подсказка]') and color == -89368321 then
      wait(500)
      sampAddChatMessage(('{32CD32}AutoBuySell - для того, чтобы открыть меню введите команду /%s'):format(ini.main.command), -1)
      wait(500)
      if ini.main.autobuy == true and ini.main.autosell == false then
        mode = 3
        clickalt()
      end
      if ini.main.autosell == true and ini.main.autobuy == false then
        pagesell = 1
        mode = 8
        clickalt()
      end
    end
  end)
end

function sampev.onShowDialog(id, style, title, button1, button2, text)

  local page = {title:match('Страница (%d+)/(%d+)')}

  if mode == 1 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    lua_thread.create(function ()
      choiceBuyArray = {}
      jsonSave(json_file_choicebuyarray,choiceBuyArray)
      wait(ini.main.delaybuy)
      sampSendDialogResponse(id, 1, getLineOnTextDialog(text, 'Добавить товар на покупку'), nil)
      mode = 2
    end)
  end

  if mode == 2 and text:find('Скупаете') and text:find('Следующая страница >>>') and page[1] ~= page[2] then
    lua_thread.create(function ()
      wait(ini.main.delaybuy)
      local size = sampGetListboxItemsCount()-1
      local rightpage = sampGetListboxItemsCount()-1
      for i = 0, size, 1 do
        if sampGetListboxItemText(i) ~= 'Следующая страница >>>' and sampGetListboxItemText(i) ~= '<<< Предыдущая страница' then
          local sampget = sampGetListboxItemText(i)
          local newsampget = sampget:gsub('{......}', '')
          if choicesellarrayfind1(newsampget) == false then
          else
            table.insert(choiceBuyArray,newsampget)
            jsonSave(json_file_choicebuyarray,choiceBuyArray)
          end
        end
      end
      sampSendDialogResponse(id, 1, rightpage, nil)
    end)
  end

  if mode == 2  and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    mode = 1
  end

  if mode == 2 and text:find('Скупаете') and text:find('Следующая страница >>>') and page[1] == page[2] then
    lua_thread.create(function ()
      wait(ini.main.delaybuy)
      local size = sampGetListboxItemsCount()-1
      for i = 0, size, 1 do
        if sampGetListboxItemText(i) ~= 'Следующая страница >>>' and sampGetListboxItemText(i) ~= '<<< Предыдущая страница' then
          local sampget = sampGetListboxItemText(i)
          local newsampget = sampget:gsub('{......}', '')
          if choicesellarrayfind1(newsampget) == false then
          else
            table.insert(choiceBuyArray,newsampget)
            jsonSave(json_file_choicebuyarray,choiceBuyArray)
          end
        end
      end
      mode = 0
      sampSendDialogResponse(id, 0)
      sms('Обновления списка товаров на скуп завершен!')
    end)
  end

  if mode == 3 and #myBuyArray <= 0 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    sms('Список товаров на скуп пустой!')
    mode = 0
  end

  if mode == 3 and #myBuyArray > 0 and text:find('Удалить товар с продажи') and text:find('Прекратить покупку товара') then
    lua_thread.create(function ()
      if imyBuyArray <= #myBuyArray and myBuyArray[imyBuyArray][4] == false then
        imyBuyArray = myBuyArrayCheck()
      end
      if imyBuyArray == nil or imyBuyArray > #myBuyArray then
        mode = 0
        imyBuyArray = 1
        sampCloseCurrentDialogWithButton(0)
        sms('Выставление товаров на скуп завершен!')
      else
        wait(ini.main.delaybuy)
        sampSendDialogResponse(id, 1, getLineOnTextDialog(text, 'Добавить товар на покупку %(поиск по предметам%)'), nil)
      end
    end)
  end

  if mode == 3 and #myBuyArray > 0 and not text:find('Удалить товар с продажи') and not text:find('Прекратить покупку товара') then
    lua_thread.create(function()
      if text:find('Введите наименование товара, который хотите найти и выставить на скупку.') and #myBuyArray > 0 then
        wait(ini.main.delaybuy)
        sampSendDialogResponse(id, 1, nil, myBuyArray[imyBuyArray][1])
      end
      if title:find('Поиск товара') and not text:find('Введите наименование товара, который хотите найти и выставить на скупку.') and #myBuyArray > 0 then
        wait(ini.main.delaybuy)
        local text = text:gsub('{......}', '')
        local text = text:gsub('%d.','')
        sampSendDialogResponse(id, 1, 0, nil)
      end
      if text:find('Введите цену за товар') and #myBuyArray > 0 then
        wait(ini.main.delaybuy)
        sampSendDialogResponse(id, 1, nil, myBuyArray[imyBuyArray][3])
        imyBuyArray = imyBuyArray + 1
      end
      if text:find('Введите количество и цену за один товар')and #myBuyArray > 0 then
        wait(ini.main.delaybuy)
        sampSendDialogResponse(id, 1, nil, myBuyArray[imyBuyArray][2]..','..myBuyArray[imyBuyArray][3])
        imyBuyArray = imyBuyArray + 1
      end
    end)
  end

  if mode == 4 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    lua_thread.create(function ()
      wait(ini.main.delaybuy)
      sampSendDialogResponse(id, 1, getLineOnTextDialog(text, 'Прекратить покупку товара'), nil)
      mode = 5
    end)
  end

  if mode == 5 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    mode = 0
    sms('Прекращение скупа товаров завершен!')
  end

  if mode == 5 and text:find('Скупаете') and text:find('Следующая страница >>>') then
    lua_thread.create(function ()
      local size = sampGetListboxItemsCount()-1
      local rightpage = sampGetListboxItemsCount()-1
      if text:find('{67BE55}.+') then
        wait(ini.main.delaybuy)
        sampSendDialogResponse(id, 1, getLineOnTextDialog(text, '{67BE55}.+')-1, nil)
      else
        wait(ini.main.delaybuy)
        sampSendDialogResponse(id, 1, rightpage, nil)
      end
    end)
  end

  if mode == 6 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    lua_thread.create(function ()
      choiceSellArray = {}
      jsonSave(json_file_choicesellarray,choiceSellArray)
      wait(ini.main.delaysell)
      sampSendDialogResponse(id, 1, getLineOnTextDialog(text, 'Выставить товар на продажу'), nil)
      mode = 7
    end)
  end

  if mode == 7 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    mode = 6
  end

  if mode == 7 and text:find('В продаже') and text:find('Следующая страница >>>') and page[1] ~= page[2] then
    lua_thread.create(function ()
      for line in text:gmatch('[^\n]+') do
        if line:find('.+') and not line:find('В наличии') and not line:find('Предыдущая страница') and not line:find('Следующая страница') then
          if line:find('{777777}') then
            local namebad = line:match('{777777}.+{777777}')
            local nameb = namebad:gsub('{......}','')
            local name = nameb:gsub('%s+$','')
            if line:find('{777777}(%d+) шт%.') then
              local num = line:match('{777777}(%d+)')
              local numgood = num:gsub('{......}','')
              if choicesellarrayfind(name,numgood) == false then
                table.insert(choiceSellArray,{name,numgood})
                jsonSave(json_file_choicesellarray,choiceSellArray)
              end
              funcmysellarraybefore(name, numgood)
            else
              if choicesellarrayfind(name,1) == false then
                local one = 1
                table.insert(choiceSellArray,{name,one})
                jsonSave(json_file_choicesellarray,choiceSellArray)
              end
              funcmysellarraybefore(name, 1)
            end
          end
          if line:find('{FFFFFF}') then
            local namebad = line:match('{FFFFFF}.+{FFFFFF}')
            local nameb = namebad:gsub('{......}','')
            local name = nameb:gsub('%s+$','')
            if line:find('{FFFFFF}(%d+) шт%.') then
              local num = line:match('{FFFFFF}(%d+)')
              local numgood = num:gsub('{......}','')
              if choicesellarrayfind(name,numgood) == false then
                table.insert(choiceSellArray,{name,numgood})
                jsonSave(json_file_choicesellarray,choiceSellArray)
              end
              funcmysellarraybefore(name, numgood)
            else
              if choicesellarrayfind(name,1) == false then
                local one = 1
                table.insert(choiceSellArray,{name,one})
                jsonSave(json_file_choicesellarray,choiceSellArray)
              end
              funcmysellarraybefore(name, 1)
            end
          end
        end
      end
      wait(ini.main.delaysell)
      sampSendDialogResponse(id, 1, getLineOnTextDialog(text, 'Следующая страница')-1, nil)
    end)
  end

  if mode == 7 and text:find('В продаже') and text:find('В наличии') and page[1] == page[2] then
    lua_thread.create(function ()
      for line in text:gmatch('[^\n]+') do
        if line:find('.+') and not line:find('В наличии') and not line:find('Предыдущая страница') and not line:find('Следующая страница') then
          if line:find('{777777}') then
            local namebad = line:match('{777777}.+{777777}')
            local nameb = namebad:gsub('{......}','')
            local name = nameb:gsub('%s+$','')
            if line:find('{777777}(%d+) шт%.') then
              local num = line:match('{777777}(%d+)')
              local numgood = num:gsub('{......}','')
              if choicesellarrayfind(name,numgood) == false then
                table.insert(choiceSellArray,{name,numgood})
                jsonSave(json_file_choicesellarray,choiceSellArray)
              end
              funcmysellarraybefore(name, numgood)
            else
              if choicesellarrayfind(name,1) == false then
                local one = 1
                table.insert(choiceSellArray,{name,one})
                jsonSave(json_file_choicesellarray,choiceSellArray)
              end
              funcmysellarraybefore(name, 1)
            end
          end
          if line:find('{FFFFFF}') then
            local namebad = line:match('{FFFFFF}.+{FFFFFF}')
            local nameb = namebad:gsub('{......}','')
            local name = nameb:gsub('%s+$','')
            if line:find('{FFFFFF}(%d+) шт%.') then
              local num = line:match('{FFFFFF}(%d+)')
              local numgood = num:gsub('{......}','')
              if choicesellarrayfind(name,numgood) == false then
                table.insert(choiceSellArray,{name,numgood})
                jsonSave(json_file_choicesellarray,choiceSellArray)
              end
              funcmysellarraybefore(name, numgood)
            else
              if choicesellarrayfind(name,1) == false then
                local one = 1
                table.insert(choiceSellArray,{name,one})
                jsonSave(json_file_choicesellarray,choiceSellArray)
              end
              funcmysellarraybefore(name, 1)
            end
          end
        end
      end
      wait(ini.main.delaysell)
      mode = 0
      sampSendDialogResponse(id, 0)
      for i, data in ipairs(mySellArray) do
        if funcmysellarraybefore1(data) == false then
          data[2] = 0
        end
      end
      sms('Обновления списка товаров на продажу завершен!')
    end)
  end

  if mode == 8 and #mySellArray <= 0 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    sms('Список товаров на продажу пустой')
    mode = 0
  end

  if mode == 8 and #mySellArray > 0 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    lua_thread.create(function ()
      if pagesell <= #mySellArray and mySellArray[pagesell][4] == false then
        pagesell = mySellArrayCheck()
      end
      if pagesell == nil or pagesell > #mySellArray then
        sms('Выставление товаров на продажу завершен!')
        pagesell = 1
        mode = 0
      else
        wait(ini.main.delaysell)
        sampSendDialogResponse(id, 1, getLineOnTextDialog(text, 'Выставить товар на продажу'), nil)
        mode = 9
      end
    end)
  end

  if mode == 9 and #mySellArray > 0 and text:find('Предыдущая страница') and page[1] ~= page[2] then
    lua_thread.create(function ()
      local massive = {}
      local name = nil
      local dd = 0
      num = 0
      for line in text:gmatch('[^\n]+') do
        table.insert(massive, line)
      end
      for i, line in ipairs(massive) do
        if line:find('.+') and not line:find('В наличии') and not line:find('Предыдущая страница') and not line:find('Следующая страница') and mode == 9 then
          if line:find('{777777}') then
            local namebad = line:match('{777777}.+{777777}')
            local nameb = namebad:gsub('{......}','')
            local namebb = nameb:gsub('%s+$','')
            if namebb == mySellArray[pagesell][1] then
              if line:find('{777777}(%d+) шт%.') then
                local numb = line:match('{777777}(%d+)')
                num = numb:gsub('{......}','')
              else
                num = 1
              end
              name = namebb
              dd = i-2
              mode = 10
            end
          end
        end
      end
      isPagesell = mySellArrayPagesell(text)
      if mode == 10 and name == mySellArray[pagesell][1] then
        wait(ini.main.delaysell)
        sampSendDialogResponse(id, 1, dd, nil)
        mode = 11
      end
      if isPagesell == false then
        wait(ini.main.delaysell)
        sampSendDialogResponse(id, 1, getLineOnTextDialog(text, 'Следующая страница')-1, nil)
      end
    end)
  end

  if mode == 9 and #mySellArray > 0 and text:find('Предыдущая страница') and page[1] == page[2] then
    lua_thread.create(function ()
      local massive = {}
      local name = nil
      local dd = 0
      num = 0
      for line in text:gmatch('[^\n]+') do
        table.insert(massive, line)
      end
      for i, line in ipairs(massive) do
        if line:find('.+') and not line:find('В наличии') and not line:find('Предыдущая страница') and not line:find('Следующая страница') and mode == 9 then
          if line:find('{777777}') then
            local namebad = line:match('{777777}.+{777777}')
            local nameb = namebad:gsub('{......}','')
            local namebb = nameb:gsub('%s+$','')
            if namebb == mySellArray[pagesell][1] then
              if line:find('{777777}(%d+) шт%.') then
                local numb = line:match('{777777}(%d+)')
                num = numb:gsub('{......}','')
              else
                num = 1
              end
              name = namebb
              dd = i-2
              mode = 10
            end
          end
        end
      end
      isPagesell = mySellArrayPagesell(text)
      if mode == 10 and name == mySellArray[pagesell][1] then
        wait(ini.main.delaysell)
        sampSendDialogResponse(id, 1, dd, nil)
        mode = 11
      end
      if isPagesell == false and mode ~= 11 then
        wait(ini.main.delaysell)
        pagesell = pagesell + 1
        sampSendDialogResponse(id, 0 , 0, nil)
        mode = 8
      end
    end)
  end

  if mode == 11 and text:find('Введите количество и цену за один товар') then
    lua_thread.create(function ()
      wait(ini.main.delaysell)
      sampSendDialogResponse(id, 1, nil, num..','..mySellArray[pagesell][3])
      mode = 8
    end)
  end
  if mode == 11 and text:find('Введите цену за товар') then
    lua_thread.create(function ()
      wait(ini.main.delaysell)
      sampSendDialogResponse(id, 1, nil, mySellArray[pagesell][3])
      mode = 8
    end)
  end

  if mode == 20 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    lua_thread.create(function ()
      wait(ini.main.delaysell)
      sampSendDialogResponse(id, 1, getLineOnTextDialog(text, 'Удалить товар с продажи'), nil)
      mode = 21
    end)
  end

  if mode == 21 and text:find('Прекратить покупку товара') and text:find('Удалить товар с продажи') then
    mode = 0
    sms('Прекращение продажи товаров завершен!')
  end

  if mode == 21 and text:find('В продаже') and text:find('Следующая страница >>>') then
    lua_thread.create(function ()
      local size = sampGetListboxItemsCount()-1
      local rightpage = sampGetListboxItemsCount()-1
      if text:find('{67BE55}.+') then
        wait(ini.main.delaysell)
        sampSendDialogResponse(id, 1, getLineOnTextDialog(text, '{67BE55}.+')-1, nil)
      else
        wait(ini.main.delaysell)
        sampSendDialogResponse(id, 1, rightpage, nil)
      end
    end)
  end

end

function choicesellarrayfind(name,numgood)
  for i, data in ipairs(choiceSellArray) do
    if name == data[1] then
      data[2] = data[2] + numgood
      jsonSave(json_file_choicesellarray,choiceSellArray)
      return true
    else
    end
  end
  return false
end

function getLineOnTextDialog(text, line_find, mode)
	local mode = mode or false
	local count_dialog, text = 0, text
	for line in text:gmatch('[^\n]+') do
		count_dialog = count_dialog + 1
		if (mode and string.find(line, line_find, 0, true) or line:find(line_find)) then
			return count_dialog - 1
		end
	end
	return 0
end

function sampGetListboxItemByText(text, plain)
  if not sampIsDialogActive() then return -1 end
      plain = not (plain == false)
  for i = 0, sampGetListboxItemsCount() - 1 do
      if sampGetListboxItemText(i):find(text, 1, plain) then
          return i
      end
  end
  return -1
end

function themesDark()
  imgui.SwitchContext()
  local style = imgui.GetStyle()
  local colors = style.Colors
  local clr = imgui.Col
  local ImVec4 = imgui.ImVec4
  local ImVec2 = imgui.ImVec2
  style.WindowPadding = ImVec2(15, 15)
  style.WindowRounding = 15.0
  style.FramePadding = ImVec2(5, 5)
  style.ItemSpacing = ImVec2(12, 8)
  style.ItemInnerSpacing = ImVec2(8, 6)
  style.IndentSpacing = 25.0
  style.ScrollbarSize = 15.0
  style.ScrollbarRounding = 15.0
  style.GrabMinSize = 15.0
  style.GrabRounding = 7.0
  style.ChildWindowRounding = 8.0
  style.FrameRounding = 6.0
  colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
  colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
  colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
  colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
  colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
  colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
  colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
  colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
  colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
  colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
  colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
  colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
  colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
  colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
  colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
  colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
  colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
  colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
  colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
  colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
  colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
  colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
  colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
  colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
  colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
  colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
  colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
  colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
  colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
  colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
  colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
  colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
  colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
  colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
  colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function imgui.InputTextWithHint(label, hint, buf, flags, callback, user_data)
  local l_pos = {imgui.GetCursorPos(), 0}
  local handle = imgui.InputText(label, buf, flags, callback, user_data)
  l_pos[2] = imgui.GetCursorPos()
  local t = (type(hint) == 'string' and buf.v:len() < 1) and hint or '\0'
  local t_size, l_size = imgui.CalcTextSize(t).x, imgui.CalcTextSize('A').x
  imgui.SetCursorPos(imgui.ImVec2(l_pos[1].x + 8, l_pos[1].y + 2))
  imgui.TextDisabled((imgui.CalcItemWidth() and t_size > imgui.CalcItemWidth()) and t:sub(1, math.floor(imgui.CalcItemWidth() / l_size)) or t)
  imgui.SetCursorPos(l_pos[2])
  return handle
end

function onScriptTerminate(script, quit)
	if script == thisScript() then
		imgui.Process = false
		imgui.ShowCursor = false
		showCursor(false, false)
	end
end

function choiceBuyArray_myBuyArray(k)
  local i = 1
  while i <= #myBuyArray do
    if choiceBuyArray[k] == myBuyArray[i][1] then
      return false
    else
      i = i + 1
    end
  end
end

function choiceSellArray_mySellArray(k)
  local i = 1
  while i <= #mySellArray do
    if choiceSellArray[k][1] == mySellArray[i][1] then
      return false
    else
      i = i + 1
    end
  end
end

function calcPriceBuy()
  local price = 0
  local myMoney = getPlayerMoney(PLAYER_HANDLE)
  for k, v in pairs(myBuyArray) do
    price = price + v[2]*v[3]
  end
  local calcMyMoneyMyBuy = myMoney - price
  local calcMyMoneyMyBuy1 = calcMyMoneyMyBuy * -1
  if calcMyMoneyMyBuy > -1 then
    imgui.Text(u8('%s$ - %s$ = %s$'):format(myMoney,price,calcMyMoneyMyBuy))
  else
    imgui.Text(u8('%s$ нехватает'):format(calcMyMoneyMyBuy1))
  end
end

function calcPriceSell()
  local price = 0
  local myMoney = getPlayerMoney(PLAYER_HANDLE)
  for k, v in pairs(mySellArray) do
    price = price + v[2]*v[3]
  end
  local calcMyMoneyMyBuy = myMoney + price
  local calcMyMoneyMyBuy1 = calcMyMoneyMyBuy * -1
  imgui.Text(u8('%s$ + %s$ = %s$'):format(myMoney,price,calcMyMoneyMyBuy))
end

function intInputMyBuyArray(i,data,n)
  local b = imgui.ImInt(data[n])
  local str
  if n == 2 then
    str = 'шт'
  end
  if n == 3 then
    str = '$'
  end
  if imgui.InputInt(u8('%s##%s'):format(u8(str),i), b) then
    if n == 3 then
      if b.v > 9 then
        data[n] = u8:decode(b.v)
        jsonSave(json_file_mybuyarray,myBuyArray)
      end
    end
    if n == 2 then
      if b.v > 0 then
        data[n] = u8:decode(b.v)
        jsonSave(json_file_mybuyarray,myBuyArray)
      end
    end
  end
end

function intInputMySellArray(i,data,n)
  local b = imgui.ImInt(data[n])
  local str
  if n == 2 then
    str = 'шт'
  end
  if n == 3 then
    str = '$'
  end
  if imgui.InputInt(u8('%s##%s'):format(u8(str),i), b) then
    if b.v > 9 then
      data[n] = u8:decode(b.v)
      jsonSave(json_file_mysellarray,mySellArray)
    end
  end
end

function settingsmaincmd()
  local buffer = imgui.ImBuffer(ini.main.command,128)
  imgui.PushItemWidth(100)
    if imgui.InputText(u8('Команда для открытия скрипта (без слеша / )'), buffer) then
      if u8:decode(buffer.v) ~= ini.main.command and not buffer.v:find(' ') then
        if buffer.v ~= '' then
          sampUnregisterChatCommand(ini.main.command)
          ini.main.command = u8:decode(buffer.v)
          sampRegisterChatCommand(ini.main.command, function() window.v = not window.v end)
          inicfg.save(ini, IniFilename)
        else
          sampUnregisterChatCommand(ini.main.command)
          ini.main.command = u8:decode(buffer.v)
          inicfg.save(ini, IniFilename)
        end
      end
    end
  imgui.PopItemWidth()
end

function sms(arg)
	local arg = tostring(arg):gsub('{mc}', '{FF0000}')
	sampAddChatMessage('[AutoBuySell] {32CD32}' .. tostring(arg), 0xFF0000)
end

function choicesellarrayfind1(k)
  for i, v in ipairs(choiceBuyArray) do
    if v == k then
      return false
    else
      
    end
  end
end

function string.rlower(s)
  s = s:lower()
  local strlen = s:len()
  if strlen == 0 then return s end
  s = s:lower()
  local output = ''
  for i = 1, strlen do
      local ch = s:byte(i)
      if ch >= 192 and ch <= 223 then -- upper russian characters
          output = output .. russian_characters[ch + 32]
      elseif ch == 168 then -- Ё
          output = output .. russian_characters[184]
      else
          output = output .. string.char(ch)
      end
  end
  return output
end
function string.rupper(s)
  s = s:upper()
  local strlen = s:len()
  if strlen == 0 then return s end
  s = s:upper()
  local output = ''
  for i = 1, strlen do
      local ch = s:byte(i)
      if ch >= 224 and ch <= 255 then -- lower russian characters
          output = output .. russian_characters[ch - 32]
      elseif ch == 184 then -- ё
          output = output .. russian_characters[168]
      else
          output = output .. string.char(ch)
      end
  end
  return output
end

function mySellArrayPagesell(text)
  local y = 1
  if text:find('{777777}'..mySellArray[pagesell][1]) then
      return true
  else
    return false
  end
end

function kdmaincmd()
  local bufferbuy = imgui.ImInt(ini.main.delaybuy)
  local buffersell = imgui.ImInt(ini.main.delaysell)
  imgui.PushItemWidth(100)
    if imgui.InputInt(u8('Задержка между окнами при скупе (лучше не трогать)'), bufferbuy, 0, 0) then
      if u8:decode(bufferbuy.v) ~= ini.main.delaybuy and bufferbuy.v > 0 then
        ini.main.delaybuy = u8:decode(bufferbuy.v)
        inicfg.save(ini, IniFilename)
      end
    end
    if imgui.InputInt(u8('Задержка между окнами при продаже (лучше не трогать)'), buffersell, 0, 0) then
      if u8:decode(buffersell.v) ~= ini.main.delaysell and bufferbuy.v > 0 then
        ini.main.delaysell = u8:decode(buffersell.v)
        inicfg.save(ini, IniFilename)
      end
    end
  imgui.PopItemWidth()
end

function imgui.ButtonActivated(activated, ...)
  if activated then
      imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.CheckMark])
      imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.CheckMark])
      imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.CheckMark])

          imgui.Button(...)

      imgui.PopStyleColor()
      imgui.PopStyleColor()
      imgui.PopStyleColor()

  else
      return imgui.Button(...)
  end
end

function myBuyArrayCheck()
  for i = imyBuyArray, #myBuyArray, 1 do
    if myBuyArray[i][4] == false then
      
    else
      return i
    end
  end
  local dd = #myBuyArray + 1
  return dd
end

function mySellArrayCheck()
  for i = pagesell, #mySellArray, 1 do
    if mySellArray[i][4] == false then
      
    else
      return i
    end
  end
  local dd = #mySellArray + 1
  return dd
end

function funcmybuy(i, data, sw, sh)
  local checkboxbuy = imgui.ImBool(true)
  if data[4] == false then
    checkboxbuy = imgui.ImBool(false)
  end
  if imgui.Checkbox(('##checkboxbuy ##%d'):format(i), checkboxbuy) then
    if data[4] == true then
      data[4] = false
    else
      data[4] = true
    end
    jsonSave(json_file_mybuyarray,myBuyArray)
  end
  imgui.SameLine()
  if imgui.ButtonActivated(tab1 == i, u8('##Переместить ##%d'):format(i), imgui.ImVec2(sh / 40, sh / 40)) then
    if tab1 == 0 then
      tab1 = i
    else
      myBuyArray[tab1][1], data[1] = data[1], myBuyArray[tab1][1]
      myBuyArray[tab1][2], data[2] = data[2], myBuyArray[tab1][2]
      myBuyArray[tab1][3], data[3] = data[3], myBuyArray[tab1][3]
      myBuyArray[tab1][4], data[4] = data[4], myBuyArray[tab1][4]
      tab1 = 0
      jsonSave(json_file_mybuyarray,myBuyArray)
    end
  end
  imgui.SameLine()
  if imgui.Button(u8'Сбросить ##%d':format(i), imgui.ImVec2(sw / 30, sh / 40)) then
    tab1 = 0
  end
  imgui.SameLine()
  imgui.Text(u8('%s - %s'):format(i, u8(data[1])))
  imgui.SameLine()
  if imgui.Button(u8('Удалить ##%d'):format(i), imgui.ImVec2(sw / 33 , sh / 40)) and myBuyArray[i] then
    table.remove(myBuyArray, i)
    tab1 = 0
    jsonSave(json_file_mybuyarray,myBuyArray)
  end
  intInputMyBuyArray(i,data,2)
  intInputMyBuyArray(i,data,3)
  imgui.Separator()
end

function funcmysell(i, data, sw, sh)
  local checkboxsell = imgui.ImBool(true)
  if data[4] == false then
    checkboxsell = imgui.ImBool(false)
  end
  if imgui.Checkbox(('##checkboxsell ##%d'):format(i), checkboxsell) then
    if data[4] == true then
      data[4] = false
    else
      data[4] = true
    end
    jsonSave(json_file_mysellarray,mySellArray)
  end
  imgui.SameLine()
  if imgui.ButtonActivated(tab2 == i, u8('##Переместитьd ##%d'):format(i), imgui.ImVec2(sh / 40, sh / 40)) then
    if tab2 == 0 then
      tab2 = i
    else
      mySellArray[tab2][1], data[1] = data[1], mySellArray[tab2][1]
      mySellArray[tab2][2], data[2] = data[2], mySellArray[tab2][2]
      mySellArray[tab2][3], data[3] = data[3], mySellArray[tab2][3]
      mySellArray[tab2][4], data[4] = data[4], mySellArray[tab2][4]
      tab2 = 0
      jsonSave(json_file_mysellarray, mySellArray)
    end
  end
  imgui.SameLine()
  if imgui.Button(u8'Сбросить ##%d':format(i), imgui.ImVec2(sw / 30, sh / 40)) then
    tab2 = 0
  end
  imgui.SameLine()
  imgui.Text(u8('%s - %s'):format(i,u8(data[1])))
  imgui.SameLine()
  if imgui.Button(u8('Удалить ##%d'):format(i), imgui.ImVec2(sw / 33 , sh / 40)) and data[1] then
    table.remove(mySellArray, i)
    tab2 = 0
    jsonSave(json_file_mysellarray,mySellArray)
  end
  imgui.Text(u8('%s шт'):format(data[2]))
  intInputMySellArray(i,data,3)
  imgui.Separator()
end

function funcchoicebuy(i, f, sw, sh)
  if imgui.Button(tostring('%s - %s'):format(i,u8(f)), imgui.ImVec2(sw / 4.3 , sh / 40)) then
    if choiceBuyArray_myBuyArray(i) ~= false then
      table.insert(myBuyArray, {f, 1, 10, true})
      jsonSave(json_file_mybuyarray,myBuyArray)
    end
  end
end

function funcchoicesell(i, data, sw, sh)
  if imgui.Button(u8('%s - %s - %s шт'):format(i,u8(data[1]),data[2]), imgui.ImVec2(sw / 4.3 , sh / 40)) then
    if choiceSellArray_mySellArray(i) ~= false then
      table.insert(mySellArray, {data[1], data[2], 10, true})
      jsonSave(json_file_mysellarray,mySellArray)
    end
  end
end

function funcmysellarraybefore(name, numgood)
  for k, f in ipairs(mySellArray) do
    if name == f[1] then
      f[2] = numgood
    end
  end
  jsonSave(json_file_mysellarray, mySellArray)
end

function funcmysellarraybefore1(data)
  for k, f in ipairs(choiceSellArray) do
    if data[1] == f[1] then
      return true
    end
  end
  return false
end

function autosellbuy()
  local autobuyparam = imgui.ImBool(false)
  if ini.main.autobuy == true then
    autobuyparam = imgui.ImBool(true)
  end
  local autosellparam = imgui.ImBool(false)
  if ini.main.autosell == true then
    autosellparam = imgui.ImBool(true)
  end
  if imgui.Checkbox(u8'Авто выставление товаров на скуп после того, как встали в лавку', autobuyparam) then
    if ini.main.autobuy == false then
      ini.main.autobuy = true
      ini.main.autosell = false
    else
      ini.main.autobuy = false
    end
    inicfg.save(ini, IniFilename)
  end
  imgui.SameLine()
  if imgui.Checkbox(u8'Авто выставление товаров на продажу после того, как встали в лавку', autosellparam) then
    if ini.main.autosell == false then
      ini.main.autosell = true
      ini.main.autobuy = false
    else
      ini.main.autosell = false
    end
    inicfg.save(ini, IniFilename)
  end
end

function clickalt()
  sampCloseCurrentDialogWithButton(0)
  while not sampIsDialogActive() do
    setVirtualKeyDown(18, true)
    wait(500)
    setVirtualKeyDown(18, false)
    wait(500)
  end
end

predmetu = {{"jenek", 100},{"site//jpg", 1000},{"jenek", 10240},{"kosta", 500}}
