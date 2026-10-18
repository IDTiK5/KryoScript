-- TieuvabHub single-file UI
-- Built from the supplied Minimal UI Library.
-- Intended for UI testing in experiences you own or are authorized to test.

--[[
	Minimal UI Library (Luau) - sinh bởi Minimal UI Builder.
	Đặt file này làm ModuleScript, require từ một LocalScript.

	API:
	  Library:CreateWindow(config) -> Window
	  Window:CreateTab(name) -> Tab
	  Tab:CreateSection(config | title) -> Section
	  Section:CreateButton / CreateToggle / CreateSlider / CreateDropdown /
	          CreateTextbox / CreateLabel / CreateParagraph / CreateDivider
	  Window:Minimize / Restore / ToggleMinimize / SetVisible / SelectTab / Destroy

	Chỉ dùng Roblox Instance API chính thức. Không dùng API riêng của executor.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.Version = "1.0.0"

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local DEFAULT_THEME = {
	Background = Color3.fromRGB(30, 31, 34),
	Secondary = Color3.fromRGB(43, 45, 49),
	Text = Color3.fromRGB(230, 232, 235),
	Accent = Color3.fromRGB(91, 163, 240),
	Border = Color3.fromRGB(58, 61, 66),
	CornerRadius = 6,
	FontSize = 14,
	Padding = 8,
	Spacing = 6,
}

local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold
local TITLE_HEIGHT = 36
local TAB_BAR_HEIGHT = 34
local TWEEN_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function safeCall(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[MinimalUI] Callback error: " .. tostring(err))
	end
end

local function tween(instance, goal)
	TweenService:Create(instance, TWEEN_INFO, goal):Play()
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function create(className, props, children)
	local instance = Instance.new(className)
	local parent = nil
	for key, value in pairs(props or {}) do
		if key == "Parent" then
			parent = value
		else
			instance[key] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end
	instance.Parent = parent
	return instance
end

local function addCorner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function addStroke(parent, color)
	return create("UIStroke", {
		Color = color,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function addPadding(parent, amount)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, amount),
		PaddingBottom = UDim.new(0, amount),
		PaddingLeft = UDim.new(0, amount),
		PaddingRight = UDim.new(0, amount),
		Parent = parent,
	})
end

local function contrastColor(color)
	local luminance = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
	if luminance > 0.6 then
		return Color3.fromRGB(20, 20, 20)
	end
	return Color3.fromRGB(255, 255, 255)
end

local function mergeTheme(custom)
	local theme = {}
	for key, value in pairs(DEFAULT_THEME) do
		theme[key] = value
	end
	if type(custom) == "table" then
		for key, value in pairs(custom) do
			local reference = DEFAULT_THEME[key]
			if reference ~= nil and typeof(value) == typeof(reference) then
				theme[key] = value
			end
		end
	end
	return theme
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------

function Library:CreateWindow(config)
	config = config or {}
	local theme = mergeTheme(config.Theme)

	local parent = config.Parent
	if parent == nil then
		local player = Players.LocalPlayer
		assert(player ~= nil, "MinimalUI: hãy chạy trong LocalScript (Players.LocalPlayer = nil)")
		parent = player:WaitForChild("PlayerGui")
	end

	-- Chạy lại script sẽ thay thế giao diện cũ cùng tên thay vì tạo thêm bản sao.
	local guiName = tostring(config.Name or "MinimalUI")
	local existing = parent:FindFirstChild(guiName)
	if existing and existing:IsA("ScreenGui") then
		existing:Destroy()
	end

	local viewport = Vector2.new(1280, 720)
	local camera = Workspace.CurrentCamera
	if camera then
		viewport = camera.ViewportSize
	end
	local requested = config.Size or Vector2.new(560, 400)
	local maxWidth = math.max(240, viewport.X * 0.95)
	local maxHeight = math.max(160, viewport.Y * 0.9)
	local width = math.clamp(requested.X, 240, maxWidth)
	local height = math.clamp(requested.Y, 160, maxHeight)

	local gui = create("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
		Parent = parent,
	})

	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	})
	addCorner(main, theme.CornerRadius)
	addStroke(main, theme.Border)
	create("UISizeConstraint", {
		MinSize = Vector2.new(240, TITLE_HEIGHT),
		MaxSize = Vector2.new(math.max(240, viewport.X), math.max(TITLE_HEIGHT, viewport.Y)),
		Parent = main,
	})

	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),
		BackgroundColor3 = theme.Secondary,
		BorderSizePixel = 0,
		Parent = main,
	})

	create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(theme.Padding + 2, 0),
		Size = UDim2.new(1, -(theme.Padding + 2 + 68), 1, 0),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = tostring(config.Title or "Window"),
		TextColor3 = theme.Text,
		TextSize = theme.FontSize + 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = titleBar,
	})

	local function titleButton(text, offsetFromRight)
		local button = create("TextButton", {
			Size = UDim2.fromOffset(26, 26),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -offsetFromRight, 0.5, 0),
			BackgroundColor3 = theme.Background,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = FONT_BOLD,
			Text = text,
			TextColor3 = theme.Text,
			TextSize = theme.FontSize,
			Parent = titleBar,
		})
		addCorner(button, math.max(theme.CornerRadius - 2, 0))
		return button
	end

	local closeButton = titleButton("X", 6)
	local minimizeButton = nil
	if config.Minimizable ~= false then
		minimizeButton = titleButton("-", 36)
	end

	local body = create("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(0, TITLE_HEIGHT),
		Size = UDim2.new(1, 0, 1, -TITLE_HEIGHT),
		BackgroundTransparency = 1,
		Parent = main,
	})

	local tabBar = create("ScrollingFrame", {
		Name = "TabBar",
		Size = UDim2.new(1, 0, 0, TAB_BAR_HEIGHT),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		Parent = body,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, theme.Spacing),
		Parent = tabBar,
	})
	create("UIPadding", {
		PaddingLeft = UDim.new(0, theme.Padding),
		PaddingRight = UDim.new(0, theme.Padding),
		Parent = tabBar,
	})

	local pages = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(0, TAB_BAR_HEIGHT),
		Size = UDim2.new(1, 0, 1, -TAB_BAR_HEIGHT),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = body,
	})

	local self = setmetatable({
		Gui = gui,
		Main = main,
		Theme = theme,
		Tabs = {},
		SelectedTab = nil,
		_connections = {},
		_activeDrag = nil,
		_minimized = false,
		_destroyed = false,
		_fullSize = UDim2.fromOffset(width, height),
		_body = body,
		_tabBar = tabBar,
		_pages = pages,
	}, Window)

	-- Một cặp kết nối toàn cục duy nhất cho mọi thao tác kéo (cửa sổ, slider).
	self:_connect(UserInputService.InputChanged, function(input)
		local kind = input.UserInputType
		if self._activeDrag and (kind == Enum.UserInputType.MouseMovement or kind == Enum.UserInputType.Touch) then
			self._activeDrag(input)
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		if isPress(input) then
			self._activeDrag = nil
		end
	end)

	if config.Draggable ~= false then
		self:_connect(titleBar.InputBegan, function(input)
			if not isPress(input) then
				return
			end
			local startPosition = main.Position
			local startInput = input.Position
			self._activeDrag = function(moved)
				local delta = moved.Position - startInput
				main.Position = UDim2.new(
					startPosition.X.Scale,
					startPosition.X.Offset + delta.X,
					startPosition.Y.Scale,
					startPosition.Y.Offset + delta.Y
				)
			end
		end)
	end

	if minimizeButton then
		self:_connect(minimizeButton.Activated, function()
			self:ToggleMinimize()
		end)
	end
	self:_connect(closeButton.Activated, function()
		self:Destroy()
	end)
	self:_connect(gui.Destroying, function()
		self:Destroy()
	end)

	return self
