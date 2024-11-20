-- МетроТаб UI - Полный функционал

-- Define colors and transparency
local colors = {
    sidebar_background = Color(50, 50, 50, 200), -- Semi-transparent black for sidebar
    box_background = Color(0, 0, 0, 150),       -- Semi-transparent black for content boxes
    text = Color(255, 255, 255),               -- White text
    tab_normal = Color(66, 66, 66, 200),
    tab_hover = Color(98, 98, 98, 200),
    tab_active = Color(255, 204, 0),           -- Yellow for active tabs
}

local MetroMenu -- Variable to store the menu panel
local canToggleMenu = false -- Prevent TAB from toggling the menu until the initial menu is exited
local stationData = {} -- Table to store station data sent by the server
local serverStats = { players = 0, wagons = 0 } -- Server-wide stats
local playerData = {} -- Table to store player-specific data sent by the server

-- Receive station data from the server
net.Receive("MetroTab_StationData", function()
    stationData = net.ReadTable() -- Update station data
end)

-- Receive server stats from the server
net.Receive("MScoreBoard.ServerStats", function()
    serverStats.players = net.ReadInt(16)
    serverStats.wagons = net.ReadInt(16)
end)

-- Receive player data from the server
net.Receive("MScoreBoard.PlayerData", function()
    playerData = net.ReadTable() -- Update player data
end)

-- Function to close the menu
local function CloseMockupGUI()
    if IsValid(MetroMenu) then
        MetroMenu:Remove()
    end
end

-- Placeholder for empty tabs
local function ShowEmptyTab(content)
    content:Clear()
    local placeholder = vgui.Create("DLabel", content)
    placeholder:SetFont("DermaLarge")
    placeholder:SetTextColor(colors.text)
    placeholder:SetText("Содержимое временно отсутствует")
    placeholder:SizeToContents()
    placeholder:SetPos(content:GetWide() / 2 - placeholder:GetWide() / 2, content:GetTall() / 2 - placeholder:GetTall() / 2)

    -- Add addon name in the bottom-right corner
    local addonName = vgui.Create("DLabel", content)
    addonName:SetFont("DermaDefault")
    addonName:SetTextColor(colors.text)
    addonName:SetText("МетроТаб UI - BETA")
    addonName:SizeToContents()
    addonName:SetPos(content:GetWide() - addonName:GetWide() - 10, content:GetTall() - addonName:GetTall() - 10)
end

-- Main Tab Function
local function ShowMainTab(content)
    content:Clear()

    local greeting = vgui.Create("DLabel", content)
    greeting:SetFont("DermaLarge")
    greeting:SetTextColor(colors.text)
    greeting:SetText("Добро пожаловать, " .. LocalPlayer():Nick())
    greeting:SizeToContents()
    greeting:SetPos(10, 50)

    local statsBox = vgui.Create("DPanel", content)
    statsBox:SetSize(content:GetWide() - 20, 200)
    statsBox:SetPos(10, 100)
    statsBox.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, colors.box_background)
        draw.SimpleText("Игроки онлайн: " .. serverStats.players, "DermaLarge", 10, 30, colors.text)
        draw.SimpleText("Количество вагонов: " .. serverStats.wagons, "DermaLarge", 10, 70, colors.text)
    end

    -- Add addon name in the bottom-right corner
    local addonName = vgui.Create("DLabel", content)
    addonName:SetFont("DermaDefault")
    addonName:SetTextColor(colors.text)
    addonName:SetText("МетроТаб UI - BETA")
    addonName:SizeToContents()
    addonName:SetPos(content:GetWide() - addonName:GetWide() - 10, content:GetTall() - addonName:GetTall() - 10)
end

