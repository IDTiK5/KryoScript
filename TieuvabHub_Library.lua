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

--[[
	Slide.lua — Section:CreateSlider (bản nâng cấp)

	Config hỗ trợ:
		Text        (string)   Tiêu đề thanh trượt
		Min / Max   (number)   Khoảng giá trị (mặc định 0 / 100)
		Step        (number)   Bước nhảy (mặc định 1)
		Default     (number)   Giá trị ban đầu
		Callback    (function) Gọi mỗi khi giá trị thay đổi
		Prefix      (string)   [MỚI] Tiền tố hiển thị, ví dụ "$"
		Suffix      (string)   [MỚI] Hậu tố hiển thị, ví dụ "%", " FPS"
		AllowInput  (boolean)  [MỚI] Cho phép gõ số trực tiếp (mặc định true)
		Tooltip     (boolean)  [MỚI] Bong bóng giá trị khi kéo (mặc định true)

	API (giữ nguyên): object:Set(value, silent), object:Get(), object.Instance

	Phụ thuộc có sẵn trong thư viện: Section, newRow, create, addCorner,
	safeCall, FONT, FONT_BOLD. Slider KHÔNG còn dùng isPress hay
	window._activeDrag nữa; window:_connect chỉ dùng (nếu có) để dọn kết nối.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- ===== [MỚI] Hằng số hoạt ảnh & kích thước =====
local TWEEN_CLICK = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) -- trượt tới vị trí khi nhấp / Set()
local TWEEN_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- hover, glow, tooltip

local TRACK_H = 6 -- độ dày Track bình thường
local TRACK_H_ACTIVE = 8 -- độ dày Track khi hover/kéo
local KNOB_SIZE = 14
local KNOB_ACTIVE_SCALE = 1.3 -- Knob phóng to khi hover/kéo
local TIP_H = 20 -- chiều cao bong bóng giá trị
local TIP_OFFSET_Y = -16 -- vị trí đáy bong bóng so với tâm Knob
local TIP_LIFT = 6 -- quãng bong bóng "nổi lên" khi xuất hiện

-- [MỚI] Input tự quản lý: chỉ nhận chuột trái hoặc chạm (không phụ thuộc isPress bên ngoài)
local function isPointerPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

-- [MỚI] Chọn màu chữ (đen/trắng) dễ đọc trên nền màu nhấn
local function contrastColor(color)
	local luma = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
	return luma > 0.6 and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
end

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

	-- [MỚI] Prefix / Suffix và các tuỳ chọn bật/tắt
	local prefix = tostring(config.Prefix or "")
	local suffix = tostring(config.Suffix or "")
	local allowInput = config.AllowInput ~= false
	local useTooltip = config.Tooltip ~= false

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
		value = math.clamp(value, minValue, maxValue)
		-- Làm sạch sai số số thực (0.30000000000000004 -> 0.3)
		return tonumber(string.format("%.6f", value)) or value
	end

	local current = snap(tonumber(config.Default) or minValue)

	-- Trạng thái nội bộ
	local hovered = false -- chuột đang ở trên thanh trượt
	local dragging = false -- đang kéo
	local editing = false -- đang gõ số trong ô giá trị
	local tipVisible = false -- bong bóng đang hiện

	local accent = theme.Accent
	local tipTextSize = math.max((tonumber(theme.FontSize) or 14) - 1, 11)

	-- Kết nối sự kiện: ưu tiên window:_connect (để window tự dọn khi huỷ)
	local function connect(signal, handler)
		if type(window._connect) == "function" then
			return window:_connect(signal, handler)
		end
		return signal:Connect(handler)
	end

	-- ===== Dựng giao diện =====
	local row = newRow(self, "Slider", 54)
	create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(10, 6),
		Size = UDim2.new(1, -110, 0, 20),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = tostring(config.Text or "Slider"),
		TextColor3 = theme.Text,
		TextSize = theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})

	-- [MỚI] ValueLabel giờ là TextBox: nhấp vào để gõ số trực tiếp
	local valueBox = create("TextBox", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 5),
		Size = UDim2.fromOffset(84, 22),
		BackgroundColor3 = theme.Border,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
		Font = FONT_BOLD,
		Text = "",
		TextColor3 = accent,
		TextSize = theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextEditable = allowInput,
		Parent = row,
	})
	addCorner(valueBox, 5)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		Parent = valueBox,
	})
	local valueStroke = create("UIStroke", {
		Color = accent,
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = valueBox,
	})

	local track = create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0, 0.5), -- neo giữa để Track dày lên đều hai phía khi hover
		Position = UDim2.new(0, 10, 0, 41),
		Size = UDim2.new(1, -20, 0, TRACK_H),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Parent = row,
	})
	addCorner(track, 3)

	-- [MỚI] Fill dùng gradient nhẹ (đậm -> sáng) cho cảm giác có chiều sâu
	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255), -- màu thật do UIGradient quyết định
		BorderSizePixel = 0,
		Parent = track,
	})
	addCorner(fill, 3)
	create("UIGradient", {
		Color = ColorSequence.new(
			accent:Lerp(Color3.fromRGB(0, 0, 0), 0.2),
			accent:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
		),
		Parent = fill,
	})

	-- [MỚI] KnobHolder: khung rỗng (0x0) di chuyển theo giá trị.
	-- Glow, Knob và Tooltip là con của nó nên luôn đi cùng nhau, chỉ cần tween 1 Position.
	local knobHolder = create("Frame", {
		Name = "KnobHolder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		Parent = track,
	})

	-- [MỚI] Hai lớp Glow (vòng sáng) nằm DƯỚI Knob; mặc định ẩn (trong suốt, thu nhỏ)
	local glowLayers = {}
	local function makeGlow(size, hoverT, dragT)
		local frame = create("Frame", {
			Name = "Glow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(size, size),
			BackgroundColor3 = accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 1,
			Parent = knobHolder,
		})
		create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = frame })
		local scale = create("UIScale", { Scale = 0.6, Parent = frame })
		glowLayers[#glowLayers + 1] = {
			frame = frame,
			scale = scale,
			hoverT = hoverT, -- độ trong suốt khi hover
			dragT = dragT, -- độ trong suốt khi kéo (đậm hơn)
		}
	end
	makeGlow(40, 0.9, 0.8) -- lớp ngoài, mờ
	makeGlow(26, 0.78, 0.6) -- lớp trong, đậm hơn

	local knob = create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(KNOB_SIZE, KNOB_SIZE),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = knobHolder,
	})
	addCorner(knob, KNOB_SIZE / 2)
	-- UIScale giúp phóng to Knob mà vẫn giữ nguyên hình tròn
	local knobScale = create("UIScale", { Scale = 1, Parent = knob })
	local knobStroke = create("UIStroke", {
		Color = accent,
		Thickness = 0,
		Transparency = 0.35,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = knob,
	})

	-- [MỚI] Floating Tooltip: bong bóng giá trị nằm trên đỉnh Knob
	local tipRoot = create("Frame", {
		Name = "Tooltip",
		Position = UDim2.fromOffset(0, TIP_OFFSET_Y),
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 10,
		Parent = knobHolder,
	})
	local bubble = create("Frame", {
		Name = "Bubble",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(40, TIP_H),
		BackgroundColor3 = accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = tipRoot,
	})
	addCorner(bubble, 6)
	local arrow = create("Frame", { -- mũi tên nhỏ chỉ xuống Knob
		Name = "Arrow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.fromOffset(8, 8),
		Rotation = 45,
		BackgroundColor3 = accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = bubble,
	})
	addCorner(arrow, 2)
	local tipLabel = create("TextLabel", {
		Name = "Text",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = "",
		TextColor3 = contrastColor(accent),
		TextSize = tipTextSize,
		TextTransparency = 1,
		ZIndex = 11,
		Parent = bubble,
	})

	-- Vùng bắt thao tác rộng hơn thanh trượt để dễ chạm trên điện thoại.
	local hit = create("TextButton", {
		Name = "Hit",
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = row,
	})

	local object = { Instance = row }

	-- ===== [MỚI] Tiện ích tween: mỗi Instance chỉ giữ 1 tween, tween mới sẽ huỷ tween cũ =====
	local tweens = {}
	local function play(instance, info, props)
		local old = tweens[instance]
		if old then
			old:Cancel()
		end
		local tween = TweenService:Create(instance, info, props)
		tweens[instance] = tween
		tween:Play()
	end
	-- Gán thẳng (không hoạt ảnh) và huỷ tween đang chạy để tránh bị ghi đè
	local function setNow(instance, props)
		local old = tweens[instance]
		if old then
			old:Cancel()
			tweens[instance] = nil
		end
		for key, value in pairs(props) do
			instance[key] = value
		end
	end

	-- ===== Hiển thị giá trị =====
	local function alphaOf(value)
		return (value - minValue) / (maxValue - minValue)
	end

	-- [MỚI] Giá trị hiển thị = Prefix .. số .. Suffix
	local function formatValue(value)
		return prefix .. string.format(format, value) .. suffix
	end

	-- Đo chiều rộng chữ của tooltip (có dự phòng nếu GetTextSize lỗi)
	local function measureText(text)
		local ok, size = pcall(function()
			return TextService:GetTextSize(text, tipTextSize, FONT_BOLD, Vector2.new(1000, 100))
		end)
		if ok and typeof(size) == "Vector2" then
			return size.X
		end
		return #text * 7
	end

	-- [MỚI] Cập nhật chữ + kích thước + vị trí bong bóng. Bong bóng được kẹp trong
	-- mép thanh trượt (tối đa lấn ra 10px) còn mũi tên vẫn chỉ đúng vào Knob.
	local function updateTooltip(alpha)
		local text = formatValue(current)
		tipLabel.Text = text
		local width = math.max(measureText(text) + 16, 28)
		bubble.Size = UDim2.fromOffset(width, TIP_H)

		local trackWidth = track.AbsoluteSize.X
		local halfExtra = width / 2 - 10
		local offsetX = 0
		if halfExtra > 0 and trackWidth > halfExtra * 2 then
			local px = alpha * trackWidth
			offsetX = math.clamp(px, halfExtra, trackWidth - halfExtra) - px
		end
		bubble.Position = UDim2.fromOffset(offsetX, 0)
		arrow.Position = UDim2.new(0.5, -offsetX, 1, 0)
	end

	-- animate = true: trượt mượt (nhấp / Set); false: bám sát con trỏ khi kéo
	local function render(animate)
		local alpha = alphaOf(current)
		local fillSize = UDim2.fromScale(alpha, 1)
		local knobPos = UDim2.fromScale(alpha, 0.5)
		if animate then
			play(fill, TWEEN_CLICK, { Size = fillSize })
			play(knobHolder, TWEEN_CLICK, { Position = knobPos })
		else
			setNow(fill, { Size = fillSize })
			setNow(knobHolder, { Position = knobPos })
		end

		-- Không ghi đè chữ khi người dùng đang gõ
		if not editing then
			valueBox.Text = formatValue(current)
		end
		if tipVisible then
			updateTooltip(alpha)
		end
	end
	render(false)

	-- [MỚI] Hiệu ứng Hover/Dragging: Knob phóng to + Glow + Track dày lên
	local function applyState()
		local active = dragging or hovered
		play(knobScale, TWEEN_FAST, { Scale = active and KNOB_ACTIVE_SCALE or 1 })
		play(knobStroke, TWEEN_FAST, { Thickness = active and 2.5 or 0 })
		play(track, TWEEN_FAST, {
			Size = UDim2.new(1, -20, 0, active and TRACK_H_ACTIVE or TRACK_H),
		})
		for _, glow in ipairs(glowLayers) do
			local transparency = 1
			if dragging then
				transparency = glow.dragT
			elseif hovered then
				transparency = glow.hoverT
			end
			play(glow.frame, TWEEN_FAST, { BackgroundTransparency = transparency })
			play(glow.scale, TWEEN_FAST, { Scale = active and 1 or 0.6 })
		end
	end

	-- [MỚI] Hiện/ẩn bong bóng giá trị (mờ dần + nổi lên nhẹ)
	local function setTooltip(visible)
		if not useTooltip or tipVisible == visible then
			return
		end
		tipVisible = visible
		if visible then
			tipRoot.Visible = true
			setNow(tipRoot, { Position = UDim2.fromOffset(0, TIP_OFFSET_Y + TIP_LIFT) })
			updateTooltip(alphaOf(current))
			play(tipRoot, TWEEN_FAST, { Position = UDim2.fromOffset(0, TIP_OFFSET_Y) })
			play(bubble, TWEEN_FAST, { BackgroundTransparency = 0 })
			play(arrow, TWEEN_FAST, { BackgroundTransparency = 0 })
			play(tipLabel, TWEEN_FAST, { TextTransparency = 0 })
		else
			play(tipRoot, TWEEN_FAST, { Position = UDim2.fromOffset(0, TIP_OFFSET_Y + TIP_LIFT) })
			play(bubble, TWEEN_FAST, { BackgroundTransparency = 1 })
			play(arrow, TWEEN_FAST, { BackgroundTransparency = 1 })
			play(tipLabel, TWEEN_FAST, { TextTransparency = 1 })
			task.delay(TWEEN_FAST.Time, function()
				-- Chỉ ẩn hẳn nếu trong lúc chờ người dùng chưa kéo lại
				if not tipVisible then
					tipRoot.Visible = false
				end
			end)
		end
	end

	-- ===== Đặt giá trị (lõi chung cho Set / kéo / gõ số) =====
	local function setValue(value, silent, animate)
		local snapped = snap(tonumber(value) or current)
		if snapped == current then
			return
		end
		current = snapped
		render(animate)
		if not silent then
			safeCall(config.Callback, current)
		end
	end

	function object:Set(value, silent)
		-- Đang kéo thì bám sát con trỏ, không tween để tránh trễ
		setValue(value, silent, not dragging)
	end

	function object:Get()
		return current
	end

	-- ===== [MỚI] Nhập số trực tiếp =====
	-- Chấp nhận "1,5" lẫn "1.5"; bỏ mọi ký tự không phải số (kể cả prefix/suffix người dùng gõ nhầm)
	local function parseNumber(text)
		local cleaned = string.gsub(text, ",", ".")
		cleaned = string.gsub(cleaned, "[^%d%.%-]", "")
		return tonumber(cleaned)
	end

	local valueHover = false -- chuột đang ở trên ô giá trị
	local function refreshValueBox()
		local boxT = 1
		if editing then
			boxT = 0.35
		elseif allowInput and valueHover then
			boxT = 0.6
		end
		play(valueBox, TWEEN_FAST, { BackgroundTransparency = boxT })
		play(valueStroke, TWEEN_FAST, { Transparency = editing and 0.25 or 1 })
	end

	if allowInput then
		local invalidChars = minValue < 0 and "[^%d%.,%-]" or "[^%d%.,]"

		connect(valueBox.Focused, function()
			-- Khi gõ: hiện số thuần (không prefix/suffix) và chọn toàn bộ để ghi đè nhanh
			valueBox.Text = string.format(format, current)
			editing = true
			valueBox.CursorPosition = #valueBox.Text + 1
			valueBox.SelectionStart = 1
			refreshValueBox()
		end)

		-- Chặn ký tự lạ ngay khi gõ
		connect(valueBox:GetPropertyChangedSignal("Text"), function()
			if not editing then
				return
			end
			local filtered = string.gsub(valueBox.Text, invalidChars, "")
			if filtered ~= valueBox.Text then
				valueBox.Text = filtered
			end
		end)

		-- Thoát ô nhập (Enter / bấm ra ngoài): áp dụng giá trị, tự kẹp theo Min/Max/Step
		connect(valueBox.FocusLost, function()
			editing = false
			local typed = parseNumber(valueBox.Text)
			if typed then
				setValue(typed, false, true)
			end
			valueBox.Text = formatValue(current) -- nhập sai/không đổi thì trả về giá trị hợp lệ
			refreshValueBox()
		end)

		connect(valueBox.MouseEnter, function()
			valueHover = true
			refreshValueBox()
		end)
		connect(valueBox.MouseLeave, function()
			valueHover = false
			refreshValueBox()
		end)
	end

	-- ===== [MỚI] Kéo thả tự quản lý (PC + điện thoại) =====
	local dragInput = nil -- InputObject đang kéo (để phân biệt từng ngón khi cảm ứng đa điểm)
	local dragConns = {} -- kết nối tạm: chỉ tồn tại trong lúc kéo → không tốn tài nguyên khi nhàn rỗi
	local scrollFrame = nil
	local scrollWasEnabled = true

	local function updateFromPosition(position, animate)
		local width = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((position.X - track.AbsolutePosition.X) / width, 0, 1)
		setValue(minValue + alpha * (maxValue - minValue), false, animate)
	end

	local function stopDrag()
		if not dragging then
			return
		end
		dragging = false
		for _, conn in ipairs(dragConns) do
			conn:Disconnect()
		end
		table.clear(dragConns)

		-- Trả lại khả năng cuộn của khung chứa
		if scrollFrame then
			scrollFrame.ScrollingEnabled = scrollWasEnabled
			scrollFrame = nil
		end

		-- Cảm ứng không có "hover": thả tay là về trạng thái thường
		if dragInput and dragInput.UserInputType == Enum.UserInputType.Touch then
			hovered = false
		end
		dragInput = nil

		setTooltip(false)
		applyState()
	end

	local function startDrag(input)
		if dragging then
			return
		end
		-- Đang gõ số mà nhấp vào thanh trượt thì chốt giá trị đang gõ trước
		if valueBox:IsFocused() then
			valueBox:ReleaseFocus()
		end

		dragging = true
		dragInput = input
		local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1

		-- Khóa cuộn của ScrollingFrame cha để kéo ngang trên điện thoại không bị cuộn trang
		scrollFrame = row:FindFirstAncestorWhichIsA("ScrollingFrame")
		if scrollFrame then
			scrollWasEnabled = scrollFrame.ScrollingEnabled
			scrollFrame.ScrollingEnabled = false
		end

		-- Nhấp vào Track: Knob trượt mượt tới vị trí bằng Tween
		updateFromPosition(input.Position, true)
		setTooltip(true)
		applyState()

		-- InputChanged: chuột thì theo MouseMovement, cảm ứng thì theo đúng ngón đã chạm
		dragConns[#dragConns + 1] = UserInputService.InputChanged:Connect(function(changed)
			if isMouse then
				if changed.UserInputType == Enum.UserInputType.MouseMovement then
					updateFromPosition(changed.Position, false)
				end
			elseif changed == input then
				updateFromPosition(changed.Position, false)
			end
		end)

		-- InputEnded: thả chuột trái / nhấc đúng ngón tay đang kéo (kể cả thả ngoài thanh trượt)
		dragConns[#dragConns + 1] = UserInputService.InputEnded:Connect(function(ended)
			if ended == input or (isMouse and ended.UserInputType == Enum.UserInputType.MouseButton1) then
				stopDrag()
			end
		end)
	end

	-- InputBegan: bắt đầu kéo khi chuột trái / chạm vào vùng Hit
	connect(hit.InputBegan, function(input)
		if isPointerPress(input) then
			startDrag(input)
		end
	end)

	-- Hover (chỉ có ở chuột)
	connect(hit.MouseEnter, function()
		hovered = true
		applyState()
	end)
	connect(hit.MouseLeave, function()
		hovered = false
		applyState()
	end)

	-- Dọn dẹp nếu hàng bị huỷ giữa lúc đang kéo
	row.Destroying:Connect(function()
		stopDrag()
		for _, tween in pairs(tweens) do
			tween:Cancel()
		end
		table.clear(tweens)
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