end

function Window:_connect(signal, handler)
	local connection = signal:Connect(handler)
	table.insert(self._connections, connection)
	return connection
end

function Window:Minimize()
	if self._minimized or self._destroyed then
		return
	end
	self._minimized = true
	self._body.Visible = false
	tween(self.Main, { Size = UDim2.new(self._fullSize.X.Scale, self._fullSize.X.Offset, 0, TITLE_HEIGHT) })
end

function Window:Restore()
	if not self._minimized or self._destroyed then
		return
	end
	self._minimized = false
	self._body.Visible = true
	tween(self.Main, { Size = self._fullSize })
end

function Window:ToggleMinimize()
	if self._minimized then
		self:Restore()
	else
		self:Minimize()
	end
end

function Window:SetVisible(visible)
	if not self._destroyed then
		self.Gui.Enabled = visible == true
	end
end

function Window:SelectTab(tab)
	if self._destroyed then
		return
	end
	local theme = self.Theme
	for _, other in ipairs(self.Tabs) do
		local selected = other == tab
		other.Page.Visible = selected
		other.Button.BackgroundColor3 = selected and theme.Accent or theme.Secondary
		other.Button.TextColor3 = selected and contrastColor(theme.Accent) or theme.Text
	end
	self.SelectedTab = tab