-- Statistics Tab Function
local function ShowStatisticsTab(content)
    content:Clear()

    local statsBox = vgui.Create("DPanel", content)
    statsBox:SetSize(content:GetWide() - 20, 150)
    statsBox:SetPos(10, 100)
    statsBox.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, colors.box_background)
        draw.SimpleText("Главная Статистика", "DermaLarge", w / 2, h / 2, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Add addon name in the bottom-right corner
    local addonName = vgui.Create("DLabel", content)
    addonName:SetFont("DermaDefault")
    addonName:SetTextColor(colors.text)
    addonName:SetText("МетроТаб UI - BETA")
    addonName:SizeToContents()
    addonName:SetPos(content:GetWide() - addonName:GetWide() - 10, content:GetTall() - addonName:GetTall() - 10)
end

-- Players Tab Function
local function ShowPlayersTab(content)
    content:Clear()

    -- Table Header
    local header = vgui.Create("DPanel", content)
    header:SetSize(content:GetWide() - 20, 30)
    header:SetPos(10, 10)
    header.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(30, 30, 30, 255))
        draw.SimpleText("Ник", "DermaDefaultBold", 20, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Должность", "DermaDefaultBold", 150, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Маршрут", "DermaDefaultBold", 300, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Вагоны", "DermaDefaultBold", 370, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Состав", "DermaDefaultBold", 450, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Станция/переход", "DermaDefaultBold", 600, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Часы", "DermaDefaultBold", 800, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Пинг", "DermaDefaultBold", 850, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local yOffset = 50
    local rowHeight = 40

    for _, data in ipairs(playerData) do
        local playerRow = vgui.Create("DPanel", content)
        playerRow:SetSize(content:GetWide() - 20, rowHeight)
        playerRow:SetPos(10, yOffset)
        playerRow.Paint = function(self, w, h)
            -- Gradient background for row
            local gradient = surface.GetTextureID("gui/gradient")
            surface.SetTexture(gradient)
            surface.SetDrawColor(255, 50, 50, 200)
            surface.DrawTexturedRect(0, 0, w, h)

            -- Correct route number by removing the last digit
            local correctedRoute = tostring(data.routeNumber):sub(1, -2) or "N/A"

            -- Player data columns
            draw.SimpleText(data.nickname, "DermaDefault", 20, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(data.jobTitle, "DermaDefault", 150, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(correctedRoute, "DermaDefault", 300, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(data.wagonCount, "DermaDefault", 370, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(data.trainType or "N/A", "DermaDefault", 450, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(data.station or "N/A", "DermaDefault", 600, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(string.format("%.2f", data.playtime / 3600) .. " ч.", "DermaDefault", 800, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(data.ping or "N/A", "DermaDefault", 850, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        -- Mute button
        local muteButton = vgui.Create("DButton", playerRow)
        muteButton:SetSize(20, 20)
        muteButton:SetPos(playerRow:GetWide() - 30, 10)
        muteButton:SetText("")
        muteButton.Paint = function(self, w, h)
            draw.SimpleText("🔇", "DermaDefaultBold", w / 2, h / 2, colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        muteButton.DoClick = function()
            local ply = player.GetByID(_) -- Replace with player lookup logic
            if ply then
                ply:SetMuted(not ply:IsMuted())
            end
        end

        yOffset = yOffset + rowHeight + 5
    end

    -- Add addon name in the bottom-right corner
    local addonName = vgui.Create("DLabel", content)
    addonName:SetFont("DermaDefault")
    addonName:SetTextColor(colors.text)
    addonName:SetText("МетроТаб UI - BETA")
    addonName:SizeToContents()
    addonName:SetPos(content:GetWide() - addonName:GetWide() - 10, content:GetTall() - addonName:GetTall() - 10)
end

-- Stations Tab Function
local function ShowStationsTab(content)
    content:Clear()

    local yOffset = 100
    local rectangleHeight = 50

    if #stationData == 0 then
        local noStations = vgui.Create("DLabel", content)
        noStations:SetFont("DermaLarge")
        noStations:SetTextColor(colors.text)
        noStations:SetText("Станции не найдены!")
        noStations:SizeToContents()
        noStations:SetPos(content:GetWide() / 2 - noStations:GetWide() / 2, content:GetTall() / 2 - noStations:GetTall() / 2)
    else
        for _, station in ipairs(stationData) do
            local stationBox = vgui.Create("DPanel", content)
            stationBox:SetSize(content:GetWide() - 40, rectangleHeight)
            stationBox:SetPos(20, yOffset)
            stationBox.Paint = function(self, w, h)
                draw.RoundedBox(10, 0, 0, w, h, colors.box_background)
                draw.SimpleText(station.id .. " - " .. station.name, "DermaDefaultBold", 10, h / 2, colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            yOffset = yOffset + rectangleHeight + 10
        end
    end

    -- Add addon name in the bottom-right corner
    local addonName = vgui.Create("DLabel", content)
    addonName:SetFont("DermaDefault")
    addonName:SetTextColor(colors.text)
    addonName:SetText("МетроТаб UI - BETA")
    addonName:SizeToContents()
    addonName:SetPos(content:GetWide() - addonName:GetWide() - 10, content:GetTall() - addonName:GetTall() - 10)
end

-- Sidebar Layout
local function AddSidebarButtons(sidebar, content)
    local activeTab = nil
    local yOffset = 10

    -- Main Tab
    local mainButton = vgui.Create("DButton", sidebar)
    mainButton:SetText("Главная")
    mainButton:SetSize(230, 50)
    mainButton:SetPos(10, yOffset)
    mainButton:SetFont("DermaLarge")
    mainButton:SetTextColor(colors.text)
    mainButton.Paint = function(self, w, h)
        draw.RoundedBox(20, 0, 0, w, h, activeTab == "Главная" and colors.tab_active or colors.tab_normal)
        if self:IsHovered() and activeTab ~= "Главная" then
            surface.SetDrawColor(colors.tab_hover)
            surface.DrawRect(0, 0, w, h)
        end
    end
    mainButton.DoClick = function()
        activeTab = "Главная"
        ShowMainTab(content)
    end

    yOffset = yOffset + 80 -- Space after Main Tab

    -- Grouped Tabs (Statistics, Players, Stations)
    local tabs = {
        { name = "Статистика", func = ShowStatisticsTab },
        { name = "Игроки", func = ShowPlayersTab },
        { name = "Станции", func = ShowStationsTab },
    }

    for _, tab in ipairs(tabs) do
        local button = vgui.Create("DButton", sidebar)
        button:SetText(tab.name)
        button:SetSize(230, 50)
        button:SetPos(10, yOffset)
        button:SetFont("DermaLarge")
        button:SetTextColor(colors.text)
        button.Paint = function(self, w, h)
            draw.RoundedBox(20, 0, 0, w, h, activeTab == tab.name and colors.tab_active or colors.tab_normal)
            if self:IsHovered() and activeTab ~= tab.name then
                surface.SetDrawColor(colors.tab_hover)
                surface.DrawRect(0, 0, w, h)
            end
        end
        button.DoClick = function()
            activeTab = tab.name
            tab.func(content)
        end

        yOffset = yOffset + 70
    end

    yOffset = yOffset + 30 -- Space after grouped tabs

    -- Rules and Discord Tabs
    local extraTabs = {
        { name = "Правила", func = ShowEmptyTab },
        { name = "Дискорд", func = ShowEmptyTab },
    }

    for _, tab in ipairs(extraTabs) do
        local button = vgui.Create("DButton", sidebar)
        button:SetText(tab.name)
        button:SetSize(230, 50)
        button:SetPos(10, yOffset)
        button:SetFont("DermaLarge")
        button:SetTextColor(colors.text)
        button.Paint = function(self, w, h)
            draw.RoundedBox(20, 0, 0, w, h, activeTab == tab.name and colors.tab_active or colors.tab_normal)
            if self:IsHovered() and activeTab ~= tab.name then
                surface.SetDrawColor(colors.tab_hover)
                surface.DrawRect(0, 0, w, h)
            end
        end
        button.DoClick = function()
            activeTab = tab.name
            tab.func(content)
        end

        yOffset = yOffset + 70
    end

    -- Settings and Exit Buttons
    local settingsButton = vgui.Create("DButton", sidebar)
    settingsButton:SetText("Настройки")
    settingsButton:SetSize(230, 50)
    settingsButton:SetPos(10, sidebar:GetTall() - 110)
    settingsButton:SetFont("DermaLarge")
    settingsButton:SetTextColor(colors.text)
    settingsButton.Paint = function(self, w, h)
        draw.RoundedBox(20, 0, 0, w, h, activeTab == "Настройки" and colors.tab_active or colors.tab_normal)
    end
    settingsButton.DoClick = function()
        activeTab = "Настройки"
        ShowEmptyTab(content)
    end

    local exitButton = vgui.Create("DButton", sidebar)
    exitButton:SetText("Выход")
    exitButton:SetSize(230, 50)
    exitButton:SetPos(10, sidebar:GetTall() - 50)
    exitButton:SetFont("DermaLarge")
    exitButton:SetTextColor(colors.text)
    exitButton.Paint = function(self, w, h)
        draw.RoundedBox(20, 0, 0, w, h, Color(150, 50, 50, 200))
        if self:IsHovered() then
            surface.SetDrawColor(Color(200, 50, 50, 200))
            surface.DrawRect(0, 0, w, h)
        end
    end
    exitButton.DoClick = function()
        canToggleMenu = true
        CloseMockupGUI()
    end
end

-- Create the Menu
function CreateMockupGUI()
    if IsValid(MetroMenu) then return end

    MetroMenu = vgui.Create("DFrame")
    MetroMenu:SetSize(ScrW(), ScrH())
    MetroMenu:SetDraggable(false)
    MetroMenu:SetSizable(false)
    MetroMenu:ShowCloseButton(false)
    MetroMenu:MakePopup()
    MetroMenu.Paint = function(self, w, h)
        for x = 0, w do
            local t = x / w
            local r = Lerp(t, 255, 0)
            local g = Lerp(t, 255, 0)
            local b = Lerp(t, 0, 255)
            surface.SetDrawColor(r, g, b, 153)
            surface.DrawRect(x, 0, 1, h)
        end
    end

    local sidebar = vgui.Create("DPanel", MetroMenu)
    sidebar:SetSize(250, MetroMenu:GetTall())
    sidebar:SetPos(0, 0)
    sidebar.Paint = function(self, w, h)
        surface.SetDrawColor(colors.sidebar_background)
        surface.DrawRect(0, 0, w, h)
    end

    local content = vgui.Create("DScrollPanel", MetroMenu)
    content:SetSize(MetroMenu:GetWide() - 250, MetroMenu:GetTall())
    content:SetPos(250, 0)

    AddSidebarButtons(sidebar, content)

    -- Display the Main Tab by default
    ShowMainTab(content)
end

-- Hook to show the menu when the player spawns
hook.Add("InitPostEntity", "OpenMockupGUIMenu", function()
    CreateMockupGUI()
end)

-- TAB Key Behavior
hook.Add("PlayerBindPress", "HoldMockupGUIMenu", function(ply, bind, pressed)
    if bind == "+showscores" then
        if not canToggleMenu then return true end
        if pressed then
            CreateMockupGUI()
        else
            CloseMockupGUI()
        end
        return true
    end
end)