end

function Window:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	table.clear(self._connections)
	self._activeDrag = nil
	if self.Gui then
		self.Gui:Destroy()
	end
end

---------------------------------------------------------------------------
-- Tab
---------------------------------------------------------------------------

function Window:CreateTab(name)
	local theme = self.Theme
	name = tostring(name or "Tab")

	local button = create("TextButton", {
		Name = "Tab_" .. name,
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = theme.Secondary,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = FONT,
		Text = name,
		TextColor3 = theme.Text,
		TextSize = theme.FontSize,
		LayoutOrder = #self.Tabs + 1,
		Parent = self._tabBar,
	})
	addCorner(button, theme.CornerRadius)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = button,
	})

	local page = create("ScrollingFrame", {
		Name = "Page_" .. name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Border,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self._pages,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, theme.Spacing),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = page,
	})
	addPadding(page, theme.Padding)

	local tab = setmetatable({
		Window = self,
		Name = name,
		Button = button,
		Page = page,
		_order = 0,
	}, Tab)
	table.insert(self.Tabs, tab)

	self:_connect(button.Activated, function()
		self:SelectTab(tab)
	end)
	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end
	return tab
end

---------------------------------------------------------------------------
-- Section
---------------------------------------------------------------------------

function Tab:CreateSection(config)
	if type(config) == "string" then
		config = { Title = config }
	end
	config = config or {}
	local window = self.Window
	local theme = window.Theme

	self._order = self._order + 1
	local frame = create("Frame", {
		Name = "Section",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Secondary,
		BorderSizePixel = 0,
		LayoutOrder = self._order,
		Parent = self.Page,
	})
	addCorner(frame, theme.CornerRadius)
	addStroke(frame, theme.Border)
	create("UIListLayout", {
		Padding = UDim.new(0, theme.Spacing),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = frame,
	})
	addPadding(frame, theme.Padding)

	create("TextLabel", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, theme.FontSize + 6),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = tostring(config.Title or "Section"),
		TextColor3 = theme.Text,
		TextSize = theme.FontSize + 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 0,
		Parent = frame,
	})

	if type(config.Description) == "string" and config.Description ~= "" then
		create("TextLabel", {
			Name = "Description",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = FONT,
			Text = config.Description,
			TextColor3 = theme.Text,
			TextTransparency = 0.35,
			TextSize = theme.FontSize - 1,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = 1,
			Parent = frame,
		})
	end

	return setmetatable({
		Tab = self,
		Window = window,
		Frame = frame,
		_order = 1,
	}, Section)
end

function Section:_nextOrder()
	self._order = self._order + 1
	return self._order
end

local function newRow(section, name, height)
	local theme = section.Window.Theme
	local row = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		LayoutOrder = section:_nextOrder(),
		Parent = section.Frame,
	})
	addCorner(row, math.max(theme.CornerRadius - 2, 0))
	return row
end

local function newContainer(section, name)
	local container = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = section:_nextOrder(),
		Parent = section.Frame,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = container,
	})
	return container
end

local function newCaption(parent, text, theme, order)
	return create("TextLabel", {
		Name = "Description",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = FONT,
		Text = text,
		TextColor3 = theme.Text,
		TextTransparency = 0.4,
		TextSize = theme.FontSize - 2,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = order,
		Parent = parent,
	})
end

---------------------------------------------------------------------------
-- Button
---------------------------------------------------------------------------

function Section:CreateButton(config)
	config = config or {}
	local window = self.Window
	local theme = window.Theme

	local container = newContainer(self, "Button")
	local button = create("TextButton", {
		Name = "Control",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = FONT,
		Text = tostring(config.Text or "Button"),
		TextColor3 = theme.Text,
		TextSize = theme.FontSize,
		LayoutOrder = 1,
		Parent = container,
	})
	addCorner(button, math.max(theme.CornerRadius - 2, 0))
	addStroke(button, theme.Border)

	if type(config.Description) == "string" and config.Description ~= "" then
		newCaption(container, config.Description, theme, 2)
	end

	local hoverColor = theme.Background:Lerp(theme.Accent, 0.2)
	local pressColor = theme.Background:Lerp(theme.Accent, 0.45)
	window:_connect(button.MouseEnter, function()
		tween(button, { BackgroundColor3 = hoverColor })
	end)
	window:_connect(button.MouseLeave, function()
		tween(button, { BackgroundColor3 = theme.Background })
	end)
	window:_connect(button.MouseButton1Down, function()
		tween(button, { BackgroundColor3 = pressColor })
	end)
	window:_connect(button.MouseButton1Up, function()
		tween(button, { BackgroundColor3 = hoverColor })
	end)
	window:_connect(button.Activated, function()
		safeCall(config.Callback)
	end)

	local object = { Instance = container }
	function object:SetText(text)
		button.Text = tostring(text)
	end
	return object
end

---------------------------------------------------------------------------
-- Toggle
---------------------------------------------------------------------------

function Section:CreateToggle(config)
	config = config or {}
	local window = self.Window
	local theme = window.Theme
	local state = config.Default == true

	local row = newRow(self, "Toggle", 36)
	create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -66, 1, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = tostring(config.Text or "Toggle"),
		TextColor3 = theme.Text,
		TextSize = theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})

	local track = create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(40, 20),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Parent = row,
	})
	addCorner(track, 10)
	local knob = create("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = track,
	})
	addCorner(knob, 8)

	local hit = create("TextButton", {
		Name = "Hit",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Parent = row,
	})

	local object = { Instance = row }

	local function render()
		tween(track, { BackgroundColor3 = state and theme.Accent or theme.Border })
		tween(knob, { Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2) })
	end
	track.BackgroundColor3 = state and theme.Accent or theme.Border
	knob.Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)

	function object:Set(value, silent)
		value = value == true
		if value == state then
			return
		end
		state = value
		render()
		if not silent then
			safeCall(config.Callback, state)
		end
	end

	function object:Get()
		return state
	end

	window:_connect(hit.Activated, function()
		object:Set(not state)
	end)
	return object
end

---------------------------------------------------------------------------
-- Slider
---------------------------------------------------------------------------

function Section:CreateSlider(config)
	config = config or {}
	local window = self.Window
	local theme = window.Theme

	local minValue = tonumber(config.Min) or 0
	local maxValue = tonumber(config.Max) or 100
	if maxValue <= minValue then
		maxValue = minValue + 1
	end
	local step = tonumber(config.Step) or 1
	if step <= 0 then
		step = 1
	end

	local decimals = 0
	while decimals < 6 do
		local scaled = step * (10 ^ decimals)
		if math.abs(scaled - math.floor(scaled + 0.5)) < 1e-9 then
			break
		end
		decimals = decimals + 1
	end
	local format = "%." .. tostring(decimals) .. "f"

	local function snap(value)
		value = math.clamp(value, minValue, maxValue)
		value = minValue + math.floor((value - minValue) / step + 0.5) * step
		return math.clamp(value, minValue, maxValue)
	end

	local current = snap(tonumber(config.Default) or minValue)

	local row = newRow(self, "Slider", 54)
	create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(10, 6),
		Size = UDim2.new(1, -90, 0, 20),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = tostring(config.Text or "Slider"),
		TextColor3 = theme.Text,
		TextSize = theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})
	local valueLabel = create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 6),
		Size = UDim2.fromOffset(70, 20),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = "",
		TextColor3 = theme.Accent,
		TextSize = theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})

	local track = create("Frame", {
		Name = "Track",
		Position = UDim2.new(0, 10, 0, 38),
		Size = UDim2.new(1, -20, 0, 6),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Parent = row,
	})
	addCorner(track, 3)
	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	addCorner(fill, 3)
	local knob = create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = track,
	})
	addCorner(knob, 7)

	-- Vùng bắt thao tác rộng hơn thanh trượt để dễ chạm trên điện thoại.
	local hit = create("TextButton", {
		Name = "Hit",
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Text = "",
		Parent = row,
	})

	local object = { Instance = row }

	local function render()
		local alpha = (current - minValue) / (maxValue - minValue)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		valueLabel.Text = string.format(format, current)
	end
	render()

	function object:Set(value, silent)
		local snapped = snap(tonumber(value) or current)
		if snapped == current then
			return
		end
		current = snapped
		render()
		if not silent then
			safeCall(config.Callback, current)
		end
	end

	function object:Get()
		return current
	end

	local function updateFromPosition(position)
		local width = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((position.X - track.AbsolutePosition.X) / width, 0, 1)
		object:Set(minValue + alpha * (maxValue - minValue))
	end

	window:_connect(hit.InputBegan, function(input)
		if not isPress(input) then
			return
		end
		updateFromPosition(input.Position)
		window._activeDrag = function(moved)
			updateFromPosition(moved.Position)
		end
	end)
	return object
end

---------------------------------------------------------------------------
-- Dropdown
---------------------------------------------------------------------------

function Section:CreateDropdown(config)
	config = config or {}
	local window = self.Window
	local theme = window.Theme

	local options = {}
	for _, option in ipairs(config.Options or {}) do
		table.insert(options, tostring(option))
	end

	local selected = nil
	if config.Default ~= nil and table.find(options, tostring(config.Default)) then
		selected = tostring(config.Default)
	else
		selected = options[1]
	end

	local container = newContainer(self, "Dropdown")
	local header = create("TextButton", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = 1,
		Parent = container,
	})
	addCorner(header, math.max(theme.CornerRadius - 2, 0))
	addStroke(header, theme.Border)

	create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(0.5, -10, 1, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = tostring(config.Text or "Dropdown"),
		TextColor3 = theme.Text,
		TextSize = theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	local valueLabel = create("TextLabel", {
		Name = "Value",
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(0.5, -28, 1, 0),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = selected or "-",
		TextColor3 = theme.Accent,
		TextSize = theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	local arrow = create("TextLabel", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = "v",
		TextColor3 = theme.Text,
		TextSize = theme.FontSize - 2,
		Parent = header,
	})

	local optionHeight = 28
	local visibleCount = math.min(math.max(#options, 1), 5)
	local list = create("ScrollingFrame", {
		Name = "List",
		Size = UDim2.new(1, 0, 0, visibleCount * optionHeight),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Border,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		LayoutOrder = 2,
		Parent = container,
	})
	addCorner(list, math.max(theme.CornerRadius - 2, 0))
	addStroke(list, theme.Border)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

	local object = { Instance = container }
	local optionButtons = {}

	local function refreshHighlight()
		for name, optionButton in pairs(optionButtons) do
			optionButton.TextColor3 = (name == selected) and theme.Accent or theme.Text
		end
	end

	local function setOpen(open)
		list.Visible = open
		arrow.Text = open and "^" or "v"
	end

	for index, name in ipairs(options) do
		local optionButton = create("TextButton", {
			Name = "Option_" .. tostring(index),
			Size = UDim2.new(1, 0, 0, optionHeight),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = FONT,
			Text = name,
			TextColor3 = theme.Text,
			TextSize = theme.FontSize,
			LayoutOrder = index,
			Parent = list,
		})
		optionButtons[name] = optionButton
		window:_connect(optionButton.Activated, function()
			object:Set(name)
			setOpen(false)
		end)
	end
	refreshHighlight()

	function object:Set(name, silent)
		name = tostring(name)
		if not optionButtons[name] or name == selected then
			return
		end
		selected = name
		valueLabel.Text = selected
		refreshHighlight()
		if not silent then
			safeCall(config.Callback, selected)
		end
	end

	function object:Get()
		return selected
	end

	function object:Open()
		setOpen(true)
	end

	function object:Close()
		setOpen(false)
	end

	window:_connect(header.Activated, function()
		setOpen(not list.Visible)
	end)
	return object
end

---------------------------------------------------------------------------
-- Textbox
---------------------------------------------------------------------------

function Section:CreateTextbox(config)
	config = config or {}
	local window = self.Window
	local theme = window.Theme

	local row = newRow(self, "Textbox", 38)
	local box = create("TextBox", {
		Name = "Input",
		Position = UDim2.fromOffset(6, 5),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundColor3 = theme.Secondary,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = FONT,
		PlaceholderText = tostring(config.Placeholder or ""),
		PlaceholderColor3 = theme.Text:Lerp(theme.Secondary, 0.5),
		Text = tostring(config.Default or ""),
		TextColor3 = theme.Text,
		TextSize = theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	addCorner(box, math.max(theme.CornerRadius - 2, 0))
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = box,
	})

	if config.Mode == "change" then
		window:_connect(box:GetPropertyChangedSignal("Text"), function()
			safeCall(config.Callback, box.Text, false)
		end)
	else
		window:_connect(box.FocusLost, function(enterPressed)
			safeCall(config.Callback, box.Text, enterPressed)
		end)
	end

	local object = { Instance = row }
	function object:Get()
		return box.Text
	end
	function object:Set(text)
		box.Text = tostring(text)
	end
	return object
end

---------------------------------------------------------------------------
-- Label / Paragraph / Divider
---------------------------------------------------------------------------

local function newTextBlock(section, name, config, font, transparency)
	local theme = section.Window.Theme
	local color = theme.Text
	if typeof(config.Color) == "Color3" then
		color = config.Color
	end
	local label = create("TextLabel", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = font,
		Text = tostring(config.Text or ""),
		TextColor3 = color,
		TextTransparency = transparency,
		TextSize = tonumber(config.Size) or theme.FontSize,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = section:_nextOrder(),
		Parent = section.Frame,
	})
	local object = { Instance = label }
	function object:SetText(text)
		label.Text = tostring(text)
	end
	return object
end

function Section:CreateLabel(config)
	return newTextBlock(self, "Label", config or {}, FONT_BOLD, 0)
end

function Section:CreateParagraph(config)
	return newTextBlock(self, "Paragraph", config or {}, FONT, 0.15)
end

function Section:CreateDivider()
	local theme = self.Window.Theme
	local divider = create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		LayoutOrder = self:_nextOrder(),
		Parent = self.Frame,
	})
	return { Instance = divider }
end

-- Return the library so callers can use Library:CreateWindow(...)
return Library
