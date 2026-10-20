local a, b, c = {}, {}, "Module not found: "
local d = function(d)
	if b[d] then
		return b[d]
	end
	local e = a[d]
	assert(e, c .. tostring(d))
	if type(e) ~= "function" then
		return e
	end
	local f = e()
	b[d] = f
	return f
end
a["Bypass/Adonis"]=function()
local e = d("Core/Logger")
local f, g, h =
	{
		Hooks = {},
		FlagFunction = nil,
		TerminateFunction = nil,
		DetectionDisabled = false,
		KillBlocked = false,
		DebugInfoIntercepted = false,
		ScanAttempts = 0,
		MaxScanAttempts = 50,
	},
	function(f, g)
		local h, i = pcall(function()
			return hookfunction(f, newcclosure(g))
		end)
		return h
	end
local i, j =
	function()
		f.ScanAttempts = f.ScanAttempts + 1
		local i, j = getgc(true), false
		for k, l in ipairs(i) do
			if typeof(l) == "table" then
				local m, n = rawget(l, "Detected"), rawget(l, "Kill")
				if typeof(m) == "function" and not f.FlagFunction then
					f.FlagFunction = m
					g(m, function(o, p, q)
						return true
					end)
					table.insert(f.Hooks, m)
					f.DetectionDisabled = true
					j = true
				end
				if typeof(n) == "function" and rawget(l, "Variables") and rawget(l, "Process") and not f.TerminateFunction then
					f.TerminateFunction = n
					g(n, function(o)
						return nil
					end)
					table.insert(f.Hooks, n)
					f.KillBlocked = true
					j = true
				end
			end
		end
		return j
	end, function()
		if not f.FlagFunction then
			return
		end
		local i = getrenv().debug.info
		h = hookfunction(
			i,
			newcclosure(function(...)
				local j = ...
				if f.FlagFunction and j == f.FlagFunction then
					return coroutine.yield(coroutine.running())
				end
				return h(...)
			end)
		)
		f.DebugInfoIntercepted = true
	end
local k, l, m =
	function()
		if not getgc or not hookfunction or not newcclosure or not getrenv or not islclosure or not isourclosure or not getconstants then
			e.Info("Adonis bypass: missing executor functions, skipping")
			return true
		end
		local k = false
		for l, m in getgc() do
			if typeof(m) == "function" and islclosure(m) and not isourclosure(m) then
				local n = false
				for o, p in getconstants(m) do
					if typeof(p) == "string" and p:find("Adonis_") then
						n = true
						break
					end
				end
				if n then
					k = true
					break
				end
			end
		end
		if not k then
			e.Info("Adonis bypass: no Adonis detected, skipping")
			return true
		end
		e.Info("Adonis detected, activating bypass...")
		setthreadidentity(2)
		for l = 1, f.MaxScanAttempts do
			local m = i()
			if m then
				break
			end
			if l < f.MaxScanAttempts then
				task.wait(0.05)
			end
		end
		if f.FlagFunction then
			j()
		end
		setthreadidentity(7)
		local l = f.DetectionDisabled and f.KillBlocked and f.DebugInfoIntercepted
		if l then
			e.Info("Adonis bypass activated after", f.ScanAttempts, "scan(s)")
		else
			e.Warn("Adonis bypass incomplete \u{2014} detection:", f.DetectionDisabled, "kill:", f.KillBlocked, "attempts:", f.ScanAttempts)
		end
		return l
	end, function()
		return f
	end, function()
		return f.DetectionDisabled and f.KillBlocked
	end
return table.freeze({ Activate = k, GetStatus = l, IsBypassed = m, State = f })
end
a["Bypass/Environment"]=function()
local e = d("Core/Logger")
local f
local g = function()
	if f then
		return f
	end
	local g = {
		gethui = pcall(function()
			local g = gethui()
			return g ~= nil
		end),
		synProtectGui = syn ~= nil and syn.protect_gui ~= nil,
		protectGui = protect_gui ~= nil,
		protectgui = protectgui ~= nil,
		coreGuiAccess = true,
		cloneref = cloneref ~= nil,
		hookfunction = hookfunction ~= nil,
		newcclosure = newcclosure ~= nil,
		getgc = getgc ~= nil,
		getconstants = getconstants ~= nil,
		islclosure = islclosure ~= nil,
		isourclosure = isourclosure ~= nil,
		setthreadidentity = setthreadidentity ~= nil,
		getrenv = getrenv ~= nil,
	}
	f = g
	return g
end
local h, i, j =
	function()
		local h = g()
		return h.hookfunction and h.newcclosure and h.getgc and h.getconstants and h.islclosure and h.setthreadidentity and h.getrenv
	end, function()
		local h = g()
		return h.gethui or h.synProtectGui or h.protectGui or h.protectgui
	end, function()
		local h = g()
		e.Info("Executor capabilities:")
		for i, j in h do
			e.Info("  ", i, "=", j)
		end
	end
return table.freeze({ Detect = g, HasBypassSupport = h, HasGuiProtection = i, LogCapabilities = j })
end
a["Bypass/GuiProtection"]=function()
local e, f = game:GetService("RunService"), d("Core/Logger")
local g = { Container = nil, Level = "hidden", StudioMode = false }
local h, i, j, k, l, m =
	function(h)
		g.StudioMode = h
		if h then
			g.Level = "protected"
		end
	end, function(h)
		g.Container = h
	end, function()
		if g.StudioMode then
			return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end
		if not cloneref then
			error([[[SeaHub] CRITICAL: cloneref not supported - executor outdated!]])
		end
		if gethui then
			local h, i = pcall(gethui)
			if h and i then
				g.Container = i
				g.Level = "hidden"
				f.Info("[GUI Protection] Using gethui() - Class:", i.ClassName)
				return i
			end
		end
		local h, i = pcall(function()
			return cloneref(game:GetService("CoreGui"))
		end)
		if not h or not i then
			error([[[SeaHub] CRITICAL: Failed to get cloneref(CoreGui) - cannot mount UI safely!]])
		end
		g.Container = i
		g.Level = "protected"
		f.Info("[GUI Protection] Using cloneref(CoreGui)")
		return i
	end, function(h, i)
		if g.StudioMode then
			h.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
			g.Level = "protected"
			f.Info("[GUI Protection] Studio mode - PlayerGui")
			return true
		end
		if not cloneref then
			error([[[SeaHub] CRITICAL: cloneref not supported - executor outdated!]])
		end
		h.Name = "_SH_" .. string.char(math.random(65, 90)) .. string.char(math.random(65, 90)) .. string.char(math.random(65, 90))
		if gethui then
			local j, k = pcall(gethui)
			if j and k then
				h.Parent = k
				g.Level = "hidden"
				f.Info("[GUI Protection] SUCCESS - gethui()")
				return true
			end
		end
		local j, k = pcall(function()
			return cloneref(game:GetService("CoreGui"))
		end)
		if not j or not k then
			error([[[SeaHub] CRITICAL: cloneref(CoreGui) failed - cannot mount UI!]])
		end
		h.Parent = k
		g.Level = "protected"
		f.Info("[GUI Protection] SUCCESS - cloneref(CoreGui)")
		return true
	end, function()
		return g.Level
	end, function()
		return g.Container ~= nil
	end
return table.freeze({
	ProtectGui = k,
	GetSecureContainer = j,
	GetProtectionLevel = l,
	IsInitialized = m,
	SetStudioMode = h,
	SetSecureContainer = i,
	State = g,
})
end
a["Bypass/Init"]=function()
local e, f, g, h, i = d("Bypass/Adonis"), d("Bypass/GuiProtection"), d("Bypass/Registry"), d("Bypass/Initializer"), d("Bypass/Environment")
return table.freeze({
	ActivateAdonis = e.Activate,
	GetAdonisStatus = e.GetStatus,
	IsAdonisBypassed = e.IsBypassed,
	ProtectGui = f.ProtectGui,
	GetSecureContainer = f.GetSecureContainer,
	GetProtectionLevel = f.GetProtectionLevel,
	IsGuiInitialized = f.IsInitialized,
	SetStudioMode = f.SetStudioMode,
	SetSecureContainer = f.SetSecureContainer,
	RegisterBypass = g.Register,
	LoadAllBypasses = g.LoadAll,
	LoadWithProgress = g.LoadWithProgress,
	IsAnyBypassActive = g.IsAnyActive,
	SetBypassEnabled = g.SetEnabled,
	GetBypassStatus = g.GetStatus,
	DetectEnvironment = i.Detect,
	HasBypassSupport = i.HasBypassSupport,
	HasGuiProtection = i.HasGuiProtection,
	LogCapabilities = i.LogCapabilities,
	Initialize = h.Initialize,
	InitializeWithProgress = h.InitializeWithProgress,
	QuickCheck = h.QuickCheck,
})
end
a["Bypass/Initializer"]=function()
local e, f, g, h, i, j = game:GetService("RunService"), d("Core/Logger"), d("Bypass/Environment"), d("Bypass/Adonis"), d("Bypass/GuiProtection"), d("Bypass/Registry")
local k = function(k)
	local l = { Success = false, Adonis = false, Gui = false, Errors = {}, StudioMode = e:IsStudio() }
	f.SetLevel("INFO")
	if l.StudioMode then
		if k then
			k("Studio mode - PlayerGui mount", 0.1)
		end
		local m = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		i.SetStudioMode(true)
		i.SetSecureContainer(m)
		l.Gui = true
		l.Success = true
		if k then
			k("Studio initialization complete", 1)
		end
		return l
	end
	if k then
		k("Detecting executor capabilities", 0.05)
	end
	g.LogCapabilities()
	if k then
		k("Initializing GUI protection", 0.2)
	end
	l.Gui = i.IsInitialized() or (i.GetSecureContainer() ~= nil)
	if not l.Gui then
		table.insert(l.Errors, "GUI protection initialization failed")
	end
	if k then
		k("Activating Adonis bypass", 0.5)
	end
	if g.HasBypassSupport() then
		local m = pcall(h.Activate)
		l.Adonis = m
		if not m then
			table.insert(l.Errors, "Adonis bypass activation failed")
		end
	else
		f.Warn("Executor lacks bypass APIs; skipping Adonis bypass")
		l.Adonis = false
	end
	if k then
		k("Loading additional bypasses", 0.8)
	end
	local m = j.LoadAll()
	for n, o in ipairs(m) do
		if not o.Success then
			f.Warn(string.format("Bypass %s failed: %s", tostring(o.Name), tostring(o.Error or "unknown")))
		end
	end
	if k then
		k("Complete", 1)
	end
	l.Success = l.Gui or l.Adonis
	return l
end
local l, m =
	function()
		return k(nil)
	end, function()
		local l = g.Detect()
		return { gethui = l.gethui, synProtectGui = l.synProtectGui, protectGui = l.protectGui, adonisDetected = (function()
			if not l.getgc or not l.getconstants or not l.islclosure then
				return false
			end
			for m, n in getgc() do
				if typeof(n) == "function" and islclosure(n) then
					for o, p in getconstants(n) do
						if typeof(p) == "string" and p:find("Adonis_") then
							return true
						end
					end
				end
			end
			return false
		end)() }
	end
return table.freeze({ Initialize = l, InitializeWithProgress = k, QuickCheck = m })
end
a["Bypass/ProtectGuiHelper"]=function()
local aa, ab = d("Core/Logger"), d("Bypass/GuiProtection")
return function(ac, ad)
	local ae = ab.ProtectGui(ac, ad)
	if not ae then
		aa.Warn("GuiProtection failed to protect ScreenGui")
	end
end
end
a["Bypass/Registry"]=function()
local e, f, g = d("Core/Logger"), d("Bypass/Environment"), d("Bypass/Adonis")
local h = {}
local i, j, k, l, m, n, o, p =
	function(i, j, k)
		table.insert(h, { Name = i, Loader = j, Enabled = k or true })
	end, function()
		if not f.HasBypassSupport() then
			e.Warn("Executor lacks bypass support; skipping Adonis bypass")
			return false
		end
		return g.Activate()
	end, function()
		local i, j = pcall(function()
			loadstring(game:HttpGet([[https://raw.githubusercontent.com/secretisadev/Babyhamsta_Backup/refs/heads/main/Universal/Bypasses.lua]], true))()
			return true
		end)
		return i
	end, function()
		local i = {}
		for j, k in ipairs(h) do
			if k.Enabled then
				local l, m = pcall(k.Loader)
				table.insert(i, { Success = l, Name = k.Name, Error = (not l and { (tostring(m)) } or { nil })[1] })
			end
		end
		return i
	end, function(i)
		local j, k = {}, #h
		for l, m in ipairs(h) do
			if m.Enabled then
				i(string.format("Loading %s Bypass", tostring(m.Name)), l / k)
				local n, o = pcall(m.Loader)
				table.insert(j, { Success = n, Name = m.Name, Error = (not n and { (tostring(o)) } or { nil })[1] })
			end
		end
		return j
	end, function()
		for i, j in ipairs(h) do
			if j.Enabled then
				return true
			end
		end
		return false
	end, function(i, j)
		for k, l in ipairs(h) do
			if l.Name == i then
				l.Enabled = j
				break
			end
		end
	end, function()
		local i = {}
		for j, k in ipairs(h) do
			i[k.Name] = k.Enabled
		end
		return i
	end
i("Adonis", j, true)
i("GC", k, false)
return table.freeze({ Register = i, LoadAll = l, LoadWithProgress = m, IsAnyActive = n, SetEnabled = o, GetStatus = p })
end
a["Core/AnimKit"]=function()
local e, f, g = d("Core/Animator"), d("Core/AnimTokens"), {}
function g.ScalePop(h, i)
	local j = i or {}
	if j.anchorObject and j.anchor then
		j.anchorObject.AnchorPoint = j.anchor
	end
	local k = j.info or f.Preset.Pop
	h.Scale = j.start or f.Scale.PopStart
	e.Tween(h, { Scale = 1 }, k)
	return k.Time
end
function g.ScaleShrink(h, i)
	local j = i or {}
	local k, l = j.info or f.Preset.Close, h.Scale * (j.endScale or f.Scale.CloseEnd)
	e.Tween(h, { Scale = l }, k)
	return k.Time
end
function g.GroupFade(h, i, j)
	local k = (j and j.info) or f.Preset.Fade
	if i == "In" then
		h.GroupTransparency = 1
		e.Tween(h, { GroupTransparency = 0 }, k)
	else
		e.Tween(h, { GroupTransparency = 1 }, k)
	end
	return k.Time
end
function g.GroupFadeTween(h, i, j)
	local k = (j and j.info) or f.Preset.Fade
	if i == "In" then
		h.GroupTransparency = 1
		return e.Tween(h, { GroupTransparency = 0 }, k)
	end
	return e.Tween(h, { GroupTransparency = 1 }, k)
end
function g.FadeProp(h, i, j, k)
	local l = k or {}
	local m = l.info or f.Preset.Fade
	if l.from ~= nil then
		(h)[i] = l.from
	end
	e.Tween(h, { [i] = j }, m)
	return m.Time
end
function g.Slide(h, i, j)
	local k = j or {}
	local l = k.info or f.Info(f.Duration.Medium, f.Easing.Decelerate)
	if k.from then
		h.Position = k.from
	end
	e.Tween(h, { Position = i }, l)
	return l.Time
end
function g.Bounce(h, i)
	local j = i or {}
	local k, l, m =
		j.peak or f.Scale.BouncePeak,
		j.popInfo or f.Info(f.Duration.Snap + 0.02, f.Easing.Standard),
		j.settleInfo or f.Preset.Settle
	e.Tween(h, { Scale = k }, l)
	g.After(l.Time, function()
		e.Tween(h, { Scale = 1 }, m)
	end)
	return l.Time + m.Time
end
function g.After(h, i, j)
	task.delay(h, function()
		if j and not j() then
			return
		end
		i()
	end)
end
return table.freeze(g)
end
a["Core/AnimTokens"]=function()
local e, f = d("Core/Animator"), {}
f.Duration = { Instant = 0, Snap = 0.08, Fast = 0.12, Base = 0.15, Medium = 0.2, Slow = 0.25, Slower = 0.35 }
f.Easing = {
	Standard = { Style = e.Style.Quad, Dir = e.Dir.Out },
	Emphasized = { Style = e.Style.Back, Dir = e.Dir.Out },
	Decelerate = { Style = e.Style.Exponential, Dir = e.Dir.Out },
	Sharp = { Style = e.Style.Quint, Dir = e.Dir.Out },
	Settle = { Style = e.Style.Sine, Dir = e.Dir.Out },
}
function f.Info(g, h)
	local i = h or f.Easing.Standard
	return TweenInfo.new(g, i.Style, i.Dir)
end
f.Preset = {
	Fade = f.Info(0.15, f.Easing.Standard),
	Pop = f.Info(0.25, f.Easing.Emphasized),
	Close = f.Info(0.15, f.Easing.Standard),
	Focus = f.Info(0.15, f.Easing.Sharp),
	Settle = f.Info(0.18, f.Easing.Settle),
}
f.Scale = { PopStart = 0.85, CloseEnd = 0.94, BouncePeak = 1.025 }
return table.freeze(f)
end
a["Core/Animator"]=function()
local e, f = game:GetService("TweenService"), {}
f.Style = {
	Linear = Enum.EasingStyle.Linear,
	Sine = Enum.EasingStyle.Sine,
	Quad = Enum.EasingStyle.Quad,
	Cubic = Enum.EasingStyle.Cubic,
	Quart = Enum.EasingStyle.Quart,
	Quint = Enum.EasingStyle.Quint,
	Exponential = Enum.EasingStyle.Exponential,
	Circular = Enum.EasingStyle.Circular,
	Back = Enum.EasingStyle.Back,
	Bounce = Enum.EasingStyle.Bounce,
	Elastic = Enum.EasingStyle.Elastic,
}
f.Dir = { In = Enum.EasingDirection.In, Out = Enum.EasingDirection.Out, InOut = Enum.EasingDirection.InOut }
local g = {}
setmetatable(g, { __mode = "k" })
local h = {}
setmetatable(h, { __mode = "k" })
local i, j = 0, TweenInfo.new(0.2, f.Style.Quad, f.Dir.Out)
local k, l =
	function(k)
		if h[k] then
			return
		end
		h[k] = true
		i = i + 1
	end, function(k)
		if not h[k] then
			return
		end
		h[k] = nil
		i = math.max(0, i - 1)
	end
function f.Tween(m, n, o)
	local p
	if type(o) == "number" then
		p = TweenInfo.new(o, f.Style.Quad, f.Dir.Out)
	else
		p = o or j
	end
	local q = g[m]
	if q then
		for r in n do
			local s = q[r]
			if s then
				s:Cancel()
				l(s)
				q[r] = nil
			end
		end
	else
		q = {}
		g[m] = q
	end
	local r = e:Create(m, p, n)
	for s in n do
		q[s] = r
	end
	k(r)
	r.Completed:Once(function()
		l(r)
		local s = g[m]
		if s then
			for t in n do
				if s[t] == r then
					s[t] = nil
				end
			end
		end
	end)
	r:Play()
	return r
end
function f.Set(m, n)
	local o = g[m]
	if o then
		for p in n do
			local q = o[p]
			if q then
				q:Cancel()
				l(q)
				o[p] = nil
			end
		end
	end
	for p, q in n do
		(m)[p] = q
	end
end
function f.CancelInstance(m)
	local n = g[m]
	if n then
		for o, p in n do
			p:Cancel()
			l(p)
			n[o] = nil
		end
		g[m] = nil
	end
end
function f.CancelAll()
	for m, n in g do
		for o, p in n do
			p:Cancel()
			l(p)
		end
	end
	table.clear(g)
end
function f.GetActiveTweenCount()
	return i
end
return table.freeze(f)
end
a["Core/CalmFlush"]=function()
local e, f, g, h, i, j, k = {}, d("Core/Scheduler"), 80, false, false, {}, {}
local l = function()
	return not h and not i
end
function e.SetDragActive(m)
	h = m
	if not m then
		e.TryFlush()
	end
end
function e.SetScrollSuppressed(m)
	i = m
	if not m then
		e.TryFlush()
	end
end
function e.Register(m)
	if k[m] then
		return
	end
	k[m] = true
	table.insert(j, m)
end
function e.Unregister(m)
	if not k[m] then
		return
	end
	k[m] = nil
	local n = table.find(j, m)
	if n then
		local o = #j
		if n ~= o then
			j[n] = j[o]
		end
		j[o] = nil
	end
end
function e.TryFlush()
	if not l() then
		return
	end
	if #j == 0 then
		return
	end
	local m = j
	j = {}
	table.clear(k)
	if #m <= g then
		for n, o in m do
			o()
		end
		return
	end
	local n, o = 1, #m
	local function p()
		local q = math.min(n + g - 1, o)
		for r = n, q do
			m[r]()
		end
		n = q + 1
		if n <= o then
			f.Defer(p, "High")
		end
	end
	p()
end
return table.freeze(e)
end
a["Core/ColorUtil"]=function()
local aa = d("Core/Common")
local ab, ac = aa.Creator, {}
ac.RootWidth = 264
ac.PanelWidth = 260
ac.PanelHeight = 220
ac.SliderHeight = 8
ac.PreviewSize = 34
ac.HueSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
})
function ac.Theme(ad, ae)
	local af = ab.GetThemeProperty(ad)
	return (af ~= nil and { af } or { ae })[1]
end
local ad, ae, af, ag =
	Color3.fromRGB(18, 18, 18), Color3.fromRGB(245, 245, 245), 0.179, function(ad)
		return (ad <= 0.03928 and { (ad / 12.92) } or { (((ad + 0.055) / 1.055) ^ 2.4) })[1]
	end
function ac.RelativeLuminance(ah)
	return 0.2126 * ag(ah.R) + 0.7152 * ag(ah.G) + 0.0722 * ag(ah.B)
end
function ac.ContrastForeground(ah)
	return (ac.RelativeLuminance(ah) > af and { ad } or { ae })[1]
end
function ac.ToHex(ah)
	return ("#%02X%02X%02X"):format(math.round(ah.R * 255), math.round(ah.G * 255), math.round(ah.B * 255))
end
function ac.ToRgbText(ah, ai)
	return ("%d, %d, %d, %d%%"):format(
		math.round(ah.R * 255),
		math.round(ah.G * 255),
		math.round(ah.B * 255),
		math.round(ai * 100)
	)
end
function ac.ToHsl(ah)
	local ai, aj, ak = ah.R, ah.G, ah.B
	local al, am, an = math.max(ai, aj, ak), math.min(ai, aj, ak), 0
	local ao, ap = (al + am) / 2, 0
	if al ~= am then
		local aq = al - am
		ap = (ao > 0.5 and { (aq / (2 - al - am)) } or { (aq / (al + am)) })[1]
		if al == ai then
			an = (aj - ak) / aq + (aj < ak and 6 or 0)
		elseif al == aj then
			an = (ak - ai) / aq + 2
		else
			an = (ai - aj) / aq + 4
		end
		an = an / 6
	end
	return an, ap, ao
end
function ac.ToHslText(ah, ai)
	local aj, ak, al = ac.ToHsl(ah)
	return ("%d, %d%%, %d%%, %d%%"):format(
		math.round(aj * 360),
		math.round(ak * 100),
		math.round(al * 100),
		math.round(ai * 100)
	)
end
local ah = function(ah, ai, aj)
	if aj < 0 then
		aj = aj + 1
	end
	if aj > 1 then
		aj = aj - 1
	end
	if aj < 0.16666666666666666 then
		return ah + (ai - ah) * 6 * aj
	end
	if aj < 0.5 then
		return ai
	end
	if aj < 0.6666666666666666 then
		return ah + (ai - ah) * (0.6666666666666666 - aj) * 6
	end
	return ah
end
function ac.FromHsl(ai, aj, ak)
	ai = (ai % 360) / 360
	aj = math.clamp(aj / 100, 0, 1)
	ak = math.clamp(ak / 100, 0, 1)
	if aj == 0 then
		return Color3.new(ak, ak, ak)
	end
	local al = (ak < 0.5 and { (ak * (1 + aj)) } or { (ak + aj - ak * aj) })[1]
	local am = 2 * ak - al
	return Color3.new(ah(am, al, ai + 0.3333333333333333), ah(am, al, ai), ah(am, al, ai - 0.3333333333333333))
end
function ac.ParseNumbers(ai)
	local aj = {}
	for ak in string.gmatch(ai, "[%d%.]+") do
		local al = tonumber(ak)
		if al ~= nil then
			table.insert(aj, al)
		end
	end
	return aj
end
function ac.ParseHex(ai)
	local aj = string.gsub(ai, "#", "")
	if #aj ~= 6 and #aj ~= 8 then
		return nil, nil
	end
	local ak, al, am, an =
		tonumber(string.sub(aj, 1, 2), 16),
		tonumber(string.sub(aj, 3, 4), 16),
		tonumber(string.sub(aj, 5, 6), 16),
		(#aj == 8 and { (tonumber(string.sub(aj, 7, 8), 16)) } or { nil })[1]
	if not ak or not al or not am then
		return nil, nil
	end
	return Color3.fromRGB(ak, al, am), (an and { (math.clamp(an / 255, 0, 1)) } or { nil })[1]
end
function ac.ParseRgb(ai)
	local aj = ac.ParseNumbers(ai)
	if #aj < 3 then
		return nil, nil
	end
	local ak = (aj[4] ~= nil and { (math.clamp(aj[4] / 100, 0, 1)) } or { nil })[1]
	return Color3.fromRGB(
		math.clamp(math.round(aj[1]), 0, 255),
		math.clamp(math.round(aj[2]), 0, 255),
		math.clamp(math.round(aj[3]), 0, 255)
	),
		ak
end
function ac.ParseHsl(ai)
	local aj = ac.ParseNumbers(ai)
	if #aj < 3 then
		return nil, nil
	end
	local ak = (aj[4] ~= nil and { (math.clamp(aj[4] / 100, 0, 1)) } or { nil })[1]
	return ac.FromHsl(aj[1], aj[2], aj[3]), ak
end
function ac.PointInX(ai, aj)
	local ak = ai.AbsoluteSize
	return math.clamp((aj.Position.X - ai.AbsolutePosition.X) / math.max(ak.X, 1), 0, 1)
end
function ac.PointInPanel(ai, aj)
	local ak = ai.AbsoluteSize
	local al, am =
		math.clamp((aj.Position.X - ai.AbsolutePosition.X) / math.max(ak.X, 1), 0, 1),
		math.clamp((aj.Position.Y - ai.AbsolutePosition.Y) / math.max(ak.Y, 1), 0, 1)
	return al, 1 - am
end
return table.freeze(ac)
end
a["Core/Common"]=function()
return {
	Creator = d("Core/Creator"),
	Animator = d("Core/Animator"),
	AnimTokens = d("Core/AnimTokens"),
	AnimKit = d("Core/AnimKit"),
	Spring = d("Core/Spring"),
	SignalManager = d("Core/SignalManager"),
	Scheduler = d("Core/Scheduler"),
	ObjectPool = d("Core/ObjectPool"),
	Responsive = d("Core/Responsive"),
	TabContentScroll = d("Core/TabContentScroll"),
	WindowDrag = d("Core/WindowDrag"),
	CalmFlush = d("Core/CalmFlush"),
}
end
a["Core/Creator"]=function()
local e, f, g, h = d("Core/Logger"), d("Core/CreatorEvents"), d("Core/CreatorDefaults"), d("Core/ThemeRegistry")
local i, j, k, l = f.EventMarker, f.ThemeTag, f.RefKey, {}
l.ThemeTag = j
l.Ref = k
l.OnEvent = f.OnEvent
l.Activated = f.Activated
l.MouseButton1Click = f.MouseButton1Click
l.MouseButton1Down = f.MouseButton1Down
l.MouseButton1Up = f.MouseButton1Up
l.MouseButton2Click = f.MouseButton2Click
l.MouseEnter = f.MouseEnter
l.MouseLeave = f.MouseLeave
l.InputBegan = f.InputBegan
l.InputEnded = f.InputEnded
l.InputChanged = f.InputChanged
l.FocusLost = f.FocusLost
l.Focused = f.Focused
l.Changed = f.Changed
function l.AddThemeObject(m, n)
	h.AddObject(m, n)
end
function l.OverrideTag(m, n)
	h.OverrideTag(m, n)
end
function l.RemoveThemeObject(m)
	h.RemoveObject(m)
end
function l.SetThemeData(m, n)
	h.SetData(m, n)
end
function l.GetThemeProperty(m)
	return h.GetProperty(m)
end
function l.GetThemeValue(m)
	return h.GetValue(m)
end
function l.OnThemeChanged(m)
	return h.OnChanged(m)
end
function l.UpdateTheme()
	return h.Update()
end
function l.FlushThemeChangedCallbacks(m)
	h.FlushChangedCallbacks(m)
end
l.DefaultProperties = g
local m = {}
setmetatable(m, { __mode = "k" })
function l.TrackConnection(n, o)
	local p = m[n]
	if not p then
		p = {}
		m[n] = p
	end
	table.insert(p, o)
end
function l.CleanupInstance(n)
	local o = m[n]
	if o then
		for p = #o, 1, -1 do
			o[p]:Disconnect()
			o[p] = nil
		end
		m[n] = nil
	end
	l.RemoveThemeObject(n)
end
function l.GetRegistrySize()
	return h.GetRegistrySize()
end
function l.GetCleanupMapSize()
	local n = 0
	for o in m do
		n = n + 1
	end
	return n
end
local function n(o, p)
	for q, r in p do
		if typeof(r) == "Instance" then
			r.Parent = o
		elseif type(r) == "table" then
			n(o, r)
		end
	end
end
function l.New(o, p, q)
	local r, s = Instance.new(o), l.DefaultProperties[o]
	if s then
		for t, u in s do
			(r)[t] = u
		end
	end
	if p then
		local t, u
		for v, w in p do
			if v == j then
				t = w
			elseif v == k then
				u = w
			elseif type(v) == "table" and v._Marker == i then
				local x = v._Name
				local y = (r)[x]
				if y and typeof(y) == "RBXScriptSignal" then
					local z = y:Connect(w)
					l.TrackConnection(r, z)
				else
					e.Warn("Invalid event:", o, ".", x)
				end
			else
				if v == "Name" then
					continue
				end
				(r)[v] = w
			end
		end
		if t then
			l.AddThemeObject(r, t)
			if h.HasCurrentTheme() then
				for v, w in t do
					local x = l.GetThemeProperty(w)
					if x ~= nil then
						(r)[v] = x
					end
				end
			end
		end
		if u then
			u(r)
		end
	end
	if q then
		n(r, q)
	end
	return r
end
local o = {}
function l.AddSignal(p, q)
	local r = p:Connect(q)
	table.insert(o, r)
	return r
end
function l.Disconnect()
	for p = #o, 1, -1 do
		o[p]:Disconnect()
		o[p] = nil
	end
	for p in m do
		l.CleanupInstance(p)
	end
	h.Disconnect()
end
return table.freeze(l)
end
a["Core/CreatorDefaults"]=function()
return {
	ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
	Frame = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
	ScrollingFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ScrollBarImageColor3 = Color3.new(0, 0, 0),
	},
	TextLabel = {
		BackgroundTransparency = 1,
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	ImageLabel = { BackgroundTransparency = 1, BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
	ImageButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		AutoButtonColor = false,
	},
	CanvasGroup = { BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 },
}
end
a["Core/CreatorEvents"]=function()
local e, f, g, h = newproxy(false), newproxy(false), newproxy(false), {}
local i = function(i)
	local j = h[i]
	if j then
		return j
	end
	local k = { _Marker = e, _Name = i }
	h[i] = k
	return k
end
return {
	EventMarker = e,
	ThemeTag = f,
	RefKey = g,
	OnEvent = i,
	Activated = i("Activated"),
	MouseButton1Click = i("MouseButton1Click"),
	MouseButton1Down = i("MouseButton1Down"),
	MouseButton1Up = i("MouseButton1Up"),
	MouseButton2Click = i("MouseButton2Click"),
	MouseEnter = i("MouseEnter"),
	MouseLeave = i("MouseLeave"),
	InputBegan = i("InputBegan"),
	InputEnded = i("InputEnded"),
	InputChanged = i("InputChanged"),
	FocusLost = i("FocusLost"),
	Focused = i("Focused"),
	Changed = i("Changed"),
}
end
a["Core/FileSystem"]=function()
local e, f, g, h, i, j, k = d("Core/FileSystemVirtual"), d("Core/FileSystemNative"), d("Core/FileSystemWarn"), "sea", ".tmp", ".bak", {}
local l = f.IsAvailable() and f.Probe(h)
local m = e.New(h, not l)
local n, o = function()
	return l and not m:IsEnabled()
end, function(n, o)
	return string.sub(n, 1, #o) == o
end
local p = function(p)
	if not p or p == "" then
		return false
	end
	if string.find(p, "\0") then
		return false
	end
	local q = string.gsub(p, "\\", "/")
	if string.match(q, "^%a:") or string.sub(q, 1, 1) == "/" then
		return false
	end
	for r in string.gmatch(q, "[^/]+") do
		if r == ".." then
			return false
		end
	end
	if q ~= h and not o(q, h .. "/") then
		return false
	end
	return true
end
local q = function(q)
	if p(q) then
		return string.gsub(q, "\\", "/")
	end
	g.Warn("[SeaHub:FileSystem] Blocked unsafe path: " .. tostring(q))
	return nil
end
function k.IsAvailable()
	return l or m:IsEnabled()
end
function k.IsVirtual()
	return m:IsEnabled() and not l
end
function k.GetCapabilities()
	return f.GetCapabilities()
end
function k.SetVirtualEnabled(r)
	m:SetEnabled(r)
end
function k.ResetVirtual()
	m:Reset()
end
function k.IsFile(r)
	local s = q(r)
	if not s then
		return false
	end
	if n() then
		return f.IsFile(s)
	end
	if m:IsEnabled() then
		return m:IsFile(s)
	end
	return false
end
function k.IsFolder(r)
	local s = q(r)
	if not s then
		return false
	end
	if n() then
		return f.IsFolder(s)
	end
	if m:IsEnabled() then
		return m:IsFolder(s)
	end
	return false
end
function k.ReadFileStatus(r)
	local s = q(r)
	if not s then
		return nil, "blocked"
	end
	if n() then
		local t, u, v = f.Read(s)
		if t then
			return u, "ok"
		end
		return nil, v == "error" and "corrupt" or v
	end
	if m:IsEnabled() then
		local t = m:ReadFile(s)
		if type(t) == "string" then
			return t, "ok"
		end
		return nil, "missing"
	end
	return nil, "unsupported"
end
function k.ReadFile(r)
	local s = k.ReadFileStatus(r)
	return s
end
local r, s =
	function(r, s)
		if n() then
			local t = f.Write(r, s)
			return t
		end
		if m:IsEnabled() then
			return m:WriteFile(r, s)
		end
		return false
	end, function(r)
		if n() then
			return f.DeleteFile(r)
		end
		if m:IsEnabled() then
			return m:DeleteFile(r)
		end
		return false
	end
function k.WriteFile(t, u)
	local v = q(t)
	if not v then
		return false
	end
	local w = v .. i
	if r(w, u) then
		local x, y = k.ReadFileStatus(w)
		if y == "ok" and x == u then
			local z = k.ReadFileStatus(v)
			if z ~= nil then
				r(v .. j, z)
			end
			local A, B, C = r(v, u), k.ReadFileStatus(v)
			s(w)
			return A and C == "ok" and B == u
		end
		s(w)
	end
	if not r(v, u) then
		return false
	end
	local x, y = k.ReadFileStatus(v)
	return y == "ok" and x == u
end
function k.AppendFile(t, u)
	local v = q(t)
	if not v then
		return false
	end
	local w = k.ReadFile(v) or ""
	return k.WriteFile(v, w .. u)
end
function k.MakeFolder(t)
	local u = q(t)
	if not u then
		return false
	end
	if k.IsFolder(u) then
		return true
	end
	if k.IsFile(u) then
		g.Warn(([[[SeaHub:FileSystem] Cannot create folder; a file already exists at `%s`.]]):format(u))
		return false
	end
	if n() then
		return f.MakeFolder(u)
	end
	if m:IsEnabled() then
		return m:MakeFolder(u)
	end
	return false
end
function k.EnsurePath(t)
	local u = q(t)
	if not u then
		return false
	end
	if k.IsFolder(u) then
		return true
	end
	local v = ""
	for w in string.gmatch(u, "[^/\\]+") do
		v = (v == "" and { w } or { (v .. "/" .. w) })[1]
		if k.IsFile(v) then
			g.Warn(([[[SeaHub:FileSystem] EnsurePath blocked: `%s` exists as a file, not a folder.]]):format(v))
			return false
		end
		if not k.IsFolder(v) then
			if not k.MakeFolder(v) then
				return false
			end
		end
	end
	return true
end
function k.DeleteFile(t)
	local u = q(t)
	if not u then
		return false
	end
	return s(u)
end
function k.DeleteFolder(t)
	local u = q(t)
	if not u then
		return false
	end
	if n() then
		return f.DeleteFolder(u)
	end
	if m:IsEnabled() then
		return m:DeleteFolder(u)
	end
	return false
end
function k.ListFilesStatus(t)
	local u = q(t)
	if not u then
		return {}, "blocked"
	end
	if n() then
		local v, w, x = f.List(u)
		return w, x
	end
	if m:IsEnabled() then
		return m:ListFiles(u), "ok"
	end
	return {}, "unsupported"
end
function k.ListFiles(t)
	local u = k.ListFilesStatus(t)
	return u
end
return table.freeze(k)
end
a["Core/FileSystemNative"]=function()
local e, f, g, h, i, j, k, l, m, n, o =
	d("Core/FileSystemWarn"), {}, isfile, isfolder, readfile, writefile, appendfile, makefolder, delfolder, delfile, listfiles
local p, q, r =
	j ~= nil,
	{
		isfile = g ~= nil,
		isfolder = h ~= nil,
		readfile = i ~= nil,
		writefile = j ~= nil,
		appendfile = k ~= nil,
		makefolder = l ~= nil,
		delfolder = m ~= nil,
		delfile = n ~= nil,
		listfiles = o ~= nil,
	},
	{}
local s = function(s)
	if r[s] then
		return
	end
	r[s] = true
	e.Warn(([[[SeaHub:FileSystem] executor lacks `%s`; some per-account operations may be degraded.]]):format(s))
end
function f.IsAvailable()
	return p
end
function f.GetCapabilities()
	return table.clone(q)
end
function f.Read(t)
	if i then
		local u, v = pcall(i, t)
		if u then
			if type(v) == "string" then
				return true, v, "ok"
			end
			return false, nil, "missing"
		end
		if f.IsFile(t) then
			return false, nil, "error"
		end
		return false, nil, "missing"
	end
	s("readfile")
	return false, nil, "unsupported"
end
function f.Write(t, u)
	if not j then
		s("writefile")
		return false, "unsupported"
	end
	local v = pcall(j, t, u)
	return v, v and "ok" or "error"
end
function f.Append(t, u)
	if k then
		local v = pcall(k, t, u)
		return v, v and "ok" or "error"
	end
	local v, w = f.Read(t)
	return f.Write(t, (w or "") .. u)
end
function f.IsFile(t)
	if g then
		local u, v = pcall(g, t)
		return u and v == true
	end
	if i then
		local u, v = pcall(i, t)
		return u and type(v) == "string"
	end
	s("isfile")
	return false
end
function f.IsFolder(t)
	if h then
		local u, v = pcall(h, t)
		return u and v == true
	end
	if o then
		local u, v = pcall(o, t)
		return u and type(v) == "table"
	end
	s("isfolder")
	return false
end
function f.MakeFolder(t)
	if l then
		local u = pcall(l, t)
		return u
	end
	s("makefolder")
	return false
end
function f.DeleteFile(t)
	if n then
		local u = pcall(n, t)
		return u
	end
	s("delfile")
	return false
end
function f.DeleteFolder(t)
	if m then
		local u = pcall(m, t)
		return u
	end
	s("delfolder")
	return false
end
function f.List(t)
	if not o then
		s("listfiles")
		return false, {}, "unsupported"
	end
	local u, v = pcall(o, t)
	if u and type(v) == "table" then
		return true, v, "ok"
	end
	return false, {}, "error"
end
function f.Probe(t)
	if not p then
		return false
	end
	local u, v = t .. "/.fsprobe", "ok:" .. tostring(os.clock())
	if l then
		pcall(l, t)
	end
	local w = f.Write(u, v)
	if not w then
		return false
	end
	local x, y = f.Read(u)
	f.DeleteFile(u)
	return x == true and y == v
end
return table.freeze(f)
end
a["Core/FileSystemVirtual"]=function()
local e, f, g =
	{}, function(e, f)
		return string.sub(e, 1, #f) == f
	end, function(e)
		return string.match(e, "^(.*)/[^/]+$")
	end
function e.New(h, i)
	local j, k, l, m = {}, i == true, {}, { [h] = true }
	function j.IsEnabled(n)
		return k
	end
	function j.SetEnabled(n, o)
		k = o == true
		if k and not m[h] then
			m[h] = true
		end
	end
	function j.Reset(n)
		table.clear(l)
		table.clear(m)
		m[h] = true
	end
	function j.IsFile(n, o)
		return l[o] ~= nil
	end
	function j.IsFolder(n, o)
		return m[o] == true
	end
	function j.ReadFile(n, o)
		return l[o]
	end
	function j.EnsureFolder(n, o)
		local p = {}
		for q in string.gmatch(o, "[^/]+") do
			table.insert(p, q)
		end
		local q = ""
		for r, s in p do
			q = (q == "" and { s } or { (q .. "/" .. s) })[1]
			m[q] = true
		end
		return true
	end
	function j.WriteFile(n, o, p)
		local q = g(o)
		if q and not m[q] then
			n:EnsureFolder(q)
		end
		l[o] = p
		return true
	end
	function j.AppendFile(n, o, p)
		local q = l[o] or ""
		return n:WriteFile(o, q .. p)
	end
	function j.MakeFolder(n, o)
		if m[o] then
			return true
		end
		return n:EnsureFolder(o)
	end
	function j.DeleteFile(n, o)
		l[o] = nil
		return true
	end
	function j.DeleteFolder(n, o)
		if o == h then
			n:Reset()
			return true
		end
		local p = o .. "/"
		m[o] = nil
		for q in m do
			if f(q, p) then
				m[q] = nil
			end
		end
		for q in l do
			if f(q, p) then
				l[q] = nil
			end
		end
		return true
	end
	function j.ListFiles(n, o)
		if not m[o] then
			return {}
		end
		local p, q, r = o .. "/", {}, {}
		for s in m do
			if s ~= o and f(s, p) then
				local t = string.sub(s, #p + 1)
				local u = string.match(t, "^[^/]+")
				if u then
					local v = p .. u
					if not q[v] then
						q[v] = true
						table.insert(r, v)
					end
				end
			end
		end
		for s in l do
			if f(s, p) then
				local t = string.sub(s, #p + 1)
				local u = string.match(t, "^[^/]+")
				if u then
					local v = p .. u
					if not q[v] then
						q[v] = true
						table.insert(r, v)
					end
				end
			end
		end
		table.sort(r)
		return r
	end
	return table.freeze(j)
end
return table.freeze(e)
end
a["Core/FileSystemWarn"]=function()
local e = {}
local f = nil
function e.SetSink(g)
	f = g
end
function e.Warn(g)
	if f then
		f("WARN", g)
	end
end
return e
end
a["Core/LogFile"]=function()
local e, f = d("Core/FileSystem"), {}
f.__index = f
local g, h, i, j, k, l, m =
	"sea/logs", 262144, 5, 32, 1, function()
		return tostring(os.time()) .. "_" .. tostring(math.floor(os.clock() * 1000))
	end, function()
		return e.IsAvailable() and not e.IsVirtual()
	end
local n = function(n)
	local o = {}
	for p, q in e.ListFiles(n) do
		local r = string.gsub(q, "\\", "/")
		if string.find(r, "/SeaHub_", 1, true) then
			table.insert(o, r)
		end
	end
	table.sort(o)
	while #o >= i do
		e.DeleteFile(table.remove(o, 1))
	end
end
function f.New(o, p)
	local q = o or g
	if not m() or not e.EnsurePath(q) then
		return nil
	end
	n(q)
	local r = q .. "/SeaHub_" .. l() .. ".log"
	if not e.WriteFile(r, "") then
		return nil
	end
	return setmetatable({ Path = r, Size = 0, Buffer = {}, FlushQueued = false, Failed = false, OnFailure = p }, f)
end
function f._Fail(o)
	if o.Failed then
		return
	end
	o.Failed = true
	o.FlushQueued = false
	table.clear(o.Buffer)
	if o.OnFailure then
		o.OnFailure()
	end
end
function f.Flush(o)
	if o.Failed or #o.Buffer == 0 then
		return false
	end
	o.FlushQueued = false
	local p = table.concat(o.Buffer, "\n") .. "\n"
	if not e.AppendFile(o.Path, p) then
		o:_Fail()
		return false
	end
	o.Size = o.Size + #p
	table.clear(o.Buffer)
	return true
end
function f._QueueFlush(o)
	if o.FlushQueued then
		return
	end
	o.FlushQueued = true
	if task and type(task.delay) == "function" then
		task.delay(k, function()
			o:Flush()
		end)
	else
		o:Flush()
	end
end
function f.Write(o, p)
	if o.Failed then
		return false
	end
	local q = #table.concat(o.Buffer, "\n")
	if o.Size + q + #p + 1 > h then
		return true
	end
	table.insert(o.Buffer, p)
	if #o.Buffer >= j then
		return o:Flush()
	end
	o:_QueueFlush()
	return not o.Failed
end
function f.IsAvailable(o)
	return not o.Failed
end
function f.ClearBuffer(o)
	table.clear(o.Buffer)
end
function f.GetBuffer(o)
	return table.concat(o.Buffer, "\n")
end
return f
end
a["Core/LogMode"]=function()
local e, f, g =
	{}, { silent = true, file = true, console = true }, function(e)
		return string.match(e, "^%s*(.-)%s*$") or ""
	end
function e.Normalize(h, i)
	local j = (f[i] and { i } or { "silent" })[1]
	if type(h) ~= "string" then
		return j
	end
	local k = string.lower(g(h))
	return (f[k] and { k } or { j })[1]
end
function e.Resolve(h, i)
	return e.Normalize(h, i and "console" or "silent")
end
return table.freeze(e)
end
a["Core/LogSink"]=function()
local e = {}
e.__index = e
function e.New(f, g, h)
	return setmetatable({ Mode = f == "file" and h == nil and "silent" or f, Console = g, File = h }, e)
end
function e.GetMode(f)
	if f.Mode == "file" and (not f.File or not f.File:IsAvailable()) then
		f.Mode = "silent"
		f.File = nil
	end
	return f.Mode
end
function e.Emit(f, g, h)
	local i = f:GetMode()
	if i == "console" then
		f.Console(g, h)
	elseif i == "file" and f.File and not f.File:Write(h) then
		f.Mode = "silent"
		f.File = nil
	end
end
function e.SetFileSink(f, g)
	f.File = g
	f.Mode = "file"
end
function e.DisableFile(f)
	f.File = nil
	if f.Mode == "file" then
		f.Mode = "silent"
	end
end
return e
end
a["Core/Logger"]=function()
local e, f, g, h, i, j, k, l =
	d("Core/FileSystemWarn"), d("Core/LogSink"), d("Core/LogFile"), d("Core/LogMode"), {}, "SeaHub", "%Y-%m-%d %H:%M:%S", { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4 }
local m, n, o, p =
	l.WARN, nil, function()
		local m, n = pcall(function()
			local m = (getfenv)(0).getgenv
			return (type(m) == "function" and { m().LOG_MODE } or { nil })[1]
		end)
		return (m and { n } or { nil })[1]
	end, function()
		local m, n = pcall(function()
			return game:GetService("RunService"):IsStudio()
		end)
		return m and n == true
	end
local q = h.Resolve(o(), p())
n = (q == "file" and { (g.New(nil, nil)) } or { nil })[1]
local r = f.New(q, function(r, s)
	if l[r] and l[r] >= l.WARN then
		warn(s)
	else
		print(s)
	end
end, n)
local s = function(s)
	n = g.New(s, nil)
	if not n then
		r:DisableFile()
		return false
	end
	r:SetFileSink(n)
	return true
end
function i.SetLevel(t)
	m = l[t] or l.WARN
end
function i.GetLevel()
	for t, u in l do
		if u == m then
			return t
		end
	end
	return "WARN"
end
function i.GetMode()
	return r:GetMode()
end
function i.EnableFileLogging(t)
	if q ~= "file" then
		return false
	end
	if n then
		n:Flush()
	end
	return s(t)
end
function i.DisableFileLogging()
	if n then
		n:Flush()
	end
	n = nil
	r:DisableFile()
end
function i.Flush()
	return n ~= nil and n:Flush() == true
end
i.SaveLogs = i.Flush
function i.ClearBuffer()
	if n then
		n:ClearBuffer()
	end
end
function i.GetBuffer()
	return (n and { (n:GetBuffer()) } or { "" })[1]
end
local t, u =
	function()
		local t, u = pcall(os.date, k)
		return (t and u and { (tostring(u)) } or { (tostring(os.time())) })[1]
	end, function(...)
		local t = select("#", ...)
		local u = table.create(t)
		for v = 1, t do
			u[v] = tostring(select(v, ...))
		end
		return table.concat(u, " ")
	end
local v = function(v, w, ...)
	if m > w then
		return
	end
	local x = string.format("[%s] %s [%s] %s", j, t(), v, u(...))
	r:Emit(v, x)
end
function i.Debug(...)
	v("DEBUG", l.DEBUG, ...)
end
function i.Info(...)
	v("INFO", l.INFO, ...)
end
function i.Warn(...)
	v("WARN", l.WARN, ...)
end
function i.Error(...)
	v("ERROR", l.ERROR, ...)
end
e.SetSink(function(w, x)
	if w == "WARN" then
		i.Warn(x)
	else
		i.Info(x)
	end
end)
return table.freeze(i)
end
a["Core/ObjectPool"]=function()
local e, f, g, h = d("Core/Logger"), {}, {}, {}
h.__index = h
function f.New(i, j, k)
	local l
	l = setmetatable(
		{
			_ClassName = i,
			_Init = j,
			_Reset = (k and { k.Reset } or { nil })[1],
			_MaxSize = (k and k.MaxSize and { (math.max(0, k.MaxSize)) } or { math.huge })[1],
			_Pool = {},
			_InPool = {},
		},
		h
	)
	table.insert(g, l)
	return l
end
function f.DrainAll()
	for i, j in g do
		j:Drain()
	end
end
function h.Acquire(i)
	local j = i._Pool
	local k = table.remove(j)
	if not k then
		k = Instance.new(i._ClassName)
		if i._Init then
			i._Init(k)
		end
	else
		i._InPool[k] = nil
	end
	return k
end
function h.Release(i, j)
	if i._InPool[j] then
		e.Warn("[SeaHub:ObjectPool] double release:", i._ClassName)
		return
	end
	if i._Reset then
		i._Reset(j)
	end
	j.Parent = nil
	if #i._Pool >= i._MaxSize then
		j:Destroy()
		return
	end
	i._InPool[j] = true
	table.insert(i._Pool, j)
end
function h.Warm(i, j)
	for k = 1, j do
		if #i._Pool >= i._MaxSize then
			return
		end
		local l = Instance.new(i._ClassName)
		if i._Init then
			i._Init(l)
		end
		i._InPool[l] = true
		table.insert(i._Pool, l)
	end
end
function h.Drain(i)
	local j = i._Pool
	for k = #j, 1, -1 do
		j[k]:Destroy()
		i._InPool[j[k]] = nil
		j[k] = nil
	end
end
function h.Size(i)
	return #i._Pool
end
return table.freeze(f)
end
a["Core/Responsive"]=function()
local e, f = {}, d("Core/Scheduler")
e.Tier = "Normal"
e.ScaleFactor = 1
e.ViewportWidth = 800
e.ViewportHeight = 500
local g, h, i, j, k, l = 500, 900, 800, 0.5, 1.5, {}
function e.OnChanged(m)
	table.insert(l, m)
	return function()
		local n = table.find(l, m)
		if n then
			local o = #l
			if n ~= o then
				l[n] = l[o]
			end
			l[o] = nil
		end
	end
end
local m, n, o, p, q, r, s, t =
	function()
		for m, n in l do
			n()
		end
	end, false, {}, false, e.ViewportWidth, e.ViewportHeight, 0, function(m)
		if m < g then
			return "Compact"
		elseif m > h then
			return "Wide"
		end
		return "Normal"
	end
function e.Update(u, v)
	if n then
		return
	end
	n = true
	local w, x = t(u), math.clamp(u / i, j, k)
	local y = w ~= e.Tier or math.abs(x - e.ScaleFactor) > 0.001
	e.Tier = w
	e.ScaleFactor = x
	e.ViewportWidth = u
	e.ViewportHeight = v
	if y then
		m()
	end
	n = false
end
local u = function(u, v)
	q = u
	r = v
	if p then
		return
	end
	p = true
	local w = s
	f.DeferKeyed(o, function()
		if w ~= s then
			return
		end
		p = false
		e.Update(q, r)
	end, "High")
end
function e.Scale(v)
	return math.round(v * e.ScaleFactor)
end
local v
function e.Init(w)
	s = s + 1
	p = false
	if v then
		v:Disconnect()
		v = nil
	end
	v = w:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local x = w.AbsoluteSize
		u(x.X, x.Y)
	end)
	local x = w.AbsoluteSize
	if x.X > 0 and x.Y > 0 then
		e.Update(x.X, x.Y)
	end
end
function e.Destroy()
	s = s + 1
	p = false
	if v then
		v:Disconnect()
		v = nil
	end
	table.clear(l)
	e.Tier = "Normal"
	e.ScaleFactor = 1
	e.ViewportWidth = 800
	e.ViewportHeight = 500
end
return e
end
a["Core/SafeCall"]=function()
local aa, ab, ac = d("Core/Logger"), {}
function ab.SetErrorHandler(ad)
	ac = ad
end
function ab.Call(ad, ...)
	local ae = table.pack(pcall(ad, ...))
	local af = ae[1]
	if not af then
		local ag = tostring(ae[2])
		if ac then
			ac(ag)
		else
			aa.Error(ag)
		end
	end
	return table.unpack(ae, 1, ae.n)
end
function ab.Defer(ad, ...)
	local ae = table.pack(...)
	task.defer(function()
		ab.Call(ad, table.unpack(ae, 1, ae.n))
	end)
end
return table.freeze(ab)
end
a["Core/Scheduler"]=function()
local e, f, g, h, i, j, k, l, m, n =
	game:GetService("RunService"), d("Core/Logger"), {}, 0.004, function()
		return { Data = {}, Head = 1, Tail = 0 }
	end, function(e, f)
		e.Tail = e.Tail + 1
		e.Data[e.Tail] = f
	end, function(e, f)
		e.Head = e.Head - 1
		e.Data[e.Head] = f
	end, function(e)
		if e.Head > e.Tail then
			return nil
		end
		local f = e.Data[e.Head]
		e.Data[e.Head] = nil
		e.Head = e.Head + 1
		if e.Head > e.Tail then
			table.clear(e.Data)
			e.Head = 1
			e.Tail = 0
		end
		return f
	end, function(e)
		return math.max(0, e.Tail - e.Head + 1)
	end, function(e)
		table.clear(e.Data)
		e.Head = 1
		e.Tail = 0
	end
local o, p, q, r, s, t, u, v, w, x, y =
	{ High = i(), Normal = i(), Low = i() },
	{ "High", "Normal", "Low" },
	false,
	0,
	debug and debug.profilebegin,
	debug and debug.profileend,
	{ TotalQueued = 0, TotalExecuted = 0, TotalDropped = 0, OwnedDropped = 0, PeakQueueSize = 0, FramesActive = 0, LastFrameBudgetUsed = 0 },
	{},
	{},
	{}
setmetatable(x, { __mode = "k" })
local z = {}
setmetatable(z, { __mode = "k" })
local A = {}
setmetatable(A, { __mode = "k" })
function g.SetBudget(B)
	h = B
end
local B = function()
	local B = os.clock()
	u.FramesActive = u.FramesActive + 1
	if s then
		s("SeaHub:Scheduler")
	end
	for C, D in p do
		local E = o[D]
		while m(E) > 0 do
			if os.clock() - B >= h then
				u.LastFrameBudgetUsed = os.clock() - B
				if t then
					t()
				end
				return
			end
			local F = l(E)
			if F then
				local G, H = pcall(F)
				if not G then
					f.Warn("[SeaHub:Scheduler]", D, "task error:", tostring(H))
				end
			end
		end
	end
	u.LastFrameBudgetUsed = os.clock() - B
	if t then
		t()
	end
	if g.Pending() == 0 then
		r = r + 1
		if r >= 2 then
			g.Stop()
		end
	else
		r = 0
	end
end
local C = function()
	if q then
		return
	end
	r = 0
	q = true
	y = e.Heartbeat:Connect(B)
end
function g.Defer(D, E)
	local F = false
	local G, H =
		function()
			if F then
				return
			end
			u.TotalExecuted = u.TotalExecuted + 1
			D()
		end, E or "Normal"
	j(o[H], G)
	u.TotalQueued = u.TotalQueued + 1
	u.PeakQueueSize = math.max(u.PeakQueueSize, g.Pending())
	C()
	return {
		Cancel = function()
			if F then
				return
			end
			F = true
			u.TotalDropped = u.TotalDropped + 1
		end,
	}
end
function g.InvalidateOwner(D)
	assert(D ~= nil, "Scheduler.InvalidateOwner - missing Owner")
	A[D] = true
end
function g.IsOwnerAlive(D)
	return D ~= nil and A[D] ~= true
end
function g.DeferOwned(D, E, F)
	assert(D ~= nil, "Scheduler.DeferOwned - missing Owner")
	if A[D] then
		u.TotalDropped = u.TotalDropped + 1
		u.OwnedDropped = u.OwnedDropped + 1
		return { Cancel = function() end }
	end
	local G = false
	local H, I =
		function()
			if G then
				return
			end
			if A[D] then
				u.TotalDropped = u.TotalDropped + 1
				u.OwnedDropped = u.OwnedDropped + 1
				return
			end
			u.TotalExecuted = u.TotalExecuted + 1
			E()
		end, F or "Normal"
	j(o[I], H)
	u.TotalQueued = u.TotalQueued + 1
	u.PeakQueueSize = math.max(u.PeakQueueSize, g.Pending())
	C()
	return {
		Cancel = function()
			if G then
				return
			end
			G = true
			u.TotalDropped = u.TotalDropped + 1
		end,
	}
end
function g.DeferKeyed(D, E, F)
	local G = (x[D] or 0) + 1
	x[D] = G
	v[D] = { Callback = E, Gen = G }
	local H = function()
		local H = v[D]
		if not H or H.Gen ~= G then
			return false
		end
		v[D] = nil
		w[D] = nil
		u.TotalDropped = u.TotalDropped + 1
		return true
	end
	if w[D] then
		local I = false
		return {
			Cancel = function()
				if I then
					return
				end
				I = true
				H()
			end,
		}
	end
	local I = (z[D] or 0) + 1
	z[D] = I
	w[D] = I
	local J, K =
		g.Defer(function()
			if w[D] ~= I then
				return
			end
			local J = v[D]
			v[D] = nil
			w[D] = nil
			if J then
				J.Callback()
			end
		end, F), false
	return {
		Cancel = function()
			if K then
				return
			end
			K = true
			if H() then
				J.Cancel()
			end
		end,
	}
end
function g.DeferImmediate(D)
	local E = false
	local F = function()
		if E then
			return
		end
		u.TotalExecuted = u.TotalExecuted + 1
		D()
	end
	k(o.High, F)
	u.TotalQueued = u.TotalQueued + 1
	u.PeakQueueSize = math.max(u.PeakQueueSize, g.Pending())
	C()
	return {
		Cancel = function()
			if E then
				return
			end
			E = true
			u.TotalDropped = u.TotalDropped + 1
		end,
	}
end
function g.Stop()
	if y then
		y:Disconnect()
		y = nil
	end
	r = 0
	q = false
end
function g.Flush()
	for D, E in p do
		local F = o[E]
		while m(F) > 0 do
			local G = l(F)
			if G then
				local H, I = pcall(G)
				if not H then
					f.Warn("[SeaHub:Scheduler]", E, "flush error:", tostring(I))
				end
			end
		end
	end
	g.Stop()
end
function g.Clear()
	u.TotalDropped = u.TotalDropped + g.Pending()
	n(o.High)
	n(o.Normal)
	n(o.Low)
	table.clear(v)
	table.clear(w)
	table.clear(x)
	table.clear(z)
	table.clear(A)
	g.Stop()
end
function g.Pending()
	return m(o.High) + m(o.Normal) + m(o.Low)
end
function g.GetStats()
	return {
		TotalQueued = u.TotalQueued,
		TotalExecuted = u.TotalExecuted,
		TotalDropped = u.TotalDropped,
		OwnedDropped = u.OwnedDropped,
		PeakQueueSize = u.PeakQueueSize,
		FramesActive = u.FramesActive,
		LastFrameBudgetUsed = u.LastFrameBudgetUsed,
		Pending = g.Pending(),
	}
end
function g.ResetStats()
	u.TotalQueued = 0
	u.TotalExecuted = 0
	u.TotalDropped = 0
	u.OwnedDropped = 0
	u.PeakQueueSize = 0
	u.FramesActive = 0
	u.LastFrameBudgetUsed = 0
end
return table.freeze(g)
end
a["Core/SignalManager"]=function()
local e, f, g, h, i, j = d("Core/Logger"), {}, 0, 0, {}, {}
j.__index = j
function j.Connect(k, l, m)
	local n = l:Connect(m)
	table.insert(k._Connections, n)
	g = g + 1
	return n
end
function j.Once(k, l, m)
	local n = l:Once(m)
	table.insert(k._Connections, n)
	g = g + 1
	return n
end
function j.Defer(k, l)
	if k._Destroyed then
		local m, n = pcall(l)
		if not m then
			e.Warn("[SeaHub:SignalManager] deferred disposer error:", tostring(n))
		end
		return
	end
	table.insert(k._Disposers, l)
end
function j.DisconnectAll(k)
	local l = k._Connections
	g = math.max(0, g - #l)
	for m = #l, 1, -1 do
		l[m]:Disconnect()
		l[m] = nil
	end
end
function j.Destroy(k)
	if k._Destroyed then
		return
	end
	k._Destroyed = true
	k:DisconnectAll()
	local l = k._Disposers
	for m = #l, 1, -1 do
		local n = l[m]
		local o, p = pcall(n)
		if not o then
			e.Warn("[SeaHub:SignalManager] deferred disposer error:", tostring(p))
		end
		l[m] = nil
	end
	i[k] = nil
	h = math.max(0, h - 1)
end
function j.Count(k)
	return #k._Connections
end
function f.CreateScope()
	local k = setmetatable({ _Connections = {}, _Disposers = {}, _Destroyed = false }, j)
	i[k] = true
	h = h + 1
	return k
end
function f.DestroyAll()
	for k in i do
		k:Destroy()
	end
	table.clear(i)
	g = 0
	h = 0
end
function f.GetStats()
	local k = 0
	for l in i do
		k = k + 1
	end
	return { TotalConnections = g, TotalScopes = h, ActiveScopeCount = k }
end
function f.DiagnoseLeaks()
	local k = {}
	for l in i do
		local m = l:Count()
		if m > 0 then
			table.insert(k, { ScopeId = tostring(l), ConnectionCount = m })
		end
	end
	return k
end
return table.freeze(f)
end
a["Core/Spring"]=function()
local e = {}
e.__index = e
local f, g, h, i, j, k, l = 500, 30, 1, 0.01, 0.05, 0.25, 1.6666666666666665E-2
function e.new(m, n)
	local o = n or {}
	return setmetatable(
		{ Value = m, Target = m, Velocity = 0, Stiffness = o.stiffness or f, Damping = o.damping or g, Mass = o.mass
			or h },
		e
	)
end
function e.SetTarget(m, n)
	m.Target = n
end
function e.Set(m, n)
	m.Value = n
	m.Target = n
	m.Velocity = 0
end
function e.Get(m)
	return m.Value
end
function e.Step(m, n)
	local o = math.min(math.max(n, 0), k)
	local p = math.max(1, math.ceil(o / l))
	local q = o / p
	for r = 1, p do
		local s = m.Value - m.Target
		local t, u = -m.Stiffness * s, -m.Damping * m.Velocity
		local v = (t + u) / m.Mass
		m.Velocity = m.Velocity + v * q
		m.Value = m.Value + m.Velocity * q
	end
	local r = math.abs(m.Value - m.Target) < i and math.abs(m.Velocity) < j
	if r then
		m.Value = m.Target
		m.Velocity = 0
	end
	return m.Value, r
end
function e.Map(m, n, o)
	return n + (o - n) * m
end
return e
end
a["Core/TabContentScroll"]=function()
local e, f, g, h = d("Core/CalmFlush"), false, 0, {}
function h.NotifyPulse()
	if not f then
		f = true
		e.SetScrollSuppressed(true)
	end
	g = g + 1
	local i = g
	task.defer(function()
		if i ~= g then
			return
		end
		f = false
		e.SetScrollSuppressed(false)
	end)
end
function h.IsSuppressing()
	return f
end
return table.freeze(h)
end
a["Core/ThemeRegistry"]=function()
local e, f, g, h, i, j, k, l, m, n, o, p, q, r, s =
	d("Core/Logger"), d("Core/Scheduler"), debug and debug.profilebegin, debug and debug.profileend, {}, 120, 40, {}, {}, {}, 0, {}, {}
function i.AddObject(t, u)
	l[t] = u
	if m[t] == nil then
		m[t] = t.Destroying:Connect(function()
			local v = m[t]
			if v then
				v:Disconnect()
				m[t] = nil
			end
			l[t] = nil
		end)
	end
end
function i.OverrideTag(t, u)
	if l[t] then
		l[t] = u
	else
		e.Warn("OverrideTag: Object is not registered in the theme registry")
	end
end
function i.RemoveObject(t)
	l[t] = nil
	local u = m[t]
	if u then
		u:Disconnect()
		m[t] = nil
	end
end
function i.SetData(t, u)
	r = t
	s = u
	local v = i.Update()
	i.FlushChangedCallbacks(v)
end
function i.GetProperty(t)
	if r and r[t] ~= nil then
		return r[t]
	end
	if s and s[t] ~= nil then
		return s[t]
	end
	e.Warn("Unknown theme token:", t)
	return nil
end
function i.GetValue(t)
	return function()
		if r and r[t] ~= nil then
			return r[t]
		end
		if s and s[t] ~= nil then
			return s[t]
		end
		return nil
	end
end
function i.HasCurrentTheme()
	return r ~= nil
end
function i.OnChanged(t)
	table.insert(n, t)
	return function()
		local u = table.find(n, t)
		if u then
			local v = #n
			if u ~= v then
				n[u] = n[v]
			end
			n[v] = nil
		end
	end
end
function i.Update()
	if not r then
		return o
	end
	o = o + 1
	local t = o
	f.DeferKeyed(p, function()
		if g then
			g("SeaHub:ThemeCollect")
		end
		if t ~= o then
			if h then
				h()
			end
			return
		end
		local u, v = {}, {}
		for w, x in l do
			if w.Parent then
				table.insert(v, w)
				for y, z in x do
					if u[z] == nil then
						local A = i.GetProperty(z)
						u[z] = (A ~= nil and { A } or { false })[1]
					end
				end
			end
		end
		if h then
			h()
		end
		local w, x = 1, #v
		local function y()
			if g then
				g("SeaHub:ThemeBatch")
			end
			if t ~= o then
				if h then
					h()
				end
				return
			end
			local z = math.min(w + j - 1, x)
			for A = w, z do
				local B = v[A]
				local C = l[B]
				if C and B.Parent then
					for D, E in C do
						local F = u[E]
						if F ~= false then
							(B)[D] = F
						end
					end
				end
			end
			w = z + 1
			if w <= x then
				f.Defer(y, "High")
			end
			if h then
				h()
			end
		end
		if x > 0 then
			y()
		end
	end, "High")
	return t
end
function i.FlushChangedCallbacks(t)
	f.DeferKeyed(q, function()
		if t ~= o then
			return
		end
		local u, v = table.clone(n), 1
		local w = #u
		local function x()
			if t ~= o then
				return
			end
			local y = math.min(v + k - 1, w)
			for z = v, y do
				local A, B = pcall(u[z])
				if not A then
					e.Warn("ThemeChanged callback error:", tostring(B))
				end
			end
			v = y + 1
			if v <= w then
				f.Defer(x, "High")
			end
		end
		if w > 0 then
			x()
		end
	end, "High")
end
function i.GetRegistrySize()
	local t = 0
	for u in l do
		t = t + 1
	end
	return t
end
function i.Disconnect()
	for t, u in m do
		u:Disconnect()
		m[t] = nil
	end
	table.clear(l)
	table.clear(m)
	table.clear(n)
end
return table.freeze(i)
end
a["Core/ThreadIdentity"]=function()
local aa, ab, ac, ad =
	{}, 8, function() end, function(aa)
		local ab, ac = pcall(function()
			return rawget(_G, aa)
		end)
		if ab and type(ac) == "function" then
			return ac
		end
		local ad, ae = pcall(function()
			return (getfenv)(0)[aa]
		end)
		if ad and type(ae) == "function" then
			return ae
		end
		return nil
	end
local ae = function()
	local ae, af =
		ad("getthreadidentity") or ad("get_thread_identity"), ad("setthreadidentity") or ad("set_thread_identity")
	return ae, af
end
function aa.Elevate(af)
	local ag, ah = ae()
	if not ah then
		return ac
	end
	local ai, aj = af or ab
	if ag then
		local ak, al = pcall(ag)
		if ak and type(al) == "number" then
			aj = al
		end
	end
	local ak = pcall(ah, ai)
	if not ak then
		return ac
	end
	local al = false
	return function()
		if al then
			return
		end
		al = true
		if aj then
			pcall(ah, aj)
		end
	end
end
function aa.Current()
	local af = (ae())
	if not af then
		return 0
	end
	local ag, ah = pcall(af)
	return (ag and type(ah) == "number" and { ah } or { 0 })[1]
end
function aa.IsSupported()
	local af, ag = ae()
	return ag ~= nil
end
return table.freeze(aa)
end
a["Core/Types"]=function()
return table.freeze({})
end
a["Core/WindowDrag"]=function()
local e, f, g, h, i, j, k = game:GetService("UserInputService"), d("Core/CalmFlush"), 0, 0, 0.16, 6, {}
function k.SuppressClicks(l)
	local m = os.clock() + (l or i)
	if m > h then
		h = m
	end
end
function k.Begin()
	if g == 0 then
		f.SetDragActive(true)
	end
	g = g + 1
	k.SuppressClicks()
end
function k.End()
	if g > 0 then
		g = g - 1
	end
	if g == 0 then
		f.SetDragActive(false)
		k.SuppressClicks()
	end
end
function k.IsActive()
	return g > 0
end
function k.ShouldSuppressClick()
	return g > 0 or os.clock() < h
end
function k.GetPressPosition()
	return e:GetMouseLocation()
end
function k.ShouldSuppressClickFrom(l)
	if k.ShouldSuppressClick() then
		return true
	end
	if not l then
		return false
	end
	local m = e:GetMouseLocation() - l
	if m.Magnitude > j then
		k.SuppressClicks()
		return true
	end
	return false
end
return table.freeze(k)
end
a["Core/WindowOptions"]=function()
local aa, ab = d("Core/Logger"), {}
ab.Default = {
	DragFpsCap = 60,
	UseDragSkeleton = true,
	UseFullVisibilityAnimation = false,
	UseClassicToggle = true,
	SnapshotApplyCallbacks = false,
}
local ac = function(ac, ad, ae)
	local af = ac[ad]
	if af ~= nil then
		return af
	end
	return ae
end
local ad, ae =
	function(ad, ae)
		local af = ac(ad, "DragFpsCap", ae)
		local ag = tonumber(af)
		if ag == nil then
			return ae
		end
		return math.max(0, ag)
	end, function(ad, ae, af)
		local ag = ac(ad, ae, af)
		if type(ag) ~= "boolean" then
			return af
		end
		return ag
	end
function ab.Clone(af)
	local ag = {}
	for ah, ai in af do
		ag[ah] = ai
	end
	return ag
end
function ab.ResolveWindow(af, ag)
	return {
		DragFpsCap = ad(af, ag.DragFpsCap),
		UseDragSkeleton = ae(af, "UseDragSkeleton", ag.UseDragSkeleton),
		UseFullVisibilityAnimation = ae(af, "UseFullVisibilityAnimation", ag.UseFullVisibilityAnimation),
		UseClassicToggle = ae(af, "UseClassicToggle", ag.UseClassicToggle ~= false),
		SnapshotApplyCallbacks = ae(af, "SnapshotApplyCallbacks", ag.SnapshotApplyCallbacks),
	}
end
function ab.Set(af, ag, ah, ai)
	if ag == "DragFpsCap" then
		local aj = tonumber(ah)
		if aj == nil then
			aa.Warn("SetOption: DragFpsCap must be a number")
			return false
		end
		ah = math.max(0, aj)
	elseif
		ag == "UseDragSkeleton"
		or ag == "UseFullVisibilityAnimation"
		or ag == "UseClassicToggle"
		or ag == "SnapshotApplyCallbacks"
	then
		if type(ah) ~= "boolean" then
			aa.Warn("SetOption:", ag, "must be a boolean")
			return false
		end
	else
		aa.Warn("SetOption: unknown option key", tostring(ag))
		return false
	end
	af[ag] = ah
	if not ai then
		return true
	end
	if ag == "DragFpsCap" and ai.SetDragFpsCap then
		ai:SetDragFpsCap(ah)
	elseif ag == "UseDragSkeleton" and ai.SetUseDragSkeleton then
		ai:SetUseDragSkeleton(ah)
	elseif ag == "UseFullVisibilityAnimation" and ai.SetUseFullVisibilityAnimation then
		ai:SetUseFullVisibilityAnimation(ah)
	elseif ag == "UseClassicToggle" and ai.SetUseClassicToggle then
		ai:SetUseClassicToggle(ah)
	elseif ag == "SnapshotApplyCallbacks" and ai.SetSnapshotApplyCallbacks then
		ai:SetSnapshotApplyCallbacks(ah)
	end
	return true
end
return table.freeze(ab)
end
a["Debug/AnimationControls"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af = aa.Creator, aa.Animator, aa.AnimTokens, d("Debug/AnimationViewport"), d("Debug/AnimationSeekBar")
local ag, ah, ai, aj, ak, al, am, an, ao, ap =
	ab.New,
	{},
	"rbxassetid://10734961526",
	"rbxassetid://10734919336",
	"rbxassetid://10734923549",
	"rbxassetid://10734961809",
	176,
	{
		{ Label = "0.25x", Value = 0.25 },
		{ Label = "0.5x", Value = 0.5 },
		{ Label = "1x", Value = 1 },
		{ Label = "1.5x", Value = 1.5 },
		{ Label = "2x", Value = 2 },
	},
	1,
	function(ag, ah)
		local ai = ab.GetThemeProperty(ag)
		return (ai ~= nil and { ai } or { ah })[1]
	end
local aq, ar =
	function(aq, ar, as, at)
		local e = ag("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = as, Size = (at and { (UDim2.new(1, 0, 0, 0)) } or { (UDim2.new(1, 0, 0, ar)) })[1], AutomaticSize = (at and { Enum.AutomaticSize.Y } or { Enum.AutomaticSize.None })[1] }, { ag("UIPadding", { PaddingLeft = ap("PaddingElement", UDim.new(0, 14)), PaddingRight = ap("PaddingElement", UDim.new(0, 14)), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), [ab.ThemeTag] = { PaddingLeft = "PaddingElement", PaddingRight = "PaddingElement" } }) })
		e.Parent = aq
		return e
	end, function(aq, ar, as)
		local at, e = ag("ImageLabel", { Name = "Icon", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 18), Image = ar, ImageColor3 = ap("Text", Color3.fromRGB(240, 240, 240)), ZIndex = 2, [ab.ThemeTag] = { ImageColor3 = "Text" } }), ag("TextButton", { Name = "Hit", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 3 })
		local f = ag("Frame", { Name = aq, BackgroundColor3 = ap("BackgroundSurface", Color3.fromRGB(22, 22, 22)), BorderSizePixel = 0, Size = UDim2.new(0.32, 0, 1, 0), LayoutOrder = as, [ab.ThemeTag] = { BackgroundColor3 = "BackgroundSurface" } }, { ag("UICorner", { CornerRadius = ap("CornerRadiusSection", UDim.new(0, 12)), [ab.ThemeTag] = { CornerRadius = "CornerRadiusSection" } }), ag("UIStroke", { Color = ap("StrokeColor", Color3.fromRGB(240, 240, 240)), Transparency = ap("StrokeTransparency", 0.9), [ab.ThemeTag] = { Color = "StrokeColor", Transparency = "StrokeTransparency" } }), at, e })
		return e, at, f
	end
function ah.New(as)
	local at = as.Modal
	local e = at:AddSection("Animation")
	local f = e:AddInput("Animation ID", {
		Placeholder = "rbxassetid://0",
		Tooltip = "Paste an animation id and press Enter to load + play it.",
		Callback = function(f)
			if as.OnSubmitId and type(f) == "string" and f ~= "" then
				as.OnSubmitId(f)
			end
		end,
	})
	e:AddDropdown("Speed", {
		Options = an,
		Default = { ao },
		ShowSearch = false,
		Tooltip = "Playback speed multiplier.",
		Callback = function(g)
			local h = (type(g) == "table" and { g[1] } or { g })[1]
			if as.OnSpeed and type(h) == "number" then
				as.OnSpeed(h)
			end
		end,
	})
	local g = at:AddSection("Preview")
	local h = aq(g.Container, am + 20, 1, false)
	local i, j = ae.New({ Parent = h, Size = UDim2.new(1, 0, 1, 0) }), at:AddSection("Timeline")
	local k = aq(j.Container, 0, 1, true)
	ag(
		"UIListLayout",
		{
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = ap("GapInline", UDim.new(0, 8)),
		}
	).Parent =
		k
	local l = af.New({ Parent = k, Height = 22 })
	l.Root.LayoutOrder = 1
	local m, n, o, p =
		ag(
			"Frame",
			{ Name = "Transport", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 2 },
			{
				ag(
					"UIListLayout",
					{
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = ap("GapInline", UDim.new(0, 6)),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}
				),
			}
		),
		ar("Back", ai, 1)
	local q, r, s = ar("PlayStop", aj, 2)
	local t, u, v = ar("Forward", al, 3)
	p.Parent = m
	s.Parent = m
	v.Parent = m
	m.Parent = k
	local w = s:FindFirstChildOfClass("UIStroke")
	local x = function(x)
		r.Image = (x and { ak } or { aj })[1]
		ac.Tween(
			r,
			{
				ImageColor3 = (x and { (ap("Accent", Color3.fromRGB(255, 185, 255))) } or {
					(ap("Text", Color3.fromRGB(240, 240, 240))),
				})[1],
			},
			ad.Preset.Fade
		)
		if w then
			ac.Tween(w, { Transparency = x and 0.4 or ap("StrokeTransparency", 0.9) }, ad.Preset.Fade)
		end
	end
	local y =
		{ Viewport = i, Scrubber = l, IdInput = f, PlayButton = q, PlayIcon = r, BackButton = n, ForwardButton = t, SetPlayingIcon = x }
	function y.Destroy()
		l:Destroy()
		i:Destroy()
	end
	return y
end
return ah
end
a["Debug/AnimationDragDrop"]=function()
local aa = d("Core/SafeCall")
local ab, ac, ad, ae, af, ag, ah, ai, aj =
	{}, {}, 0, function(ab, ac)
		if not ab.Accepts then
			return true
		end
		local ad, ae = aa.Call(ab.Accepts, ac)
		return ad and ae == true
	end
local ak = function(ak)
	local al = af
	if not al then
		return nil, nil
	end
	for am, an in ac do
		local ao, ap = aa.Call(an.Contains, ak)
		if ao and ap == true and ae(an, al) then
			return am, an
		end
	end
	return nil, nil
end
local al, am =
	function(al)
		local am = ak(al)
		if am == aj then
			return
		end
		if aj and ac[aj] and ac[aj].OnHoverChanged then
			aa.Call(ac[aj].OnHoverChanged, false)
		end
		if am and ac[am] and ac[am].OnHoverChanged then
			aa.Call(ac[am].OnHoverChanged, true)
		end
		aj = am
	end, function()
		if aj and ac[aj] and ac[aj].OnHoverChanged then
			aa.Call(ac[aj].OnHoverChanged, false)
		end
		aj = nil
		af = nil
		ag = nil
		ah = nil
		ai = nil
	end
function ab.RegisterTarget(an)
	ad = ad + 1
	local ao = ad
	ac[ao] = an
	return function()
		if aj == ao then
			aj = nil
		end
		ac[ao] = nil
	end
end
function ab.Begin(an, ao)
	if ag then
		return nil
	end
	af = an
	ah = ao and ao.OnMove or nil
	ai = ao and ao.OnRelease or nil
	local ap
	ap = {
		Update = function(aq)
			if ag ~= ap then
				return
			end
			al(aq)
			if ah then
				aa.Call(ah, aq)
			end
		end,
		Drop = function(aq)
			if ag ~= ap then
				return false
			end
			local ar, as = ak(aq)
			local at, e, f = af, ai, false
			if as and at then
				aa.Call(as.OnDrop, at, aq)
				f = true
			end
			am()
			if e then
				aa.Call(e, f, aq)
			end
			return f
		end,
		Cancel = function()
			if ag ~= ap then
				return
			end
			local aq = ai
			am()
			if aq then
				aa.Call(aq, false, nil)
			end
		end,
		IsActive = function()
			return ag == ap
		end,
	}
	ag = ap
	return ap
end
function ab.IsDragging()
	return ag ~= nil
end
function ab.GetActivePayload()
	return af
end
return ab
end
a["Debug/AnimationLogger"]=function()
local aa, ab = game:GetService("UserInputService"), d("Core/Common")
local ac, ad, ae, af, ag = ab.SignalManager, d("Debug/AnimationLoggerPanel"), 380, 320, {}
function ag.New(ah, ai)
	ai = (type(ai) == "table" and { ai } or { {} })[1]
	local aj, ak, al, am =
		(type(ai.Title) == "string" and ai.Title ~= "" and { ai.Title } or { "Animation Logger" })[1], { Modal = nil }
	local an = function()
		if am then
			am:Destroy()
			am = nil
		end
	end
	local ao = function()
		an()
		am = ac.CreateScope()
		am:Connect(aa.InputBegan, function(ao, ap)
			if ap or not al or not ak.Modal or not ak.Modal:IsOpen() then
				return
			end
			if ao.KeyCode == Enum.KeyCode.Q then
				al:CycleBy(-1)
			elseif ao.KeyCode == Enum.KeyCode.E then
				al:CycleBy(1)
			end
		end)
	end
	ak.Modal = ah:Modal({
		Title = aj,
		Width = tonumber(ai.Width) or ae,
		Height = tonumber(ai.Height) or af,
		Draggable = true,
		Resizable = ai.Resizable == nil and true or ai.Resizable == true,
		MinWidth = 300,
		MinHeight = 260,
		MaxWidth = 720,
		MaxHeight = 600,
		AllowStacked = true,
		AllowOverlayDismiss = false,
		ShowCloseButton = ai.ShowCloseButton ~= false,
		AutoOpen = false,
		OnClose = function(ap)
			an()
			if type(ai.OnClose) == "function" then
				ai.OnClose(ap)
			end
		end,
		Build = function(ap)
			al = ad.New({
				Modal = ap,
				Categories = ai.Categories,
				MaxPerCategory = ai.MaxPerCategory,
				AutoScroll = ai.AutoScroll,
				OnEntryActivated = ai.OnEntryActivated,
				OnEntryDragged = ai.OnEntryDragged,
				OnNotify = function(aq)
					if ah.Notify then
						ah:Notify(aq)
					end
				end,
			})
		end,
	})
	if not ak.Modal then
		return ak
	end
	function ak.Open(ap)
		if not ap.Modal then
			return false
		end
		local aq = ap.Modal:Open()
		if aq then
			ao()
		end
		return aq
	end
	function ak.Close(ap, aq)
		if ap.Modal then
			ap.Modal:Close(aq)
		end
	end
	function ak.IsOpen(ap)
		return ap.Modal ~= nil and ap.Modal:IsOpen()
	end
	function ak.SetTitle(ap, aq)
		if ap.Modal then
			ap.Modal:SetTitle(aq)
		end
	end
	function ak.Destroy(ap, aq)
		an()
		if al then
			al:Destroy()
			al = nil
		end
		if ap.Modal then
			ap.Modal:Destroy(aq)
		end
	end
	function ak.AddEntry(ap, aq)
		return al and al:AddEntry(aq)
	end
	function ak.AddAnimation(ap, aq, ar)
		return al and al:AddAnimation(aq, ar)
	end
	function ak.AddKeyframe(ap, aq, ar)
		return al and al:AddKeyframe(aq, ar)
	end
	function ak.AddTelemetry(ap, aq, ar)
		return al and al:AddTelemetry(aq, ar)
	end
	function ak.AddMissing(ap, aq, ar)
		return al and al:AddMissing(aq, ar)
	end
	function ak.Clear(ap, aq)
		if al then
			al:Clear(aq)
		end
	end
	function ak.SetCategory(ap, aq)
		if al then
			al:SetCategory(aq)
		end
	end
	function ak.Blacklist(ap, aq)
		if al then
			al:Blacklist(aq)
		end
	end
	function ak.Unblacklist(ap, aq)
		if al then
			al:Unblacklist(aq)
		end
	end
	function ak.UndoBlacklist(ap)
		return al and al:UndoBlacklist()
	end
	function ak.Categories(ap)
		return (al and { (al:Categories()) } or { {} })[1]
	end
	if not (ai.AutoOpen == false) then
		ak:Open()
	end
	return ak
end
return table.freeze(ag)
end
a["Debug/AnimationLoggerEntry"]=function()
local aa, ab = game:GetService("UserInputService"), d("Core/Common")
local ac, ad, ae, af, ag, ah, ai = ab.Creator, ab.SignalManager, d("UI/Element"), d("Core/SafeCall"), d("Debug/AnimationDragDrop"), d("UI/Tooltip"), d("Debug/AnimationLoggerTypes")
local aj, ak, al, am, an =
	ac.New,
	{},
	"rbxassetid://12187365364",
	{
		Accent = { Bg = "Accent", Text = "AccentForeground", Transparency = 0.15 },
		Warning = { Bg = "VariantWarningBg", Text = "VariantWarningText", Transparency = 0.4 },
		Destructive = { Bg = "VariantDestructiveBg", Text = "VariantDestructiveText", Transparency = 0.4 },
		Success = { Bg = "VariantSuccessBg", Text = "VariantSuccessText", Transparency = 0.4 },
		Info = { Bg = "VariantInfoBg", Text = "VariantInfoText", Transparency = 0.4 },
		Muted = { Bg = "VariantMutedBg", Text = "VariantMutedText", Transparency = 0.5 },
	},
	function(aj, ak)
		local al = ac.GetThemeProperty(aj)
		return (al ~= nil and { al } or { ak })[1]
	end
local ao = function(ao)
	if ao then
		if ao == "TextWarning" or ao == "Warning" then
			return am.Warning
		elseif ao == "TextDestructive" or ao == "Destructive" then
			return am.Destructive
		elseif ao == "TextSuccess" or ao == "Success" then
			return am.Success
		elseif ao == "TextInfo" or ao == "Info" then
			return am.Info
		elseif ao == "TextMuted" or ao == "Muted" then
			return am.Muted
		end
	end
	return am.Accent
end
function ak.New(ap)
	local aq, ar = ap.Entry, ad.CreateScope()
	local as, at =
		ae.New({ Title = aq.Text, Height = 32, HasDivider = false, Hover = true }), aq.AnimationId or aq.Key or ""
	if at ~= "" then
		local e = ao(aq.Variant)
		local f = aj(
			"TextLabel",
			{
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = an(e.Bg, Color3.fromRGB(255, 185, 255)),
				BackgroundTransparency = e.Transparency,
				BorderSizePixel = 0,
				FontFace = Font.new(an("FontFamily", al), Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Size = UDim2.fromOffset(0, 20),
				Text = at,
				TextColor3 = an(e.Text, Color3.fromRGB(20, 24, 6)),
				TextSize = an("TextSizeCaption", 14),
				[ac.ThemeTag] = { BackgroundColor3 = e.Bg, TextColor3 = e.Text },
			},
			{
				aj("UICorner", { CornerRadius = an("CornerRadiusFull", UDim.new(1, 0)) }),
				aj(
					"UIPadding",
					{
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingTop = UDim.new(0, 1),
						PaddingBottom = UDim.new(0, 1),
					}
				),
			}
		)
		f.Parent = as.Container
	end
	as:Mount(ap.Parent)
	local e, f, g, h, i = (as.InteractButton or as.Root), false
	local j = function()
		if i and not i.Destroyed then
			return i
		end
		local j = as.Root
		while j do
			if j:IsA("ScreenGui") then
				i = ah.Get(j)
				return i
			end
			j = j.Parent
		end
		return nil
	end
	local k = function(k)
		if f or not aq.AnimationId then
			return
		end
		f = true
		local l = j()
		if l then
			l:Show(aq.AnimationId)
			l:Lock()
		end
		g = ag.Begin({ AnimationId = aq.AnimationId, Label = aq.Text, Key = aq.Key, Timestamp = aq.Timestamp }, {
			OnMove = function(m) end,
			OnRelease = function()
				if l and not l.Destroyed then
					l:Unlock()
					l:Hide()
				end
				f = false
				g = nil
			end,
		})
		if g and ap.OnDragged then
			af.Call(ap.OnDragged, aq)
		end
	end
	ar:Connect(e.InputBegan, function(l)
		if l.UserInputType == Enum.UserInputType.MouseButton1 then
			h = Vector2.new(l.Position.X, l.Position.Y)
		elseif l.UserInputType == Enum.UserInputType.MouseButton2 then
			af.Call(ap.OnBlacklist, aq)
		end
	end)
	ar:Connect(aa.InputChanged, function(l)
		if l.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local m = Vector2.new(l.Position.X, l.Position.Y)
		if g then
			g.Update(m)
		elseif h and aq.AnimationId then
			if (m - h).Magnitude > 6 then
				k(m)
			end
		end
	end)
	ar:Connect(aa.InputEnded, function(l)
		if l.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		local m = Vector2.new(l.Position.X, l.Position.Y)
		if g then
			g.Drop(m)
		elseif h then
			af.Call(ap.OnActivated, aq)
		end
		h = nil
	end)
	local l, m = { Root = as.Root }, false
	function l.Destroy(n)
		if m then
			return
		end
		m = true
		if g then
			g.Cancel()
		end
		if i and not i.Destroyed then
			i:Unlock()
			i:Hide()
		end
		ar:Destroy()
		as:Destroy()
	end
	return l
end
return ak
end
a["Debug/AnimationLoggerPanel"]=function()
local aa, ab, ac, ad, ae, af, ag =
	d("Debug/AnimationLoggerStore"), d("Debug/AnimationLoggerToolbar"), d("Debug/AnimationLoggerTypes"), d("Core/SafeCall"), { "Animation", "Keyframe", "Telemetry", "Missing" }, 30, {}
function ag.New(ah)
	local ai = ah.Categories or ae
	if #ai == 0 then
		ai = ae
	end
	local aj, ak, al, am =
		aa.New(ai, ah.MaxPerCategory or af), ah.AutoScroll == nil and true or ah.AutoScroll == true, function(aj)
			if ah.OnNotify then
				ad.Call(ah.OnNotify, aj)
			end
		end
	am = ab.New({
		Modal = ah.Modal,
		Ring = aj,
		AutoScroll = ak,
		OnActivated = function(an)
			local ao = an.AnimationId or an.Key
			if ao and typeof(setclipboard) == "function" then
				pcall(setclipboard, ao)
				al(("Copied '%s' to clipboard."):format(ao))
			end
			if ah.OnEntryActivated then
				ad.Call(ah.OnEntryActivated, an)
			end
		end,
		OnBlacklist = function(an)
			aa.Blacklist_(aj, an.Key)
			al(("Blacklisted '%s'."):format(an.Key))
		end,
		OnDragged = ah.OnEntryDragged,
		OnSelectCategory = function(an)
			aa.SetCategory(aj, an)
		end,
		OnClear = function()
			aa.Clear(aj)
		end,
		OnUndo = function()
			local an = aa.UndoBlacklist(aj)
			if an then
				al(("Re-whitelisted '%s'."):format(an))
			end
		end,
	})
	aj.OnChanged = function()
		am.Refresh()
	end
	am.Refresh()
	local an = {}
	function an.AddEntry(ao, ap)
		return aa.Add(aj, ap)
	end
	function an.AddAnimation(ao, ap, aq)
		local ar = aq or { Text = "" }
		ar.Category = ar.Category or "Animation"
		ar.AnimationId = ap
		ar.Key = ar.Key or ap
		if not ar.Text or ar.Text == "" then
			ar.Text = ("Animation %s"):format(ap)
		end
		return aa.Add(aj, ar)
	end
	function an.AddKeyframe(ao, ap, aq)
		local ar = aq or { Text = ap }
		ar.Text = ap
		ar.Category = ar.Category or "Keyframe"
		return aa.Add(aj, ar)
	end
	function an.AddTelemetry(ao, ap, aq)
		local ar = aq or { Text = ap }
		ar.Text = ap
		ar.Category = ar.Category or "Telemetry"
		ar.Variant = ar.Variant or "TextMuted"
		return aa.Add(aj, ar)
	end
	function an.AddMissing(ao, ap, aq)
		local ar = aq or { Text = ap }
		ar.Text = ap
		ar.Category = ar.Category or "Missing"
		ar.Variant = ar.Variant or "TextWarning"
		return aa.Add(aj, ar)
	end
	function an.Clear(ao, ap)
		aa.Clear(aj, ap)
	end
	function an.SetCategory(ao, ap)
		aa.SetCategory(aj, ap)
	end
	function an.CycleBy(ao, ap)
		aa.CycleBy(aj, ap)
	end
	function an.Blacklist(ao, ap)
		aa.Blacklist_(aj, ap)
	end
	function an.Unblacklist(ao, ap)
		aa.Unblacklist(aj, ap)
	end
	function an.UndoBlacklist(ao)
		local ap = aa.UndoBlacklist(aj)
		if ap then
			al(("Re-whitelisted '%s'."):format(ap))
		end
		return ap
	end
	function an.Categories(ao)
		return table.clone(aj.Categories)
	end
	local ao = false
	function an.Destroy(ap)
		if ao then
			return
		end
		ao = true
		aj.OnChanged = nil
		am.Destroy()
	end
	return an
end
return ag
end
a["Debug/AnimationLoggerStore"]=function()
d("Debug/AnimationLoggerTypes")
local aa, ab = {}, function(aa)
	if aa.OnChanged then
		aa.OnChanged()
	end
end
function aa.New(ac, ad)
	return {
		Categories = ac,
		MaxPerCategory = math.max(1, ad),
		Entries = {},
		Blacklist = {},
		BlacklistHistory = {},
		CycleIndex = 1,
		OnChanged = nil,
		OnEvicted = nil,
	}
end
function aa.CurrentCategory(ac)
	return ac.Categories[ac.CycleIndex] or ac.Categories[1] or "Default"
end
local ac, ad =
	function(ac, ad)
		local ae = 0
		for af, ag in ac.Entries do
			if ag.Category == ad then
				ae = ae + 1
			end
		end
		return ae
	end, function(ac, ad)
		for ae = #ac.Entries, 1, -1 do
			local af = ac.Entries[ae]
			if af.Category == ad then
				table.remove(ac.Entries, ae)
				if ac.OnEvicted then
					ac.OnEvicted(af)
				end
				return
			end
		end
	end
function aa.Add(ae, af)
	local ag = af.Category
	if not ag or not table.find(ae.Categories, ag) then
		ag = ae.Categories[1] or "Default"
	end
	local ah = af.Key or tostring(math.random())
	if ae.Blacklist[ah] then
		return nil
	end
	local ai = {
		Category = ag,
		Text = af.Text,
		AnimationId = af.AnimationId,
		Variant = af.Variant,
		Key = ah,
		Timestamp = af.Timestamp or os.clock(),
		Row = nil,
	}
	table.insert(ae.Entries, 1, ai)
	if ac(ae, ag) > ae.MaxPerCategory then
		ad(ae, ag)
	end
	ab(ae)
	return ai
end
function aa.VisibleEntries(ae)
	local af, ag = aa.CurrentCategory(ae), {}
	for ah, ai in ae.Entries do
		if ai.Category == af and not ae.Blacklist[ai.Key] then
			table.insert(ag, ai)
		end
	end
	return ag
end
function aa.SetCategory(ae, af)
	local ag = table.find(ae.Categories, af)
	if ag then
		ae.CycleIndex = ag
		ab(ae)
	end
end
function aa.CycleBy(ae, af)
	local ag = #ae.Categories
	if ag == 0 then
		return
	end
	ae.CycleIndex = math.clamp(ae.CycleIndex + af, 1, ag)
	ab(ae)
end
function aa.Blacklist_(ae, af)
	if ae.Blacklist[af] then
		return
	end
	ae.Blacklist[af] = true
	table.insert(ae.BlacklistHistory, 1, af)
	ab(ae)
end
function aa.Unblacklist(ae, af)
	if not ae.Blacklist[af] then
		return
	end
	ae.Blacklist[af] = nil
	local ag = table.find(ae.BlacklistHistory, af)
	if ag then
		table.remove(ae.BlacklistHistory, ag)
	end
	ab(ae)
end
function aa.UndoBlacklist(ae)
	local af = ae.BlacklistHistory[1]
	if not af then
		return nil
	end
	aa.Unblacklist(ae, af)
	return af
end
function aa.Clear(ae, af)
	if af then
		for ag = #ae.Entries, 1, -1 do
			if ae.Entries[ag].Category == af then
				local ah = ae.Entries[ag]
				table.remove(ae.Entries, ag)
				if ae.OnEvicted then
					ae.OnEvicted(ah)
				end
			end
		end
	else
		for ag, ah in ae.Entries do
			if ae.OnEvicted then
				ae.OnEvicted(ah)
			end
		end
		table.clear(ae.Entries)
	end
	ab(ae)
end
return aa
end
a["Debug/AnimationLoggerToolbar"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af = aa.Creator, aa.SignalManager, d("Debug/AnimationLoggerEntry"), d("Debug/AnimationLoggerStore"), d("Debug/AnimationLoggerTypes")
local ag, ah = ab.New, {}
function ah.New(ai)
	local aj, ak, al, am = ai.Ring, ai.Modal, ac.CreateScope(), {}
	local an, ao = ak:AddSection("Filter"), {}
	for ap, aq in aj.Categories do
		table.insert(ao, { Label = aq, Value = aq })
	end
	local ap = an:AddDropdown("Category", {
		Options = ao,
		Default = { ae.CurrentCategory(aj) },
		Tooltip = "Filter the log by category (or press Q / E to cycle).",
		Callback = function(ap)
			local aq = (type(ap) == "table" and { ap[1] } or { ap })[1]
			if type(aq) == "string" then
				ai.OnSelectCategory(aq)
			end
		end,
	})
	an:AddButton({ Title = "Clear", Tooltip = "Clear all entries in the active category.", Callback = ai.OnClear })
	an:AddButton({
		Title = "Undo Blacklist",
		Tooltip = "Re-whitelist the most recently blacklisted entry.",
		Callback = ai.OnUndo,
	})
	local aq, ar =
		ak:AddSection("Log"),
		ag(
			"Frame",
			{ Name = "LogBody", AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(
				1,
				0,
				0,
				0
			) },
			{
				ag(
					"UIListLayout",
					{
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 2),
					}
				),
			}
		)
	ar.Parent = aq.Container
	local as, at =
		function()
			for as, at in am do
				at:Destroy()
			end
			table.clear(am)
		end, function()
			local as = ae.CurrentCategory(aj)
			if ap and ap.SetValue then
				pcall(function()
					ap:SetValue({ as })
				end)
			end
		end
	local e = function()
		as()
		at()
		local e = ae.VisibleEntries(aj)
		for f = #e, 1, -1 do
			local g = e[f]
			local h = ad.New({
				Entry = g,
				Parent = ar,
				OnActivated = ai.OnActivated,
				OnBlacklist = ai.OnBlacklist,
				OnDragged = ai.OnDragged,
			})
			h.Root.LayoutOrder = #e - f + 1
			table.insert(am, h)
		end
		if ai.AutoScroll then
			task.defer(function()
				local f = ak.Container
				if f and f.Parent and f:IsA("ScrollingFrame") then
					f.CanvasPosition = Vector2.new(0, f.AbsoluteCanvasSize.Y)
				end
			end)
		end
	end
	local f = { Refresh = e }
	function f.Destroy()
		as()
		al:Destroy()
	end
	return f
end
return ah
end
a["Debug/AnimationLoggerTypes"]=function()
return {}
end
a["Debug/AnimationPlayer"]=function()
local aa, ab = game:GetService("RunService"), d("Core/Common")
local ac, ad, ae, af, ag = ab.SignalManager, d("Core/SafeCall"), d("Core/ThreadIdentity"), {}, 0.01
function af.New(ah)
	local ai, aj, ak, al, am, an, ao = ac.CreateScope(), true, 0, 1
	local ap, aq, ar, as =
		function()
			return (am and am.Length > 0 and { am.Length } or { 0 })[1]
		end, {}, function(ap, aq)
			local ar, as = ae.Elevate(), pcall(function()
				ap:StepAnimations(aq)
			end)
			ar()
			return as
		end
	ai:Connect(aa.PreRender, function(at)
		local e, f = am, an
		if not e or not f then
			return
		end
		if not aj then
			ak = ak + at
			local g = 1
			if ao then
				local h, i = ad.Call(ao, ak)
				g = (h and type(i) == "number" and { i } or { 1 })[1]
			end
			e:AdjustSpeed(g * al)
		else
			e:AdjustSpeed(0)
		end
		if as ~= false then
			local g = ar(f, at)
			if as == nil then
				as = g
			end
		end
		ad.Call(ah.OnTick, e.TimePosition, ap(), not aj)
	end)
	local at = function()
		if am then
			pcall(function()
				am:Stop(0)
				am:Destroy()
			end)
			am = nil
		end
		an = nil
	end
	function aq.Load(e, f, g, h)
		at()
		an = f
		ak = 0
		aj = true
		ao = h and h.SpeedAt or nil
		local i = Instance.new("Animation")
		i.AnimationId = g
		local j, k = pcall(function()
			return f:LoadAnimation(i)
		end)
		i:Destroy()
		if not j or not k then
			return false, "Failed To Load Animation"
		end
		am = k;
		(am).Looped = true
		(am).Priority = Enum.AnimationPriority.Action;
		(am):Play(0, 1, 0);
		(am):AdjustSpeed(0);
		(am).TimePosition = 0
		ai:Connect((am).DidLoop, function()
			ak = 0
		end)
		return true, nil
	end
	function aq.Play(e)
		if am then
			aj = false
		end
	end
	function aq.Pause(e)
		aj = true
	end
	function aq.TogglePlay(e)
		if am then
			aj = not aj
		end
	end
	function aq.Seek(e, f)
		if am then
			am.TimePosition = math.clamp(f, 0, ap())
		end
	end
	function aq.Step(e, f)
		if not am then
			return
		end
		aj = true
		local g = math.clamp(am.TimePosition + f * ag, 0, ap())
		am.TimePosition = g
	end
	function aq.SetSpeed(e, f)
		if type(f) ~= "number" or f <= 0 then
			return
		end
		al = f
		if am and not aj then
			am:AdjustSpeed(f)
		end
	end
	function aq.IsPlaying(e)
		return am ~= nil and not aj
	end
	function aq.GetLength(e)
		return ap()
	end
	function aq.Stop(e)
		at()
		aj = true
		ak = 0
	end
	local e = false
	function aq.Destroy(f)
		if e then
			return
		end
		e = true
		at()
		ai:Destroy()
	end
	return aq
end
return table.freeze(af)
end
a["Debug/AnimationRigLoader"]=function()
local aa = {}
function aa.ClearModels(ab)
	for ac, ad in ab:GetChildren() do
		if ad:IsA("Model") then
			ad:Destroy()
		end
	end
end
function aa.FrameModel(ab, ac)
	local ad, ae, af = pcall(function()
		return ac:GetBoundingBox()
	end)
	if not ad or not ae then
		return
	end
	local ag, ah = ae.Position, math.max((af).Magnitude, 4)
	local ai = Vector3.new(0, ah * 0.15, ah * 0.95)
	ab.CFrame = CFrame.lookAt(ag + ai, ag)
end
function aa.MountRig(ab, ac, ad)
	aa.ClearModels(ab)
	local ae = ad.Archivable
	ad.Archivable = true
	local af = ad:Clone()
	ad.Archivable = ae
	if not af then
		return nil, "Failed To Clone Entity"
	end
	af.Parent = ab
	if not af.PrimaryPart then
		local ag = af:FindFirstChildWhichIsA("BasePart", true)
		if ag then
			af.PrimaryPart = ag
		end
	end
	if not af.PrimaryPart then
		af:Destroy()
		return nil, "No Primary Part Found"
	end
	af:PivotTo(CFrame.new(0, 0, 0))
	aa.FrameModel(ac, af)
	return af, nil
end
function aa.ResolveAnimator(ab)
	local ac = ab:FindFirstChildWhichIsA("Animator", true)
	if ac then
		return ac, nil
	end
	local ad = ab:FindFirstChildWhichIsA("Humanoid", true) or ab:FindFirstChildWhichIsA("AnimationController", true)
	if ad then
		local ae = Instance.new("Animator")
		ae.Parent = ad
		return ae, nil
	end
	return nil, "No Animator Found"
end
function aa.ComputeOrbit(ab)
	local ac, ad, ae = pcall(function()
		return ab:GetBoundingBox()
	end)
	if not ac or not ad then
		return nil, nil, nil
	end
	local af = math.max((ae).Magnitude, 4)
	return ad.Position, af * 0.95, af * 0.15
end
return aa
end
a["Debug/AnimationSeekBar"]=function()
local aa, ab, ac, ad = d("Debug/AnimationSeekBarInput"), d("Debug/AnimationSeekBarView"), d("Core/SafeCall"), {}
function ad.New(ae)
	local af, ag, ah, ai, aj = ab.New({ Parent = ae.Parent, Height = ae.Height }), 0, 0
	local ak = function()
		local ak = (ag > 0 and { (math.clamp(ah / ag, 0, 1)) } or { 0 })[1]
		af.Fill.Size = UDim2.new(ak, 0, 1, 0)
	end
	aa.Wire({
		Track = af.Track,
		OnSeekStart = function()
			if aj then
				ac.Call(aj, true)
			end
		end,
		SetFraction = function(al)
			ah = al * ag
			ak()
			if ai then
				ac.Call(ai, ah)
			end
		end,
		OnSeekEnd = function()
			if aj then
				ac.Call(aj, false)
			end
		end,
	})
	local al = { Root = af.Root }
	function al.SetRange(am, an)
		ag = math.max(an, 0)
		ak()
	end
	function al.SetPosition(am, an)
		ah = math.clamp(an, 0, math.max(ag, an))
		ak()
	end
	function al.SetText(am, an)
		af.Label.Text = an
	end
	function al.OnSeek(am, an)
		ai = an
	end
	function al.OnSeekStateChanged(am, an)
		aj = an
	end
	local am = false
	function al.Destroy(an)
		if am then
			return
		end
		am = true
		ai = nil
		aj = nil
		af.Root:Destroy()
	end
	return al
end
return table.freeze(ad)
end
a["Debug/AnimationSeekBarInput"]=function()
local aa, ab = game:GetService("UserInputService"), d("Core/Common")
local ac, ad = ab.Creator, ab.SignalManager
local ae, af = ac.New, {}
function af.Wire(ag)
	local ah = ae(
		"TextButton",
		{
			Name = "SeekHitZone",
			Text = "",
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 0, 1, 18),
			ZIndex = 10,
		}
	)
	ah.Parent = ag.Track
	local ai, aj, ak =
		function(ai)
			local aj, ak = ag.Track.AbsolutePosition.X, math.max(ag.Track.AbsoluteSize.X, 1)
			return math.clamp((ai - aj) / ak, 0, 1)
		end, 0
	local al = function()
		if ak then
			ak:Destroy()
			ak = nil
			if ag.OnSeekEnd then
				ag.OnSeekEnd(aj)
			end
		end
	end
	ac.TrackConnection(
		ah,
		ah.MouseButton1Down:Connect(function(am)
			if ag.OnSeekStart then
				ag.OnSeekStart()
			end
			aj = ai(am)
			ag.SetFraction(aj)
			if ak then
				return
			end
			ak = ad.CreateScope()
			ak:Connect(aa.InputChanged, function(an)
				local ao = an.UserInputType
				if ao == Enum.UserInputType.MouseMovement or ao == Enum.UserInputType.Touch then
					aj = ai(an.Position.X)
					ag.SetFraction(aj)
				end
			end)
			ak:Connect(aa.InputEnded, function(an)
				local ao = an.UserInputType
				if ao == Enum.UserInputType.MouseButton1 or ao == Enum.UserInputType.Touch then
					al()
				end
			end)
		end)
	)
	ac.TrackConnection(ah, ah.Destroying:Connect(al))
end
return af
end
a["Debug/AnimationSeekBarView"]=function()
local aa = d("Core/Common")
local ab = aa.Creator
local ac, ad, ae =
	ab.New, {}, function(ac, ad)
		local ae = ab.GetThemeProperty(ac)
		return (ae ~= nil and { ae } or { ad })[1]
	end
local af = "CornerRadiusFull"
function ad.New(ag)
	local ah, ai, aj =
		ac(
			"TextLabel",
			{
				Name = "Label",
				BackgroundTransparency = 1,
				FontFace = Font.new(
					ae("FontFamily", "rbxassetid://12187365364"),
					Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 14),
				Text = "0.000 / 0.000 (0ms)",
				TextColor3 = ae("SubText", Color3.fromRGB(160, 160, 160)),
				TextSize = ae("TextSizeCategory", 12),
				TextXAlignment = Enum.TextXAlignment.Right,
				[ab.ThemeTag] = { TextColor3 = "SubText", TextSize = "TextSizeCategory" },
			}
		),
		ac(
			"Frame",
			{
				Name = "Fill",
				BackgroundColor3 = ae("SliderFill", Color3.fromRGB(255, 185, 255)),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 1, 0),
				ZIndex = 2,
				[ab.ThemeTag] = { BackgroundColor3 = "SliderFill" },
			},
			{ ac("UICorner", { CornerRadius = ae(af, UDim.new(1, 0)) }) }
		),
		ac(
			"Frame",
			{
				Name = "Knob",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = ae("SliderKnob", ae("Text", Color3.fromRGB(240, 240, 240))),
				BorderSizePixel = 0,
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(12, 12),
				ZIndex = 3,
				[ab.ThemeTag] = { BackgroundColor3 = "SliderKnob" },
			},
			{
				ac("UICorner", { CornerRadius = ae(af, UDim.new(1, 0)) }),
				ac(
					"UIStroke",
					{
						Color = ae("StrokeColor", Color3.fromRGB(240, 240, 240)),
						Transparency = ae("StrokeTransparency", 0.9),
						[ab.ThemeTag] = { Color = "StrokeColor", Transparency = "StrokeTransparency" },
					}
				),
			}
		)
	aj.Parent = ai
	local ak = ac(
		"Frame",
		{
			Name = "Track",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = ae("SliderRail", Color3.fromRGB(140, 140, 140)),
			BackgroundTransparency = ae("SliderRailTransparency", 0.9),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 0, 0, 4),
			[ab.ThemeTag] = { BackgroundColor3 = "SliderRail", BackgroundTransparency = "SliderRailTransparency" },
		},
		{ ac("UICorner", { CornerRadius = ae(af, UDim.new(1, 0)) }), ai }
	)
	local al = ac(
		"Frame",
		{ Name = "RailRow", BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, ag.Height or 18) },
		{ ak }
	)
	local am = ac(
		"Frame",
		{ Name = "Scrubber", AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(
			1,
			0,
			0,
			0
		) },
		{
			ac(
				"UIListLayout",
				{ FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(
					0,
					4
				) }
			),
			ah,
			al,
		}
	)
	am.Parent = ag.Parent
	return { Root = am, Track = ak, Fill = ai, Knob = aj, Label = ah }
end
return ad
end
a["Debug/AnimationViewport"]=function()
local aa, ab, ac, ad = d("Debug/AnimationViewportView"), d("Debug/AnimationRigLoader"), d("Debug/AnimationDragDrop"), d("Core/Common")
local ae, af, ag, ah, ai, aj, ak, al, am, an =
	ad.SignalManager,
	game:GetService("RunService"),
	game:GetService("UserInputService"),
	0.6,
	0.01,
	1.5,
	0.12,
	0.4,
	2.5,
	{}
function an.New(ao)
	local ap, aq, ar, as, at, e, f, g, h, i, j, k, l =
		aa.New({ Parent = ao.Parent, Size = ao.Size, Position = ao.Position }),
		ae.CreateScope(),
		0,
		0,
		0,
		0,
		false,
		0,
		0
	local m, n =
		function()
			local m = ap.Root
			if not m.Parent or not m.Visible then
				return false
			end
			local n, o, p = ag:GetMouseLocation(), m.AbsolutePosition, m.AbsoluteSize
			return n.X >= o.X and n.X <= o.X + p.X and n.Y >= o.Y and n.Y <= o.Y + p.Y
		end, function()
			local m = l
			if not m then
				return
			end
			ap.Camera.CFrame = CFrame.lookAt(m + Vector3.new(math.sin(ar) * as, e, math.cos(ar) * as), m)
		end
	aq:Connect(af.PreRender, function(o)
		if not l then
			return
		end
		if not f and os.clock() >= h then
			ar = ar + o * ah
		end
		n()
	end)
	aq:Connect(ap.Root.InputBegan, function(o)
		if o.UserInputType == Enum.UserInputType.MouseButton1 or o.UserInputType == Enum.UserInputType.Touch then
			f = true
			g = o.Position.X
		end
	end)
	aq:Connect(ag.InputChanged, function(o)
		if
			f and (o.UserInputType == Enum.UserInputType.MouseMovement or o.UserInputType == Enum.UserInputType.Touch)
		then
			local p = o.Position.X - g
			g = o.Position.X
			ar = ar - p * ai
		elseif o.UserInputType == Enum.UserInputType.MouseWheel and at > 0 then
			if m() then
				local p = as - o.Position.Z * ak * at
				as = math.clamp(p, at * al, at * am)
				n()
			end
		end
	end)
	local o = function(o)
		if o.UserInputType == Enum.UserInputType.MouseButton1 or o.UserInputType == Enum.UserInputType.Touch then
			if f then
				f = false
				h = os.clock() + aj
			end
		end
	end
	aq:Connect(ap.Root.InputEnded, o)
	aq:Connect(ag.InputEnded, o)
	local p = { Root = ap.Root, WorldModel = ap.WorldModel, Camera = ap.Camera }
	function p.GetAnimator(q)
		return j
	end
	function p.SetRig(q, r)
		local s, t = ab.MountRig(ap.WorldModel, ap.Camera, r)
		if not s then
			i = nil
			j = nil
			ap.ShowMessage(t or "Failed To Load Rig")
			return false, t
		end
		local u, v = ab.ResolveAnimator(s)
		if not u then
			s:Destroy()
			i = nil
			j = nil
			ap.ShowMessage(v or "No Animator Found")
			return false, v
		end
		i = s
		j = u
		l, as, e = ab.ComputeOrbit(s)
		at = as or 0
		ar = 0
		ap.HideMessage()
		return true, nil
	end
	function p.Clear(q)
		ab.ClearModels(ap.WorldModel)
		i = nil
		j = nil
		l = nil
		at = 0
	end
	function p.ShowMessage(q, r)
		ap.ShowMessage(r)
	end
	function p.HideMessage(q)
		ap.HideMessage()
	end
	function p.RegisterDropTarget(q, r, s)
		if k then
			k()
		end
		k = ac.RegisterTarget({
			Contains = function(t)
				local u = ap.Root
				if not u.Parent or not u.Visible then
					return false
				end
				local v, w = u.AbsolutePosition, u.AbsoluteSize
				return t.X >= v.X and t.X <= v.X + w.X and t.Y >= v.Y and t.Y <= v.Y + w.Y
			end,
			Accepts = s,
			OnDrop = function(t)
				r(t)
			end,
			OnHoverChanged = function(t)
				ap.SetDropHighlight(t)
			end,
		})
		return k
	end
	local q = false
	function p.Destroy(r)
		if q then
			return
		end
		q = true
		if k then
			k()
			k = nil
		end
		aq:Destroy()
		p:Clear()
		ap.Destroy()
	end
	return p
end
return table.freeze(an)
end
a["Debug/AnimationViewportView"]=function()
local aa = d("Core/Common")
local ab, ac, ad = aa.Creator, aa.Animator, aa.AnimTokens
local ae, af, ag =
	ab.New, {}, function(ae, af)
		local ag = ab.GetThemeProperty(ae)
		return (ag ~= nil and { ag } or { af })[1]
	end
function af.New(ah)
	local ai, aj, ak =
		ae("Camera", { FieldOfView = 70, CFrame = CFrame.lookAt(Vector3.new(0, 2, 8), Vector3.new(0, 1.5, 0)) }),
		ae("WorldModel", {}),
		ae("UIStroke", { Color = ag("Accent", Color3.fromRGB(255, 185, 255)), Transparency = 1, Thickness = 1.5 })
	local al = ae(
		"ViewportFrame",
		{
			Name = "Viewport",
			BackgroundColor3 = ag("BackgroundMain", Color3.fromRGB(20, 20, 20)),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = ah.Size or UDim2.new(1, 0, 0, 200),
			Position = ah.Position or UDim2.fromOffset(0, 0),
			LightColor = Color3.fromRGB(140, 134, 111),
			Ambient = Color3.fromRGB(81, 81, 81),
			[ab.ThemeTag] = { BackgroundColor3 = "BackgroundMain" },
		},
		{ ae("UICorner", { CornerRadius = ag("CornerRadiusSection", UDim.new(0, 18)) }), ak, aj }
	)
	al.CurrentCamera = ai
	ai.Parent = al
	al.Parent = ah.Parent
	local am = ae(
		"TextLabel",
		{
			Name = "Message",
			BackgroundTransparency = 1,
			FontFace = Font.new(
				ag("FontFamily", "rbxassetid://12187365364"),
				Enum.FontWeight.Medium,
				Enum.FontStyle.Normal
			),
			Size = UDim2.new(1, -24, 1, -24),
			Position = UDim2.fromOffset(12, 12),
			Text = "",
			TextColor3 = ag("TextMuted", Color3.fromRGB(140, 140, 140)),
			TextSize = ag("TextSizeSmall", 15),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Visible = false,
			ZIndex = 5,
			[ab.ThemeTag] = { TextColor3 = "TextMuted" },
		}
	)
	am.Parent = al
	local an = { Root = al, WorldModel = aj, Camera = ai }
	function an.ShowMessage(ao)
		am.Text = ao
		am.Visible = true
	end
	function an.HideMessage()
		am.Visible = false
	end
	function an.SetDropHighlight(ao)
		ac.Tween(ak, { Transparency = ao and 0 or 1 }, ad.Preset.Fade)
	end
	function an.Destroy()
		al:Destroy()
	end
	return an
end
return af
end
a["Debug/AnimationVisualizer"]=function()
local aa, ab, ac = game:GetService("Players"), game:GetService("UserInputService"), d("Core/Common")
local ad, ae, af, ag, ah, ai, aj, ak, al, am =
	ac.SignalManager, d("Core/SafeCall"), d("Debug/AnimationControls"), d("Debug/AnimationPlayer"), 300, 540, "Waiting For Animation ID", {}, function()
		local ad = aa.LocalPlayer
		local ae = ad and ad.Character
		return (ae and ae:IsA("Model") and { ae } or { nil })[1]
	end, function(ad, ae)
		return ("%.3f / %.3f (%dms)"):format(ad, ae, math.floor(ad * 1000))
	end
function ak.New(an, ao)
	ao = (type(ao) == "table" and { ao } or { {} })[1]
	local ap, aq, ar, as, at, e, f, g, h =
		(type(ao.Title) == "string" and ao.Title ~= "" and { ao.Title } or { "Animation Visualizer" })[1],
		(type(ao.RigProvider) == "function" and { ao.RigProvider } or { al })[1],
		false,
		{ Modal = nil },
		function(ap)
			if an.Notify then
				an:Notify(ap)
			end
		end
	local i, j =
		function(i, j)
			if not e or not f then
				return false
			end
			if type(i) ~= "string" or i == "" then
				return false
			end
			local k = aq()
			if not k then
				e.Viewport:ShowMessage("No Rig Available")
				return false
			end
			local l, m = e.Viewport:SetRig(k)
			if not l then
				at(m or "Failed To Load Rig")
				return false
			end
			local n = e.Viewport:GetAnimator()
			if not n then
				e.Viewport:ShowMessage("No Animator Found")
				return false
			end
			local o, p = f:Load(n, i, j)
			if not o then
				e.Viewport:ShowMessage(p or "Failed To Load Animation")
				return false
			end
			e.IdInput:SetValue(i)
			f:Play()
			e.SetPlayingIcon(true)
			return true
		end, function()
			if g then
				g:Destroy()
				g = nil
			end
		end
	local k = function()
		j()
		local k, l = e, f
		g = ad.CreateScope()
		local m = g
		m:Connect(k.PlayButton.MouseButton1Click, function()
			l:TogglePlay()
			k.SetPlayingIcon(l:IsPlaying())
		end)
		m:Connect(k.BackButton.MouseButton1Click, function()
			l:Step(-1)
			k.SetPlayingIcon(false)
		end)
		m:Connect(k.ForwardButton.MouseButton1Click, function()
			l:Step(1)
			k.SetPlayingIcon(false)
		end)
		k.Scrubber:OnSeek(function(n)
			l:Seek(n)
		end)
		k.Scrubber:OnSeekStateChanged(function(n)
			ar = n
			if n then
				l:Pause()
				k.SetPlayingIcon(false)
			end
		end)
		m:Connect(ab.InputBegan, function(n, o)
			if o or not as.Modal or not as.Modal:IsOpen() then
				return
			end
			if n.KeyCode == Enum.KeyCode.Space then
				l:TogglePlay()
				k.SetPlayingIcon(l:IsPlaying())
			elseif n.KeyCode == Enum.KeyCode.Right then
				l:Step(1)
				k.SetPlayingIcon(false)
			elseif n.KeyCode == Enum.KeyCode.Left then
				l:Step(-1)
				k.SetPlayingIcon(false)
			end
		end)
	end
	as.Modal = an:Modal({
		Title = ap,
		Width = tonumber(ao.Width) or ah,
		Height = tonumber(ao.Height) or ai,
		Draggable = true,
		Resizable = ao.Resizable == nil and true or ao.Resizable == true,
		MinWidth = 300,
		MinHeight = 540,
		MaxWidth = 600,
		MaxHeight = 760,
		AllowStacked = true,
		AllowOverlayDismiss = false,
		ShowCloseButton = ao.ShowCloseButton ~= false,
		AutoOpen = false,
		OnClose = function(l)
			j()
			if f then
				f:Pause()
			end
			if type(ao.OnClose) == "function" then
				ao.OnClose(l)
			end
		end,
		Build = function(l)
			e = af.New({
				Modal = l,
				OnSubmitId = function(m)
					i(m)
				end,
				OnSpeed = function(m)
					if f then
						f:SetSpeed(m)
					end
				end,
			})
			f = ag.New({
				OnTick = function(m, n, o)
					local p = e
					if not p then
						return
					end
					if not ar then
						p.Scrubber:SetRange(n)
						p.Scrubber:SetPosition(m)
					end
					p.Scrubber:SetText(am(m, n))
				end,
			})
			e.Viewport:ShowMessage(aj)
			h = e.Viewport:RegisterDropTarget(function(m)
				local n = m.AnimationId
				if type(n) == "string" and n ~= "" then
					i(n)
					at(("Loaded %s"):format(n))
				end
			end, function(m)
				return type(m.AnimationId) == "string"
			end)
			k()
		end,
	})
	if not as.Modal then
		return as
	end
	function as.Open(l)
		return l.Modal ~= nil and l.Modal:Open()
	end
	function as.Close(l, m)
		if l.Modal then
			l.Modal:Close(m)
		end
	end
	function as.IsOpen(l)
		return l.Modal ~= nil and l.Modal:IsOpen()
	end
	function as.SetTitle(l, m)
		if l.Modal then
			l.Modal:SetTitle(m)
		end
	end
	function as.Load(l, m, n)
		return i(m, n)
	end
	function as.Play(l)
		if f then
			f:Play()
			if e then
				e.SetPlayingIcon(true)
			end
		end
	end
	function as.Pause(l)
		if f then
			f:Pause()
			if e then
				e.SetPlayingIcon(false)
			end
		end
	end
	function as.Seek(l, m)
		if f then
			f:Seek(m)
		end
	end
	function as.Step(l, m)
		if f then
			f:Step(m)
		end
	end
	function as.AcceptDropFrom(l, m)
		return true
	end
	function as.Destroy(l, m)
		j()
		if h then
			h()
			h = nil
		end
		if f then
			f:Destroy()
			f = nil
		end
		if e then
			e.Destroy()
			e = nil
		end
		if l.Modal then
			l.Modal:Destroy(m)
		end
	end
	if not (ao.AutoOpen == false) then
		as:Open()
	end
	return as
end
return table.freeze(ak)
end
a["Elements/Button"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag, ah, ai = aa.Creator, aa.Animator, aa.WindowDrag, d("Core/SafeCall"), d("Core/Types"), d("UI/Attributes"), d("UI/Element"), d("Localization/Localization")
local aj = ab.New
local ak = {
	Outline = {
		Bg = "ButtonOutlineBg",
		BgTransparency = "ButtonOutlineBgTransparency",
		Text = "Text",
		Stroke = "ButtonOutlineStroke",
		StrokeTransparency = "ButtonOutlineStrokeTransparency",
		FontWeight = Enum.FontWeight.Medium,
	},
	Destructive = {
		Bg = "ButtonDestructiveBg",
		BgTransparency = "ButtonDestructiveBgTransparency",
		Text = "ButtonDestructiveText",
		Stroke = nil,
		StrokeTransparency = nil,
		FontWeight = Enum.FontWeight.SemiBold,
	},
}
ak.Default = ak.Outline
local al = {}
al.__type = "Button"
function al.New(am, an, ao, ap)
	local aq, ar = ao or {}
	if ai.IsTagged(aq.Title) then
		ar = aq.Title
	else
		ar = (type(an) == "string" and an) or aq.Title or ""
	end
	local as, at = aq.Variant or "Outline", "Outline"
	local e, f = ak[as] or ak[at], ah.New({ Title = ar, Desc = aq.Desc, Hover = true })
	f.Root:SetAttribute(ag.HoverThemeToken, e.Bg)
	local g = aj(
		"ImageLabel",
		{
			Name = "ButtonIcon",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(22, 22),
			Image = "rbxassetid://108148383005386",
			ImageColor3 = ab.GetThemeProperty("SubText") or Color3.fromRGB(160, 160, 160),
			[ab.ThemeTag] = { ImageColor3 = "SubText" },
		}
	)
	g.Parent = f.Container
	local h, i, j, k =
		TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		false
	local l, m, n, o =
		function()
			j = true
			k = ad.GetPressPosition()
			ac.Tween(g, { Size = UDim2.fromOffset(18, 18) }, h)
		end, function()
			if not j then
				return
			end
			j = false
			ac.Tween(g, { Size = UDim2.fromOffset(22, 22) }, i)
		end, function(l, m, n)
			ab.RemoveThemeObject(l)
			ab.AddThemeObject(l, { TextColor3 = m })
			ac.Tween(l, { TextColor3 = ab.GetThemeProperty(m) or n }, 0.3)
		end, "ButtonIconHover"
	local p = ab.GetThemeProperty(o) or ab.GetThemeProperty(e.Text) or Color3.fromRGB(240, 240, 240)
	local q = function(q)
		ab.RemoveThemeObject(g)
		if q then
			ab.AddThemeObject(g, { ImageColor3 = o })
			ac.Tween(g, { ImageColor3 = ab.GetThemeProperty(o) or p }, 0.3)
			if f.TitleLabel then
				n(f.TitleLabel, e.Text, Color3.fromRGB(240, 240, 240))
			end
			if f.DescLabel then
				n(f.DescLabel, e.Text, Color3.fromRGB(160, 160, 160))
			end
		else
			ab.AddThemeObject(g, { ImageColor3 = "SubText" })
			ac.Tween(g, { ImageColor3 = ab.GetThemeProperty("SubText") or Color3.fromRGB(160, 160, 160) }, 0.3)
			if f.TitleLabel then
				n(f.TitleLabel, "Text", Color3.fromRGB(240, 240, 240))
			end
			if f.DescLabel then
				n(f.DescLabel, "SubText", Color3.fromRGB(160, 160, 160))
			end
		end
	end
	if f.InteractButton then
		ab.TrackConnection(
			f.Root,
			f.InteractButton.MouseEnter:Connect(function()
				q(true)
			end)
		)
		ab.TrackConnection(
			f.Root,
			f.InteractButton.MouseLeave:Connect(function()
				q(false)
			end)
		)
		ab.TrackConnection(
			f.Root,
			f.InteractButton.MouseButton1Down:Connect(function()
				l()
			end)
		)
		ab.TrackConnection(
			f.Root,
			f.InteractButton.MouseButton1Up:Connect(function()
				m()
			end)
		)
		ab.TrackConnection(
			f.Root,
			f.InteractButton.MouseButton1Click:Connect(function()
				m()
				local r = k
				k = nil
				if ad.ShouldSuppressClickFrom(r) then
					return
				end
				local s = aq.Callback
				if s then
					ae.Call(s)
				end
			end)
		)
	end
	local r = {}
	r.Root = f.Root
	r.Type = "Button"
	function r.Mount(s, t)
		f:Mount(t)
	end
	function r.SetTitle(s, t)
		f:SetTitle(t)
	end
	function r.SetDesc(s, t)
		f:SetDesc(t)
	end
	function r.SetCallback(s, t)
		aq.Callback = t
	end
	function r.Destroy(s)
		ac.CancelInstance(g)
		f:Destroy()
	end
	return r
end
return al
end
a["Elements/ColorPicker"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af = aa.Creator, d("Core/SafeCall"), d("Core/Types"), d("UI/Element"), d("Localization/Localization")
local ag, ah = ab.New, {}
ah.__type = "ColorPicker"
local ai, aj, ak = 22, 6, Color3.fromRGB(40, 34, 165)
function ah.New(al, am, an, ao)
	local ap, aq = an or {}
	if af.IsTagged(ap.Title) then
		aq = ap.Title
	else
		aq = (type(am) == "string" and am) or ap.Title or ""
	end
	local ar, as, at =
		ap.Default or ak, math.clamp(ap.Alpha or 1, 0, 1), ae.New({ Title = aq, Desc = ap.Desc, Hover = true })
	local e = ag(
		"Frame",
		{ Name = "ColorPreview", BackgroundColor3 = ar, BorderSizePixel = 0, Size = UDim2.fromOffset(ai, ai) },
		{
			ag("UICorner", { CornerRadius = UDim.new(0, aj) }),
			ag(
				"UIStroke",
				{
					Color = ab.GetThemeProperty("DropdownStroke") or Color3.fromRGB(240, 240, 240),
					Transparency = ab.GetThemeProperty("DropdownStrokeTransparency") or 0.9,
					[ab.ThemeTag] = { Color = "DropdownStroke", Transparency = "DropdownStrokeTransparency" },
				}
			),
		}
	)
	e.Parent = at.Container
	local f = function()
		e.BackgroundColor3 = ar
	end
	local g, h =
		function(g, h)
			ar = g
			as = math.clamp(h, 0, 1)
			f()
			local i = ap.LiveCallback
			if i then
				ac.Call(i, ar, as)
			end
		end, function(g, h)
			ar = g
			as = math.clamp(h, 0, 1)
			f()
			local i = ap.Callback
			if i then
				ac.Call(i, ar, as)
			end
		end
	local i = function()
		local i = ao and ao.Window
		if not i or type(i.Modal) ~= "function" then
			return
		end
		i:Modal({
			Title = ap.ModalTitle or (aq ~= "" and aq) or d("Localization/Localization").t("dialog.colorPicker.defaultTitle"),
			Draggable = true,
			AllowStacked = true,
			AllowOverlayDismiss = false,
			SnapshotMode = "Isolated",
			Build = function(j)
				j:AddColorPicker({
					Default = ar,
					Alpha = as,
					Mode = ap.Mode,
					ApplyText = ap.ApplyText,
					LiveThreshold = ap.LiveThreshold,
					LiveDebounce = ap.LiveDebounce,
					LiveCallback = g,
					Callback = h,
					OnApply = function()
						(j):Close("apply")
					end,
				})
			end,
		})
	end
	if at.InteractButton then
		ab.TrackConnection(at.Root, at.InteractButton.MouseButton1Click:Connect(i))
	end
	local j = { Root = at.Root, Type = "ColorPicker" }
	function j.Mount(k, l)
		at:Mount(l)
	end
	function j.GetValue(k)
		return ar, as
	end
	function j.SetValue(k, l, m)
		ar = l
		if m ~= nil then
			as = math.clamp(m, 0, 1)
		end
		f()
	end
	function j.SetTitle(k, l)
		at:SetTitle(l)
	end
	function j.SetDesc(k, l)
		at:SetDesc(l)
	end
	function j.Pack(k)
		return { R = ar.R, G = ar.G, B = ar.B, A = as }
	end
	function j.Unpack(k, l, m)
		if type(l) ~= "table" then
			return
		end
		local n, o, p = tonumber(l.R), tonumber(l.G), tonumber(l.B)
		if n == nil or o == nil or p == nil then
			return
		end
		ar = Color3.new(math.clamp(n, 0, 1), math.clamp(o, 0, 1), math.clamp(p, 0, 1))
		as = math.clamp(tonumber(l.A) or as, 0, 1)
		f()
		if m and m.Callbacks == true then
			local q = ap.Callback
			if q then
				ac.Call(q, ar, as)
			end
		end
	end
	j.Save = j.Pack
	j.Load = j.Unpack
	function j.Destroy(k)
		at:Destroy()
	end
	return j
end
return ah
end
a["Elements/ColorPickerInputs"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag = aa.Creator, aa.Animator, d("Core/SafeCall"), d("Core/ColorUtil"), d("Elements/InputField"), d("Elements/Select")
local ah, ai = ab.New, {}
local aj = 28
local ak, al, am, an = aj, 8, 4, 70
local ao = ae.PanelWidth - an - al
local ap, aq, ar =
	math.floor((ao - am * 2) / 3), function(ap, aq, ar)
		local as, at = "", af.Create({ MultiLine = false, Text = "", Placeholder = aq, FieldHeight = aj, ShellSize = UDim2.new(1, 0, 0, aj) })
		local e, f, g, h, i = at.TextBox, at.FieldShell, at.FieldStroke, false, aa.AnimTokens.Preset.Focus
		local j = function(j, k)
			as = j
			h = true
			e.Text = j
			h = false
			if k then
				ad.Call(ar)
			end
		end
		ab.TrackConnection(
			f,
			e:GetPropertyChangedSignal("Text"):Connect(function()
				if h then
					return
				end
				as = e.Text
			end)
		)
		ab.TrackConnection(
			f,
			e.Focused:Connect(function()
				ac.Tween(g, { Transparency = at.FocusedStrokeTransparency }, i)
			end)
		)
		ab.TrackConnection(
			f,
			e.FocusLost:Connect(function()
				ac.Tween(g, { Transparency = at.RestingStrokeTransparency }, i)
				j(e.Text, true)
			end)
		)
		f.Parent = ap
		local k = {}
		function k.GetValue(l)
			return as
		end
		function k.SetValue(l, m)
			j(m, false)
		end
		function k.Destroy(l)
			ac.CancelInstance(g)
			ab.CleanupInstance(f)
			f:Destroy()
		end
		return k
	end, function(ap)
		return ah("Frame", { AnchorPoint = Vector2.new(0, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0), Size = UDim2.new(1, 0, 1, 0), Visible = ap }, { ah("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, am), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }) })
	end
local as, at =
	function(as, at)
		local e, f, g = ar(at), -math.round(am * (as - 1) / as), {}
		for h = 1, as do
			local i = ah("Frame", { BackgroundTransparency = 1, LayoutOrder = h, Size = UDim2.new(1 / as, f, 1, 0), Parent = e })
			g[h] = i
		end
		return e, g
	end, function(as, at, e)
		local f, g = ah("Frame", { AnchorPoint = Vector2.new(0, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0), Visible = e, Size = UDim2.new(0, 0, 1, 0) }, { ah("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, am), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }) }), {}
		for h = 1, as do
			local i = ah("Frame", { BackgroundTransparency = 1, LayoutOrder = h, Size = UDim2.new(0, at, 1, 0), Parent = f })
			g[h] = i
		end
		return f, g
	end
function ai.Build(e)
	local f, g =
		{ Inputs = {}, Groups = {} },
		ah(
			"Frame",
			{ AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Size = UDim2.fromOffset(
				ae.PanelWidth,
				0
			) }
		)
	local h = ah(
		"Frame",
		{ AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, ak), Parent = g },
		{
			ah(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, al),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}
			),
		}
	)
	local i, j =
		ah("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(an, ak), Parent = h }),
		ah("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(ao, ak), Parent = h })
	f.FormatSelect = ag:New("", {
		Title = "",
		CompactChrome = true,
		StretchShell = true,
		Height = aj,
		Options = { { Label = "HSL", Value = "HSL" }, { Label = "RGB", Value = "RGB" }, { Label = "Hex", Value = "HEX" } },
		Default = { e.Mode },
		MaxSelection = 1,
		Callback = function(k)
			if type(k) == "string" then
				e.OnFormatChanged(k)
			end
		end,
	})
	f.FormatSelect:Mount(i)
	local k, l = at(3, ap, e.Mode == "HSL")
	k.Parent = j
	f.Groups.HSL = k
	f.Inputs.H = aq(l[1], "H", e.OnValuesSubmitted)
	f.Inputs.S = aq(l[2], "S", e.OnValuesSubmitted)
	f.Inputs.L = aq(l[3], "L", e.OnValuesSubmitted)
	local m, n = as(4, e.Mode == "RGB")
	m.Parent = j
	f.Groups.RGB = m
	f.Inputs.R = aq(n[1], "R", e.OnValuesSubmitted)
	f.Inputs.G = aq(n[2], "G", e.OnValuesSubmitted)
	f.Inputs.B = aq(n[3], "B", e.OnValuesSubmitted)
	f.Inputs.AlphaPct = aq(n[4], "%", e.OnValuesSubmitted)
	local o, p = as(1, e.Mode == "HEX")
	o.Parent = j
	f.Groups.HEX = o
	f.Inputs.Hex = aq(p[1], "#", e.OnValuesSubmitted)
	f.Host = g
	return f
end
function ai.SetMode(e, f)
	for g, h in e.Groups do
		h.Visible = g == f
	end
end
function ai.Destroy(e)
	e.FormatSelect:Destroy()
	for f, g in pairs(e.Inputs) do
		if g and g.Destroy then
			g:Destroy()
		end
	end
end
return table.freeze(ai)
end
a["Elements/ColorPickerPanel"]=function()
local aa, ab = game:GetService("UserInputService"), d("Core/Common")
local ac, ad, ae, af, ag, ah, ai, aj, ak =
	ab.SignalManager, ab.WindowDrag, ab.Animator, d("Core/SafeCall"), d("Core/Types"), d("Core/ColorUtil"), d("Elements/ColorPickerInputs"), d("Elements/ColorPickerPanelView"), {}
ak.__type = "ColorPicker"
function ak.New(al, am, an, ao)
	local ap, aq = an or {}, ac.CreateScope()
	local ar = ap.Default or Color3.fromRGB(40, 34, 165)
	local as, at, e = Color3.toHSV(ar)
	local f, g, h, i, j, k, l, m, n, o, p, q, r, s =
		math.clamp(ap.Alpha or 1, 0, 1),
		ap.Mode or "HSL",
		math.max(0, ap.LiveThreshold or 0.01),
		math.max(0, ap.LiveDebounce or 0.05),
		-math.huge,
		-math.huge,
		-math.huge,
		-math.huge,
		-math.huge,
		function()
			return Color3.fromHSV(as, at, e)
		end,
		-math.huge
	local t, u, v =
		function()
			local t = o()
			if as ~= p then
				s.HueBase.BackgroundColor3 = Color3.fromHSV(as, 1, 1)
				p = as
			end
			s.PanelCursor.Position = UDim2.fromScale(at, 1 - e)
			s.HueCursor.Position = UDim2.fromScale(as, 0.5)
			s.AlphaCursor.Position = UDim2.fromScale(f, 0.5)
			s.AlphaFill.BackgroundColor3 = t
			s.ColorPreview.BackgroundColor3 = t
			local u = s.Controls.Inputs
			if g == "HEX" then
				u.Hex:SetValue(ah.ToHex(t))
			elseif g == "RGB" then
				u.R:SetValue(tostring(math.round(t.R * 255)))
				u.G:SetValue(tostring(math.round(t.G * 255)))
				u.B:SetValue(tostring(math.round(t.B * 255)))
				u.AlphaPct:SetValue(("%d%%"):format(math.round(f * 100)))
			else
				local v, w, x = ah.ToHsl(t)
				u.H:SetValue(tostring(math.round(v * 360)))
				u.S:SetValue(tostring(math.round(w * 100)))
				u.L:SetValue(tostring(math.round(x * 100)))
			end
			local v = ah.ContrastForeground(t)
			ae.Set(s.ApplyFill, { BackgroundColor3 = t })
			ae.Set(s.ApplyLabel, { TextColor3 = v })
			ae.Set(s.ApplyIcon, { ImageColor3 = v })
		end, function()
			j = -math.huge
			k, l, m, n = as, at, e, f
			local t = ap.Callback
			if t then
				af.Call(t, o(), f)
			end
		end, function()
			local t = ap.LiveCallback
			if not t then
				return
			end
			local u = os.clock()
			local v, w = u - j, math.max(math.abs(as - k), math.abs(at - l), math.abs(e - m), math.abs(f - n))
			if w < h or v < i then
				return
			end
			j = u
			k, l, m, n = as, at, e, f
			af.Call(t, o(), f)
		end
	local w, x, y =
		function()
			local w
			if g == "HEX" then
				w = ah.ParseHex(s.Controls.Inputs.Hex:GetValue())
			elseif g == "RGB" then
				w = ah.ParseRgb(("%s, %s, %s"):format(s.Controls.Inputs.R:GetValue(), s.Controls.Inputs.G:GetValue(), s.Controls.Inputs.B:GetValue()))
				local x = s.Controls.Inputs.AlphaPct:GetValue():gsub("%%", ""):match("^%s*(.-)%s*$") or ""
				local y = tonumber(x)
				if y then
					f = math.clamp(y / 100, 0, 1)
				end
			else
				w = ah.ParseHsl(("%s, %s, %s"):format(s.Controls.Inputs.H:GetValue(), s.Controls.Inputs.S:GetValue(), s.Controls.Inputs.L:GetValue()))
			end
			if not w then
				t()
				return
			end
			as, at, e = Color3.toHSV(w)
			t()
			u()
		end, function(w)
			at, e = ah.PointInPanel(s.HueBase, w)
			t()
			v()
		end, function(w, x, y)
			local z = ah.PointInX(w, x)
			if y == "Hue" then
				as = z
			else
				f = z
			end
			t()
			v()
		end
	local z, A =
		function(z)
			if q == "Panel" then
				x(z)
			elseif q == "Hue" then
				y(s.HueSlider, z, "Hue")
			elseif q == "Alpha" then
				y(s.AlphaSlider, z, "Alpha")
			end
		end, function(z)
			local A = q ~= nil
			q = nil
			if r then
				r:Destroy()
				r = nil
			end
			if A and z == true then
				u()
			end
		end
	local B = function()
		if r then
			return
		end
		local B = ac.CreateScope()
		r = B
		B:Connect(aa.InputChanged, function(C)
			if C.UserInputType ~= Enum.UserInputType.MouseMovement and C.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			z(C)
		end)
		B:Connect(aa.InputEnded, function(C)
			if C.UserInputType == Enum.UserInputType.MouseButton1 or C.UserInputType == Enum.UserInputType.Touch then
				A(true)
			end
		end)
	end
	aq:Defer(function()
		A(false)
	end)
	local C = function(C, D)
		q = C
		B()
		z(D)
	end
	s = aj.Build({
		Hue = as,
		InitialColor = ar,
		Mode = g,
		ApplyText = ap.ApplyText or d("Localization/Localization").t("common.actions.save"),
		OnPanelBegin = function(D)
			C("Panel", D)
		end,
		OnHueBegin = function(D)
			C("Hue", D)
		end,
		OnAlphaBegin = function(D)
			C("Alpha", D)
		end,
		OnFormatChanged = function(D)
			if D == "HSL" or D == "RGB" or D == "HEX" then
				g = D
				ai.SetMode(s.Controls, g)
				t()
			end
		end,
		OnValuesSubmitted = w,
	})
	aq:Connect(s.ApplyButton.Activated, function()
		if ad.ShouldSuppressClick() then
			return
		end
		u()
		local D = ap.OnApply
		if D then
			af.Call(D)
		end
	end)
	local D = { Root = s.Root, Type = "ColorPicker" }
	function D.Mount(E, F)
		s.Root.Parent = F
		t()
	end
	function D.SetValue(E, F, G)
		as, at, e = Color3.toHSV(F)
		if G ~= nil then
			f = math.clamp(G, 0, 1)
		end
		t()
	end
	function D.GetValue(E)
		return o(), f
	end
	function D.Pack(E)
		local F = o()
		return { R = F.R, G = F.G, B = F.B, A = f }
	end
	function D.Unpack(E, F, G)
		if type(F) ~= "table" then
			return
		end
		local H, I, J = tonumber(F.R), tonumber(F.G), tonumber(F.B)
		if H == nil or I == nil or J == nil then
			return
		end
		local K = Color3.new(math.clamp(H, 0, 1), math.clamp(I, 0, 1), math.clamp(J, 0, 1))
		as, at, e = Color3.toHSV(K)
		f = math.clamp(tonumber(F.A) or f, 0, 1)
		t()
		if G ~= nil and G.Callbacks == true then
			u()
		end
	end
	D.Save = D.Pack
	D.Load = D.Unpack
	function D.Destroy(E)
		aq:Destroy()
		ai.Destroy(s.Controls)
		s.Root:Destroy()
	end
	return D
end
return ak
end
a["Elements/ColorPickerPanelView"]=function()
local aa = d("Core/Common")
local ab, ac, ad = aa.Creator, d("Core/ColorUtil"), d("Elements/ColorPickerInputs")
local ae, af = ab.New, {}
local ag, ah =
	function(ag)
		return ae("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 10,
			[ab.InputBegan] = function(ah)
				if ah.UserInputType == Enum.UserInputType.MouseButton1 or ah.UserInputType == Enum.UserInputType.Touch then
					ag(ah)
				end
			end,
		})
	end, function(ag, ah, ai, aj)
		return ae("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = aj and 1 or 0,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(ai, ai),
			ZIndex = 9,
			[ab.Ref] = function(ak)
				ag[ah] = ak
			end,
		}, { ae("UICorner", { CornerRadius = UDim.new(1, 0) }), (aj and { (ae("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 3 })) } or { nil })[1] })
	end
local ai, aj =
	function(ai, aj, ak)
		return ae("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.fromOffset(ac.PanelWidth, ac.PanelHeight) }, { ae("UICorner", { CornerRadius = UDim.new(0, 12) }), ae("UIStroke", { Color = ac.Theme("DialogBorder", Color3.fromRGB(240, 240, 240)), Transparency = 0.88, [ab.ThemeTag] = { Color = "DialogBorder" } }), ae("Frame", {
			BackgroundColor3 = Color3.fromHSV(aj, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			[ab.Ref] = function(al)
				ai.HueBase = al
			end,
		}, { ae("UICorner", { CornerRadius = UDim.new(0, 12) }) }), ae("Frame", { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, { ae("UICorner", { CornerRadius = UDim.new(0, 12) }), ae("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) }) }), ae("Frame", { BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, { ae("UICorner", { CornerRadius = UDim.new(0, 12) }), ae("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }) }), ah(ai, "PanelCursor", 18, true), ag(ak) })
	end, function(ai, aj, ak, al, am)
		local an = table.clone(al)
		table.insert(an, ah(ai, ak, 10, false))
		table.insert(an, ag(am))
		return ae("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, ac.SliderHeight),
			[ab.Ref] = function(ao)
				ai[aj] = ao
			end,
		}, an)
	end
local ak, al, am, an, ao, ap, aq =
	function(ak, al, am, an)
		return ae("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(ac.PanelWidth, ac.PreviewSize) }, { ae("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }), ae("Frame", {
			BackgroundColor3 = al,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(ac.PreviewSize, ac.PreviewSize),
			[ab.Ref] = function(ao)
				ak.ColorPreview = ao
			end,
		}, { ae("UICorner", { CornerRadius = UDim.new(0, 9) }), ae("UIStroke", { Color = ac.Theme("InputStroke", Color3.fromRGB(240, 240, 240)), Transparency = ac.Theme("InputStrokeTransparency", 0.85), [ab.ThemeTag] = { Color = "InputStroke", Transparency = "InputStrokeTransparency" } }) }), ae("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -ac.PreviewSize - 10, 1, 0) }, { ae("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }), aj(ak, "HueSlider", "HueCursor", { ae("UICorner", { CornerRadius = UDim.new(1, 0) }), ae("UIGradient", { Color = ac.HueSequence }) }, am), aj(ak, "AlphaSlider", "AlphaCursor", { ae("UICorner", { CornerRadius = UDim.new(1, 0) }), ae("Frame", {
			BackgroundColor3 = al,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			[ab.Ref] = function(ao)
				ak.AlphaFill = ao
			end,
		}, { ae("UICorner", { CornerRadius = UDim.new(1, 0) }), ae("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.88), NumberSequenceKeypoint.new(1, 0) }) }) }) }, an) }) })
	end, 30, 14, 14, 6, "rbxassetid://12187365364", "rbxassetid://10709790644"
local ar = function(ar, as, at)
	local e = ac.ContrastForeground(at)
	return ae(
		"TextButton",
		{
			Name = "ApplyPill",
			AutoButtonColor = false,
			BackgroundColor3 = at,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, al),
			Text = "",
			[ab.Ref] = function(f)
				ar.ApplyFill = f
				ar.ApplyButton = f
			end,
		},
		{
			ae("UICorner", { CornerRadius = UDim.new(0, 12) }),
			ae("UIPadding", { PaddingLeft = UDim.new(0, am), PaddingRight = UDim.new(0, am) }),
			ae(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, ao),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}
			),
			ae("ImageLabel", {
				Name = "ApplyIcon",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = aq,
				ImageColor3 = e,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(an, an),
				ZIndex = 93,
				[ab.Ref] = function(f)
					ar.ApplyIcon = f
				end,
			}),
			ae("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new(ap, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				LayoutOrder = 2,
				Size = UDim2.new(0, 0, 1, 0),
				Text = as,
				TextColor3 = e,
				TextSize = 15,
				ZIndex = 93,
				[ab.Ref] = function(f)
					ar.ApplyLabel = f
				end,
			}),
		}
	)
end
function af.Build(as)
	local at = {}
	at.Controls =
		ad.Build({ Mode = as.Mode, OnFormatChanged = as.OnFormatChanged, OnValuesSubmitted = as.OnValuesSubmitted })
	at.Root = ae(
		"Frame",
		{
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = ac.Theme("Element", Color3.fromRGB(255, 255, 255)),
			BackgroundTransparency = ac.Theme("ElementTransparency", 1),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(ac.RootWidth, 0),
			[ab.ThemeTag] = { BackgroundColor3 = "Element", BackgroundTransparency = "ElementTransparency" },
		},
		{
			ae(
				"UIListLayout",
				{
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}
			),
			ae("UIPadding", { PaddingBottom = UDim.new(0, 6), PaddingTop = UDim.new(0, 6) }),
			ai(at, as.Hue, as.OnPanelBegin),
			ak(at, as.InitialColor, as.OnHueBegin, as.OnAlphaBegin),
			at.Controls.Host,
			ar(at, as.ApplyText or d("Localization/Localization").t("common.actions.save"), as.InitialColor),
		}
	)
	return at
end
return table.freeze(af)
end
a["Elements/ConfigPrep"]=function()
local aa, ab, ac, ad =
	{},
	{ Toggle = true, Slider = true, Input = true, Keybind = true, Select = true, Dropdown = true, ColorPicker = true },
	function(aa)
		return type(aa) == "string" and aa:sub(1, 2) == "__"
	end,
	function(aa, ab)
		return function(...)
			if aa and aa.MarkSnapshotDirty then
				aa:MarkSnapshotDirty()
			end
			if type(ab) == "function" then
				return ab(...)
			end
		end
	end
function aa.PrepareConfig(ae, af, ag, ah)
	if not ab[ae] or ac(ag) or type(af) ~= "table" then
		return af
	end
	local ai = table.clone(af)
	ai.Callback = ad(ah, ai.Callback)
	ai.LiveCallback = ad(ah, ai.LiveCallback)
	return ai
end
return table.freeze(aa)
end
a["Elements/Dropdown"]=function()
local aa, ab, ac = d("Core/Types"), d("Elements/Select"), {}
ac.__type = "Dropdown"
function ac.New(ad, ae, af, ag)
	return ab:New(ae, af, ag)
end
return ac
end
a["Elements/Elements"]=function()
local aa, ab, ac, ad, ae, af, ag, ah, ai =
	d("Core/Scheduler"), d("Core/Types"), d("Elements/ConfigPrep"), d("Localization/Localization"), d("UI/Tooltip"), d("Elements/Schema"), d("Core/Logger"), d("Elements/ToggleClassic"), function(aa)
		while aa do
			if aa:IsA("ScreenGui") then
				return aa
			end
			aa = aa.Parent
		end
		return nil
	end
local aj, ak, al =
	function(aj)
		if ad.IsTagged(aj) then
			return ad.ResolveTag(aj)
		end
		return (type(aj) == "string" and aj ~= "" and { aj } or { nil })[1]
	end, { d("Elements/Label"), d("Elements/Paragraph"), d("Elements/Toggle"), d("Elements/Button"), d("Elements/Slider"), d("Elements/Input"), d("Elements/Keybind"), d("Elements/Select"), d("Elements/Dropdown"), d("Elements/ColorPicker"), d("Elements/InfoRow") }, {}
al.__index = al
al.__namecall = function(am, an, ...)
	local ao = al[an]
	if ao then
		return ao(am, ...)
	end
	error(("Elements: unknown method '%s'"):format(tostring(an)), 2)
end
for am, an in ipairs(ak) do
	local ao = an.__type
	assert(type(ao) == "string", "Elements: Component __type must be a string")
	al["Add" .. ao] = function(ap, aq, ar)
		local as, at, e = {
			Container = ap.Container,
			ScrollFrame = ap.ScrollFrame,
			Window = ap.Window,
			ColumnCount = ap.ColumnCount,
			Registry = ap.Registry,
		}
		if type(aq) == "table" and not ad.IsTagged(aq) and ar == nil then
			e = aq
			if ad.IsTagged(e.Title) then
				at = ad.ResolveTag(e.Title) or ""
			else
				at = e.Title or ""
			end
		else
			at = aq
			e = ar
		end
		local f
		if type(e) == "table" and type(e.Idx) == "string" and e.Idx ~= "" then
			f = e.Idx
		elseif type(at) == "string" and at ~= "" then
			f = at
		end
		e = ac.PrepareConfig(ao, e, f, ap.Window)
		local g = an
		if ao == "Toggle" then
			local h = true
			if ap.Window and ap.Window.GetUseClassicToggle then
				h = ap.Window:GetUseClassicToggle()
			end
			g = (h and { ah } or { an })[1]
		end
		local h = g:New(at, e, as)
		if h then
			if ao == "Toggle" and ap.Window and ap.Window._RegisterToggle then
				ap.Window:_RegisterToggle(h)
			end
			if f then
				local i = function(i)
					if ad.IsTagged(i) then
						return ad.ResolveTag(i)
					end
					return (type(i) == "string" and { i } or { nil })[1]
				end
				h._SnapshotMeta = {
					Idx = f,
					Title = i((type(e) == "table" and { e.Title } or { nil })[1]) or tostring(at or ""),
					Desc = i((type(e) == "table" and { e.Desc } or { nil })[1]),
					TitleSource = (type(e) == "table" and { e.Title } or { nil })[1],
					DescSource = (type(e) == "table" and { e.Desc } or { nil })[1],
					Group = {
						TabSource = ap._GroupTabSource,
						SectionSource = ap._GroupSectionSource,
						SectionOrder = ap._GroupSectionOrder or 0,
						ElementOrder = (ap._ElementOrder or 0) + 1,
					},
					Field = af.Describe(ao, (type(e) == "table" and { e } or { {} })[1]),
					Dynamic = type(e) == "table" and e.Dynamic == true,
				}
				if
					h._SnapshotMeta.Dynamic
					and type(h.SetOptions) == "function"
					and ap.Window
					and ap.Window.ReportSnapshotOptions
				then
					local j, k = ap.Window, f
					local l, m =
						function(l)
							if type(l) == "table" then
								j:ReportSnapshotOptions(k, l)
							end
						end, h.SetOptions
					function h.SetOptions(n, o)
						m(n, o)
						l(o)
					end
					local n = (type(e) == "table" and { e.Options } or { nil })[1]
					if type(n) == "table" then
						task.defer(l, n)
					end
				end
			end
			ap._ElementOrder = (ap._ElementOrder or 0) + 1
			if h.Root then
				h.Root.LayoutOrder = ap._ElementOrder
			end
			local i = ap._Children
			if not i then
				i = {}
				ap._Children = i
			end
			table.insert(i, h)
			if h.Mount then
				local j = ap.Container
				local k, l =
					aa.DeferOwned(h, function()
						if j and j.Parent then
							h:Mount(j)
						end
					end, "Normal"), h.Destroy
				function h.Destroy(m)
					aa.InvalidateOwner(m)
					k.Cancel()
					if l then
						l(m)
					end
				end
			end
			if h.Pack and f and ap.Registry then
				local j = ap.Registry[f]
				if j and j ~= h then
					ag.Warn(
						([[[SeaHub:Snapshot] Duplicate registry key '%s'. Use unique 'Idx' in element config.]]):format(
							f
						)
					)
				end
				ap.Registry[f] = h
				h._Registry = ap.Registry
				h._RegistryKey = f
				local k, l = h.Destroy, false
				function h.Destroy(m)
					if l then
						return
					end
					l = true
					if m._Registry and m._RegistryKey then
						m._Registry[m._RegistryKey] = nil
						m._Registry = nil
						m._RegistryKey = nil
					end
					if k then
						k(m)
					end
				end
			end
		end
		local i = (type(e) == "table" and { (aj(e.Tooltip)) } or { nil })[1]
		if h and i and h.Root then
			local j = (type(e) == "table" and { (aj(e.TooltipDesc)) } or { nil })[1]
			aa.DeferOwned(h, function()
				local k, l = (h.InteractButton or h.Root), ai(h.Root)
				if not k or not l then
					return
				end
				local m = ae.Get(l)
				local n, o = m:Attach(k, i, j), h.Destroy
				function h.Destroy(p)
					n()
					if o then
						o(p)
					end
				end
			end, "Normal")
		end
		return h
	end
end
al.AddSwitch = al.AddToggle
return al
end
a["Elements/InfoRow"]=function()
local aa = d("Core/Common")
local ab, ac, ad = aa.Creator, d("Core/Types"), d("UI/Element")
local ae, af = ab.New, {}
af.__type = 'InfoRow'
local ag, ah, ai, aj = 'rbxassetid://12187365364', function(ag, ah)
	local ai = ab.GetThemeProperty(ag)
	return(ai ~= nil and{ai}or{ah})[1]
end, {
	Accent = {
		Bg = 'Accent',
		Text = 'AccentForeground',
		Transparency = 0.15,
		Bg3 = Color3.fromRGB(255, 185, 255),
		Text3 = Color3.fromRGB(20, 24, 6)
	},
	Outline = {
		Bg = 'VariantOutlineBg',
		Text = 'VariantOutlineText',
		Transparency = 0.9,
		Bg3 = Color3.fromRGB(140, 140, 140),
		Text3 = Color3.fromRGB(240, 240, 240)
	},
	Destructive = {
		Bg = 'VariantDestructiveBg',
		Text = 'VariantDestructiveText',
		Transparency = 0.4,
		Bg3 = Color3.fromRGB(127, 29, 29),
		Text3 = Color3.fromRGB(240, 78, 78)
	},
	Warning = {
		Bg = 'VariantWarningBg',
		Text = 'VariantWarningText',
		Transparency = 0.4,
		Bg3 = Color3.fromRGB(120, 53, 15),
		Text3 = Color3.fromRGB(251, 191, 36)
	},
	Success = {
		Bg = 'VariantSuccessBg',
		Text = 'VariantSuccessText',
		Transparency = 0.4,
		Bg3 = Color3.fromRGB(20, 83, 45),
		Text3 = Color3.fromRGB(74, 222, 128)
	},
	Info = {
		Bg = 'VariantInfoBg',
		Text = 'VariantInfoText',
		Transparency = 0.4,
		Bg3 = Color3.fromRGB(30, 58, 138),
		Text3 = Color3.fromRGB(96, 165, 250)
	},
	Muted = {
		Bg = 'VariantMutedBg',
		Text = 'VariantMutedText',
		Transparency = 0.5,
		Bg3 = Color3.fromRGB(64, 64, 64),
		Text3 = Color3.fromRGB(163, 163, 163)
	}
}, {
	TextAccent = {Text = 'TextAccent', Text3 = Color3.fromRGB(255, 185, 255)},
	TextDestructive = {Text = 'TextDestructive', Text3 = Color3.fromRGB(248, 113, 113)},
	TextWarning = {Text = 'TextWarning', Text3 = Color3.fromRGB(251, 191, 36)},
	TextSuccess = {Text = 'TextSuccess', Text3 = Color3.fromRGB(74, 222, 128)},
	TextInfo = {Text = 'TextInfo', Text3 = Color3.fromRGB(96, 165, 250)},
	TextMuted = {Text = 'TextMuted', Text3 = Color3.fromRGB(140, 140, 140)}
}
local ak = function(ak, al)
	return Font.new(ah('FontFamily', ag), ah(ak, al), Enum.FontStyle.Normal)
end
local al, am, an = function(al, am)
	local an = ai[am]or ai.Accent
	return ae('TextLabel', {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = ah(an.Bg, an.Bg3),
		BackgroundTransparency = an.Transparency,
		BorderSizePixel = 0,
		FontFace = ak('FontWeightMedium', Enum.FontWeight.Medium),
		Size = UDim2.fromOffset(0, 22),
		Text = al,
		TextColor3 = ah(an.Text, an.Text3),
		TextSize = ah('TextSizeCaption', 14),
		[ab.ThemeTag] = {BackgroundColor3 = an.Bg, TextColor3 = an.Text}
	}, {
		ae('UICorner', {CornerRadius = ah('CornerRadiusFull', UDim.new(1, 0))}),
		ae('UIPadding', {
			PaddingLeft = UDim.new(0, 9),
			PaddingRight = UDim.new(0, 9),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2)
		})
	})
end, function(al, am)
	local an = (am and{(aj[am])}or{nil})[1]
	local ao, ap = (an and{(an.Text)}or{'Text'})[1], (an and{(an.Text3)}or{(Color3.fromRGB(240, 240, 240))})[1]
	return ae('TextLabel', {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		FontFace = ak('FontWeightMedium', Enum.FontWeight.Medium),
		Size = UDim2.fromOffset(0, 22),
		Text = al,
		TextColor3 = ah(ao, ap),
		TextSize = ah('TextSizeSmall', 15),
		TextXAlignment = Enum.TextXAlignment.Right,
		[ab.ThemeTag] = {TextColor3 = ao, TextSize = 'TextSizeSmall'}
	})
end, function(al)
	if type(al) == 'string'and(ai[al]or aj[al])then
		return al
	end
	return nil
end function af.New(ao, ap, aq, ar)
	local as = aq or{}
	local at, e = (type(ap) == 'string'and ap)or as.Title or'', (as.Value ~= nil and{(tostring(as.Value))}or{'\u{2014}'})[1]
	local f = ad.New{Title = at, Desc = as.Desc}
	local g, h = ((f.Container))
	local i = function(i, j)
		if h then
			h:Destroy()
		end
		if j and ai[j]then
			h = al(i, j)
		else
			h = am(i, j)
		end
		h.Parent = g
	end
	i(e, an(as.Variant))
	local j = {Root = f.Root, Type = 'InfoRow'}function j.Mount(k, l)
		f:Mount(l)
	end function j.SetTitle(k, l)
		f:SetTitle(l)
	end function j.SetValue(k, l, m)
		i((l ~= nil and{(tostring(l))}or{'\u{2014}'})[1], an(m))
	end
	local k = false function j.Destroy(l)
		if k then
			return
		end
		k = true
		if h then
			h:Destroy()
		end
		f:Destroy()
	end
	return j
end
return af
end
a["Elements/Input"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag, ah = aa.Creator, aa.Animator, d("Core/SafeCall"), d("UI/Element"), d("Core/Types"), d("Elements/InputField"), d("Localization/Localization")
local ai, aj = ab.New, {}
aj.__type = "Input"
function aj.New(ak, al, am, an)
	local ao, ap = am or {}
	if ah.IsTagged(ao.Title) then
		ap = ao.Title
	elseif type(al) == "string" and (ao.Title == nil or ao.Title == "") then
		ap = al
	else
		ap = ao.Title or ""
	end
	local aq = ao.MultiLine or false
	local ar, as, at, e, f =
		(aq and { (ao.Height or 64) } or { (ao.Height or 24) })[1],
		ao.Default or "",
		ae.New({
			Title = ap,
			Desc = ao.Desc,
			Hover = false,
			Height = aq and 48 or 44,
			BelowRowSlot = aq,
			AlignControlsTop = aq,
			DescResize = true,
		}),
		aa.AnimTokens.Preset.Focus,
		""
	if ah.IsTagged(ao.Placeholder) then
		f = ah.ResolveTag(ao.Placeholder) or ""
	elseif type(ao.Placeholder) == "string" then
		f = ao.Placeholder
	end
	local g = ag.Create({ MultiLine = aq, Text = as, Placeholder = f, FieldHeight = ar })
	local h, i, j, k, l, m =
		g.FieldShell, g.TextBox, g.FieldStroke, g.RestingStrokeTransparency, g.FocusedStrokeTransparency, false
	local n = function(n, o)
		as = n
		m = true
		i.Text = n
		m = false
		if o then
			local p = ao.Callback
			if p then
				ad.Call(p, as)
			end
		end
	end
	ab.TrackConnection(
		at.Root,
		i:GetPropertyChangedSignal("Text"):Connect(function()
			if m then
				return
			end
			as = i.Text
			local o = ao.LiveCallback
			if o then
				ad.Call(o, as)
			end
		end)
	)
	if aq then
		local o = ai(
			"Frame",
			{
				Name = "TextareaBlock",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
			},
			{
				ai("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
				ai("UIPadding", { PaddingBottom = UDim.new(0, 2), PaddingTop = UDim.new(0, 2) }),
				h,
			}
		)
		o.Parent = at.BelowRow
	else
		h.Parent = at.Container
	end
	ab.TrackConnection(
		at.Root,
		i.Focused:Connect(function()
			ac.Tween(j, { Transparency = l }, e)
		end)
	)
	ab.TrackConnection(
		at.Root,
		i.FocusLost:Connect(function()
			ac.Tween(j, { Transparency = k }, e)
			n(i.Text, true)
		end)
	)
	local o = { Root = at.Root, Type = "Input" }
	function o.Mount(p, q)
		at:Mount(q)
	end
	function o.GetValue(p)
		return as
	end
	function o.SetValue(p, q)
		n(q, false)
	end
	function o.Pack(p)
		return as
	end
	function o.Unpack(p, q, r)
		if type(q) ~= "string" then
			return
		end
		n(q, r ~= nil and r.Callbacks == true)
	end
	o.Save = o.Pack
	o.Load = o.Unpack
	function o.SetTitle(p, q)
		at:SetTitle(q)
	end
	function o.SetDesc(p, q)
		at:SetDesc(q)
	end
	function o.SetPlaceholder(p, q)
		i.PlaceholderText = q
	end
	local p
	if ah.IsTagged(ao.Placeholder) then
		p = ah.Attach(o, "Placeholder", ao.Placeholder)
	end
	function o.Destroy(q)
		if p then
			p()
			p = nil
		end
		ac.CancelInstance(j)
		at:Destroy()
	end
	return o
end
return aj
end
a["Elements/InputField"]=function()
local aa = d("Core/Common")
local ab = aa.Creator
local ac, ad = ab.New, {}
function ad.Create(ae)
	local af, ag = ae.MultiLine == true, ae.Tokens or {}
	local ah, ai, aj, ak, al, am, an =
		ag.Bg or "InputBg",
		ag.BgTransparency or "InputBgTransparency",
		ag.Stroke or "InputStroke",
		ag.StrokeTransparency or "InputStrokeTransparency",
		ag.Text or "InputText",
		ag.Placeholder or "InputPlaceholder",
		ag.TextSize or "TextSizeCaption"
	local ao = ab.GetThemeProperty(ak) or 0.9
	local ap, aq, ar =
		math.clamp(ao - 0.3, 0, 1),
		ac(
			"TextBox",
			{
				FontFace = Font.new(
					ab.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
					ab.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = ae.Text,
				PlaceholderText = ae.Placeholder or "",
				PlaceholderColor3 = ab.GetThemeProperty(am) or Color3.fromRGB(140, 140, 140),
				TextColor3 = ab.GetThemeProperty(al) or Color3.fromRGB(255, 255, 255),
				TextSize = ab.GetThemeProperty(an) or (an == "TextSizeSmall" and 15 or 14),
				TextXAlignment = ae.TextXAlignment or Enum.TextXAlignment.Left,
				TextYAlignment = (af and { Enum.TextYAlignment.Top } or { Enum.TextYAlignment.Center })[1],
				TextWrapped = af,
				MultiLine = af,
				ClearTextOnFocus = false,
				ClipsDescendants = true,
				BackgroundTransparency = 1,
				TextEditable = (ae.TextEditable ~= nil and { ae.TextEditable } or { true })[1],
				Size = (ae.TextBoxSize and { ae.TextBoxSize } or {
					(af and { (UDim2.fromScale(1, 1)) } or { (UDim2.new(1, -10, 1, 0)) })[1],
				})[1],
				Position = (ae.TextBoxPosition and { ae.TextBoxPosition } or {
					(af and { (UDim2.fromScale(0, 0)) } or { (UDim2.new(0, 5, 0, 0)) })[1],
				})[1],
				[ab.ThemeTag] = { TextColor3 = al, PlaceholderColor3 = am, TextSize = an },
			}
		),
		ac(
			"UIStroke",
			{
				Color = ab.GetThemeProperty(aj) or Color3.fromRGB(240, 240, 240),
				Transparency = ao,
				[ab.ThemeTag] = { Color = aj, Transparency = ak },
			}
		)
	local as = { ac("UICorner"), ar, aq }
	if af then
		table.insert(
			as,
			ac(
				"UIPadding",
				{
					PaddingLeft = ab.GetThemeProperty("PaddingInput") or UDim.new(0, 8),
					PaddingRight = ab.GetThemeProperty("PaddingInput") or UDim.new(0, 8),
					PaddingTop = ab.GetThemeProperty("PaddingInputSmall") or UDim.new(0, 5),
					PaddingBottom = ab.GetThemeProperty("PaddingInputSmall") or UDim.new(0, 5),
					[ab.ThemeTag] = { PaddingLeft = "PaddingInput", PaddingRight = "PaddingInput" },
				}
			)
		)
	end
	local at
	if af then
		local e = ae.FieldHeight or 64
		at = UDim2.new(1, 0, 0, e)
	elseif ae.ShellSize then
		at = ae.ShellSize
	else
		at = UDim2.fromOffset(130, 22)
	end
	local e = ac(
		"Frame",
		{
			Name = "FieldShell",
			BackgroundColor3 = ab.GetThemeProperty(ah) or Color3.fromRGB(140, 140, 140),
			BackgroundTransparency = ab.GetThemeProperty(ai) or 0.9,
			BorderSizePixel = 0,
			Size = at,
			[ab.ThemeTag] = { BackgroundColor3 = ah, BackgroundTransparency = ai },
		},
		as
	)
	return { FieldShell = e, TextBox = aq, FieldStroke = ar, RestingStrokeTransparency = ao, FocusedStrokeTransparency = ap }
end
return ad
end
a["Elements/Keybind"]=function()
local aa, ab = game:GetService("UserInputService"), d("Core/Common")
local ac, ad, ae, af, ag, ah, ai, aj, ak =
	ab.Creator, ab.Animator, ab.WindowDrag, d("Core/SafeCall"), d("UI/Element"), d("Core/Types"), d("Elements/KeybindUtil"), d("Elements/KeybindCapture"), d("Localization/Localization")
local al = ac.New
local am = {}
am.__type = "Keybind"
local an, ao, ap =
	"...", "Toggle", function(an)
		return ((an == "Press" or an == "Toggle" or an == "Hold" or an == "Always") and { an } or { nil })[1]
	end
function am.New(aq, ar, as, at)
	local e, f = as or {}
	if ak.IsTagged(e.Title) then
		f = e.Title
	else
		f = (type(ar) == "string" and ar) or e.Title or ""
	end
	local g, h, i, j, k, l, m, n, o, p, q =
		ai.NormalizeBind(e.Default),
		ap(e.Mode) or ao,
		e.AllowMouse ~= false,
		e.AllowGamepad ~= false,
		e.IgnoreTextBox ~= false,
		false,
		false,
		{},
		{},
		(ag.New({ Title = f, Desc = e.Desc, Hover = false, Height = 44, DescResize = true }))
	local r, s =
		al(
			"TextLabel",
			{
				BackgroundTransparency = 1,
				FontFace = Font.new(
					ac.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
					ac.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = ai.DisplayBind(g),
				TextColor3 = ac.GetThemeProperty("InputText") or Color3.fromRGB(255, 255, 255),
				TextSize = ac.GetThemeProperty("TextSizeCaption") or 14,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(1, -12, 1, 0),
				Position = UDim2.new(0, 6, 0, 0),
				[ac.ThemeTag] = { TextColor3 = "InputText", TextSize = "TextSizeCaption" },
			}
		),
		al(
			"UIStroke",
			{
				Color = ac.GetThemeProperty("InputStroke") or Color3.fromRGB(240, 240, 240),
				Transparency = ac.GetThemeProperty("InputStrokeTransparency") or 0.9,
				[ac.ThemeTag] = { Color = "InputStroke", Transparency = "InputStrokeTransparency" },
			}
		)
	local t = al(
		"TextButton",
		{
			BackgroundColor3 = ac.GetThemeProperty("InputBg") or Color3.fromRGB(140, 140, 140),
			BackgroundTransparency = ac.GetThemeProperty("InputBgTransparency") or 0.9,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(96, 24),
			Text = "",
			[ac.ThemeTag] = { BackgroundColor3 = "InputBg", BackgroundTransparency = "InputBgTransparency" },
		},
		{ al("UICorner"), s, r }
	)
	t.Parent = p.Container
	local u, v = ab.AnimTokens.Preset.Focus, s.Transparency
	local w, x, y =
		math.clamp(v - 0.3, 0, 1), function()
			r.Text = (l and { an } or { (ai.DisplayBind(g)) })[1]
		end, function(w)
			local x = e.Callback
			if x then
				af.Call(x, w, ai.CloneBind(g))
			end
		end
	local z, A =
		function(z, A, B)
			g = ai.NormalizeBind(z)
			local C = ap(A)
			if C then
				h = C
			end
			m = false
			x()
			if B then
				local D = e.ChangedCallback
				if D then
					af.Call(D, ai.CloneBind(g))
				end
			end
		end, function()
			l = false
			aj.EndCapture(o)
			ad.Tween(s, { Transparency = v }, u)
			x()
		end
	local B, C =
		function()
			l = true
			aj.BeginCapture(o, function(B)
				if B.KeyCode == Enum.KeyCode.Escape then
					A()
					return
				end
				if B.KeyCode == Enum.KeyCode.Backspace then
					z(nil, nil, true)
					A()
					return
				end
				local C = ai.BindFromInput(B, i, j)
				if C then
					z(C, nil, true)
					A()
				end
			end)
			ad.Tween(s, { Transparency = w }, u)
			x()
		end, function(B)
			table.insert(n, B)
		end
	C(t.MouseButton1Down:Connect(function()
		q = ae.GetPressPosition()
	end))
	C(t.MouseButton1Click:Connect(function()
		local D = q
		q = nil
		if ae.ShouldSuppressClickFrom(D) then
			return
		end
		if l then
			A()
		else
			B()
		end
	end))
	function o.InputBegan(D, E)
		if l then
			return
		end
		if k and aa:GetFocusedTextBox() then
			return
		end
		if E or not ai.InputMatchesBind(D, g) then
			return
		end
		if h == "Toggle" then
			m = not m
			y(m)
		elseif h == "Press" or h == "Hold" then
			y(true)
		end
	end
	function o.InputEnded(D)
		if not l and h == "Hold" and ai.InputMatchesBind(D, g) then
			y(false)
		end
	end
	local D, E = aj.Register(o), { Root = p.Root, Type = "Keybind" }
	function E.Mount(F, G)
		p:Mount(G)
	end
	function E.GetValue(F)
		return ai.CloneBind(g)
	end
	function E.SetValue(F, G, H)
		z(G, H, false)
	end
	function E.GetState(F)
		if h == "Always" then
			return true
		end
		if h == "Hold" then
			return ai.IsBindDown(g)
		end
		return m
	end
	function E.SetMode(F, G)
		h = ap(G) or h
		m = false
	end
	function E.Capture(F)
		B()
	end
	function E.CancelCapture(F)
		A()
	end
	function E.Pack(F)
		return { Mode = h, Bind = ai.CloneBind(g) }
	end
	function E.Unpack(F, G, H)
		if type(G) == "table" then
			z(G.Bind or G.Key or G.key, G.Mode or G.mode, H ~= nil and H.Callbacks == true)
		else
			z(G, nil, H ~= nil and H.Callbacks == true)
		end
	end
	E.Save = E.Pack
	E.Load = E.Unpack
	function E.OnChanged(F, G)
		e.ChangedCallback = G
		af.Call(G, ai.CloneBind(g))
	end
	function E.SetTitle(F, G)
		p:SetTitle(G)
	end
	function E.SetDesc(F, G)
		p:SetDesc(G)
	end
	function E.Destroy(F)
		D()
		for G = #n, 1, -1 do
			n[G]:Disconnect()
			n[G] = nil
		end
		ad.CancelInstance(s)
		p:Destroy()
	end
	return E
end
return am
end
a["Elements/KeybindCapture"]=function()
local aa, ab = game:GetService("UserInputService"), {}
local ac, ad, ae, af, ag, ah = {}, 0
local ai, aj =
	function()
		if ae then
			return
		end
		ae = aa.InputBegan:Connect(function(ai, aj)
			if ag and ah then
				ah(ai)
				return
			end
			for ak in ac do
				local al = ak.InputBegan
				if al then
					al(ai, aj)
				end
			end
		end)
		af = aa.InputEnded:Connect(function(ai)
			for aj in ac do
				local ak = aj.InputEnded
				if ak then
					ak(ai)
				end
			end
		end)
	end, function()
		if ad > 0 or ag ~= nil then
			return
		end
		if ae then
			ae:Disconnect()
			ae = nil
		end
		if af then
			af:Disconnect()
			af = nil
		end
	end
function ab.Register(ak)
	if ac[ak] then
		return function() end
	end
	ac[ak] = true
	ad = ad + 1
	ai()
	local al = false
	return function()
		if al then
			return
		end
		al = true
		if ac[ak] then
			ac[ak] = nil
			ad = ad - 1
		end
		if ag == ak then
			ag = nil
			ah = nil
		end
		aj()
	end
end
function ab.BeginCapture(ak, al)
	ag = ak
	ah = al
	ai()
end
function ab.EndCapture(ak)
	if ag == ak then
		ag = nil
		ah = nil
		aj()
	end
end
return ab
end
a["Elements/KeybindUtil"]=function()
local aa, ab = game:GetService("UserInputService"), {}
local ac = d("Localization/Localization")
local ad = function()
	return ac.t("common.keybind.none")
end
function ab.CloneBind(ae)
	return ae and { Type = ae.Type, Name = ae.Name } or nil
end
function ab.NormalizeBind(ae)
	if ae == nil or ae == "" or ae == ad() then
		return nil
	end
	if typeof(ae) == "EnumItem" then
		if ae.EnumType == Enum.KeyCode then
			return { Type = "KeyCode", Name = ae.Name }
		end
		if ae.EnumType == Enum.UserInputType then
			return { Type = "UserInputType", Name = ae.Name }
		end
	end
	if type(ae) == "string" then
		if Enum.KeyCode[ae] then
			return { Type = "KeyCode", Name = ae }
		end
		local af = ae == "MouseLeft" and "MouseButton1" or (ae == "MouseRight" and "MouseButton2" or ae)
		if Enum.UserInputType[af] then
			return { Type = "UserInputType", Name = af }
		end
	end
	if type(ae) == "table" and type(ae.Type) == "string" and type(ae.Name) == "string" then
		if ae.Type == "KeyCode" and Enum.KeyCode[ae.Name] then
			return { Type = "KeyCode", Name = ae.Name }
		end
		if ae.Type == "UserInputType" and Enum.UserInputType[ae.Name] then
			return { Type = "UserInputType", Name = ae.Name }
		end
	end
	return nil
end
function ab.BindFromInput(ae, af, ag)
	if ae.UserInputType == Enum.UserInputType.Keyboard and ae.KeyCode ~= Enum.KeyCode.Unknown then
		return { Type = "KeyCode", Name = ae.KeyCode.Name }
	end
	if
		af
		and (
			ae.UserInputType == Enum.UserInputType.MouseButton1
			or ae.UserInputType == Enum.UserInputType.MouseButton2
			or ae.UserInputType == Enum.UserInputType.MouseButton3
		)
	then
		return { Type = "UserInputType", Name = ae.UserInputType.Name }
	end
	if ag and string.find(ae.UserInputType.Name, "Gamepad", 1, true) and ae.KeyCode ~= Enum.KeyCode.Unknown then
		return { Type = "KeyCode", Name = ae.KeyCode.Name }
	end
	return nil
end
function ab.InputMatchesBind(ae, af)
	if not af then
		return false
	end
	if af.Type == "KeyCode" then
		return ae.KeyCode.Name == af.Name
	end
	return ae.UserInputType.Name == af.Name
end
function ab.IsBindDown(ae)
	if not ae then
		return false
	end
	if ae.Type == "KeyCode" then
		local af = Enum.KeyCode[ae.Name]
		return af ~= nil and aa:IsKeyDown(af)
	end
	local af = Enum.UserInputType[ae.Name]
	return af ~= nil and aa:IsMouseButtonPressed(af)
end
function ab.DisplayBind(ae)
	if not ae then
		return ad()
	end
	if ae.Name == "MouseButton1" then
		return "MouseLeft"
	end
	if ae.Name == "MouseButton2" then
		return "MouseRight"
	end
	return ae.Name
end
return table.freeze(ab)
end
a["Elements/Label"]=function()
local aa, ab, ac = d("Core/Creator"), d("Core/Types"), d("UI/Attributes")
local ad, ae = aa.New, {}
ae.__type = "Label"
function ae.New(af, ag, ah, ai)
	local aj = (type(ag) == "string" and ag) or (ah and ah.Title) or ""
	local ak, al =
		ad(
			"TextLabel",
			{
				FontFace = Font.new(
					aa.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
					aa.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = aj,
				TextColor3 = aa.GetThemeProperty("Text") or Color3.fromRGB(240, 240, 240),
				TextSize = aa.GetThemeProperty("TextSizeBody") or 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.XY,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0.5, 0),
				Size = UDim2.new(1, -28, 0, 0),
				[aa.ThemeTag] = { TextColor3 = "Text", TextSize = "TextSizeBody" },
			}
		),
		ad(
			"Frame",
			{
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = aa.GetThemeProperty("DividerColor") or Color3.fromRGB(70, 70, 70),
				BackgroundTransparency = aa.GetThemeProperty("DividerTransparency") or 0.7,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 1),
				[aa.ThemeTag] = { BackgroundColor3 = "DividerColor", BackgroundTransparency = "DividerTransparency" },
			}
		)
	al:SetAttribute(ac.IsDivider, true)
	local am = ad(
		"Frame",
		{
			BackgroundColor3 = aa.GetThemeProperty("Element") or Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = aa.GetThemeProperty("ElementTransparency") or 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 40),
			[aa.ThemeTag] = { BackgroundColor3 = "Element", BackgroundTransparency = "ElementTransparency" },
		},
		{ ak, al }
	)
	local an, ao =
		{ Root = am, TitleLabel = ak, Divider = al, Type = "Label" }, function(an)
			if not an then
				return
			end
			local ao = "Variant" .. an
			aa.OverrideTag(ak, { TextColor3 = ao .. "Text" })
			local ap = aa.GetThemeProperty(ao .. "Text")
			if ap ~= nil then
				ak.TextColor3 = ap
			end
		end
	function an.Mount(ap, aq)
		am.Parent = aq
	end
	function an.SetVariant(ap, aq)
		ao(aq)
	end
	function an.SetValue(ap, aq)
		ak.Text = aq
	end
	function an.Destroy(ap)
		am:Destroy()
	end
	ao(ah and ah.Variant)
	return an
end
return ae
end
a["Elements/Paragraph"]=function()
local aa, ab, ac = d("Core/Creator"), d("Core/Types"), d("UI/Attributes")
local ad, ae = aa.New, {}
ae.__type = "Paragraph"
function ae.New(af, ag, ah, ai)
	local aj, ak = (type(ag) == "string" and ag) or (ah and ah.Title) or "", (ah and ah.Content) or ""
	local al, am =
		ad(
			"TextLabel",
			{
				FontFace = Font.new(
					aa.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
					aa.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = aj,
				TextSize = aa.GetThemeProperty("TextSizeBody") or 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				[aa.ThemeTag] = { TextColor3 = "Text", TextSize = "TextSizeBody" },
			}
		),
		ad(
			"TextLabel",
			{
				FontFace = Font.new(
					aa.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
					aa.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = ak,
				TextSize = aa.GetThemeProperty("TextSizeBody") or 16,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				[aa.ThemeTag] = {
					TextColor3 = "Text",
					TextTransparency = "TextDescriptionTransparency",
					TextSize = "TextSizeBody",
				},
			}
		)
	local an, ao =
		ad(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.new(1, -28, 0, 0),
			},
			{
				ad("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
				ad("UIPadding", { PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 10) }),
				al,
				am,
			}
		),
		ad(
			"Frame",
			{
				AnchorPoint = Vector2.new(0, 1),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 1),
				[aa.ThemeTag] = { BackgroundColor3 = "DividerColor", BackgroundTransparency = "DividerTransparency" },
			}
		)
	ao:SetAttribute(ac.IsDivider, true)
	local ap = ad(
		"Frame",
		{
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			[aa.ThemeTag] = { BackgroundColor3 = "Element", BackgroundTransparency = "ElementTransparency" },
		},
		{ an, ao }
	)
	local aq, ar =
		{ Root = ap, TitleLabel = al, ContentLabel = am, Divider = ao, Type = "Paragraph" }, function(aq)
			if not aq then
				return
			end
			local ar = "Variant" .. aq
			aa.OverrideTag(al, { TextColor3 = ar .. "Text" })
			local as = aa.GetThemeProperty(ar .. "Text")
			if as ~= nil then
				al.TextColor3 = as
			end
			aa.OverrideTag(am, { TextColor3 = ar .. "Text", TextTransparency = "TextDescriptionTransparency" })
			if as ~= nil then
				am.TextColor3 = as
			end
		end
	function aq.Mount(as, at)
		ap.Parent = at
	end
	function aq.SetVariant(as, at)
		ar(at)
	end
	function aq.SetTitle(as, at)
		al.Text = at
	end
	function aq.SetContent(as, at)
		am.Text = at
	end
	function aq.SetValue(as, at, e)
		al.Text = at
		if e then
			am.Text = e
		end
	end
	function aq.Destroy(as)
		ap:Destroy()
	end
	ar(ah and ah.Variant)
	return aq
end
return ae
end
a["Elements/Schema"]=function()
local aa, ab = d("Localization/Localization"), {}
local ac = function(ac)
	if aa.IsTagged(ac) then
		local ad = {}
		for ae, af in aa.SupportedLocales() do
			local ag = aa.ResolveTagFor(af, ac)
			if type(ag) == "string" then
				ad[af] = ag
			end
		end
		return (next(ad) ~= nil and { ad } or { nil })[1]
	end
	if type(ac) == "string" and ac ~= "" then
		return ac
	end
	return nil
end
function ab.DescribeLabels(ad, ae)
	return { title = ac(ad), description = ac(ae) }
end
function ab.DescribeGroupTitle(ad)
	return ac(ad)
end
local ad =
	{ Toggle = true, Slider = true, Input = true, Keybind = true, Select = true, Dropdown = true, ColorPicker = true }
function ab.IsValueType(ae)
	return ad[ae] == true
end
local ae, af, ag, ah =
	function(ae)
		local af, ag, ah = (type(ae.Min) == "number" and { ae.Min } or { 0 })[1], (type(ae.Max) == "number" and { ae.Max } or { 100 })[1], (type(ae.Step) == "number" and { ae.Step } or { 1 })[1]
		local ai = ah == math.floor(ah) and af == math.floor(af) and ag == math.floor(ag)
		local aj = { type = ai and "integer" or "number", minimum = af, maximum = ag }
		if ah > 0 then
			aj.multipleOf = ah
		end
		if type(ae.Default) == "number" then
			aj.default = ae.Default
		end
		return aj
	end, function(ae)
		local af = ae.MaxSelection
		local ag, ah = af == nil or af == 1, {}
		if ae.StaticOptions == true and type(ae.Options) == "table" then
			for ai, aj in ae.Options do
				if type(aj) == "table" and aj.Value ~= nil then
					table.insert(ah, aj.Value)
				end
			end
		end
		if ag then
			local ai = { type = "string" }
			if #ah > 0 then
				ai.enum = ah
			end
			if type(ae.Default) == "table" and ae.Default[1] ~= nil then
				ai.default = ae.Default[1]
			end
			return ai
		end
		local ai = { type = "string" }
		if #ah > 0 then
			ai.enum = ah
		end
		local aj = { type = "array", items = ai }
		if type(ae.Default) == "table" then
			aj.default = ae.Default
		end
		if type(af) == "number" and af > 0 then
			aj.maxItems = af
		end
		return aj
	end, function(ae)
		local af = { type = "object", additionalProperties = false, properties = { Mode = { type = "string", enum = { "Press", "Toggle", "Hold", "Always" } }, Bind = { type = "object", additionalProperties = false, properties = { Type = { type = "string" }, Name = { type = "string" } } } } }
		if type(ae.Default) == "table" then
			af.default = ae.Default
		end
		return af
	end, function(ae)
		local af = { type = "number" }
		local ag = { type = "object", additionalProperties = false, properties = { R = af, G = af, B = af, A = af } }
		if type(ae.Default) == "table" then
			ag.default = ae.Default
		end
		return ag
	end
function ab.Describe(ai, aj)
	if not ab.IsValueType(ai) then
		return nil
	end
	if ai == "Toggle" then
		local ak = { type = "boolean" }
		if type(aj.Default) == "boolean" then
			ak.default = aj.Default
		end
		return ak
	elseif ai == "Slider" then
		return ae(aj)
	elseif ai == "Input" then
		local ak = { type = "string" }
		if type(aj.Default) == "string" then
			ak.default = aj.Default
		end
		return ak
	elseif ai == "Select" or ai == "Dropdown" then
		return af(aj)
	elseif ai == "Keybind" then
		return ag(aj)
	elseif ai == "ColorPicker" then
		return ah(aj)
	end
	return nil
end
return ab
end
a["Elements/Section"]=function()
local aa, ab, ac, ad = d("Elements/Elements"), d("Elements/SectionFrame"), d("Elements/SectionHover"), {}
function ad.New(ae)
	ae.Title = string.upper(ae.Title)
	local af, ag = ab.New({ Title = ae.Title, Parent = ae.Parent, Unstyled = ae.Unstyled })
	local ah, ai =
		(ae.Unstyled and { nil } or { (ac.New({ Root = af, SectionContainer = ag })) })[1],
		{
			Root = af,
			Container = ag,
			ScrollFrame = ae.Parent,
			Window = ae.Window,
			ColumnCount = ae.ColumnCount,
			Registry = ae.Registry,
			Type = "Section",
			Title = ae.Title,
			_GroupTabSource = ae.TabSource,
			_GroupSectionSource = ae.TitleSource or ae.Title,
			_GroupSectionOrder = (
				ae.Window and ae.Window._NextSectionOrder and { (ae.Window:_NextSectionOrder()) } or { 0 }
			)[1],
		}
	function ai.Destroy(aj)
		local ak = aj._Children
		if ak then
			for al = #ak, 1, -1 do
				local am = ak[al]
				ak[al] = nil
				if am and type(am.Destroy) == "function" then
					pcall(function()
						am:Destroy()
					end)
				end
			end
			aj._Children = nil
		end
		if ah then
			ah:Destroy()
		end
		af:Destroy()
	end
	setmetatable(ai, aa)
	return ai
end
return ad
end
a["Elements/SectionFrame"]=function()
local aa = d("Core/Common")
local ab = aa.Creator
local ac, ad = ab.New, {}
function ad.New(ae)
	local af, ag = (ae.Unstyled == true)
	local ah = {
		ac("UIListLayout", { Padding = UDim.new(0, af and 10 or 0), SortOrder = Enum.SortOrder.LayoutOrder }),
		ac("UIPadding", {}),
	}
	if not af then
		table.insert(
			ah,
			1,
			ac(
				"UICorner",
				{
					CornerRadius = ab.GetThemeProperty("CornerRadiusSection") or UDim.new(0, 12),
					[ab.ThemeTag] = { CornerRadius = "CornerRadiusSection" },
				}
			)
		)
		table.insert(
			ah,
			2,
			ac(
				"UIStroke",
				{
					Color = ab.GetThemeProperty("StrokeColor") or Color3.fromRGB(240, 240, 240),
					Transparency = ab.GetThemeProperty("StrokeTransparency") or 0.9,
					[ab.ThemeTag] = { Color = "StrokeColor", Transparency = "StrokeTransparency" },
				}
			)
		)
	end
	local ai = ac(
		"Frame",
		{
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 0),
			Parent = ae.Parent,
		},
		{
			ac("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = ab.GetThemeProperty("BackgroundSurface") or Color3.fromRGB(22, 22, 22),
				BackgroundTransparency = af and 1 or 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Position = UDim2.fromOffset(0, 20),
				Size = UDim2.new(1, 0, 0, 10),
				[ab.Ref] = function(ai)
					ag = ai
				end,
				[ab.ThemeTag] = (af and { nil } or { { BackgroundColor3 = "BackgroundSurface" } })[1],
			}, ah),
			ac(
				"TextLabel",
				{
					FontFace = Font.new(
						ab.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
						ab.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					),
					Text = ae.Title,
					TextColor3 = ab.GetThemeProperty("SubText") or Color3.fromRGB(160, 160, 160),
					TextSize = ab.GetThemeProperty("TextSizeCategory") or 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.new(1, -10, 0, 20),
					[ab.ThemeTag] = { TextColor3 = "SubText", TextSize = "TextSizeCategory" },
				}
			),
		}
	)
	return ai, ag
end
return ad
end
a["Elements/SectionHover"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af = aa.Creator, d("UI/Attributes"), aa.Animator, aa.SignalManager, UDim.new(0, 0)
local ag, ah = ab.New, {}
ah.__index = ah
function ah.New(ai)
	local aj, ak, al, am = ae.CreateScope(), ai.Root, ai.SectionContainer, ag("UICorner", { CornerRadius = af })
	local an, ao, ap, aq, ar, as, at =
		ag(
			"Frame",
			{
				Name = "SharedHoverBg",
				BackgroundColor3 = ab.GetThemeProperty("Hover") or Color3.fromRGB(100, 100, 100),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 0,
				[ab.ThemeTag] = { BackgroundColor3 = "Hover" },
			},
			{ am }
		),
		false,
		{}
	local e = function()
		an.Parent = ak
		an.AnchorPoint = Vector2.zero
		an.Position = UDim2.fromOffset(0, 0)
		an.Size = UDim2.new(1, 0, 0, 0)
		an.Visible = false
	end
	e()
	local f = function(f)
		for g, h in f:GetChildren() do
			if h:GetAttribute(ac.IsDivider) then
				return h
			end
		end
		return nil
	end
	local g = function()
		ao = false
		local g, h, i = {}
		for j, k in ipairs(al:GetChildren()) do
			if k:IsA("GuiObject") and k.Visible and k ~= an then
				table.insert(g, k)
				local l = f(k)
				if l then
					l.Visible = true
				end
				if not h then
					h = k
				end
				i = k
			end
		end
		if i then
			local j = f(i)
			if j then
				j.Visible = false
			end
		end
		as = h
		ar = i
		table.clear(ap)
		local j = #g
		for k, l in g do
			if j == 1 then
				ap[l] = "Single"
			elseif k == 1 then
				ap[l] = "Top"
			elseif k == j then
				ap[l] = "Bottom"
			else
				ap[l] = "Middle"
			end
		end
	end
	local h = function()
		if ao then
			return
		end
		ao = true
		task.defer(g)
	end
	aj:Connect(al.ChildAdded, function(i)
		if not i:IsA("GuiObject") or i == an then
			return
		end
		if ar then
			local j = f(ar)
			if j then
				j.Visible = true
			end
		end
		local j = f(i)
		if j then
			j.Visible = false
		end
		if not as then
			as = i
			ar = i
			ap[i] = "Single"
		else
			local k = ar
			if k then
				local l = ap[k]
				if l == "Single" then
					ap[k] = "Top"
				elseif l == "Bottom" then
					ap[k] = "Middle"
				end
			end
			ar = i
			ap[i] = "Bottom"
		end
	end)
	aj:Connect(al.ChildRemoved, function(i)
		if not i:IsA("GuiObject") or i == an then
			return
		end
		ap[i] = nil
		if aq == i then
			ad.Set(an, { BackgroundTransparency = 1 })
			e()
			aq = nil
		end
		h()
	end)
	local i, j =
		function(i)
			local j = ab.GetThemeProperty("CornerRadiusSection") or UDim.new(0, 12)
			if i == "Single" then
				am.CornerRadius = j
				an.Size = UDim2.fromScale(1, 1)
				an.Position = UDim2.fromOffset(0, 0)
			elseif i == "Top" then
				am.CornerRadius = j
				an.Size = UDim2.new(1, 0, 1, 12)
				an.Position = UDim2.fromOffset(0, 0)
			elseif i == "Bottom" then
				am.CornerRadius = j
				an.Size = UDim2.new(1, 0, 1, 12)
				an.Position = UDim2.fromOffset(0, -12)
			else
				am.CornerRadius = af
				an.Size = UDim2.fromScale(1, 1)
				an.Position = UDim2.fromOffset(0, 0)
			end
		end, function(i, j)
			local k = i:GetAttribute("HoverTransToken")
			if k then
				local l = ab.GetThemeProperty(k) or 0.9
				return math.clamp(l + j, 0, 1)
			end
			local l = ab.GetThemeProperty("HoverTransparency") or 1
			return math.clamp((l - 0.1) + j, 0, 1)
		end
	local k, l, m, n =
		function(k)
			if aq == k then
				return
			end
			ad.CancelInstance(an)
			an.Visible = true
			an.BackgroundTransparency = 1
			an.Parent = k
			local l = ap[k] or "Middle"
			i(l)
			local m = k:GetAttribute(ac.HoverThemeToken)
			local n = (type(m) == "string" and { m } or { "Hover" })[1]
			if n ~= at then
				ab.RemoveThemeObject(an)
				ab.AddThemeObject(an, { BackgroundColor3 = n })
				at = n
			end
			an.BackgroundColor3 = ab.GetThemeProperty(n) or (n == "Hover" and { (Color3.fromRGB(100, 100, 100)) } or { (Color3.fromRGB(240, 240, 240)) })[1]
			ad.Tween(an, { BackgroundTransparency = j(k, 0) }, 0.15)
			aq = k
		end, function(k)
			if aq ~= k then
				return
			end
			local l, m = ad.Tween(an, { BackgroundTransparency = 1 }, 0.15), k
			l.Completed:Once(function()
				if aq == m or aq == nil then
					e()
					aq = nil
				end
			end)
			aq = nil
		end, function(k)
			if aq ~= k then
				return
			end
			ad.Tween(an, { BackgroundTransparency = j(k, 0.15) }, 0.1)
		end, function(k)
			if aq ~= k then
				return
			end
			ad.Tween(an, { BackgroundTransparency = j(k, 0) }, 0.1)
		end
	local o = function(o)
		if not o:IsA("GuiObject") or o == an then
			return
		end
		local p
		for q, r in o:GetChildren() do
			if r:IsA("TextButton") and r.ZIndex == 5 then
				p = r
				break
			end
		end
		if not p then
			return
		end
		local q = o
		if q:GetAttribute("_HoverHooked") then
			return
		end
		q:SetAttribute("_HoverHooked", true)
		ab.TrackConnection(
			q,
			p.MouseEnter:Connect(function()
				k(q)
			end)
		)
		ab.TrackConnection(
			q,
			p.MouseLeave:Connect(function()
				l(q)
			end)
		)
		ab.TrackConnection(
			q,
			p.MouseButton1Down:Connect(function()
				m(q)
			end)
		)
		ab.TrackConnection(
			q,
			p.MouseButton1Up:Connect(function()
				n(q)
			end)
		)
	end
	aj:Connect(al.ChildAdded, function(p)
		task.defer(o, p)
	end)
	for p, q in ipairs(al:GetChildren()) do
		task.defer(o, q)
	end
	g()
	return setmetatable({ Scope = aj }, ah)
end
function ah.Destroy(ai)
	if ai.Scope then
		ai.Scope:Destroy()
		ai.Scope = nil
	end
end
return ah
end
a["Elements/Select"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag, ah, ai, aj =
	aa.Creator, aa.Animator, aa.WindowDrag, d("Core/SafeCall"), d("Core/Types"), aa.SignalManager, d("UI/Element"), d("Elements/SelectDropdown"), d("Elements/SelectSelection")
local ak, al, am, an, ao, ap, aq, ar, as, at, e = ab.New, "rbxassetid://10709790948", 120, 280, 24, 18, 8, 4, 14, 12, {}
e.__type = "Select"
function e.New(f, g, h, i)
	local j, k = h or {}, d("Localization/Localization")
	local l = j.Title
	if l == nil and type(g) == "string" and g ~= "" then
		l = g
	end
	local m, n = j.Options or {}
	if k.IsTagged(j.Placeholder) then
		n = k.ResolveTag(j.Placeholder) or ""
	elseif type(j.Placeholder) == "string" then
		n = j.Placeholder
	else
		n = k.t("common.placeholder.select")
	end
	local o, p = j.MaxSelectedDisplay or 2, aj.NormalizeMaxSelection(j.MaxSelection)
	local q, r, s, t, u, v, w, x, y =
		p == 1,
		j.ShowSearch ~= false,
		(j.CompactChrome == true and { (math.max(ap, j.Height or ao)) } or { ao })[1],
		aj.InitSelectedMap(j.Default, p),
		{
			IsOpen = false,
			PopupContainer = nil,
			PopupScroll = nil,
			PopupSearchInput = nil,
			PortalHandle = nil,
			PopupScope = nil,
			UnsubResize = nil,
			OptionRowData = {},
		},
		ah.New({
			Title = l,
			Desc = j.Desc,
			Hover = true,
			Height = (j.CompactChrome == true and { (j.Height or 26) } or { nil })[1],
			CompactChrome = j.CompactChrome == true,
			HasDivider = (j.CompactChrome == true and { false } or { nil })[1],
		}),
		ag.CreateScope(),
		ak(
			"TextLabel",
			{
				Name = "ValueLabel",
				FontFace = Font.new(
					ab.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
					ab.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = n,
				TextColor3 = ab.GetThemeProperty("TextPlaceholder") or Color3.fromRGB(140, 140, 140),
				TextSize = ab.GetThemeProperty("TextSizeSmall") or 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -22, 1, 0),
				[ab.ThemeTag] = { TextColor3 = "TextPlaceholder", TextSize = "TextSizeSmall" },
			}
		),
		ak(
			"ImageLabel",
			{
				Name = "Chevron",
				Image = al,
				ImageColor3 = ab.GetThemeProperty("SubText") or Color3.fromRGB(160, 160, 160),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -4, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				[ab.ThemeTag] = { ImageColor3 = "SubText" },
			}
		)
	local z = ak(
		"Frame",
		{
			Name = "SelectShell",
			BackgroundColor3 = ab.GetThemeProperty("DropdownBg") or Color3.fromRGB(140, 140, 140),
			BackgroundTransparency = ab.GetThemeProperty("DropdownBgTransparency") or 0.9,
			Size = UDim2.fromOffset(120, s),
			[ab.ThemeTag] = { BackgroundColor3 = "DropdownBg", BackgroundTransparency = "DropdownBgTransparency" },
		},
		{
			ak("UICorner"),
			ak(
				"UIStroke",
				{
					Color = ab.GetThemeProperty("DropdownStroke") or Color3.fromRGB(240, 240, 240),
					Transparency = ab.GetThemeProperty("DropdownStrokeTransparency") or 0.9,
					[ab.ThemeTag] = { Color = "DropdownStroke", Transparency = "DropdownStrokeTransparency" },
				}
			),
			ak("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 4) }),
			x,
			y,
		}
	)
	z.Parent = v.Container
	local A, B, C =
		function()
			if not j.Callback then
				return
			end
			local A, B = aj.GetSelectedOptions(m, t)
			if q then
				ae.Call(j.Callback, A[1], B)
			else
				ae.Call(j.Callback, A, B)
			end
		end, function()
			local A, B = aj.GetSelectedOptions(m, t)
			local C = #B
			if C == 0 then
				x.Text = n
				ab.OverrideTag(x, { TextColor3 = "TextPlaceholder", TextSize = "TextSizeSmall" })
				x.TextColor3 = ab.GetThemeProperty("TextPlaceholder") or Color3.fromRGB(140, 140, 140)
			else
				ab.OverrideTag(x, { TextColor3 = "DropdownText", TextSize = "TextSizeSmall" })
				x.TextColor3 = ab.GetThemeProperty("DropdownText") or Color3.fromRGB(240, 240, 240)
				if C <= o then
					local D = {}
					for E, F in B do
						table.insert(D, F.Label)
					end
					x.Text = table.concat(D, ", ")
				else
					x.Text = d("Localization/Localization").t("common.selection.selectedCount", { count = C })
				end
			end
		end, function()
			if j.StretchShell == true then
				z.Size = UDim2.new(1, 0, 0, s)
				return
			end
			local A = math.ceil(x.TextBounds.X)
			local B = math.clamp(A + aq + ar + as + at, am, an)
			z.Size = UDim2.fromOffset(B, s)
		end
	local D = function(D, E)
		local F = table.clone(t)
		table.clear(t)
		if q and typeof(D) ~= "table" then
			if D ~= nil then
				t[D] = true
			end
		else
			local G, H = (typeof(D) == "table" and { D } or { { D } })[1], 0
			for I, J in G do
				if H >= p then
					break
				end
				t[J] = true
				H = H + 1
			end
		end
		B()
		C()
		if u.PopupContainer then
			ai.UpdateOptionVisuals(u, m, t)
		end
		if E and aj.HasSelectionChanged(F, t) then
			A()
		end
	end
	B()
	C()
	ab.TrackConnection(v.Root, x:GetPropertyChangedSignal("TextBounds"):Connect(C))
	local E, F =
		function()
			local E = v.Root
			while E do
				if E:IsA("ScreenGui") then
					return E
				end
				E = E.Parent
			end
			return nil
		end, function()
			ai.Close(u)
			ac.Tween(y, { Rotation = 0 }, 0.15)
		end
	local G = function()
		if u.PopupContainer ~= nil then
			F()
			return
		end
		local G = E()
		if not G then
			return
		end
		ac.Tween(y, { Rotation = 180 }, 0.15)
		ai.Open(u, m, t, z, x, G, function(H)
			if t[H.Value] then
				t[H.Value] = nil
			else
				local I, J = aj.GetSelectedOptions(m, t)
				if #I >= p then
					for K, L in m do
						if t[L.Value] then
							t[L.Value] = nil
							break
						end
					end
				end
				t[H.Value] = true
			end
			ai.UpdateOptionVisuals(u, m, t)
			B()
			C()
			A()
		end, function()
			return aj.GetFirstSelectedIndex(m, t)
		end, F, r)
	end
	if v.InteractButton then
		local H
		ab.TrackConnection(
			v.Root,
			v.InteractButton.MouseButton1Down:Connect(function()
				H = ad.GetPressPosition()
			end)
		)
		ab.TrackConnection(
			v.Root,
			v.InteractButton.MouseButton1Click:Connect(function()
				local I = H
				H = nil
				if ad.ShouldSuppressClickFrom(I) then
					return
				end
				G()
			end)
		)
	end
	local H = { Root = v.Root, Type = "Select" }
	function H.SetValue(I, J)
		D(J, false)
	end
	function H.GetValue(I)
		local J, K = aj.GetSelectedOptions(m, t)
		if q then
			return J[1]
		end
		return J
	end
	function H.Pack(I)
		local J = I:GetValue()
		if typeof(J) == "table" then
			return table.clone(J)
		end
		return J
	end
	function H.Unpack(I, J, K)
		local L = J
		if q and typeof(J) == "table" then
			L = J[1]
		end
		D(L, K ~= nil and K.Callbacks == true)
	end
	H.Save = H.Pack
	H.Load = H.Unpack
	function H.Open(I)
		G()
	end
	function H.Close(I)
		F()
	end
	function H.Toggle(I)
		if u.PopupContainer ~= nil then
			F()
		else
			G()
		end
	end
	function H.SetOptions(I, J)
		F()
		m = J
		local K = {}
		for L, M in J do
			K[M.Value] = true
		end
		for L in t do
			if not K[L] then
				t[L] = nil
			end
		end
		B()
		C()
	end
	function H.Mount(I, J)
		v:Mount(J)
		task.defer(C)
	end
	function H.SetTitle(I, J)
		v:SetTitle(J)
	end
	function H.SetDesc(I, J)
		v:SetDesc(J)
	end
	function H.SetPlaceholder(I, J)
		n = (type(J) == "string" and { J } or { "" })[1]
		B()
	end
	local I
	if k.IsTagged(j.Placeholder) then
		I = k.Attach(H, "Placeholder", j.Placeholder)
	end
	function H.Destroy(J)
		if I then
			I()
			I = nil
		end
		ai.Close(u, true)
		w:Destroy()
		ac.CancelInstance(y)
		ac.CancelInstance(z)
		v:Destroy()
	end
	return H
end
return e
end
a["Elements/SelectDismiss"]=function()
local aa, ab = game:GetService("UserInputService"), {}
function ab.WatchAncestorScroll(ac, ad, ae, af, ag)
	local ah, ai = ad.Parent, 0
	while ah and ah ~= ae do
		if ah:IsA("ScrollingFrame") then
			local aj = ah
			ai = ai + 1
			ac:Connect(aj:GetPropertyChangedSignal("CanvasPosition"), function()
				if ag() then
					af()
				end
			end)
		end
		ah = ah.Parent
	end
	return ai
end
function ab.BindOutsideDismiss(ac, ad, ae, af)
	ac:Connect(aa.InputBegan, function(ag)
		if not ad.PopupContainer then
			return
		end
		if ag.UserInputType ~= Enum.UserInputType.MouseButton1 and ag.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local ah, ai, aj = ag.Position, ad.PopupContainer.AbsolutePosition, ad.PopupContainer.AbsoluteSize
		if ah.X >= ai.X and ah.X <= ai.X + aj.X and ah.Y >= ai.Y and ah.Y <= ai.Y + aj.Y then
			return
		end
		local ak, al = ae.AbsolutePosition, ae.AbsoluteSize
		if ah.X >= ak.X and ah.X <= ak.X + al.X and ah.Y >= ak.Y and ah.Y <= ak.Y + al.Y then
			return
		end
		af()
	end)
end
return table.freeze(ab)
end
a["Elements/SelectDropdown"]=function()
local aa, ab = game:GetService("TextService"), d("Core/Common")
local ac, ad, ae, af, ag, ah, ai, aj, ak, al, am, an, ao, ap, aq, ar, as =
	ab.Creator,
	ab.Animator,
	ab.SignalManager,
	ab.Scheduler,
	d("UI/PopupLayer"),
	d("Elements/SelectDropdownLayout"),
	d("Elements/SelectSearchFilter"),
	d("Elements/SelectDismiss"),
	d("Elements/SelectDropdownBinding"),
	d("Core/Logger"),
	debug and debug.profilebegin,
	debug and debug.profileend,
	{},
	104,
	300,
	1.5,
	64
local at = ah.POPUP_PADDING_H * 2 + ah.ROW_PADDING_X * 2 + 14 + as
local e = function(e)
	local f, g = ac.GetThemeProperty("TextSizeSmall") or 15, 0
	for h, i in e do
		local j = aa:GetTextSize(i.Label, f, Enum.Font.SourceSans, Vector2.new(math.huge, f))
		g = math.max(g, math.ceil(j.X))
	end
	return math.clamp(g + at, ap, aq)
end
function ao.Open(f, g, h, i, j, k, l, m, n, o)
	if f.PopupContainer ~= nil then
		return
	end
	if am then
		am("SeaHub:SelectOpen")
	end
	local p = os.clock()
	f.IsOpen = true
	local q = ae.CreateScope()
	f.PopupScope = q
	local r, s, t, u, v = "", "", {}, #g, {}
	f.OptionRowData = {}
	for w, x in g do
		local y = h[x.Value] == true
		local z = ah.CreateOptionRow(x, y, function()
			l(x)
		end)
		z.Row.LayoutOrder = w
		z.Label = x.Label
		table.insert(v, z.Row)
		table.insert(f.OptionRowData, z)
	end
	local w, x, y, z = o ~= false, e(g), k.AbsoluteSize, ah.GetContentHeight(#g)
	local A, B, C, D, E =
		ah.GetVisibleHeight(#g, y.Y, w), function(A)
			if not f.PopupContainer then
				return
			end
			local B, C = f.PopupContainer.AbsoluteSize.Y, k.AbsoluteSize
			local D = ah.ComputePosition(i.AbsolutePosition, i.AbsoluteSize, j.AbsolutePosition, j.AbsoluteSize, x, B, C, A)
			f.PopupContainer.Position = UDim2.fromOffset(D.X, D.Y)
		end
	local F = function(F)
		if not f.PopupContainer then
			return
		end
		r = F
		u = ai.Apply({ State = f, Options = g, Query = F, PopupWidth = x, ScreenGui = k, Reposition = B })
	end
	local G = function(G)
		s = G
		af.DeferKeyed(t, function()
			F(s)
		end, "Normal")
	end
	C, D, f.PopupSearchInput, E = ah.CreateContainer(v, A, z, G, w)
	C.Size = UDim2.fromOffset(x, ah.GetContainerHeight(A, w))
	f.PopupContainer = C
	f.PopupScroll = D
	f.PopupScale = E
	f.PortalHandle = ag.Mount(C, k)
	local H = aj.WatchAncestorScroll(q, i, k, n, function()
		return f.PopupContainer ~= nil
	end)
	task.defer(function()
		if not f.PopupContainer then
			return
		end
		local I, J, K, L, M, N, O =
			i.AbsolutePosition,
			i.AbsoluteSize,
			j.AbsolutePosition,
			j.AbsoluteSize,
			C.AbsoluteSize.Y,
			k.AbsoluteSize,
			m()
		local P = ah.ComputePosition(I, J, K, L, x, M, N, O)
		local Q = ah.ComputeOpenFromPosition(P, x, M, N)
		if O and O > 0 then
			local R, S = K.Y + L.Y / 2, ah.GetAnchorCenterY(O)
			local T, U = S - (R - P.Y - ah.GetHeaderOffset(w)), math.max(0, D.CanvasSize.Y.Offset - D.AbsoluteSize.Y)
			D.CanvasPosition = Vector2.new(0, math.clamp(math.round(T), 0, U))
		end
		ah.AnimateOpen(C, Q, P, E)
	end)
	aj.BindOutsideDismiss(q, f, i, n)
	f.UnsubResize = ak.Bind({
		State = f,
		ScreenGui = k,
		PopupWidth = x,
		SelectShell = i,
		ContentAnchor = j,
		ShowSearch = w,
		GetFilteredCount = function()
			return u
		end,
		GetSearchQuery = function()
			return r
		end,
		GetFirstSelectedIndex = m,
	})
	q:Connect(i.AncestryChanged, function(I, J)
		if not J then
			ao.Close(f, true)
		end
	end)
	if an then
		an()
	end
	local I = (os.clock() - p) * 1000
	if I >= ar then
		al.Warn(([[[SeaHub:Select] open took %.2fms (options=%d, watchedScrollFrames=%d)]]):format(I, #g, H))
	end
end
local f = function(f)
	for g, h in f.OptionRowData do
		ah.ReleaseOptionRow(h.Row)
	end
	f.OptionRowData = {}
	if f.PopupSearchInput then
		ac.CleanupInstance(f.PopupSearchInput)
		f.PopupSearchInput = nil
	end
	if f.PopupContainer then
		ad.CancelInstance(f.PopupContainer)
		f.PopupContainer:Destroy()
		f.PopupContainer = nil
	end
	f.PopupScroll = nil
	f.PopupScale = nil
	if f.PortalHandle then
		f.PortalHandle.Destroy()
		f.PortalHandle = nil
	end
end
function ao.Close(g, h)
	if not g.PopupContainer then
		return
	end
	g.IsOpen = false
	if g.UnsubResize then
		g.UnsubResize()
		g.UnsubResize = nil
	end
	if g.PopupScope then
		g.PopupScope:Destroy()
		g.PopupScope = nil
	end
	if h or not g.PopupContainer then
		f(g)
		return
	end
	local i = g.PopupContainer
	ah.AnimateClose(i, function()
		if g.PopupContainer == i then
			f(g)
		else
			ad.CancelInstance(i)
			for j, k in i:GetChildren() do
				if k.Name == "SelectOptionRow" then
					ah.ReleaseOptionRow(k)
				end
			end
			i:Destroy()
		end
	end, g.PopupScale)
end
function ao.UpdateOptionVisuals(g, h, i)
	for j, k in g.OptionRowData do
		local l = h[j]
		if not l then
			continue
		end
		local m = i[l.Value] == true
		k.Check.Visible = m
		ad.Tween(k.Row, { BackgroundTransparency = m and 0.85 or 1 }, 0.1)
	end
end
return ao
end
a["Elements/SelectDropdownBinding"]=function()
local aa = d("Core/Common")
local ab, ac, ad = aa.Responsive, d("Elements/SelectDropdownLayout"), {}
function ad.Bind(ae)
	return ab.OnChanged(function()
		local af = ae.State
		if not af.PopupContainer then
			return
		end
		local ag, ah = ae.ScreenGui.AbsoluteSize, ae.GetFilteredCount()
		local ai = ac.GetVisibleHeight(ah, ag.Y, ae.ShowSearch)
		local aj = ac.GetContainerHeight(ai, ae.ShowSearch)
		af.PopupContainer.Size = UDim2.fromOffset(ae.PopupWidth, aj)
		if af.PopupScroll then
			af.PopupScroll.Size = UDim2.new(1, 0, 0, ai)
			af.PopupScroll.CanvasSize = UDim2.fromOffset(0, ac.GetContentHeight(ah))
		end
		local ak = (ae.GetSearchQuery() == "" and { (ae.GetFirstSelectedIndex()) } or { nil })[1]
		local al = ac.ComputePosition(
			ae.SelectShell.AbsolutePosition,
			ae.SelectShell.AbsoluteSize,
			ae.ContentAnchor.AbsolutePosition,
			ae.ContentAnchor.AbsoluteSize,
			ae.PopupWidth,
			aj,
			ag,
			ak
		)
		af.PopupContainer.Position = UDim2.fromOffset(al.X, al.Y)
		if af.PopupScroll and ak and ak > 0 then
			local am, an =
				ae.ContentAnchor.AbsolutePosition.Y + ae.ContentAnchor.AbsoluteSize.Y / 2, ac.GetAnchorCenterY(ak)
			local ao, ap =
				an - (am - al.Y), math.max(0, af.PopupScroll.CanvasSize.Y.Offset - af.PopupScroll.AbsoluteSize.Y)
			af.PopupScroll.CanvasPosition = Vector2.new(0, math.clamp(math.round(ao), 0, ap))
		end
	end)
end
return table.freeze(ad)
end
a["Elements/SelectDropdownLayout"]=function()
local aa = d("Core/Common")
local ab, ac, ad = aa.Creator, aa.AnimKit, aa.AnimTokens
local ae, af, ag, ah, ai, aj, ak, al, am, an, ao, ap, aq, ar, as, at =
	ab.New, d("Elements/SelectOptionRow"), d("Elements/InputField"), {}, 4, 4, 6, 8, 0.14, 0.14, 8, 34, 1, "rbxassetid://10734943674", 14, 6
function ah.CreateOptionRow(e, f, g)
	return af.Create(e, f, g)
end
function ah.ReleaseOptionRow(e)
	af.Release(e)
end
function ah.CreateContainer(e, f, g, h, i)
	local j, k, l, m, n =
		i ~= false,
		(ae(
			"ScrollingFrame",
			{
				AutomaticCanvasSize = Enum.AutomaticSize.None,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromOffset(0, g),
				ClipsDescendants = true,
				ScrollBarImageColor3 = ab.GetThemeProperty("ScrollBarColor") or Color3.fromRGB(0, 0, 0),
				ScrollBarImageTransparency = ab.GetThemeProperty("ScrollBarTransparency") or 0.5,
				ScrollBarThickness = ab.GetThemeProperty("ScrollBarThickness") or 2,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, f),
				[ab.ThemeTag] = {
					ScrollBarImageColor3 = "ScrollBarColor",
					ScrollBarImageTransparency = "ScrollBarTransparency",
					ScrollBarThickness = "ScrollBarThickness",
				},
			},
			{
				ae("UIListLayout", { Padding = UDim.new(0, af.LIST_SPACING), SortOrder = Enum.SortOrder.LayoutOrder }),
				ae(
					"UIPadding",
					{
						PaddingTop = UDim.new(0, ai),
						PaddingBottom = UDim.new(0, ai),
						PaddingLeft = UDim.new(0, aj),
						PaddingRight = UDim.new(0, aj),
					}
				),
				table.unpack(e),
			}
		))
	if j then
		local o = ae(
			"ImageLabel",
			{
				BackgroundTransparency = 1,
				Image = ar,
				ImageColor3 = ab.GetThemeProperty("InputPlaceholder") or Color3.fromRGB(140, 140, 140),
				ImageTransparency = 0.15,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.fromOffset(as, as),
				ZIndex = 2,
				[ab.ThemeTag] = { ImageColor3 = "InputPlaceholder" },
			}
		)
		n = ae(
			"Frame",
			{ BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, ap) },
			{
				ae(
					"UIPadding",
					{
						PaddingBottom = UDim.new(0, at),
						PaddingLeft = UDim.new(0, at + 4),
						PaddingRight = UDim.new(0, at),
						PaddingTop = UDim.new(0, at),
					}
				),
				o,
			}
		)
		local p = ag.Create({
			MultiLine = false,
			Text = "",
			Placeholder = d("Localization/Localization").t("common.placeholder.searchOptions"),
			FieldHeight = ap - at * 2,
			ShellSize = UDim2.fromScale(1, 1),
			TextBoxSize = UDim2.new(1, -(as + 8), 1, 0),
			TextBoxPosition = UDim2.new(0, as + 8, 0, 0),
		})
		p.FieldStroke:Destroy()
		p.FieldShell.BackgroundTransparency = 1
		ab.OverrideTag(p.FieldShell, {})
		p.FieldShell.Parent = n
		ab.TrackConnection(
			n,
			p.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				h(p.TextBox.Text)
			end)
		)
		m = p.TextBox
	end
	local o = {
		ae("UICorner", { CornerRadius = UDim.new(0, 8) }),
		ae("UIScale", {
			Scale = 1,
			[ab.Ref] = function(o)
				l = o
			end,
		}),
		ae(
			"UIStroke",
			{
				Color = ab.GetThemeProperty("DropdownStroke") or Color3.fromRGB(240, 240, 240),
				Transparency = ab.GetThemeProperty("DropdownStrokeTransparency") or 0.9,
				[ab.ThemeTag] = { Color = "DropdownStroke", Transparency = "DropdownStrokeTransparency" },
			}
		),
		ae("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		k,
	}
	if j and n then
		table.insert(
			o,
			ae(
				"Frame",
				{
					BackgroundColor3 = ab.GetThemeProperty("DividerColor") or Color3.fromRGB(70, 70, 70),
					BackgroundTransparency = ab.GetThemeProperty("DividerTransparency") or 0.7,
					BorderSizePixel = 0,
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 1),
					[ab.ThemeTag] = { BackgroundColor3 = "DividerColor", BackgroundTransparency = "DividerTransparency" },
				}
			)
		)
		table.insert(o, n)
	end
	local p = ae(
		"CanvasGroup",
		{
			BackgroundColor3 = ab.GetThemeProperty("SelectPopupBg") or Color3.fromRGB(22, 22, 22),
			BackgroundTransparency = ab.GetThemeProperty("SelectPopupBgTransparency") or 0,
			Size = UDim2.fromOffset(0, ah.GetContainerHeight(f, j)),
			ClipsDescendants = true,
			[ab.ThemeTag] = { BackgroundColor3 = "SelectPopupBg", BackgroundTransparency = "SelectPopupBgTransparency" },
		},
		o
	)
	return p, k, m, l
end
local e, f, g =
	function(e, f, g, h, i, j, k)
		local l, m = (g.X - aj - ak)
		if k and k > 0 then
			m = e.Y
		else
			m = e.Y + f.Y + 4
		end
		local n, o = j.Y - (e.Y + f.Y) - al, e.Y - al
		if not k or k <= 0 then
			if n < i and o > n then
				m = e.Y - i - 4
			end
		end
		return l, m
	end, 0, -14
function ah.ComputeOpenFromPosition(h, i, j, k)
	local l, m = h.X + f, h.Y + g
	return Vector2.new(math.clamp(l, al, k.X - i - al), math.clamp(m, al, k.Y - j - al))
end
function ah.ComputePosition(h, i, j, k, l, m, n, o)
	local p, q = e(h, i, j, l, m, n, o)
	local r, s = math.clamp(p, al, n.X - l - al), math.clamp(q, al, n.Y - m - al)
	return Vector2.new(r, s)
end
function ah.GetContentHeight(h)
	if h <= 0 then
		return ai * 2
	end
	return ai * 2 + h * af.OPTION_HEIGHT + (h - 1) * af.LIST_SPACING
end
function ah.GetVisibleHeight(h, i, j)
	local k, l, m = (j ~= false and { ap } or { 0 })[1], ah.GetContentHeight(h), ah.GetContentHeight(ao)
	local n = math.max(af.OPTION_HEIGHT, i - al * 2 - k)
	return math.min(l, m, n)
end
function ah.GetContainerHeight(h, i)
	if i == false then
		return h
	end
	return h + aq + ap
end
function ah.GetHeaderOffset(h)
	if h == false then
		return 0
	end
	return ap + aq
end
function ah.GetAnchorCenterY(h)
	local i, j = af.OPTION_HEIGHT, af.LIST_SPACING
	return ai + (h - 1) * (i + j) + i / 2
end
local h, i, j = ad.Info(0.18, ad.Easing.Emphasized), ad.Info(am, ad.Easing.Standard), ad.Info(an, ad.Easing.Standard)
function ah.AnimateOpen(k, l, m, n)
	k.Position = UDim2.fromOffset(l.X, l.Y)
	if n then
		ac.ScalePop(n, { start = 0.9, info = h })
	end
	ac.GroupFade(k, "In", { info = i })
	ac.Slide(k, UDim2.fromOffset(m.X, m.Y), { info = i })
end
function ah.AnimateClose(k, l, m)
	if m then
		ac.ScaleShrink(m, { endScale = 0.96, info = j })
	end
	local n = ac.GroupFadeTween(k, "Out", { info = j })
	n.Completed:Once(function()
		l()
	end)
end
ah.OPTION_HEIGHT = af.OPTION_HEIGHT
ah.LIST_SPACING = af.LIST_SPACING
ah.POPUP_PADDING_V = ai
ah.POPUP_PADDING_H = aj
ah.ROW_PADDING_X = ak
ah.ANIM_DURATION = am
return ah
end
a["Elements/SelectOptionRow"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae = aa.Creator, aa.Animator, aa.ObjectPool, aa.WindowDrag
local af, ag, ah, ai = ab.New, "rbxassetid://10709790644", 28, 512
local aj = {}
setmetatable(aj, { __mode = "k" })
local ak = function(ak)
	ak.Name = "SelectOptionRow"
	ak.BorderSizePixel = 0
	ak.BackgroundColor3 = ab.GetThemeProperty("Hover") or Color3.fromRGB(100, 100, 100)
	ak.BackgroundTransparency = 1
	ak.Size = UDim2.new(1, 0, 0, ah)
	ab.AddThemeObject(ak, { BackgroundColor3 = "Hover" })
end
local al, am =
	function(al)
		local am = al
		ak(am)
		local an, ao, ap, aq = {}, af("ImageLabel", { Image = ag, ImageColor3 = ab.GetThemeProperty("Text") or Color3.fromRGB(240, 240, 240), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(14, 14), Visible = false, [ab.ThemeTag] = { ImageColor3 = "Text" } }), af("Frame", { BackgroundColor3 = ab.GetThemeProperty("Hover") or Color3.fromRGB(100, 100, 100), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 0, [ab.ThemeTag] = { BackgroundColor3 = "Hover" } }, { af("UICorner", { CornerRadius = UDim.new(0, 6) }) }), af("TextLabel", { FontFace = Font.new(ab.GetThemeProperty("FontFamily") or "rbxassetid://12187365364", ab.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium, Enum.FontStyle.Normal), Text = "", TextColor3 = ab.GetThemeProperty("DropdownText") or Color3.fromRGB(240, 240, 240), TextSize = ab.GetThemeProperty("TextSizeSmall") or 15, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), [ab.ThemeTag] = { TextColor3 = "DropdownText", TextSize = "TextSizeSmall" } })
		local ar, as = af("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, { af("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }), aq, ao }), af("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			[ab.MouseEnter] = function()
				ac.Tween(an.HoverFrame, { BackgroundTransparency = 0.85 }, 0.1)
			end,
			[ab.MouseLeave] = function()
				ac.Tween(an.HoverFrame, { BackgroundTransparency = 1 }, 0.1)
			end,
			[ab.MouseButton1Down] = function()
				an.PressStart = ae.GetPressPosition()
			end,
			[ab.MouseButton1Click] = function()
				local ar = an.PressStart
				an.PressStart = nil
				if ae.ShouldSuppressClickFrom(ar) then
					return
				end
				local as = an.OnClick
				if as then
					as()
				end
			end,
		})
		af("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = am
		ap.Parent = am
		ar.Parent = am
		as.Parent = am
		an.Check = ao
		an.HoverFrame = ap
		an.LabelText = aq
		an.Interact = as
		an.OnClick = nil
		an.PressStart = nil
		aj[am] = an
	end, function(al)
		local am = al
		local an = aj[am]
		ac.CancelInstance(am)
		for ao, ap in am:GetDescendants() do
			ac.CancelInstance(ap)
		end
		ak(am)
		am.Visible = true
		am.LayoutOrder = 0
		if an then
			an.OnClick = nil
			an.PressStart = nil
			an.Check.Visible = false
			an.HoverFrame.BackgroundTransparency = 1
			an.LabelText.Text = ""
		end
	end
local an, ao = ad.New("Frame", al, { MaxSize = ai, Reset = am }), {}
ao.OPTION_HEIGHT = ah
ao.LIST_SPACING = 2
function ao.Create(ap, aq, ar)
	local as = (an:Acquire())
	local at = aj[as]
	if not at then
		al(as)
		at = aj[as]
	end
	am(as)
	at = aj[as]
	at.LabelText.Text = ap.Label
	at.Check.Visible = aq
	at.OnClick = ar
	as.BackgroundTransparency = aq and 0.85 or 1
	return { Row = as, Check = at.Check, HoverFrame = at.HoverFrame, Label = ap.Label }
end
function ao.Release(ap)
	an:Release(ap)
end
return table.freeze(ao)
end
a["Elements/SelectSearchFilter"]=function()
local aa, ab, ac =
	d("Elements/SelectDropdownLayout"), {}, function(aa, ab)
		local ac, ad = string.lower(aa), string.lower(ab)
		if ad == "" then
			return 0
		end
		local ae = string.find(ac, ad, 1, true)
		if ae then
			return ae
		end
		local af, ag = 1, 0
		for ah = 1, #ad do
			local ai = string.sub(ad, ah, ah)
			local aj = string.find(ac, ai, af, true)
			if not aj then
				return nil
			end
			ag = ag + (aj - af)
			af = aj + 1
		end
		return 1000 + ag
	end
function ab.Apply(ad)
	local ae = ad.State
	if not ae.PopupContainer or not ae.PopupScroll then
		return #ad.Options
	end
	local af = {}
	for ag, ah in ae.OptionRowData do
		local ai = ah.Label or (ad.Options[ag] and ad.Options[ag].Label) or ""
		local aj = ac(ai, ad.Query)
		if aj then
			table.insert(af, { Data = ah, Score = aj, Index = ag })
		else
			ah.Row.Visible = false
		end
	end
	table.sort(af, function(ag, ah)
		if ag.Score == ah.Score then
			return ag.Index < ah.Index
		end
		return ag.Score < ah.Score
	end)
	for ag, ah in af do
		local ai = ah.Data.Row
		ai.Visible = true
		ai.LayoutOrder = ag
	end
	local ag = #af
	local ah, ai = aa.GetContentHeight(ag), aa.GetVisibleHeight(ag, ad.ScreenGui.AbsoluteSize.Y)
	ae.PopupScroll.CanvasSize = UDim2.fromOffset(0, ah)
	ae.PopupScroll.CanvasPosition = Vector2.zero
	ae.PopupScroll.Size = UDim2.new(1, 0, 0, ai)
	ae.PopupContainer.Size = UDim2.fromOffset(ad.PopupWidth, aa.GetContainerHeight(ai))
	ad.Reposition(nil)
	return ag
end
return table.freeze(ab)
end
a["Elements/SelectSelection"]=function()
local aa = {}
function aa.NormalizeMaxSelection(ab)
	if ab == nil then
		return 1
	end
	local ac = math.floor(ab)
	if ac == 0 then
		return math.huge
	end
	if ac < 0 then
		return 1
	end
	return ac
end
function aa.InitSelectedMap(ab, ac)
	local ad = {}
	if not ab then
		return ad
	end
	local ae = 0
	for af, ag in ab do
		if ae >= ac then
			break
		end
		ad[ag] = true
		ae = ae + 1
	end
	return ad
end
function aa.GetSelectedOptions(ab, ac)
	local ad, ae = {}, {}
	for af, ag in ab do
		if ac[ag.Value] then
			table.insert(ad, ag.Value)
			table.insert(ae, ag)
		end
	end
	return ad, ae
end
function aa.HasSelectionChanged(ab, ac)
	for ad in ab do
		if not ac[ad] then
			return true
		end
	end
	for ad in ac do
		if not ab[ad] then
			return true
		end
	end
	return false
end
function aa.GetFirstSelectedIndex(ab, ac)
	for ad, ae in ab do
		if ac[ae.Value] then
			return ad
		end
	end
	return nil
end
return aa
end
a["Elements/Slider"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag, ah, ai, aj = aa.Creator, aa.Animator, d("Core/SafeCall"), d("Core/Types"), d("UI/Element"), d("Elements/SliderRail"), d("Elements/SliderInput"), d("Elements/InputField"), d("Localization/Localization")
local ak, al = ab.New, {}
al.__type = "Slider"
function al.New(am, an, ao, ap)
	local aq, ar = ao or {}
	if aj.IsTagged(aq.Title) then
		ar = aq.Title
	else
		ar = (type(an) == "string" and an) or aq.Title or ""
	end
	local as, at, e, f = aq.Min or 0, aq.Max or 100, aq.Step or 1, aq.Suffix or "%"
	local g, h, i =
		math.max(at - as, 1), ap and ap.ColumnCount == 1 or false, function(g)
			local h = math.clamp(g, as, at)
			if e > 0 then
				h = math.clamp(math.round((h - as) / e) * e + as, as, at)
			end
			return (tonumber(string.format("%.6g", h)))
		end
	local j, k, l, m, n, o, p, q, r =
		function(j)
			local k = j:match("^%s*(.-)%s*$") or ""
			k = k:gsub("[^%d%.%-]+$", "")
			local l = tonumber(k)
			return (l and { (i(l)) } or { nil })[1]
		end, i((aq.Default ~= nil and { aq.Default } or { as })[1]), false, (h and { (aq.Desc and 54 or 40) } or { (aq.Desc and 72 or 58) })[1]
	local s = af.New({
		Title = ar,
		Desc = aq.Desc,
		Height = m,
		LabelOffsetY = aq.Desc and 10 or (h and 10 or 12),
		AlignControlsTop = h,
		DescResize = not h,
		Hover = false,
	})
	local t = s.Container:FindFirstChildOfClass("UIListLayout")
	if t and t:IsA("UIListLayout") then
		t.Padding = UDim.new(0, 8)
	end
	local u = ai.Create({
		MultiLine = false,
		Text = tostring(k) .. f,
		Placeholder = "",
		ShellSize = UDim2.fromOffset(40, 22),
		TextEditable = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextBoxSize = UDim2.fromScale(1, 1),
		TextBoxPosition = UDim2.fromScale(0, 0),
		Tokens = {
			Bg = "SliderValueBg",
			BgTransparency = "SliderValueBgTransparency",
			Stroke = "StrokeColor",
			StrokeTransparency = "StrokeTransparency",
			Text = "SliderValueText",
			Placeholder = "InputPlaceholder",
			TextSize = "TextSizeSmall",
		},
	})
	local v = u.FieldShell
	v.Name = "ValueBadge"
	v.ZIndex = 7
	v.LayoutOrder = h and 2 or 0
	local w, x, y, z, A =
		u.TextBox,
		u.FieldStroke,
		u.RestingStrokeTransparency,
		u.FocusedStrokeTransparency,
		TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	ab.TrackConnection(
		s.Root,
		w.Focused:Connect(function()
			l = true
			w.TextEditable = true
			w.Text = tostring(k)
			w.CursorPosition = #w.Text + 1
			ac.Tween(v, { Size = UDim2.fromOffset(48, 22) }, A)
			ac.Tween(x, { Transparency = z }, A)
		end)
	)
	ab.TrackConnection(
		s.Root,
		w.FocusLost:Connect(function()
			local B = j(w.Text)
			w.TextEditable = false
			ac.Tween(v, { Size = UDim2.fromOffset(40, 22) }, A)
			ac.Tween(x, { Transparency = y }, A)
			l = false
			if B then
				o(B, p, true)
			else
				w.Text = tostring(k) .. f
			end
		end)
	)
	local B = ab.GetThemeProperty("CornerRadiusFull") or UDim.new(1, 0)
	local C = ak(
		"Frame",
		{
			Name = "SliderFill",
			BackgroundColor3 = ab.GetThemeProperty("SliderFill") or Color3.fromRGB(255, 185, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromScale((k - as) / g, 1),
			[ab.ThemeTag] = { BackgroundColor3 = "SliderFill" },
		},
		{ ak("UICorner", { CornerRadius = B }) }
	)
	local D = ak(
		"Frame",
		{
			Name = "SliderRail",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = ab.GetThemeProperty("SliderRail") or Color3.fromRGB(140, 140, 140),
			BackgroundTransparency = ab.GetThemeProperty("SliderRailTransparency") or 0.9,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 4),
			[ab.ThemeTag] = { BackgroundColor3 = "SliderRail", BackgroundTransparency = "SliderRailTransparency" },
		},
		{ ak("UICorner", { CornerRadius = B }), C }
	)
	if h then
		D.Position = UDim2.new(0.5, 0, 0.5, 1)
		q, r = ag.Create(D, s, v)
	else
		D.AnchorPoint = Vector2.new(0.5, 1)
		D.Position = UDim2.new(0.5, 0, 1, -12)
		D.Size = UDim2.new(1, -28, 0, 4)
		D.Parent = s.Root
	end
	local E = ak(
		"Frame",
		{
			Name = "KnobInner",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = ab.GetThemeProperty("SliderFill") or Color3.fromRGB(255, 185, 255),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			ZIndex = 3,
			[ab.ThemeTag] = { BackgroundColor3 = "SliderFill" },
		},
		{ ak("UICorner", { CornerRadius = B }) }
	)
	local F = ak(
		"Frame",
		{
			Name = "KnobShadow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = ab.GetThemeProperty("SliderKnobShadow") or Color3.fromRGB(22, 24, 28),
			BackgroundTransparency = ab.GetThemeProperty("SliderKnobShadowTransparency") or 0.9,
			BorderSizePixel = 0,
			Position = UDim2.new((k - as) / g, 0, 0.5, 0),
			Size = UDim2.fromOffset(18, 18),
			ZIndex = 2,
			[ab.ThemeTag] = {
				BackgroundColor3 = "SliderKnobShadow",
				BackgroundTransparency = "SliderKnobShadowTransparency",
			},
		},
		{ ak("UICorner", { CornerRadius = B }), E }
	)
	F.Parent = D
	p = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	n = function(G, H)
		local I, J = { Size = UDim2.fromScale(G, 1) }, { Position = UDim2.new(G, 0, 0.5, 0) }
		if H then
			ac.Tween(C, I, H)
			ac.Tween(F, J, H)
		else
			ac.Set(C, I)
			ac.Set(F, J)
		end
	end
	local G = function(G, H)
		if G == k then
			if not l then
				w.Text = tostring(k) .. f
			end
			return false
		end
		k = G
		if not l then
			w.Text = tostring(k) .. f
		end
		if H then
			local I = aq.Callback
			if I then
				ad.Call(I, k)
			end
		end
		return true
	end
	o = function(H, I, J)
		local K = i(H)
		n((K - as) / g, I)
		G(K, J)
	end
	v.Parent = s.Container
	local H, I, J, K, L =
		function(H, I)
			local J = math.clamp(H, 0, 1)
			n(J, I)
			local K = i(as + J * (at - as))
			G(K, true)
		end, function(H)
			local I = D.AbsoluteSize.X
			return I < 1 and 0 or math.clamp((H - D.AbsolutePosition.X) / I, 0, 1)
		end, (q and { q } or { s.Root })[1], (h and { (UDim2.fromScale(0.5, 0.5)) } or { (UDim2.new(0.5, 0, 1, -14)) })[1], (h and { (UDim2.fromScale(1.1, 1.1)) } or { (UDim2.new(1, -16, 0, 18)) })[1]
	ah.Wire({
		RootOrHost = J,
		HitPos = K,
		HitSize = L,
		IsEditing = function()
			return l
		end,
		SetValueFromFraction = H,
		ComputeFraction = I,
		JUMP_INFO = p,
	})
	local M = { Root = s.Root, Type = "Slider" }
	function M.Mount(N, O)
		s:Mount(O)
	end
	function M.SetValue(N, O)
		o(O, p, false)
	end
	function M.GetValue(N)
		return k
	end
	function M.Pack(N)
		return k
	end
	function M.Unpack(N, O, P)
		if type(O) ~= "number" then
			return
		end
		o(O, p, P ~= nil and P.Callbacks == true)
	end
	M.Save = M.Pack
	M.Load = M.Unpack
	function M.SetTitle(N, O)
		s:SetTitle(O)
	end
	function M.SetDesc(N, O)
		s:SetDesc(O)
	end
	function M.Destroy(N)
		ac.CancelInstance(C)
		ac.CancelInstance(F)
		ac.CancelInstance(v)
		ac.CancelInstance(x)
		s:Destroy()
	end
	return M
end
return al
end
a["Elements/SliderInput"]=function()
local aa, ab = game:GetService("UserInputService"), d("Core/Common")
local ac, ad = ab.Creator, ab.SignalManager
local ae, af = ac.New, {}
function af.Wire(ag)
	local ah = ae(
		"TextButton",
		{
			Name = "SliderHitZone",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = ag.HitPos,
			Size = ag.HitSize,
			ZIndex = 6,
		}
	)
	ah.Parent = ag.RootOrHost
	local ai, aj, ak, al = false
	local am, an =
		function()
			ai = false
			if al then
				al:Destroy()
				al = nil
			end
			aj = nil
			ak = nil
		end, function()
			if not al then
				al = ad.CreateScope()
			end
			return al
		end
	local ao = function()
		if not ai or aj then
			return
		end
		aj = an():Connect(aa.InputChanged, function(ao)
			if ag.IsEditing() then
				am()
				return
			end
			local ap = ao.UserInputType
			if ap == Enum.UserInputType.MouseMovement or ap == Enum.UserInputType.Touch then
				ag.SetValueFromFraction(ag.ComputeFraction(ao.Position.X), nil)
			end
		end)
	end
	local ap = function()
		if ak then
			return
		end
		ai = true
		local ap = an()
		ak = ap:Connect(aa.InputEnded, function(aq)
			local ar = aq.UserInputType
			if ar == Enum.UserInputType.MouseButton1 or ar == Enum.UserInputType.Touch then
				am()
			end
		end)
		task.defer(ao)
	end
	ac.TrackConnection(
		ag.RootOrHost,
		ah.MouseButton1Down:Connect(function(aq)
			if ag.IsEditing() then
				return
			end
			ag.SetValueFromFraction(ag.ComputeFraction(aq), ag.JUMP_INFO)
			ap()
		end)
	)
	ac.TrackConnection(ag.RootOrHost, ag.RootOrHost.Destroying:Connect(am))
end
return af
end
a["Elements/SliderRail"]=function()
local aa = d("Core/Common")
local ab = aa.Creator
local ac, ad, ae, af, ag, ah, ai = ab.New, {}, 120, 48, 132, 96, 12
function ad.Create(aj, ak, al)
	local am = ac(
		"Frame",
		{ Name = "SliderRailHost", BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(0, ae, 0, 18), ZIndex = 6 }
	)
	aj.Parent = am
	am.Parent = ak.Container
	local an = function(an, ao)
		local ap = math.max(al.AbsoluteSize.X, 40)
		if an < 50 then
			return
		end
		local aq = ak.Container:FindFirstChildOfClass("UIListLayout")
		local ar = (aq and aq:IsA("UIListLayout")) and aq.Padding.Offset or 6
		local as = math.max(af, an - ah - ai - ap - ar)
		local at = math.clamp(ae, af, math.min(ag, as))
		am.Size = UDim2.new(0, at, 0, 18)
	end
	if ak.OnPostLayout then
		ak:OnPostLayout(an)
	end
	ab.TrackConnection(
		am,
		al:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			task.defer(function()
				if not am.Parent then
					return
				end
				an(ak.Body.AbsoluteSize.X, 0)
			end)
		end)
	)
	return am, an
end
return ad
end
a["Elements/Toggle"]=function()
local aa, ab = d("Elements/ToggleBase"), {}
ab.__type = "Toggle"
function ab.New(ac, ad, ae, af)
	return aa.New(ad, ae, af, false)
end
return ab
end
a["Elements/ToggleBase"]=function()
local aa, ab, ac, ad, ae, af, ag = d("Core/SafeCall"), d("UI/Element"), d("Localization/Localization"), d("Elements/ToggleRendererClassic"), d("Elements/ToggleRendererGlass"), {}, 0.08
function af.New(ah, ai, aj, ak)
	local al, am = ai or {}
	if ac.IsTagged(al.Title) then
		am = al.Title
	else
		am = (type(ah) == "string" and ah) or al.Title or ""
	end
	local an, ao, ap, aq, ar =
		al.Default == true, ab.New({ Title = am, Desc = al.Desc, Hover = true }), ak == true, -math.huge
	local as = function(as)
		local at = as == true
		if at == an then
			return false
		end
		local e = os.clock()
		if e - aq < ag then
			return false
		end
		aq = e
		an = at
		if ar then
			ar:SetValue(an, true)
		end
		aa.Call(al.Callback, an)
		return true
	end
	local at = function()
		local at = (ap and { ad } or { ae })[1]
		ar = at.New(ao, an, as)
	end
	at()
	local e = { Root = ao.Root, Type = "Toggle" }
	function e.Mount(f, g)
		ao:Mount(g)
	end
	function e.GetValue(f)
		return an
	end
	function e.SetValue(f, g)
		an = g == true
		if ar then
			ar:SetValue(an, true)
		end
	end
	function e.Pack(f)
		return an
	end
	function e.Unpack(f, g, h)
		if type(g) ~= "boolean" then
			return
		end
		an = g
		if ar then
			ar:SetValue(an, true)
		end
		if h ~= nil and h.Callbacks == true then
			aa.Call(al.Callback, an)
		end
	end
	e.Save = e.Pack
	e.Load = e.Unpack
	function e.SetTitle(f, g)
		ao:SetTitle(g)
	end
	function e.SetDesc(f, g)
		ao:SetDesc(g)
	end
	function e.SetRenderer(f, g)
		local h = g == true
		if h == ap then
			return
		end
		ap = h
		if ar then
			ar:Destroy()
			ar = nil
		end
		at()
	end
	function e.GetRendererMode(f)
		return ap and "classic" or "glass"
	end
	function e.Destroy(f)
		if f._SeaHubDestroyed then
			return
		end
		f._SeaHubDestroyed = true
		if ar then
			ar:Destroy()
			ar = nil
		end
		ao:Destroy()
	end
	return e
end
return af
end
a["Elements/ToggleClassic"]=function()
local aa, ab = d("Elements/ToggleBase"), {}
ab.__type = "Toggle"
function ab.New(ac, ad, ae, af)
	return aa.New(ad, ae, af, true)
end
return ab
end
a["Elements/ToggleRendererClassic"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae = aa.Creator, aa.Animator, aa.SignalManager, aa.WindowDrag
local af, ag, ah, ai = ab.New, {}, 16, 0.2
function ag.New(aj, ak, al)
	local am, an, ao, ap, aq =
		ad.CreateScope(),
		ak == true,
		UDim2.fromScale(1, 0.5),
		UDim2.new(0, ah, 0.5, 0),
		af(
			"UIGradient",
			{
				Color = ab.GetThemeProperty("AccentGradient") or ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 185, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 123, 160)),
				}),
				Rotation = ab.GetThemeProperty("AccentGradientRotation") or 45,
				[ab.ThemeTag] = { Color = "AccentGradient", Rotation = "AccentGradientRotation" },
			}
		)
	local ar, as, at =
		af(
			"Frame",
			{
				Name = "Dot",
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = ab.GetThemeProperty("ToggleKnob") or Color3.fromRGB(240, 240, 240),
				BorderSizePixel = 0,
				Position = (an and { ao } or { ap })[1],
				Size = UDim2.fromOffset(ah, ah),
				[ab.ThemeTag] = { BackgroundColor3 = "ToggleKnob" },
			},
			{ af("UICorner", { CornerRadius = ab.GetThemeProperty("CornerRadiusPill") or UDim.new(0, 192) }) }
		),
		ab.GetThemeProperty("ToggleTrackInactive") or Color3.fromRGB(140, 140, 140),
		ab.GetThemeProperty("ToggleTrackInactiveTransparency") or 0.9
	local e = af(
		"Frame",
		{
			Name = "ToggleTrack",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = (an and { (Color3.fromRGB(255, 255, 255)) } or { as })[1],
			BackgroundTransparency = an and 0 or at,
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(36, 20),
			[ab.ThemeTag] = (an and { nil } or {
				{ BackgroundColor3 = "ToggleTrackInactive", BackgroundTransparency = "ToggleTrackInactiveTransparency" },
			})[1],
		},
		{
			af("UICorner", { CornerRadius = ab.GetThemeProperty("CornerRadiusPill") or UDim.new(0, 192) }),
			af("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }),
			af(
				"UIStroke",
				{
					Color = ab.GetThemeProperty("ToggleTrackStroke") or Color3.fromRGB(33, 181, 226),
					Thickness = ab.GetThemeProperty("StrokeThicknessToggle") or 1.25,
					Transparency = ab.GetThemeProperty("StrokeTransparency") or 0.9,
					[ab.ThemeTag] = {
						Color = "ToggleTrackStroke",
						Thickness = "StrokeThicknessToggle",
						Transparency = "StrokeTransparency",
					},
				}
			),
			ar,
			aq,
		}
	)
	e.Parent = aj.Container
	local f, g = function(f, g)
		local h = (f and { ao } or { ap })[1]
		if f then
			ab.RemoveThemeObject(e)
			if g then
				ac.Tween(e, { BackgroundTransparency = 0 }, ai)
				ac.Tween(ar, { Position = h }, ai)
			else
				ac.Set(e, { BackgroundTransparency = 0 })
				ac.Set(ar, { Position = h })
			end
			e.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		else
			ab.AddThemeObject(
				e,
				{ BackgroundColor3 = "ToggleTrackInactive", BackgroundTransparency = "ToggleTrackInactiveTransparency" }
			)
			if g then
				ac.Tween(e, { BackgroundColor3 = as, BackgroundTransparency = at }, ai)
				ac.Tween(ar, { Position = h }, ai)
			else
				ac.Set(e, { BackgroundColor3 = as, BackgroundTransparency = at })
				ac.Set(ar, { Position = h })
			end
		end
	end
	if aj.InteractButton then
		am:Connect(aj.InteractButton.MouseButton1Down, function()
			g = ae.GetPressPosition()
		end)
		am:Connect(aj.InteractButton.MouseButton1Click, function()
			local h = g
			g = nil
			if ae.ShouldSuppressClickFrom(h) then
				return
			end
			al(not an)
		end)
	end
	f(an, false)
	local h = {}
	function h.SetValue(i, j, k)
		an = j == true
		f(an, k)
	end
	function h.GetValue(i)
		return an
	end
	function h.Destroy(i)
		am:Destroy()
		ac.CancelInstance(e)
		ac.CancelInstance(ar)
		e:Destroy()
	end
	return h
end
return ag
end
a["Elements/ToggleRendererGlass"]=function()
local aa, ab, ac = game:GetService("UserInputService"), game:GetService("RunService"), d("Core/Common")
local ad, ae, af = ac.Creator, ac.Spring, ac.SignalManager
local ag, ah, ai, aj, ak, al, am = ad.New, {}, 38, 20, 16, 14, 3
local an, ao, ap, aq, ar =
	ai - ak - am * 2,
	3,
	{ stiffness = 700, damping = 48, mass = 0.55 },
	{ stiffness = 500, damping = 25, mass = 1 },
	function(an, ao, ap)
		return math.min(math.max(an, ao), ap)
	end
function ah.New(as, at, e)
	local f, g, h =
		af.CreateScope(),
		at == true,
		ag(
			"Frame",
			{
				Name = "ToggleTrack",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(ai, aj),
				BackgroundColor3 = ad.GetThemeProperty("ToggleTrackInactive") or Color3.fromRGB(140, 140, 140),
				BackgroundTransparency = ad.GetThemeProperty("ToggleTrackInactiveTransparency") or 0.9,
				BorderSizePixel = 0,
				[ad.ThemeTag] = {
					BackgroundColor3 = "ToggleTrackInactive",
					BackgroundTransparency = "ToggleTrackInactiveTransparency",
				},
			},
			{
				ag("UICorner", { CornerRadius = UDim.new(1, 0) }),
				ag(
					"UIStroke",
					{
						Color = ad.GetThemeProperty("ToggleTrackStroke") or Color3.fromRGB(240, 240, 240),
						Transparency = 0.9,
						[ad.ThemeTag] = { Color = "ToggleTrackStroke" },
					}
				),
			}
		)
	h.Parent = as.Container
	local i = ag(
		"Frame",
		{
			Name = "Fill",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = ad.GetThemeProperty("Accent") or Color3.fromRGB(255, 185, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 1,
			[ad.ThemeTag] = { BackgroundColor3 = "Accent" },
		},
		{ ag("UICorner", { CornerRadius = UDim.new(1, 0) }) }
	)
	i.Parent = h
	local j = ag(
		"Frame",
		{
			Name = "Liquid",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, am, 0.5, 0),
			Size = UDim2.fromOffset(ak, al),
			BackgroundColor3 = ad.GetThemeProperty("BackgroundSurface") or Color3.fromRGB(20, 20, 20),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 8,
			[ad.ThemeTag] = { BackgroundColor3 = "BackgroundSurface" },
		},
		{ ag("UICorner", { CornerRadius = UDim.new(1, 0) }) }
	)
	j.Parent = h
	local k = ag(
		"Frame",
		{
			Name = "Thumb",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, am, 0.5, 0),
			Size = UDim2.fromOffset(ak, al),
			BackgroundColor3 = ad.GetThemeProperty("ToggleKnob") or Color3.fromRGB(240, 240, 240),
			BorderSizePixel = 0,
			ZIndex = 10,
			[ad.ThemeTag] = { BackgroundColor3 = "ToggleKnob" },
		},
		{ ag("UICorner", { CornerRadius = UDim.new(1, 0) }), ag(
			"UIStroke",
			{ Color = Color3.fromRGB(0, 0, 0), Transparency = 0.88 }
		) }
	)
	k.Parent = h
	local l, m, n, o, p, q, r, s, t = ae.new((g and { an } or { 0 })[1], ap), ae.new(0, aq), false, false, 0, 0
	local u, v =
		function()
			local u, v = ar(l:Get(), 0, an), ar(m:Get(), 0, 1)
			local w, x, y = ar(u / an, 0, 1), ak + am * 4.5 * v, al + am * 2.3 * v
			local z = u - (x - ak) / 2
			k.Size = UDim2.fromOffset(x, y)
			k.Position = UDim2.new(0, am + z, 0.5, 0)
			k.BackgroundTransparency = ae.Map(v, 0, 0.8)
			j.Size = UDim2.fromOffset(x, y)
			j.Position = UDim2.new(0, am + z, 0.5, 0)
			j.BackgroundTransparency = 1 - ae.Map(v, 0, 0.76)
			i.BackgroundTransparency = 1 - w
		end, function()
			if t then
				t:Disconnect()
				t = nil
			end
		end
	local w = function()
		if t then
			return
		end
		t = ab.RenderStepped:Connect(function(w)
			local x, y = l:Step(w)
			local z, A = m:Step(w)
			u()
			if y and A and not n then
				v()
			end
		end)
	end
	f:Defer(v)
	local y, z =
		function(y, z)
			if r == Enum.UserInputType.Touch then
				return y == s
			end
			if r == Enum.UserInputType.MouseButton1 then
				return (z and { (y.UserInputType == Enum.UserInputType.MouseButton1) } or { (y.UserInputType == Enum.UserInputType.MouseMovement) })[1]
			end
			return false
		end, as.InteractButton or h
	f:Connect(z.InputBegan, function(A)
		local B, C = A.UserInputType == Enum.UserInputType.MouseButton1, A.UserInputType == Enum.UserInputType.Touch
		if not B and not C then
			return
		end
		if n then
			return
		end
		n = true
		o = false
		r = A.UserInputType
		s = (C and { A } or { nil })[1]
		p = A.Position.X
		q = ar(l:Get(), 0, an)
		m:SetTarget(1)
		l:Set(q)
		w()
	end)
	f:Connect(aa.InputChanged, function(A)
		if not n or not y(A) then
			return
		end
		local B = A.Position.X - p
		if math.abs(B) > ao then
			o = true
		end
		if o then
			l:Set(ar(q + B, 0, an))
			u()
		end
	end)
	f:Connect(aa.InputEnded, function(A)
		if not n or not y(A, true) then
			return
		end
		n = false
		r = nil
		s = nil
		m:SetTarget(0)
		local B = (o and { (l:Get() >= an / 2) } or { not g })[1]
		if e(B) == false then
			l:SetTarget((g and { an } or { 0 })[1])
		end
		w()
	end)
	u()
	local A = {}
	function A.SetValue(B, C, D)
		g = C == true
		if D then
			l:SetTarget((g and { an } or { 0 })[1])
			w()
		else
			l:Set((g and { an } or { 0 })[1])
			u()
		end
	end
	function A.GetValue(B)
		return g
	end
	function A.Destroy(B)
		n = false
		f:Destroy()
		h:Destroy()
	end
	return A
end
return ah
end
a["Library"]=function()
local e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, A =
	game:GetService("RunService"),
	game:GetService("Players").LocalPlayer,
	d("Core/Logger"),
	d("Core/Creator"),
	d("Bypass/ProtectGuiHelper"),
	d("Core/ObjectPool"),
	d("Core/WindowOptions"),
	d("Core/Scheduler"),
	d("Core/Responsive"),
	d("Theme/ThemeManager"),
	d("Persist/SnapshotStorage"),
	d("Persist/SnapshotSettings"),
	d("Persist/AccountScopes"),
	d("Persist/DirtyTracker"),
	d("Persist/UiSettings"),
	d("Runtime/Sync"),
	d("Core/ThreadIdentity"),
	d("Localization/Localization"),
	d("UI/Window"),
	d("UI/PopupLayer"),
	d("UI/Notifications"),
	d("UI/Tooltip"),
	d("Bypass/Init")
local B, C = n.DefaultThemeName, s.Load()
local D = {
	Version = "0.1.0",
	Options = k.ResolveWindow(C, k.Clone(k.Default)),
	Settings = C,
	Themes = {},
	Window = nil,
	Registry = {},
	Unloaded = false,
	Theme = B,
	DialogOpen = false,
	_Notifier = nil,
	_DefaultSnapshotToken = nil,
	_SnapshotAutoSaveToken = nil,
	_SnapshotAutoSaveStats = { LastAutoSaveAt = nil, LastAutoSaveOk = nil, LastAutoSaveError = nil, SkippedUnchanged = 0 },
	_BypassInitialized = false,
}
D.Themes = n.GetThemeNames()
v.Initialize()
D.Localization = {
	t = v.t,
	Get = v.Get,
	Set = v.Set,
	GetSupported = v.GetSupported,
	Has = v.Has,
	Add = v.Add,
	OnChanged = v.OnChanged,
	Bind = v.Bind,
	tag = v.tag,
	IsTagged = v.IsTagged,
	ResolveTag = v.ResolveTag,
	Attach = v.Attach,
}
function D._RefreshThemeList(E)
	E.Themes = n.GetThemeNames()
end
function D._InitGui(E)
	if E._Gui and E._Gui.Parent then
		return
	end
	if E._Gui and not E._Gui.Parent then
		E._Gui = nil
	end
	local F, G = (u.Elevate())
	if e:IsStudio() then
		G = f.PlayerGui
	else
		local H, I = pcall(gethui)
		if H and I then
			G = I
		else
			local J, K = pcall(function()
				return cloneref(game:GetService("CoreGui"))
			end)
			if J and K then
				G = K
			else
				G = game:GetService("CoreGui")
			end
		end
	end
	local H = h.New(
		"ScreenGui",
		{
			Name = "SeaHub",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			IgnoreGuiInset = true,
			ScreenInsets = Enum.ScreenInsets.None,
			DisplayOrder = math.random(1, 30000),
		}
	)
	i(H, G)
	E._Gui = H
	F()
end
function D._ResolveTheme(E, F)
	local G = n.ResolveKey(F)
	local H = (G and { (n.GetRawThemeData(G)) } or { nil })[1]
	if H then
		E.Theme = G
		return H
	end
	g.Warn("Unknown theme:", F, "fallback to", B)
	E.Theme = B
	return n.GetRawThemeData(B)
end
function D._EnsureNotifier(E)
	if E._Notifier then
		return E._Notifier
	end
	E:_InitGui()
	local F = E:_ResolveTheme(E.Theme)
	h.SetThemeData(F, n.GetRawThemeData(B))
	E._Notifier = y.New({ Parent = E._Gui })
	return E._Notifier
end
function D.Tooltip(E)
	E:_InitGui()
	return z.Get(E._Gui)
end
function D.SetTooltipMode(E, F)
	z.SetMode(F)
end
function D._ScheduleDefaultSnapshotLoad(E)
	local F = {}
	E._DefaultSnapshotToken = F
	l.Defer(function()
		l.Defer(function()
			if E._DefaultSnapshotToken == F and E.Window then
				q.ClaimPending()
				E:LoadDefaultSnapshot()
				t.PublishLocalBaseline(E.Window)
			end
		end, "Low")
	end, "Low")
end
function D._GetAutoSaveSnapshotName(E)
	return ("Auto Save - %s"):format(E.Theme or B)
end
function D._GetDirtyKey(E)
	return q.GetFolder(), E.Theme or B
end
function D._SetSnapshotDirty(E, F)
	local G, H = E:_GetDirtyKey()
	if F == true then
		r.Mark(G, H)
	else
		r.Clear(G, H)
	end
end
function D.MarkSnapshotDirty(E)
	local F, G = E:_GetDirtyKey()
	r.Mark(F, G)
	if E.Window and not E._RuntimeReportPending then
		E._RuntimeReportPending = true
		task.defer(function()
			E._RuntimeReportPending = false
			t.ReportWindowState(E.Window)
		end)
	end
end
function D.IsSnapshotDirty(E)
	local F, G = E:_GetDirtyKey()
	return r.IsDirty(F, G)
end
function D.ReportSnapshotOptions(E, F, G)
	t.ReportOptions(F, G)
end
function D.GetSnapshotAutoSaveStats(E)
	return {
		Dirty = E:IsSnapshotDirty(),
		LastAutoSaveAt = E._SnapshotAutoSaveStats.LastAutoSaveAt,
		LastAutoSaveOk = E._SnapshotAutoSaveStats.LastAutoSaveOk,
		LastAutoSaveError = E._SnapshotAutoSaveStats.LastAutoSaveError,
		SkippedUnchanged = E._SnapshotAutoSaveStats.SkippedUnchanged,
	}
end
function D._SaveAutoSnapshot(E)
	if not E.Window then
		return false
	end
	if not E:IsSnapshotDirty() then
		do
			local F = E._SnapshotAutoSaveStats
			F.SkippedUnchanged = F.SkippedUnchanged + 1
		end
		return true
	end
	local F, G, H = (E:GetDefaultSnapshotName(E.Theme))
	if type(F) ~= "string" or F == "" then
		F = E:_GetAutoSaveSnapshotName()
		G, H = E:SaveSnapshot(F)
		if G then
			E:SetDefaultSnapshotName(E.Theme, F)
		end
	else
		G, H = E:SaveSnapshot(F)
	end
	E._SnapshotAutoSaveStats.LastAutoSaveAt = os.time()
	E._SnapshotAutoSaveStats.LastAutoSaveOk = G == true
	E._SnapshotAutoSaveStats.LastAutoSaveError = (G and { nil } or { (tostring(H or "unknown error")) })[1]
	return G == true
end
function D._RestartSnapshotAutoSave(E, F)
	local G = p.Get()
	local H = G.AutoSave
	local I, J = type(H) == "table" and H.Enabled == true, {}
	E._SnapshotAutoSaveToken = (I and { J } or { nil })[1]
	if not I then
		return
	end
	local function K()
		if E.Unloaded or E._SnapshotAutoSaveToken ~= J then
			return
		end
		E:_SaveAutoSnapshot()
		local L = p.Get()
		local M = L.AutoSave
		if type(M) == "table" and M.Enabled == true then
			task.delay(p.GetIntervalSeconds(M.Interval), K)
		end
	end
	if F then
		task.defer(K)
	else
		task.delay(p.GetIntervalSeconds(H.Interval), K)
	end
end
function D.CreateWindow(E, F)
	assert(F and F.Title, "Window \u{2014} missing Title")
	if E.Unloaded then
		E.Unloaded = false
	end
	if E.Window then
		g.Warn("Only one window can be created")
		return E.Window
	end
	if not E._BypassInitialized then
		E._BypassInitialized = true
		local G = A.Initialize()
		if not G.Success then
			g.Warn("Bypass initialization incomplete")
		end
	end
	E:_InitGui()
	E.Settings = s.Load()
	local G = E.Settings.Theme
	E.Theme = F.Theme or (type(G) == "string" and G) or B
	local H = E:_ResolveTheme(E.Theme)
	h.SetThemeData(H, n.GetRawThemeData(B))
	E.Registry = {}
	E.Options = k.ResolveWindow(F, E.Options)
	local I = w.New({
		Title = F.Title,
		Sidebar = F.Sidebar,
		Size = F.Size,
		Position = F.Position,
		Parent = E._Gui,
		Registry = E.Registry,
		DragFpsCap = E.Options.DragFpsCap,
		UseDragSkeleton = E.Options.UseDragSkeleton,
		UseFullVisibilityAnimation = E.Options.UseFullVisibilityAnimation,
		UseClassicToggle = E.Options.UseClassicToggle,
		OverlayEnabled = (type(F.OverlayEnabled) == "boolean" and { F.OverlayEnabled } or {
			(E.Settings.OverlayEnabled ~= false),
		})[1],
		SnapshotApplyCallbacks = E.Options.SnapshotApplyCallbacks,
		GetSetting = function(I)
			return E:GetSetting(I)
		end,
		SetSetting = function(I, J)
			return E:SetSetting(I, J)
		end,
		PersistSetting = function(I, J)
			return E:SetSetting(I, J)
		end,
		GetThemes = function()
			return E:GetThemes()
		end,
		GetThemePresets = function()
			return E:GetThemePresets()
		end,
		GetCurrentThemeName = function()
			return E:GetCurrentThemeName()
		end,
		GetThemeData = function(I)
			return E:GetThemeData(I)
		end,
		SetTheme = function(I)
			E:SetTheme(I)
		end,
		AddTheme = function(I)
			E:AddTheme(I)
		end,
		PatchThemeTokens = function(I, J)
			return E:PatchThemeTokens(I, J)
		end,
		SaveThemeFile = function(I, J)
			return E:SaveThemeFile(I, J)
		end,
		LoadThemeFile = function(I, J)
			return E:LoadThemeFile(I, J)
		end,
		ListThemeFiles = function()
			return E:ListThemeFiles()
		end,
		SaveSnapshot = function(I)
			return E:SaveSnapshot(I)
		end,
		LoadSnapshot = function(I)
			return E:LoadSnapshot(I)
		end,
		ListSnapshots = function()
			return E:ListSnapshots()
		end,
		DeleteSnapshot = function(I)
			return E:DeleteSnapshot(I)
		end,
		DuplicateSnapshot = function(I, J)
			return E:DuplicateSnapshot(I, J)
		end,
		RenameSnapshot = function(I, J)
			return E:RenameSnapshot(I, J)
		end,
		GetDefaultSnapshotName = function(I)
			return E:GetDefaultSnapshotName(I)
		end,
		SetDefaultSnapshotName = function(I, J)
			return E:SetDefaultSnapshotName(I, J)
		end,
		GetSnapshotSettings = function()
			return E:GetSnapshotSettings()
		end,
		SetSnapshotAutoSave = function(I, J)
			return E:SetSnapshotAutoSave(I, J)
		end,
		GetSnapshotSyncAccounts = function()
			return E:GetSnapshotSyncAccounts()
		end,
		SetSnapshotSyncAccounts = function(I)
			return E:SetSnapshotSyncAccounts(I)
		end,
		ListSnapshotAccountScopes = function()
			return E:ListSnapshotAccountScopes()
		end,
		ListSnapshotsInScope = function(I)
			return E:ListSnapshotsInScope(I)
		end,
		BorrowSnapshot = function(I, J, K)
			return E:BorrowSnapshot(I, J, K)
		end,
		GetLocale = function()
			return E:GetLocale()
		end,
		SetLocale = function(I)
			return E:SetLocale(I)
		end,
		GetSupportedLocales = function()
			return E:GetSupportedLocales()
		end,
		OnLocaleChanged = function(I)
			return E:OnLocaleChanged(I)
		end,
		MarkSnapshotDirty = function()
			E:MarkSnapshotDirty()
		end,
		IsSnapshotDirty = function()
			return E:IsSnapshotDirty()
		end,
		ReportSnapshotOptions = function(I, J)
			E:ReportSnapshotOptions(I, J)
		end,
		GetSnapshotAutoSaveStats = function()
			return E:GetSnapshotAutoSaveStats()
		end,
		DuplicateTheme = function(I, J)
			return E:DuplicateTheme(I, J)
		end,
		DeleteTheme = function(I)
			return E:DeleteTheme(I)
		end,
		RenameTheme = function(I, J)
			return E:RenameTheme(I, J)
		end,
		Notify = function(I)
			return E:Notify(I)
		end,
		OnDialogStateChanged = function(I)
			E.DialogOpen = I
		end,
		OnClose = function()
			E:Destroy()
		end,
	})
	E.Window = I
	I.Localization = E.Localization
	E.DialogOpen = false
	m.Init(E._Gui)
	pcall(function()
		E:_EnsureNotifier()
	end)
	E:_ScheduleDefaultSnapshotLoad()
	E:_RestartSnapshotAutoSave(false)
	E._RuntimeSyncDetach = t.Attach(I)
	g.Info("Window created:", F.Title)
	return I
end
function D.SetOption(E, F, G)
	local H = k.Set(E.Options, F, G, E.Window)
	if H then
		E:SetSetting(F, E.Options[F])
	end
	return H
end
function D.GetOptions(E)
	return k.Clone(E.Options)
end
function D.GetSetting(E, F)
	return E.Settings[F]
end
function D.SetSetting(E, F, G)
	local H = s.Set(F, G)
	if not H then
		return false
	end
	E.Settings[F] = G
	if k.Default[F] ~= nil then
		k.Set(E.Options, F, G, nil)
	end
	return true
end
function D.SetTheme(E, F)
	local G = n.ResolveKey(F)
	local H = (G and { (n.GetRawThemeData(G)) } or { nil })[1]
	if not H then
		g.Warn("Unknown theme:", F)
		return
	end
	E.Theme = G
	h.SetThemeData(H, n.GetRawThemeData(B))
	s.Set("Theme", G)
	E.Settings.Theme = G
	g.Debug("Theme set to", G)
end
function D.AddTheme(E, F)
	local G = n.AddTheme(F)
	E:_RefreshThemeList()
	if E.Theme == G then
		h.SetThemeData(n.GetRawThemeData(G), n.GetRawThemeData(B))
	end
	g.Debug("Theme registered:", G)
end
function D.GetThemes(E)
	return table.clone(E.Themes)
end
function D.GetThemePresets(E)
	return n.GetThemePresets(E.Theme)
end
function D.GetCurrentThemeName(E)
	return E.Theme
end
function D.GetThemeData(E, F)
	local G = F or E.Theme
	local H = n.GetThemeData(G)
	if not H then
		g.Warn("GetThemeData: unknown theme:", tostring(G))
		return nil
	end
	return H
end
function D.PatchThemeTokens(E, F, G)
	if type(G) ~= "table" then
		g.Warn("PatchThemeTokens: TokenPatch must be a table")
		return false, "invalid token patch"
	end
	local H = F or E.Theme
	local I, J, K, L = n.ResolveKey(H), n.PatchThemeTokens(H, G)
	if not J or not K or not L then
		g.Warn("PatchThemeTokens:", K or "unknown theme")
		return false, K
	end
	E:_RefreshThemeList()
	if E.Theme == I or E.Theme == K then
		E.Theme = K
		h.SetThemeData(L, n.GetRawThemeData(B))
	end
	return true, K
end
function D.SaveThemeFile(E, F, G)
	local H = F or E.Theme
	local I, J, K, L = n.ResolveKey(H), n.SaveThemeFile(H, G)
	if not J then
		return false, K
	end
	if K and L and (E.Theme == I or E.Theme == K) then
		E.Theme = K
		E:_RefreshThemeList()
		h.SetThemeData(L, n.GetRawThemeData(B))
	end
	return true, K
end
function D.LoadThemeFile(E, F, G)
	local H, I = n.LoadThemeFile(F, G)
	if not H or not I then
		return false, I
	end
	E:_RefreshThemeList()
	E:SetTheme(I)
	return true, I
end
function D.ListThemeFiles(E)
	return n.ListThemeFiles()
end
function D.SaveSnapshot(E, F)
	if not E.Window then
		return false, "window unavailable"
	end
	local G = E.Window:Snapshot(F)
	local H, I = o.SaveSnapshot(F, G)
	if H then
		E:_SetSnapshotDirty(false)
	end
	return H, I
end
function D.LoadSnapshot(E, F)
	local G, H = o.LoadSnapshot(F)
	if not G or type(H) ~= "table" then
		return false, tostring(H)
	end
	E:_RunApply(H)
	E:_SetSnapshotDirty(false)
	return true, F
end
function D.ListSnapshots(E)
	return o.ListSnapshotMeta()
end
function D.DeleteSnapshot(E, F)
	return o.DeleteSnapshot(F)
end
function D.DuplicateSnapshot(E, F, G)
	return o.DuplicateSnapshot(F, G)
end
function D.RenameSnapshot(E, F, G)
	return o.RenameSnapshot(F, G)
end
function D.GetDefaultSnapshotName(E, F)
	return o.GetDefaultSnapshot(F or E.Theme)
end
function D.SetDefaultSnapshotName(E, F, G)
	return o.SetDefaultSnapshot(F or E.Theme, G)
end
function D.LoadDefaultSnapshot(E)
	local F = E:GetDefaultSnapshotName(E.Theme)
	if not F then
		return false, "no default snapshot"
	end
	return E:LoadSnapshot(F)
end
function D.GetSnapshotSettings(E)
	return p.Get()
end
function D.SetSnapshotAutoSave(E, F, G)
	local H = p.Get()
	H.AutoSave.Enabled = F == true
	if type(G) == "string" then
		H.AutoSave.Interval = G
	end
	local I = p.Set(H)
	if I then
		E:_RestartSnapshotAutoSave(H.AutoSave.Enabled)
	end
	return I, (I and { H } or { nil })[1]
end
function D.GetSnapshotSyncAccounts(E)
	return q.IsSynced()
end
function D.SetSnapshotSyncAccounts(E, F)
	local G = F == true
	if q.IsSynced() == G then
		return true
	end
	if E.Window and E:IsSnapshotDirty() then
		E:_SaveAutoSnapshot()
	end
	local H = q.SetSynced(G)
	if not H then
		return false
	end
	o.MigrateScope(not G, G)
	local I = p.Get()
	E:_RestartSnapshotAutoSave(I.AutoSave.Enabled == true)
	return true
end
function D.ListSnapshotAccountScopes(E)
	local F, G = q.GetCurrentUserId(), {}
	for H, I in q.ListAccountScopes() do
		table.insert(G, { UserId = I.UserId, Folder = I.Folder, IsCurrent = F ~= nil and I.UserId == F })
	end
	return G
end
function D.ListSnapshotsInScope(E, F)
	return o.ListSnapshotsInScope(F)
end
function D.BorrowSnapshot(E, F, G, H)
	return o.BorrowSnapshot(F, G, H)
end
function D.GetLocale(E)
	return v.Get()
end
function D.SetLocale(E, F)
	return v.Set(F)
end
function D.GetSupportedLocales(E)
	return v.GetSupported()
end
function D.OnLocaleChanged(E, F)
	return v.OnChanged(function(G)
		F(G)
	end)
end
function D.DuplicateTheme(E, F, G)
	local H = n.DuplicateTheme(F, G)
	if H then
		E:_RefreshThemeList()
	end
	return H
end
function D.DeleteTheme(E, F)
	local G, H = n.ResolveKey(F), n.DeleteTheme(F)
	if not H then
		return false
	end
	E:_RefreshThemeList()
	if E.Theme == G then
		E:SetTheme(B)
	end
	return true
end
function D.RenameTheme(E, F, G)
	local H, I = n.ResolveKey(F), n.RenameTheme(F, G)
	if not I then
		return nil
	end
	E:_RefreshThemeList()
	if E.Theme == H then
		E.Theme = I
		h.SetThemeData(n.GetRawThemeData(I), n.GetRawThemeData(B))
	end
	return I
end
function D.Notify(E, F)
	if E.Unloaded then
		g.Warn("Notify ignored because SeaHub is unloaded")
		return nil
	end
	local G, H = pcall(function()
		local G = E:_EnsureNotifier()
		return G:Notify(F)
	end)
	if not G then
		g.Warn("Notify failed:", tostring(H))
		return nil
	end
	if type(F) == "table" then
		g.Debug("Notification:", F.Title or "untitled")
	elseif type(F) == "string" then
		g.Debug("Notification:", F)
	else
		g.Debug("Notification:", "untitled")
	end
	return H
end
function D.Snapshot(E, F)
	if E.Window and E.Window.Snapshot then
		return E.Window:Snapshot(F)
	end
	return nil
end
function D.ExportSnapshotSchema(E)
	if E.Window and E.Window.ExportSchema then
		return E.Window:ExportSchema()
	end
	return nil
end
function D._RunApply(E, F, G)
	if not (E.Window and E.Window.Apply) then
		return
	end
	r.BeginApply()
	local H, I = pcall(function()
		E.Window:Apply(F, G)
	end)
	task.defer(function()
		r.EndApply()
	end)
	if not H then
		g.Warn("Snapshot apply failed:", tostring(I))
	end
end
function D.Apply(E, F, G)
	E:_RunApply(F, G)
	E:_SetSnapshotDirty(false)
end
function D.Destroy(E)
	if E.Unloaded then
		return
	end
	E.Unloaded = true
	if E._RuntimeSyncDetach then
		pcall(E._RuntimeSyncDetach)
		E._RuntimeSyncDetach = nil
	end
	l.Clear()
	m.Destroy()
	x.Destroy()
	if E._Notifier then
		E._Notifier:Destroy()
		E._Notifier = nil
	end
	if E.Window then
		E.Window:Destroy()
	end
	h.Disconnect()
	j.DrainAll()
	if E._Gui then
		E._Gui:Destroy()
		E._Gui = nil
	end
	E.Window = nil
	E.Registry = {}
	E.DialogOpen = false
	E._DefaultSnapshotToken = nil
	E._SnapshotAutoSaveToken = nil
	r.Reset()
	g.Info("SeaHub destroyed")
end
D.Bypass = {
	Initialize = A.Initialize,
	InitializeWithProgress = A.InitializeWithProgress,
	QuickCheck = A.QuickCheck,
	ProtectGui = A.ProtectGui,
	GetSecureContainer = A.GetSecureContainer,
	GetProtectionLevel = A.GetProtectionLevel,
	IsAdonisBypassed = A.IsAdonisBypassed,
	GetAdonisStatus = A.GetAdonisStatus,
	DetectEnvironment = A.DetectEnvironment,
	HasBypassSupport = A.HasBypassSupport,
	HasGuiProtection = A.HasGuiProtection,
	LogCapabilities = A.LogCapabilities,
	SetStudioMode = A.SetStudioMode,
	SetSecureContainer = A.SetSecureContainer,
}
return D
end
a["Localization/LocaleConfig"]=function()
return table.freeze({ SUPPORTED_LOCALES = { "en", "vi" }, DEFAULT_LOCALE = "en" })
end
a["Localization/LocaleStore"]=function()
local e, f, g, h, i =
	d("Core/FileSystem"), d("Localization/LocaleConfig"), {}, "sea/locale.json", function()
		local e, f = pcall(function()
			return (game):GetService("HttpService")
		end)
		return (e and { f } or { nil })[1]
	end
local j = function(j)
	if type(j) ~= "string" then
		return false
	end
	for k, l in f.SUPPORTED_LOCALES do
		if l == j then
			return true
		end
	end
	return false
end
function g.Read()
	if not e.IsAvailable() or not e.IsFile(h) then
		return nil
	end
	local k = e.ReadFile(h)
	if type(k) ~= "string" or k == "" then
		return nil
	end
	local l = i()
	if not l then
		return nil
	end
	local m, n = pcall(l.JSONDecode, l, k)
	if not m or type(n) ~= "table" or not j(n.Code) then
		return nil
	end
	return n.Code
end
function g.Write(k)
	if not e.IsAvailable() or not e.EnsurePath("sea") then
		return false
	end
	local l = i()
	if not l then
		return false
	end
	local m, n = pcall(l.JSONEncode, l, { Version = 1, Code = k })
	if not m then
		return false
	end
	return e.WriteFile(h, n)
end
return table.freeze(g)
end
a["Localization/Locale_en"]=function()
local e = {
	common = {
		actions = { save = "Save", close = "Close", cancel = "Cancel", delete = "Delete", yes = "Yes", no = "No" },
		state = { enabled = "Enabled", disabled = "Disabled" },
		badge = {
			default = "Default",
			invalid = "Invalid",
			builtIn = "Built-in",
			custom = "Custom",
			active = "Active",
			unsaved = "Unsaved",
		},
		placeholder = { select = "Select...", searchOptions = "Search options..." },
		selection = {
			selectedCount = function(e)
				local f = e and e.count or 0
				return ("%d selected"):format(f)
			end,
		},
		timestamp = { none = "No timestamp", noneLower = "no timestamp", unknown = "unknown", updated = "Updated {time}" },
		keybind = { none = "None" },
		tabs = { main = "Main" },
	},
	dialog = { modal = { defaultTitle = "Modal" }, confirm = { defaultTitle = "Confirm" }, colorPicker = {
		defaultTitle = "Color Picker",
	} },
	confirm = {
		snapshot = { delete = { title = "Delete Snapshot", content = "Delete snapshot '{name}'? This cannot be undone." } },
		theme = { delete = { title = "Delete Theme", content = "Delete theme '{name}'? This cannot be undone." } },
	},
	notify = {
		common = { defaultTitle = "Notification" },
		snapshot = {
			renamed = { title = "Snapshot Renamed" },
			renameFailed = { title = "Snapshot Rename Failed" },
			deleted = { title = "Snapshot Deleted" },
			deleteFailed = { title = "Snapshot Delete Failed" },
			invalid = { title = "Snapshot Invalid" },
			borrowUnavailable = { title = "Borrow Unavailable", content = "Filesystem not available" },
			nothingToBorrow = { title = "Nothing to Borrow", content = "No other accounts have saved snapshots yet." },
			borrowed = { title = "Snapshot Borrowed" },
			borrowFailed = { title = "Borrow Failed" },
			syncUpdated = { title = "Snapshot Sync Updated", shared = "Shared across accounts", perAccount = "Per account" },
			syncFailed = { title = "Snapshot Sync Failed" },
			autoSaveUpdated = { title = "Snapshot Auto Save Updated" },
			autoSaveFailed = { title = "Snapshot Auto Save Failed" },
			autoSaveFrequencyUpdated = { title = "Snapshot Auto Save Frequency" },
			applied = { title = "Snapshot Applied" },
			applyFailed = { title = "Snapshot Apply Failed" },
			defaultSet = { title = "Default Snapshot Set" },
			defaultCleared = { title = "Default Snapshot Cleared" },
			defaultFailed = { title = "Default Snapshot Failed" },
			overwritten = { title = "Snapshot Overwritten" },
			overwriteFailed = { title = "Snapshot Overwrite Failed" },
			duplicated = { title = "Snapshot Duplicated" },
			duplicateFailed = { title = "Snapshot Duplicate Failed" },
			created = { title = "Snapshot Created" },
			createFailed = { title = "Snapshot Create Failed" },
		},
		theme = {
			deleted = { title = "Theme Deleted" },
			deleteFailed = { title = "Theme Delete Failed" },
			applied = { title = "Theme Applied" },
			saved = { title = "Theme Saved" },
			saveFailed = { title = "Theme Save Failed" },
			duplicated = { title = "Theme Duplicated" },
			duplicateFailed = { title = "Theme Duplicate Failed" },
		},
		server = {
			actionStarted = { content = "Action started." },
			actionFailed = { title = "{name} Failed" },
			scheduledRejoinFailed = { title = "Scheduled Rejoin Failed", content = "Minutes must be greater than 0." },
			scheduledRejoinCancelled = { content = "Scheduled rejoin was cancelled." },
		},
		locale = { updated = { title = "Language Updated" } },
	},
	settings = {
		tabs = { settings = "Settings", general = "General", theme = "Theme", snapshots = "Snapshots" },
		localization = {
			section = { title = "Localization" },
			locale = {
				title = "Language",
				desc = "Display language for the Kyotaki Hub built-in interface.",
				options = { english = "English", vietnamese = "Vietnamese" },
			},
		},
		performance = {
			section = { title = "Performance" },
			fpsCap = {
				title = "FPS Cap",
				desc = [[Global frame rate cap for this client. Requires the executor's setfpscap function.]],
				unavailable = "Your executor does not expose setfpscap.",
				options = {
					cap1 = "1 FPS",
					cap5 = "5 FPS",
					cap15 = "15 FPS",
					cap30 = "30 FPS",
					cap60 = "60 FPS",
					cap120 = "120 FPS",
					cap144 = "144 FPS",
					cap240 = "240 FPS",
					unlimited = "Unlimited",
				},
			},
			render3d = {
				title = "3D Rendering",
				desc = [[Disable 3D world rendering to save GPU. Warning: the screen will go black; use the Toggle UI Keybind to find this setting again.]],
			},
		},
		runtime = {
			section = { title = "Window" },
			dragFpsCap = {
				title = "Drag FPS Cap",
				desc = [[0 = uncapped drag updates. Higher cap = smoother but more work.]],
			},
			useDragSkeleton = {
				title = "Use Drag Skeleton",
				desc = [[Show drag skeleton instead of moving full window while dragging.]],
			},
			fullVisibilityAnimation = {
				title = "Full UI Visibility Animation",
				desc = [[Use scale + fade like modal dialogs when hiding or showing the main window.]],
			},
			useClassicToggle = {
				title = "Use Classic Toggle",
				desc = [[Use the lightweight classic toggle instead of the animated Glass Toggle.]],
			},
			toggleUiKeybind = { title = "Toggle UI Keybind", desc = "Press this key to hide or show the Kyotaki Hub window." },
			overlay = {
				title = "Floating Logo Button",
				desc = [[Show a draggable Kyotaki Hub logo button that toggles the main UI.]],
			},
		},
		snapshot = {
			rename = {
				modal = { title = "Rename Snapshot" },
				section = { title = "Rename" },
				nameInput = { title = "Snapshot Name", desc = "Choose a new snapshot name." },
				saveButton = { title = "Save Name" },
			},
			borrow = {
				modal = { title = "Borrow Snapshot" },
				section = { title = "Pick a snapshot from another account" },
				emptyScope = "No snapshots in this scope.",
				resolving = "Loading account name...",
				card = { desc = "Updated {time} \u{2014} click to copy into this account." },
				button = {
					title = "Borrow Snapshot",
					desc = [[Copy a snapshot from another Roblox account on this executor into the current scope.]],
				},
			},
			sync = {
				section = { title = "Account Sync" },
				toggle = {
					title = "Sync Snapshots Across Accounts",
					desc = [[Off: each Roblox account stores its own snapshots, settings, and default. On: all accounts on this executor share one set of snapshots.]],
				},
			},
			autoSave = {
				section = { title = "Auto Save" },
				toggle = {
					title = "Auto Save Snapshots",
					desc = "Automatically overwrite the current theme default snapshot.",
				},
				frequency = {
					title = "Auto Save Frequency",
					desc = [[Continuous uses a short debounce-like interval; longer intervals reduce disk writes.]],
				},
				options = {
					continuous = "Continuous",
					every15Seconds = "Every 15 seconds",
					every30Seconds = "Every 30 seconds",
					every60Seconds = "Every 60 seconds",
					every5Minutes = "Every 5 minutes",
				},
			},
			create = {
				section = { title = "Create Snapshot" },
				nameInput = {
					title = "Snapshot Name",
					desc = "Create a new snapshot of current element values.",
					placeholder = "Main Snapshot",
				},
				button = { title = "Create Snapshot", desc = "Save current element values under this name." },
			},
			list = { section = { title = "Snapshots" } },
		},
		theme = {
			presets = { section = { title = "Theme Presets" } },
			customize = {
				modal = { title = "Customize: {name}" },
				overview = {
					section = { title = "Overview" },
					nameInput = {
						title = "Preset Name",
						desc = [[Rename custom themes. Built-ins clone only after the first change.]],
					},
					renameButton = { title = "Rename", desc = "Rename this custom preset." },
					saveButton = { title = "Save", desc = "Persist preset JSON into sea/themes." },
					closeButton = {
						title = "Close",
						desc = [[Close editor. Unsaved runtime changes stay marked on the theme card.]],
					},
				},
				brand = {
					section = { title = "Brand" },
					syncLogoWithAccent = { title = "Sync Logo With Accent", desc = "Logo follows Accent when enabled." },
				},
				coreColors = { section = { title = "Core Colors" } },
				components = { section = { title = "Components" } },
				shapeMotion = { section = { title = "Shape & Motion" } },
			},
			tokens = {
				color = {
					Accent = { title = "Accent", desc = "Primary accent color." },
					AccentForeground = { title = "Accent Foreground", desc = "Text/icon color on accent fill." },
					AccentDark = { title = "Accent Dark", desc = "Secondary accent color used to rebuild gradient." },
					LogoColorBase = { title = "Logo Base Color", desc = "Logo color when accent sync is disabled." },
					BackgroundMain = { title = "Background Main", desc = "Root window background." },
					BackgroundSurface = { title = "Background Surface", desc = "Cards, sidebar, tab surfaces." },
					BackgroundElevated = { title = "Background Elevated", desc = "Elevated UI surfaces." },
					Text = { title = "Text", desc = "Primary text." },
					SubText = { title = "Sub Text", desc = "Muted text." },
					TextPlaceholder = { title = "Placeholder Text", desc = "Placeholder color." },
					StrokeColor = { title = "Stroke Color", desc = "Global border color." },
					DividerColor = { title = "Divider Color", desc = "Element divider color." },
					Hover = { title = "Hover", desc = "Hover overlay color." },
					InputBg = { title = "Input Background", desc = "Input field background." },
					InputText = { title = "Input Text", desc = "Input field text." },
					SliderRail = { title = "Slider Rail", desc = "Slider track background." },
					SliderFill = { title = "Slider Fill", desc = "Slider filled portion." },
					DropdownBg = { title = "Dropdown Background", desc = "Select trigger background." },
					DropdownText = { title = "Dropdown Text", desc = "Select value text." },
					SelectPopupBg = { title = "Select Popup Background", desc = "Floating select popup background." },
					TabBar = { title = "Tab Bar", desc = "Top tab bar surface." },
					TabActive = { title = "Tab Active", desc = "Active tab text/indicator." },
					TabInactive = { title = "Tab Inactive", desc = "Inactive tab text." },
					SidebarBg = { title = "Sidebar Background", desc = "Sidebar panel background." },
					SidebarIcon = { title = "Sidebar Icon", desc = "Inactive sidebar icon." },
					SidebarIconActive = { title = "Sidebar Icon Active", desc = "Active sidebar icon." },
					SidebarActiveIndicator = { title = "Sidebar Active Indicator", desc = "Sidebar active bar." },
					DialogSurface = { title = "Dialog Surface", desc = "Dialog card surface." },
					DialogBorder = { title = "Dialog Border", desc = "Dialog border color." },
					DialogHeaderText = { title = "Dialog Header Text", desc = "Dialog title text." },
					DialogCloseIcon = { title = "Dialog Close Icon", desc = "Dialog close icon color." },
				},
				numeric = {
					AccentGradientRotation = {
						title = "Accent Gradient Rotation",
						desc = "Rotate accent gradient direction.",
					},
					BackgroundMainTransparency = {
						title = "Background Transparency",
						desc = "Window background transparency.",
					},
					StrokeTransparency = { title = "Stroke Transparency", desc = "Global border visibility." },
					HoverTransparency = { title = "Hover Transparency", desc = "Hover overlay transparency." },
					ScrollBarThickness = { title = "Scrollbar Thickness", desc = "Scrollbar width in pixels." },
					TextSizeBody = { title = "Text Size Body", desc = "Main text size." },
					TextSizeSmall = { title = "Text Size Small", desc = "Secondary text size." },
					TextSizeTab = { title = "Text Size Tab", desc = "Tab label text size." },
					CornerRadiusWindow = {
						title = "Window Corner Radius",
						desc = "Corner radius for the main window and dialogs.",
					},
					CornerRadiusSubTabs = { title = "Sub-Tabs Corner Radius", desc = "Corner radius for sub-tabs." },
					CornerRadiusSidebar = { title = "Sidebar Corner Radius", desc = "Corner radius for the sidebar panel." },
					CornerRadiusTab = { title = "Tab Corner Radius", desc = "Corner radius for individual tab buttons." },
					CornerRadiusSection = {
						title = "Section Corner Radius",
						desc = "Corner radius for inner section frames.",
					},
					PaddingWindow = { title = "Window Padding", desc = "Padding inside the main window." },
					PaddingElement = { title = "Element Padding", desc = "Internal padding for element rows." },
					PaddingInput = { title = "Input Box Padding", desc = "Horizontal padding for text inputs." },
				},
			},
		},
		server = {
			actions = {
				section = { title = "Server Actions" },
				rejoinSameServer = { title = "Rejoin Same Server", desc = "Reconnect to the current server instance." },
				manualServerHop = {
					title = "Manual Server Hop",
					desc = "Find and join a different public server on demand.",
				},
				joinLowPlayerServer = {
					title = "Join Low Player Server",
					desc = "Search for a public server with fewer active players.",
				},
			},
			lowPlayerHop = {
				section = { title = "Low Player Hop" },
				toggle = {
					title = "Server Hop if Low Player",
					desc = [[Automatically hop when the current server population is below the threshold.]],
				},
				minimumPlayers = {
					title = "Minimum Players",
					desc = [[Population threshold used by low-player server hop automation.]],
				},
			},
			scheduledRejoin = {
				section = { title = "Scheduled Rejoin" },
				minutesInput = {
					title = "Minutes to Rejoin",
					desc = "Delay before a timed rejoin action is allowed to run.",
				},
				toggle = {
					title = "Rejoin after X Minutes",
					desc = "Enable scheduled rejoin using the minutes value above.",
				},
			},
			jobJoin = {
				section = { title = "Job Join" },
				jobIdInput = {
					title = "Job ID",
					desc = "Target Roblox server JobId for direct join actions.",
					placeholder = "Paste Job ID here",
				},
				joinButton = { title = "Join Job ID", desc = "Join the server matching the Job ID field." },
				copyButton = { title = "Copy Current Job ID", desc = "Copy the current server JobId." },
			},
		},
	},
	overlay = { toggle = { tooltip = "Show or hide Kyotaki Hub" } },
	sidebar = { expand = { tooltip = "Expand sidebar" }, collapse = { tooltip = "Collapse sidebar" } },
	errors = {
		window = {
			saveSnapshotUnavailable = "save snapshot unavailable",
			loadSnapshotUnavailable = "load snapshot unavailable",
			patchThemeTokensUnavailable = "patch theme tokens unavailable",
			saveThemeFileUnavailable = "save theme file unavailable",
			loadThemeFileUnavailable = "load theme file unavailable",
		},
		server = {
			localPlayerUnavailable = "LocalPlayer is unavailable.",
			noServerListAvailable = "No server list is available.",
			noMatchingPublicServer = "No matching public server was found.",
			jobIdEmpty = "Job ID is empty.",
			clipboardUnavailable = "Clipboard API is unavailable.",
		},
	},
	formatDate = function(e)
		if not e or type(e.timestamp) ~= "number" then
			return ""
		end
		local f, g = pcall(function()
			return os.date("%Y-%m-%d %H:%M", e.timestamp)
		end)
		return (f and type(g) == "string" and { g } or { (tostring(e.timestamp)) })[1]
	end,
}
return e
end
a["Localization/Locale_vi"]=function()
local e = {
	common = {
		actions = {
			save = "L\u{1b0}u",
			close = "\u{110}\u{f3}ng",
			cancel = "H\u{1ee7}y",
			delete = "X\u{f3}a",
			yes = "C\u{f3}",
			no = "Kh\u{f4}ng",
		},
		state = { enabled = "\u{110}\u{e3} b\u{1ead}t", disabled = "\u{110}\u{e3} t\u{1eaf}t" },
		badge = {
			default = "M\u{1eb7}c \u{111}\u{1ecb}nh",
			invalid = "H\u{1ecf}ng",
			builtIn = "C\u{f3} s\u{1eb5}n",
			custom = "T\u{f9}y ch\u{1ec9}nh",
			active = "\u{110}ang d\u{f9}ng",
			unsaved = "Ch\u{1b0}a l\u{1b0}u",
		},
		placeholder = { select = "Ch\u{1ecd}n...", searchOptions = "T\u{ec}m t\u{f9}y ch\u{1ecd}n..." },
		selection = {
			selectedCount = function(e)
				local f = e and e.count or 0
				return ("\u{110}\u{e3} ch\u{1ecd}n %d"):format(f)
			end,
		},
		timestamp = {
			none = "Kh\u{f4}ng c\u{f3} th\u{1edd}i gian",
			noneLower = "kh\u{f4}ng c\u{f3} th\u{1edd}i gian",
			unknown = "kh\u{f4}ng r\u{f5}",
			updated = "C\u{1ead}p nh\u{1ead}t {time}",
		},
		keybind = { none = "Tr\u{1ed1}ng" },
		tabs = { main = "Ch\u{ed}nh" },
	},
	dialog = {
		modal = { defaultTitle = "H\u{1ed9}p tho\u{1ea1}i" },
		confirm = { defaultTitle = "X\u{e1}c nh\u{1ead}n" },
		colorPicker = { defaultTitle = "B\u{1ea3}ng m\u{e0}u" },
	},
	confirm = {
		snapshot = {
			delete = {
				title = "X\u{f3}a Snapshot",
				content = "X\u{f3}a snapshot '{name}'? Thao t\u{e1}c n\u{e0}y kh\u{f4}ng th\u{1ec3} ho\u{e0}n t\u{e1}c.",
			},
		},
		theme = {
			delete = {
				title = "X\u{f3}a Theme",
				content = "X\u{f3}a theme '{name}'? Thao t\u{e1}c n\u{e0}y kh\u{f4}ng th\u{1ec3} ho\u{e0}n t\u{e1}c.",
			},
		},
	},
	notify = {
		common = { defaultTitle = "Th\u{f4}ng b\u{e1}o" },
		snapshot = {
			renamed = { title = "\u{110}\u{e3} \u{111}\u{1ed5}i t\u{ea}n Snapshot" },
			renameFailed = { title = "\u{110}\u{1ed5}i t\u{ea}n Snapshot th\u{1ea5}t b\u{1ea1}i" },
			deleted = { title = "\u{110}\u{e3} x\u{f3}a Snapshot" },
			deleteFailed = { title = "X\u{f3}a Snapshot th\u{1ea5}t b\u{1ea1}i" },
			invalid = { title = "Snapshot b\u{1ecb} h\u{1ecf}ng" },
			borrowUnavailable = {
				title = "Kh\u{f4}ng th\u{1ec3} m\u{1b0}\u{1ee3}n",
				content = "Filesystem kh\u{f4}ng kh\u{1ea3} d\u{1ee5}ng",
			},
			nothingToBorrow = {
				title = "Kh\u{f4}ng c\u{f3} g\u{ec} \u{111}\u{1ec3} m\u{1b0}\u{1ee3}n",
				content = "Ch\u{1b0}a c\u{f3} account kh\u{e1}c l\u{1b0}u snapshot n\u{e0}o.",
			},
			borrowed = { title = "\u{110}\u{e3} m\u{1b0}\u{1ee3}n Snapshot" },
			borrowFailed = { title = "M\u{1b0}\u{1ee3}n Snapshot th\u{1ea5}t b\u{1ea1}i" },
			syncUpdated = {
				title = "\u{110}\u{e3} c\u{1ead}p nh\u{1ead}t Sync",
				shared = "D\u{f9}ng chung m\u{1ecd}i account",
				perAccount = "Ri\u{ea}ng t\u{1eeb}ng account",
			},
			syncFailed = { title = "C\u{1ead}p nh\u{1ead}t Sync th\u{1ea5}t b\u{1ea1}i" },
			autoSaveUpdated = { title = "\u{110}\u{e3} c\u{1ead}p nh\u{1ead}t t\u{1ef1} \u{111}\u{1ed9}ng l\u{1b0}u" },
			autoSaveFailed = {
				title = "C\u{1ead}p nh\u{1ead}t t\u{1ef1} \u{111}\u{1ed9}ng l\u{1b0}u th\u{1ea5}t b\u{1ea1}i",
			},
			autoSaveFrequencyUpdated = { title = "T\u{1ea7}n su\u{1ea5}t t\u{1ef1} \u{111}\u{1ed9}ng l\u{1b0}u" },
			applied = { title = "\u{110}\u{e3} \u{e1}p d\u{1ee5}ng Snapshot" },
			applyFailed = { title = "\u{c1}p d\u{1ee5}ng Snapshot th\u{1ea5}t b\u{1ea1}i" },
			defaultSet = { title = "\u{110}\u{e3} \u{111}\u{1eb7}t Snapshot m\u{1eb7}c \u{111}\u{1ecb}nh" },
			defaultCleared = { title = "\u{110}\u{e3} b\u{1ecf} Snapshot m\u{1eb7}c \u{111}\u{1ecb}nh" },
			defaultFailed = { title = "\u{110}\u{1eb7}t m\u{1eb7}c \u{111}\u{1ecb}nh th\u{1ea5}t b\u{1ea1}i" },
			overwritten = { title = "\u{110}\u{e3} ghi \u{111}\u{e8} Snapshot" },
			overwriteFailed = { title = "Ghi \u{111}\u{e8} Snapshot th\u{1ea5}t b\u{1ea1}i" },
			duplicated = { title = "\u{110}\u{e3} nh\u{e2}n b\u{1ea3}n Snapshot" },
			duplicateFailed = { title = "Nh\u{e2}n b\u{1ea3}n Snapshot th\u{1ea5}t b\u{1ea1}i" },
			created = { title = "\u{110}\u{e3} t\u{1ea1}o Snapshot" },
			createFailed = { title = "T\u{1ea1}o Snapshot th\u{1ea5}t b\u{1ea1}i" },
		},
		theme = {
			deleted = { title = "\u{110}\u{e3} x\u{f3}a Theme" },
			deleteFailed = { title = "X\u{f3}a Theme th\u{1ea5}t b\u{1ea1}i" },
			applied = { title = "\u{110}\u{e3} \u{e1}p d\u{1ee5}ng Theme" },
			saved = { title = "\u{110}\u{e3} l\u{1b0}u Theme" },
			saveFailed = { title = "L\u{1b0}u Theme th\u{1ea5}t b\u{1ea1}i" },
			duplicated = { title = "\u{110}\u{e3} nh\u{e2}n b\u{1ea3}n Theme" },
			duplicateFailed = { title = "Nh\u{e2}n b\u{1ea3}n Theme th\u{1ea5}t b\u{1ea1}i" },
		},
		server = {
			actionStarted = { content = "\u{110}\u{e3} b\u{1eaf}t \u{111}\u{1ea7}u ch\u{1ea1}y." },
			actionFailed = { title = "{name} th\u{1ea5}t b\u{1ea1}i" },
			scheduledRejoinFailed = {
				title = "H\u{1eb9}n v\u{e0}o l\u{1ea1}i th\u{1ea5}t b\u{1ea1}i",
				content = "S\u{1ed1} ph\u{fa}t ph\u{1ea3}i l\u{1edb}n h\u{1a1}n 0.",
			},
			scheduledRejoinCancelled = { content = "\u{110}\u{e3} h\u{1ee7}y h\u{1eb9}n v\u{e0}o l\u{1ea1}i." },
		},
		locale = { updated = { title = "\u{110}\u{e3} \u{111}\u{1ed5}i ng\u{f4}n ng\u{1eef}" } },
	},
	settings = {
		tabs = { settings = "C\u{e0}i \u{111}\u{1eb7}t", general = "Chung", theme = "Theme", snapshots = "Snapshots" },
		localization = {
			section = { title = "Ng\u{f4}n ng\u{1eef}" },
			locale = {
				title = "Ng\u{f4}n ng\u{1eef} hi\u{1ec3}n th\u{1ecb}",
				desc = "Ng\u{f4}n ng\u{1eef} hi\u{1ec3}n th\u{1ecb} cho giao di\u{1ec7}n s\u{1eb5}n c\u{f3} c\u{1ee7}a Kyotaki Hub.",
				options = { english = "Ti\u{1ebf}ng Anh", vietnamese = "Ti\u{1ebf}ng Vi\u{1ec7}t" },
			},
		},
		performance = {
			section = { title = "Hi\u{1ec7}u n\u{103}ng" },
			fpsCap = {
				title = "Gi\u{1edb}i h\u{1ea1}n FPS",
				desc = "Gi\u{1edb}i h\u{1ea1}n FPS to\u{e0}n client. C\u{1ea7}n executor c\u{f3} h\u{e0}m setfpscap.",
				unavailable = "Executor c\u{1ee7}a b\u{1ea1}n kh\u{f4}ng h\u{1ed7} tr\u{1ee3} setfpscap.",
				options = {
					cap1 = "1 FPS",
					cap5 = "5 FPS",
					cap15 = "15 FPS",
					cap30 = "30 FPS",
					cap60 = "60 FPS",
					cap120 = "120 FPS",
					cap144 = "144 FPS",
					cap240 = "240 FPS",
					unlimited = "Kh\u{f4}ng gi\u{1edb}i h\u{1ea1}n",
				},
			},
			render3d = {
				title = "Render 3D",
				desc = "T\u{1eaf}t render th\u{1ebf} gi\u{1edb}i 3D \u{111}\u{1ec3} gi\u{1ea3}m t\u{1ea3}i GPU. C\u{1ea3}nh b\u{e1}o: m\u{e0}n h\u{ec}nh s\u{1ebd} \u{111}en \u{2014} d\u{f9}ng Ph\u{ed}m t\u{1eaf}t \u{1ea9}n/hi\u{1ec7}n UI \u{111}\u{1ec3} m\u{1edf} l\u{1ea1}i setting n\u{e0}y.",
			},
		},
		runtime = {
			section = { title = "C\u{1eed}a s\u{1ed5}" },
			dragFpsCap = {
				title = "Gi\u{1edb}i h\u{1ea1}n FPS khi k\u{e9}o",
				desc = "0 = kh\u{f4}ng gi\u{1edb}i h\u{1ea1}n. Gi\u{e1} tr\u{1ecb} cao = m\u{1b0}\u{1ee3}t h\u{1a1}n nh\u{1b0}ng t\u{1ed1}n t\u{e0}i nguy\u{ea}n.",
			},
			useDragSkeleton = {
				title = "D\u{f9}ng Skeleton khi k\u{e9}o",
				desc = "Hi\u{1ec3}n th\u{1ecb} khung skeleton thay v\u{ec} k\u{e9}o c\u{1ea3} c\u{1eed}a s\u{1ed5}.",
			},
			fullVisibilityAnimation = {
				title = "Animation \u{111}\u{1ea7}y \u{111}\u{1ee7} khi \u{1ea9}n/hi\u{1ec7}n",
				desc = "D\u{f9}ng scale + fade nh\u{1b0} modal khi \u{1ea9}n ho\u{1eb7}c hi\u{1ec7}n c\u{1eed}a s\u{1ed5} ch\u{ed}nh.",
			},
			useClassicToggle = {
				title = "D\u{f9}ng Toggle C\u{1ed5} \u{111}i\u{1ec3}n",
				desc = "D\u{f9}ng toggle c\u{1ed5} \u{111}i\u{1ec3}n nh\u{1eb9} h\u{1a1}n thay cho Glass Toggle c\u{f3} animation.",
			},
			toggleUiKeybind = {
				title = "Ph\u{ed}m t\u{1eaf}t \u{1ea9}n/hi\u{1ec7}n UI",
				desc = "B\u{1ea5}m ph\u{ed}m n\u{e0}y \u{111}\u{1ec3} \u{1ea9}n ho\u{1eb7}c hi\u{1ec7}n c\u{1eed}a s\u{1ed5} Kyotaki Hub.",
			},
			overlay = {
				title = "N\u{fa}t logo n\u{1ed5}i",
				desc = "Hi\u{1ec7}n n\u{fa}t logo Kyotaki Hub c\u{f3} th\u{1ec3} k\u{e9}o \u{111}\u{1ec3} b\u{1ead}t/t\u{1eaf}t UI ch\u{ed}nh.",
			},
		},
		snapshot = {
			rename = {
				modal = { title = "\u{110}\u{1ed5}i t\u{ea}n Snapshot" },
				section = { title = "\u{110}\u{1ed5}i t\u{ea}n" },
				nameInput = { title = "T\u{ea}n Snapshot", desc = "Ch\u{1ecd}n t\u{ea}n m\u{1edb}i cho snapshot." },
				saveButton = { title = "L\u{1b0}u t\u{ea}n" },
			},
			borrow = {
				modal = { title = "M\u{1b0}\u{1ee3}n Snapshot" },
				section = { title = "Ch\u{1ecd}n snapshot t\u{1eeb} account kh\u{e1}c" },
				emptyScope = "Account n\u{e0}y ch\u{1b0}a c\u{f3} snapshot n\u{e0}o.",
				resolving = "\u{110}ang t\u{1ea3}i t\u{ea}n account...",
				card = {
					desc = "C\u{1ead}p nh\u{1ead}t {time} \u{2014} b\u{1ea5}m \u{111}\u{1ec3} copy v\u{1ec1} account hi\u{1ec7}n t\u{1ea1}i.",
				},
				button = {
					title = "M\u{1b0}\u{1ee3}n Snapshot",
					desc = "Copy snapshot t\u{1eeb} account Roblox kh\u{e1}c tr\u{ea}n executor n\u{e0}y v\u{1ec1} scope hi\u{1ec7}n t\u{1ea1}i.",
				},
			},
			sync = {
				section = { title = "\u{110}\u{1ed3}ng b\u{1ed9} Account" },
				toggle = {
					title = "\u{110}\u{1ed3}ng b\u{1ed9} Snapshot gi\u{1eef}a c\u{e1}c Account",
					desc = "T\u{1eaf}t: m\u{1ed7}i account Roblox l\u{1b0}u snapshot, settings v\u{e0} m\u{1eb7}c \u{111}\u{1ecb}nh ri\u{ea}ng. B\u{1ead}t: m\u{1ecd}i account tr\u{ea}n executor n\u{e0}y d\u{f9}ng chung 1 b\u{1ed9} snapshot.",
				},
			},
			autoSave = {
				section = { title = "T\u{1ef1} \u{111}\u{1ed9}ng l\u{1b0}u" },
				toggle = {
					title = "T\u{1ef1} \u{111}\u{1ed9}ng l\u{1b0}u Snapshot",
					desc = "T\u{1ef1} \u{111}\u{1ed9}ng ghi \u{111}\u{e8} snapshot m\u{1eb7}c \u{111}\u{1ecb}nh c\u{1ee7}a theme hi\u{1ec7}n t\u{1ea1}i.",
				},
				frequency = {
					title = "T\u{1ea7}n su\u{1ea5}t t\u{1ef1} \u{111}\u{1ed9}ng l\u{1b0}u",
					desc = "Continuous d\u{f9}ng debounce ng\u{1eaf}n; kho\u{1ea3}ng c\u{e1}ch d\u{e0}i h\u{1a1}n gi\u{1ea3}m l\u{1b0}\u{1ee3}ng ghi \u{111}\u{129}a.",
				},
				options = {
					continuous = "Li\u{ea}n t\u{1ee5}c",
					every15Seconds = "M\u{1ed7}i 15 gi\u{e2}y",
					every30Seconds = "M\u{1ed7}i 30 gi\u{e2}y",
					every60Seconds = "M\u{1ed7}i 60 gi\u{e2}y",
					every5Minutes = "M\u{1ed7}i 5 ph\u{fa}t",
				},
			},
			create = {
				section = { title = "T\u{1ea1}o Snapshot" },
				nameInput = {
					title = "T\u{ea}n Snapshot",
					desc = "T\u{1ea1}o snapshot m\u{1edb}i t\u{1eeb} gi\u{e1} tr\u{1ecb} element hi\u{1ec7}n t\u{1ea1}i.",
					placeholder = "Snapshot Ch\u{ed}nh",
				},
				button = {
					title = "T\u{1ea1}o Snapshot",
					desc = "L\u{1b0}u gi\u{e1} tr\u{1ecb} element hi\u{1ec7}n t\u{1ea1}i v\u{1edb}i t\u{ea}n n\u{e0}y.",
				},
			},
			list = { section = { title = "Danh s\u{e1}ch Snapshot" } },
		},
		theme = {
			presets = { section = { title = "Theme c\u{f3} s\u{1eb5}n" } },
			customize = {
				modal = { title = "T\u{f9}y ch\u{1ec9}nh: {name}" },
				overview = {
					section = { title = "T\u{1ed5}ng quan" },
					nameInput = {
						title = "T\u{ea}n Preset",
						desc = "\u{110}\u{1ed5}i t\u{ea}n theme t\u{f9}y ch\u{1ec9}nh. Theme c\u{f3} s\u{1eb5}n ch\u{1ec9} \u{111}\u{1b0}\u{1ee3}c clone sau l\u{1ea7}n \u{111}\u{1ed5}i \u{111}\u{1ea7}u ti\u{ea}n.",
					},
					renameButton = {
						title = "\u{110}\u{1ed5}i t\u{ea}n",
						desc = "\u{110}\u{1ed5}i t\u{ea}n preset t\u{f9}y ch\u{1ec9}nh n\u{e0}y.",
					},
					saveButton = { title = "L\u{1b0}u", desc = "Ghi preset JSON v\u{e0}o sea/themes." },
					closeButton = {
						title = "\u{110}\u{f3}ng",
						desc = "\u{110}\u{f3}ng editor. Thay \u{111}\u{1ed5}i runtime ch\u{1b0}a l\u{1b0}u v\u{1eab}n \u{111}\u{1b0}\u{1ee3}c \u{111}\u{e1}nh d\u{1ea5}u tr\u{ea}n theme card.",
					},
				},
				brand = {
					section = { title = "Th\u{1b0}\u{1a1}ng hi\u{1ec7}u" },
					syncLogoWithAccent = {
						title = "\u{110}\u{1ed3}ng b\u{1ed9} Logo v\u{1edb}i Accent",
						desc = "Logo theo m\u{e0}u Accent khi b\u{1ead}t.",
					},
				},
				coreColors = { section = { title = "M\u{e0}u c\u{1a1} b\u{1ea3}n" } },
				components = { section = { title = "Components" } },
				shapeMotion = { section = { title = "H\u{ec}nh & Chuy\u{1ec3}n \u{111}\u{1ed9}ng" } },
			},
			tokens = {
				color = {
					Accent = { title = "Accent", desc = "M\u{e0}u accent ch\u{ed}nh." },
					AccentForeground = {
						title = "Accent Foreground",
						desc = "M\u{e0}u ch\u{1eef}/icon tr\u{ea}n n\u{1ec1}n accent.",
					},
					AccentDark = {
						title = "Accent Dark",
						desc = "Accent ph\u{1ee5} d\u{f9}ng \u{111}\u{1ec3} t\u{1ea1}o gradient.",
					},
					LogoColorBase = {
						title = "M\u{e0}u Logo g\u{1ed1}c",
						desc = "M\u{e0}u logo khi t\u{1eaf}t \u{111}\u{1ed3}ng b\u{1ed9} accent.",
					},
					BackgroundMain = {
						title = "Background ch\u{ed}nh",
						desc = "N\u{1ec1}n c\u{1eed}a s\u{1ed5} g\u{1ed1}c.",
					},
					BackgroundSurface = { title = "Background Surface", desc = "N\u{1ec1}n card, sidebar, tab." },
					BackgroundElevated = {
						title = "Background Elevated",
						desc = "N\u{1ec1}n c\u{e1}c b\u{1ec1} m\u{1eb7}t n\u{1ed5}i.",
					},
					Text = { title = "Ch\u{1eef}", desc = "Ch\u{1eef} ch\u{ed}nh." },
					SubText = { title = "Ch\u{1eef} ph\u{1ee5}", desc = "Ch\u{1eef} m\u{1edd}." },
					TextPlaceholder = { title = "Ch\u{1eef} Placeholder", desc = "M\u{e0}u placeholder." },
					StrokeColor = { title = "M\u{e0}u vi\u{1ec1}n", desc = "M\u{e0}u vi\u{1ec1}n t\u{1ed5}ng th\u{1ec3}." },
					DividerColor = {
						title = "M\u{e0}u Divider",
						desc = "M\u{e0}u \u{111}\u{1b0}\u{1edd}ng ph\u{e2}n chia element.",
					},
					Hover = { title = "Hover", desc = "M\u{e0}u overlay khi hover." },
					InputBg = { title = "Background Input", desc = "N\u{1ec1}n \u{f4} nh\u{1ead}p." },
					InputText = { title = "Ch\u{1eef} Input", desc = "Ch\u{1eef} trong \u{f4} nh\u{1ead}p." },
					SliderRail = { title = "Slider Rail", desc = "N\u{1ec1}n track c\u{1ee7}a slider." },
					SliderFill = { title = "Slider Fill", desc = "Ph\u{1ea7}n \u{111}\u{e3} ch\u{1ecd}n c\u{1ee7}a slider." },
					DropdownBg = { title = "Background Dropdown", desc = "N\u{1ec1}n n\u{fa}t trigger c\u{1ee7}a select." },
					DropdownText = { title = "Ch\u{1eef} Dropdown", desc = "Ch\u{1eef} gi\u{e1} tr\u{1ecb} select." },
					SelectPopupBg = {
						title = "Background Popup Select",
						desc = "N\u{1ec1}n popup n\u{1ed5}i c\u{1ee7}a select.",
					},
					TabBar = { title = "Tab Bar", desc = "N\u{1ec1}n thanh tab tr\u{ea}n c\u{f9}ng." },
					TabActive = {
						title = "Tab \u{111}ang ch\u{1ecd}n",
						desc = "Ch\u{1eef}/indicator c\u{1ee7}a tab \u{111}ang ch\u{1ecd}n.",
					},
					TabInactive = {
						title = "Tab kh\u{f4}ng ch\u{1ecd}n",
						desc = "Ch\u{1eef} tab kh\u{f4}ng \u{111}\u{1b0}\u{1ee3}c ch\u{1ecd}n.",
					},
					SidebarBg = { title = "Background Sidebar", desc = "N\u{1ec1}n panel sidebar." },
					SidebarIcon = { title = "Icon Sidebar", desc = "Icon sidebar kh\u{f4}ng ho\u{1ea1}t \u{111}\u{1ed9}ng." },
					SidebarIconActive = {
						title = "Icon Sidebar \u{111}ang ch\u{1ecd}n",
						desc = "Icon sidebar \u{111}ang ch\u{1ecd}n.",
					},
					SidebarActiveIndicator = {
						title = "Indicator Sidebar",
						desc = "Thanh indicator \u{111}ang ch\u{1ecd}n c\u{1ee7}a sidebar.",
					},
					DialogSurface = { title = "B\u{1ec1} m\u{1eb7}t Dialog", desc = "N\u{1ec1}n card dialog." },
					DialogBorder = { title = "Vi\u{1ec1}n Dialog", desc = "M\u{e0}u vi\u{1ec1}n dialog." },
					DialogHeaderText = {
						title = "Ch\u{1eef} Header Dialog",
						desc = "M\u{e0}u ti\u{ea}u \u{111}\u{1ec1} dialog.",
					},
					DialogCloseIcon = {
						title = "Icon \u{110}\u{f3}ng Dialog",
						desc = "M\u{e0}u icon \u{111}\u{f3}ng dialog.",
					},
				},
				numeric = {
					AccentGradientRotation = {
						title = "G\u{f3}c Gradient Accent",
						desc = "Xoay h\u{1b0}\u{1edb}ng gradient accent.",
					},
					BackgroundMainTransparency = {
						title = "\u{110}\u{1ed9} trong Background",
						desc = "\u{110}\u{1ed9} trong n\u{1ec1}n c\u{1eed}a s\u{1ed5}.",
					},
					StrokeTransparency = {
						title = "\u{110}\u{1ed9} trong vi\u{1ec1}n",
						desc = "\u{110}\u{1ed9} hi\u{1ec7}n vi\u{1ec1}n t\u{1ed5}ng th\u{1ec3}.",
					},
					HoverTransparency = {
						title = "\u{110}\u{1ed9} trong Hover",
						desc = "\u{110}\u{1ed9} trong overlay hover.",
					},
					ScrollBarThickness = {
						title = "\u{110}\u{1ed9} d\u{e0}y Scrollbar",
						desc = "\u{110}\u{1ed9} r\u{1ed9}ng scrollbar (pixel).",
					},
					TextSizeBody = { title = "C\u{1ee1} ch\u{1eef} Body", desc = "C\u{1ee1} ch\u{1eef} ch\u{ed}nh." },
					TextSizeSmall = { title = "C\u{1ee1} ch\u{1eef} Nh\u{1ecf}", desc = "C\u{1ee1} ch\u{1eef} ph\u{1ee5}." },
					TextSizeTab = { title = "C\u{1ee1} ch\u{1eef} Tab", desc = "C\u{1ee1} ch\u{1eef} nh\u{e3}n tab." },
					CornerRadiusWindow = {
						title = "Bo g\u{f3}c c\u{1eed}a s\u{1ed5}",
						desc = "Bo g\u{f3}c cho c\u{1eed}a s\u{1ed5} ch\u{ed}nh v\u{e0} dialog.",
					},
					CornerRadiusSubTabs = { title = "Bo g\u{f3}c Sub-Tabs", desc = "Bo g\u{f3}c cho sub-tabs." },
					CornerRadiusSidebar = { title = "Bo g\u{f3}c Sidebar", desc = "Bo g\u{f3}c cho panel sidebar." },
					CornerRadiusTab = { title = "Bo g\u{f3}c Tab", desc = "Bo g\u{f3}c cho t\u{1eeb}ng n\u{fa}t tab." },
					CornerRadiusSection = {
						title = "Bo g\u{f3}c Section",
						desc = "Bo g\u{f3}c cho khung section b\u{ea}n trong.",
					},
					PaddingWindow = {
						title = "Padding c\u{1eed}a s\u{1ed5}",
						desc = "Padding b\u{ea}n trong c\u{1eed}a s\u{1ed5} ch\u{ed}nh.",
					},
					PaddingElement = {
						title = "Padding Element",
						desc = "Padding n\u{1ed9}i b\u{1ed9} cho h\u{e0}ng element.",
					},
					PaddingInput = { title = "Padding Input", desc = "Padding ngang cho \u{f4} nh\u{1ead}p text." },
				},
			},
		},
		server = {
			actions = {
				section = { title = "H\u{e0}nh \u{111}\u{1ed9}ng Server" },
				rejoinSameServer = {
					title = "V\u{e0}o l\u{1ea1}i Server hi\u{1ec7}n t\u{1ea1}i",
					desc = "K\u{1ebf}t n\u{1ed1}i l\u{1ea1}i v\u{e0}o instance server \u{111}ang ch\u{1a1}i.",
				},
				manualServerHop = {
					title = "Server Hop th\u{1ee7} c\u{f4}ng",
					desc = "T\u{ec}m v\u{e0} join server c\u{f4}ng khai kh\u{e1}c theo y\u{ea}u c\u{1ea7}u.",
				},
				joinLowPlayerServer = {
					title = "V\u{e0}o Server \u{ed}t ng\u{1b0}\u{1edd}i",
					desc = "T\u{ec}m server c\u{f4}ng khai c\u{f3} \u{ed}t ng\u{1b0}\u{1edd}i ch\u{1a1}i h\u{1a1}n.",
				},
			},
			lowPlayerHop = {
				section = { title = "Hop khi \u{ed}t ng\u{1b0}\u{1edd}i" },
				toggle = {
					title = "T\u{1ef1} hop khi server \u{ed}t ng\u{1b0}\u{1edd}i",
					desc = "T\u{1ef1} \u{111}\u{1ed9}ng hop khi s\u{1ed1} ng\u{1b0}\u{1edd}i trong server hi\u{1ec7}n t\u{1ea1}i d\u{1b0}\u{1edb}i ng\u{1b0}\u{1ee1}ng.",
				},
				minimumPlayers = {
					title = "S\u{1ed1} ng\u{1b0}\u{1edd}i t\u{1ed1}i thi\u{1ec3}u",
					desc = "Ng\u{1b0}\u{1ee1}ng s\u{1ed1} ng\u{1b0}\u{1edd}i d\u{f9}ng cho t\u{1ef1} \u{111}\u{1ed9}ng low-player server hop.",
				},
			},
			scheduledRejoin = {
				section = { title = "H\u{1eb9}n v\u{e0}o l\u{1ea1}i" },
				minutesInput = {
					title = "S\u{1ed1} ph\u{fa}t tr\u{1b0}\u{1edb}c khi v\u{e0}o l\u{1ea1}i",
					desc = "Kho\u{1ea3}ng ch\u{1edd} tr\u{1b0}\u{1edb}c khi h\u{e0}nh \u{111}\u{1ed9}ng v\u{e0}o l\u{1ea1}i theo th\u{1edd}i gian \u{111}\u{1b0}\u{1ee3}c ch\u{1ea1}y.",
				},
				toggle = {
					title = "V\u{e0}o l\u{1ea1}i sau X ph\u{fa}t",
					desc = "B\u{1ead}t h\u{1eb9}n v\u{e0}o l\u{1ea1}i v\u{1edb}i s\u{1ed1} ph\u{fa}t b\u{ea}n tr\u{ea}n.",
				},
			},
			jobJoin = {
				section = { title = "V\u{e0}o theo Job" },
				jobIdInput = {
					title = "Job ID",
					desc = "Roblox JobId \u{111}\u{ed}ch cho h\u{e0}nh \u{111}\u{1ed9}ng join tr\u{1ef1}c ti\u{1ebf}p.",
					placeholder = "D\u{e1}n Job ID v\u{e0}o \u{111}\u{e2}y",
				},
				joinButton = {
					title = "V\u{e0}o theo Job ID",
					desc = "V\u{e0}o server theo Job ID \u{111}\u{e3} nh\u{1ead}p.",
				},
				copyButton = {
					title = "Copy Job ID hi\u{1ec7}n t\u{1ea1}i",
					desc = "Copy JobId c\u{1ee7}a server hi\u{1ec7}n t\u{1ea1}i.",
				},
			},
		},
	},
	overlay = { toggle = { tooltip = "Hi\u{1ec7}n ho\u{1eb7}c \u{1ea9}n Kyotaki Hub" } },
	sidebar = { expand = { tooltip = "M\u{1edf} r\u{1ed9}ng sidebar" }, collapse = { tooltip = "Thu g\u{1ecd}n sidebar" } },
	errors = {
		window = {
			saveSnapshotUnavailable = "kh\u{f4}ng th\u{1ec3} l\u{1b0}u snapshot",
			loadSnapshotUnavailable = "kh\u{f4}ng th\u{1ec3} t\u{1ea3}i snapshot",
			patchThemeTokensUnavailable = "kh\u{f4}ng th\u{1ec3} patch theme tokens",
			saveThemeFileUnavailable = "kh\u{f4}ng th\u{1ec3} l\u{1b0}u file theme",
			loadThemeFileUnavailable = "kh\u{f4}ng th\u{1ec3} t\u{1ea3}i file theme",
		},
		server = {
			localPlayerUnavailable = "LocalPlayer kh\u{f4}ng kh\u{1ea3} d\u{1ee5}ng.",
			noServerListAvailable = "Kh\u{f4}ng c\u{f3} danh s\u{e1}ch server.",
			noMatchingPublicServer = "Kh\u{f4}ng t\u{ec}m th\u{1ea5}y server c\u{f4}ng khai ph\u{f9} h\u{1ee3}p.",
			jobIdEmpty = "Job ID \u{111}ang tr\u{1ed1}ng.",
			clipboardUnavailable = "Clipboard API kh\u{f4}ng kh\u{1ea3} d\u{1ee5}ng.",
		},
	},
	formatDate = function(e)
		if not e or type(e.timestamp) ~= "number" then
			return ""
		end
		local f, g = pcall(function()
			return os.date("%H:%M %d/%m/%Y", e.timestamp)
		end)
		return (f and type(g) == "string" and { g } or { (tostring(e.timestamp)) })[1]
	end,
}
return e
end
a["Localization/Localization"]=function()
local e, f, g, h, i, j = d("Localization/LocaleConfig"), d("Localization/LocaleStore"), d("Localization/Locale_en"), d("Localization/Locale_vi"), d("Core/Logger"), {}
local k, l, m, n, o, p, q =
	{ en = g, vi = h }, e.DEFAULT_LOCALE, {}, {}, function(k)
		if type(k) ~= "string" then
			return false
		end
		for l, m in e.SUPPORTED_LOCALES do
			if m == k then
				return true
			end
		end
		return false
	end, function(k, l)
		if type(k) ~= "table" then
			return nil
		end
		local m = k
		for n in string.gmatch(l, "[^%.]+") do
			if type(m) ~= "table" then
				return nil
			end
			m = m[n]
			if m == nil then
				return nil
			end
		end
		return m
	end, function(k, l)
		if l == nil then
			return k
		end
		return (string.gsub(k, "{([%w_]+)}", function(m)
			local n = l[m]
			return (n == nil and { nil } or { (tostring(n)) })[1]
		end))
	end
function j.t(r, s)
	if type(r) ~= "string" or r == "" then
		return tostring(r)
	end
	local t = p(k[l], r)
	if t == nil and l ~= e.DEFAULT_LOCALE then
		t = p(k[e.DEFAULT_LOCALE], r)
	end
	if type(t) == "string" then
		return q(t, s)
	end
	if type(t) == "function" then
		local u, v = pcall(t, s)
		if u and type(v) == "string" then
			return v
		end
	end
	if not n[r] then
		n[r] = true
		i.Warn(("[SeaHub:Localization] missing translation key: %q"):format(r))
	end
	return r
end
function j.tFor(r, s, t)
	if type(s) ~= "string" or s == "" then
		return tostring(s)
	end
	local u = k[r]
	local v = (u ~= nil and { (p(u, s)) } or { nil })[1]
	if v == nil and r ~= e.DEFAULT_LOCALE then
		v = p(k[e.DEFAULT_LOCALE], s)
	end
	if type(v) == "string" then
		return q(v, t)
	end
	if type(v) == "function" then
		local w, x = pcall(v, t)
		if w and type(x) == "string" then
			return x
		end
	end
	return s
end
function j.SupportedLocales()
	return table.clone(e.SUPPORTED_LOCALES)
end
function j.ResolveTagFor(r, s)
	if not j.IsTagged(s) then
		return nil
	end
	return j.tFor(r, s.Key, s.Params)
end
function j.Get()
	return l
end
function j.GetSupported()
	return table.clone(e.SUPPORTED_LOCALES)
end
function j.Has(r)
	if type(r) ~= "string" or r == "" then
		return false
	end
	return p(k[l], r) ~= nil
end
local r = function()
	local r = {}
	for s, t in m do
		table.insert(r, t)
	end
	for s, t in r do
		local u, v = pcall(t, l)
		if not u then
			i.Warn("[SeaHub:Localization] subscriber error:", v)
		end
	end
end
function j.Set(s)
	if not o(s) then
		return false
	end
	if s == l then
		return true
	end
	l = s
	n = {}
	f.Write(s)
	r()
	return true
end
function j.Initialize()
	local s = f.Read()
	if s and o(s) then
		l = s
	end
end
local function s(t, u)
	for v, w in u do
		if type(w) == "table" and type(t[v]) == "table" then
			s(t[v], w)
		else
			t[v] = w
		end
	end
end
function j.Add(t, u)
	if not o(t) or type(u) ~= "table" then
		return false
	end
	local v = k[t]
	if not v then
		v = {}
		k[t] = v
	end
	s(v, u)
	n = {}
	if t == l then
		r()
	end
	return true
end
function j.OnChanged(t)
	if type(t) ~= "function" then
		return function() end
	end
	local u = {}
	m[u] = t
	return function()
		m[u] = nil
	end
end
local t = newproxy(false)
function j.tag(u, v)
	return { [t] = true, Key = (type(u) == "string" and { u } or { (tostring(u)) })[1], Params = v }
end
function j.IsTagged(u)
	return type(u) == "table" and u[t] == true
end
function j.ResolveTag(u)
	if not j.IsTagged(u) then
		return nil
	end
	return j.t(u.Key, u.Params)
end
function j.Attach(u, v, w)
	if not j.IsTagged(w) then
		return function() end
	end
	local x = u["Set" .. v]
	if type(x) ~= "function" then
		return function() end
	end
	local y = function()
		x(u, j.t(w.Key, w.Params))
	end
	y()
	return j.OnChanged(y)
end
function j.Bind(u, v, w)
	if type(v) ~= "table" then
		return function() end
	end
	local x = function()
		if v.Title and u.SetTitle then
			u:SetTitle(j.t(v.Title, w and w.Title))
		end
		if v.Desc ~= nil and u.SetDesc then
			u:SetDesc(j.t(v.Desc, w and w.Desc))
		end
		if v.Placeholder and u.SetPlaceholder then
			u:SetPlaceholder(j.t(v.Placeholder, w and w.Placeholder))
		end
	end
	x()
	return j.OnChanged(x)
end
return table.freeze(j)
end
a["Persist/AccountNameCache"]=function()
local aa, ab = game:GetService("Players"), {}
local ac, ad = {}, function(ac)
	return "User " .. ac
end
local ae = function(ae)
	local af = ac[ae]
	if not af then
		af = { Name = ad(ae), Pending = false }
		ac[ae] = af
	end
	return af
end
function ab.Get(af)
	if type(af) ~= "string" or af == "" then
		return ""
	end
	return ae(af).Name
end
function ab.Prime(af, ag)
	if type(af) ~= "string" or af == "" then
		return
	end
	local ah = ae(af)
	if ah.Pending or ah.Name ~= ad(af) then
		if ag and ah.Name ~= ad(af) then
			ag(ah.Name)
		end
		return
	end
	local ai = tonumber(af)
	if not ai then
		return
	end
	ah.Pending = true
	task.spawn(function()
		local aj, ak = pcall(function()
			return aa:GetNameFromUserIdAsync(ai)
		end)
		ah.Pending = false
		if aj and type(ak) == "string" and ak ~= "" then
			ah.Name = ak
			if ag then
				ag(ak)
			end
		end
	end)
end
return table.freeze(ab)
end
a["Persist/AccountScopes"]=function()
local aa, ab, ac, ad, ae, af = game:GetService("Players"), game:GetService("HttpService"), d("Core/FileSystem"), d("Core/Logger"), {}, "sea"
local ag = af .. "/snapshots"
local ah = ag .. "/accounts"
local ai, aj, ak, al, am, an, ao =
	ah .. "/_pending", ag .. "/sync.json", 1, false, function(ai)
		return type(ai) == "string" and ai:match("^%d+$") ~= nil and ai ~= "0"
	end
ae.IsValidUserId = am
local ap, aq, ar =
	function()
		if not ac.IsAvailable() then
			return al, "unavailable"
		end
		if not ac.IsFile(aj) then
			return al, "missing"
		end
		local ap = ac.ReadFile(aj)
		if type(ap) ~= "string" or ap == "" then
			return al, "corrupt"
		end
		local aq, ar = pcall(function()
			return ab:JSONDecode(ap)
		end)
		if not aq or type(ar) ~= "table" then
			return al, "corrupt"
		end
		return ar.SyncAccounts == true, "valid"
	end, function()
		return ac.EnsurePath(af) and ac.EnsurePath(ag)
	end, function()
		local ap = aa.LocalPlayer
		if ap and ap.UserId and ap.UserId ~= 0 then
			local aq = tostring(ap.UserId)
			if am(aq) then
				return aq
			end
		end
		return nil
	end
local as = function()
	if ao then
		return ao
	end
	local as = ar()
	if as then
		ao = as
	end
	return as
end
function ae.InvalidateScope()
	an = nil
	ao = nil
end
function ae.IsSynced()
	if an ~= nil then
		return an
	end
	local at, e = ap()
	if e == "valid" or e == "missing" then
		an = at
		return at
	end
	if e == "corrupt" then
		ad.Warn([[[SeaHub:SnapshotScope] sync.json is unreadable/corrupt; retaining last-known scope.]])
		if an ~= nil then
			return an
		end
	end
	return at
end
function ae.SetSynced(at)
	if not ac.IsAvailable() or not aq() then
		return false
	end
	local e, f = pcall(function()
		return ab:JSONEncode({ Version = ak, SyncAccounts = at == true })
	end)
	if not e then
		return false
	end
	if not ac.WriteFile(aj, f) then
		return false
	end
	an = at == true
	return true
end
function ae.GetFolder()
	if ae.IsSynced() then
		return ag
	end
	local at = as()
	if not at then
		return ai
	end
	return ah .. "/" .. at
end
function ae.GetSharedFolder()
	return ag
end
function ae.GetPendingFolder()
	return ai
end
function ae.GetAccountFolder(at)
	if not am(at) then
		error([[[SeaHub:SnapshotScope] GetAccountFolder requires a valid numeric UserId]], 2)
	end
	return ah .. "/" .. at
end
function ae.GetCurrentUserId()
	return as()
end
function ae.IsPending()
	return not ae.IsSynced() and as() == nil
end
function ae.ClaimPending()
	if not ac.IsAvailable() then
		return false
	end
	local at = as()
	if not at then
		return false
	end
	if not ac.IsFolder(ai) then
		return true
	end
	local e = ah .. "/" .. at
	if not (ac.EnsurePath(ah) and ac.EnsurePath(e)) then
		return false
	end
	local f = true
	for g, h in ac.ListFiles(ai) do
		local i = h:gsub("[/\\]+$", "")
		local j = i:match("([^/\\]+)$")
		local k = ai .. "/" .. (j or "")
		if j and j ~= "" and ac.IsFile(k) then
			local l = e .. "/" .. j
			if ac.IsFile(l) then
				f = false
			else
				local m = ac.ReadFile(k)
				if m == nil then
					f = false
				else
					local n = ac.WriteFile(l, m)
					if n and ac.ReadFile(l) == m then
						ac.DeleteFile(k)
					else
						f = false
					end
				end
			end
		end
	end
	return f
end
function ae.ListAccountScopes()
	local at = {}
	if not ac.IsAvailable() then
		return at
	end
	if not ac.IsFolder(ah) then
		return at
	end
	local e = {}
	for f, g in ac.ListFiles(ah) do
		local h = g:gsub("[/\\]+$", "")
		local i = h:match("([^/\\]+)$")
		if i and i ~= "" and not e[i] then
			if am(i) and ac.IsFolder(ah .. "/" .. i) then
				e[i] = true
				table.insert(at, { UserId = i, Folder = ah .. "/" .. i })
			end
		end
	end
	table.sort(at, function(f, g)
		local h, i = tonumber(f.UserId), tonumber(g.UserId)
		if h and i then
			return h < i
		end
		return f.UserId < g.UserId
	end)
	return at
end
function ae.EnsureFolder()
	if not ac.IsAvailable() then
		return false
	end
	if not aq() then
		return false
	end
	local at = ae.GetFolder()
	if at == ag then
		return true
	end
	return ac.EnsurePath(ah) and ac.EnsurePath(at)
end
return table.freeze(ae)
end
a["Persist/DirtyTracker"]=function()
local aa, ab, ac, ad = {}, {}, 0, function(aa, ab)
	return tostring(aa) .. "\0" .. tostring(ab)
end
function aa.Mark(ae, af)
	if ac > 0 then
		return
	end
	ab[ad(ae, af)] = true
end
function aa.Clear(ae, af)
	ab[ad(ae, af)] = nil
end
function aa.IsDirty(ae, af)
	return ab[ad(ae, af)] == true
end
function aa.BeginApply()
	ac = ac + 1
end
function aa.EndApply()
	ac = math.max(0, ac - 1)
end
function aa.IsApplying()
	return ac > 0
end
function aa.Count()
	local ae = 0
	for af in ab do
		ae = ae + 1
	end
	return ae
end
function aa.Reset()
	table.clear(ab)
	ac = 0
end
return aa
end
a["Persist/SnapshotSettings"]=function()
local aa, ab, ac, ad, ae, af = game:GetService("HttpService"), d("Core/FileSystem"), d("Persist/ValueCodec"), d("Persist/AccountScopes"), {}, "sea"
local ag, ah, ai =
	function()
		return ad.GetFolder() .. "/settings.json"
	end, { Version = 1, AutoSave = { Enabled = false, Interval = "60s" } }, { continuous = true, ["15s"] = true, ["30s"] = true, ["60s"] = true, ["5m"] = true }
local function aj(ak)
	local al = {}
	for am, an in ak do
		al[am] = (type(an) == "table" and { (aj(an)) } or { an })[1]
	end
	return al
end
local ak, al =
	function(ak)
		local al = aj(ah)
		if type(ak) ~= "table" then
			return al
		end
		local am = ak.AutoSave
		if type(am) == "table" then
			al.AutoSave.Enabled = am.Enabled == true
			if type(am.Interval) == "string" and ai[am.Interval] then
				al.AutoSave.Interval = am.Interval
			end
		end
		return al
	end, function()
		return ab.EnsurePath(af) and ad.EnsureFolder()
	end
function ae.Get()
	local am = ag()
	if not ab.IsAvailable() or not ab.IsFile(am) then
		return aj(ah)
	end
	local an = ab.ReadFile(am)
	if an == nil then
		return aj(ah)
	end
	local ao, ap = pcall(function()
		return aa:JSONDecode(an)
	end)
	if not ao then
		return aj(ah)
	end
	local aq, ar = pcall(function()
		return ac.Decode(ap)
	end)
	return ak((aq and { ar } or { nil })[1])
end
function ae.Set(am)
	if not ab.IsAvailable() or not al() then
		return false
	end
	local an, ao = pcall(ac.Encode, ak(am))
	if not an then
		return false
	end
	local ap, aq = pcall(function()
		return aa:JSONEncode(ao)
	end)
	if not ap then
		return false
	end
	return ab.WriteFile(ag(), aq)
end
function ae.GetIntervalSeconds(am)
	if am == "continuous" then
		return 5
	elseif am == "15s" then
		return 15
	elseif am == "30s" then
		return 30
	elseif am == "5m" then
		return 300
	end
	return 60
end
return table.freeze(ae)
end
a["Persist/SnapshotStorage"]=function()
local aa, ab, ac, ad, ae, af = game:GetService("HttpService"), d("Core/FileSystem"), d("Persist/ValueCodec"), d("Persist/AccountScopes"), {}, "sea"
local ag, ah =
	af .. "/themes", function(ag)
		local ah = ag:gsub("^%s*(.-)%s*$", "%1")
		if ah == "" then
			return "Theme"
		end
		local ai = ah:gsub('[%c\\/:*?"<>|]', "_")
		if ai == "" then
			return "Theme"
		end
		return ai
	end
local ai, aj = function(ai)
	return ("%s/%s.json"):format(ag, ah(ai))
end, function()
	return ad.GetFolder()
end
local ak, al, am, an, ao, ap =
	function(ak)
		return ("%s/%s.json"):format(aj(), ah(ak))
	end, function()
		return aj() .. "/defaults.json"
	end, function()
		return aj() .. "/index.json"
	end, function(ak)
		local al = ah(ak)
		return al == "defaults" or al == "settings" or al == "sync" or al == "index"
	end, function(ak, al)
		local am, an, ao = ac.TryEncode(al)
		if not am then
			return false, ao or "failed to encode value"
		end
		local ap, aq = pcall(function()
			return aa:JSONEncode(an)
		end)
		if not ap then
			return false, "failed to encode json"
		end
		if ab.WriteFile(ak, aq) then
			return true, nil
		end
		return false, "failed to write file"
	end, function(ak)
		local al = ab.ReadFile(ak)
		if al == nil then
			return false, "file not found"
		end
		local am, an = pcall(function()
			return aa:JSONDecode(al)
		end)
		if not am or type(an) ~= "table" then
			return false, "failed to decode json"
		end
		local ao, ap = pcall(function()
			return ac.Decode(an)
		end)
		return ao and true or false, ap
	end
function ae.EnsureFolders()
	return ab.EnsurePath(af) and ab.EnsurePath(ag) and ad.EnsureFolder()
end
function ae.IsAvailable()
	return ab.IsAvailable()
end
function ae._TouchSnapshotIndex(aq, ar)
	if not ab.IsAvailable() then
		return
	end
	local as, at, e = {}, ap(am())
	if at and type(e) == "table" and type(e.ByName) == "table" then
		as = e.ByName
	end
	as[ah(aq)] = ar
	ao(am(), { Version = 1, ByName = as })
end
function ae.SaveTheme(aq, ar)
	if type(aq) ~= "string" or aq == "" then
		return false, "invalid theme name"
	end
	if type(ar) ~= "table" then
		return false, "invalid theme data"
	end
	if not ab.IsAvailable() then
		return false, "filesystem unavailable"
	end
	if not ae.EnsureFolders() then
		return false, "failed to create themes folder"
	end
	local as = ai(aq)
	local at, e = ao(as, ar)
	return at and true or false, (at and { as } or { e })[1]
end
function ae.GetThemePath(aq)
	return ai(aq)
end
function ae.LoadTheme(aq)
	if type(aq) ~= "string" or aq == "" then
		return false, "invalid theme name"
	end
	if not ab.IsAvailable() then
		return false, "filesystem unavailable"
	end
	local ar, as = ap(ai(aq))
	if not ar then
		return false, as == "file not found" and "theme file not found" or tostring(as)
	end
	if type(as) ~= "table" then
		return false, "invalid decoded theme data"
	end
	return true, as
end
function ae.ListThemeFiles()
	if not ab.IsAvailable() or not ab.IsFolder(ag) then
		return {}
	end
	local aq, ar = ab.ListFiles(ag), {}
	for as, at in aq do
		local e = at:match("([^/\\]+)$")
		if e then
			local f = e:match("^(.*)%.json$")
			if f and f ~= "" then
				table.insert(ar, f)
			end
		end
	end
	table.sort(ar)
	return ar
end
function ae.SaveSnapshot(aq, ar)
	if type(aq) ~= "string" or aq == "" then
		return false, "invalid snapshot name"
	end
	if an(aq) then
		return false, "reserved snapshot name"
	end
	if type(ar) ~= "table" then
		return false, "invalid snapshot data"
	end
	if not ab.IsAvailable() then
		return false, "filesystem unavailable"
	end
	if not ae.EnsureFolders() then
		return false, "failed to create snapshots folder"
	end
	local as, at = ae.LoadSnapshot(aq)
	ar.Name = aq
	ar.CreatedAt = (as and type(at) == "table" and type(at.CreatedAt) == "number" and { at.CreatedAt } or {
		ar.CreatedAt or os.time(),
	})[1]
	ar.UpdatedAt = os.time()
	local e, f = ao(ak(aq), ar)
	if e then
		ae._TouchSnapshotIndex(aq, ar.UpdatedAt)
	end
	return e and true or false, (e and { (ak(aq)) } or { f })[1]
end
function ae.LoadSnapshot(aq)
	if type(aq) ~= "string" or aq == "" then
		return false, "invalid snapshot name"
	end
	if not ab.IsAvailable() then
		return false, "filesystem unavailable"
	end
	local ar, as = ap(ak(aq))
	if not ar then
		return false, as == "file not found" and "snapshot file not found" or tostring(as)
	end
	if type(as) ~= "table" then
		return false, "invalid decoded snapshot data"
	end
	return true, as
end
function ae.ListSnapshotFiles()
	local aq = aj()
	if not ab.IsAvailable() or not ab.IsFolder(aq) then
		return {}
	end
	local ar = {}
	for as, at in ab.ListFiles(aq) do
		local e = at:match("([^/\\]+)$")
		local f = e and e:match("^(.*)%.json$")
		if f and f ~= "" and not an(f) then
			table.insert(ar, f)
		end
	end
	table.sort(ar)
	return ar
end
function ae.ListSnapshotMeta()
	local aq, ar, as, at, e = ae.ListSnapshotFiles(), {}, {}, ap(am())
	if at and type(e) == "table" and type(e.ByName) == "table" then
		as = e.ByName
	end
	local f, g = false, {}
	for h, i in aq do
		local j = as[i]
		if type(j) == "number" then
			g[i] = j
			table.insert(ar, { Name = i, UpdatedAt = j, Invalid = false })
		else
			local k, l = ae.LoadSnapshot(i)
			local m = k and type(l) == "table"
			local n = (m and { (l).UpdatedAt } or { nil })[1]
			table.insert(ar, { Name = i, UpdatedAt = n, Invalid = not m })
			if m and type(n) == "number" then
				g[i] = n
				f = true
			end
		end
	end
	if not f then
		for h in as do
			if g[h] == nil then
				f = true
				break
			end
		end
	end
	if f and ab.IsAvailable() then
		ao(am(), { Version = 1, ByName = g })
	end
	return ar
end
local aq, ar =
	function()
		local aq, ar = { Version = 1, ByTheme = {} }, al()
		if not ab.IsAvailable() or not ab.IsFile(ar) then
			return aq
		end
		local as, at = ap(ar)
		if as and type(at) == "table" and type(at.ByTheme) == "table" then
			aq.ByTheme = at.ByTheme
		end
		return aq
	end, function(aq)
		if not ae.EnsureFolders() then
			return false
		end
		local ar = ao(al(), aq)
		return ar == true
	end
function ae.GetDefaultSnapshot(as)
	if type(as) ~= "string" or as == "" then
		return nil
	end
	return aq().ByTheme[as]
end
function ae.SetDefaultSnapshot(as, at)
	if type(as) ~= "string" or as == "" then
		return false
	end
	local e = aq()
	if type(at) == "string" and at ~= "" then
		if not ab.IsFile(ak(at)) then
			return false
		end
		e.ByTheme[as] = at
	else
		e.ByTheme[as] = nil
	end
	return ar(e)
end
function ae.DeleteSnapshot(as)
	local at = ab.DeleteFile(ak(as))
	if not at then
		return false
	end
	local e = aq()
	for f, g in e.ByTheme do
		if g == as then
			e.ByTheme[f] = nil
		end
	end
	ar(e)
	return true
end
function ae.MakeUniqueSnapshotName(as)
	local at = ah(as)
	local e, f = at, 1
	while ab.IsFile(ak(e)) do
		e = ("%s %d"):format(at, f)
		f = f + 1
	end
	return e
end
function ae.DuplicateSnapshot(as, at)
	local e, f = ae.LoadSnapshot(as)
	if not e or type(f) ~= "table" then
		return nil, (type(f) == "string" and { f } or { "source snapshot unavailable" })[1]
	end
	local g = (type(at) == "string" and at ~= "" and { at } or { (as .. " Copy") })[1]
	local h = ae.MakeUniqueSnapshotName(g)
	local i, j = ae.SaveSnapshot(h, f)
	if i then
		return h, nil
	end
	return nil, j or "failed to write duplicate"
end
local as = function(as, at)
	return ("%s/%s.json"):format(as, ah(at))
end
function ae.ListSnapshotsInScope(at)
	local e = {}
	if not ad.IsValidUserId(at) then
		return e
	end
	local f = ad.GetAccountFolder(at)
	if not ab.IsAvailable() or not ab.IsFolder(f) then
		return e
	end
	for g, h in ab.ListFiles(f) do
		local i = h:match("([^/\\]+)$")
		local j = i and i:match("^(.*)%.json$")
		if j and j ~= "" and not an(j) then
			local k = as(f, j)
			local l, m = ap(k)
			table.insert(
				e,
				{
					Name = j,
					UpdatedAt = (l and type(m) == "table" and type(m.UpdatedAt) == "number" and { m.UpdatedAt } or {
						nil,
					})[1],
					Invalid = not l or type(m) ~= "table",
				}
			)
		end
	end
	table.sort(e, function(g, h)
		return g.Name < h.Name
	end)
	return e
end
function ae.BorrowSnapshot(at, e, f)
	if not ad.IsValidUserId(at) then
		return nil, "invalid source account"
	end
	if type(e) ~= "string" or e == "" then
		return nil, "invalid snapshot name"
	end
	if an(e) then
		return nil, "reserved snapshot name"
	end
	if not ab.IsAvailable() then
		return nil, "filesystem unavailable"
	end
	local g = ad.GetAccountFolder(at)
	if not ab.IsFolder(g) then
		return nil, "source account has no snapshots"
	end
	local h, i = ap(as(g, e))
	if not h or type(i) ~= "table" then
		return nil, (type(i) == "string" and { i } or { "source snapshot invalid" })[1]
	end
	local j = (type(f) == "string" and f ~= "" and { f } or { e })[1]
	local k = ae.MakeUniqueSnapshotName(j)
	local l, m = ae.SaveSnapshot(k, i)
	if l then
		return k, nil
	end
	return nil, m or "failed to write borrowed snapshot"
end
function ae.RenameSnapshot(at, e)
	local f, g = ae.LoadSnapshot(at)
	if not f or type(g) ~= "table" then
		return nil, (type(g) == "string" and { g } or { "snapshot unavailable" })[1]
	end
	local h = ae.MakeUniqueSnapshotName(e)
	local i, j = ae.SaveSnapshot(h, g)
	if not i then
		return nil, j or "failed to write renamed snapshot"
	end
	if not ab.DeleteFile(ak(at)) then
		return nil, "renamed copy written but old snapshot could not be removed"
	end
	local k = aq()
	for l, m in k.ByTheme do
		if m == at then
			k.ByTheme[l] = h
		end
	end
	ar(k)
	return h, nil
end
local at = function(at)
	if at then
		return ad.GetSharedFolder()
	end
	local e = ad.GetCurrentUserId()
	if not e then
		return nil
	end
	return ad.GetAccountFolder(e)
end
function ae.MigrateScope(e, f)
	if not ab.IsAvailable() then
		return false
	end
	local g, h = at(e), at(f)
	if not g or not h or g == h then
		return false
	end
	if not ab.IsFolder(g) then
		return true
	end
	if not ab.EnsurePath(h) then
		return false
	end
	local i = true
	for j, k in ab.ListFiles(g) do
		local l = k:match("([^/\\]+)$")
		if l and l:match("%.json$") then
			local m = ("%s/%s"):format(h, l)
			if ab.IsFile(m) then
				i = false
			else
				local n, o = ab.ReadFileStatus(("%s/%s"):format(g, l))
				if o == "ok" and type(n) == "string" then
					if not ab.WriteFile(m, n) then
						i = false
					end
				else
					i = false
				end
			end
		end
	end
	return i
end
return table.freeze(ae)
end
a["Persist/UiSettings"]=function()
local aa, ab, ac, ad, ae, af, ag, ah, ai, aj =
	d("Core/FileSystem"),
	{},
	"sea/ui-settings.json",
	1,
	{
		UseClassicToggle = true,
		DragFpsCap = 60,
		UseDragSkeleton = true,
		UseFullVisibilityAnimation = false,
		OverlayEnabled = true,
		FpsCap = 60,
		Render3dEnabled = true,
	},
	function()
		local aa, ab = pcall(function()
			return (game):GetService("HttpService")
		end)
		return (aa and { ab } or { nil })[1]
	end,
	function(aa)
		local ab = {}
		for ac, ad in aa do
			if type(ad) == "table" then
				local ae = {}
				for af, ag in ad do
					ae[af] = ag
				end
				ab[ac] = ae
			else
				ab[ac] = ad
			end
		end
		return ab
	end,
	function(aa)
		return type(aa) == "number" and aa == aa and aa >= 0 and aa < math.huge
	end,
	function(aa)
		if aa == nil or aa == "" then
			return nil
		end
		if type(aa) ~= "table" then
			return nil
		end
		if (aa.Type ~= "KeyCode" and aa.Type ~= "UserInputType") or type(aa.Name) ~= "string" or aa.Name == "" then
			return nil
		end
		return { Type = aa.Type, Name = aa.Name }
	end
local ak = function(ak)
	local al = ag(ae)
	if type(ak) ~= "table" then
		return al
	end
	for am, an in
		{ "UseClassicToggle", "UseDragSkeleton", "UseFullVisibilityAnimation", "OverlayEnabled", "Render3dEnabled" }
	do
		if type(ak[an]) == "boolean" then
			al[an] = ak[an]
		end
	end
	if ah(ak.DragFpsCap) then
		al.DragFpsCap = ak.DragFpsCap
	end
	if ah(ak.FpsCap) then
		al.FpsCap = ak.FpsCap
	end
	local am = ai(ak.ToggleUiKeybind)
	if ak.ToggleUiKeybind == nil or ak.ToggleUiKeybind == "" or am ~= nil then
		al.ToggleUiKeybind = am
	end
	if type(ak.Theme) == "string" and ak.Theme ~= "" then
		al.Theme = ak.Theme
	end
	return al
end
local al = function()
	if not aa.IsAvailable() or not aa.IsFile(ac) then
		return ag(ae)
	end
	local al = aa.ReadFile(ac)
	if type(al) ~= "string" or al == "" then
		return ag(ae)
	end
	local am = af()
	if not am then
		return ag(ae)
	end
	local an, ao = pcall(am.JSONDecode, am, al)
	if not an or type(ao) ~= "table" then
		return ag(ae)
	end
	return ak(ao.Settings or ao)
end
local am, an =
	function()
		if aj == nil then
			aj = al()
		end
	end, function(am)
		if not aa.IsAvailable() or not aa.EnsurePath("sea") then
			return false
		end
		local an = af()
		if not an then
			return false
		end
		local ao, ap = pcall(an.JSONEncode, an, { Version = ad, Settings = am })
		if not ao then
			return false
		end
		return aa.WriteFile(ac, ap)
	end
function ab.Load()
	aj = al()
	return ag(aj)
end
function ab.Get(ao)
	am()
	return (aj)[ao]
end
function ab.Set(ao, ap)
	am()
	local aq = ag(aj)
	if
		ao == "UseClassicToggle"
		or ao == "UseDragSkeleton"
		or ao == "UseFullVisibilityAnimation"
		or ao == "OverlayEnabled"
		or ao == "Render3dEnabled"
	then
		if type(ap) ~= "boolean" then
			return false
		end
	elseif ao == "DragFpsCap" or ao == "FpsCap" then
		if not ah(ap) then
			return false
		end
	elseif ao == "ToggleUiKeybind" then
		ap = ai(ap)
	elseif ao == "Theme" then
		if ap ~= nil and (type(ap) ~= "string" or ap == "") then
			return false
		end
	else
		return false
	end
	aq[ao] = ap
	if not an(aq) then
		return false
	end
	aj = aq
	return true
end
function ab.GetPath()
	return ac
end
return table.freeze(ab)
end
a["Persist/ValueCodec"]=function()
local aa, ab, ac, ad, ae =
	{}, 32, 16, { Color3 = true, ColorSequence = true, UDim = true, EnumItem = true }, function(aa)
		local ab = tostring(aa.EnumType)
		return ab:match("^Enum%.(.+)$") or ab
	end
local function af(ag, ah, ai)
	if ah > ab then
		error(("value encode: max depth %d exceeded"):format(ab), 0)
	end
	local aj = typeof(ag)
	if aj == "Color3" then
		return { __type = "Color3", R = ag.R, G = ag.G, B = ag.B }
	end
	if aj == "ColorSequence" then
		local ak = {}
		for al, am in ag.Keypoints do
			table.insert(ak, { Time = am.Time, Value = af(am.Value, ah + 1, ai) })
		end
		return { __type = "ColorSequence", Keypoints = ak }
	end
	if aj == "UDim" then
		return { __type = "UDim", Scale = ag.Scale, Offset = ag.Offset }
	end
	if aj == "EnumItem" then
		return { __type = "EnumItem", EnumType = ae(ag), Name = ag.Name }
	end
	if aj == "table" then
		if ai[ag] then
			error("value encode: cyclic table reference", 0)
		end
		ai[ag] = true
		local ak = {}
		for al, am in ag do
			ak[al] = af(am, ah + 1, ai)
		end
		ai[ag] = nil
		return ak
	end
	if aj == "number" then
		if ag ~= ag or ag == math.huge or ag == -math.huge then
			error("value encode: NaN/inf is not serialisable", 0)
		end
		return ag
	end
	if aj == "string" or aj == "boolean" or aj == "nil" then
		return ag
	end
	error(("value encode: unsupported value type `%s`"):format(aj), 0)
end
function aa.Encode(ag)
	return af(ag, 0, {})
end
function aa.TryEncode(ag)
	local ah, ai = pcall(af, ag, 0, {})
	if ah then
		return true, ai, nil
	end
	return false, nil, tostring(ai)
end
local ag = function(ag, ah)
	if type(ag) ~= "string" or type(ah) ~= "string" then
		return nil
	end
	local ai = ag:match("^Enum%.(.+)$") or ag
	local aj = (Enum)[ai]
	if aj == nil then
		return nil
	end
	local ak = aj[ah]
	return (typeof(ak) == "EnumItem" and { ak } or { nil })[1]
end
function aa.Decode(ah, ai)
	local aj = ai or 0
	if aj > ab then
		error(("value decode: max depth %d exceeded"):format(ab), 0)
	end
	if type(ah) ~= "table" then
		return ah
	end
	local ak = ah.__type
	if ak == "Color3" then
		if type(ah.R) == "number" and type(ah.G) == "number" and type(ah.B) == "number" then
			return Color3.new(ah.R, ah.G, ah.B)
		end
		return nil
	end
	if ak == "UDim" then
		if type(ah.Scale) == "number" and type(ah.Offset) == "number" then
			return UDim.new(ah.Scale, ah.Offset)
		end
		return nil
	end
	if ak == "EnumItem" then
		return ag(ah.EnumType, ah.Name)
	end
	if ak == "ColorSequence" then
		local al = ah.Keypoints
		if type(al) ~= "table" then
			return nil
		end
		if #al > ac then
			error(("value decode: ColorSequence keypoints exceed %d"):format(ac), 0)
		end
		local am = {}
		for an, ao in al do
			if type(ao) == "table" and type(ao.Time) == "number" then
				local ap = aa.Decode(ao.Value, aj + 1)
				if typeof(ap) == "Color3" then
					table.insert(am, ColorSequenceKeypoint.new(ao.Time, ap))
				end
			end
		end
		table.sort(am, function(an, ao)
			return an.Time < ao.Time
		end)
		return (#am > 0 and { (ColorSequence.new(am)) } or { nil })[1]
	end
	if type(ak) == "string" and not ad[ak] then
		return nil
	end
	local al = {}
	for am, an in ah do
		al[am] = aa.Decode(an, aj + 1)
	end
	return al
end
return table.freeze(aa)
end
a["Runtime/Bridge"]=function()
local aa = {}
local ab, ac, ad =
	function(ab)
		local ac, ad = pcall(function()
			local ac = (getfenv)(0).getgenv
			if type(ac) == "function" then
				return ac()[ab]
			end
			return nil
		end)
		if ac and ad ~= nil then
			return ad
		end
		local ae, af = pcall(function()
			return rawget(_G, ab)
		end)
		if ae and af ~= nil then
			return af
		end
		local ag, ah = pcall(function()
			return (getfenv)(0)[ab]
		end)
		return (ag and { ah } or { nil })[1]
	end, false
function aa.Get()
	if ac and ad ~= nil then
		return ad
	end
	local ae = ab("SEA_RUNTIME")
	if type(ae) ~= "table" then
		return nil
	end
	if type(ae.GetSnapshot) ~= "function" or type(ae.ReportState) ~= "function" then
		return nil
	end
	ad = ae
	ac = true
	return ad
end
function aa.IsAvailable()
	return aa.Get() ~= nil
end
function aa.GetSnapshot()
	local ae = aa.Get()
	if not ae then
		return nil
	end
	local af, ag = pcall(ae.GetSnapshot)
	if af and type(ag) == "table" then
		return ag
	end
	return nil
end
function aa.GetVersion()
	local ae = aa.Get()
	if not ae or type(ae.GetVersion) ~= "function" then
		return 0
	end
	local af, ag = pcall(ae.GetVersion)
	if af and type(ag) == "number" then
		return ag
	end
	return 0
end
function aa.ReportState(ae)
	local af = aa.Get()
	if not af then
		return false
	end
	local ag, ah = pcall(af.ReportState, ae)
	return ag and ah == true
end
function aa.ReportOptions(ae, af)
	local ag = aa.Get()
	if not ag or type(ag.ReportOptions) ~= "function" then
		return false
	end
	local ah, ai = pcall(ag.ReportOptions, ae, af)
	return ah and ai == true
end
function aa.PublishLocal(ae)
	local af = aa.Get()
	if not af or type(af.Local) ~= "table" then
		return false
	end
	for ag, ah in ae do
		local ai = pcall(function()
			af.Local[ag] = ah
		end)
		if not ai then
			return false
		end
	end
	return true
end
function aa.OnChanged(ae)
	local af = aa.Get()
	if not af or type(af.OnSnapshotChanged) ~= "table" then
		return nil
	end
	local ag, ah = pcall(function()
		return af.OnSnapshotChanged:Connect(ae)
	end)
	if not ag or type(ah) ~= "table" then
		return nil
	end
	return function()
		pcall(function()
			ah:Disconnect()
		end)
	end
end
return aa
end
a["Runtime/Sync"]=function()
local aa, ab, ac, ad, ae, af, ag =
	d("Runtime/Bridge"), d("Core/Logger"), {}, false, { Value = false }, function(aa)
		local ab = {}
		for ac, ad in aa do
			if type(ac) == "string" then
				ab[ac] = { Value = ad }
			end
		end
		return { Entries = ab }
	end, function(aa)
		local ab, ac = {}, aa.Entries
		if type(ac) ~= "table" then
			return ab
		end
		for ad, ae in ac do
			if type(ad) == "string" and type(ae) == "table" then
				ab[ad] = ae.Value
			end
		end
		return ab
	end
local ah = function(ah)
	local ai = ae
	aa.PublishLocal({
		GetState = function(aj)
			local ak, al, am = {}, pcall(function()
				return ah:ListSnapshots()
			end)
			if al and type(am) == "table" then
				for an, ao in am do
					if type(ao) == "table" and type(ao.Name) == "string" then
						table.insert(ak, { name = ao.Name, updatedAt = ao.UpdatedAt, invalid = ao.Invalid == true })
					end
				end
			end
			local an, ao, ap = nil, pcall(function()
				return ah:GetDefaultSnapshotName()
			end)
			if ao and type(ap) == "string" then
				an = ap
			end
			local aq = { active = an, persist = ai.Value == true, snapshots = ak }
			if aj == true then
				local ar, as = pcall(function()
					return ah:ExportSchema()
				end)
				if ar and type(as) == "table" then
					aq.schema = as
				end
			end
			return aq
		end,
		LoadSnapshot = function(aj)
			if type(aj) ~= "string" or aj == "" then
				return false
			end
			local ak = pcall(function()
				ah:LoadSnapshot(aj)
				ah:SetDefaultSnapshotName(nil, aj)
			end)
			return ak
		end,
		SaveSnapshot = function(aj)
			if type(aj) ~= "string" or aj == "" then
				return false
			end
			return (pcall(function()
				ah:SaveSnapshot(aj)
			end))
		end,
		SetPersist = function(aj)
			ai.Value = aj == true
			return true
		end,
		DeleteSnapshot = function(aj)
			if type(aj) ~= "string" or aj == "" then
				return false
			end
			return (pcall(function()
				ah:DeleteSnapshot(aj)
			end))
		end,
	})
end
function ac.PublishLocalBaseline(ai)
	if aa.IsAvailable() then
		local aj, ak = pcall(function()
			return ai:Snapshot()
		end)
		if aj and type(ak) == "table" then
			aa.ReportState(ag(ak))
		end
		ah(ai)
	end
	ad = true
end
function ac.Attach(ai)
	local aj, ak, al, am, an, ao =
		function(aj, ak)
			if type(aj) ~= "table" or next(aj) == nil then
				return
			end
			local al, am = pcall(function()
				return ai:Apply(af(aj), { Callbacks = false })
			end)
			if not al then
				ab.Warn("RuntimeSync: apply from server failed:", am)
				return
			end
			if ak and ae.Value == true then
				pcall(function()
					local an = ai:GetDefaultSnapshotName()
					if type(an) == "string" and an ~= "" then
						ai:SaveSnapshot(an)
					end
				end)
			end
		end, true, -1, false
	local ap = function()
		if not ak then
			return
		end
		if not aa.IsAvailable() then
			return
		end
		if not ad then
			return
		end
		if not am then
			am = true
			ao = aa.OnChanged(function()
				al = -1
			end)
		end
		local ap, aq = aa.GetVersion(), aa.GetSnapshot()
		if not aq or next(aq) == nil then
			return
		end
		local ar, as, at = nil, pcall(function()
			return game:GetService("HttpService"):JSONEncode(aq)
		end)
		if as then
			ar = at
		end
		if ap ~= al or ar ~= an then
			local e = ap ~= al and al ~= -1
			al = ap
			an = ar
			aj(aq, e)
		end
	end
	task.spawn(function()
		local aq = 0
		while ak do
			pcall(ap)
			aq = aq + 1
			task.wait(aq < 40 and 0.25 or 2)
		end
	end)
	return function()
		ak = false
		if ao then
			ao()
		end
	end
end
function ac.ReportWindowState(ai)
	if not aa.IsAvailable() then
		return false
	end
	local aj, ak = pcall(function()
		return ai:Snapshot()
	end)
	if not aj or type(ak) ~= "table" then
		return false
	end
	return aa.ReportState(ag(ak))
end
function ac.ReportOptions(ai, aj)
	if not aa.IsAvailable() then
		return false
	end
	return aa.ReportOptions(ai, aj)
end
return ac
end
a["Server/ServerActions"]=function()
local aa, ab, ac, ad, ae, af, ag, ah, ai, aj =
	game:GetService("Players"),
	game:GetService("TeleportService"),
	game:GetService("HttpService"),
	d("Core/FileSystem"),
	d("Persist/AccountScopes"),
	d("Localization/Localization"),
	{},
	"Asc",
	"sea/servers",
	100
local ak, al, am =
	function()
		return aa.LocalPlayer
	end, function()
		local ak, al, am = ai .. "/" .. tostring(game.PlaceId), (ae.GetCurrentUserId())
		if ae.IsSynced() then
			am = "shared"
		elseif al then
			am = al
		else
			am = "_pending"
		end
		ak = ak .. "/" .. am
		if not ad.EnsurePath(ak) then
			return nil
		end
		return ak .. "/servers.json"
	end, function()
		return os.date("!*t").yday * 24 + os.date("!*t").hour
	end
local an = function()
	return { hour = am(), usedIds = {}, backup = nil }
end
local ao, ap =
	function()
		local ao, ap = al(), an()
		if not ao then
			return ap
		end
		local aq = ad.ReadFile(ao)
		if type(aq) == "string" and aq ~= "" then
			local ar, as = pcall(function()
				return ac:JSONDecode(aq)
			end)
			if ar and type(as) == "table" then
				ap.hour = as.hour or ap.hour
				ap.usedIds = (type(as.usedIds) == "table" and { as.usedIds } or { {} })[1]
				ap.backup = as.backup
			end
		end
		if tonumber(ap.hour) ~= am() then
			ap = an()
		end
		return ap
	end, function(ao)
		local ap = al()
		if not ap then
			return false
		end
		local aq, ar = pcall(function()
			return ac:JSONEncode(ao)
		end)
		if not aq then
			return false
		end
		return ad.WriteFile(ap, ar)
	end
local aq, ar, as =
	function(aq, ar)
		local as, at = pcall(function()
			local as = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=" .. aq .. "&limit=" .. tostring(aj) .. "&excludeFullGames=true"
			return ac:JSONDecode(game:HttpGet(as))
		end)
		if as and type(at) == "table" and type(at.data) == "table" then
			ar.backup = at
			ap(ar)
			return at
		end
		if type(ar.backup) == "table" and type(ar.backup.data) == "table" then
			return ar.backup
		end
		return nil
	end, function(aq, ar)
		local as = aq.backup
		if type(as) ~= "table" or type(as.data) ~= "table" then
			return
		end
		for at = #as.data, 1, -1 do
			if tostring(as.data[at].id) == ar then
				table.remove(as.data, at)
			end
		end
	end, function(aq, ar)
		return table.find(aq, ar) ~= nil
	end
function ag.RejoinSameServer()
	local at = ak()
	if not at then
		return false, af.t("errors.server.localPlayerUnavailable")
	end
	local e, f = game.PlaceId, game.JobId
	local g, h = pcall(function()
		ab:TeleportToPlaceInstance(e, f, at)
	end)
	if g then
		task.wait(3)
		pcall(function()
			ab:Teleport(e, at)
		end)
		return true
	end
	return false, tostring(h)
end
function ag.HopServer(at)
	local e = ak()
	if not e then
		return false, af.t("errors.server.localPlayerUnavailable")
	end
	local f = ao()
	local g = (type(f.usedIds) == "table" and { f.usedIds } or { {} })[1]
	f.usedIds = g
	local h = aq(at or ah, f)
	if not h or type(h.data) ~= "table" then
		return false, af.t("errors.server.noServerListAvailable")
	end
	for i, j in h.data do
		local k, l = tostring(j.id), tonumber(j.maxPlayers) or 0
		local m = tonumber(j.playing) or l
		if k ~= game.JobId and l > m and not as(g, k) then
			local n, o = pcall(function()
				ab:TeleportToPlaceInstance(game.PlaceId, k, e)
			end)
			if n then
				table.insert(g, k)
				ar(f, k)
				ap(f)
				return true
			end
			return false, tostring(o)
		end
	end
	ap(f)
	return false, af.t("errors.server.noMatchingPublicServer")
end
function ag.RejoinAfterMinutes(at)
	if at <= 0 then
		return false, af.t("notify.server.scheduledRejoinFailed.content")
	end
	task.wait(at * 60)
	return ag.RejoinSameServer()
end
function ag.JoinJobId(at)
	local e = ak()
	if not e then
		return false, af.t("errors.server.localPlayerUnavailable")
	end
	if at == "" then
		return false, af.t("errors.server.jobIdEmpty")
	end
	local f, g = pcall(function()
		ab:TeleportToPlaceInstance(game.PlaceId, at, e)
	end)
	return f, (f and { nil } or { (tostring(g)) })[1]
end
function ag.CopyCurrentJobId()
	if type(setclipboard) ~= "function" then
		return false, af.t("errors.server.clipboardUnavailable")
	end
	local at, e = pcall(setclipboard, game.JobId)
	return at, (at and { game.JobId } or { (tostring(e)) })[1]
end
return table.freeze(ag)
end
a["Settings/Helpers"]=function()
local aa = {}
function aa.Trim(ab)
	return (ab:gsub("^%s*(.-)%s*$", "%1"))
end
function aa.CloneTable(ab)
	local ac = {}
	for ad, ae in ab do
		ac[ad] = ae
	end
	return ac
end
function aa.BuildThemeOptions(ab, ac)
	local ad = table.clone(ab)
	table.sort(ad)
	local ae, af = {}, false
	for ag, ah in ad do
		if ah == ac then
			af = true
		end
		table.insert(ae, { Label = ah, Value = ah })
	end
	if not af and ac ~= "" then
		table.insert(ae, 1, { Label = ac, Value = ac })
	end
	return ae
end
return table.freeze(aa)
end
a["Settings/ServerSection"]=function()
local aa, ab, ac, ad, ae =
	d("UI/Attributes"), d("Server/ServerActions"), d("Localization/Localization"), {}, function(aa, ab, ac)
		if aa and aa.Notify then
			aa:Notify({ Title = ab, Content = ac })
		end
	end
local af, ag =
	function(af, ag, ah)
		task.spawn(function()
			local ai, aj, ak = pcall(ah)
			if not ai then
				ae(af, ac.t("notify.server.actionFailed.title", { name = ag }), tostring(aj))
				return
			end
			if aj then
				ae(af, ag, ak or ac.t("notify.server.actionStarted.content"))
			else
				ae(af, ac.t("notify.server.actionFailed.title", { name = ag }), ak)
			end
		end)
	end, function(af)
		local ag = tonumber(af)
		if not ag then
			return 0
		end
		return math.max(0, ag)
	end
function ad.Build(ah, ai)
	local aj, ak, al, am = 15, "30", "", 0
	local an, ao, ap =
		function()
			am = am + 1
			local an, ao = am, ag(ak)
			if ao <= 0 then
				ae(ai, ac.t("notify.server.scheduledRejoinFailed.title"), ac.t("notify.server.scheduledRejoinFailed.content"))
				return
			end
			local ap = ac.t("settings.server.scheduledRejoin.section.title")
			af(ai, ap, function()
				task.wait(ao * 60)
				if an ~= am then
					return false, ac.t("notify.server.scheduledRejoinCancelled.content")
				end
				return ab.RejoinSameServer()
			end)
		end, function()
			if #game:GetService("Players"):GetPlayers() < aj then
				af(ai, ac.t("settings.server.lowPlayerHop.toggle.title"), function()
					return ab.HopServer("Asc")
				end)
			end
		end, ah:AddSection(ac.t("settings.server.actions.section.title"))
	ap:AddButton({
		Title = ac.tag("settings.server.actions.rejoinSameServer.title"),
		Desc = ac.tag("settings.server.actions.rejoinSameServer.desc"),
		Variant = "Outline",
		Callback = function()
			af(ai, ac.t("settings.server.actions.rejoinSameServer.title"), ab.RejoinSameServer)
		end,
	})
	ap:AddButton({
		Title = ac.tag("settings.server.actions.manualServerHop.title"),
		Desc = ac.tag("settings.server.actions.manualServerHop.desc"),
		Variant = "Outline",
		Callback = function()
			af(ai, ac.t("settings.server.actions.manualServerHop.title"), function()
				return ab.HopServer("Asc")
			end)
		end,
	})
	ap:AddButton({
		Title = ac.tag("settings.server.actions.joinLowPlayerServer.title"),
		Desc = ac.tag("settings.server.actions.joinLowPlayerServer.desc"),
		Variant = "Outline",
		Callback = function()
			af(ai, ac.t("settings.server.actions.joinLowPlayerServer.title"), function()
				return ab.HopServer("Asc")
			end)
		end,
	})
	local aq = ah:AddSection(ac.t("settings.server.lowPlayerHop.section.title"))
	aq:AddToggle({
		Idx = aa.SettingsIdx.ServerHopIfLowPlayer,
		Title = ac.tag("settings.server.lowPlayerHop.toggle.title"),
		Desc = ac.tag("settings.server.lowPlayerHop.toggle.desc"),
		Default = false,
		Callback = function(ar)
			if ar then
				ao()
			end
		end,
	})
	aq:AddSlider({
		Idx = aa.SettingsIdx.ServerHopMinimumPlayers,
		Title = ac.tag("settings.server.lowPlayerHop.minimumPlayers.title"),
		Desc = ac.tag("settings.server.lowPlayerHop.minimumPlayers.desc"),
		Min = 1,
		Max = 25,
		Step = 1,
		Suffix = "/25",
		Default = aj,
		Callback = function(ar)
			aj = ar
		end,
	})
	local ar = ah:AddSection(ac.t("settings.server.scheduledRejoin.section.title"))
	ar:AddInput({
		Idx = aa.SettingsIdx.ServerHopMinutesToRejoin,
		Title = ac.tag("settings.server.scheduledRejoin.minutesInput.title"),
		Desc = ac.tag("settings.server.scheduledRejoin.minutesInput.desc"),
		Default = ak,
		Callback = function(as)
			ak = as
		end,
	})
	ar:AddToggle({
		Idx = aa.SettingsIdx.ServerHopRejoinAfterMinutes,
		Title = ac.tag("settings.server.scheduledRejoin.toggle.title"),
		Desc = ac.tag("settings.server.scheduledRejoin.toggle.desc"),
		Default = false,
		Callback = function(as)
			if as then
				an()
			else
				am = am + 1
			end
		end,
	})
	local as = ah:AddSection(ac.t("settings.server.jobJoin.section.title"))
	as:AddInput({
		Idx = aa.SettingsIdx.ServerHopJobId,
		Title = ac.tag("settings.server.jobJoin.jobIdInput.title"),
		Desc = ac.tag("settings.server.jobJoin.jobIdInput.desc"),
		Placeholder = ac.tag("settings.server.jobJoin.jobIdInput.placeholder"),
		Callback = function(at)
			al = at
		end,
	})
	as:AddButton({
		Title = ac.tag("settings.server.jobJoin.joinButton.title"),
		Desc = ac.tag("settings.server.jobJoin.joinButton.desc"),
		Variant = "Outline",
		Callback = function()
			af(ai, ac.t("settings.server.jobJoin.joinButton.title"), function()
				return ab.JoinJobId(al)
			end)
		end,
	})
	as:AddButton({
		Title = ac.tag("settings.server.jobJoin.copyButton.title"),
		Desc = ac.tag("settings.server.jobJoin.copyButton.desc"),
		Variant = "Outline",
		Callback = function()
			af(ai, ac.t("settings.server.jobJoin.copyButton.title"), ab.CopyCurrentJobId)
		end,
	})
end
return table.freeze(ad)
end
a["Settings/SnapshotListView"]=function()
local aa, ab = d("Core/Common"), d("Localization/Localization")
local ac, ad = aa.Creator, aa.Animator
local ae, af, ag, ah, ai, aj, ak, al, am, an, ao, ap =
	ac.New,
	{},
	78,
	44,
	28,
	6,
	"rbxassetid://12187365364",
	aa.AnimTokens.Info(0.14, aa.AnimTokens.Easing.Sharp),
	aa.AnimTokens.Info(aa.AnimTokens.Duration.Snap, aa.AnimTokens.Easing.Standard),
	{
		Snapshot = "rbxassetid://10723356830",
		Apply = "rbxassetid://10734923549",
		Star = "rbxassetid://10734966248",
		Save = "rbxassetid://10734941499",
		Copy = "rbxassetid://10709812159",
		Rename = "rbxassetid://10734919691",
		Delete = "rbxassetid://10747362241",
	},
	function(ae, af)
		local ag = ac.GetThemeProperty(ae)
		return (ag ~= nil and { ag } or { af })[1]
	end,
	function(ae)
		if type(ae) ~= "number" then
			return ab.t("common.timestamp.none")
		end
		local af = ab.t("formatDate", { timestamp = ae })
		if af == "" or af == "formatDate" then
			return ab.t("common.timestamp.unknown")
		end
		return ab.t("common.timestamp.updated", { time = af })
	end
local aq, ar =
	function(aq, ar, as)
		return ae("TextLabel", { AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = ao(as and "Accent" or "VariantDestructiveBg", Color3.fromRGB(255, 185, 255)), BackgroundTransparency = as and 0.16 or 0.4, BorderSizePixel = 0, FontFace = Font.new(ak, ao("FontWeightMedium", Enum.FontWeight.Medium), Enum.FontStyle.Normal), LayoutOrder = ar, Size = UDim2.fromOffset(0, 18), Text = aq, TextColor3 = ao(as and "AccentForeground" or "VariantDestructiveText", Color3.fromRGB(240, 240, 240)), TextSize = 11, [ac.ThemeTag] = { BackgroundColor3 = as and "Accent" or "VariantDestructiveBg", TextColor3 = as and "AccentForeground" or "VariantDestructiveText" } }, { ae("UICorner", { CornerRadius = UDim.new(0, 999) }), ae("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }) })
	end, function(aq, ar, as, at, e)
		local f, g, h, i, j, k = as and "Accent" or (at and "VariantDestructiveBg" or "Hover"), as and "AccentForeground" or (at and "VariantDestructiveText" or "SubText"), as and 0 or 0.86, as and 0 or 0.74
		local l = ae("TextButton", { AutoButtonColor = false, BackgroundColor3 = ao(f, Color3.fromRGB(140, 140, 140)), BackgroundTransparency = h, BorderSizePixel = 0, LayoutOrder = ar, Size = UDim2.fromOffset(ai, ai), Text = "", [ac.Activated] = e, [ac.ThemeTag] = { BackgroundColor3 = f } }, { ae("UICorner", { CornerRadius = ao("CornerRadiusTab", UDim.new(0, 6)), [ac.ThemeTag] = { CornerRadius = "CornerRadiusTab" } }), ae("UIScale", {
			Scale = 1,
			[ac.Ref] = function(l)
				j = l
			end,
		}), ae("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = aq,
			ImageColor3 = ao(g, Color3.fromRGB(240, 240, 240)),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(15, 15),
			[ac.Ref] = function(l)
				k = l
			end,
			[ac.ThemeTag] = { ImageColor3 = g },
		}) })
		ac.TrackConnection(
			l,
			l.MouseEnter:Connect(function()
				ad.Tween(l, { BackgroundTransparency = i }, al)
				if j then
					ad.Tween(j, { Scale = 1.06 }, al)
				end
				if k then
					ad.Tween(k, { Size = UDim2.fromOffset(16, 16) }, al)
				end
			end)
		)
		ac.TrackConnection(
			l,
			l.MouseLeave:Connect(function()
				ad.Tween(l, { BackgroundTransparency = h }, al)
				if j then
					ad.Tween(j, { Scale = 1 }, al)
				end
				if k then
					ad.Tween(k, { Size = UDim2.fromOffset(15, 15) }, al)
				end
			end)
		)
		ac.TrackConnection(
			l,
			l.MouseButton1Down:Connect(function()
				if j then
					ad.Tween(j, { Scale = 0.92 }, am)
				end
			end)
		)
		ac.TrackConnection(
			l,
			l.MouseButton1Up:Connect(function()
				if j then
					ad.Tween(j, { Scale = 1.06 }, al)
				end
			end)
		)
		return l
	end
function af.New(as)
	local at, e =
		{
			ae(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, aj),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}
			),
			ar(an.Apply, 1, false, false, as.OnApply),
			ar(an.Star, 2, as.IsDefault, false, as.OnSetDefault),
			ar(an.Save, 3, false, false, as.OnOverwrite),
			ar(an.Copy, 4, false, false, as.OnDuplicate),
			ar(an.Rename, 5, false, false, as.OnRename),
			ar(an.Delete, 6, false, true, as.OnDelete),
		},
		6 * ai + 5 * aj
	local f = ae(
		"Frame",
		{
			BackgroundColor3 = ao("BackgroundSurface", Color3.fromRGB(22, 22, 22)),
			BorderSizePixel = 0,
			Parent = as.Parent,
			Size = UDim2.new(1, 0, 0, ag),
			[ac.ThemeTag] = { BackgroundColor3 = "BackgroundSurface" },
		},
		{
			ae(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}
			),
			ae(
				"UIPadding",
				{
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
					PaddingTop = UDim.new(0, 10),
				}
			),
			ae(
				"Frame",
				{
					BackgroundColor3 = ao("Hover", Color3.fromRGB(140, 140, 140)),
					BackgroundTransparency = 0.84,
					BorderSizePixel = 0,
					LayoutOrder = 1,
					Size = UDim2.fromOffset(ah, ah),
					[ac.ThemeTag] = { BackgroundColor3 = "Hover" },
				},
				{
					ae(
						"UICorner",
						{
							CornerRadius = ao("CornerRadiusTab", UDim.new(0, 8)),
							[ac.ThemeTag] = { CornerRadius = "CornerRadiusTab" },
						}
					),
					ae(
						"ImageLabel",
						{
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = an.Snapshot,
							ImageColor3 = ao("Accent", Color3.fromRGB(255, 185, 255)),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(21, 21),
							[ac.ThemeTag] = { ImageColor3 = "Accent" },
						}
					),
				}
			),
			ae(
				"Frame",
				{ BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromOffset(0, 46) },
				{
					ae("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }),
					ae("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }),
					ae(
						"TextLabel",
						{
							BackgroundTransparency = 1,
							FontFace = Font.new(
								ak,
								ao("FontWeightSemiBold", Enum.FontWeight.SemiBold),
								Enum.FontStyle.Normal
							),
							LayoutOrder = 1,
							Size = UDim2.new(1, 0, 0, 20),
							Text = as.Snapshot.Name,
							TextColor3 = ao("Text", Color3.fromRGB(240, 240, 240)),
							TextSize = 15,
							TextTruncate = Enum.TextTruncate.AtEnd,
							TextXAlignment = Enum.TextXAlignment.Left,
							[ac.ThemeTag] = { TextColor3 = "Text" },
						}
					),
					ae(
						"TextLabel",
						{
							BackgroundTransparency = 1,
							FontFace = Font.new(ak),
							LayoutOrder = 2,
							Size = UDim2.new(1, 0, 0, 16),
							Text = ap(as.Snapshot.UpdatedAt),
							TextColor3 = ao("SubText", Color3.fromRGB(160, 160, 160)),
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
							[ac.ThemeTag] = { TextColor3 = "SubText" },
						}
					),
				}
			),
			ae(
				"Frame",
				{ AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, LayoutOrder = 3, Size = UDim2.fromOffset(
					0,
					0
				) },
				{
					ae(
						"UIListLayout",
						{
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 5),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}
					),
					(as.IsDefault and { (aq(ab.t("common.badge.default"), 1, true)) } or { nil })[1],
					(as.Snapshot.Invalid and { (aq(ab.t("common.badge.invalid"), 2, false)) } or { nil })[1],
				}
			),
			ae("Frame", { BackgroundTransparency = 1, LayoutOrder = 4, Size = UDim2.fromOffset(e, ai) }, at),
		}
	)
	ae(
		"UICorner",
		{ CornerRadius = ao("CornerRadiusWindow", UDim.new(0, 12)), [ac.ThemeTag] = { CornerRadius = "CornerRadiusWindow" } }
	).Parent =
		f
	ae(
		"UIStroke",
		{
			Color = (as.IsDefault and { (ao("Accent", Color3.fromRGB(255, 185, 255))) } or {
				(ao("StrokeColor", Color3.fromRGB(240, 240, 240))),
			})[1],
			Transparency = as.IsDefault and 0.38 or ao("StrokeTransparency", 0.9),
			[ac.ThemeTag] = { Color = as.IsDefault and "Accent" or "StrokeColor" },
		}
	).Parent =
		f
	return {
		Root = f,
		Destroy = function()
			f:Destroy()
		end,
	}
end
return table.freeze(af)
end
a["Settings/SnapshotSection"]=function()
local aa, ab, ac, ad, ae, af =
	d("Settings/SnapshotListView"),
	d("Settings/Helpers"),
	d("Persist/AccountNameCache"),
	d("Localization/Localization"),
	{},
	{
		{ Value = "continuous", LabelKey = "continuous" },
		{ Value = "15s", LabelKey = "every15Seconds" },
		{ Value = "30s", LabelKey = "every30Seconds" },
		{ Value = "60s", LabelKey = "every60Seconds" },
		{ Value = "5m", LabelKey = "every5Minutes" },
	}
local ag, ah, ai, aj =
	function()
		local ag = {}
		for ah, ai in af do
			table.insert(ag, { Label = ad.t("settings.snapshot.autoSave.options." .. ai.LabelKey), Value = ai.Value })
		end
		return ag
	end, function(ag, ah, ai)
		if ag.Notify then
			ag:Notify({ Title = ah, Content = ai or "", Duration = 3 })
		end
	end, function(ag)
		if ag.ListSnapshots then
			return ag:ListSnapshots()
		end
		return {}
	end, function(ag)
		local ah = (ag.GetSnapshotSettings and { (ag:GetSnapshotSettings()) } or { nil })[1]
		local ai = (type(ah) == "table" and { ah.AutoSave } or { nil })[1]
		if type(ai) ~= "table" then
			return false, "60s"
		end
		local aj = (type(ai.Interval) == "string" and { ai.Interval } or { "60s" })[1]
		return ai.Enabled == true, aj
	end
local ak, al, am =
	function(ak, al, am)
		if not ak.Modal or not ak.RenameSnapshot then
			return
		end
		ak:Modal({
			Title = ad.t("settings.snapshot.rename.modal.title"),
			Draggable = true,
			Width = 420,
			Height = 220,
			AllowOverlayDismiss = false,
			SnapshotMode = "Isolated",
			Build = function(an)
				local ao = an:AddSection(ad.t("settings.snapshot.rename.section.title"))
				local ap = ao:AddInput({ Title = ad.tag("settings.snapshot.rename.nameInput.title"), Desc = ad.tag("settings.snapshot.rename.nameInput.desc"), Default = al, MultiLine = false })
				ao:AddButton({
					Title = ad.tag("settings.snapshot.rename.saveButton.title"),
					Variant = "Default",
					Callback = function()
						local aq = ab.Trim(ap:GetValue())
						if aq == "" or aq == al then
							return
						end
						local ar, as = ak:RenameSnapshot(al, aq)
						if ar then
							ah(ak, ad.t("notify.snapshot.renamed.title"), ar)
							am()
							an:Close("renamed")
						else
							ah(ak, ad.t("notify.snapshot.renameFailed.title"), tostring(as or al))
						end
					end,
				})
			end,
		})
	end, function(ak, al, am)
		if not ak.Confirm then
			if ak.DeleteSnapshot and ak:DeleteSnapshot(al) then
				ah(ak, ad.t("notify.snapshot.deleted.title"), al)
				am()
			else
				ah(ak, ad.t("notify.snapshot.deleteFailed.title"), al)
			end
			return
		end
		ak:Confirm({ Title = ad.t("confirm.snapshot.delete.title"), Content = ad.t("confirm.snapshot.delete.content", { name = al }), Actions = { {
			Id = "delete",
			Label = ad.t("common.actions.delete"),
			Variant = "Destructive",
			Callback = function()
				if ak.DeleteSnapshot and ak:DeleteSnapshot(al) then
					ah(ak, ad.t("notify.snapshot.deleted.title"), al)
					am()
				else
					ah(ak, ad.t("notify.snapshot.deleteFailed.title"), al)
				end
			end,
		}, { Id = "cancel", Label = ad.t("common.actions.cancel"), Variant = "Secondary" } } })
	end, function(ak)
		if type(ak) ~= "number" then
			return ad.t("common.timestamp.noneLower")
		end
		local al = ad.t("formatDate", { timestamp = ak })
		if al == "" or al == "formatDate" then
			return ad.t("common.timestamp.unknown")
		end
		return al
	end
local an = function(an, ao)
	if not an.Modal or not an.ListSnapshotAccountScopes or not an.BorrowSnapshot or not an.ListSnapshotsInScope then
		ah(an, ad.t("notify.snapshot.borrowUnavailable.title"), ad.t("notify.snapshot.borrowUnavailable.content"))
		return
	end
	local ap, aq = an:ListSnapshotAccountScopes(), {}
	for ar, as in ap do
		if not as.IsCurrent then
			table.insert(aq, as)
		end
	end
	if #aq == 0 then
		ah(an, ad.t("notify.snapshot.nothingToBorrow.title"), ad.t("notify.snapshot.nothingToBorrow.content"))
		return
	end
	for ar, as in aq do
		ac.Prime(as.UserId)
	end
	task.wait(0.15)
	local ar = function(ar)
		local as = ac.Get(ar)
		if as == "" or as == ("User " .. ar) then
			return ("%s (%s)"):format(ad.t("settings.snapshot.borrow.resolving"), ar)
		end
		return ("%s (%s)"):format(as, ar)
	end
	an:Modal({
		Title = ad.t("settings.snapshot.borrow.modal.title"),
		Draggable = true,
		Width = 520,
		Height = 460,
		AllowOverlayDismiss = true,
		SnapshotMode = "Isolated",
		Build = function(as)
			as:AddSection(ad.t("settings.snapshot.borrow.section.title"))
			for at, e in aq do
				local f = e.UserId
				local g, h = as:AddSection(ar(f)), an:ListSnapshotsInScope(f)
				if #h == 0 then
					g:AddLabel(ad.t("settings.snapshot.borrow.emptyScope"))
					continue
				end
				for i, j in h do
					local k, l = j.Name, ad.t("common.badge.invalid")
					local m = (j.Invalid and { (("[%s] %s"):format(l, k)) } or { k })[1]
					g:AddButton({
						Title = m,
						Desc = ad.t("settings.snapshot.borrow.card.desc", { time = am(j.UpdatedAt) }),
						Variant = "Outline",
						Callback = function()
							if j.Invalid then
								ah(an, ad.t("notify.snapshot.invalid.title"), k)
								return
							end
							local n, o = an:BorrowSnapshot(f, k)
							if n then
								ah(an, ad.t("notify.snapshot.borrowed.title"), n)
								ao()
								as:Close("borrowed")
							else
								ah(an, ad.t("notify.snapshot.borrowFailed.title"), tostring(o or k))
							end
						end,
					})
				end
			end
		end,
	})
end
function ae.Build(ao, ap)
	if not ap.SaveSnapshot or not ap.ListSnapshots or not ap.LoadSnapshot then
		return
	end
	local aq, ar, as, at, e, f =
		ao:AddSection(ad.t("settings.snapshot.sync.section.title")),
		(ap.GetSnapshotSyncAccounts and { (ap:GetSnapshotSyncAccounts()) } or { false })[1]
	f = aq:AddToggle({
		Idx = "__SnapshotSyncAccounts",
		Title = ad.tag("settings.snapshot.sync.toggle.title"),
		Desc = ad.tag("settings.snapshot.sync.toggle.desc"),
		Default = ar,
		Callback = function(g)
			if not ap.SetSnapshotSyncAccounts then
				if f and f.SetValue then
					f:SetValue(not g)
				end
				ah(ap, ad.t("notify.snapshot.syncFailed.title"), ad.t("notify.snapshot.borrowUnavailable.content"))
				return
			end
			local h = ap:SetSnapshotSyncAccounts(g)
			ah(
				ap,
				(
					h and { (ad.t("notify.snapshot.syncUpdated.title")) } or { (ad.t("notify.snapshot.syncFailed.title")) }
				)[1],
				(g and { (ad.t("notify.snapshot.syncUpdated.shared")) } or {
					(ad.t("notify.snapshot.syncUpdated.perAccount")),
				})[1]
			)
			if not h then
				if f and f.SetValue then
					f:SetValue(not g)
				end
				return
			end
			local i, j = aj(ap)
			if as and as.SetValue then
				as:SetValue(i)
			end
			if at and at.SetValue then
				at:SetValue({ j })
			end
			if e then
				e()
			end
		end,
	})
	aq:AddButton({
		Title = ad.tag("settings.snapshot.borrow.button.title"),
		Desc = ad.tag("settings.snapshot.borrow.button.desc"),
		Variant = "Outline",
		Callback = function()
			task.spawn(function()
				an(ap, function()
					if e then
						e()
					end
				end)
			end)
		end,
	})
	local g, h, i = ao:AddSection(ad.t("settings.snapshot.autoSave.section.title")), aj(ap)
	as = g:AddToggle({
		Idx = "__SnapshotAutoSaveEnabled",
		Title = ad.tag("settings.snapshot.autoSave.toggle.title"),
		Desc = ad.tag("settings.snapshot.autoSave.toggle.desc"),
		Default = h,
		Callback = function(j)
			if ap.SetSnapshotAutoSave then
				local k, l = aj(ap)
				local m = ap:SetSnapshotAutoSave(j, l)
				ah(
					ap,
					(m and { (ad.t("notify.snapshot.autoSaveUpdated.title")) } or {
						(ad.t("notify.snapshot.autoSaveFailed.title")),
					})[1],
					(j and { (ad.t("common.state.enabled")) } or { (ad.t("common.state.disabled")) })[1]
				)
			end
		end,
	})
	at = g:AddSelect({
		Idx = "__SnapshotAutoSaveInterval",
		Title = ad.tag("settings.snapshot.autoSave.frequency.title"),
		Desc = ad.tag("settings.snapshot.autoSave.frequency.desc"),
		Options = ag(),
		Default = { i },
		MaxSelection = 1,
		Callback = function(j)
			if ap.SetSnapshotAutoSave and type(j) == "string" then
				local k = aj(ap)
				local l = ap:SetSnapshotAutoSave(k, j)
				ah(
					ap,
					(l and { (ad.t("notify.snapshot.autoSaveFrequencyUpdated.title")) } or {
						(ad.t("notify.snapshot.autoSaveFailed.title")),
					})[1],
					j
				)
			end
		end,
	})
	ad.OnChanged(function()
		if at and at.SetOptions then
			at:SetOptions(ag())
		end
	end)
	local j = ao:AddSection(ad.t("settings.snapshot.create.section.title"))
	local k, l, m =
		j:AddInput({
			Title = ad.tag("settings.snapshot.create.nameInput.title"),
			Desc = ad.tag("settings.snapshot.create.nameInput.desc"),
			Placeholder = ad.tag("settings.snapshot.create.nameInput.placeholder"),
			Default = "",
			MultiLine = false,
		}),
		ao:AddSection({ Title = ad.t("settings.snapshot.list.section.title"), Unstyled = true }),
		{}
	local n = function()
		for n, o in m do
			if o.Destroy then
				o:Destroy()
			end
		end
		table.clear(m)
	end
	e = function()
		n()
		local o = (ap.GetCurrentThemeName and { (ap:GetCurrentThemeName()) } or { nil })[1]
		local p = (ap.GetDefaultSnapshotName and { (ap:GetDefaultSnapshotName(o)) } or { nil })[1]
		for q, r in ai(ap) do
			local s = r.Name
			if type(s) ~= "string" or s == "" then
				continue
			end
			local t = aa.New({
				Parent = l.Container,
				Snapshot = r,
				IsDefault = p == s,
				OnApply = function()
					if not r.Invalid then
						local t, u = ap:LoadSnapshot(s)
						if t then
							ah(ap, ad.t("notify.snapshot.applied.title"), s)
						else
							ah(ap, ad.t("notify.snapshot.applyFailed.title"), tostring(u or s))
						end
					else
						ah(ap, ad.t("notify.snapshot.invalid.title"), s)
					end
				end,
				OnSetDefault = function()
					if ap.SetDefaultSnapshotName then
						local t = (p == s and { nil } or { s })[1]
						if ap:SetDefaultSnapshotName(o, t) then
							ah(
								ap,
								(t and { (ad.t("notify.snapshot.defaultSet.title")) } or {
									(ad.t("notify.snapshot.defaultCleared.title")),
								})[1],
								s
							)
							e()
						else
							ah(ap, ad.t("notify.snapshot.defaultFailed.title"), s)
						end
					end
				end,
				OnOverwrite = function()
					if ap:SaveSnapshot(s) then
						ah(ap, ad.t("notify.snapshot.overwritten.title"), s)
						e()
					else
						ah(ap, ad.t("notify.snapshot.overwriteFailed.title"), s)
					end
				end,
				OnDuplicate = function()
					if ap.DuplicateSnapshot then
						local t, u = ap:DuplicateSnapshot(s)
						if t then
							ah(ap, ad.t("notify.snapshot.duplicated.title"), t)
							e()
						else
							ah(ap, ad.t("notify.snapshot.duplicateFailed.title"), tostring(u or s))
						end
					end
				end,
				OnRename = function()
					ak(ap, s, e)
				end,
				OnDelete = function()
					al(ap, s, e)
				end,
			})
			table.insert(m, t)
		end
	end
	j:AddButton({
		Title = ad.tag("settings.snapshot.create.button.title"),
		Desc = ad.tag("settings.snapshot.create.button.desc"),
		Variant = "Default",
		Callback = function()
			local o = ab.Trim(k:GetValue())
			if o == "" then
				return
			end
			if ap:SaveSnapshot(o) then
				ah(ap, ad.t("notify.snapshot.created.title"), o)
				e()
			else
				ah(ap, ad.t("notify.snapshot.createFailed.title"), o)
			end
		end,
	})
	ad.OnChanged(function()
		e()
	end)
	e()
end
return table.freeze(ae)
end
a["Settings/Tab"]=function()
local aa, ab, ac, ad, ae, af, ag, ah =
	{},
	game:GetService("RunService"),
	d("Settings/ThemeSection"),
	d("Settings/SnapshotSection"),
	d("Settings/ServerSection"),
	d("UI/Attributes"),
	d("Localization/Localization"),
	{
		{ Value = "1", LabelKey = "cap1", Cap = 1 },
		{ Value = "5", LabelKey = "cap5", Cap = 5 },
		{ Value = "15", LabelKey = "cap15", Cap = 15 },
		{ Value = "30", LabelKey = "cap30", Cap = 30 },
		{ Value = "60", LabelKey = "cap60", Cap = 60 },
		{ Value = "120", LabelKey = "cap120", Cap = 120 },
		{ Value = "144", LabelKey = "cap144", Cap = 144 },
		{ Value = "240", LabelKey = "cap240", Cap = 240 },
		{ Value = "0", LabelKey = "unlimited", Cap = 0 },
	}
local ai, aj =
	function()
		local ai = {}
		for aj, ak in ah do
			table.insert(ai, { Label = ag.t("settings.performance.fpsCap.options." .. ak.LabelKey), Value = ak.Value })
		end
		return ai
	end, function(ai)
		local aj, ak = pcall(function()
			return rawget(_G, ai)
		end)
		if aj and ak ~= nil then
			return ak
		end
		local al, am = pcall(function()
			return (getfenv)(0)[ai]
		end)
		return (al and { am } or { nil })[1]
	end
local ak, al =
	function()
		local ak = aj("setfpscap")
		return (type(ak) == "function" and { ak } or { nil })[1]
	end, { { Code = "en", LabelKey = "english" }, { Code = "vi", LabelKey = "vietnamese" } }
local am, an, ao =
	function()
		local am = {}
		for an, ao in al do
			table.insert(am, { Label = ag.t("settings.localization.locale.options." .. ao.LabelKey), Value = ao.Code })
		end
		return am
	end, function(am, an, ao)
		if am.GetSetting then
			local ap = am:GetSetting(an)
			if ap ~= nil then
				return ap
			end
		end
		return ao
	end, function(am, an, ao)
		if am.SetSetting then
			am:SetSetting(an, ao)
		end
	end
function aa.Build(ap, aq)
	local ar = ap.MainSubTab or ap
	ar.Title = ag.t("settings.tabs.general")
	if ar.Button then
		ar.Button.Text = ag.t("settings.tabs.general")
	end
	local as = ar:AddSection(ag.t("settings.localization.section.title"))
	local at = as:AddSelect({
		Idx = "__SeaHubLocale",
		Title = ag.tag("settings.localization.locale.title"),
		Desc = ag.tag("settings.localization.locale.desc"),
		Options = am(),
		Default = { ag.Get() },
		MaxSelection = 1,
		Callback = function(at)
			if type(at) ~= "string" then
				return
			end
			if ag.Set(at) and aq.Notify then
				aq:Notify({ Title = ag.t("notify.locale.updated.title"), Content = "", Duration = 2 })
			end
		end,
	})
	ag.OnChanged(function()
		if at.SetOptions then
			at:SetOptions(am())
			at:SetValue({ ag.Get() })
		end
	end)
	local e, f = ar:AddSection(ag.t("settings.performance.section.title")), an(aq, "FpsCap", 60)
	local g, h = tonumber(f) or 60, ak()
	if h then
		pcall(h, g)
	end
	local i = e:AddSelect({
		Idx = af.SettingsIdx.FpsCap,
		Title = ag.tag("settings.performance.fpsCap.title"),
		Desc = (ak() == nil and { (ag.t("settings.performance.fpsCap.unavailable")) } or {
			(ag.t("settings.performance.fpsCap.desc")),
		})[1],
		Options = ai(),
		Default = { tostring(g) },
		MaxSelection = 1,
		Callback = function(i)
			local j = tonumber(i)
			if not j then
				return
			end
			local k = ak()
			if not k then
				if aq.Notify then
					aq:Notify({
						Title = ag.t("settings.performance.fpsCap.title"),
						Content = ag.t("settings.performance.fpsCap.unavailable"),
						Duration = 4,
					})
				end
				return
			end
			pcall(k, j)
			ao(aq, "FpsCap", j)
		end,
	})
	ag.OnChanged(function()
		if i.SetOptions then
			i:SetOptions(ai())
		end
		if i.SetDesc then
			i:SetDesc(
				(ak() == nil and { (ag.t("settings.performance.fpsCap.unavailable")) } or {
					(ag.t("settings.performance.fpsCap.desc")),
				})[1]
			)
		end
	end)
	local j = an(aq, "Render3dEnabled", true)
	pcall(function()
		ab:Set3dRenderingEnabled(j == true)
	end)
	e:AddToggle({
		Idx = af.SettingsIdx.Render3dEnabled,
		Title = ag.tag("settings.performance.render3d.title"),
		Desc = ag.tag("settings.performance.render3d.desc"),
		Default = j == true,
		Callback = function(k)
			pcall(function()
				ab:Set3dRenderingEnabled(k)
			end)
			ao(aq, "Render3dEnabled", k == true)
		end,
	})
	local k = ar:AddSection(ag.t("settings.runtime.section.title"))
	k:AddSlider({
		Idx = af.SettingsIdx.DragFpsCap,
		Title = ag.tag("settings.runtime.dragFpsCap.title"),
		Desc = ag.tag("settings.runtime.dragFpsCap.desc"),
		Min = 0,
		Max = 240,
		Step = 5,
		Suffix = "Hz",
		Default = aq:GetDragFpsCap(),
		Callback = function(l)
			aq:SetDragFpsCap(l)
		end,
	})
	k:AddToggle({
		Idx = af.SettingsIdx.UseDragSkeleton,
		Title = ag.tag("settings.runtime.useDragSkeleton.title"),
		Desc = ag.tag("settings.runtime.useDragSkeleton.desc"),
		Default = aq:GetUseDragSkeleton(),
		Callback = function(l)
			aq:SetUseDragSkeleton(l)
		end,
	})
	k:AddToggle({
		Idx = af.SettingsIdx.UseFullVisibilityAnimation,
		Title = ag.tag("settings.runtime.fullVisibilityAnimation.title"),
		Desc = ag.tag("settings.runtime.fullVisibilityAnimation.desc"),
		Default = aq.GetUseFullVisibilityAnimation and aq:GetUseFullVisibilityAnimation() or false,
		Callback = function(l)
			if aq.SetUseFullVisibilityAnimation then
				aq:SetUseFullVisibilityAnimation(l)
			end
		end,
	})
	k:AddToggle({
		Idx = af.SettingsIdx.UseClassicToggle,
		Title = ag.tag("settings.runtime.useClassicToggle.title"),
		Desc = ag.tag("settings.runtime.useClassicToggle.desc"),
		Default = aq.GetUseClassicToggle and aq:GetUseClassicToggle() or true,
		Callback = function(l)
			if aq.SetUseClassicToggle then
				aq:SetUseClassicToggle(l)
			end
		end,
	})
	k:AddKeybind({
		Idx = af.SettingsIdx.ToggleUiKeybind,
		Title = ag.tag("settings.runtime.toggleUiKeybind.title"),
		Desc = ag.tag("settings.runtime.toggleUiKeybind.desc"),
		Default = an(aq, "ToggleUiKeybind", nil),
		Mode = "Press",
		AllowMouse = false,
		Callback = function()
			if aq.ToggleVisible then
				aq:ToggleVisible()
			end
		end,
		ChangedCallback = function(l)
			ao(aq, "ToggleUiKeybind", l)
		end,
	})
	k:AddToggle({
		Idx = af.SettingsIdx.OverlayEnabled,
		Title = ag.tag("settings.runtime.overlay.title"),
		Desc = ag.tag("settings.runtime.overlay.desc"),
		Default = an(aq, "OverlayEnabled", aq.GetOverlayEnabled and aq:GetOverlayEnabled() or true),
		Callback = function(l)
			if aq.SetOverlayEnabled then
				aq:SetOverlayEnabled(l)
			end
		end,
	})
	ae.Build(ar, aq)
	local l = ap:AddSubTab(ag.t("settings.tabs.theme"), 1)
	ac.Build(l, aq)
	local m = ap:AddSubTab(ag.t("settings.tabs.snapshots"), 1)
	ad.Build(m, aq)
end
return table.freeze(aa)
end
a["Settings/ThemeColorTokens"]=function()
local aa = {
	{ Key = "Accent" },
	{ Key = "AccentForeground" },
	{ Key = "AccentDark" },
	{ Key = "LogoColorBase" },
	{ Key = "BackgroundMain" },
	{ Key = "BackgroundSurface" },
	{ Key = "BackgroundElevated" },
	{ Key = "Text" },
	{ Key = "SubText" },
	{ Key = "TextPlaceholder" },
	{ Key = "StrokeColor" },
	{ Key = "DividerColor" },
	{ Key = "Hover" },
	{ Key = "InputBg" },
	{ Key = "InputText" },
	{ Key = "SliderRail" },
	{ Key = "SliderFill" },
	{ Key = "DropdownBg" },
	{ Key = "DropdownText" },
	{ Key = "SelectPopupBg" },
	{ Key = "TabBar" },
	{ Key = "TabActive" },
	{ Key = "TabInactive" },
	{ Key = "SidebarBg" },
	{ Key = "SidebarIcon" },
	{ Key = "SidebarIconActive" },
	{ Key = "SidebarActiveIndicator" },
	{ Key = "DialogSurface" },
	{ Key = "DialogBorder" },
	{ Key = "DialogHeaderText" },
	{ Key = "DialogCloseIcon" },
}
return table.freeze(aa)
end
a["Settings/ThemeOtherTokens"]=function()
local aa = {
	{ Key = "AccentGradientRotation", Min = 0, Max = 360, Step = 1, Suffix = "deg", Default = 45 },
	{ Key = "BackgroundMainTransparency", Min = 0, Max = 1, Step = 0.01, Suffix = "", Default = 0 },
	{ Key = "StrokeTransparency", Min = 0, Max = 1, Step = 0.01, Suffix = "", Default = 0 },
	{ Key = "HoverTransparency", Min = 0, Max = 1, Step = 0.01, Suffix = "", Default = 1 },
	{ Key = "ScrollBarThickness", Min = 0, Max = 12, Step = 1, Suffix = "px", Default = 2 },
	{ Key = "TextSizeBody", Min = 10, Max = 28, Step = 1, Suffix = "px", Default = 16 },
	{ Key = "TextSizeSmall", Min = 10, Max = 24, Step = 1, Suffix = "px", Default = 15 },
	{ Key = "TextSizeTab", Min = 12, Max = 30, Step = 1, Suffix = "px", Default = 17 },
	{ Key = "CornerRadiusWindow", Min = 0, Max = 32, Step = 1, Suffix = "px", Default = 12, ValueType = "UDim" },
	{ Key = "CornerRadiusSubTabs", Min = 0, Max = 32, Step = 1, Suffix = "px", Default = 16, ValueType = "UDim" },
	{ Key = "CornerRadiusSidebar", Min = 0, Max = 32, Step = 1, Suffix = "px", Default = 10, ValueType = "UDim" },
	{ Key = "CornerRadiusTab", Min = 0, Max = 32, Step = 1, Suffix = "px", Default = 6, ValueType = "UDim" },
	{ Key = "CornerRadiusSection", Min = 0, Max = 32, Step = 1, Suffix = "px", Default = 18, ValueType = "UDim" },
	{ Key = "PaddingWindow", Min = 0, Max = 32, Step = 1, Suffix = "px", Default = 12, ValueType = "UDim" },
	{ Key = "PaddingElement", Min = 0, Max = 32, Step = 1, Suffix = "px", Default = 14, ValueType = "UDim" },
	{ Key = "PaddingInput", Min = 0, Max = 24, Step = 1, Suffix = "px", Default = 8, ValueType = "UDim" },
}
return table.freeze(aa)
end
a["Settings/ThemePreview"]=function()
local aa, ab = d("Core/Common"), d("Localization/Localization")
local ac, ad = aa.Creator, aa.Animator
local ae, af, ag, ah, ai, aj, ak, al, am, an, ao, ap =
	ac.New,
	{},
	76,
	52,
	28,
	6,
	"rbxassetid://12187365364",
	aa.AnimTokens.Info(0.14, aa.AnimTokens.Easing.Sharp),
	aa.AnimTokens.Info(aa.AnimTokens.Duration.Snap, aa.AnimTokens.Easing.Standard),
	{
		Apply = "rbxassetid://10709790644",
		Customize = "rbxassetid://10734910430",
		Save = "rbxassetid://10734941499",
		Duplicate = "rbxassetid://10709812159",
		Delete = "rbxassetid://10747362241",
	},
	function(ae, af)
		local ag = ac.GetThemeProperty(ae)
		return (ag ~= nil and { ag } or { af })[1]
	end,
	function(ae, af, ag)
		local ah = ae[af]
		return (typeof(ah) == "Color3" and { ah } or { ag })[1]
	end
local aq, ar, as =
	function(aq)
		local ar = ap(aq, "Accent", Color3.fromRGB(255, 185, 255))
		local as, at, e = ap(aq, "AccentDark", ar), ap(aq, "BackgroundSurface", Color3.fromRGB(22, 22, 22)), ap(aq, "BackgroundMain", Color3.fromRGB(20, 20, 20))
		return ae("Frame", { BackgroundColor3 = ar, BorderSizePixel = 0, LayoutOrder = 2, Size = UDim2.fromOffset(ah, ah) }, { ae("UICorner", { CornerRadius = ao("CornerRadiusTab", UDim.new(0, 10)), [ac.ThemeTag] = { CornerRadius = "CornerRadiusTab" } }), ae("UIStroke", { Color = ao("StrokeColor", Color3.fromRGB(240, 240, 240)), Transparency = ao("StrokeTransparency", 0.9), [ac.ThemeTag] = { Color = "StrokeColor", Transparency = "StrokeTransparency" } }), ae("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, ar), ColorSequenceKeypoint.new(0.48, as), ColorSequenceKeypoint.new(0.72, at), ColorSequenceKeypoint.new(1, e) }), Rotation = tonumber(aq.AccentGradientRotation) or 45 }), ae("Frame", { AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = ap(aq, "Text", Color3.fromRGB(240, 240, 240)), BorderSizePixel = 0, Position = UDim2.new(1, -7, 1, -7), Size = UDim2.fromOffset(12, 12) }, { ae("UICorner", { CornerRadius = UDim.new(0, 999) }), ae("UIStroke", { Color = e, Thickness = 2 }) }) })
	end, function(aq, ar, as)
		return ae("TextLabel", { AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = ao(as or "Hover", Color3.fromRGB(140, 140, 140)), BackgroundTransparency = as and 0.15 or ao("HoverTransparency", 0.85), BorderSizePixel = 0, FontFace = Font.new(ak, ao("FontWeightMedium", Enum.FontWeight.Medium), Enum.FontStyle.Normal), LayoutOrder = ar, Size = UDim2.fromOffset(0, 18), Text = aq, TextColor3 = ao(as and "AccentForeground" or "SubText", Color3.fromRGB(160, 160, 160)), TextSize = 11, [ac.ThemeTag] = { BackgroundColor3 = as or "Hover", TextColor3 = as and "AccentForeground" or "SubText" } }, { ae("UICorner", { CornerRadius = UDim.new(0, 999) }), ae("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }) })
	end, function(aq, ar, as, at)
		local e, f = as == "Primary", as == "Destructive"
		local g, h, i, j, k, l = e and "Accent" or (f and "VariantDestructiveBg" or "Hover"), e and "AccentForeground" or (f and "VariantDestructiveText" or "SubText"), e and 0 or 0.86, e and 0 or 0.74
		local m = ae("TextButton", { AutoButtonColor = false, BackgroundColor3 = ao(g, Color3.fromRGB(140, 140, 140)), BackgroundTransparency = i, BorderSizePixel = 0, LayoutOrder = ar, Size = UDim2.fromOffset(ai, ai), Text = "", [ac.Activated] = at, [ac.ThemeTag] = { BackgroundColor3 = g } }, { ae("UICorner", { CornerRadius = ao("CornerRadiusTab", UDim.new(0, 6)), [ac.ThemeTag] = { CornerRadius = "CornerRadiusTab" } }), ae("UIScale", {
			Scale = 1,
			[ac.Ref] = function(m)
				k = m
			end,
		}), ae("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = aq,
			ImageColor3 = ao(h, Color3.fromRGB(240, 240, 240)),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(15, 15),
			[ac.Ref] = function(m)
				l = m
			end,
			[ac.ThemeTag] = { ImageColor3 = h },
		}) })
		ac.TrackConnection(
			m,
			m.MouseEnter:Connect(function()
				ad.Tween(m, { BackgroundTransparency = j }, al)
				if k then
					ad.Tween(k, { Scale = 1.06 }, al)
				end
				if l then
					ad.Tween(l, { Size = UDim2.fromOffset(16, 16) }, al)
				end
			end)
		)
		ac.TrackConnection(
			m,
			m.MouseLeave:Connect(function()
				ad.Tween(m, { BackgroundTransparency = i }, al)
				if k then
					ad.Tween(k, { Scale = 1 }, al)
				end
				if l then
					ad.Tween(l, { Size = UDim2.fromOffset(15, 15) }, al)
				end
			end)
		)
		ac.TrackConnection(
			m,
			m.MouseButton1Down:Connect(function()
				if k then
					ad.Tween(k, { Scale = 0.92 }, am)
				end
			end)
		)
		ac.TrackConnection(
			m,
			m.MouseButton1Up:Connect(function()
				if k then
					ad.Tween(k, { Scale = 1.06 }, al)
				end
			end)
		)
		return m
	end
function af.New(at)
	local e, f, g =
		at.ThemeData or {},
		{
			ae(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, aj),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}
			),
		},
		0
	local h = function(h, i, j)
		g = g + 1
		table.insert(f, as(h, g, i, j))
	end
	if not at.Preset.IsActive then
		h(an.Apply, "Primary", at.OnApply)
	end
	h(an.Customize, "Ghost", at.OnCustomize)
	if at.Preset.IsDirty then
		h(an.Save, "Primary", at.OnSave)
	end
	h(an.Duplicate, "Ghost", at.OnDuplicate)
	if not at.Preset.IsBuiltIn then
		h(an.Delete, "Destructive", at.OnDelete)
	end
	local i = g * ai + math.max(0, g - 1) * aj
	local j = ae(
		"Frame",
		{
			BackgroundColor3 = ao("BackgroundSurface", Color3.fromRGB(22, 22, 22)),
			BorderSizePixel = 0,
			Parent = at.Parent,
			Size = UDim2.new(1, 0, 0, ag),
			[ac.ThemeTag] = { BackgroundColor3 = "BackgroundSurface" },
		},
		{
			ae(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}
			),
			ae(
				"UIPadding",
				{
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
					PaddingTop = UDim.new(0, 10),
				}
			),
			aq(e),
			ae(
				"Frame",
				{ BackgroundTransparency = 1, LayoutOrder = 3, Size = UDim2.fromOffset(0, 48) },
				{
					ae("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }),
					ae("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
					ae(
						"TextLabel",
						{
							BackgroundTransparency = 1,
							FontFace = Font.new(
								ak,
								ao("FontWeightSemiBold", Enum.FontWeight.SemiBold),
								Enum.FontStyle.Normal
							),
							LayoutOrder = 1,
							Size = UDim2.new(1, 0, 0, 20),
							Text = at.Preset.Name,
							TextColor3 = ao("Text", Color3.fromRGB(240, 240, 240)),
							TextSize = 15,
							TextTruncate = Enum.TextTruncate.AtEnd,
							TextXAlignment = Enum.TextXAlignment.Left,
							[ac.ThemeTag] = { TextColor3 = "Text" },
						}
					),
					ae(
						"Frame",
						{
							AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundTransparency = 1,
							LayoutOrder = 2,
							Size = UDim2.fromOffset(0, 0),
						},
						{
							ae(
								"UIListLayout",
								{
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = UDim.new(0, 5),
									SortOrder = Enum.SortOrder.LayoutOrder,
								}
							),
							ar(
								(at.Preset.IsBuiltIn and { (ab.t("common.badge.builtIn")) } or {
									(ab.t("common.badge.custom")),
								})[1],
								1
							),
							(at.Preset.IsActive and { (ar(ab.t("common.badge.active"), 2, "Accent")) } or { nil })[1],
							(at.Preset.IsDirty and { (ar(ab.t("common.badge.unsaved"), 3, "TextWarning")) } or { nil })[1],
						}
					),
				}
			),
			ae("Frame", { BackgroundTransparency = 1, LayoutOrder = 4, Size = UDim2.fromOffset(i, ai) }, f),
		}
	)
	ae(
		"UICorner",
		{ CornerRadius = ao("CornerRadiusWindow", UDim.new(0, 12)), [ac.ThemeTag] = { CornerRadius = "CornerRadiusWindow" } }
	).Parent =
		j
	ae(
		"UIStroke",
		{
			Color = (at.Preset.IsActive and { (ao("Accent", Color3.fromRGB(255, 185, 255))) } or {
				(ao("StrokeColor", Color3.fromRGB(240, 240, 240))),
			})[1],
			Transparency = at.Preset.IsActive and 0.38 or ao("StrokeTransparency", 0.9),
			[ac.ThemeTag] = { Color = at.Preset.IsActive and "Accent" or "StrokeColor" },
		}
	).Parent =
		j
	return {
		Root = j,
		Destroy = function()
			j:Destroy()
		end,
	}
end
return table.freeze(af)
end
a["Settings/ThemeSection"]=function()
local aa, ab, ac, ad, ae, af =
	d("Settings/ThemePreview"), d("Settings/ThemeTokenEditor"), d("Localization/Localization"), {}, function(aa, ab, ac)
		if aa.Notify then
			aa:Notify({ Title = ab, Content = ac or "", Duration = 3 })
		end
	end, function(aa)
		if aa.GetThemePresets then
			return aa:GetThemePresets()
		end
		local ab, ac = (aa.GetCurrentThemeName and { (aa:GetCurrentThemeName()) } or { "" })[1], {}
		for ad, ae in aa:GetThemes() do
			table.insert(ac, { Name = ae, IsBuiltIn = ae == "Default" or ae == "ShadcnDark", IsActive = ae == ab, IsDirty = false })
		end
		return ac
	end
local ag, ah =
	function(ag, ah, ai)
		ab.Open(ag, ah.Name, ai, { IsBuiltIn = ah.IsBuiltIn == true })
	end, function(ag, ah, ai)
		if ag.DeleteTheme and ag:DeleteTheme(ah) then
			ae(ag, ac.t("notify.theme.deleted.title"), ah)
			ai()
		else
			ae(ag, ac.t("notify.theme.deleteFailed.title"), ah)
		end
	end
local ai = function(ai, aj, ak)
	if not ai.Confirm then
		ah(ai, aj, ak)
		return
	end
	ai:Confirm({
		Title = ac.t("confirm.theme.delete.title"),
		Content = ac.t("confirm.theme.delete.content", { name = aj }),
		Actions = {
			{
				Id = "delete",
				Label = ac.t("common.actions.delete"),
				Variant = "Destructive",
				Callback = function()
					ah(ai, aj, ak)
				end,
			},
			{ Id = "cancel", Label = ac.t("common.actions.cancel"), Variant = "Secondary" },
		},
	})
end
function ad.Build(aj, ak)
	if not ak.GetThemes or not ak.GetThemeData or not ak.SetTheme or not ak.PatchThemeTokens then
		return
	end
	local al, am = aj:AddSection({ Title = ac.t("settings.theme.presets.section.title"), Unstyled = true }), {}
	local an = function()
		for an, ao in am do
			if ao.Destroy then
				ao:Destroy()
			end
		end
		table.clear(am)
	end
	local function ao()
		an()
		for ap, aq in af(ak) do
			local ar = ak:GetThemeData(aq.Name)
			local as = aa.New({
				Parent = al.Container,
				Preset = aq,
				ThemeData = ar,
				OnApply = function()
					ak:SetTheme(aq.Name)
					ae(ak, ac.t("notify.theme.applied.title"), aq.Name)
					ao()
				end,
				OnCustomize = function()
					ag(ak, aq, ao)
				end,
				OnSave = function()
					if ak.SaveThemeFile then
						local as, at = ak:SaveThemeFile(aq.Name, aq.Name)
						if as then
							ae(ak, ac.t("notify.theme.saved.title"), aq.Name)
							ao()
						else
							ae(ak, ac.t("notify.theme.saveFailed.title"), tostring(at or aq.Name))
						end
					end
				end,
				OnDuplicate = function()
					if ak.DuplicateTheme then
						local as = ak:DuplicateTheme(aq.Name)
						if type(as) == "string" then
							ak:SetTheme(as)
							ae(ak, ac.t("notify.theme.duplicated.title"), as)
							ao()
						else
							ae(ak, ac.t("notify.theme.duplicateFailed.title"), aq.Name)
						end
					end
				end,
				OnDelete = function()
					ai(ak, aq.Name, ao)
				end,
			})
			table.insert(am, as)
		end
	end
	ac.OnChanged(function()
		ao()
	end)
	ao()
end
return table.freeze(ad)
end
a["Settings/ThemeTokenEditor"]=function()
local aa, ab, ac, ad, ae, af, ag, ah, ai =
	d("Settings/ThemeOtherTokens"),
	d("Settings/ThemeColorTokens"),
	d("Settings/Helpers"),
	d("UI/Attributes"),
	d("Localization/Localization"),
	{},
	Color3.fromRGB(255, 185, 255),
	{ Accent = true, AccentDark = true, LogoColorBase = true },
	{
		BackgroundMain = true,
		BackgroundSurface = true,
		BackgroundElevated = true,
		Text = true,
		SubText = true,
		TextPlaceholder = true,
		StrokeColor = true,
		DividerColor = true,
		Hover = true,
	}
local aj, ak, al, am =
	function(aj, ak)
		local al = aj:GetThemeData(ak)
		return (type(al) == "table" and { (ac.CloneTable(al)) } or { nil })[1]
	end, function(aj, ak, al)
		if aj and type(aj[ak]) == "boolean" then
			return aj[ak]
		end
		return al
	end, function(aj, ak)
		local al = aj and aj[ak.Key]
		if type(al) == "number" then
			return al
		end
		if typeof(al) == "UDim" then
			return al.Offset
		end
		return ak.Default
	end, function(aj, ak, al, am)
		local an = Color3.fromRGB(255, 255, 255)
		if am and typeof(am[al.Key]) == "Color3" then
			an = am[al.Key]
		end
		aj:AddColorPicker({
			Idx = ad.SettingsIdx.ThemeTokenPrefix .. al.Key,
			Title = ae.tag("settings.theme.tokens.color." .. al.Key .. ".title"),
			Desc = ae.tag("settings.theme.tokens.color." .. al.Key .. ".desc"),
			Default = an,
			Mode = "HEX",
			ApplyText = ae.t("common.actions.save"),
			Callback = function(ao)
				ak({ [al.Key] = ao })
			end,
		})
	end
local an = function(an, ao, ap, aq)
	for ar, as in ab do
		if (aq and aq[as.Key]) or (not aq and not ah[as.Key] and not ai[as.Key]) then
			am(an, ao, as, ap)
		end
	end
end
function af.Open(ao, ap, aq, ar)
	local as = aj(ao, ap)
	if not as then
		return
	end
	local at, e, f, g, h = ar and ar.IsBuiltIn == true, false, false
	local i, j =
		function()
			if f then
				return
			end
			f = true
			if aq then
				aq()
			end
		end, function()
			return ae.t("settings.theme.customize.modal.title", { name = ap })
		end
	local k = function(k)
		if type(k) ~= "string" or k == "" or k == ap then
			return
		end
		local l = ap
		ap = k
		if at and ao.SetTheme then
			ao:SetTheme(k)
		end
		if g then
			g:SetTitle(j())
		end
		if h and ac.Trim(h:GetValue()) == l then
			h:SetValue(k)
		end
	end
	local l = function(l)
		local m, n = ao:PatchThemeTokens(ap, l)
		if not m then
			return false
		end
		e = true
		k(n)
		i()
		return true
	end
	g = ao:Modal({
		Title = j(),
		Draggable = true,
		Width = 620,
		Height = 480,
		AllowOverlayDismiss = false,
		SnapshotMode = "Isolated",
		Build = function(m)
			local n = m:AddSection(ae.t("settings.theme.customize.overview.section.title"))
			h = n:AddInput({
				Idx = ad.SettingsIdx.ThemeFileName,
				Title = ae.tag("settings.theme.customize.overview.nameInput.title"),
				Desc = ae.tag("settings.theme.customize.overview.nameInput.desc"),
				Default = ap,
				MultiLine = false,
			})
			n:AddButton({
				Title = ae.tag("settings.theme.customize.overview.renameButton.title"),
				Desc = ae.tag("settings.theme.customize.overview.renameButton.desc"),
				Variant = "Outline",
				Callback = function()
					if not ao.RenameTheme then
						return
					end
					local o = ac.Trim(h:GetValue())
					local p = ao:RenameTheme(ap, o)
					if p then
						ap = p
						m:SetTitle(j())
						h:SetValue(p)
						if aq then
							aq()
						end
					end
				end,
			})
			n:AddButton({
				Title = ae.tag("settings.theme.customize.overview.saveButton.title"),
				Desc = ae.tag("settings.theme.customize.overview.saveButton.desc"),
				Variant = "Default",
				Callback = function()
					local o = ac.Trim(h:GetValue())
					if at and not e and (o == "" or o == ap) then
						return
					end
					local p, q = ao:SaveThemeFile(ap, o)
					if p then
						e = false
						f = false
						k(q)
					end
					if p and aq then
						aq()
					end
				end,
			})
			n:AddButton({
				Title = ae.tag("settings.theme.customize.overview.closeButton.title"),
				Desc = ae.tag("settings.theme.customize.overview.closeButton.desc"),
				Callback = function()
					m:Close("close_button")
				end,
			})
			local o = m:AddSection(ae.t("settings.theme.customize.brand.section.title"))
			o:AddToggle({
				Idx = ad.SettingsIdx.ThemeLogoSyncAccent,
				Title = ae.tag("settings.theme.customize.brand.syncLogoWithAccent.title"),
				Desc = ae.tag("settings.theme.customize.brand.syncLogoWithAccent.desc"),
				Default = ak(as, "LogoSyncAccent", true),
				Callback = function(p)
					local q = { LogoSyncAccent = p }
					if p == false then
						q.LogoColorBase = ag
					end
					l(q)
				end,
			})
			an(o, l, as, ah)
			an(m:AddSection(ae.t("settings.theme.customize.coreColors.section.title")), l, as, ai)
			an(m:AddSection(ae.t("settings.theme.customize.components.section.title")), l, as, nil)
			local p = m:AddSection(ae.t("settings.theme.customize.shapeMotion.section.title"))
			for q, r in aa do
				p:AddSlider({
					Idx = ad.SettingsIdx.ThemeTokenPrefix .. r.Key,
					Title = ae.tag("settings.theme.tokens.numeric." .. r.Key .. ".title"),
					Desc = ae.tag("settings.theme.tokens.numeric." .. r.Key .. ".desc"),
					Min = r.Min,
					Max = r.Max,
					Step = r.Step,
					Suffix = r.Suffix,
					Default = al(as, r),
					Callback = function(s)
						local t = (r.ValueType == "UDim" and { (UDim.new(0, s)) } or { s })[1]
						l({ [r.Key] = t })
					end,
				})
			end
		end,
	})
	ae.OnChanged(function()
		if g and g.SetTitle then
			g:SetTitle(j())
		end
	end)
end
return table.freeze(af)
end
a["Sidebar/Button"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae = aa.Creator, aa.Animator, aa.AnimTokens, d("Sidebar/Metrics")
local af, ag, ah, ai = ab.New, "rbxasset://fonts/families/SourceSansPro.json", 0.12, {}
function ai.New(aj)
	local ak, al, am
	local an = af(
		"TextButton",
		{
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			LayoutOrder = aj.LayoutOrder or 0,
			Size = UDim2.fromOffset(ae.ITEM_SIZE, ae.ITEM_SIZE),
			Text = "",
		},
		{
			af(
				"Frame",
				{
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 0,
					[ab.Ref] = function(an)
						am = an
					end,
					[ab.ThemeTag] = { BackgroundColor3 = "SidebarActiveBackground" },
				},
				{
					af(
						"UICorner",
						{
							CornerRadius = ab.GetThemeProperty("CornerRadiusSidebar") or UDim.new(0, 12),
							[ab.ThemeTag] = { CornerRadius = "CornerRadiusSidebar" },
						}
					),
					af("UIGradient", { Rotation = 45, [ab.ThemeTag] = { Color = "AccentGradient" } }),
				}
			),
			af("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = aj.Image,
				ImageColor3 = ab.GetThemeProperty("SidebarIcon") or Color3.fromRGB(240, 240, 240),
				ImageTransparency = ab.GetThemeProperty("SidebarIconTransparency") or 0.6,
				Position = UDim2.fromOffset(ae.ITEM_SIZE / 2, ae.ITEM_SIZE / 2),
				Size = UDim2.fromOffset(ae.ICON_SIZE, ae.ICON_SIZE),
				ZIndex = 2,
				[ab.Ref] = function(an)
					ak = an
				end,
			}),
			af("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new(
					ab.GetThemeProperty("FontFamily") or ag,
					Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Position = UDim2.fromOffset(ae.LABEL_LEFT - ae.ITEM_LEFT + ae.LABEL_SLIDE_X, 0),
				Size = UDim2.new(1, -(ae.LABEL_LEFT - ae.ITEM_LEFT + 8), 1, 0),
				Text = aj.Title,
				TextColor3 = ab.GetThemeProperty("SidebarIcon") or Color3.fromRGB(240, 240, 240),
				TextSize = ae.LABEL_FONT_SIZE,
				TextTransparency = 1,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,
				[ab.Ref] = function(an)
					al = an
				end,
				[ab.ThemeTag] = { TextColor3 = "SidebarIcon" },
			}),
		}
	)
	an.Parent = aj.Parent
	local ao = {
		Root = an,
		Icon = ak,
		Label = al,
		ActiveBackground = am,
		ExpandedTarget = false,
		Active = false,
		LabelReveal = 0,
		SelectionBlend = 0,
	}
	function ao.SetWidth(ap, aq)
		an.Size = UDim2.fromOffset(math.max(ae.ITEM_SIZE, aq), ae.ITEM_SIZE)
	end
	function ao.SetExpanded(ap, aq, ar)
		ap.ExpandedTarget = aq
	end
	function ao.SetExpansionProgress(ap, aq, ar)
		ap.LabelReveal = math.clamp(aq, 0, 1)
		ap.SelectionBlend = math.clamp(ar, 0, 1)
		local as = {
			Position = UDim2.fromOffset(ae.LABEL_LEFT - ae.ITEM_LEFT + ae.LABEL_SLIDE_X * (1 - ap.LabelReveal), 0),
			TextTransparency = 1 - ap.LabelReveal * (ap.Active and 0.98 or 0.78),
		}
		ac.Set(al, as)
		ac.Set(am, { BackgroundTransparency = 1 - (ap.Active and { (ah * ap.SelectionBlend) } or { 0 })[1] })
	end
	function ao.SetActive(ap, aq, ar, as)
		ap.Active = aq
		local at, e =
			1 - (ar and aq and { (ah * ap.SelectionBlend) } or { 0 })[1], 1 - ap.LabelReveal * (aq and 0.98 or 0.78)
		if as then
			ac.Tween(am, { BackgroundTransparency = at }, ad.Preset.Fade)
			ac.Tween(al, { TextTransparency = e }, ad.Preset.Fade)
		else
			ac.Set(am, { BackgroundTransparency = at })
			ac.Set(al, { TextTransparency = e })
		end
	end
	function ao.SetTitle(ap, aq)
		al.Text = aq
	end
	function ao.Destroy(ap)
		ac.CancelInstance(ak)
		ac.CancelInstance(al)
		ac.CancelInstance(am)
		an:Destroy()
	end
	return ao
end
return ai
end
a["Sidebar/Config"]=function()
local aa, ab = d("Sidebar/Metrics"), {}
function ab.ResolveConfig(ac)
	local ad = ac or {}
	return {
		Expandable = ad.Expandable ~= false,
		DefaultExpanded = ad.DefaultExpanded == true,
		Subtitle = (type(ad.Subtitle) == "string" and ad.Subtitle ~= "" and { ad.Subtitle } or { nil })[1],
	}
end
function ab.ResolveEffective(ac, ad, ae)
	return ad and ac and ae ~= "Compact"
end
function ab.WidthFor(ac)
	return (ac and { aa.EXPANDED_WIDTH } or { aa.COMPACT_WIDTH })[1]
end
function ab.ProgressFromWidth(ac)
	local ad = aa.EXPANDED_WIDTH - aa.COMPACT_WIDTH
	if ad <= 0 then
		return 0
	end
	return math.clamp((ac - aa.COMPACT_WIDTH) / ad, 0, 1)
end
function ab.ContentInsetFromWidth(ac)
	return aa.SHELL_X + ac + aa.CONTENT_GAP
end
return table.freeze(ab)
end
a["Sidebar/Indicator"]=function()
local aa, ab = game:GetService("RunService"), {}
ab.__index = ab
function ab.New(ac)
	return setmetatable(
		{ Root = ac.Root, ActiveTabIndicator = ac.ActiveTabIndicator, Conn = nil, LastY = 0, Size = 16 },
		ab
	)
end
function ab.Stop(ac)
	if ac.Conn then
		ac.Conn:Disconnect()
		ac.Conn = nil
	end
end
function ab.Start(ac)
	if ac.Conn then
		return
	end
	ac.LastY = 0
	local ad = ac.ActiveTabIndicator
	local ae = aa.RenderStepped:Connect(function(ae)
		if not ad.Parent then
			ac:Stop()
			return
		end
		local af, ag = ad.Position.Y.Offset, 5
		if ac.LastY ~= 0 then
			local ah = math.max(ae, 4.166666666666667E-3)
			ag = math.abs(af - ac.LastY) / ah
		end
		ac.LastY = af
		local ah = math.clamp(ag * 0.03, 0, 24)
		local ai = 16 + ah
		ac.Size = ac.Size + (ai - ac.Size) * math.clamp(ae * 22, 0, 1)
		ad.Size = UDim2.fromOffset(4, ac.Size)
		if ag < 5 and math.abs(ac.Size - 16) < 0.5 then
			ac.Size = 16
			ad.Size = UDim2.fromOffset(4, 16)
			ac:Stop()
		end
	end)
	ac.Conn = ae
end
return ab
end
a["Sidebar/Metrics"]=function()
local aa = {
	SHELL_X = 8,
	SHELL_Y = 9,
	COMPACT_WIDTH = 50,
	EXPANDED_WIDTH = 184,
	CONTENT_GAP = 2,
	HEADER_HEIGHT = 52,
	IDENTITY_SIZE = 32,
	IDENTITY_TOP = 10,
	BRAND_LABEL_LEFT = 50,
	BRAND_FONT_SIZE = 13,
	METADATA_FONT_SIZE = 10,
	ITEM_SIZE = 32,
	ITEM_LEFT = 9,
	ITEM_RIGHT = 9,
	ITEM_GAP = 8,
	ITEM_FIRST_TOP = 64,
	ICON_SIZE = 16,
	LABEL_LEFT = 46,
	LABEL_FONT_SIZE = 13,
	INDICATOR_WIDTH = 4,
	INDICATOR_HEIGHT = 16,
	LABEL_SLIDE_X = -8,
	SPRING = table.freeze({ stiffness = 420, damping = 42, mass = 0.72 }),
}
return table.freeze(aa)
end
a["Sidebar/Reveal"]=function()
local aa, ab = game:GetService("RunService"), d("Core/Common")
local ac, ad, ae, af = ab.Spring, d("Sidebar/Metrics"), d("Sidebar/Config"), {}
af.__index = af
local ag = 0.18
function af.New(ah)
	local ai = ae.ResolveConfig(ah.Sidebar)
	local aj = ai.DefaultExpanded
	local ak = ae.ResolveEffective(aj, ai.Expandable, ah.Responsive.Tier)
	local al = ae.WidthFor(ak)
	local am = setmetatable(
		{
			Navigation = ah.Navigation,
			ContentRoot = ah.ContentRoot,
			Responsive = ah.Responsive,
			Resolved = ai,
			RequestedExpanded = aj,
			EffectiveExpanded = ak,
			Width = ac.new(al, ad.SPRING),
			Reveal = ak and 1 or 0,
			RevealStart = ak and 1 or 0,
			RevealTarget = ak and 1 or 0,
			RevealElapsed = ag,
			FrameConnection = nil,
			ResponsiveDisconnect = nil,
			Destroyed = false,
		},
		af
	)
	am:ApplyWidth(al)
	am.Navigation:SetExpandedTarget(ak, false)
	am.ResponsiveDisconnect = ah.Responsive.OnChanged(function()
		am:RefreshEffective(true)
	end)
	return am
end
function af.ApplyWidth(ah, ai)
	local aj = ae.ProgressFromWidth(ai)
	ah.Navigation:SetExpansionProgress(aj, ai, ah.Reveal)
	ah.ContentRoot.Size = UDim2.new(1, -ae.ContentInsetFromWidth(ai), 1, 0)
end
function af.SetRevealTarget(ah, ai, aj)
	local ak = ai and 1 or 0
	if not aj then
		ah.Reveal = ak
		ah.RevealStart = ak
		ah.RevealTarget = ak
		ah.RevealElapsed = ag
		return
	end
	ah.RevealStart = ah.Reveal
	ah.RevealTarget = ak
	ah.RevealElapsed = 0
end
function af.StepReveal(ah, ai)
	if ah.RevealElapsed >= ag then
		ah.Reveal = ah.RevealTarget
		return true
	end
	ah.RevealElapsed = math.min(ah.RevealElapsed + math.max(ai, 0), ag)
	local aj = ah.RevealElapsed / ag
	local ak = 1 - (1 - aj) ^ 2
	ah.Reveal = ah.RevealStart + (ah.RevealTarget - ah.RevealStart) * ak
	return ah.RevealElapsed >= ag
end
function af.StopLoop(ah)
	if ah.FrameConnection then
		ah.FrameConnection:Disconnect()
		ah.FrameConnection = nil
	end
end
function af.StartLoop(ah)
	if ah.Destroyed or ah.FrameConnection then
		return
	end
	ah.FrameConnection = aa.RenderStepped:Connect(function(ai)
		if ah.Destroyed or not ah.Navigation.Root.Parent then
			ah:StopLoop()
			return
		end
		local aj, ak = ah.Width:Step(ai)
		local al = ah:StepReveal(ai)
		ah:ApplyWidth(aj)
		if ak and al then
			ah:StopLoop()
		end
	end)
end
function af.RefreshEffective(ah, ai)
	if ah.Destroyed then
		return false
	end
	local aj = ae.ResolveEffective(ah.RequestedExpanded, ah.Resolved.Expandable, ah.Responsive.Tier)
	local ak = aj ~= ah.EffectiveExpanded
	if not ak then
		return aj
	end
	ah.EffectiveExpanded = aj
	ah.Navigation:SetExpandedTarget(aj, ai)
	ah:SetRevealTarget(aj, ai)
	local al = ae.WidthFor(aj)
	if ai then
		ah.Width:SetTarget(al)
		ah:StartLoop()
	else
		ah:StopLoop()
		ah.Width:Set(al)
		ah:ApplyWidth(al)
	end
	return aj
end
function af.SetExpanded(ah, ai, aj)
	if ah.Destroyed or not ah.Resolved.Expandable then
		return false
	end
	ah.RequestedExpanded = ai == true
	return ah:RefreshEffective(aj ~= false)
end
function af.Toggle(ah, ai)
	return ah:SetExpanded(not ah.RequestedExpanded, ai)
end
function af.IsExpanded(ah)
	return not ah.Destroyed and ah.EffectiveExpanded
end
function af.Destroy(ah)
	if ah.Destroyed then
		return
	end
	ah.Destroyed = true
	ah:StopLoop()
	if ah.ResponsiveDisconnect then
		ah.ResponsiveDisconnect()
		ah.ResponsiveDisconnect = nil
	end
end
return af
end
a["Sidebar/Sidebar"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag, ah, ai, aj = aa.Creator, aa.Animator, aa.AnimTokens, aa.SignalManager, aa.WindowDrag, d("Sidebar/Button"), d("Sidebar/Metrics"), d("Sidebar/Indicator"), d("Sidebar/View")
local ak, al, am, an, ao = TweenInfo.new(0.35, ac.Style.Exponential, ac.Dir.Out), TweenInfo.new(0.4, ac.Style.Exponential, ac.Dir.Out), ad.Preset.Fade, {}, function(ak, al, am)
	local an = math.clamp((am-ak)/(al-ak), 0, 1)
	return an*an*(3-2*an)
end function an.New(ap)
	local aq, ar, as = ap.Expandable ~= false, false
	local at, e, f, g, h, i, j, k, l, m = aj.Build{
		Parent = ap.Parent,
		Title = ap.Title or'',
		Subtitle = ap.Subtitle,
		Expandable = aq,
		OnExpandRequested = function()
			if as and not as:IsExpanded()and not af.ShouldSuppressClick()and ap.OnToggleRequested then
				ap.OnToggleRequested(true)
			end
		end,
		OnCollapseRequested = function()
			if as and as:IsExpanded()and not af.ShouldSuppressClick()and ap.OnToggleRequested then
				ap.OnToggleRequested(false)
			end
		end
	}, ae.CreateScope(), {}, 0, 0, 0, 0, 0, {
		Inactive = Color3.fromRGB(240, 240, 240),
		CompactActive = Color3.new(1, 1, 1),
		ExpandedActive = Color3.fromRGB(255, 185, 255),
		InactiveTransparency = 0.6,
		ActiveTransparency = 0
	}
	local n, o = function()
		l.Inactive = ab.GetThemeProperty'SidebarIcon'or Color3.fromRGB(240, 240, 240)
		l.CompactActive = ab.GetThemeProperty'SidebarIconActive'or ab.GetThemeProperty'Text'or Color3.new(1, 1, 1)
		l.ExpandedActive = ab.GetThemeProperty'SidebarActiveIndicator'or ab.GetThemeProperty'Accent'or Color3.fromRGB(255, 185, 255)
		local n = ab.GetThemeProperty'SidebarIconTransparency'
		l.InactiveTransparency = (type(n) == 'number'and{n}or{0.6})[1]
		local o = ab.GetThemeProperty'SidebarIconActiveTransparency'
		l.ActiveTransparency = (type(o) == 'number'and{o}or{0})[1]
	end, function(n, o, p)
		local q = l.CompactActive:Lerp(l.ExpandedActive, i)
		local r, s = (o and{q}or{(l.Inactive)})[1], (o and{(l.ActiveTransparency)}or{(l.InactiveTransparency)})[1]
		local t, u = {ImageColor3 = r, ImageTransparency = s}, {TextColor3 = l.Inactive}
		if p then
			ac.Tween(n.Icon, t, am)
			ac.Tween(n.Label, u, am)
		else
			ac.Set(n.Icon, t)
			ac.Set(n.Label, u)
		end
		n:SetActive(o, k>0.001, p)
	end
	local p, q = function(p)
		for q, r in f do
			o(r, q == g, p)
		end
	end, ai.New{Root = at.Root, ActiveTabIndicator = at.ActiveTabIndicator}
	as = {
		Root = at.Root,
		ActiveTabBackground = at.ActiveTabBackground,
		ActiveTabIndicator = at.ActiveTabIndicator,
		TabHolder = at.TabHolder,
		LogoButton = at.LogoButton,
		CollapseButton = at.CollapseButton,
		Destroyed = false
	}function as.SetExpansionProgress(r, s, t, u)
		local v = math.clamp(s, 0, 1)
		i = v
		local w = math.clamp((u == nil and{v}or{u})[1], 0, 1)
		j = w*ao(0.43, 0.86, v)
		k = ao(0.3, 0.72, v)
		at.Root.Size = UDim2.new(0, t, 1, -(ah.SHELL_Y*2))
		local y = math.max(ah.ITEM_SIZE, t-ah.ITEM_LEFT-ah.ITEM_RIGHT)
		for z, A in f do
			A:SetWidth(y)
			A:SetExpansionProgress(j, k)
			if z == g then
				ac.Set(A.Icon, {
					ImageColor3 = l.CompactActive:Lerp(l.ExpandedActive, v),
					ImageTransparency = l.ActiveTransparency
				})
			end
		end
		ac.Set(at.IdentityTitle, {
			Position = UDim2.fromOffset(ah.BRAND_LABEL_LEFT+ah.LABEL_SLIDE_X*(1-j), 11),
			TextTransparency = 1-j
		})
		ac.Set(at.IdentitySubtitle, {
			Position = UDim2.fromOffset(ah.BRAND_LABEL_LEFT+ah.LABEL_SLIDE_X*(1-j), 27),
			TextTransparency = 1-j*0.66
		})
		ac.Set(at.CollapseButton, {ImageTransparency = 1-j*0.64})
		ac.Set(at.ActiveTabBackground, {BackgroundTransparency = k})
	end function as.SetExpandedTarget(r, s, t)
		ar = aq and s == true
		for u, v in f do
			v:SetExpanded(ar, t ~= false)
		end
		p(t ~= false)
	end function as.IsExpanded(r)
		return ar
	end function as.SetActiveTab(r, s)
		if r.Destroyed or s == g or s<1 or s>h then
			return
		end
		local t = f[s]
		local u = function()
			if r.Destroyed or not t.Root.Parent then
				return
			end
			local u, v = t.Root.AbsolutePosition.Y+t.Root.AbsoluteSize.Y/2, ((at.ActiveTabBackground.Parent)).AbsolutePosition.Y
			local w = u-v ac.Tween(at.ActiveTabBackground, {Position = UDim2.fromOffset(ah.ITEM_LEFT, w-at.ActiveTabBackground.AbsoluteSize.Y/2)}, ak)
			ac.Tween(at.ActiveTabIndicator, {Position = UDim2.fromOffset(0, w)}, al)
		end
		if t.Root.AbsolutePosition.Y == 0 then
			task.defer(u)
		else
			u()
		end
		q:Start()
		local v = g g = s
		if v>0 and f[v]then
			o(f[v], false, true)
		end
		o(t, true, true)
		if t.Callback then
			t.Callback()
		end
	end function as.AddTab(r, s, t, u)
		h = h+1
		local v = h
		local w = ag.New{
			Image = s,
			Title = (u and u.Title and{(u.Title)}or{''})[1],
			LayoutOrder = (u and u.LayoutOrder and{(u.LayoutOrder)}or{v})[1],
			Parent = at.TabHolder
		}
		w.Callback = t w:SetExpanded(ar, false)
		w:SetExpansionProgress(j, k)
		w:SetWidth(((ar and{(ah.EXPANDED_WIDTH)}or{(ah.COMPACT_WIDTH)})[1])-ah.ITEM_LEFT-ah.ITEM_RIGHT)
		o(w, false, false)
		e:Connect(w.Root.Activated, function()
			if not af.ShouldSuppressClick()then
				as:SetActiveTab(v)
			end
		end)
		table.insert(f, w)
		local y = (u and u.AutoSelect ~= nil and{(u.AutoSelect)}or{true})[1]
		if y and g == 0 then
			as:SetActiveTab(v)
		end
		return w
	end function as.Destroy(r)
		if r.Destroyed then
			return
		end
		r.Destroyed = true
		if m then
			m()
			m = nil
		end
		q:Stop()
		e:Destroy()
		for s, t in f do
			t:Destroy()
		end
		at.Root:Destroy()
	end
	m = ab.OnThemeChanged(function()
		n()
		p(false)
	end)
	n()
	as:SetExpansionProgress(0, ah.COMPACT_WIDTH)
	as:SetExpandedTarget(false, false)
	return as
end
return an
end
a["Sidebar/Tooltips"]=function()
local aa, ab, ac = d("UI/Tooltip"), d("Localization/Localization"), {}
function ac.New(ad)
	local ae, af, ag = {}, false
	local ah = function()
		for ah, ai in ae do
			ai()
		end
		table.clear(ae)
	end
	local ai = function()
		ah()
		if af or not ad.Expandable then
			return
		end
		local ai, aj = ad.Navigation, aa.Get(ad.Parent)
		table.insert(
			ae,
			aj:Attach(ai.LogoButton, ab.t("sidebar.expand.tooltip"), nil, function()
				return not ai:IsExpanded()
			end)
		)
		table.insert(
			ae,
			aj:Attach(ai.CollapseButton, ab.t("sidebar.collapse.tooltip"), nil, function()
				return ai:IsExpanded()
			end)
		)
	end
	ai()
	ag = ab.OnChanged(ai)
	return {
		Destroy = function()
			if af then
				return
			end
			af = true
			if ag then
				ag()
				ag = nil
			end
			ah()
		end,
	}
end
return table.freeze(ac)
end
a["Sidebar/View"]=function()
local aa = d("Core/Common")
local ab, ac = aa.Creator, d("Sidebar/Metrics")
local ad, ae, af, ag, ah, ai =
	ab.New,
	"rbxassetid://78362564258186",
	"http://www.roblox.com/asset/?id=87637008590790",
	"rbxassetid://10709790948",
	"rbxasset://fonts/families/SourceSansPro.json",
	{}
function ai.Build(aj)
	local ak, al, am, an, ao, ap, aq
	local ar = ad(
		"Frame",
		{
			AnchorPoint = Vector2.new(0, 0.5),
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.new(0, ac.SHELL_X, 0.5, 0),
			Size = UDim2.new(0, ac.COMPACT_WIDTH, 1, -(ac.SHELL_Y * 2)),
			ZIndex = 3,
			[ab.ThemeTag] = { BackgroundColor3 = "SidebarBg" },
		},
		{
			ad(
				"UICorner",
				{
					CornerRadius = ab.GetThemeProperty("CornerRadiusSidebar") or UDim.new(0, 16),
					[ab.ThemeTag] = { CornerRadius = "CornerRadiusSidebar" },
				}
			),
			ad(
				"Frame",
				{ BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2 },
				{
					ad(
						"TextButton",
						{
							AutoButtonColor = false,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromOffset(ac.ITEM_LEFT, ac.IDENTITY_TOP),
							Size = UDim2.fromOffset(ac.IDENTITY_SIZE, ac.IDENTITY_SIZE),
							Text = "",
							ZIndex = 3,
							Active = aj.Expandable,
							[ab.Ref] = function(ar)
								ap = ar
							end,
							[ab.Activated] = function()
								if aj.Expandable and aj.OnExpandRequested then
									aj.OnExpandRequested()
								end
							end,
						},
						{
							ad(
								"ImageLabel",
								{
									Active = false,
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Image = ae,
									Position = UDim2.fromScale(0.5, 0.5),
									ScaleType = Enum.ScaleType.Fit,
									Size = UDim2.fromScale(1, 1),
									ZIndex = 2,
									ImageColor3 = ab.GetThemeProperty("LogoColor")
										or ab.GetThemeProperty("Accent")
										or Color3.fromRGB(255, 185, 255),
									[ab.ThemeTag] = { ImageColor3 = "LogoColor" },
								}
							),
							ad(
								"ImageLabel",
								{
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Image = af,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.new(1, 20, 1, 20),
									ZIndex = 0,
									[ab.ThemeTag] = {
										ImageColor3 = "AccentGlow",
										ImageTransparency = "AccentGlowTransparency",
									},
								}
							),
						}
					),
					ad("TextLabel", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						FontFace = Font.new(
							ab.GetThemeProperty("FontFamily") or ah,
							Enum.FontWeight.SemiBold,
							Enum.FontStyle.Normal
						),
						Position = UDim2.fromOffset(ac.BRAND_LABEL_LEFT + ac.LABEL_SLIDE_X, 11),
						Size = UDim2.new(1, -(ac.BRAND_LABEL_LEFT + 38), 0, 16),
						Text = aj.Title,
						TextColor3 = ab.GetThemeProperty("Text") or Color3.new(1, 1, 1),
						TextSize = ac.BRAND_FONT_SIZE,
						TextTransparency = 1,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 3,
						[ab.Ref] = function(ar)
							an = ar
						end,
						[ab.ThemeTag] = { TextColor3 = "Text" },
					}),
					ad("TextLabel", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						FontFace = Font.new(
							ab.GetThemeProperty("FontFamily") or ah,
							Enum.FontWeight.Medium,
							Enum.FontStyle.Normal
						),
						Position = UDim2.fromOffset(ac.BRAND_LABEL_LEFT + ac.LABEL_SLIDE_X, 27),
						Size = UDim2.new(1, -(ac.BRAND_LABEL_LEFT + 38), 0, 14),
						Text = aj.Subtitle or "",
						TextColor3 = ab.GetThemeProperty("SidebarIcon") or Color3.fromRGB(190, 190, 190),
						TextSize = ac.METADATA_FONT_SIZE,
						TextTransparency = 1,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						Visible = aj.Subtitle ~= nil,
						ZIndex = 3,
						[ab.Ref] = function(ar)
							ao = ar
						end,
						[ab.ThemeTag] = { TextColor3 = "SidebarIcon" },
					}),
					ad("ImageButton", {
						Active = aj.Expandable,
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Image = ag,
						ImageColor3 = ab.GetThemeProperty("SidebarIcon") or Color3.fromRGB(220, 220, 220),
						ImageTransparency = 1,
						Position = UDim2.fromOffset(ac.EXPANDED_WIDTH - 33, 14),
						Rotation = 90,
						Size = UDim2.fromOffset(24, 24),
						ZIndex = 4,
						[ab.Ref] = function(ar)
							aq = ar
						end,
						[ab.Activated] = function()
							if aj.Expandable and aj.OnCollapseRequested then
								aj.OnCollapseRequested()
							end
						end,
						[ab.ThemeTag] = { ImageColor3 = "SidebarIcon" },
					}),
					ad(
						"Frame",
						{
							BackgroundColor3 = Color3.new(1, 1, 1),
							BackgroundTransparency = 0.9,
							BorderSizePixel = 0,
							Position = UDim2.fromOffset(0, ac.HEADER_HEIGHT - 1),
							Size = UDim2.new(1, 0, 0, 1),
							ZIndex = 1,
							[ab.ThemeTag] = {
								BackgroundColor3 = "StrokeColor",
								BackgroundTransparency = "StrokeTransparency",
							},
						}
					),
					ad(
						"Frame",
						{
							Active = true,
							BackgroundColor3 = Color3.new(1, 1, 1),
							BorderSizePixel = 0,
							Position = UDim2.fromOffset(ac.ITEM_LEFT, ac.ITEM_FIRST_TOP),
							Size = UDim2.fromOffset(ac.ITEM_SIZE, ac.ITEM_SIZE),
							ZIndex = 0,
							[ab.Ref] = function(ar)
								ak = ar
							end,
						},
						{
							ad(
								"UICorner",
								{
									CornerRadius = ab.GetThemeProperty("CornerRadiusSidebar") or UDim.new(0, 12),
									[ab.ThemeTag] = { CornerRadius = "CornerRadiusSidebar" },
								}
							),
							ad("UIGradient", { Rotation = 45, [ab.ThemeTag] = { Color = "AccentGradient" } }),
						}
					),
					ad(
						"Frame",
						{
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromOffset(0, ac.ITEM_FIRST_TOP + ac.ITEM_SIZE / 2),
							Size = UDim2.fromOffset(ac.INDICATOR_WIDTH, ac.INDICATOR_HEIGHT),
							ZIndex = 3,
							[ab.Ref] = function(ar)
								al = ar
							end,
						},
						{
							ad(
								"Frame",
								{
									BorderSizePixel = 0,
									Position = UDim2.fromOffset(-1, 0),
									Size = UDim2.fromScale(1, 1),
									[ab.ThemeTag] = { BackgroundColor3 = "SidebarActiveIndicator" },
								},
								{
									ad(
										"UICorner",
										{
											CornerRadius = ab.GetThemeProperty("CornerRadiusIndicator")
												or UDim.new(0, 2),
											[ab.ThemeTag] = { CornerRadius = "CornerRadiusIndicator" },
										}
									),
								}
							),
						}
					),
					ad(
						"ScrollingFrame",
						{
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							CanvasSize = UDim2.fromOffset(0, 0),
							Position = UDim2.fromOffset(0, ac.ITEM_FIRST_TOP),
							ScrollBarImageTransparency = 1,
							ScrollBarThickness = 0,
							ScrollingDirection = Enum.ScrollingDirection.Y,
							Size = UDim2.new(1, 0, 1, -ac.ITEM_FIRST_TOP),
							ZIndex = 2,
							[ab.Ref] = function(ar)
								am = ar
							end,
						},
						{
							ad(
								"UIListLayout",
								{ Padding = UDim.new(0, ac.ITEM_GAP), SortOrder = Enum.SortOrder.LayoutOrder }
							),
							ad(
								"UIPadding",
								{ PaddingLeft = UDim.new(0, ac.ITEM_LEFT), PaddingRight = UDim.new(0, ac.ITEM_RIGHT) }
							),
						}
					),
				}
			),
			ad("UIStroke", { [ab.ThemeTag] = { Color = "StrokeColor", Transparency = "StrokeTransparency" } }),
		}
	)
	ar.Parent = aj.Parent
	return {
		Root = ar,
		ActiveTabBackground = ak,
		ActiveTabIndicator = al,
		TabHolder = am,
		IdentityTitle = an,
		IdentitySubtitle = ao,
		LogoButton = ap,
		CollapseButton = aq,
	}
end
return table.freeze(ai)
end
a["Snapshot/Snapshot"]=function()
local aa, ab, ac, ad = d("Core/Logger"), d("Core/ThreadIdentity"), d("Elements/Schema"), {}
ad.__index = ad
function ad.New(ae, af)
	local ag = setmetatable({ Registry = ae, ApplyCallbacks = af == true }, ad)
	return ag
end
function ad.SetApplyCallbacks(ae, af)
	ae.ApplyCallbacks = af == true
end
function ad.GetApplyCallbacks(ae)
	return ae.ApplyCallbacks
end
local ae, af =
	function(ae)
		return ae:sub(1, 2) == "__"
	end, function(ae)
		if type(ae) == "string" then
			return ae
		end
		if type(ae) == "table" then
			if type(ae.en) == "string" then
				return ae.en
			end
			local af = {}
			for ag in pairs(ae) do
				table.insert(af, ag)
			end
			table.sort(af)
			if af[1] then
				return tostring(ae[af[1]])
			end
		end
		return ""
	end
function ad.ExportSchema(ag)
	local ah, ai, aj = {}, {}, {}
	for ak, al in pairs(ag.Registry) do
		if type(ak) == "string" and not ae(ak) and al then
			local am = al._SnapshotMeta
			local an = (type(am) == "table" and { am.Field } or { nil })[1]
			if type(an) == "table" then
				local ao = {}
				for ap, aq in pairs(an) do
					ao[ap] = aq
				end
				local ap = ac.DescribeLabels(am.TitleSource, am.DescSource)
				if ap.title ~= nil then
					ao["x-title"] = ap.title
				end
				if ap.description ~= nil then
					ao["x-description"] = ap.description
				end
				if am.Dynamic == true then
					ao["x-dynamic"] = true
				end
				local aq = (type(am) == "table" and { am.Group } or { nil })[1]
				if type(aq) == "table" then
					local ar, as = ac.DescribeGroupTitle(aq.TabSource), ac.DescribeGroupTitle(aq.SectionSource)
					local at = af(ar) .. "/" .. af(as)
					if at ~= "/" then
						ao["x-group"] = at
						if not aj[at] then
							aj[at] = {
								entry = { key = at, tab = ar, section = as },
								order = (type(aq.SectionOrder) == "number" and { aq.SectionOrder } or { 0 })[1],
							}
						end
					end
					if type(aq.ElementOrder) == "number" then
						ao["x-order"] = aq.ElementOrder
					end
				end
				ah[ak] = ao
				table.insert(ai, ak)
			end
		end
	end
	table.sort(ai)
	local ak = {}
	for al, am in pairs(aj) do
		table.insert(ak, am)
	end
	table.sort(ak, function(al, am)
		if al.order == am.order then
			return tostring(al.entry.key) < tostring(am.entry.key)
		end
		return al.order < am.order
	end)
	local al = {}
	for am, an in ak do
		table.insert(al, an.entry)
	end
	local am = {
		["$schema"] = "http://json-schema.org/draft-07/schema#",
		type = "object",
		additionalProperties = false,
		properties = ah,
		required = ai,
	}
	if #al > 0 then
		am["x-seahub-groups"] = al
	end
	return am
end
local ag = function(ag)
	local ah = typeof(ag)
	if ah == "boolean" then
		return ag and "On" or "Off"
	end
	if ah == "number" or ah == "string" then
		return tostring(ag)
	end
	if type(ag) == "table" then
		if type(ag.R) == "number" and type(ag.G) == "number" and type(ag.B) == "number" then
			return ("rgb(%d, %d, %d)"):format(math.round(ag.R * 255), math.round(ag.G * 255), math.round(ag.B * 255))
		end
		local ai = {}
		for aj = 1, math.min(#ag, 3) do
			table.insert(ai, tostring(ag[aj]))
		end
		if #ag > 3 then
			table.insert(ai, "...")
		end
		return (#ai > 0 and { (table.concat(ai, ", ")) } or { "Table" })[1]
	end
	return ah
end
function ad.Snapshot(ah, ai)
	local aj = {}
	for ak, al in pairs(ah.Registry) do
		if al and al.Pack and type(ak) == "string" and not ae(ak) then
			local am, an, ao = al._SnapshotMeta, pcall(function()
				return al:Pack()
			end)
			if an then
				aj[ak] = {
					Type = al.Type or "Unknown",
					Title = (type(am) == "table" and { am.Title } or { nil })[1],
					Desc = (type(am) == "table" and { am.Desc } or { nil })[1],
					Value = ao,
					ValueText = ag(ao),
				}
			else
				aa.Warn(("Snapshot pack skipped for '%s': %s"):format(ak, tostring(ao)))
			end
		end
	end
	local ak = os.time()
	return { Version = 2, Kind = "SeaHubSnapshot", Name = ai, CreatedAt = ak, UpdatedAt = ak, Entries = aj }
end
function ad.Apply(ah, ai, aj)
	if type(ai) ~= "table" then
		return
	end
	local ak = ai.Entries
	if type(ak) ~= "table" then
		return
	end
	local al = ah.ApplyCallbacks
	if type(aj) == "table" and aj.Callbacks ~= nil then
		al = aj.Callbacks == true
	end
	local am, an, ao = { Callbacks = al }, ab.Elevate(), {}
	for ap, aq in pairs(ak) do
		if type(ap) == "string" then
			local ar = ah.Registry[ap]
			if ar and ar.Unpack then
				local as = (type(aq) == "table" and { aq.Value } or { aq })[1]
				local at, e = pcall(function()
					ar:Unpack(as, am)
				end)
				if not at then
					table.insert(ao, { Key = ap, Error = tostring(e) })
					aa.Warn(("Snapshot unpack skipped for '%s': %s"):format(ap, tostring(e)))
				end
			end
		end
	end
	an()
	return ao
end
return ad
end
a["Theme/BuiltInThemes"]=function()
return { Default = d("Theme/DefaultTheme"), ShadcnDark = d("Theme/ShadcnDarkTheme") }
end
a["Theme/DefaultTheme"]=function()
local aa = {
	Name = "Default",
	Accent = Color3.fromRGB(255, 185, 255),
	AccentForeground = Color3.fromRGB(20, 24, 6),
	AccentStroke = Color3.fromRGB(160, 123, 160),
	AccentStrokeTransparency = 1,
	AccentDark = Color3.fromRGB(160, 123, 160),
	AccentGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 185, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 123, 160)),
	}),
	AccentGradientRotation = 45,
	AccentGlow = Color3.fromRGB(255, 185, 255),
	AccentGlowTransparency = 0.4,
	LogoSyncAccent = true,
	LogoColorBase = Color3.fromRGB(240, 240, 240),
	LogoColor = Color3.fromRGB(255, 185, 255),
	BackgroundMain = Color3.fromRGB(20, 20, 20),
	BackgroundMainTransparency = 0.2,
	BackgroundSurface = Color3.fromRGB(22, 22, 22),
	BackgroundElevated = Color3.fromRGB(22, 24, 28),
	DialogOverlayColor = Color3.fromRGB(0, 0, 0),
	DialogOverlayTransparency = 0.35,
	DialogSurface = Color3.fromRGB(22, 22, 22),
	DialogBorder = Color3.fromRGB(240, 240, 240),
	DialogHeaderText = Color3.fromRGB(240, 240, 240),
	DialogContentTransparency = 0.18,
	DialogCloseIcon = Color3.fromRGB(240, 240, 240),
	DialogCloseIconHover = Color3.fromRGB(255, 185, 255),
	DialogActionBg = Color3.fromRGB(240, 240, 240),
	DialogActionBgTransparency = 0,
	DialogActionText = Color3.fromRGB(0, 0, 0),
	DialogActionGap = UDim.new(0, 8),
	DialogActionDefaultBg = Color3.fromRGB(240, 240, 240),
	DialogActionDefaultBgTransparency = 0,
	DialogActionDefaultText = Color3.fromRGB(0, 0, 0),
	DialogActionDefaultStroke = Color3.fromRGB(240, 240, 240),
	DialogActionDefaultStrokeTransparency = 1,
	DialogActionSecondaryBg = Color3.fromRGB(240, 240, 240),
	DialogActionSecondaryBgTransparency = 0.9,
	DialogActionSecondaryText = Color3.fromRGB(240, 240, 240),
	DialogActionSecondaryStroke = Color3.fromRGB(240, 240, 240),
	DialogActionSecondaryStrokeTransparency = 0.92,
	DialogActionGhostBg = Color3.fromRGB(240, 240, 240),
	DialogActionGhostBgTransparency = 1,
	DialogActionGhostText = Color3.fromRGB(240, 240, 240),
	DialogActionGhostStroke = Color3.fromRGB(240, 240, 240),
	DialogActionGhostStrokeTransparency = 1,
	DialogActionOutlineBg = Color3.fromRGB(240, 240, 240),
	DialogActionOutlineBgTransparency = 1,
	DialogActionOutlineText = Color3.fromRGB(240, 240, 240),
	DialogActionOutlineStroke = Color3.fromRGB(240, 240, 240),
	DialogActionOutlineStrokeTransparency = 0.86,
	DialogActionDestructiveBg = Color3.fromRGB(127, 29, 29),
	DialogActionDestructiveBgTransparency = 0.2,
	DialogActionDestructiveText = Color3.fromRGB(255, 220, 220),
	DialogActionDestructiveStroke = Color3.fromRGB(127, 29, 29),
	DialogActionDestructiveStrokeTransparency = 0.35,
	NoiseTransparency = 0.85,
	Text = Color3.fromRGB(240, 240, 240),
	TextInput = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(160, 160, 160),
	TextPlaceholder = Color3.fromRGB(140, 140, 140),
	TextDestructive = Color3.fromRGB(248, 113, 113),
	TextWarning = Color3.fromRGB(251, 191, 36),
	TextDescriptionTransparency = 0.4,
	NotifierContentTransparency = 0.18,
	FontFamily = "rbxassetid://12187365364",
	FontFamilyFallback = "rbxasset://fonts/families/SourceSansPro.json",
	TextSizeBody = 16,
	TextSizeSmall = 15,
	TextSizeCaption = 14,
	TextSizeCategory = 12,
	TextSizeTab = 17,
	FontWeightNormal = Enum.FontWeight.Regular,
	FontWeightMedium = Enum.FontWeight.Medium,
	FontWeightSemiBold = Enum.FontWeight.SemiBold,
	StrokeColor = Color3.fromRGB(240, 240, 240),
	StrokeTransparency = 0.9,
	StrokeThickness = 1,
	StrokeThicknessToggle = 1.25,
	DragSkeletonStrokeTransparency = 0.78,
	DragSkeletonStrokeThickness = 1.25,
	DividerColor = Color3.fromRGB(70, 70, 70),
	DividerTransparency = 0.7,
	ToggleTrackInactive = Color3.fromRGB(140, 140, 140),
	ToggleTrackInactiveTransparency = 0.9,
	ToggleTrackStroke = Color3.fromRGB(240, 240, 240),
	ToggleKnob = Color3.fromRGB(240, 240, 240),
	VariantOutlineBg = Color3.fromRGB(140, 140, 140),
	VariantOutlineBgTransparency = 0.9,
	VariantOutlineText = Color3.fromRGB(240, 240, 240),
	VariantOutlineStroke = Color3.fromRGB(240, 240, 240),
	VariantOutlineStrokeTransparency = 0.9,
	VariantDefaultBg = Color3.fromRGB(255, 255, 255),
	VariantDefaultText = Color3.fromRGB(0, 0, 0),
	VariantDefaultStroke = Color3.fromRGB(240, 240, 240),
	VariantDefaultStrokeTransparency = 0.9,
	VariantDefaultHoverFillTransparency = 0.14,
	VariantDestructiveBg = Color3.fromRGB(127, 29, 29),
	VariantDestructiveBgTransparency = 0.4,
	VariantDestructiveText = Color3.fromRGB(240, 78, 78),
	VariantDestructiveStroke = Color3.fromRGB(127, 29, 29),
	VariantDestructiveStrokeTransparency = 0.4,
	VariantWarningBg = Color3.fromRGB(120, 53, 15),
	VariantWarningBgTransparency = 0.4,
	VariantWarningText = Color3.fromRGB(251, 191, 36),
	VariantWarningStroke = Color3.fromRGB(120, 53, 15),
	VariantWarningStrokeTransparency = 0.4,
	VariantSuccessBg = Color3.fromRGB(20, 83, 45),
	VariantSuccessBgTransparency = 0.4,
	VariantSuccessText = Color3.fromRGB(74, 222, 128),
	VariantSuccessStroke = Color3.fromRGB(20, 83, 45),
	VariantSuccessStrokeTransparency = 0.4,
	VariantInfoBg = Color3.fromRGB(30, 58, 138),
	VariantInfoBgTransparency = 0.4,
	VariantInfoText = Color3.fromRGB(96, 165, 250),
	VariantInfoStroke = Color3.fromRGB(30, 58, 138),
	VariantInfoStrokeTransparency = 0.4,
	VariantMutedBg = Color3.fromRGB(64, 64, 64),
	VariantMutedBgTransparency = 0.5,
	VariantMutedText = Color3.fromRGB(163, 163, 163),
	VariantMutedStroke = Color3.fromRGB(64, 64, 64),
	VariantMutedStrokeTransparency = 0.5,
	TextAccent = Color3.fromRGB(255, 185, 255),
	TextSuccess = Color3.fromRGB(74, 222, 128),
	TextInfo = Color3.fromRGB(96, 165, 250),
	TextMuted = Color3.fromRGB(140, 140, 140),
	ButtonOutlineBg = Color3.fromRGB(140, 140, 140),
	ButtonOutlineBgTransparency = 0.9,
	ButtonOutlineStroke = Color3.fromRGB(240, 240, 240),
	ButtonOutlineStrokeTransparency = 0.9,
	ButtonDefaultBg = Color3.fromRGB(255, 255, 255),
	ButtonDefaultText = Color3.fromRGB(0, 0, 0),
	ButtonDefaultStroke = Color3.fromRGB(240, 240, 240),
	ButtonDefaultStrokeTransparency = 0.9,
	ButtonDestructiveBg = Color3.fromRGB(127, 29, 29),
	ButtonDestructiveBgTransparency = 0.4,
	ButtonDestructiveText = Color3.fromRGB(240, 78, 78),
	ButtonWarningBg = Color3.fromRGB(120, 53, 15),
	ButtonWarningBgTransparency = 0.4,
	ButtonWarningText = Color3.fromRGB(251, 191, 36),
	ButtonIconHover = Color3.fromRGB(240, 240, 240),
	InputBg = Color3.fromRGB(140, 140, 140),
	InputBgTransparency = 0.9,
	InputStroke = Color3.fromRGB(240, 240, 240),
	InputStrokeTransparency = 0.9,
	InputText = Color3.fromRGB(255, 255, 255),
	InputPlaceholder = Color3.fromRGB(140, 140, 140),
	SliderRail = Color3.fromRGB(140, 140, 140),
	SliderRailTransparency = 0.9,
	SliderFill = Color3.fromRGB(255, 185, 255),
	SliderKnobShadow = Color3.fromRGB(22, 24, 28),
	SliderKnobShadowTransparency = 0.9,
	SliderValueBg = Color3.fromRGB(140, 140, 140),
	SliderValueBgTransparency = 0.9,
	SliderValueText = Color3.fromRGB(240, 240, 240),
	DropdownBg = Color3.fromRGB(140, 140, 140),
	DropdownBgTransparency = 0.9,
	DropdownStroke = Color3.fromRGB(240, 240, 240),
	DropdownStrokeTransparency = 0.9,
	DropdownText = Color3.fromRGB(240, 240, 240),
	SelectPopupBg = Color3.fromRGB(22, 22, 22),
	SelectPopupBgTransparency = 0,
	TabBar = Color3.fromRGB(22, 22, 22),
	TabActive = Color3.fromRGB(255, 185, 255),
	TabInactive = Color3.fromRGB(160, 160, 160),
	TabIndicator = Color3.fromRGB(255, 185, 255),
	TabIndicatorTrack = Color3.fromRGB(240, 240, 240),
	TabIndicatorTrackTransparency = 0.9,
	SidebarBg = Color3.fromRGB(22, 22, 22),
	SidebarIcon = Color3.fromRGB(240, 240, 240),
	SidebarIconTransparency = 0.6,
	SidebarIconActive = Color3.fromRGB(240, 240, 240),
	SidebarIconActiveTransparency = 0,
	SidebarActiveIndicator = Color3.fromRGB(255, 185, 255),
	SidebarActiveBackground = Color3.fromRGB(255, 255, 255),
	Element = Color3.fromRGB(130, 130, 130),
	ElementTransparency = 1,
	ShadowColor = Color3.fromRGB(0, 0, 0),
	ShadowTransparencySidebar = 0.8,
	ShadowTransparencyWindow = 0.3,
	CornerRadiusWindow = UDim.new(0, 12),
	CornerRadiusSubTabs = UDim.new(0, 16),
	CornerRadiusSidebar = UDim.new(0, 10),
	CornerRadiusTab = UDim.new(0, 6),
	CornerRadiusPill = UDim.new(0, 192),
	CornerRadiusFull = UDim.new(1, 0),
	CornerRadiusIndicator = UDim.new(0, 2),
	CornerRadiusNoise = UDim.new(0, 26),
	CornerRadiusSection = UDim.new(0, 18),
	PaddingWindow = UDim.new(0, 12),
	PaddingElement = UDim.new(0, 14),
	PaddingInput = UDim.new(0, 8),
	PaddingInputSmall = UDim.new(0, 5),
	GapSection = UDim.new(0, 16),
	GapColumns = UDim.new(0, 12),
	GapTab = UDim.new(0, 16),
	GapSidebar = UDim.new(0, 10),
	GapInline = UDim.new(0, 6),
	GapLabelContent = UDim.new(0, 4),
	GapContentPadding = UDim.new(0, 18),
	ScrollBarColor = Color3.fromRGB(0, 0, 0),
	ScrollBarTransparency = 1,
	ScrollBarThickness = 2,
	Hover = Color3.fromRGB(100, 100, 100),
	HoverTransparency = 1,
	LoaderBackground = Color3.fromRGB(255, 255, 255),
	LoaderTagline = Color3.fromRGB(76, 51, 76),
	LoaderTitleStroke = Color3.fromRGB(99, 73, 99),
	LoaderTitleStrokeTransparency = 0.2,
	LoaderProgressTrack = Color3.fromRGB(200, 212, 180),
	LoaderProgressTrackStroke = Color3.fromRGB(99, 73, 99),
	LoaderProgressTrackStrokeTransparency = 0.8,
	LoaderProgressFill = Color3.fromRGB(255, 185, 255),
	LoaderProgressFillStroke = Color3.fromRGB(99, 73, 99),
	LoaderProgressFillStrokeTransparency = 0.4,
	LoaderPadding = UDim.new(0, 16),
	FontFamilyTitle = "rbxasset://fonts/families/FredokaOne.json",
	FontFamilyTagline = "rbxasset://fonts/families/GothamSSm.json",
	TextSizeTitle = 32,
}
aa.ButtonDefaultBg = aa.VariantDefaultBg
aa.ButtonDefaultText = aa.VariantDefaultText
aa.ButtonDefaultStroke = aa.VariantDefaultStroke
aa.ButtonDefaultStrokeTransparency = aa.VariantDefaultStrokeTransparency
aa.ButtonDefaultHoverFillTransparency = aa.VariantDefaultHoverFillTransparency
aa.ButtonOutlineBg = aa.VariantOutlineBg
aa.ButtonOutlineBgTransparency = aa.VariantOutlineBgTransparency
aa.ButtonOutlineStroke = aa.VariantOutlineStroke
aa.ButtonOutlineStrokeTransparency = aa.VariantOutlineStrokeTransparency
aa.ButtonDestructiveBg = aa.VariantDestructiveBg
aa.ButtonDestructiveBgTransparency = aa.VariantDestructiveBgTransparency
aa.ButtonDestructiveText = aa.VariantDestructiveText
return aa
end
a["Theme/ShadcnDarkTheme"]=function()
local aa = {
	Name = "shadcn/ui's Dark",
	Accent = Color3.fromHex("#2563eb"),
	AccentForeground = Color3.fromHex("#fafafa"),
	AccentStroke = Color3.fromHex("#1d4ed8"),
	AccentStrokeTransparency = 1,
	AccentDark = Color3.fromHex("#1d4ed8"),
	AccentGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("#2563eb")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("#1d4ed8")),
	}),
	AccentGradientRotation = 45,
	AccentGlow = Color3.fromHex("#2563eb"),
	AccentGlowTransparency = 0.5,
	LogoSyncAccent = true,
	LogoColorBase = Color3.fromRGB(255, 185, 255),
	LogoColor = Color3.fromHex("#2563eb"),
	BackgroundMain = Color3.fromHex("#09090b"),
	BackgroundMainTransparency = 0,
	BackgroundSurface = Color3.fromHex("#0a0a0a"),
	BackgroundElevated = Color3.fromHex("#171717"),
	DialogOverlayColor = Color3.fromHex("#000000"),
	DialogOverlayTransparency = 0.45,
	DialogSurface = Color3.fromHex("#0a0a0a"),
	DialogBorder = Color3.fromHex("#262626"),
	DialogHeaderText = Color3.fromHex("#fafafa"),
	DialogContentTransparency = 0.16,
	DialogCloseIcon = Color3.fromHex("#a3a3a3"),
	DialogCloseIconHover = Color3.fromHex("#fafafa"),
	DialogActionBg = Color3.fromHex("#fafafa"),
	DialogActionBgTransparency = 0,
	DialogActionText = Color3.fromHex("#09090b"),
	DialogActionGap = UDim.new(0, 8),
	DialogActionDefaultBg = Color3.fromHex("#fafafa"),
	DialogActionDefaultBgTransparency = 0,
	DialogActionDefaultText = Color3.fromHex("#09090b"),
	DialogActionDefaultStroke = Color3.fromHex("#fafafa"),
	DialogActionDefaultStrokeTransparency = 1,
	DialogActionSecondaryBg = Color3.fromHex("#27272a"),
	DialogActionSecondaryBgTransparency = 0,
	DialogActionSecondaryText = Color3.fromHex("#fafafa"),
	DialogActionSecondaryStroke = Color3.fromHex("#27272a"),
	DialogActionSecondaryStrokeTransparency = 1,
	DialogActionGhostBg = Color3.fromHex("#fafafa"),
	DialogActionGhostBgTransparency = 1,
	DialogActionGhostText = Color3.fromHex("#fafafa"),
	DialogActionGhostStroke = Color3.fromHex("#fafafa"),
	DialogActionGhostStrokeTransparency = 1,
	DialogActionOutlineBg = Color3.fromHex("#fafafa"),
	DialogActionOutlineBgTransparency = 1,
	DialogActionOutlineText = Color3.fromHex("#fafafa"),
	DialogActionOutlineStroke = Color3.fromHex("#27272a"),
	DialogActionOutlineStrokeTransparency = 0,
	DialogActionDestructiveBg = Color3.fromHex("#7f1d1d"),
	DialogActionDestructiveBgTransparency = 0,
	DialogActionDestructiveText = Color3.fromHex("#fecaca"),
	DialogActionDestructiveStroke = Color3.fromHex("#7f1d1d"),
	DialogActionDestructiveStrokeTransparency = 1,
	NoiseTransparency = 1,
	Text = Color3.fromHex("#fafafa"),
	TextInput = Color3.fromHex("#fafafa"),
	SubText = Color3.fromHex("#a3a3a3"),
	TextPlaceholder = Color3.fromHex("#737373"),
	TextDestructive = Color3.fromHex("#ef4444"),
	TextWarning = Color3.fromHex("#eab308"),
	TextDescriptionTransparency = 0.35,
	NotifierContentTransparency = 0.16,
	FontFamily = "rbxassetid://12187365364",
	FontFamilyFallback = "rbxasset://fonts/families/SourceSansPro.json",
	TextSizeBody = 16,
	TextSizeSmall = 15,
	TextSizeCaption = 14,
	TextSizeCategory = 12,
	TextSizeTab = 17,
	FontWeightNormal = Enum.FontWeight.Regular,
	FontWeightMedium = Enum.FontWeight.Medium,
	FontWeightSemiBold = Enum.FontWeight.SemiBold,
	StrokeColor = Color3.fromHex("#262626"),
	StrokeTransparency = 0,
	StrokeThickness = 1,
	StrokeThicknessToggle = 1.25,
	DragSkeletonStrokeTransparency = 0.35,
	DragSkeletonStrokeThickness = 1.25,
	DividerColor = Color3.fromHex("#262626"),
	DividerTransparency = 0,
	ToggleTrackInactive = Color3.fromHex("#262626"),
	ToggleTrackInactiveTransparency = 0,
	ToggleTrackStroke = Color3.fromHex("#404040"),
	ToggleKnob = Color3.fromHex("#fafafa"),
	VariantOutlineBg = Color3.fromHex("#09090b"),
	VariantOutlineBgTransparency = 0,
	VariantOutlineText = Color3.fromHex("#fafafa"),
	VariantOutlineStroke = Color3.fromHex("#262626"),
	VariantOutlineStrokeTransparency = 0,
	VariantDefaultBg = Color3.fromHex("#2563eb"),
	VariantDefaultText = Color3.fromHex("#ffffff"),
	VariantDefaultStroke = Color3.fromHex("#2563eb"),
	VariantDefaultStrokeTransparency = 0,
	VariantDefaultHoverFillTransparency = 0.12,
	VariantDestructiveBg = Color3.fromHex("#7f1d1d"),
	VariantDestructiveBgTransparency = 0,
	VariantDestructiveText = Color3.fromHex("#ef4444"),
	VariantDestructiveStroke = Color3.fromHex("#7f1d1d"),
	VariantDestructiveStrokeTransparency = 0,
	VariantWarningBg = Color3.fromHex("#713f12"),
	VariantWarningBgTransparency = 0,
	VariantWarningText = Color3.fromHex("#eab308"),
	VariantWarningStroke = Color3.fromHex("#713f12"),
	VariantWarningStrokeTransparency = 0,
	ButtonOutlineBg = Color3.fromHex("#09090b"),
	ButtonOutlineBgTransparency = 0,
	ButtonOutlineStroke = Color3.fromHex("#262626"),
	ButtonOutlineStrokeTransparency = 0,
	ButtonDefaultBg = Color3.fromHex("#2563eb"),
	ButtonDefaultText = Color3.fromHex("#ffffff"),
	ButtonDefaultStroke = Color3.fromHex("#2563eb"),
	ButtonDefaultStrokeTransparency = 0,
	ButtonDestructiveBg = Color3.fromHex("#7f1d1d"),
	ButtonDestructiveBgTransparency = 0,
	ButtonDestructiveText = Color3.fromHex("#ef4444"),
	ButtonWarningBg = Color3.fromHex("#713f12"),
	ButtonWarningBgTransparency = 0,
	ButtonWarningText = Color3.fromHex("#eab308"),
	ButtonIconHover = Color3.fromHex("#fafafa"),
	InputBg = Color3.fromHex("#0a0a0a"),
	InputBgTransparency = 0,
	InputStroke = Color3.fromHex("#262626"),
	InputStrokeTransparency = 0,
	InputText = Color3.fromHex("#fafafa"),
	InputPlaceholder = Color3.fromHex("#737373"),
	SliderRail = Color3.fromHex("#262626"),
	SliderRailTransparency = 0,
	SliderFill = Color3.fromHex("#2563eb"),
	SliderKnobShadow = Color3.fromHex("#0a0a0a"),
	SliderKnobShadowTransparency = 0.5,
	SliderValueBg = Color3.fromHex("#171717"),
	SliderValueBgTransparency = 0,
	SliderValueText = Color3.fromHex("#fafafa"),
	DropdownBg = Color3.fromHex("#0a0a0a"),
	DropdownBgTransparency = 0,
	DropdownStroke = Color3.fromHex("#262626"),
	DropdownStrokeTransparency = 0,
	DropdownText = Color3.fromHex("#fafafa"),
	SelectPopupBg = Color3.fromHex("#0a0a0a"),
	SelectPopupBgTransparency = 0,
	TabBar = Color3.fromHex("#0a0a0a"),
	TabActive = Color3.fromHex("#2563eb"),
	TabInactive = Color3.fromHex("#a3a3a3"),
	TabIndicator = Color3.fromHex("#2563eb"),
	TabIndicatorTrack = Color3.fromHex("#262626"),
	TabIndicatorTrackTransparency = 0,
	SidebarBg = Color3.fromHex("#0a0a0a"),
	SidebarIcon = Color3.fromHex("#a3a3a3"),
	SidebarIconTransparency = 0,
	SidebarIconActive = Color3.fromHex("#fafafa"),
	SidebarIconActiveTransparency = 0,
	SidebarActiveIndicator = Color3.fromHex("#2563eb"),
	SidebarActiveBackground = Color3.fromHex("#171717"),
	Element = Color3.fromHex("#171717"),
	ElementTransparency = 1,
	ShadowColor = Color3.fromHex("#000000"),
	ShadowTransparencySidebar = 0.6,
	ShadowTransparencyWindow = 0.2,
	CornerRadiusWindow = UDim.new(0, 8),
	CornerRadiusSidebar = UDim.new(0, 8),
	CornerRadiusTab = UDim.new(0, 6),
	CornerRadiusPill = UDim.new(0, 192),
	CornerRadiusFull = UDim.new(1, 0),
	CornerRadiusIndicator = UDim.new(0, 2),
	CornerRadiusNoise = UDim.new(0, 8),
	CornerRadiusSection = UDim.new(0, 8),
	PaddingWindow = UDim.new(0, 12),
	PaddingElement = UDim.new(0, 14),
	PaddingInput = UDim.new(0, 8),
	PaddingInputSmall = UDim.new(0, 5),
	GapSection = UDim.new(0, 16),
	GapTab = UDim.new(0, 16),
	GapSidebar = UDim.new(0, 10),
	GapInline = UDim.new(0, 6),
	GapLabelContent = UDim.new(0, 4),
	GapContentPadding = UDim.new(0, 18),
	ScrollBarColor = Color3.fromHex("#404040"),
	ScrollBarTransparency = 0.5,
	ScrollBarThickness = 2,
	Hover = Color3.fromHex("#262626"),
	HoverTransparency = 1,
	LoaderBackground = Color3.fromHex("#0a0a0a"),
	LoaderTagline = Color3.fromHex("#a3a3a3"),
	LoaderTitleStroke = Color3.fromHex("#1e3a5f"),
	LoaderTitleStrokeTransparency = 0.2,
	LoaderProgressTrack = Color3.fromHex("#262626"),
	LoaderProgressTrackStroke = Color3.fromHex("#404040"),
	LoaderProgressTrackStrokeTransparency = 0.8,
	LoaderProgressFill = Color3.fromHex("#2563eb"),
	LoaderProgressFillStroke = Color3.fromHex("#1d4ed8"),
	LoaderProgressFillStrokeTransparency = 0.4,
	LoaderPadding = UDim.new(0, 16),
	FontFamilyTitle = "rbxasset://fonts/families/FredokaOne.json",
	FontFamilyTagline = "rbxasset://fonts/families/GothamSSm.json",
	TextSizeTitle = 32,
}
aa.ButtonDefaultBg = aa.VariantDefaultBg
aa.ButtonDefaultText = aa.VariantDefaultText
aa.ButtonDefaultStroke = aa.VariantDefaultStroke
aa.ButtonDefaultStrokeTransparency = aa.VariantDefaultStrokeTransparency
aa.ButtonDefaultHoverFillTransparency = aa.VariantDefaultHoverFillTransparency
aa.ButtonOutlineBg = aa.VariantOutlineBg
aa.ButtonOutlineBgTransparency = aa.VariantOutlineBgTransparency
aa.ButtonOutlineStroke = aa.VariantOutlineStroke
aa.ButtonOutlineStrokeTransparency = aa.VariantOutlineStrokeTransparency
aa.ButtonDestructiveBg = aa.VariantDestructiveBg
aa.ButtonDestructiveBgTransparency = aa.VariantDestructiveBgTransparency
aa.ButtonDestructiveText = aa.VariantDestructiveText
return aa
end
a["Theme/ThemeManager"]=function()
local aa, ab, ac, ad, ae, af, ag, ah, ai, aj, ak, al =
	d("Core/Logger"),
	d("Persist/SnapshotStorage"),
	d("Theme/BuiltInThemes"),
	d("Theme/ThemeSchema"),
	"Default",
	Color3.fromRGB(255, 185, 255),
	{ "Name", "BackgroundMain", "BackgroundSurface", "Text", "SubText", "StrokeColor", "Hover" },
	{},
	{},
	{},
	{},
	{}
local am, an, ao =
	{ DefaultThemeName = ae }, function(am)
		local an = {}
		for ao, ap in am do
			an[ao] = ap
		end
		return an
	end, function(am)
		return typeof(am.Accent) == "Color3" and typeof(am.AccentDark) == "Color3"
	end
local ap = function(ap)
	local aq = an(ap)
	if aq.AccentGradientAuto ~= false and ao(aq) then
		aq.AccentGradient =
			ColorSequence.new({ ColorSequenceKeypoint.new(0, aq.Accent), ColorSequenceKeypoint.new(1, aq.AccentDark) })
	end
	local ar = aq.LogoSyncAccent
	if type(ar) ~= "boolean" then
		ar = true
	end
	aq.LogoSyncAccent = ar
	local as = aq.LogoColorBase
	if typeof(as) ~= "Color3" then
		as = af
	end
	aq.LogoColorBase = as
	aq.LogoColor = (ar and typeof(aq.Accent) == "Color3" and { aq.Accent } or { as })[1]
	return aq
end
local aq, ar =
	function(aq, ar)
		local as = ap(ar)
		ah[aq] = as
		for at, e in aj do
			if e == aq then
				ai[at] = nil
				aj[at] = nil
			end
		end
		ai[aq] = aq
		aj[aq] = aq
		local at = as.Name
		if type(at) == "string" and at ~= "" then
			ai[at] = aq
			aj[at] = aq
		end
	end, function(aq)
		for ar, as in aj do
			if as == aq then
				ai[ar] = nil
				aj[ar] = nil
			end
		end
	end
function am.ResolveKey(as)
	local at = ai[as]
	if at and ah[at] then
		return at
	end
	if ah[as] then
		return as
	end
	return nil
end
local as, at =
	function(as)
		assert(type(as) == "table", "AddTheme \u{2014} ThemeTable must be a table")
		local at = as.Name
		assert(type(at) == "string" and at ~= "", "AddTheme \u{2014} missing Name")
		local e = {}
		for f, g in ag do
			if as[g] == nil then
				table.insert(e, g)
			end
		end
		if #e > 0 then
			error(("AddTheme \u{2014} theme '%s' missing required keys: %s"):format(at, table.concat(e, ", ")), 3)
		end
		for f, g in as do
			local h = ad[f]
			if h and typeof(g) ~= h then
				error(("AddTheme \u{2014} theme '%s' token '%s' expected %s, got %s"):format(at, f, h, typeof(g)), 3)
			end
		end
		if as.AccentGradient == nil and not ao(as) then
			error(("AddTheme \u{2014} theme '%s' missing AccentGradient and cannot build from Accent/AccentDark"):format(at), 3)
		end
	end, function(as, at)
		for e, f in at do
			if e == "Name" then
				continue
			end
			local g = ad[e]
			if g and typeof(f) ~= g then
				return false, ("theme '%s' token '%s' expected %s, got %s"):format(as, e, g, typeof(f))
			end
		end
		return true, nil
	end
function am.MakeUniqueCustomThemeName(e)
	local f = e:gsub("^%s*(.-)%s*$", "%1")
	if f == "" then
		f = "Theme"
	end
	local g, h = f, 1
	while ah[g] or ak[g] do
		g = ("%s %d"):format(f, h)
		h = h + 1
	end
	return g
end
local e = function(e, f)
	local g = (ak[e] and { (am.MakeUniqueCustomThemeName(e)) } or { e })[1]
	f.Name = g
	aq(g, f)
	return g
end
for f, g in ac do
	aq(f, g)
	ak[f] = true
	if type(g.Name) == "string" and g.Name ~= "" then
		ak[g.Name] = true
	end
end
function am.LoadCustomThemes()
	if not ab.EnsureFolders then
		return
	end
	ab.EnsureFolders()
	for f, g in ab.ListThemeFiles() do
		local h, i = ab.LoadTheme(g)
		if not h then
			aa.Warn("Load custom theme failed:", g, tostring(i))
			continue
		end
		local j = i
		local k, l = pcall(function()
			as(j)
		end)
		if not k then
			aa.Warn("Invalid custom theme:", g, tostring(l))
			continue
		end
		local m = (type(j.Name) == "string" and j.Name ~= "" and { j.Name } or { g })[1]
		e(m, ap(j))
	end
end
am.LoadCustomThemes()
function am.GetThemeNames()
	local f = {}
	for g in ah do
		table.insert(f, g)
	end
	table.sort(f)
	return f
end
function am.GetThemePresets(f)
	local g, h = (type(f) == "string" and { (am.ResolveKey(f)) } or { nil })[1], {}
	for i in ah do
		table.insert(h, { Name = i, IsBuiltIn = ak[i] == true, IsActive = g == i, IsDirty = al[i] == true })
	end
	table.sort(h, function(i, j)
		if i.IsBuiltIn ~= j.IsBuiltIn then
			return i.IsBuiltIn
		end
		return i.Name < j.Name
	end)
	return h
end
function am.GetThemeData(f)
	local g = am.ResolveKey(f)
	local h = (g and { ah[g] } or { nil })[1]
	return (h and { (an(h)) } or { nil })[1]
end
function am.GetRawThemeData(f)
	local g = am.ResolveKey(f)
	return (g and { ah[g] } or { nil })[1]
end
function am.CreateEditableTheme(f)
	local g = am.ResolveKey(f)
	if not g then
		return nil
	end
	if not ak[g] then
		return g
	end
	local h = ah[g]
	if not h then
		return nil
	end
	local i, j = am.MakeUniqueCustomThemeName(g), an(h)
	j.Name = i
	aq(i, ap(j))
	al[i] = true
	return i
end
function am.AddTheme(f)
	as(f)
	local g, h = f.Name, ap(f)
	if ak[g] then
		g = am.MakeUniqueCustomThemeName(g)
		h.Name = g
	end
	aq(g, h)
	al[g] = true
	return g
end
function am.PatchThemeTokens(f, g)
	local h = am.CreateEditableTheme(f)
	if not h then
		return false, "unknown theme", nil
	end
	local i = ah[h]
	if not i then
		return false, "theme data not found", nil
	end
	local j, k = at(h, g)
	if not j then
		return false, k, nil
	end
	for l, m in g do
		if l ~= "Name" then
			i[l] = m
		end
	end
	aq(h, ap(i))
	al[h] = true
	return true, h, ah[h]
end
function am.DuplicateTheme(f, g)
	local h = am.ResolveKey(f)
	local i = (h and { ah[h] } or { nil })[1]
	if not h or not i then
		return nil
	end
	local j = (type(g) == "string" and g ~= "" and { g } or { (h .. " Copy") })[1]
	local k, l = am.MakeUniqueCustomThemeName(j), an(i)
	l.Name = k
	aq(k, ap(l))
	al[k] = true
	return k
end
function am.DeleteTheme(f)
	local g = am.ResolveKey(f)
	if not g or ak[g] then
		return false
	end
	ah[g] = nil
	al[g] = nil
	ar(g)
	return true
end
function am.RenameTheme(f, g)
	local h = am.ResolveKey(f)
	if not h or ak[h] then
		return nil
	end
	local i = g:gsub("^%s*(.-)%s*$", "%1")
	if i == "" then
		return nil
	end
	local j, k = ((ah[i] or ak[i]) and { (am.MakeUniqueCustomThemeName(i)) } or { i })[1], ah[h]
	if not k then
		return nil
	end
	ah[h] = nil
	ar(h)
	k.Name = j
	aq(j, ap(k))
	al[j] = true
	al[h] = nil
	return j
end
function am.SaveThemeFile(f, g)
	local h = am.ResolveKey(f)
	if not h then
		return false, "unknown theme", nil
	end
	if ak[h] then
		h = am.CreateEditableTheme(h) or h
	end
	local i = ah[h]
	if not i then
		return false, "theme data not found", nil
	end
	local j = (type(g) == "string" and g ~= "" and { g } or { h })[1]
	if ak[j] and j == f then
		j = h
	elseif ak[j] then
		j = am.MakeUniqueCustomThemeName(j)
	end
	if j ~= h then
		local k = an(i)
		k.Name = j
		h = e(j, ap(k))
		i = ah[h]
	end
	local k, l = ab.SaveTheme(h, i)
	if not k then
		return false, l, nil
	end
	al[h] = nil
	return true, h, i
end
function am.LoadThemeFile(f, g)
	local h, i = ab.LoadTheme(f)
	if not h then
		return false, i
	end
	local j, k = i, g or f
	local l = am.ResolveKey(k) or k
	if ak[l] then
		l = am.MakeUniqueCustomThemeName(l)
	end
	local m = ah[l]
	if m and type(m.Name) == "string" and m.Name ~= "" then
		j.Name = m.Name
	elseif type(j.Name) ~= "string" or j.Name == "" then
		j.Name = l
	end
	local n, o = pcall(function()
		as(j)
	end)
	if not n then
		return false, tostring(o)
	end
	e(l, j)
	al[l] = nil
	return true, l
end
function am.ListThemeFiles()
	return ab.ListThemeFiles()
end
return table.freeze(am)
end
a["Theme/ThemeSchema"]=function()
local aa, ab = d("Theme/DefaultTheme"), {}
for ac, ad in aa do
	ab[ac] = typeof(ad)
end
return table.freeze(ab)
end
a["UI/Attributes"]=function()
return table.freeze({
	ModalManagedSize = "__ModalManagedSize",
	ModalWantsColorPickerSize = "__ModalWantsColorPickerSize",
	IsDivider = "__IsDivider",
	HoverThemeToken = "HoverThemeToken",
	SettingsIdx = table.freeze({
		DragFpsCap = "__Settings_DragFpsCap",
		UseDragSkeleton = "__Settings_UseDragSkeleton",
		UseFullVisibilityAnimation = "__Settings_UseFullVisibilityAnimation",
		UseClassicToggle = "__Settings_UseClassicToggle",
		ToggleUiKeybind = "__Settings_ToggleUiKeybind",
		OverlayEnabled = "__Settings_OverlayEnabled",
		SnapshotApplyCallbacks = "__Settings_SnapshotApplyCallbacks",
		ThemeFileName = "__Settings_ThemeFileName",
		ThemeLogoSyncAccent = "__Settings_ThemeLogoSyncAccent",
		ThemeSelect = "__Settings_ThemeSelect",
		ThemeSaveFile = "__Settings_ThemeSaveFile",
		ThemeLoadFile = "__Settings_ThemeLoadFile",
		ThemeRefreshList = "__Settings_ThemeRefreshList",
		ThemeTokenPrefix = "__Settings_ThemeToken_",
		ServerHopIfLowPlayer = "__Settings_ServerHopIfLowPlayer",
		ServerHopMinimumPlayers = "__Settings_ServerHopMinimumPlayers",
		ServerHopMinutesToRejoin = "__Settings_ServerHopMinutesToRejoin",
		ServerHopRejoinAfterMinutes = "__Settings_ServerHopRejoinAfterMinutes",
		ServerHopJobId = "__Settings_ServerHopJobId",
		FpsCap = "__Settings_FpsCap",
		Render3dEnabled = "__Settings_Render3dEnabled",
	}),
})
end
a["UI/Confirm"]=function()
local aa, ab = d("Core/SafeCall"), d("Core/Common")
local ac, ad, ae, af, ag, ah, ai =
	ab.Animator,
	d("Localization/Localization"),
	d("UI/DialogConfig"),
	d("UI/DialogBuilder"),
	{},
	ab.AnimTokens.Info(0.1, ab.AnimTokens.Easing.Standard),
	ab.AnimTokens.Preset.Settle
local aj = function(aj)
	local ak, al, am, an, ao = ae.GetConfirmActionVisualTokens(aj.Variant)
	return {
		Id = aj.Id,
		Label = aj.Label,
		Variant = ae.NormalizeConfirmVariant(aj.Variant),
		Callback = aj.Callback,
		Side = ae.IsPrimaryConfirmAction(aj) and "Left" or "Right",
		BgToken = ak,
		BgTransparencyToken = al,
		TextToken = am,
		StrokeToken = an,
		StrokeTransparencyToken = ao,
	}
end
function ag.New(ak)
	local al = ak.Data
	local am, an, ao, ap, aq =
		(type(al.Title) == "string" and al.Title ~= "" and { al.Title } or { (ad.t("dialog.confirm.defaultTitle")) })[1],
		(type(al.Content) == "string" and { al.Content } or { "" })[1],
		{},
		false,
		{}
	for ar, as in ae.ResolveConfirmActions(al.Actions) do
		table.insert(ao, aj(as))
	end
	local ar = af.BuildConfirm({
		Parent = ak.Parent,
		Title = am,
		Content = an,
		Actions = ao,
		OnAction = function(ar)
			if ap then
				return
			end
			local as = { Id = ar.Id, Label = ar.Label, Reason = "action:" .. ar.Id }
			if ar.Callback then
				aa.Call(ar.Callback, as)
			end
			(aq):Close(as.Reason, as)
		end,
	})
	ae.AnimateOpen(ar, 0.2)
	local as = function(as, at, e)
		if ap then
			return
		end
		ap = true
		if e then
			ar.Root:Destroy()
			ak.OnClosed(as, at)
			return
		end
		local f = ae.AnimateClose(ar)
		task.delay(f + 0.03, function()
			if ar.Root and ar.Root.Parent then
				ar.Root:Destroy()
			end
			ak.OnClosed(as, at)
		end)
	end
	function aq.Close(at, e, f)
		as(e or "api", f, false)
	end
	function aq.Destroy(at, e, f)
		as(e or "api", f, true)
	end
	function aq.ShouldBlockWindowDrag(at, e)
		return true
	end
	function aq.Remind(at)
		if ap or not ar.PanelScale then
			return
		end
		local e = ar.PanelScale
		ac.Tween(e, { Scale = ab.AnimTokens.Scale.BouncePeak }, ah).Completed:Once(function()
			if ap or not e.Parent then
				return
			end
			ac.Tween(e, { Scale = 1 }, ai)
		end)
	end
	return aq
end
return table.freeze(ag)
end
a["UI/DialogBuilder"]=function()
local aa = d("Core/Common")
local ab, ac = aa.Creator, d("UI/DialogFooter")
local ad, ae, af, ag, ah, ai, aj, ak, al =
	ab.New,
	{},
	"rbxassetid://12187365364",
	"rbxassetid://8992230677",
	90,
	"rbxassetid://10747384394",
	0.18,
	20,
	function(ad, ae)
		local af = ab.GetThemeProperty(ad)
		return (af ~= nil and { af } or { ae })[1]
	end
local am, an =
	function(am)
		return ad("TextLabel", { FontFace = Font.new(af, al("FontWeightSemiBold", Enum.FontWeight.SemiBold), Enum.FontStyle.Normal), Text = am, TextColor3 = al("DialogHeaderText", Color3.fromRGB(240, 240, 240)), TextSize = 18, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromScale(1, 0), ZIndex = 93, [ab.ThemeTag] = { TextColor3 = "DialogHeaderText" } })
	end, function(am)
		return ad("TextLabel", { FontFace = Font.new(af), Text = am, TextColor3 = al("DialogHeaderText", Color3.fromRGB(240, 240, 240)), TextSize = 16, TextTransparency = al("DialogContentTransparency", aj), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, LayoutOrder = 2, Size = UDim2.fromScale(1, 0), ZIndex = 93, [ab.ThemeTag] = { TextColor3 = "DialogHeaderText", TextTransparency = "DialogContentTransparency" } })
	end
local ao, ap, aq, ar =
	function(ao, ap)
		return ad("Frame", { AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 0) }, { am(ao), an(ap), ad("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }), ad("UIPadding", { PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 14) }) })
	end, function(ao)
		return ad("TextButton", {
			Name = "Backdrop",
			Text = "",
			AutoButtonColor = false,
			Active = true,
			BackgroundColor3 = al("DialogOverlayColor", Color3.fromRGB(0, 0, 0)),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = ah - 1,
			[ab.Ref] = function(ap)
				ao.OverlayButton = ap
			end,
		}, { ad("UICorner", { CornerRadius = al("CornerRadiusWindow", UDim.new(0, 12)), [ab.ThemeTag] = { CornerRadius = "CornerRadiusWindow" } }) })
	end, function(ao)
		return ad("ImageLabel", {
			Image = ag,
			ImageColor3 = al("ShadowColor", Color3.fromRGB(0, 0, 0)),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(99, 99, 99, 99),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			ImageTransparency = 1,
			[ab.Ref] = function(ap)
				ao.Shadow = ap
			end,
		})
	end, function(ao)
		return ad("TextButton", {
			Name = "ResizeGrip",
			AnchorPoint = Vector2.new(1, 1),
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -ak, 1, -ak),
			Size = UDim2.fromOffset(24, 24),
			Text = "",
			ZIndex = 6,
			[ab.Ref] = function(ap)
				ao.ResizeHandle = ap
			end,
		})
	end
function ae.BuildConfirm(as)
	local at = {}
	local e = ad(
		"TextButton",
		{
			AutoButtonColor = false,
			Text = "",
			Active = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = ah,
			Parent = as.Parent,
		},
		{
			ap(at),
			ad(
				"Frame",
				{
					AnchorPoint = Vector2.new(0.5, 0.5),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(420 + ak * 2, 0),
					ZIndex = 92,
					[ab.Ref] = function(e)
						at.PanelWrapper = e
					end,
				},
				{
					aq(at),
					ad("UIScale", {
						Scale = 0.85,
						[ab.Ref] = function(e)
							at.PanelScale = e
						end,
					}),
					ad(
						"CanvasGroup",
						{
							Active = true,
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							GroupTransparency = 1,
							Size = UDim2.fromScale(1, 0),
							ZIndex = 2,
							[ab.Ref] = function(e)
								at.PanelGroup = e
							end,
						},
						{
							ad(
								"UIPadding",
								{
									PaddingTop = UDim.new(0, ak),
									PaddingBottom = UDim.new(0, ak),
									PaddingLeft = UDim.new(0, ak),
									PaddingRight = UDim.new(0, ak),
								}
							),
							ad(
								"Frame",
								{
									AutomaticSize = Enum.AutomaticSize.Y,
									BackgroundColor3 = al("DialogSurface", Color3.fromRGB(20, 20, 20)),
									BorderSizePixel = 0,
									Size = UDim2.fromScale(1, 0),
									[ab.Ref] = function(e)
										at.PanelContent = e
									end,
									[ab.ThemeTag] = { BackgroundColor3 = "DialogSurface" },
								},
								{
									ad(
										"UIStroke",
										{
											Color = al("DialogBorder", Color3.fromRGB(240, 240, 240)),
											Transparency = 0.9,
											[ab.ThemeTag] = { Color = "DialogBorder" },
										}
									),
									ad(
										"UICorner",
										{
											CornerRadius = al("CornerRadiusWindow", UDim.new(0, 12)),
											[ab.ThemeTag] = { CornerRadius = "CornerRadiusWindow" },
										}
									),
									ad("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
									ao(as.Title, as.Content),
									ac.BuildFooter(as.Actions, as.OnAction),
								}
							),
						}
					),
				}
			),
		}
	)
	at.Root = e
	return at
end
function ae.BuildModal(as)
	local at, e, f, g, h =
		{ ShowCloseButton = as.ShowCloseButton },
		as.Width or 420,
		as.Height or 600,
		as.NoBackdrop == true,
		as.ShowTitleBar ~= false
	local i, j =
		g and as.Resizable == true,
		{
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = ah,
			Parent = as.Parent,
		}
	if not g then
		j.Name = "SeaHubModalDialog"
		j.AutoButtonColor = false
		j.Text = ""
		j.Active = true
	end
	local k = {}
	if not g then
		table.insert(k, ap(at))
	end
	local l, m = e + ak * 2, f + ak * 2
	local n = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		ClipsDescendants = false,
		Size = (g and { (UDim2.fromOffset(l, m)) } or { (UDim2.new(1, -32, 1, -48)) })[1],
		ZIndex = ah + 2,
		[ab.Ref] = function(n)
			at.PanelWrapper = n
		end,
	}
	if g then
		n.GroupTransparency = 0
		n.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
	table.insert(
		k,
		ad(
			g and "CanvasGroup" or "Frame",
			n,
			{
				(g and { nil } or {
					(ad("UISizeConstraint", {
						MaxSize = Vector2.new(l, m),
						[ab.Ref] = function(o)
							at.PanelMaxSizeConstraint = o
						end,
					})),
				})[1],
				aq(at),
				ad("UIScale", {
					Scale = 0.85,
					[ab.Ref] = function(o)
						at.PanelScale = o
					end,
				}),
				ad(
					"CanvasGroup",
					{
						Active = true,
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						GroupTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						ZIndex = 2,
						[ab.Ref] = function(o)
							at.PanelGroup = o
						end,
					},
					{
						ad(
							"UIPadding",
							{
								PaddingTop = UDim.new(0, ak),
								PaddingBottom = UDim.new(0, ak),
								PaddingLeft = UDim.new(0, ak),
								PaddingRight = UDim.new(0, ak),
							}
						),
						ad(
							"Frame",
							{
								BackgroundColor3 = al("DialogSurface", Color3.fromRGB(20, 20, 20)),
								BorderSizePixel = 0,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 3,
								[ab.Ref] = function(o)
									at.PanelContent = o
								end,
								[ab.ThemeTag] = { BackgroundColor3 = "DialogSurface" },
							},
							{
								ad(
									"UIStroke",
									{
										Color = al("DialogBorder", Color3.fromRGB(240, 240, 240)),
										Transparency = 0.9,
										[ab.ThemeTag] = { Color = "DialogBorder" },
									}
								),
								ad(
									"UICorner",
									{
										CornerRadius = al("CornerRadiusWindow", UDim.new(0, 12)),
										[ab.ThemeTag] = { CornerRadius = "CornerRadiusWindow" },
									}
								),
								ad("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
								ad(
									"Frame",
									{
										Active = h,
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										BackgroundTransparency = 1,
										BorderColor3 = Color3.fromRGB(0, 0, 0),
										BorderSizePixel = 0,
										LayoutOrder = 1,
										Size = (h and { (UDim2.new(1, 0, 0, 48)) } or { (UDim2.new(1, 0, 0, 0)) })[1],
										Visible = h,
										[ab.Ref] = function(o)
											at.TitleBar = o
										end,
									},
									{
										ad(
											"UIPadding",
											{ PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }
										),
										ad("TextLabel", {
											AnchorPoint = Vector2.new(0, 0.5),
											BackgroundTransparency = 1,
											FontFace = Font.new(
												al("FontFamily", "rbxassetid://12187365364"),
												al("FontWeightSemiBold", Enum.FontWeight.SemiBold),
												Enum.FontStyle.Normal
											),
											Position = UDim2.fromScale(0, 0.5),
											Size = UDim2.new(1, -40, 0, 24),
											Text = as.Title,
											TextColor3 = al("DialogHeaderText", Color3.fromRGB(240, 240, 240)),
											TextSize = al("TextSizeBody", 18),
											TextXAlignment = Enum.TextXAlignment.Left,
											ZIndex = 3,
											[ab.Ref] = function(o)
												at.TitleLabel = o
											end,
											[ab.ThemeTag] = { TextColor3 = "DialogHeaderText", TextSize = "TextSizeBody" },
										}),
										ad(
											"TextButton",
											{
												AnchorPoint = Vector2.new(1, 0.5),
												AutoButtonColor = false,
												BackgroundTransparency = 1,
												Position = UDim2.new(1, 0, 0.5, 0),
												Size = UDim2.fromOffset(24, 24),
												Text = "",
												Visible = h and as.ShowCloseButton,
												ZIndex = 4,
												[ab.Ref] = function(o)
													at.CloseButton = o
												end,
												[ab.Activated] = as.OnCloseButtonActivated,
											},
											{
												ad("ImageLabel", {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Image = ai,
													ImageColor3 = al("DialogCloseIcon", Color3.fromRGB(240, 240, 240)),
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromOffset(16, 16),
													ZIndex = 4,
													[ab.Ref] = function(o)
														at.CloseIcon = o
													end,
													[ab.ThemeTag] = { ImageColor3 = "DialogCloseIcon" },
												}),
											}
										),
									}
								),
								ad("Frame", {
									BackgroundColor3 = al("DialogBorder", Color3.fromRGB(240, 240, 240)),
									BackgroundTransparency = 0.9,
									BorderSizePixel = 0,
									LayoutOrder = 2,
									Size = (h and { (UDim2.new(1, 0, 0, 1)) } or { (UDim2.new(1, 0, 0, 0)) })[1],
									Visible = h,
									[ab.Ref] = function(o)
										at.HeaderDivider = o
									end,
									[ab.ThemeTag] = { BackgroundColor3 = "DialogBorder" },
								}),
								ad(
									"ScrollingFrame",
									{
										AutomaticCanvasSize = Enum.AutomaticSize.Y,
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										CanvasSize = UDim2.fromOffset(0, 0),
										LayoutOrder = 3,
										ScrollBarImageColor3 = al("ScrollBarColor", Color3.fromRGB(0, 0, 0)),
										ScrollBarImageTransparency = al("ScrollBarTransparency", 0.5),
										ScrollBarThickness = al("ScrollBarThickness", 2),
										Size = (h and { (UDim2.new(1, 0, 1, -49)) } or { (UDim2.fromScale(1, 1)) })[1],
										ScrollingDirection = Enum.ScrollingDirection.Y,
										ZIndex = 3,
										[ab.Ref] = function(o)
											at.Scroll = o
										end,
										[ab.ThemeTag] = {
											ScrollBarImageColor3 = "ScrollBarColor",
											ScrollBarImageTransparency = "ScrollBarTransparency",
											ScrollBarThickness = "ScrollBarThickness",
										},
									},
									{
										ad(
											"UIPadding",
											{
												PaddingTop = UDim.new(0, 10),
												PaddingBottom = UDim.new(0, 10),
												PaddingLeft = UDim.new(0, 10),
												PaddingRight = UDim.new(0, 10),
											}
										),
										ad(
											"UIListLayout",
											{ Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }
										),
									}
								),
							}
						),
					}
				),
				(i and { (ar(at)) } or { nil })[1],
			}
		)
	)
	local o = ad(g and "Frame" or "TextButton", j, k)
	at.Root = o
	return at
end
function ae.SetTitleBarVisible(as, at)
	if as.TitleBar then
		as.TitleBar.Visible = at
		as.TitleBar.Size = (at and { (UDim2.new(1, 0, 0, 48)) } or { (UDim2.new(1, 0, 0, 0)) })[1]
	end
	if as.CloseButton then
		as.CloseButton.Visible = at and as.ShowCloseButton == true
	end
	if as.HeaderDivider then
		as.HeaderDivider.Visible = at
		as.HeaderDivider.Size = (at and { (UDim2.new(1, 0, 0, 1)) } or { (UDim2.new(1, 0, 0, 0)) })[1]
	end
	if as.Scroll then
		as.Scroll.Size = (at and { (UDim2.new(1, 0, 1, -49)) } or { (UDim2.fromScale(1, 1)) })[1]
	end
end
function ae.ApplyContentBounds(as, at, e, f)
	local g, h = at + ak * 2, e + ak * 2
	if f then
		local i = as.PanelWrapper
		if i then
			i.Size = UDim2.fromOffset(g, h)
		end
	else
		local i = as.PanelMaxSizeConstraint
		if i then
			i.MaxSize = Vector2.new(g, h)
		end
	end
end
ae.Bleed = ak
return table.freeze(ae)
end
a["UI/DialogConfig"]=function()
local aa, ab = d("Core/Common"), d("Localization/Localization")
local ac, ad, ae = aa.AnimKit, aa.AnimTokens, {}
ae.COLOR_PICKER_MODAL_WIDTH = 284
ae.COLOR_PICKER_MODAL_BODY_HEIGHT = 364
ae.COLOR_PICKER_MODAL_TITLEBAR_HEIGHT = 49
ae.COLOR_PICKER_MODAL_HEIGHT = ae.COLOR_PICKER_MODAL_BODY_HEIGHT + ae.COLOR_PICKER_MODAL_TITLEBAR_HEIGHT
local af, ag, ah, ai, aj, ak =
	ad.Preset.Fade, ad.Preset.Pop, ad.Preset.Close, ad.Preset.Close, function()
		return { { Id = "yes", Label = ab.t("common.actions.yes"), Variant = "Default" }, { Id = "no", Label = ab.t("common.actions.no"), Variant = "Secondary" } }
	end, { Default = true, Secondary = true, Ghost = true, Destructive = true, Outline = true }
function ae.ResolveConfirmActions(al)
	if type(al) ~= "table" or #al == 0 then
		return aj()
	end
	local am = {}
	for an, ao in al do
		if type(ao) == "table" then
			local ap = (type(ao.Id) == "string" and ao.Id ~= "" and { ao.Id } or { "action" })[1]
			local aq = (type(ao.Label) == "string" and ao.Label ~= "" and { ao.Label } or { ap })[1]
			table.insert(am, { Id = ap, Label = aq, Variant = ao.Variant, Callback = ao.Callback })
		end
	end
	if #am == 0 then
		return aj()
	end
	return am
end
function ae.NormalizeConfirmVariant(al)
	if type(al) ~= "string" or al == "" then
		return "Secondary"
	end
	local am = al:sub(1, 1):upper() .. al:sub(2):lower()
	if ak[am] then
		return am
	end
	return "Secondary"
end
function ae.IsPrimaryConfirmAction(al)
	local am = ae.NormalizeConfirmVariant(al.Variant)
	if am == "Default" then
		return true
	end
	local an, ao =
		(type(al.Id) == "string" and { (al.Id:lower()) } or { "" })[1],
		(type(al.Label) == "string" and { (al.Label:lower()) } or { "" })[1]
	return an == "yes" or an == "confirm" or ao == "yes" or ao == "confirm"
end
function ae.GetConfirmActionVisualTokens(al)
	local am = ae.NormalizeConfirmVariant(al)
	local an = "DialogAction" .. am
	return an .. "Bg", an .. "BgTransparency", an .. "Text", an .. "Stroke", an .. "StrokeTransparency"
end
function ae.GetButtonVisualTokens(al)
	if al == "Destructive" then
		return "VariantDestructiveBg", "VariantDestructiveText", "VariantDestructiveStroke"
	end
	if al == "Default" then
		return "VariantDefaultBg", "VariantDefaultText", "VariantDefaultStroke"
	end
	return "VariantOutlineBg", "VariantOutlineText", "VariantOutlineStroke"
end
function ae.NormalizeModalConfig(al)
	local am = (type(al) == "table" and { al } or { {} })[1]
	local an, ao =
		math.clamp(tonumber(am.MinWidth) or 320, 240, 880), math.clamp(tonumber(am.MinHeight) or 240, 160, 680)
	local ap, aq = math.clamp(tonumber(am.MaxWidth) or 880, an, 880), math.clamp(tonumber(am.MaxHeight) or 680, ao, 680)
	return {
		Title = (
			type(am.Title) == "string" and am.Title ~= "" and { am.Title } or { (ab.t("dialog.modal.defaultTitle")) }
		)[1],
		Build = (type(am.Build) == "function" and { am.Build } or { nil })[1],
		Width = math.clamp(tonumber(am.Width) or 480, an, ap),
		Height = math.clamp(tonumber(am.Height) or 360, ao, aq),
		MinWidth = an,
		MinHeight = ao,
		MaxWidth = ap,
		MaxHeight = aq,
		AllowEscDismiss = am.AllowEscDismiss == nil and true or am.AllowEscDismiss == true,
		AllowOverlayDismiss = am.AllowOverlayDismiss == nil and true or am.AllowOverlayDismiss == true,
		ShowCloseButton = am.ShowCloseButton == nil and true or am.ShowCloseButton == true,
		ShowTitleBar = am.ShowTitleBar == nil and true or am.ShowTitleBar == true,
		SnapshotMode = am.SnapshotMode == "Shared" and "Shared" or "Isolated",
		Draggable = am.Draggable == true and true or false,
		Resizable = am.Resizable == true and true or false,
		AllowStacked = am.AllowStacked == true and true or false,
	}
end
function ae.AnimateOpen(al, am)
	local an, ao = al.Backdrop or al.OverlayButton, am or 0.2
	if al.PanelScale then
		ac.ScalePop(al.PanelScale, { start = ad.Scale.PopStart, info = ag })
	end
	if al.PanelGroup then
		ac.GroupFade(al.PanelGroup, "In", { info = af })
	end
	if an then
		ac.FadeProp(an, "BackgroundTransparency", ao, { from = 1, info = af })
	end
	if al.Shadow then
		ac.FadeProp(al.Shadow, "ImageTransparency", 0, { from = 1, info = af })
	end
end
function ae.AnimateClose(al)
	local am = al.Backdrop or al.OverlayButton
	if al.PanelScale then
		ac.ScaleShrink(al.PanelScale, { endScale = ad.Scale.CloseEnd, info = ai })
	end
	if al.PanelGroup then
		ac.GroupFade(al.PanelGroup, "Out", { info = ah })
	end
	if am then
		ac.FadeProp(am, "BackgroundTransparency", 1, { info = ah })
	end
	if al.Shadow then
		ac.FadeProp(al.Shadow, "ImageTransparency", 1, { info = ah })
	end
	return ah.Time
end
return table.freeze(ae)
end
a["UI/DialogFooter"]=function()
local aa = d("Core/Common")
local ab, ac = aa.Creator, aa.WindowDrag
local ad, ae, af, ag =
	ab.New, {}, "rbxassetid://12187365364", function(ad, ae)
		local af = ab.GetThemeProperty(ad)
		return (af ~= nil and { af } or { ae })[1]
	end
local ah = function(ah, ai)
	return ad(
		"Frame",
		{
			Active = true,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = ag(ah.BgToken, Color3.fromRGB(240, 240, 240)),
			BackgroundTransparency = ag(ah.BgTransparencyToken, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(0, 30),
			[ab.ThemeTag] = { BackgroundColor3 = ah.BgToken, BackgroundTransparency = ah.BgTransparencyToken },
		},
		{
			ad("UICorner", { CornerRadius = UDim.new(0, 12) }),
			ad("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }),
			ad(
				"UIStroke",
				{
					Color = ag(ah.StrokeToken, Color3.fromRGB(240, 240, 240)),
					Transparency = ag(ah.StrokeTransparencyToken, 1),
					[ab.ThemeTag] = { Color = ah.StrokeToken, Transparency = ah.StrokeTransparencyToken },
				}
			),
			ad(
				"TextLabel",
				{
					FontFace = Font.new(af, ag("FontWeightMedium", Enum.FontWeight.Medium), Enum.FontStyle.Normal),
					Text = ah.Label,
					TextColor3 = ag(ah.TextToken, Color3.fromRGB(0, 0, 0)),
					TextSize = 16,
					TextWrapped = true,
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = 2,
					Size = UDim2.new(0, 0, 1, 0),
					ZIndex = 93,
					[ab.ThemeTag] = { TextColor3 = ah.TextToken },
				}
			),
			ad("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				Text = "",
				ZIndex = 94,
				[ab.Activated] = function()
					if ac.ShouldSuppressClick() then
						return
					end
					ai(ah)
				end,
			}),
		}
	)
end
local ai = function(ai, aj, ak)
	local al = {
		ad(
			"UIListLayout",
			{
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = ai,
				[ab.ThemeTag] = { Padding = "DialogActionGap" },
			}
		),
	}
	for am, an in aj do
		table.insert(al, ah(an, ak))
	end
	return ad(
		"Frame",
		{ BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 30) },
		al
	)
end
function ae.BuildFooter(aj, ak)
	local al, am = {}, {}
	for an, ao in aj do
		if ao.Side == "Left" then
			table.insert(al, ao)
		else
			table.insert(am, ao)
		end
	end
	local an, ao, ap =
		ad(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 0),
			},
			{
				ad(
					"UIListLayout",
					{
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = ag("DialogActionGap", UDim.new(0, 8)),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						[ab.ThemeTag] = { Padding = "DialogActionGap" },
					}
				),
				ad(
					"UIPadding",
					{
						PaddingTop = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
					}
				),
				ai(Enum.HorizontalAlignment.Left, al, ak),
				ai(Enum.HorizontalAlignment.Right, am, ak),
			}
		),
		ad(
			"Frame",
			{
				BackgroundColor3 = ag("DialogBorder", Color3.fromRGB(240, 240, 240)),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 1),
				[ab.ThemeTag] = { BackgroundColor3 = "DialogBorder" },
			}
		),
		ag("CornerRadiusWindow", UDim.new(0, 12))
	local aq = math.max(1, ap.Offset)
	local ar, as =
		ad(
			"Frame",
			{
				Name = "TopCornerCover",
				AnchorPoint = Vector2.new(0, 0),
				BackgroundColor3 = ag("BackgroundSurface", Color3.fromRGB(22, 22, 22)),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 0),
				Size = UDim2.new(1, 0, 0, aq),
				ZIndex = 0,
				[ab.ThemeTag] = { BackgroundColor3 = "BackgroundSurface" },
			}
		),
		ad(
			"Frame",
			{
				Name = "FooterBody",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				ZIndex = 1,
			},
			{ ad("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }), ao, an }
		)
	return ad(
		"Frame",
		{
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = ag("BackgroundSurface", Color3.fromRGB(22, 22, 22)),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Position = UDim2.fromOffset(0, 20),
			Size = UDim2.new(1, 0, 0, 10),
			[ab.ThemeTag] = { BackgroundColor3 = "BackgroundSurface" },
		},
		{ ad("UICorner", { CornerRadius = ap, [ab.ThemeTag] = { CornerRadius = "CornerRadiusWindow" } }), ar, as }
	)
end
return table.freeze(ae)
end
a["UI/DialogManager"]=function()
local aa, ab, ac, ad = d("Core/SafeCall"), d("UI/Confirm"), d("UI/Modal"), {}
ad.__index = ad
function ad.New(ae)
	local af = setmetatable(
		{
			Parent = ae.Parent,
			Window = ae.Window,
			Registry = ae.Registry,
			OnDialogStateChanged = ae.OnDialogStateChanged,
			ActiveDialog = nil,
			ActiveStack = {},
			Handles = {},
			Destroying = false,
		},
		ad
	)
	return af
end
function ad._HasBlockingDialog(ae)
	for af, ag in ae.ActiveStack do
		if (ag).Floating ~= true then
			return true
		end
	end
	return false
end
function ad._EmitDialogState(ae, af)
	if ae.OnDialogStateChanged then
		local ag = (af and { (ae:_HasBlockingDialog()) } or { false })[1]
		aa.Call(ae.OnDialogStateChanged, ag)
	end
end
function ad._SetActiveDialog(ae, af)
	ae.ActiveDialog = af
	ae:_EmitDialogState(af ~= nil)
end
function ad._FindActiveIndex(ae, af)
	for ag = #ae.ActiveStack, 1, -1 do
		if ae.ActiveStack[ag] == af then
			return ag
		end
	end
	return nil
end
function ad._PushActiveDialog(ae, af)
	if ae:_FindActiveIndex(af) then
		ae:_SetActiveDialog(af)
		return
	end
	table.insert(ae.ActiveStack, af)
	ae:_SetActiveDialog(af)
end
function ad._RemoveActiveDialog(ae, af)
	local ag = ae:_FindActiveIndex(af)
	if ag then
		table.remove(ae.ActiveStack, ag)
	end
	ae:_SetActiveDialog(ae.ActiveStack[#ae.ActiveStack])
end
function ad.IsOpen(ae)
	return ae.ActiveDialog ~= nil
end
function ad.RemindActive(ae)
	local af = ae.ActiveDialog
	if not af then
		return
	end
	local ag = (af).Remind
	if type(ag) == "function" then
		ag(af)
	end
end
function ad.ShouldBlockWindowDrag(ae, af)
	local ag = ae.ActiveDialog
	if not ag then
		return false
	end
	local ah = (ag).ShouldBlockWindowDrag
	if type(ah) == "function" then
		return ah(ag, af)
	end
	return true
end
function ad._CloseActiveForReplace(ae)
	if #ae.ActiveStack == 0 then
		return
	end
	local af = table.clone(ae.ActiveStack)
	table.clear(ae.ActiveStack)
	ae:_SetActiveDialog(nil)
	for ag, ah in af do
		ah:Close("replaced")
	end
end
function ad._TrackHandle(ae, af)
	table.insert(ae.Handles, af)
end
function ad._UntrackHandle(ae, af)
	local ag = table.find(ae.Handles, af)
	if ag then
		table.remove(ae.Handles, ag)
	end
end
function ad._RequestOpen(ae, af)
	if ae.Destroying then
		return false
	end
	if ae.ActiveDialog == af then
		return true
	end
	if (af).Floating == true then
		ae:_PushActiveDialog(af)
		return true
	end
	local ag = (af).AllowStacked == true
	if ae.ActiveDialog ~= nil and not ag then
		ae:RemindActive()
		return false
	end
	if ag and #ae.ActiveStack >= 2 then
		ae:RemindActive()
		return false
	end
	ae:_PushActiveDialog(af)
	return true
end
function ad.Confirm(ae, af)
	ae:_CloseActiveForReplace()
	local ag
	ag = ab.New({
		Parent = ae.Parent,
		Data = af,
		OnClosed = function(ah, ai)
			ae:_RemoveActiveDialog(ag)
			if type(af) == "table" and type(af.OnClose) == "function" then
				aa.Call(af.OnClose, ai or { Reason = ah })
			end
		end,
	})
	ae:_PushActiveDialog(ag)
	return ag
end
function ad.Modal(ae, af)
	local ag
	ag = ac.New({
		Parent = ae.Parent,
		Window = ae.Window,
		SharedRegistry = ae.Registry,
		Data = af,
		OnClosed = function(ah, ai)
			ae:_RemoveActiveDialog(ag)
			ae:_UntrackHandle(ag)
			if type(af) == "table" and type(af.OnClose) == "function" then
				aa.Call(af.OnClose, ah, ai)
			end
		end,
		RequestOpen = function(ah)
			return ae:_RequestOpen(ah)
		end,
	})
	ae:_TrackHandle(ag)
	if not (type(af) == "table" and af.AutoOpen == false) then
		local ah = (ag).Open
		if type(ah) == "function" then
			ah(ag)
		end
	end
	return ag
end
function ad.Dismiss(ae, af)
	local ag = ae.ActiveDialog
	if not ag then
		return
	end
	ag:Close(af or "api")
end
function ad.Destroy(ae)
	if ae.Destroying then
		return
	end
	ae.Destroying = true
	for af, ag in table.clone(ae.ActiveStack) do
		local ah = (ag).IsDestroyed
		if type(ah) ~= "function" or not ah(ag) then
			ag:Destroy("api")
		end
	end
	for af, ag in ae.Handles do
		local ah = (ag).IsDestroyed
		if type(ah) ~= "function" or not ah(ag) then
			ag:Destroy("api")
		end
	end
	table.clear(ae.ActiveStack)
	table.clear(ae.Handles)
	ae:_SetActiveDialog(nil)
end
return table.freeze(ad)
end
a["UI/DragSkeleton"]=function()
local aa = d("Core/Common")
local ab, ac, ad = aa.Creator, aa.Animator, d("UI/WindowDesign")
local ae, af, ag, ah, ai, aj, ak, al =
	ab.New,
	TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	1,
	{},
	function()
		local ae = ab.GetThemeProperty("DragSkeletonStrokeTransparency")
		if type(ae) == "number" then
			return ae
		end
		return 0.72
	end,
	function()
		local ae = ab.GetThemeProperty("DragSkeletonStrokeThickness")
		if type(ae) == "number" then
			return ae
		end
		return 1.25
	end,
	function(ae)
		local af = ae.RootContainer.AbsoluteSize
		if af.X > 0 and af.Y > 0 then
			return UDim2.fromOffset(af.X, af.Y)
		end
		local ag = ae.RootContainer.Size
		if ag.X.Scale == 0 and ag.Y.Scale == 0 then
			return UDim2.fromOffset(math.max(1, ag.X.Offset), math.max(1, ag.Y.Offset))
		end
		return UDim2.fromOffset(ad.DESIGN_W, ad.DESIGN_H)
	end
local am = function(am)
	if am.DragProxy and am.DragProxy.Parent == am.Parent then
		return am.DragProxy
	end
	if am.DragProxy then
		am.DragProxy:Destroy()
		am.DragProxyStroke = nil
	end
	am.DragProxy = ae(
		"CanvasGroup",
		{
			Name = "SeaHubDragSkeleton",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = ab.GetThemeProperty("BackgroundSurface") or Color3.fromRGB(22, 22, 22),
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			GroupTransparency = 1,
			Size = UDim2.fromOffset(100, 100),
			Visible = false,
			ZIndex = 300,
			[ab.ThemeTag] = { BackgroundColor3 = "BackgroundSurface" },
			Parent = am.Parent,
		},
		{
			ae(
				"UICorner",
				{
					CornerRadius = ab.GetThemeProperty("CornerRadiusWindow") or UDim.new(0, 12),
					[ab.ThemeTag] = { CornerRadius = "CornerRadiusWindow" },
				}
			),
			ae("UIStroke", {
				Thickness = ak(),
				Transparency = ah,
				[ab.Ref] = function(an)
					am.DragProxyStroke = an
				end,
				[ab.ThemeTag] = { Color = "StrokeColor", Thickness = "DragSkeletonStrokeThickness" },
			}),
		}
	)
	return am.DragProxy
end
function ai.Begin(an)
	if not an.UseDragSkeleton then
		an.Root.GroupTransparency = 0
		if an.DragProxy then
			an.DragProxy.Visible = false
			an.DragProxy.GroupTransparency = 1
		end
		if an.DragProxyStroke then
			ac.CancelInstance(an.DragProxyStroke)
			an.DragProxyStroke.Transparency = ah
		end
		return
	end
	local ao, ap = am(an), an.DragProxyStroke
	ac.CancelInstance(ao)
	ac.CancelInstance(an.Root)
	if ap then
		ac.CancelInstance(ap)
	end
	ao.Position = an.Root.Position
	ao.Size = al(an)
	ao.Visible = true
	ao.GroupTransparency = 1
	an.Root.GroupTransparency = 0
	if ap then
		ap.Thickness = ak()
		ap.Transparency = ah
		ac.Tween(ap, { Transparency = aj() }, ag)
	end
	ac.Tween(ao, { GroupTransparency = 0 }, af)
	ac.Tween(an.Root, { GroupTransparency = 1 }, af)
end
function ai.Commit(an, ao)
	if not an.UseDragSkeleton then
		an.Root.GroupTransparency = 0
		if ao then
			ao()
		end
		return
	end
	if an.DragProxy and an.DragProxy.Visible then
		local ap = an.DragProxyStroke
		an.Root.Position = an.DragProxy.Position
		ac.CancelInstance(an.DragProxy)
		ac.CancelInstance(an.Root)
		if ap then
			ac.CancelInstance(ap)
		end
		ac.Tween(an.Root, { GroupTransparency = 0 }, af)
		ac.Tween(an.DragProxy, { GroupTransparency = 1 }, af)
		if ap then
			ac.Tween(ap, { Transparency = ah }, ag)
		end
		task.delay(ag.Time + 0.03, function()
			if an.DragProxy and not an.DragFlagArmed then
				an.DragProxy.Visible = false
			end
			if ao then
				ao()
			end
		end)
		return
	end
	an.Root.GroupTransparency = 0
	if ao then
		ao()
	end
end
function ai.SetUseSkeleton(an, ao)
	local ap = ao ~= false
	if an.UseDragSkeleton == ap then
		return
	end
	an.UseDragSkeleton = ap
	ac.CancelInstance(an.Root)
	an.Root.GroupTransparency = 0
	if an.DragProxy then
		ac.CancelInstance(an.DragProxy)
		if an.DragProxyStroke then
			ac.CancelInstance(an.DragProxyStroke)
			an.DragProxyStroke.Transparency = ah
		end
		if an.DragProxy.Visible then
			an.Root.Position = an.DragProxy.Position
		end
		an.DragProxy.Visible = false
		an.DragProxy.GroupTransparency = 1
	end
	if an.UseDragSkeleton and an.Dragging and an.IsActuallyDragging and an.DragFlagArmed then
		ai.Begin(an)
	end
end
function ai.OnWindowResized(an, ao, ap)
	if an.DragProxy then
		an.DragProxy.Size = UDim2.fromOffset(ao, ap)
	end
end
function ai.Destroy(an)
	if an.DragProxy then
		if an.DragProxyStroke then
			ac.CancelInstance(an.DragProxyStroke)
		end
		an.DragProxy:Destroy()
		an.DragProxy = nil
		an.DragProxyStroke = nil
	end
end
return ai
end
a["UI/Element"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag, ah, ai, aj, ak =
	aa.Creator,
	aa.SignalManager,
	aa.Responsive,
	aa.TabContentScroll,
	aa.WindowDrag,
	aa.CalmFlush,
	d("UI/ElementText"),
	d("Localization/Localization"),
	debug and debug.profilebegin,
	debug and debug.profileend
local al, am, an = ab.New, {}, 0
function am.GetLayoutCallCount()
	return an
end
function am.ResetLayoutCallCount()
	an = 0
end
function am.New(ao)
	local ap, aq, ar, as = ac.CreateScope(), ah.Build(ao), ao.Height or 40, ao.DescResize ~= false
	local at, e, f, g, h = aq.LabelOffsetY or 10, false, false, false
	local i = function()
		if e then
			return
		end
		an = an + 1
		if aj then
			aj("SeaHub:ElementLayout")
		end
		e = true
		f = false
		local i, j = aq.Root.AbsoluteSize.X, 0
		if aq.RowPadding then
			j = aq.RowPadding.PaddingLeft.Offset + aq.RowPadding.PaddingRight.Offset
		end
		local k, l, m = math.max(0, i - j), aq.Container.AbsoluteSize.X
		if aq.LabelHolder then
			local n = (l > 0 and { (math.max(0, k - l - 12)) } or { k })[1]
			if aq.LabelHolderConstraint then
				aq.LabelHolderConstraint.MaxSize = Vector2.new(n, 1000000)
			end
			m = math.min(n, aq.LabelHolder.AbsoluteSize.X)
		else
			m = 0
		end
		local n = aq.Row.AbsoluteSize.Y
		if aq.LabelHolder then
			n = math.max(n, aq.LabelHolder.AbsoluteSize.Y)
		end
		if aq.BelowRow then
			n = n + (8 + aq.BelowRow.AbsoluteSize.Y)
		end
		local o = at + n + 8
		if (aq.DescLabel and as) or aq.BelowRow then
			aq.Root.Size = UDim2.new(1, 0, 0, math.max(ar, o))
		end
		e = false
		if h then
			for p, q in h do
				q(k, m)
			end
		end
		if ak then
			ak()
		end
	end
	local j = function()
		if aq.Root and aq.Root.Parent then
			f = false
			i()
		end
	end
	local k = function()
		if af.IsActive() or ae.IsSuppressing() then
			ag.Register(j)
			return
		end
		if f then
			return
		end
		f = true
		task.defer(function()
			if not f then
				return
			end
			if aq.Root and aq.Root.Parent then
				i()
			end
		end)
	end
	local l = function()
		if g then
			return
		end
		g = true
		ap:Connect(aq.Root:GetPropertyChangedSignal("AbsoluteSize"), k)
		ap:Connect(aq.Container:GetPropertyChangedSignal("AbsoluteSize"), k)
		ap:Connect(aq.Row:GetPropertyChangedSignal("AbsoluteSize"), k)
		if aq.LabelHolder then
			ap:Connect(aq.LabelHolder:GetPropertyChangedSignal("AbsoluteSize"), k)
		end
		if aq.BelowRow then
			ap:Connect(aq.BelowRow:GetPropertyChangedSignal("AbsoluteSize"), k)
		end
		ap:Defer(ad.OnChanged(k))
	end
	aq.Root = al(
		"Frame",
		{
			BackgroundColor3 = ab.GetThemeProperty("Element") or Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = ab.GetThemeProperty("ElementTransparency") or 1,
			BorderSizePixel = 0,
			LayoutOrder = 7,
			Size = UDim2.new(1, 0, 0, ar),
			ClipsDescendants = true,
			[ab.ThemeTag] = { BackgroundColor3 = "Element", BackgroundTransparency = "ElementTransparency" },
		},
		{ aq.Body, aq.Divider, aq.InteractButton }
	)
	if (aq.DescLabel and as) or aq.BelowRow then
		l()
	end
	function aq.OnPostLayout(m, n)
		l()
		if not h then
			h = {}
		end
		local o = h
		table.insert(o, n)
	end
	function aq.Mount(m, n)
		m.Root.Parent = n or ao.Parent
		i()
	end
	function aq.SetTitle(m, n)
		if m.TitleLabel then
			m.TitleLabel.Text = n
		end
	end
	function aq.SetDesc(m, n)
		if m.DescLabel then
			if n and n ~= "" then
				m.DescLabel.Text = n
				m.DescLabel.Visible = true
			else
				m.DescLabel.Visible = false
			end
		end
	end
	if ai.IsTagged(ao.Title) then
		ap:Defer(ai.Attach(aq, "Title", ao.Title))
	end
	if ai.IsTagged(ao.Desc) then
		ap:Defer(ai.Attach(aq, "Desc", ao.Desc))
	end
	function aq.Destroy(m)
		f = false
		ag.Unregister(j)
		ap:Destroy()
		m.Root:Destroy()
	end
	return aq
end
return am
end
a["UI/ElementText"]=function()
local aa = d("Core/Common")
local ab, ac, ad = aa.Creator, d("UI/Attributes"), d("Localization/Localization")
local ae, af, ag =
	ab.New, {}, function(ae)
		if ae == nil then
			return nil
		end
		if ad.IsTagged(ae) then
			return ad.ResolveTag(ae)
		end
		if type(ae) == "string" then
			return ae
		end
		return tostring(ae)
	end
function af.Build(ah)
	local ai, aj, ak = {}, ag(ah.Title), ag(ah.Desc)
	ai.TitleLabel = aj
		and ae(
			"TextLabel",
			{
				FontFace = Font.new(
					ab.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
					ab.GetThemeProperty("FontWeightMedium") or Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = aj,
				TextColor3 = ab.GetThemeProperty("Text") or Color3.fromRGB(240, 240, 240),
				TextSize = ab.GetThemeProperty("TextSizeBody") or 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				[ab.ThemeTag] = { TextColor3 = "Text", TextSize = "TextSizeBody" },
			}
		)
	ai.DescLabel = ak
		and ae(
			"TextLabel",
			{
				FontFace = Font.new(
					ab.GetThemeProperty("FontFamily") or "rbxassetid://12187365364",
					ab.GetThemeProperty("FontWeightNormal") or Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				Text = ak,
				TextColor3 = ab.GetThemeProperty("SubText") or Color3.fromRGB(160, 160, 160),
				TextSize = ab.GetThemeProperty("TextSizeCaption") or 14,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				[ab.ThemeTag] = { TextColor3 = "SubText", TextSize = "TextSizeCaption" },
			}
		)
	local al = { ae("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }) }
	if ai.TitleLabel then
		table.insert(al, ai.TitleLabel)
	end
	if ai.DescLabel then
		table.insert(al, ai.DescLabel)
	end
	local am = ah.CompactChrome == true
	local an, ao, ap =
		(am and { (ah.LabelOffsetY or 0) } or { (ah.LabelOffsetY or 10) })[1],
		ah.AlignControlsTop == true,
		ah.BelowRowSlot == true
	ai.LabelOffsetY = an
	ai.BelowRowSlot = ap
	ai.Hover = ah.Hover or false
	ai.LabelHolderConstraint = nil
	local aq = (am and { nil } or { (table.clone(al)) })[1]
	if aq then
		table.insert(
			aq,
			ae("UISizeConstraint", {
				MaxSize = Vector2.new(1000000, 1000000),
				[ab.Ref] = function(ar)
					ai.LabelHolderConstraint = ar
				end,
			})
		)
	end
	ai.LabelHolder = (not am and {
		(ae(
			"Frame",
			{ BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromScale(0, 0) },
			aq
		)),
	} or { nil })[1]
	ai.Container = ae(
		"Frame",
		{
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Size = (am and { (UDim2.new(1, 0, 0, 0)) } or { (UDim2.fromScale(0, 0)) })[1],
		},
		{
			ae(
				"UIListLayout",
				{
					Padding = UDim.new(0, 6),
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = (am and { Enum.HorizontalAlignment.Left } or {
						Enum.HorizontalAlignment.Right,
					})[1],
				}
			),
		}
	)
	local ar = ae(
		"UIListLayout",
		{
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = (am and { nil } or { Enum.UIFlexAlignment.SpaceBetween })[1],
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = (ao and { Enum.VerticalAlignment.Top } or { Enum.VerticalAlignment.Center })[1],
			Padding = UDim.new(0, 12),
		}
	)
	local as = { ar }
	if am then
		table.insert(as, ai.Container)
	else
		table.insert(as, ai.LabelHolder)
		table.insert(as, ai.Container)
	end
	ai.Row = ae(
		"Frame",
		{ Name = "Row", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0) },
		as
	)
	ai.BelowRow = ap
			and ae(
				"Frame",
				{ Name = "BelowRow", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(
					1,
					0,
					0,
					0
				) }
			)
		or nil
	local at = ap
			and ae(
				"Frame",
				{ Name = "BodyStack", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(
					1,
					0,
					0,
					0
				) },
				{
					ae(
						"UIListLayout",
						{
							FillDirection = Enum.FillDirection.Vertical,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 6),
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
						}
					),
					ai.Row,
					ai.BelowRow,
				}
			)
		or nil
	ai.RowPadding = ae(
		"UIPadding",
		{
			PaddingTop = UDim.new(0, an),
			PaddingLeft = (
				am and { (UDim.new(0, 0)) } or { (ab.GetThemeProperty("PaddingElement") or UDim.new(0, 14)) }
			)[1],
			PaddingRight = (
				am and { (UDim.new(0, 0)) } or { (ab.GetThemeProperty("PaddingElement") or UDim.new(0, 14)) }
			)[1],
			[ab.ThemeTag] = am and {} or { PaddingLeft = "PaddingElement", PaddingRight = "PaddingElement" },
		}
	)
	local e = { ai.RowPadding }
	if ap and at then
		table.insert(e, at)
	else
		table.insert(e, ai.Row)
	end
	ai.Body = ae(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
		},
		e
	)
	ai.InteractButton = ah.Hover
			and ae("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5 })
		or nil
	ai.Divider = (ah.HasDivider ~= false)
			and ae(
				"Frame",
				{
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = ab.GetThemeProperty("DividerColor") or Color3.fromRGB(70, 70, 70),
					BackgroundTransparency = ab.GetThemeProperty("DividerTransparency") or 0.7,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.new(1, 0, 0, 1),
					[ab.ThemeTag] = { BackgroundColor3 = "DividerColor", BackgroundTransparency = "DividerTransparency" },
				}
			)
		or nil
	if ai.Divider then
		ai.Divider:SetAttribute(ac.IsDivider, true)
	end
	return ai
end
return af
end
a["UI/InfoPanel"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag = aa.SignalManager, d("UI/InfoPanelData"), d("UI/InfoPanelContent"), d("UI/InfoPanelPlan"), 1, {}
function ag.New(ah, ai)
	ai = (type(ai) == "table" and { ai } or { {} })[1]
	local aj, ak, al =
		(type(ai.Title) == "string" and ai.Title ~= "" and { ai.Title } or { "Information" })[1],
		tonumber(ai.RefreshInterval) or af,
		function(aj, ak)
			return (aj == nil and { ak } or { (aj == true) })[1]
		end
	local am, an = ae.Plan({
		UserColumns = ac.NormalizeData(ai.Data),
		MergeFirst = al(ai.MergeFirstColumn, false),
		ShowAccount = al(ai.ShowAccount, true),
		ShowServer = al(ai.ShowServer, true),
		ShowClient = al(ai.ShowClient, true),
	})
	local ao, ap =
		math.clamp(math.max(am, tonumber(ai.MinWidth) or 0), 240, 880),
		math.clamp(math.max(an, tonumber(ai.MinHeight) or 0), 160, 680)
	local aq, ar = math.clamp(tonumber(ai.MaxWidth) or 880, ao, 880), math.clamp(tonumber(ai.MaxHeight) or 680, ap, 680)
	local as, at, e, f, g =
		math.clamp(math.max(tonumber(ai.Width) or 0, ao), ao, aq),
		math.clamp(math.max(tonumber(ai.Height) or 0, ap), ap, ar),
		{ Modal = nil }
	local h = function()
		if g then
			g:Destroy()
			g = nil
		end
	end
	local i = function()
		h()
		if ak <= 0 then
			return
		end
		g = ab.CreateScope()
		local i = g
		task.spawn(function()
			while g == i and e.Modal and e.Modal:IsOpen() do
				task.wait(ak)
				if g == i and f and e.Modal and e.Modal:IsOpen() then
					f:Refresh()
				end
			end
		end)
	end
	e.Modal = ah:Modal({
		Title = aj,
		Width = as,
		Height = at,
		Draggable = true,
		Resizable = ai.Resizable == nil and true or ai.Resizable == true,
		MinWidth = ao,
		MinHeight = ap,
		MaxWidth = aq,
		MaxHeight = ar,
		AllowStacked = true,
		AllowOverlayDismiss = (ai.AllowOverlayDismiss == nil and { false } or { (ai.AllowOverlayDismiss == true) })[1],
		ShowCloseButton = ai.ShowCloseButton ~= false,
		AutoOpen = false,
		OnClose = function(j)
			h()
			if type(ai.OnClose) == "function" then
				ai.OnClose(j)
			end
		end,
		Build = function(j)
			f = ad.New({ Modal = j, Identity = ac.GetIdentity(), Raw = ai })
		end,
	})
	if not e.Modal then
		return e
	end
	function e.Open(j)
		if not j.Modal then
			return false
		end
		local k = j.Modal:Open()
		if k then
			i()
		end
		return k
	end
	function e.Refresh(j)
		if f then
			f:Refresh()
		end
	end
	function e.SetTitle(j, k)
		if j.Modal then
			j.Modal:SetTitle(k)
		end
	end
	function e.IsOpen(j)
		return j.Modal ~= nil and j.Modal:IsOpen()
	end
	function e.Close(j, k)
		if j.Modal then
			j.Modal:Close(k)
		end
	end
	function e.Destroy(j, k)
		h()
		if j.Modal then
			j.Modal:Destroy(k)
		end
	end
	if not (ai.AutoOpen == false) then
		e:Open()
	end
	return e
end
return table.freeze(ag)
end
a["UI/InfoPanelContent"]=function()
local aa, ab, ac, ad, ae = d("UI/InfoPanelData"), d("UI/InfoPanelUserCard"), d("UI/InfoPanelStats"), d("UI/InfoPanelGrid"), {}
ae.__index = ae
local af = function(af, ag)
	if af == nil then
		return ag
	end
	return af == true
end
function ae.New(ag)
	local ah = setmetatable({}, ae)
	ah.Modal = ag.Modal
	ah.Identity = ag.Identity
	ah.Raw = ag.Raw
	ah.ShowAccount = af(ag.Raw.ShowAccount, true)
	ah.ShowServer = af(ag.Raw.ShowServer, true)
	ah.ShowClient = af(ag.Raw.ShowClient, true)
	ah.Server = nil
	ah.Client = nil
	ah.Dynamic = {}
	ah.BuiltInColumn = 1
	ah:SetupColumns()
	if ah.ShowAccount then
		ah:BuildAccount()
	end
	ah:RefreshServer()
	ah:RefreshClient()
	ah:RefreshDynamic()
	return ah
end
function ae.UserColumn(ag, ah)
	if ag.MergeFirst then
		return ah == 1 and 1 or ah
	end
	return ah + 1
end
function ae.SetupColumns(ag)
	local ah = aa.NormalizeData(ag.Raw.Data)
	ag.UserColumns = ah
	ag.MergeFirst = af(ag.Raw.MergeFirstColumn, false) and #ah > 0
	local ai = 1 + #ah - (ag.MergeFirst and 1 or 0)
	ag.ColumnCount = math.max(1, ai)
	ag.BuiltInRow = 0
	ag.ColumnHost = ad.New({ Parent = ag:ScrollParent(), Count = ag.ColumnCount })
end
function ae.ScrollParent(ag)
	return ag.Modal.ScrollFrame or ag.Modal.Container
end
function ae.NextBuiltInRow(ag)
	ag.BuiltInRow = ag.BuiltInRow + 1
	return ag.BuiltInRow
end
function ae.MakeSection(ag, ah, ai, aj)
	local ak = ag.Modal:AddSection(ah)
	if ag.ColumnHost and ak.Root then
		ak.Root.Parent = ag.ColumnHost:GetCell(ai, aj)
	end
	return ak
end
local ag = function(ag, ah, ai, aj)
	local ak = ag:AddInfoRow({ Title = ah, Value = ai, Variant = aj })
	return { Title = ah, Handle = ak }
end
function ae.BuildAccount(ah)
	local ai, aj = ah.Identity, ah:MakeSection("Account", ah:NextBuiltInRow(), 1)
	local ak = ab.UserCard({
		Headshot = aa.GetHeadshot(ai.RawUserId),
		DisplayName = ai.DisplayName,
		Username = ai.Username,
		UserId = ai.UserId,
	})
	ak.Parent = aj.Container
end
function ae.RefreshServer(ah)
	if not ah.ShowServer then
		return
	end
	local ai = aa.GetServerInfo()
	local aj = ("%d / %d"):format(ai.PlayerCount, ai.MaxPlayers)
	if not ah.Server then
		local ak = ah:MakeSection("Server", ah:NextBuiltInRow(), 1)
		ah.Server = {
			Title = "Server",
			Section = ak,
			Rows = { ag(ak, "Players", aj), ag(ak, "Server Time", ai.ServerTime), ag(ak, "Uptime", ai.Uptime) },
		}
		return
	end
	ah.Server.Rows[1].Handle:SetValue(aj)
	ah.Server.Rows[2].Handle:SetValue(ai.ServerTime)
	ah.Server.Rows[3].Handle:SetValue(ai.Uptime)
end
local ah, ai =
	function(ah)
		return ah >= 50 and "TextSuccess" or (ah >= 30 and "TextWarning" or "TextDestructive")
	end, function(ah)
		return ah <= 80 and "TextSuccess" or (ah <= 160 and "TextWarning" or "TextDestructive")
	end
function ae.RefreshClient(aj)
	if not aj.ShowClient then
		return
	end
	local ak, al = ac.GetFps(), ac.GetPing()
	local am, an, ao =
		tostring(ak) .. " FPS",
		(al and { (tostring(al) .. " ms") } or { "\u{2014}" })[1],
		(al and { (ai(al)) } or { "TextMuted" })[1]
	if not aj.Client then
		local ap = aj:MakeSection("Client", aj:NextBuiltInRow(), 1)
		aj.Client = { Title = "Client", Section = ap, Rows = { ag(ap, "FPS", am, ah(ak)), ag(ap, "Ping", an, ao) } }
		return
	end
	aj.Client.Rows[1].Handle:SetValue(am, ah(ak))
	aj.Client.Rows[2].Handle:SetValue(an, ao)
end
function ae.PlanDynamic(aj)
	local ak, al = {}, aj.UserColumns or {}
	for am, an in ipairs(al) do
		local ao = aj:UserColumn(am)
		local ap, aq = (ao == 1 and { (aj.BuiltInRow or 0) } or { 0 })[1], 0
		for ar, as in an.Sections do
			if #as.Rows > 0 then
				aq = aq + 1
				local at = (as.Title ~= "" and { as.Title } or { "Info" })[1]
				table.insert(ak, { Title = at, Rows = as.Rows, Row = ap + aq, Column = ao })
			end
		end
	end
	return ak
end
local aj = function(aj, ak)
	if #aj ~= #ak then
		return false
	end
	for al, am in aj do
		local an = ak[al]
		if not an or am.Title ~= an.Title or #am.Rows ~= #an.Rows or am.Row ~= an.Row or am.Column ~= an.Column then
			return false
		end
		for ao, ap in am.Rows do
			if ap.Title ~= an.Rows[ao].Title then
				return false
			end
		end
	end
	return true
end
function ae.ClearDynamic(ak)
	for al, am in ak.Dynamic do
		for an, ao in am.Rows do
			ao.Handle:Destroy()
		end
		if am.Section.Root then
			am.Section.Root:Destroy()
		end
	end
	ak.Dynamic = {}
end
function ae.RefreshDynamic(ak)
	local al = ak:PlanDynamic()
	if aj(ak.Dynamic, al) then
		for am, an in ak.Dynamic do
			for ao, ap in an.Rows do
				local aq = al[am].Rows[ao]
				ap.Handle:SetValue(aq.Value, aq.Variant)
			end
		end
		return
	end
	ak:ClearDynamic()
	for am, an in al do
		local ao, ap = ak:MakeSection(an.Title, an.Row, an.Column), {}
		for aq, ar in an.Rows do
			table.insert(ap, ag(ao, ar.Title, ar.Value, ar.Variant))
		end
		table.insert(ak.Dynamic, { Title = an.Title, Section = ao, Rows = ap, Row = an.Row, Column = an.Column })
	end
end
function ae.Refresh(ak)
	ak:RefreshServer()
	ak:RefreshClient()
	ak:RefreshDynamic()
end
return ae
end
a["UI/InfoPanelData"]=function()
local aa, ab, ac, ad = game:GetService("Players"), game:GetService("Workspace"), d("Core/SafeCall"), {}
ad.SeaLogo = "rbxassetid://78362564258186"
local ae = {
	Default = true,
	Accent = true,
	Outline = true,
	Destructive = true,
	Warning = true,
	Success = true,
	Info = true,
	Muted = true,
	TextAccent = true,
	TextDestructive = true,
	TextWarning = true,
	TextSuccess = true,
	TextInfo = true,
	TextMuted = true,
}
function ad.Resolve(af)
	if type(af) == "function" then
		local ag, ah = ac.Call(af)
		return (ag and { ah } or { nil })[1]
	end
	return af
end
function ad.ResolveText(af, ag)
	local ah = ad.Resolve(af)
	if ah == nil then
		return ag or ""
	end
	return (type(ah) == "string" and { ah } or { (tostring(ah)) })[1]
end
function ad.NormalizeVariant(af)
	if type(af) == "string" and ae[af] and af ~= "Default" then
		return af
	end
	return nil
end
local af = function(af)
	if type(af) ~= "table" then
		return nil
	end
	return {
		Title = ad.ResolveText(af.Title, ""),
		Value = ad.ResolveText(af.Value, "\u{2014}"),
		Variant = ad.NormalizeVariant(af.Variant),
	}
end
local ag = function(ag)
	local ah, ai = ad.Resolve(ag), {}
	if type(ah) ~= "table" then
		return ai
	end
	for aj, ak in ipairs(ah) do
		local al = af(ak)
		if al then
			table.insert(ai, al)
		end
	end
	return ai
end
local ah = function(ah)
	local ai = ad.Resolve(ah)
	if type(ai) ~= "table" then
		return nil
	end
	local aj = ad.ResolveText(ai.Title, "")
	return { Title = aj, Rows = ag(ai.Rows) }
end
function ad.NormalizeData(ai)
	local aj, ak = ad.Resolve(ai), {}
	if type(aj) ~= "table" then
		return ak
	end
	for al, am in ipairs(aj) do
		local an, ao = ad.Resolve(am), {}
		if type(an) == "table" then
			for ap, aq in ipairs(an) do
				local ar = ah(aq)
				if ar then
					table.insert(ao, ar)
				end
			end
		end
		table.insert(ak, { Sections = ao })
	end
	return ak
end
function ad.GetIdentity()
	local ai = aa.LocalPlayer
	local aj = (ai and { ai.Name } or { "" })[1]
	local ak, al = (ai and ai.DisplayName ~= "" and { ai.DisplayName } or { aj })[1], (ai and { ai.UserId } or { 0 })[1]
	return { Username = aj, DisplayName = ak, UserId = tostring(al), RawUserId = al }
end
function ad.GetHeadshot(ai)
	if not ai or ai <= 0 then
		return ""
	end
	return ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(ai)
end
function ad.FormatUptime(ai)
	local aj = math.max(0, math.floor(ai))
	local ak, al, am = math.floor(aj / 3600), math.floor((aj % 3600) / 60), aj % 60
	if ak >= 1 then
		return ("%dh %dm %ds"):format(ak, al, am)
	end
	if al >= 1 then
		return ("%dm %ds"):format(al, am)
	end
	return ("%ds"):format(am)
end
function ad.GetServerInfo()
	return {
		PlayerCount = #aa:GetPlayers(),
		MaxPlayers = aa.MaxPlayers,
		ServerTime = os.date("%H:%M:%S"),
		Uptime = ad.FormatUptime(ab.DistributedGameTime),
	}
end
return table.freeze(ad)
end
a["UI/InfoPanelGrid"]=function()
local aa = d("Core/Common")
local ab = aa.Creator
local ac, ad = ab.New, {}
ad.__index = ad
local ae = function(ae, af)
	local ag = ab.GetThemeProperty(ae)
	return (ag ~= nil and { ag } or { af })[1]
end
function ad.New(af)
	local ag = setmetatable({}, ad)
	ag.Count = math.max(1, math.floor(af.Count))
	ag.Bands = {}
	ag.Root = ac(
		"Frame",
		{
			Name = "InfoPanelGrid",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = af.Parent,
		},
		{
			ac(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Vertical,
					Padding = ae("GapSection", UDim.new(0, 16)),
					SortOrder = Enum.SortOrder.LayoutOrder,
					[ab.ThemeTag] = { Padding = "GapSection" },
				}
			),
		}
	)
	return ag
end
function ad.EnsureBand(af, ag)
	local ah = af.Bands[ag]
	if ah then
		return ah
	end
	local ai, aj =
		{},
		{
			ac(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = ae("GapColumns", UDim.new(0, 12)),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					[ab.ThemeTag] = { Padding = "GapColumns" },
				}
			),
		}
	for ak = 1, af.Count do
		local al = ac(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = ak,
				Size = UDim2.fromOffset(0, 0),
			},
			{
				ac("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }),
				ac(
					"UIListLayout",
					{
						Padding = ae("GapSection", UDim.new(0, 16)),
						SortOrder = Enum.SortOrder.LayoutOrder,
						[ab.ThemeTag] = { Padding = "GapSection" },
					}
				),
			}
		)
		ai[ak] = al
		table.insert(aj, al)
	end
	local ak = ac(
		"Frame",
		{
			Name = "Band" .. ag,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = ag,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = af.Root,
		},
		aj
	)
	local al = { Frame = ak, Cells = ai }
	af.Bands[ag] = al
	return al
end
function ad.GetCell(af, ag, ah)
	local ai, aj = math.max(1, math.floor(ag or 1)), math.clamp(math.floor(ah or 1), 1, af.Count)
	return af:EnsureBand(ai).Cells[aj]
end
function ad.Destroy(af)
	if af.Root then
		af.Root:Destroy()
		af.Root = nil
	end
	table.clear(af.Bands)
end
return ad
end
a["UI/InfoPanelPlan"]=function()
local aa, ab, ac, ad, ae, af, ag, ah, ai, aj, ak, al, am, an, ao, ap, aq, ar =
	{}, 0.55, 16, 15, 12, 12, 18, 28, 188, 12, 16, 20, 49, 16, 24, 36, 30, 72
local as = function(as, at)
	return math.ceil(#as * at * ab)
end
local at = function(at)
	local e, f = as(at.Title, ac), as(at.Value, ad)
	if at.Variant then
		f = f + ag
	end
	return e + af + f + ah
end
local e, f =
	function(e)
		local f = as(e.Title, ae) + ah
		for g, h in e.Rows do
			f = math.max(f, at(h))
		end
		return f
	end, function(e)
		return aq + #e.Rows * ap
	end
function aa.FromColumns(g)
	local h = #g
	if h == 0 then
		return 0, 0
	end
	local i, j = 0, 0
	for k, l in g do
		i = math.max(i, l.Width)
		j = math.max(j, l.Height)
	end
	local k, l = h * i + (h - 1) * aj + al + an, j + am + al + ao
	return math.ceil(k), math.ceil(l)
end
local g, h =
	{ { Title = "Players", Value = "00 / 00" }, { Title = "Server Time", Value = "00:00:00" }, {
		Title = "Uptime",
		Value = "00h 00m 00s",
	} },
	{ { Title = "FPS", Value = "000 FPS", Variant = "TextSuccess" }, {
		Title = "Ping",
		Value = "000 ms",
		Variant = "TextSuccess",
	} }
function aa.Plan(i)
	local j = 1 + #i.UserColumns - (i.MergeFirst and 1 or 0)
	j = math.max(1, j)
	local k, l = table.create(j, 0), table.create(j, 0)
	local m = function(m, n, o)
		if m < 1 or m > j then
			return
		end
		k[m] = math.max(k[m], n)
		if l[m] > 0 then
			l[m] = l[m] + ak
		end
		l[m] = l[m] + o
	end
	if i.ShowAccount then
		m(1, ai, ar)
	end
	if i.ShowServer then
		m(1, e({ Title = "SERVER", Rows = g }), f({ Rows = g }))
	end
	if i.ShowClient then
		m(1, e({ Title = "CLIENT", Rows = h }), f({ Rows = h }))
	end
	for n, o in ipairs(i.UserColumns) do
		local p = (i.MergeFirst and { (n == 1 and 1 or n) } or { (n + 1) })[1]
		for q, r in o.Sections do
			if #r.Rows > 0 then
				m(p, e(r), f(r))
			end
		end
	end
	local n = {}
	for o = 1, j do
		n[o] = { Width = k[o], Height = l[o] }
	end
	return aa.FromColumns(n)
end
return table.freeze(aa)
end
a["UI/InfoPanelStats"]=function()
local aa, ab = game:GetService("RunService"), {}
local ac, ad, ae, af = (aa:IsRunning() and { time } or { os.clock })[1], {}, false, 0
local ag = function()
	local ag = ac()
	for ah = #ad, 1, -1 do
		ad[ah + 1] = (ad[ah] >= ag - 1 and { ad[ah] } or { nil })[1]
	end
	ad[1] = ag
end
local ah = function()
	if ae then
		return
	end
	ae = true
	af = ac()
	aa.Heartbeat:Connect(ag)
end
function ab.GetFps()
	ah()
	local ai, aj = ac() - af, #ad
	if ai >= 1 then
		return math.floor(aj)
	end
	if ai <= 0 then
		return aj
	end
	return math.floor(aj / ai)
end
function ab.GetPing()
	local ai, aj = pcall(function()
		local ai = game:GetService("Stats")
		local aj = ai.Network.ServerStatsItem["Data Ping"]
		return aj:GetValue()
	end)
	if ai and type(aj) == "number" and aj == aj then
		return math.floor(aj)
	end
	return nil
end
return table.freeze(ab)
end
a["UI/InfoPanelUserCard"]=function()
local aa = d("Core/Common")
local ab = aa.Creator
local ac, ad, ae, af, ag =
	ab.New, {}, "rbxassetid://12187365364", 44, function(ac, ad)
		local ae = ab.GetThemeProperty(ac)
		return (ae ~= nil and { ae } or { ad })[1]
	end
local ah, ai =
	function(ah, ai)
		return Font.new(ag("FontFamily", ae), ag(ah, ai), Enum.FontStyle.Normal)
	end, function(ah)
		return ac("Frame", { BackgroundColor3 = ag("BackgroundElevated", Color3.fromRGB(22, 24, 28)), BorderSizePixel = 0, LayoutOrder = 1, Size = UDim2.fromOffset(af, af), [ab.ThemeTag] = { BackgroundColor3 = "BackgroundElevated" } }, { ac("UICorner", { CornerRadius = ag("CornerRadiusFull", UDim.new(1, 0)), [ab.ThemeTag] = { CornerRadius = "CornerRadiusFull" } }), ac("UIStroke", { Color = ag("StrokeColor", Color3.fromRGB(240, 240, 240)), Transparency = ag("StrokeTransparency", 0.9), Thickness = ag("StrokeThickness", 1), [ab.ThemeTag] = { Color = "StrokeColor", Transparency = "StrokeTransparency", Thickness = "StrokeThickness" } }), ac("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = ah, Position = UDim2.fromScale(0.5, 0.5), ScaleType = Enum.ScaleType.Fit, Size = UDim2.fromScale(1, 1) }, { ac("UICorner", { CornerRadius = ag("CornerRadiusFull", UDim.new(1, 0)), [ab.ThemeTag] = { CornerRadius = "CornerRadiusFull" } }) }) })
	end
function ad.UserCard(aj)
	return ac(
		"Frame",
		{ AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) },
		{
			ac(
				"UIPadding",
				{
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = ag("PaddingElement", UDim.new(0, 14)),
					PaddingRight = ag("PaddingElement", UDim.new(0, 14)),
					[ab.ThemeTag] = { PaddingLeft = "PaddingElement", PaddingRight = "PaddingElement" },
				}
			),
			ac(
				"UIListLayout",
				{
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 12),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}
			),
			ai(aj.Headshot),
			ac(
				"Frame",
				{
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.new(1, -(af + 12), 0, 0),
				},
				{
					ac("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
					ac(
						"TextLabel",
						{
							BackgroundTransparency = 1,
							FontFace = ah("FontWeightSemiBold", Enum.FontWeight.SemiBold),
							LayoutOrder = 1,
							Size = UDim2.new(1, 0, 0, 19),
							Text = ("%s  (%s)"):format(aj.DisplayName, aj.Username),
							TextColor3 = ag("Text", Color3.fromRGB(240, 240, 240)),
							TextSize = ag("TextSizeSmall", 15),
							TextTruncate = Enum.TextTruncate.AtEnd,
							TextXAlignment = Enum.TextXAlignment.Left,
							[ab.ThemeTag] = { TextColor3 = "Text", TextSize = "TextSizeSmall" },
						}
					),
					ac(
						"TextLabel",
						{
							BackgroundTransparency = 1,
							FontFace = ah("FontWeightMedium", Enum.FontWeight.Medium),
							LayoutOrder = 2,
							Size = UDim2.new(1, 0, 0, 15),
							Text = ("ID: %s"):format(aj.UserId),
							TextColor3 = ag("SubText", Color3.fromRGB(160, 160, 160)),
							TextSize = ag("TextSizeCategory", 12),
							TextTruncate = Enum.TextTruncate.AtEnd,
							TextXAlignment = Enum.TextXAlignment.Left,
							[ab.ThemeTag] = { TextColor3 = "SubText", TextSize = "TextSizeCategory" },
						}
					),
				}
			),
		}
	)
end
return table.freeze(ad)
end
a["UI/Modal"]=function()
local aa, ab, ac = game:GetService("UserInputService"), game:GetService("RunService"), d("Core/Common")
local ad, ae, af, ag, ah, ai, aj, ak, al, am, an, ao, ap, aq =
	ac.Creator, d("Core/SafeCall"), d("UI/DialogConfig"), d("UI/DialogBuilder"), d("UI/ModalBuilder"), d("UI/WindowDragger"), d("UI/ModalResizer"), d("UI/ModalStack"), d("UI/Attributes"), {}, function(ad, ae)
		if not ad or not ad.Parent then
			return false
		end
		local af, ag = ad.AbsolutePosition, ad.AbsoluteSize
		return ae.X >= af.X and ae.X <= af.X + ag.X and ae.Y >= af.Y and ae.Y <= af.Y + ag.Y
	end, function(ad)
		while ad do
			if ad:IsA("ScreenGui") then
				return ad
			end
			ad = ad.Parent
		end
		return nil
	end, ac.AnimTokens.Info(0.1, ac.AnimTokens.Easing.Standard), ac.AnimTokens.Preset.Settle
function am.New(ar)
	local as = ar.Data
	local at, e, f, g, h, i, j, k, l, m, n =
		type(as) == "table" and rawget(as, "Width") ~= nil,
		type(as) == "table" and rawget(as, "Height") ~= nil,
		af.NormalizeModalConfig(ar.Data),
		false,
		false,
		0,
		ac.SignalManager.CreateScope(),
		{}
	(k).AllowStacked = f.AllowStacked == true
	(k).Floating = f.Draggable == true
	local o = (f.Draggable and { (ao(ar.Parent) or ar.Parent) } or { ar.Parent })[1]
	local p = ag.BuildModal({
		Parent = o,
		Title = f.Title,
		Width = f.Width,
		Height = f.Height,
		ShowCloseButton = f.ShowCloseButton,
		ShowTitleBar = f.ShowTitleBar,
		NoBackdrop = f.Draggable,
		Resizable = f.Draggable and f.Resizable,
		OnCloseButtonActivated = function()
			(k):Close("close_button")
		end,
	})
	p.Scroll:SetAttribute(al.ModalManagedSize, true)
	p.Root.Visible = false
	local q = (f.SnapshotMode == "Shared" and { ar.SharedRegistry } or { nil })[1]
	local r = ah.New({ Parent = p.Scroll, Window = ar.Window, Registry = q });
	(k).ScrollFrame = p.Scroll;
	(k).Container = p.Scroll
	local s, t
	if f.Draggable then
		t = {
			Root = p.Root,
			Contains = function(u)
				return an(p.PanelContent or p.PanelWrapper, Vector3.new(u.X, u.Y, 0))
			end,
			IsOpen = function()
				return h and not g
			end,
		}
		s = ak.Register(t)
	end
	local u = function()
		if m then
			m:Destroy()
			m = nil
		end
		if n then
			n:Destroy()
			n = nil
		end
		if l then
			l:Destroy()
			l = nil
		end
	end
	local v, w =
		function()
			u()
			l = ac.SignalManager.CreateScope()
			local v = l
			if p.OverlayButton and f.AllowOverlayDismiss then
				v:Connect(p.OverlayButton.Activated, function()
					(k):Close("overlay")
				end)
			end
			if f.AllowEscDismiss then
				v:Connect(aa.InputBegan, function(w, x)
					if x or not h then
						return
					end
					if w.KeyCode == Enum.KeyCode.Escape then
						(k):Close("esc")
					end
				end)
			end
			if f.Draggable and p.TitleBar then
				m = ai.New({ Parent = o, Root = p.PanelWrapper, RootContainer = (p.PanelContent or p.PanelWrapper), UseDragSkeleton = ar.Window and ar.Window.GetUseDragSkeleton and ar.Window:GetUseDragSkeleton() or false })
				v:Connect(p.TitleBar.InputBegan, function(w)
					m:OnInputBegan(w)
				end)
				v:Connect(aa.InputEnded, function(w)
					m:OnInputEnded(w)
					if n then
						n:OnInputEnded(w)
					end
				end)
				v:Connect(aa.InputChanged, function(w)
					m:OnInputChanged(w)
					if n then
						n:OnInputChanged(w)
					end
				end)
				v:Connect(ab.RenderStepped, function()
					m:OnRenderStepped()
					if n then
						n:OnRenderStepped()
					end
				end)
				if f.Resizable and p.ResizeHandle then
					n = aj.New({ Root = p.PanelWrapper, Bleed = ag.Bleed or 20, MinSize = Vector2.new(f.MinWidth, f.MinHeight), MaxSize = Vector2.new(f.MaxWidth, f.MaxHeight) })
					v:Connect(p.ResizeHandle.InputBegan, function(w)
						n:OnInputBegan(w)
					end)
				end
			end
		end, function(v, w, x)
			if g or h or i ~= v then
				return
			end
			ar.OnClosed(w, x)
		end
	function k.Open(x)
		if g then
			return false
		end
		if h then
			return true
		end
		if ar.RequestOpen and not ar.RequestOpen(k) then
			return false
		end
		i = i + 1
		h = true
		p.Root.Visible = true
		v()
		if t then
			ak.Raise(t)
		end
		af.AnimateOpen(p, ad.GetThemeProperty("DialogOverlayTransparency") or 0.4)
		return true
	end
	function k.AddSection(x, y)
		return r:AddSection(y)
	end
	function k.AddColorPicker(x, y, z)
		return r:AddColorPicker(y, z)
	end
	function k.SetTitle(x, y)
		if p.TitleLabel then
			p.TitleLabel.Text = y
		end
	end
	function k.Close(x, y, z)
		if g or not h then
			return
		end
		h = false
		i = i + 1
		local A = i
		u()
		local B = af.AnimateClose(p)
		task.delay(B + 0.03, function()
			if g or h or i ~= A then
				return
			end
			if p.Root then
				p.Root.Visible = false
			end
			w(A, y or "api", z)
		end)
	end
	function k.Destroy(x, y, z)
		if g then
			return
		end
		local A = h
		g = true
		h = false
		i = i + 1
		u()
		if s then
			s()
			s = nil
		end
		j:Destroy()
		r:Destroy()
		p.Root:Destroy()
		if A then
			ar.OnClosed(y or "api", z)
		end
	end
	function k.IsOpen(x)
		return h
	end
	function k.IsDestroyed(x)
		return g
	end
	function k.Remind(x)
		if g or not h or not p.PanelScale then
			return
		end
		local y = p.PanelScale
		ac.Animator.Tween(y, { Scale = ac.AnimTokens.Scale.BouncePeak }, ap).Completed:Once(function()
			if g or not h or not y.Parent then
				return
			end
			ac.Animator.Tween(y, { Scale = 1 }, aq)
		end)
	end
	function k.ShouldBlockWindowDrag(x, y)
		if not h then
			return false
		end
		if f.Draggable then
			local z = (p.PanelContent or p.PanelWrapper)
			return an(z, y.Position)
		end
		return true
	end
	if p.CloseButton and p.CloseIcon and f.ShowCloseButton then
		j:Connect(p.CloseButton.MouseEnter, function()
			ac.Animator.Tween(
				p.CloseIcon,
				{ ImageColor3 = ad.GetThemeProperty("DialogCloseIconHover") or Color3.fromRGB(240, 240, 240) },
				0.12
			)
		end)
		j:Connect(p.CloseButton.MouseLeave, function()
			ac.Animator.Tween(
				p.CloseIcon,
				{ ImageColor3 = ad.GetThemeProperty("DialogCloseIcon") or Color3.fromRGB(240, 240, 240) },
				0.12
			)
		end)
	end
	if f.Build then
		ae.Call(f.Build, k)
	end
	local x = p.Scroll
	local y = x:GetAttribute(al.ModalWantsColorPickerSize) == true
	if y and (not at or not e) then
		local z, A =
			(at and { f.Width } or { af.COLOR_PICKER_MODAL_WIDTH })[1],
			(e and { f.Height } or {
				(f.ShowTitleBar and { af.COLOR_PICKER_MODAL_HEIGHT } or { af.COLOR_PICKER_MODAL_BODY_HEIGHT })[1],
			})[1]
		ag.ApplyContentBounds(p, z, A, f.Draggable == true)
	end
	x:SetAttribute(al.ModalManagedSize, nil)
	x:SetAttribute(al.ModalWantsColorPickerSize, nil)
	return k
end
return table.freeze(am)
end
a["UI/ModalBuilder"]=function()
local aa, ab, ac, ad, ae, af, ag =
	d("Elements/Section"),
	d("Elements/ColorPickerPanel"),
	d("UI/Attributes"),
	d("Elements/ConfigPrep"),
	d("Core/Logger"),
	{
		"AddLabel",
		"AddParagraph",
		"AddToggle",
		"AddButton",
		"AddSlider",
		"AddInput",
		"AddSelect",
		"AddDropdown",
		"AddColorPicker",
		"AddInfoRow",
	},
	{}
ag.__index = ag
local ah = function(ah, ai)
	local aj = {
		Type = ah.Type,
		Title = ah.Title,
		Root = ah.Root,
		Container = ah.Container,
		ScrollFrame = ah.ScrollFrame,
		Window = ah.Window,
		ColumnCount = ah.ColumnCount,
	}
	for ak, al in af do
		aj[al] = function(am, ...)
			local an = ah[al](ah, ...)
			if an then
				table.insert(ai, an)
			end
			return an
		end
	end
	return aj
end
function ag.New(ai)
	local aj = setmetatable({}, ag)
	aj.Parent = ai.Parent
	aj.Window = ai.Window
	aj.Registry = ai.Registry
	aj.Sections = {}
	aj.TrackedElements = {}
	return aj
end
local ai = function(ai, aj)
	local ak, al = ai, aj
	if type(ai) == "table" and aj == nil then
		al = ai
		ak = al.Title or ""
	end
	local am
	if type(al) == "table" and type(al.Idx) == "string" and al.Idx ~= "" then
		am = al.Idx
	elseif type(ak) == "string" and ak ~= "" then
		am = ak
	end
	return tostring(ak or ""), al, am
end
function ag.AddColorPicker(aj, ak, al)
	local am = aj.Parent
	if am and am:IsA("ScrollingFrame") and am:GetAttribute(ac.ModalManagedSize) == true then
		am:SetAttribute(ac.ModalWantsColorPickerSize, true)
	end
	local an, ao, ap = ai(ak, al)
	ao = ad.PrepareConfig("ColorPicker", ao, ap, aj.Window)
	local aq =
		ab:New(an, ao, { Container = aj.Parent, ScrollFrame = aj.Parent, Window = aj.Window, Registry = aj.Registry })
	if not aq then
		return nil
	end
	aj._ElementOrder = (aj._ElementOrder or 0) + 1
	if aq.Root then
		aq.Root.LayoutOrder = aj._ElementOrder
	end
	if ap then
		aq._SnapshotMeta = {
			Idx = ap,
			Title = (type(ao) == "table" and type(ao.Title) == "string" and { ao.Title } or { (tostring(an or "")) })[1],
			Desc = (type(ao) == "table" and type(ao.Desc) == "string" and { ao.Desc } or { nil })[1],
		}
	end
	if aq.Mount then
		aq:Mount(aj.Parent)
	end
	if aq.Pack and ap and aj.Registry then
		local ar = aj.Registry[ap]
		if ar and ar ~= aq then
			ae.Warn(([[[SeaHub:Snapshot] Duplicate registry key '%s'. Use unique 'Idx' in element config.]]):format(ap))
		end
		aj.Registry[ap] = aq
		aq._Registry = aj.Registry
		aq._RegistryKey = ap
		local as = aq.Destroy
		function aq.Destroy(at)
			if at._Registry and at._RegistryKey then
				at._Registry[at._RegistryKey] = nil
				at._Registry = nil
				at._RegistryKey = nil
			end
			if as then
				as(at)
			end
		end
	end
	table.insert(aj.TrackedElements, aq)
	return aq
end
function ag.AddSection(aj, ak)
	local al = aa.New({ Parent = aj.Parent, Window = aj.Window, Registry = aj.Registry, Title = ak })
	table.insert(aj.Sections, al)
	return ah(al, aj.TrackedElements)
end
function ag.Destroy(aj)
	for ak, al in aj.TrackedElements do
		if type(al.Destroy) == "function" then
			pcall(function()
				al:Destroy()
			end)
		end
	end
	for ak, al in aj.Sections do
		if type(al.Destroy) == "function" then
			pcall(function()
				al:Destroy()
			end)
		end
	end
	table.clear(aj.TrackedElements)
	table.clear(aj.Sections)
end
return table.freeze(ag)
end
a["UI/ModalResizer"]=function()
local aa = {}
aa.__index = aa
local ab = 0.4
function aa.New(ac)
	local ad = ac.Bleed or 0
	local ae = setmetatable(
		{
			Root = ac.Root,
			Bleed = ad,
			MinSize = ac.MinSize,
			MaxSize = ac.MaxSize,
			Resizing = false,
			PointerKind = nil,
			ActiveTouch = nil,
			StartPointer = Vector2.zero,
			StartVisible = Vector2.zero,
			StartPosOffset = Vector2.zero,
			TargetSize = Vector2.zero,
			TargetPosOffset = Vector2.zero,
		},
		aa
	)
	return ae
end
local ac, ad =
	function(ac, ad)
		return ad - Vector2.new(ac.Bleed * 2, ac.Bleed * 2)
	end, function(ac, ad, ae)
		local af = ac.Root.Position
		ac.Root.Size = UDim2.fromOffset(ad.X, ad.Y)
		ac.Root.Position = UDim2.new(af.X.Scale, ae.X, af.Y.Scale, ae.Y)
	end
function aa.IsResizing(ae)
	return ae.Resizing
end
function aa.OnInputBegan(ae, af)
	local ag
	if af.UserInputType == Enum.UserInputType.MouseButton1 then
		ag = "Mouse"
	elseif af.UserInputType == Enum.UserInputType.Touch then
		ag = "Touch"
		ae.ActiveTouch = af
	else
		return
	end
	ae.Resizing = true
	ae.PointerKind = ag
	ae.StartPointer = Vector2.new(af.Position.X, af.Position.Y)
	local ah = ae.Root.Size
	ae.StartVisible = ac(ae, Vector2.new(ah.X.Offset, ah.Y.Offset))
	local ai = ae.Root.Position
	ae.StartPosOffset = Vector2.new(ai.X.Offset, ai.Y.Offset)
	ae.TargetSize = Vector2.new(ah.X.Offset, ah.Y.Offset)
	ae.TargetPosOffset = ae.StartPosOffset
end
function aa.OnInputChanged(ae, af)
	if not ae.Resizing then
		return
	end
	if ae.PointerKind == "Mouse" then
		if af.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
	elseif ae.PointerKind == "Touch" then
		if af.UserInputType ~= Enum.UserInputType.Touch or af ~= ae.ActiveTouch then
			return
		end
	else
		return
	end
	local ag = Vector2.new(af.Position.X, af.Position.Y) - ae.StartPointer
	local ah = ae.StartVisible + ag
	local ai = Vector2.new(math.clamp(ah.X, ae.MinSize.X, ae.MaxSize.X), math.clamp(ah.Y, ae.MinSize.Y, ae.MaxSize.Y))
	local aj = ai - ae.StartVisible
	ae.TargetSize = ai + Vector2.new(ae.Bleed * 2, ae.Bleed * 2)
	ae.TargetPosOffset = ae.StartPosOffset + aj * 0.5
end
function aa.OnInputEnded(ae, af)
	if not ae.Resizing then
		return
	end
	local ag = (ae.PointerKind == "Mouse" and af.UserInputType == Enum.UserInputType.MouseButton1)
		or (ae.PointerKind == "Touch" and af.UserInputType == Enum.UserInputType.Touch and af == ae.ActiveTouch)
	if not ag then
		return
	end
	ad(ae, ae.TargetSize, ae.TargetPosOffset)
	ae.Resizing = false
	ae.PointerKind = nil
	ae.ActiveTouch = nil
end
function aa.OnRenderStepped(ae)
	if not ae.Resizing then
		return
	end
	local af, ag = ae.Root.Position, ae.Root.Size
	local ah, ai = Vector2.new(ag.X.Offset, ag.Y.Offset), Vector2.new(af.X.Offset, af.Y.Offset)
	ad(ae, ah:Lerp(ae.TargetSize, ab), ai:Lerp(ae.TargetPosOffset, ab))
end
function aa.Destroy(ae)
	ae.Resizing = false
	ae.ActiveTouch = nil
end
return aa
end
a["UI/ModalStack"]=function()
local aa, ab = game:GetService("UserInputService"), 90
local ac, ad, ae = {}, {}
local af, ag =
	function(af)
		local ag = table.clone(ad)
		table.sort(ag, function(ah, ai)
			local aj, ak = ah.Root.ZIndex, ai.Root.ZIndex
			if aj == ak then
				local al, am = table.find(ad, ah) or 0, table.find(ad, ai) or 0
				return al < am
			end
			return aj < ak
		end)
		if af then
			local ah = table.find(ag, af)
			if ah then
				table.remove(ag, ah)
				table.insert(ag, af)
			end
		end
		for ah, ai in ag do
			ai.Root.ZIndex = ab + (ah - 1)
		end
	end, function(af)
		local ag, ah, ai = -math.huge, -1
		for aj, ak in ad do
			if ak.IsOpen() and ak.Contains(af) then
				local al = ak.Root.ZIndex
				if al > ag or (al == ag and aj > ah) then
					ai = ak
					ag = al
					ah = aj
				end
			end
		end
		return ai
	end
local ah = function(ah, ai)
	if ah.UserInputType ~= Enum.UserInputType.MouseButton1 and ah.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local aj = Vector2.new(ah.Position.X, ah.Position.Y)
	local ak = ag(aj)
	if not ak then
		return
	end
	local al = ab
	for am, an in ad do
		al = math.max(al, an.Root.ZIndex)
	end
	if ak.Root.ZIndex == al and #ad > 1 then
		local am = 0
		for an, ao in ad do
			if ao.Root.ZIndex == al then
				am = am + 1
			end
		end
		if am == 1 then
			return
		end
	end
	af(ak)
end
function ac.Register(ai)
	table.insert(ad, ai)
	if not ae then
		ae = aa.InputBegan:Connect(ah)
	end
	local aj = false
	return function()
		if aj then
			return
		end
		aj = true
		local ak = table.find(ad, ai)
		if ak then
			table.remove(ad, ak)
		end
		if #ad == 0 and ae then
			ae:Disconnect()
			ae = nil
		end
	end
end
function ac.Raise(ai)
	if table.find(ad, ai) then
		af(ai)
	end
end
return ac
end
a["UI/Notifications"]=function()
local e, f, g, h, i, j, k, l, m = d("Core/Common").Creator, d("UI/NotificationsAnimation"), d("Localization/Localization"), {}, 4, 1, 20, 5, 0.18
local n = function(n)
	if type(n) == 'string'then
		return{Title = n, Content = '', Duration = i}
	end
	local o = (type(n) == 'table'and{n}or{{}})[1]
	local p, q, r = (type(o.Title) == 'string'and o.Title ~= ''and{(o.Title)}or{(g.t'notify.common.defaultTitle')})[1], (type(o.Content) == 'string'and{(o.Content)}or{''})[1], math.clamp(tonumber(o.Duration)or i, j, k)
	return{Title = p, Content = q, Duration = r}
end function h.New(o)
	local p, q, r, s, t, u, v = o.Parent, {}, false, 0, (setmetatable({}, {__mode = 'k'})), ((setmetatable({}, {__mode = 'k'})))
	local w, x, y = function()
		if v and v.Parent == p then
			return v
		end
		if v then
			v:Destroy()
		end
		v = e.New('Frame', {
			Name = 'SeaHubNotifications',
			AnchorPoint = Vector2.new(0.5, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0, 12),
			Size = UDim2.new(0, 340, 0, 0),
			ZIndex = 200,
			Parent = p
		}, {
			e.New('UIListLayout', {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			})
		})
		return v
	end, function(w)
		local x = table.find(q, w)
		if x then
			table.remove(q, x)
		end
	end, function(w)
		local x = e.GetThemeProperty(w)
		assert(x ~= nil, ('Notifier missing theme token: %s'):format(w))
		return x
	end
	local z, A = function(z)
		if t[z]then
			return
		end
		t[z] = true
		local A = u[z]
		if A then
			u[z] = nil
			pcall(task.cancel, A)
		end
		x(z)
		if not z.Parent then
			return
		end
		local B = math.max(1, z.AbsoluteSize.Y)
		z.ClipsDescendants = true
		z.AutomaticSize = Enum.AutomaticSize.None z.Size = UDim2.new(1, 0, 0, B)
		f.Exit(z, function()
			if z and z.Parent then
				z:Destroy()
			end
		end)
	end, {}function A.Notify(B, C)
		if r then
			return nil
		end
		local D, E, F, G, H = n(C), (w())
		local I = {
			e.New('TextLabel', {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				FontFace = Font.new(e.GetThemeProperty'FontFamily'or'rbxassetid://12187365364', e.GetThemeProperty'FontWeightMedium'or Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text = D.Title,
				TextColor3 = y'Text',
				TextSize = e.GetThemeProperty'TextSizeBody'or 16,
				TextTransparency = 0,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 0),
				[e.ThemeTag] = {TextColor3 = 'Text', TextSize = 'TextSizeBody'}
			})
		}
		if D.Content ~= ''then
			table.insert(I, e.New('TextLabel', {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				FontFace = Font.new(e.GetThemeProperty'FontFamily'or'rbxassetid://12187365364', e.GetThemeProperty'FontWeightNormal'or Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				LayoutOrder = 2,
				Text = D.Content,
				TextColor3 = y'Text',
				TextSize = e.GetThemeProperty'TextSizeSmall'or 15,
				TextTransparency = e.GetThemeProperty'NotifierContentTransparency'or m,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 0),
				[e.ThemeTag] = {
					TextColor3 = 'Text',
					TextSize = 'TextSizeSmall',
					TextTransparency = 'NotifierContentTransparency'
				}
			}))
		end
		local J = {
			e.New('UICorner', {CornerRadius = f.RadiusStart, [e.Ref] = function(J)
				F = J
			end}),
			e.New('UIScale', {Scale = f.ScaleStart, [e.Ref] = function(J)
				G = J
			end}),
			e.New('UIStroke', {
				Color = y'StrokeColor',
				Transparency = y'StrokeTransparency',
				[e.ThemeTag] = {Color = 'StrokeColor', Transparency = 'StrokeTransparency'}
			}),
			e.New('UIPadding', {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16)
			}),
			e.New('Frame', {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, f.TranslateY),
				Size = UDim2.new(1, 0, 0, 0),
				[e.Ref] = function(J)
					H = J
				end
			}, {
				e.New('UIListLayout', {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4)
				}),
				I
			})
		}
		s = s+1
		local K = (e.New('CanvasGroup', {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = y'BackgroundSurface',
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			GroupTransparency = 1,
			LayoutOrder = s,
			Size = UDim2.new(1, 0, 0, 0),
			[e.ThemeTag] = {BackgroundColor3 = 'BackgroundSurface'}
		}, J))
		K.Parent = E table.insert(q, K)
		f.Intro(K, F, G, H, function()
			return r
		end)
		while#q>l do
			local L = q[1]
			if not L then
				break
			end
			z(L)
		end
		u[K] = task.delay(D.Duration, function()
			u[K] = nil
			if r then
				return
			end
			if K and K.Parent then
				z(K)
			end
		end)
		return K
	end function A.Destroy(B)
		if r then
			return
		end
		r = true
		for C, D in u do
			u[C] = nil
			pcall(task.cancel, D)
		end
		for C = #q, 1, -1 do
			local D = q[C]
			if D and D.Parent then
				D:Destroy()
			end
			q[C] = nil
		end
		if v then
			v:Destroy()
			v = nil
		end
	end
	w()
	return A
end
return table.freeze(h)
end
a["UI/NotificationsAnimation"]=function()
local e, f = d("Core/Common").Animator, {}
f.RadiusStart = UDim.new(0, 999)
f.ScaleStart = 0.9
f.TranslateY = 10
local g, h, i, j, k, l, m, n =
	UDim.new(0, 24),
	1.015,
	1,
	TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
function f.Intro(o, p, q, r, s)
	if not o.Parent then
		return
	end
	if p then
		e.Tween(p, { CornerRadius = g }, j)
	end
	if q then
		e.Tween(q, { Scale = h }, k)
		task.delay(k.Time * 0.9, function()
			if s() or not q.Parent then
				return
			end
			e.Tween(q, { Scale = i }, l)
		end)
	end
	e.Tween(o, { GroupTransparency = 0, BackgroundTransparency = 0.08 }, m)
	if r then
		e.Tween(r, { Position = UDim2.new(0, 0, 0, 0) }, m)
	end
end
function f.Exit(o, p)
	local q = e.Tween(o, { GroupTransparency = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) }, n)
	q.Completed:Once(p)
end
return table.freeze(f)
end
a["UI/OverlayButton"]=function()
local aa, ab = game:GetService'UserInputService', d("Core/Common")
local ac, ad, ae = ab.Creator, ab.Animator, ab.SignalManager
local af, ag, ah, ai, aj, ak, al, am, an = ac.New, 'rbxassetid://78362564258186', 220, 54, 8, 4, {}, function(af, ag)
	return ac.GetThemeProperty(af)or ag
end, function(af)
	return af.UserInputType == Enum.UserInputType.MouseButton1 or af.UserInputType == Enum.UserInputType.Touch
end function al.New(ao)
	local ap, aq, ar, as, at, e, f, g, h = ao.Parent, ae.CreateScope(), false, false, Vector3.zero, UDim2.fromOffset(0, 0), false, ((af('ImageButton', {
		Name = 'SeaHubOverlay',
		Active = true,
		AnchorPoint = Vector2.new(0, 0),
		AutoButtonColor = false,
		BackgroundColor3 = am('BackgroundElevated', Color3.fromRGB(24, 24, 24)),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Image = ag,
		ImageColor3 = am('LogoColor', am('Accent', Color3.fromRGB(255, 185, 255))),
		Position = UDim2.new(1, -(ai+aj), 1, -(ai+86)),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromOffset(ai, ai),
		Visible = ao.Enabled ~= false,
		ZIndex = ah,
		[ac.ThemeTag] = {BackgroundColor3 = 'BackgroundElevated', ImageColor3 = 'LogoColor'}
	}, {
		af('UICorner', {
			CornerRadius = ac.GetThemeProperty'CornerRadiusFull'or UDim.new(1, 0),
			[ac.ThemeTag] = {CornerRadius = 'CornerRadiusFull'}
		}),
		af('UIStroke', {
			Color = am('Accent', Color3.fromRGB(255, 185, 255)),
			Transparency = 0.2,
			Thickness = 1.25,
			[ac.ThemeTag] = {Color = 'Accent'}
		})
	})))
	g.Parent = ap
	local i, j = function(i, j)
		local k = ap.AbsoluteSize
		if k.X <= 0 or k.Y <= 0 then
			local l = workspace.CurrentCamera
			if l then
				k = l.ViewportSize
			end
		end
		local l, m = (g.AbsoluteSize.X>0 and{(g.AbsoluteSize.X)}or{ai})[1], (g.AbsoluteSize.Y>0 and{(g.AbsoluteSize.Y)}or{ai})[1]
		local n, o = math.max(aj, k.X-l-aj), math.max(aj, k.Y-m-aj)
		return math.clamp(i, aj, n), math.clamp(j, aj, o)
	end, function(i)
		local j = ap.AbsoluteSize
		if j.X <= 0 or j.Y <= 0 then
			local k = workspace.CurrentCamera
			if k then
				j = k.ViewportSize
			end
		end
		return i.X.Scale*j.X+i.X.Offset, i.Y.Scale*j.Y+i.Y.Offset
	end
	local k, l = function(k, l)
		local m, n = i(k, l)
		g.Position = UDim2.fromOffset(m, n)
	end, function()
		ar = false
		as = false
		h = nil
	end
	aq:Connect(g.InputBegan, function(m)
		if f or not an(m)then
			return
		end
		ar = true
		as = false
		h = (m.UserInputType == Enum.UserInputType.Touch and{m}or{nil})[1]
		at = m.Position
		local n, o = j(g.Position)
		e = UDim2.fromOffset(n, o)
	end)
	aq:Connect(aa.InputChanged, function(m)
		if f or not ar then
			return
		end
		if m.UserInputType ~= Enum.UserInputType.MouseMovement then
			if m.UserInputType ~= Enum.UserInputType.Touch or m ~= h then
				return
			end
		end
		local n = m.Position-at
		if not as and(math.abs(n.X)>ak or math.abs(n.Y)>ak)then
			as = true
		end
		if as then
			k(e.X.Offset+n.X, e.Y.Offset+n.Y)
		end
	end)
	aq:Connect(aa.InputEnded, function(m)
		if f or not ar then
			return
		end
		local n, o = m.UserInputType == Enum.UserInputType.MouseButton1 and h == nil, m.UserInputType == Enum.UserInputType.Touch and m == h
		if not n and not o then
			return
		end
		local p = not as l()
		if p and ao.OnActivated then
			ao.OnActivated()
		end
	end)
	aq:Connect(ap:GetPropertyChangedSignal'AbsoluteSize', function()
		if not f then
			local m, n = j(g.Position)
			k(m, n)
		end
	end)
	aq:Connect(g.MouseEnter, function()
		ad.Tween(g, {Size = UDim2.fromOffset(ai+4, ai+4)}, 0.12)
	end)
	aq:Connect(g.MouseLeave, function()
		ad.Tween(g, {Size = UDim2.fromOffset(ai, ai)}, 0.16)
	end)
	local m = {Root = g, Enabled = ao.Enabled ~= false}function m.SetEnabled(n, o)
		n.Enabled = o == true
		if not n.Enabled then
			l()
		end
		g.Visible = n.Enabled
	end function m.IsEnabled(n)
		return n.Enabled == true
	end function m.GetPosition(n)
		return g.Position
	end function m.SetPosition(n, o)
		if typeof(o) ~= 'UDim2'then
			return
		end
		k(o.X.Offset, o.Y.Offset)
	end function m.Destroy(n)
		if f then
			return
		end
		f = true
		l()
		ad.CancelInstance(g)
		aq:Destroy()
		g:Destroy()
	end
	return m
end
return table.freeze(al)
end
a["UI/PopupLayer"]=function()
local e, f, g, h, i = {}, ("PL_%08X"):format(math.random(0, 0x7fffffff)), 100
local j = function(j)
	if h and h.Parent == j then
		return h
	end
	if h then
		h:Destroy()
		h = nil
	end
	local k = Instance.new("Frame")
	k.Name = f
	k.BackgroundTransparency = 1
	k.BorderSizePixel = 0
	k.Size = UDim2.fromScale(1, 1)
	k.ZIndex = g
	k.Parent = j
	h = k
	return k
end
function e.DismissActive()
	if i then
		i:Destroy()
		i = nil
	end
end
function e.Mount(k, l)
	e.DismissActive()
	local m = j(l)
	k.Parent = m
	local n, o = false, {}
	function o.Destroy(p)
		if n then
			return
		end
		n = true
		k.Parent = nil
		if i == o then
			i = nil
		end
	end
	i = o
	return o
end
function e.GetLayer()
	return h
end
function e.IsActive()
	return i ~= nil
end
function e.Destroy()
	e.DismissActive()
	if h then
		h:Destroy()
		h = nil
	end
end
return e
end
a["UI/SubTabBar"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag = aa.Creator, aa.Animator, aa.SignalManager, aa.Scheduler, aa.WindowDrag, d("UI/SubTabIndicator")
local ah, ai, aj, ak, al =
	ab.New,
	ab.GetThemeProperty,
	TweenInfo.new(0.2, ac.Style.Quad, ac.Dir.Out),
	TweenInfo.new(0.25, ac.Style.Quad, ac.Dir.Out),
	{}
function al.New(am)
	local an, ao, ap, aq, ar, as, at, e, f, g, h, i, j, k, l, m, n, o, p, q =
		ad.CreateScope(), false, {}, 0, 0, false, false, true, true, {}, 0, false, false, false
	ah(
		"Frame",
		{
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Color3.fromRGB(22, 22, 22),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(0, 36),
			Visible = false,
			ZIndex = 2,
			[ab.Ref] = function(r)
				n = r
			end,
			[ab.ThemeTag] = { BackgroundColor3 = "BackgroundSurface" },
		},
		{
			ah(
				"UICorner",
				{
					CornerRadius = ai("CornerRadiusSubTabs") or UDim.new(0, 16),
					[ab.ThemeTag] = { CornerRadius = "CornerRadiusSubTabs" },
				}
			),
			ah("UIStroke", {
				Color = Color3.fromRGB(240, 240, 240),
				Transparency = 1,
				[ab.Ref] = function(r)
					o = r
				end,
				[ab.ThemeTag] = { Color = "StrokeColor" },
			}),
			ah(
				"UIListLayout",
				{
					Padding = UDim.new(0, 0),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}
			),
			ah(
				"UIPadding",
				{ PaddingBottom = UDim.new(0, 1), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }
			),
			ah(
				"Frame",
				{
					AnchorPoint = Vector2.new(0.5, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.new(0, 0, 1, 0),
				},
				{
					ah(
						"Frame",
						{
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundTransparency = 1,
							Size = UDim2.new(0, 0, 1, 0),
							[ab.Ref] = function(r)
								p = r
							end,
						},
						{
							ah(
								"UIListLayout",
								{
									Padding = UDim.new(0, 6),
									FillDirection = Enum.FillDirection.Horizontal,
									SortOrder = Enum.SortOrder.LayoutOrder,
									VerticalAlignment = Enum.VerticalAlignment.Center,
								}
							),
							ah("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }),
						}
					),
					ah(
						"Frame",
						{ BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 6 },
						{
							ah(
								"Frame",
								{
									AnchorPoint = Vector2.new(0, 1),
									BackgroundTransparency = 1,
									Position = UDim2.new(0, 0, 1, 0),
									Size = UDim2.fromOffset(0, 1),
									[ab.ThemeTag] = { BackgroundColor3 = "Accent" },
									[ab.Ref] = function(r)
										q = r
									end,
								},
								{
									ah(
										"UICorner",
										{
											CornerRadius = ai("CornerRadiusFull") or UDim.new(1, 0),
											[ab.ThemeTag] = { CornerRadius = "CornerRadiusFull" },
										}
									),
								}
							),
						}
					),
				}
			),
		}
	)
	local r = ag.New({
		Root = am.Root,
		Indicator = q,
		GetTarget = function()
			if aq == 0 then
				return nil, nil
			end
			local r = ap[aq]
			if not r then
				return nil, nil
			end
			return r.Button, q.Parent
		end,
	})
	local s = function()
		local s = at or e
		if s ~= l then
			i = true
			j = true
			l = s
		end
		f = s
		if i then
			i = false
		end
		if j then
			j = false
		end
		if k then
			k = false
			r.Start()
		end
	end
	local t = function()
		if ao then
			return
		end
		local t = h
		ae.DeferKeyed(g, function()
			if ao or t ~= h then
				return
			end
			s()
		end, "Normal")
	end
	an:Connect(n.MouseEnter, function()
		if ao then
			return
		end
		at = true
		i = true
		j = true
		t()
	end)
	an:Connect(n.MouseLeave, function()
		if ao then
			return
		end
		at = false
		i = true
		j = true
		t()
	end)
	local u = {}
	u.Wrapper = n
	local v, w =
		function()
			return ai("TabInactive") or Color3.fromRGB(160, 160, 160)
		end, function()
			return ai("TabActive") or ai("Text") or Color3.fromRGB(240, 240, 240)
		end
	local y = function(y, z, A)
		local B = (z and { (w()) } or { (v()) })[1]
		if A then
			ac.Tween(y.Button, { TextColor3 = B }, aj)
		else
			ac.Set(y.Button, { TextColor3 = B })
		end
	end
	local z = function(z)
		for A, B in ap do
			y(B, A == aq, z)
		end
	end
	function u.AddButton(A, B, C)
		local D, E
		local F = ah(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Color3.fromRGB(100, 100, 100),
				BackgroundTransparency = 1,
				ClipsDescendants = false,
				LayoutOrder = B,
				Size = UDim2.fromOffset(0, 26),
				Parent = p,
			},
			{
				ah(
					"UICorner",
					{ CornerRadius = ai("CornerRadiusTab") or UDim.new(0, 6), [ab.ThemeTag] = {
						CornerRadius = "CornerRadiusTab",
					} }
				),
				ah(
					"UIPadding",
					{
						PaddingBottom = UDim.new(0, 2),
						PaddingTop = UDim.new(0, 2),
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 6),
					}
				),
				ah("TextLabel", {
					FontFace = Font.new(
						ai("FontFamily") or "rbxassetid://12187365364",
						ai("FontWeightMedium") or Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					),
					Text = C,
					TextColor3 = ai("TabInactive") or Color3.fromRGB(160, 160, 160),
					TextSize = ai("TextSizeTab") or 17,
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 1, 0),
					[ab.Ref] = function(F)
						D = F
					end,
				}),
				ah("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					ZIndex = 5,
					[ab.Ref] = function(F)
						E = F
					end,
				}),
			}
		)
		ar = ar + 1
		table.insert(ap, { Index = B, Button = D, ButtonObj = F })
		y(ap[#ap], false, false)
		an:Connect(E.Activated, function()
			if af.ShouldSuppressClick() then
				return
			end
			am.OnSelect(B)
		end)
		i = true
		j = true
		k = true
		if ar > 1 then
			n.Visible = true
			t()
		end
		return F, D
	end
	function u.Select(A, B)
		if ao or B == aq then
			return
		end
		local C, D = ap[aq], ap[B]
		if C then
			y(C, false, true)
		end
		if D then
			y(D, true, true)
		end
		aq = B
		i = true
		j = true
		k = true
		r.Start()
		t()
	end
	function u.UpdateContentScroll(A, B)
		if ao then
			return
		end
		local C = B > 2
		if C ~= as then
			as = C
			local D, E, F = C and 0.2 or 1, C and 0.9 or 1, UDim.new(0, C and 8 or 4)
			ac.Tween(n, { BackgroundTransparency = D }, ak)
			ac.Tween(o, { Transparency = E }, ak)
			ac.Tween(am.RootPadding, { PaddingTop = F }, ak)
		end
		local D = e
		e = B <= 2
		if e ~= D then
			i = true
			j = true
			t()
		end
	end
	function u.Destroy(A)
		if ao then
			return
		end
		ao = true
		h = h + 1
		if m then
			m()
			m = nil
		end
		r.Destroy()
		an:Destroy()
	end
	m = ab.OnThemeChanged(function()
		if ao then
			return
		end
		z(false)
	end)
	return u
end
return al
end
a["UI/SubTabIndicator"]=function()
local aa = {}
function aa.New(ab)
	local ac, ad, ae, af, ag, ah, ai, aj = 0, 0, 0, 0, 0, false, ab.Indicator
	local ak = function()
		if aj then
			aj:Disconnect()
			aj = nil
		end
	end
	local al, am =
		function()
			if aj or ah then
				return
			end
			local al = game:GetService("RunService").RenderStepped:Connect(function(al)
				if ah then
					ak()
					return
				end
				local am, an = ab.GetTarget()
				if not am or not am.Parent then
					ak()
					return
				end
				if not an or not an.Parent then
					ak()
					return
				end
				local ao = am.AbsoluteSize.X
				if ao < 1 then
					return
				end
				ad = math.round(ao)
				ac = math.round(am.AbsolutePosition.X - an.AbsolutePosition.X)
				if af == 0 then
					ae, af = ac, ad
					ag = ae
					ai.Position = UDim2.new(0, ae, 1, 0)
					ai.Size = UDim2.fromOffset(af, 1)
					ai.BackgroundTransparency = 0
					ak()
					return
				end
				local ap = math.clamp(al * 15, 0, 1)
				ae = ae + (ac - ae) * ap
				af = af + (ad - af) * ap
				local aq = ae - ag
				ag = ae
				local ar = math.abs(aq) * 2
				ai.Position = UDim2.new(0, math.round(ae - ar / 2), 1, 0)
				ai.Size = UDim2.fromOffset(math.round(af + ar), 1)
				if math.abs(ac - ae) < 0.5 and math.abs(ad - af) < 0.5 and math.abs(aq) < 0.1 then
					ae, af = ac, ad
					ag = ae
					ai.Position = UDim2.new(0, ac, 1, 0)
					ai.Size = UDim2.fromOffset(ad, 1)
					ak()
				end
			end)
			aj = al
		end, {}
	am.Start = al
	am.Stop = ak
	function am.Destroy()
		ah = true
		ak()
	end
	return am
end
return aa
end
a["UI/Tab"]=function()
local aa, ab = d("UI/TabContent"), {}
function ab.New(ac)
	local ad, ae = ac
	local af, ag = function()
		if ae then
			return ae
		end
		ae = aa.New(ad)
		return ae
	end, {}
	function ag.AddSection(ah, ai)
		return af():AddSection(ai)
	end
	function ag.AddSubTab(ah, ai, aj)
		return af():AddSubTab(ai, aj)
	end
	function ag.SelectSubTab(ah, ai)
		return af():SelectSubTab(ai)
	end
	function ag.Show(ah)
		af():Show()
	end
	function ag.Hide(ah)
		if ae then
			ae:Hide()
		end
	end
	function ag.Destroy(ah)
		if ae then
			ae:Destroy()
		end
		ae = nil
	end
	return setmetatable(ag, {
		__index = function(ah, ai)
			return af()[ai]
		end,
	})
end
return table.freeze(ab)
end
a["UI/TabContent"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae, af, ag = aa.Creator, aa.SignalManager, aa.TabContentScroll, d("Elements/Section"), d("UI/SubTabBar"), d("Localization/Localization")
local ah, ai = ab.New, {}
function ai.New(aj)
	local ak, al, am, an, ao, ap = ac.CreateScope(), {}, 0, 0
	local aq = ah(
		"Frame",
		{ BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false },
		{
			ah(
				"UIListLayout",
				{
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 12),
				}
			),
			ah("UIPadding", {
				PaddingBottom = ab.GetThemeProperty("PaddingWindow") or UDim.new(0, 12),
				PaddingTop = UDim.new(0, 4),
				PaddingLeft = ab.GetThemeProperty("PaddingWindow") or UDim.new(0, 12),
				PaddingRight = ab.GetThemeProperty("PaddingWindow") or UDim.new(0, 12),
				[ab.ThemeTag] = {
					PaddingBottom = "PaddingWindow",
					PaddingLeft = "PaddingWindow",
					PaddingRight = "PaddingWindow",
				},
				[ab.Ref] = function(aq)
					ao = aq
				end,
			}),
		}
	)
	aq.Parent = aj.Parent
	local ar = af.New({
		Root = aq,
		RootPadding = ao,
		Window = aj.Window,
		OnSelect = function(ar)
			ap:SelectSubTab(ar)
		end,
	})
	ar.Wrapper.Parent = aq
	ap = { Root = aq, Window = aj.Window }
	function ap.SelectSubTab(as, at)
		if at == am then
			return
		end
		local e, f = al[am], al[at]
		if e then
			e.Container.Visible = false
		end
		if f then
			f.Container.Visible = true
			ar:UpdateContentScroll(f.Container.CanvasPosition.Y)
		end
		am = at
		ar:Select(at)
	end
	function ap.AddSubTab(as, at, e)
		an = an + 1
		local f, g = an, math.clamp(e or 1, 1, 2)
		local h, i = ar:AddButton(f, at)
		local j = function()
			return UDim.new(0, an > 1 and 0 or 8)
		end
		local k, l =
			function()
				local k = j()
				for l, m in al do
					if m.Pad then
						m.Pad.PaddingTop = k
					end
				end
			end, 8
		local m, n =
			ah(
				"UIListLayout",
				{
					Padding = UDim.new(0, l),
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}
			),
			ah(
				"UIPadding",
				{ PaddingBottom = UDim.new(0, 16), PaddingTop = j(), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(
					0,
					6
				) }
			)
		local o, p =
			ah(
				"ScrollingFrame",
				{
					ScrollBarImageTransparency = 1,
					ScrollBarThickness = 2,
					BackgroundTransparency = 1,
					ClipsDescendants = false,
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 0),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					Visible = false,
					Parent = aq,
				},
				{ ah("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }), m, n }
			),
			{}
		for q = 1, g do
			local r, s = 1 / g, (g > 1 and { (-math.round(l * (g - 1) / g)) } or { 0 })[1]
			local t = ah(
				"Frame",
				{ BackgroundTransparency = 1, Size = UDim2.new(r, s, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = o },
				{ ah("UIListLayout", { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder }) }
			)
			table.insert(p, t)
		end
		ak:Connect(m:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			o.CanvasSize = UDim2.fromOffset(0, m.AbsoluteContentSize.Y + n.PaddingTop.Offset + n.PaddingBottom.Offset)
		end)
		ak:Connect(o:GetPropertyChangedSignal("CanvasPosition"), function()
			ad.NotifyPulse()
			if am == f then
				ar:UpdateContentScroll(o.CanvasPosition.Y)
			end
		end)
		local q = function(q)
			local r = {
				Container = q,
				ScrollFrame = o,
				Window = aj.Window,
				Registry = aj.Registry,
				_GroupTabSource = aj.TabSource or aj.Title,
			}
			function r.AddSection(s, t)
				local u = type(t) == "table" and not ag.IsTagged(t)
				local v = (u and { t } or { { Title = t } })[1]
				local w = v.Title
				local y = (ag.IsTagged(w) and { (ag.ResolveTag(w) or "") } or { w })[1]
				return ae.New({
					Title = y,
					Parent = s.Container,
					Window = s.Window,
					ColumnCount = g,
					Registry = s.Registry,
					Unstyled = v.Unstyled == true,
					TitleSource = w,
					TabSource = s._GroupTabSource,
				})
			end
			return r
		end
		local r = q(p[1])
		local s = p[2] and q(p[2]) or r
		local t =
			{ Title = at, Button = i, ButtonObj = h, Container = o, Layout = m, Pad = n, Columns = p, Left = r, Right = s }
		function t.AddSection(u, v)
			return u.Left:AddSection(v)
		end
		table.insert(al, t)
		k()
		if an == 1 then
			ap:SelectSubTab(1)
		end
		return t
	end
	function ap.Show(as)
		aq.Visible = true
	end
	function ap.Hide(as)
		aq.Visible = false
	end
	local as = ap:AddSubTab(aj.Title or ag.t("common.tabs.main"), aj.Columns)
	ap.MainSubTab = as
	ap.Left = as.Left
	ap.Right = as.Right
	ap.Columns = as.Columns
	function ap.AddSection(at, e)
		return as:AddSection(e)
	end
	function ap.Destroy(at)
		ar:Destroy()
		ak:Destroy()
		aq:Destroy()
	end
	return ap
end
return ai
end
a["UI/Tooltip"]=function()
local e, f, g = game:GetService'RunService', game:GetService'UserInputService', d("Core/Common")
local h, i, j, k, l, m, n, o, p, q, r = g.Spring, g.Animator, g.AnimKit, g.AnimTokens, g.Creator, g.SignalManager, d("UI/TooltipView"), d("UI/TooltipFade"), {}, {stiffness = 220, damping = 34, mass = 0.7}, Vector2.new(16, 16)
local s, t, u = k.Info(0.22, k.Easing.Settle), k.Info(0.16, k.Easing.Standard), 'Crossfade'function p.SetMode(v)
	if v == 'FadeIn'or v == 'FadeSwap'or v == 'Crossfade'then
		u = v
	end
end function p.GetMode()
	return u
end
local v, w = (setmetatable({}, {__mode = 'k'})), {}
w.__index = w function p.Get(x)
	local y = v[x]
	if y and not y.Destroyed then
		return y
	end
	local z = setmetatable({
		Gui = x,
		Refs = n.Build(x),
		Active = false,
		Destroyed = false,
		Locked = false,
		SpringX = h.new(0, q),
		SpringY = h.new(0, q),
		TState = {ActiveLayer = 1},
		ChangeToken = 0,
		Render = nil,
		Scope = m.CreateScope()
	}, w)
	v[x] = z
	return z
end function w._PointerPosition(x)
	local y = f:GetMouseLocation()
	return Vector2.new(y.X+r.X, y.Y+r.Y)
end function w._StartRender(x)
	if x.Render then
		return
	end
	local y = x:_PointerPosition()
	x.SpringX:Set(y.X)
	x.SpringY:Set(y.Y)
	x.Render = e.RenderStepped:Connect(function(z)
		x:_Step(z)
	end)
end function w._StopRender(x)
	if x.Render then
		x.Render:Disconnect()
		x.Render = nil
	end
end function w._Step(x, y)
	local z = x:_PointerPosition()
	x.SpringX:SetTarget(z.X)
	x.SpringY:SetTarget(z.Y)
	local A, B, C = x.SpringX:Step(y), x.SpringY:Step(y), (x.Refs.Wrapper)
	C.Position = UDim2.fromOffset(math.round(A-n.Bleed), math.round(B-n.Bleed))
	o.StepSize(x.Refs, x.TState, y)
end function w._SetImmediate(x, y, z)
	local A = o.ActiveLayer(x.Refs, x.TState)
	o.WriteLayer(A, y, z or''); ((A.Group)).GroupTransparency = 0
	local B = (x.TState.ActiveLayer or 1) == 1 and 2 or 1
	local C = x.Refs.Layers[B]
	o.WriteLayer(C, '', nil); ((C.Group)).GroupTransparency = 1
	x.CurTitle = y x.CurDesc = z or''
end function w.SetContent(x, y, z)
	if x.Locked then
		return
	end
	local A, B = (type(y) == 'string'and{y}or{(tostring(y or''))})[1], (type(z) == 'string'and{z}or{''})[1]
	if not x.Active then
		x:_SetImmediate(A, B)
		return
	end
	if A == x.CurTitle and B == x.CurDesc then
		return
	end
	x.ChangeToken = x.ChangeToken+1
	local C = x.ChangeToken x.CurTitle = A x.CurDesc = B o.Run(x.Refs, x.TState, u, A, B, C, function(D)
		return not x.Destroyed and x.Active and x.ChangeToken == D
	end)
end function w.Show(x, y, z)
	if x.Destroyed or x.Locked then
		return
	end
	x:_SetImmediate((type(y) == 'string'and{y}or{(tostring(y or''))})[1], (type(z) == 'string'and{z}or{''})[1])
	x.Active = true
	local A = (x.Refs.Wrapper)
	o.SnapNext(x.TState)
	A.GroupTransparency = 1
	A.Visible = true
	x:_StartRender()
	x:_Step(0)
	i.Tween(A, {GroupTransparency = 0}, s)
end function w.Hide(x)
	if x.Destroyed or not x.Active or x.Locked then
		return
	end
	x.Active = false
	local y = (x.Refs.Wrapper)
	i.Tween(y, {GroupTransparency = 1}, t)
	j.After(t.Time, function()
		if not x.Active and not x.Destroyed then
			y.Visible = false
			x:_StopRender()
		end
	end)
end function w.IsOpen(x)
	return x.Active and not x.Destroyed
end function w.Lock(x)
	x.Locked = true
end function w.Unlock(x)
	x.Locked = false
end function w.Attach(x, y, z, A, B)
	local C, D = y.MouseEnter:Connect(function()
		if B and not B()then
			return
		end
		x:Show(z, A)
	end), y.MouseLeave:Connect(function()
		x:Hide()
	end)
	l.TrackConnection(y, C)
	l.TrackConnection(y, D)
	local E = false
	return function()
		if E then
			return
		end
		E = true
		C:Disconnect()
		D:Disconnect()
		x:Hide()
	end
end function w.Destroy(x)
	if x.Destroyed then
		return
	end
	x.Destroyed = true
	x.Active = false
	x:_StopRender()
	x.Scope:Destroy()
	if x.Refs.Layer then
		x.Refs.Layer:Destroy()
	end
	if v[x.Gui] == x then
		v[x.Gui] = nil
	end
end
return table.freeze(p)
end
a["UI/TooltipFade"]=function()
local e = d("Core/Common")
local f, g, h, i, j = e.Animator, e.AnimTokens, e.Spring, d("UI/TooltipTextWidth"), {}
local k, l, m, n = g.Info(0.1, g.Easing.Standard), g.Info(0.16, g.Easing.Settle), {stiffness = 210, damping = 30, mass = 0.9}, function(k, l, m)
	local n, o = (k.Title), (k.Desc)
	n.Text = l
	if type(m) == 'string'and m ~= ''then
		o.Text = m o.Visible = true
	else
		o.Text = ''
		o.Visible = false
	end
	local p = (k.Group)
	if l == ''and(o.Visible == false)then
		p.Size = UDim2.fromOffset(0, 0)
		k.MeasureFrames = nil
		return
	end
	local q = i.LayerWidth(n.TextSize, o.TextSize, l, m)
	p.Size = UDim2.fromOffset(q, 0)
	k.MeasureFrames = 2
end
j.WriteLayer = n
local o = function(o)
	local p = o.MeasureFrames
	if type(p) ~= 'number'then
		return
	end
	if p>0 then
		o.MeasureFrames = p-1
		return
	end
	local q, r = (o.Title), (o.Desc)
	local s = (r.Visible and{(r.TextBounds.X)}or{0})[1]
	local t = i.RenderedLayerWidth(q.TextBounds.X, s)
	if not t then
		return
	end
	local u = (o.Group)
	u.Size = UDim2.fromOffset(t, 0)
	o.MeasureFrames = nil
end function j.ActiveLayer(p, q)
	return p.Layers[q.ActiveLayer or 1]
end
local p = function(p)
	if not p.SizeW then
		p.SizeW = h.new(0, m)
		p.SizeH = h.new(0, m)
	end
end function j.SnapNext(q)
	q.Snap = true
end function j.StepSize(q, r, s)
	p(r)
	local t, u = (q.Bubble), j.ActiveLayer(q, r)
	o(u)
	local v = ((u.Group)).AbsoluteSize
	local w, x = v.X, v.Y
	if w <= 0 or x <= 0 then
		return
	end
	if r.Snap then
		r.Snap = false
		r.SizeW:Set(w)
		r.SizeH:Set(x)
	else
		r.SizeW:SetTarget(w)
		r.SizeH:SetTarget(x)
	end
	local y, z = r.SizeW:Step(s), r.SizeH:Step(s)
	t.Size = UDim2.fromOffset(math.round(y), math.round(z))
end function j.Run(q, r, s, t, u, v, w)
	if s == 'Crossfade'then
		local x = r.ActiveLayer or 1
		local y, z = x == 1 and 2 or 1, q.Layers[x]
		local A = q.Layers[y]
		n(A, t, u); ((A.Group)).GroupTransparency = 1
		r.ActiveLayer = y f.Tween(A.Group, {GroupTransparency = 0}, l)
		f.Tween(z.Group, {GroupTransparency = 1}, k)
		return
	end
	local x = j.ActiveLayer(q, r)
	local y = (x.Group)
	if s == 'FadeIn'then
		n(x, t, u)
		y.GroupTransparency = 1
		f.Tween(y, {GroupTransparency = 0}, l)
		return
	end
	local z = f.Tween(y, {GroupTransparency = 1}, k)
	z.Completed:Once(function()
		if not w(v)then
			return
		end
		n(x, t, u)
		f.Tween(y, {GroupTransparency = 0}, l)
	end)
end
return table.freeze(j)
end
a["UI/TooltipTextWidth"]=function()
local e, f = game:GetService("TextService"), {}
f.MinInnerWidth = 132
f.MaxInnerWidth = 260
f.PaddingX = 22
local g, h, i, j = Enum.Font.GothamMedium, Enum.Font.Gotham, Vector2.new(100000, 100000), 2
local k, l =
	function(k, l, m)
		if k == nil or k == "" then
			return 0
		end
		local n, o = pcall(function()
			return e:GetTextSize(k, l, m, i)
		end)
		return (n and o and { o.X } or { 0 })[1]
	end, function(k, l, m, n)
		if k == nil or k == "" or n <= 0 then
			return 0
		end
		local o, p = pcall(function()
			return e:GetTextSize(k, l, m, Vector2.new(n, 100000))
		end)
		return (o and p and { p.X } or { n })[1]
	end
function f.LayerWidth(m, n, o, p)
	local q, r = k(o, m, g), type(p) == "string" and p ~= ""
	if not r then
		local s = math.min(q + j, f.MaxInnerWidth)
		return math.ceil(s) + f.PaddingX
	end
	local s = k(p, n, h)
	local t = math.clamp(math.max(q, s) + j, f.MinInnerWidth, f.MaxInnerWidth)
	local u = l(p, n, h, t)
	local v = math.clamp(math.max(q, u) + j, f.MinInnerWidth, f.MaxInnerWidth)
	return math.ceil(v) + f.PaddingX
end
function f.RenderedLayerWidth(m, n)
	local o = math.max(m, n or 0)
	if o <= 0 then
		return nil
	end
	return math.ceil(math.min(o, f.MaxInnerWidth)) + f.PaddingX
end
return table.freeze(f)
end
a["UI/TooltipView"]=function()
local e = d("Core/Common")
local f = e.Creator
local g, h, i, j, k, l, m =
	f.New, {}, "rbxassetid://8992230677", "rbxassetid://12187365364", 250, 18, function(g, h)
		local i = f.GetThemeProperty(g)
		return (i ~= nil and { i } or { h })[1]
	end
local n = function(n, o)
	return Font.new(m("FontFamily", j), m(n, o), Enum.FontStyle.Normal)
end
function h.Build(o)
	local p = {}
	local q = g(
		"Frame",
		{
			Name = "SeaHubTooltipLayer",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = k,
			Active = false,
			Parent = o,
		},
		{
			g(
				"CanvasGroup",
				{
					Name = "Wrapper",
					AnchorPoint = Vector2.new(0, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					GroupTransparency = 1,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.fromOffset(0, 0),
					Visible = false,
					ZIndex = k,
					[f.Ref] = function(q)
						p.Wrapper = q
					end,
				},
				{
					g(
						"UIPadding",
						{
							PaddingTop = UDim.new(0, l),
							PaddingBottom = UDim.new(0, l),
							PaddingLeft = UDim.new(0, l),
							PaddingRight = UDim.new(0, l),
						}
					),
					g(
						"ImageLabel",
						{
							Image = i,
							ImageColor3 = m("ShadowColor", Color3.fromRGB(0, 0, 0)),
							ImageTransparency = m("ShadowTransparencyWindow", 0.3),
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(99, 99, 99, 99),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.new(1, l, 1, l),
							ZIndex = k,
							[f.ThemeTag] = { ImageColor3 = "ShadowColor", ImageTransparency = "ShadowTransparencyWindow" },
						}
					),
					h.BuildBubble(p),
				}
			),
		}
	)
	p.Layer = q
	return p
end
local o = function(o, p)
	local q = {}
	g(
		"CanvasGroup",
		{
			Name = "Content" .. p,
			AnchorPoint = Vector2.new(0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			GroupTransparency = p == 1 and 0 or 1,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromOffset(0, 0),
			ZIndex = k + 1,
			[f.Ref] = function(r)
				q.Group = r
			end,
		},
		{
			g(
				"UIPadding",
				{
					PaddingTop = UDim.new(0, 7),
					PaddingBottom = UDim.new(0, 7),
					PaddingLeft = UDim.new(0, 11),
					PaddingRight = UDim.new(0, 11),
				}
			),
			g(
				"UIListLayout",
				{ FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }
			),
			g("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				FontFace = n("FontWeightMedium", Enum.FontWeight.Medium),
				LayoutOrder = 1,
				Size = UDim2.fromOffset(0, 0),
				Text = "",
				TextColor3 = m("Text", Color3.fromRGB(240, 240, 240)),
				TextSize = m("TextSizeSmall", 15),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = k + 1,
				[f.Ref] = function(r)
					q.Title = r
				end,
				[f.ThemeTag] = { TextColor3 = "Text", TextSize = "TextSizeSmall" },
			}),
			g("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				FontFace = n("FontWeightNormal", Enum.FontWeight.Regular),
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 0),
				Text = "",
				TextColor3 = m("SubText", Color3.fromRGB(160, 160, 160)),
				TextSize = m("TextSizeCaption", 14),
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = false,
				ZIndex = k + 1,
				[f.Ref] = function(r)
					q.Desc = r
				end,
				[f.ThemeTag] = { TextColor3 = "SubText", TextSize = "TextSizeCaption" },
			}),
		}
	)
	return q
end
function h.BuildBubble(p)
	p.Layers = {}
	local q, r = o(p, 1), o(p, 2)
	p.Layers[1] = q
	p.Layers[2] = r
	return g(
		"Frame",
		{
			Name = "Bubble",
			AnchorPoint = Vector2.new(0, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundColor3 = m("DialogSurface", Color3.fromRGB(22, 22, 22)),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromOffset(0, 0),
			ZIndex = k + 1,
			[f.Ref] = function(s)
				p.Bubble = s
			end,
			[f.ThemeTag] = { BackgroundColor3 = "DialogSurface" },
		},
		{
			g(
				"UICorner",
				{ CornerRadius = m("CornerRadiusWindow", UDim.new(0, 12)), [f.ThemeTag] = {
					CornerRadius = "CornerRadiusWindow",
				} }
			),
			g(
				"UIStroke",
				{
					Color = m("DialogBorder", Color3.fromRGB(240, 240, 240)),
					Transparency = m("StrokeTransparency", 0.9),
					Thickness = m("StrokeThickness", 1),
					[f.ThemeTag] = {
						Color = "DialogBorder",
						Transparency = "StrokeTransparency",
						Thickness = "StrokeThickness",
					},
				}
			),
			q.Group,
			r.Group,
		}
	)
end
h.Bleed = l
return table.freeze(h)
end
a["UI/VisibilityScale"]=function()
local aa = d("Core/Common")
local ab, ac, ad = aa.Animator, aa.AnimTokens, {}
local ae, af, ag, ah, ai, aj, ak, al, am, an, ao, ap =
	ac.Preset.Fade,
	ac.Preset.Pop,
	ac.Preset.Close,
	ac.Preset.Close,
	ac.Scale.PopStart,
	ac.Scale.CloseEnd,
	ac.Info(0.16, ac.Easing.Standard),
	ac.Info(0.18, ac.Easing.Decelerate),
	ac.Info(ac.Duration.Fast, ac.Easing.Standard),
	ac.Info(0.14, ac.Easing.Decelerate),
	2,
	function(ae, af)
		return UDim2.new(ae.X.Scale, ae.X.Offset, ae.Y.Scale, ae.Y.Offset + af)
	end
function ad.New(aq)
	local ar, as, at, e = aq.Root, true, false, 0
	local f, g = ar.Position, Instance.new("UIScale")
	g.Name = "SeaHubVisibilityScale"
	g.Scale = 1
	g.Parent = ar
	local h, i = {}, function(h)
		if e == h then
			at = false
		end
	end
	function h.SetVisible(j, k)
		local l = k ~= false
		if as == l then
			return
		end
		local m, n = at, aq.UseFullAnimation()
		as = l
		at = true
		e = e + 1
		local o = e
		if l then
			local p = ar.Visible
			ar.Visible = true
			if n then
				if not p then
					ab.Set(ar, { GroupTransparency = 1 })
					ab.Set(g, { Scale = ai })
				end
				ab.Tween(ar, { GroupTransparency = 0 }, ae)
				ab.Tween(g, { Scale = 1 }, af)
				task.delay(af.Time + 0.03, function()
					i(o)
				end)
				return
			end
			ab.Set(g, { Scale = 1 })
			if not p then
				ab.Set(ar, { GroupTransparency = 1, Position = ap(f, ao) })
			end
			ab.Tween(ar, { GroupTransparency = 0 }, ak)
			ab.Tween(ar, { Position = f }, al)
			task.delay(al.Time + 0.03, function()
				i(o)
			end)
			return
		end
		if not m then
			f = ar.Position
		end
		if n then
			ab.Tween(ar, { GroupTransparency = 1 }, ag)
			ab.Tween(g, { Scale = aj }, ah)
			task.delay(ah.Time + 0.03, function()
				if e ~= o or as then
					return
				end
				ar.Visible = false
				i(o)
			end)
			return
		end
		ab.Set(g, { Scale = 1 })
		ab.Tween(ar, { GroupTransparency = 1 }, am)
		ab.Tween(ar, { Position = ap(f, ao) }, an)
		task.delay(an.Time + 0.03, function()
			if e ~= o or as then
				return
			end
			ar.Visible = false
			i(o)
		end)
	end
	function h.ToggleVisible(j)
		j:SetVisible(not as)
		return as
	end
	function h.IsVisible(j)
		return as
	end
	function h.Destroy(j)
		ab.CancelInstance(ar)
		ab.CancelInstance(g)
		g:Destroy()
	end
	return h
end
return table.freeze(ad)
end
a["UI/Window"]=function()
local e, f, g = game:GetService("UserInputService"), game:GetService("RunService"), d("Core/Common")
local h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, A, B, C, D, E, F, G =
	g.SignalManager,
	g.Responsive,
	d("Sidebar/Sidebar"),
	d("UI/TabContent"),
	d("UI/Tab"),
	d("UI/WindowFrame"),
	d("Sidebar/Reveal"),
	d("Sidebar/Tooltips"),
	d("UI/WindowDragger"),
	d("UI/WindowBackdrop"),
	d("UI/WindowSizeAdapter"),
	d("Snapshot/Snapshot"),
	d("UI/VisibilityScale"),
	d("Localization/Localization"),
	d("Settings/Tab"),
	d("UI/DialogManager"),
	d("UI/InfoPanel"),
	d("Debug/AnimationLogger"),
	d("Debug/AnimationVisualizer"),
	d("UI/Tooltip"),
	d("Core/Logger"),
	d("UI/OverlayButton"),
	function(h)
		while h do
			if h:IsA("ScreenGui") then
				return h
			end
			h = h.Parent
		end
		return nil
	end,
	{},
	"rbxassetid://10734950309",
	1000000
function E.New(H)
	local I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X =
		H.Registry or {},
		{},
		0,
		H.DragFpsCap,
		H.UseDragSkeleton == true,
		H.UseFullVisibilityAnimation == true,
		H.UseClassicToggle ~= false,
		0
	local Y, Z, _, aa = m.Build({
		Position = H.Position,
		OnInputBegan = function(Y)
			if R and R:ShouldBlockWindowDrag(Y) then
				return
			end
			if Q then
				Q:OnInputBegan(Y)
				S(Y)
			end
		end,
		OnInputEnded = function(Y)
			if Q then
				Q:OnInputEnded(Y)
			end
		end,
	})
	local ab = t.New({
		Root = Y,
		UseFullAnimation = function()
			return N
		end,
	})
	Y.Parent = H.Parent
	local ac
	Q =
		p.New({ Parent = H.Parent, Root = Y, RootContainer = Z, DragFpsCap = H.DragFpsCap, UseDragSkeleton = H.UseDragSkeleton })
	local ad
	local ae = function()
		if ad then
			ad:Destroy()
			ad = nil
		end
	end
	function S(af)
		if ad then
			return
		end
		ad = h.CreateScope()
		ad:Connect(e.InputChanged, function(ag)
			Q:OnInputChanged(ag)
		end)
		ad:Connect(f.RenderStepped, function()
			Q:OnRenderStepped()
		end)
		ad:Connect(e.InputEnded, function(ag)
			Q:OnInputEnded(ag)
			if not Q.Dragging then
				ae()
			end
		end)
	end
	local af, ag =
		r.New({
			Responsive = i,
			Root = Y,
			RootContainer = Z,
			OnSizeChanged = function(af, ag)
				Q:OnWindowResized(af, ag)
			end,
		}), j.New({
			Parent = Z,
			Title = H.Title,
			Subtitle = (H.Sidebar and { H.Sidebar.Subtitle } or { nil })[1],
			Expandable = not H.Sidebar or H.Sidebar.Expandable ~= false,
			OnToggleRequested = function(af)
				if U then
					U:SetExpanded(af, true)
				end
			end,
		})
	U = n.New({ Navigation = ag, ContentRoot = _, Responsive = i, Sidebar = H.Sidebar })
	V = o.New({ Parent = H.Parent, Navigation = ag, Expandable = not H.Sidebar or H.Sidebar.Expandable ~= false })
	local ah, ai =
		s.New(I, H.SnapshotApplyCallbacks == true),
		{ Root = Y, RootContainer = Z, Nav = ag, Registry = I, _SectionOrderSeq = 0, _ToggleHandles = {}, _Destroyed = false }
	function ai._RegisterToggle(aj, ak)
		if type(ak) == "table" then
			table.insert(aj._ToggleHandles, ak)
		end
	end
	T = C.New({
		Parent = H.Parent,
		Enabled = H.OverlayEnabled ~= false,
		OnActivated = function()
			ai:ToggleVisible()
		end,
	})
	local aj = function()
		if W then
			W()
		end
		W = A.Get(H.Parent):Attach(T.Root, u.t("overlay.toggle.tooltip"))
	end
	aj()
	X = u.OnChanged(aj)
	R = w.New({
		Parent = Z,
		Window = ai,
		Registry = I,
		OnDialogStateChanged = function(ak)
			ac:SetOpen(ak)
			if H.OnDialogStateChanged then
				H.OnDialogStateChanged(ak)
			end
		end,
	})
	ac = q.New({
		Parent = Z,
		OnActivated = function()
			R:RemindActive()
		end,
	})
	function ai.SetDragFpsCap(ak, al)
		L = al
		Q:SetDragFpsCap(al)
		if H.PersistSetting then
			H.PersistSetting("DragFpsCap", al)
		end
	end
	function ai.SetUseDragSkeleton(ak, al)
		M = al == true
		Q:SetUseDragSkeleton(al)
		if H.PersistSetting then
			H.PersistSetting("UseDragSkeleton", M)
		end
	end
	function ai.SetUseFullVisibilityAnimation(ak, al)
		N = al == true
		if H.PersistSetting then
			H.PersistSetting("UseFullVisibilityAnimation", N)
		end
	end
	function ai.SetUseClassicToggle(ak, al)
		O = al == true
		if H.PersistSetting then
			H.PersistSetting("UseClassicToggle", O)
		end
		P = P + 1
		local am = P
		task.delay(0.08, function()
			if ak._Destroyed or am ~= P then
				return
			end
			for an = #ak._ToggleHandles, 1, -1 do
				local ao = ak._ToggleHandles[an]
				if not ao or ao._SeaHubDestroyed then
					table.remove(ak._ToggleHandles, an)
				elseif ao.SetRenderer then
					local ap = pcall(ao.SetRenderer, ao, O)
					if not ap then
						table.remove(ak._ToggleHandles, an)
					end
				end
			end
		end)
	end
	function ai.SetOverlayEnabled(ak, al)
		T:SetEnabled(al)
		if H.PersistSetting then
			H.PersistSetting("OverlayEnabled", al == true)
		end
	end
	function ai.GetOverlayEnabled(ak)
		return T:IsEnabled()
	end
	function ai.SetSidebarExpanded(ak, al, am)
		return U:SetExpanded(al, am)
	end
	function ai.ToggleSidebar(ak, al)
		return U:Toggle(al)
	end
	function ai.IsSidebarExpanded(ak)
		return U:IsExpanded()
	end
	function ai.SetVisible(ak, al)
		ab:SetVisible(al)
	end
	function ai.ToggleVisible(ak)
		return ab:ToggleVisible()
	end
	function ai.IsVisible(ak)
		return ab:IsVisible()
	end
	function ai.SetSnapshotApplyCallbacks(ak, al)
		ah:SetApplyCallbacks(al)
	end
	function ai.GetSnapshotApplyCallbacks(ak)
		return ah:GetApplyCallbacks()
	end
	function ai.GetDragFpsCap(ak)
		return L
	end
	function ai.GetUseDragSkeleton(ak)
		return M
	end
	function ai.GetUseFullVisibilityAnimation(ak)
		return N
	end
	function ai.GetUseClassicToggle(ak)
		return O
	end
	function ai.GetSetting(ak, al)
		if H.GetSetting then
			return H.GetSetting(al)
		end
		return nil
	end
	function ai.SetSetting(ak, al, am)
		if H.SetSetting then
			return H.SetSetting(al, am)
		end
		return false
	end
	function ai.SaveSnapshot(ak, al)
		if H.SaveSnapshot then
			return H.SaveSnapshot(al)
		end
		return false, u.t("errors.window.saveSnapshotUnavailable")
	end
	function ai.LoadSnapshot(ak, al)
		if H.LoadSnapshot then
			return H.LoadSnapshot(al)
		end
		return false, u.t("errors.window.loadSnapshotUnavailable")
	end
	function ai.ListSnapshots(ak)
		if H.ListSnapshots then
			return H.ListSnapshots()
		end
		return {}
	end
	function ai.DeleteSnapshot(ak, al)
		if H.DeleteSnapshot then
			return H.DeleteSnapshot(al)
		end
		return false
	end
	function ai.DuplicateSnapshot(ak, al, am)
		if H.DuplicateSnapshot then
			return H.DuplicateSnapshot(al, am)
		end
		return nil
	end
	function ai.RenameSnapshot(ak, al, am)
		if H.RenameSnapshot then
			return H.RenameSnapshot(al, am)
		end
		return nil
	end
	function ai.GetDefaultSnapshotName(ak, al)
		if H.GetDefaultSnapshotName then
			return H.GetDefaultSnapshotName(al)
		end
		return nil
	end
	function ai.SetDefaultSnapshotName(ak, al, am)
		if H.SetDefaultSnapshotName then
			return H.SetDefaultSnapshotName(al, am)
		end
		return false
	end
	function ai.GetSnapshotSettings(ak)
		if H.GetSnapshotSettings then
			return H.GetSnapshotSettings()
		end
		return { Version = 1, AutoSave = { Enabled = false, Interval = "60s" } }
	end
	function ai.SetSnapshotAutoSave(ak, al, am)
		if H.SetSnapshotAutoSave then
			return H.SetSnapshotAutoSave(al, am)
		end
		return false, nil
	end
	function ai.MarkSnapshotDirty(ak)
		if H.MarkSnapshotDirty then
			H.MarkSnapshotDirty()
		end
	end
	function ai.ReportSnapshotOptions(ak, al, am)
		if H.ReportSnapshotOptions then
			H.ReportSnapshotOptions(al, am)
		end
	end
	function ai._NextSectionOrder(ak)
		ak._SectionOrderSeq = ak._SectionOrderSeq + 1
		return ak._SectionOrderSeq
	end
	function ai.IsSnapshotDirty(ak)
		if H.IsSnapshotDirty then
			return H.IsSnapshotDirty()
		end
		return false
	end
	function ai.GetSnapshotAutoSaveStats(ak)
		if H.GetSnapshotAutoSaveStats then
			return H.GetSnapshotAutoSaveStats()
		end
		return { Dirty = false, LastAutoSaveAt = nil, LastAutoSaveOk = nil, LastAutoSaveError = nil, SkippedUnchanged = 0 }
	end
	function ai.GetThemes(ak)
		if H.GetThemes then
			return H.GetThemes()
		end
		return {}
	end
	function ai.GetThemePresets(ak)
		if H.GetThemePresets then
			return H.GetThemePresets()
		end
		return {}
	end
	function ai.GetCurrentThemeName(ak)
		if H.GetCurrentThemeName then
			return H.GetCurrentThemeName()
		end
		return ""
	end
	function ai.GetThemeData(ak, al)
		if H.GetThemeData then
			return H.GetThemeData(al)
		end
		return nil
	end
	function ai.SetTheme(ak, al)
		if H.SetTheme then
			H.SetTheme(al)
		end
	end
	function ai.AddTheme(ak, al)
		if H.AddTheme then
			H.AddTheme(al)
		end
	end
	function ai.PatchThemeTokens(ak, al, am)
		if H.PatchThemeTokens then
			return H.PatchThemeTokens(al, am)
		end
		return false, u.t("errors.window.patchThemeTokensUnavailable")
	end
	function ai.SaveThemeFile(ak, al, am)
		if H.SaveThemeFile then
			return H.SaveThemeFile(al, am)
		end
		return false, u.t("errors.window.saveThemeFileUnavailable")
	end
	function ai.LoadThemeFile(ak, al, am)
		if H.LoadThemeFile then
			return H.LoadThemeFile(al, am)
		end
		return false, u.t("errors.window.loadThemeFileUnavailable")
	end
	function ai.ListThemeFiles(ak)
		if H.ListThemeFiles then
			return H.ListThemeFiles()
		end
		return {}
	end
	function ai.DuplicateTheme(ak, al, am)
		if H.DuplicateTheme then
			return H.DuplicateTheme(al, am)
		end
		return nil
	end
	function ai.DeleteTheme(ak, al)
		if H.DeleteTheme then
			return H.DeleteTheme(al)
		end
		return false
	end
	function ai.RenameTheme(ak, al, am)
		if H.RenameTheme then
			return H.RenameTheme(al, am)
		end
		return nil
	end
	function ai.Notify(ak, al)
		if H.Notify then
			return H.Notify(al)
		end
		return nil
	end
	function ai.Confirm(ak, al)
		if R:IsOpen() then
			R:RemindActive()
			return nil
		end
		return R:Confirm(al)
	end
	function ai.Modal(ak, al)
		local am = type(al) == "table"
		local an, ao = am and al.AllowStacked == true, am and al.Draggable == true
		if R:IsOpen() and not an and not ao then
			R:RemindActive()
			return nil
		end
		return R:Modal(al)
	end
	function ai.DismissDialog(ak, al)
		R:Dismiss(al)
	end
	function ai.IsDialogOpen(ak)
		return R:IsOpen()
	end
	function ai.RemindDialog(ak)
		R:RemindActive()
	end
	function ai.InfoPanel(ak, al)
		return x.New(ai, al)
	end
	function ai.AnimationLogger(ak, al)
		return y.New(ai, al)
	end
	function ai.AnimationVisualizer(ak, al)
		return z.New(ai, al)
	end
	local ak = function(ak, al)
		local am = (al and al.IsUserTab ~= nil and { al.IsUserTab } or { true })[1]
		local an, ao, ap = (am and { (K > 0) } or { true })[1], ak.Title
		if an then
			ap =
				l.New({ Title = ak.Title, Parent = aa, Window = ai, Columns = ak.Columns, Registry = I, TabSource = ao })
		else
			ap =
				k.New({ Title = ak.Title, Parent = aa, Window = ai, Columns = ak.Columns, Registry = I, TabSource = ao })
		end
		local aq, ar, as =
			ag:AddTab(ak.Image, function()
				for aq, ar in J do
					ar:Hide()
				end
				ap:Show()
			end, { AutoSelect = (al and { al.AutoSelect } or { nil })[1], LayoutOrder = (al and { al.LayoutOrder } or { nil })[1], Title = ak.Title }), (ak.Tooltip == false and { nil } or { (type(ak.Tooltip) == "string" and { ak.Tooltip } or { ak.Title })[1] })[1], (type(ak.TooltipDesc) == "string" and { ak.TooltipDesc } or { nil })[1]
		if aq and aq.Root and ar and ar ~= "" then
			task.defer(function()
				local at = D(aq.Root)
				if at and aq.Root.Parent then
					A.Get(at):Attach(aq.Root, ar, as, function()
						return not ag:IsExpanded()
					end)
				end
			end)
		end
		table.insert(J, ap)
		if am then
			K = K + 1
		end
		return ap
	end
	function ai.AddTab(al, am)
		return ak(am, { IsUserTab = true, AutoSelect = true })
	end
	local al = ak(
		{ Title = u.t("settings.tabs.settings"), Image = F, Columns = 1 },
		{ IsUserTab = false, AutoSelect = false, LayoutOrder = G }
	)
	local am, an = pcall(function()
		v.Build(al, ai)
	end)
	if not am then
		B.Warn("[SeaHub:Window] Settings tab build failed:", tostring(an))
	end
	function ai.Snapshot(ao, ap)
		return ah:Snapshot(ap)
	end
	function ai.Apply(ao, ap, aq)
		return ah:Apply(ap, aq)
	end
	function ai.ExportSchema(ao)
		return ah:ExportSchema()
	end
	function ai.Destroy(ao)
		ao._Destroyed = true
		P = P + 1
		if X then
			X()
			X = nil
		end
		if W then
			W()
			W = nil
		end
		V:Destroy()
		T:Destroy()
		R:Destroy()
		for ap, aq in J do
			if aq.Destroy then
				aq:Destroy()
			end
		end
		af:Destroy()
		U:Destroy()
		ag:Destroy()
		ac:Destroy()
		ae()
		Q:Destroy()
		ab:Destroy()
		Y:Destroy()
	end
	return ai
end
return E
end
a["UI/WindowBackdrop"]=function()
local aa, ab = d("Core/Common").Creator, {}
function ab.New(ac)
	local ad = aa.New(
		"TextButton",
		{
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			Visible = false,
			ZIndex = 85,
			Parent = ac.Parent,
		}
	)
	local ae, af = ad.Activated:Connect(ac.OnActivated), {}
	function af.SetOpen(ag, ah)
		ad.Visible = ah
	end
	function af.Destroy(ag)
		ae:Disconnect()
		ad:Destroy()
	end
	return af
end
return table.freeze(ab)
end
a["UI/WindowDesign"]=function()
local aa = { DESIGN_W = 800, DESIGN_H = 500, SHADOW_MARGIN = 100, VIEWPORT_MARGIN = 0.9 }
return table.freeze(aa)
end
a["UI/WindowDragger"]=function()
local aa = d("Core/Common")
local ab, ac, ad, ae = aa.Animator, aa.WindowDrag, d("UI/DragSkeleton"), {}
ae.__index = ae
local af
function ae.New(ag)
	local ah = tonumber(ag and ag.DragFpsCap) or 0
	local ai = setmetatable(
		{
			Parent = ag.Parent,
			Root = ag.Root,
			RootContainer = ag.RootContainer,
			Dragging = false,
			IsActuallyDragging = false,
			DragFlagArmed = false,
			DragPointerKind = nil,
			ActiveTouchInput = nil,
			DragStart = Vector3.zero,
			StartPos = UDim2.new(),
			PendingDragDelta = Vector3.zero,
			HasPendingDrag = false,
			LastDragApply = 0,
			DragFpsCap = ah,
			DragApplyInterval = (ah > 0) and (1 / ah) or 0,
			UseDragSkeleton = ag.UseDragSkeleton ~= false,
			DragProxy = nil,
			DragWindowActive = false,
		},
		ae
	)
	return ai
end
function ae.BeginDragVisual(ag)
	ad.Begin(ag)
end
function ae.CommitDragVisual(ag, ah)
	ad.Commit(ag, ah)
end
function ae.OnInputBegan(ag, ah)
	if af ~= nil and af ~= ag then
		return
	end
	if ah.UserInputType == Enum.UserInputType.MouseButton1 then
		ab.CancelInstance(ag.Root)
		af = ag
		ag.Dragging = true
		ag.DragPointerKind = "Mouse"
		ag.ActiveTouchInput = nil
		ag.IsActuallyDragging = false
		ag.DragFlagArmed = false
		ag.DragStart = ah.Position
		ag.StartPos = ag.Root.Position
	elseif ah.UserInputType == Enum.UserInputType.Touch then
		ab.CancelInstance(ag.Root)
		af = ag
		ag.Dragging = true
		ag.DragPointerKind = "Touch"
		ag.ActiveTouchInput = ah
		ag.IsActuallyDragging = false
		ag.DragFlagArmed = false
		ag.DragStart = ah.Position
		ag.StartPos = ag.Root.Position
	end
end
function ae.OnInputEnded(ag, ah)
	if ah.UserInputType == Enum.UserInputType.MouseButton1 and ag.DragPointerKind == "Mouse" then
		ag.Dragging = false
		ag.IsActuallyDragging = false
		ag.DragPointerKind = nil
		if af == ag then
			af = nil
		end
		if ag.DragFlagArmed then
			ag.DragFlagArmed = false
			ag:CommitDragVisual(function()
				if ag.DragWindowActive then
					ag.DragWindowActive = false
					ac.End()
				end
			end)
		end
	elseif
		ah.UserInputType == Enum.UserInputType.Touch
		and ag.DragPointerKind == "Touch"
		and ag.ActiveTouchInput == ah
	then
		ag.Dragging = false
		ag.IsActuallyDragging = false
		ag.DragPointerKind = nil
		ag.ActiveTouchInput = nil
		if af == ag then
			af = nil
		end
		if ag.DragFlagArmed then
			ag.DragFlagArmed = false
			ag:CommitDragVisual(function()
				if ag.DragWindowActive then
					ag.DragWindowActive = false
					ac.End()
				end
			end)
		end
	end
end
function ae.OnInputChanged(ag, ah)
	if not ag.Dragging then
		return
	end
	local ai
	if ag.DragPointerKind == "Mouse" then
		if ah.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		ai = ah.Position - ag.DragStart
	elseif ag.DragPointerKind == "Touch" then
		if ah.UserInputType ~= Enum.UserInputType.Touch or ah ~= ag.ActiveTouchInput then
			return
		end
		ai = ah.Position - ag.DragStart
	else
		return
	end
	if not ag.IsActuallyDragging and (math.abs(ai.X) > 3 or math.abs(ai.Y) > 3) then
		ag.IsActuallyDragging = true
		if not ag.DragFlagArmed then
			ag.DragFlagArmed = true
			ag:BeginDragVisual()
			if not ag.DragWindowActive then
				ag.DragWindowActive = true
				ac.Begin()
			end
		end
	end
	if ag.IsActuallyDragging then
		ag.PendingDragDelta = ai
		ag.HasPendingDrag = true
	end
end
function ae.OnRenderStepped(ag)
	if not ag.Dragging or not ag.IsActuallyDragging or not ag.HasPendingDrag then
		return
	end
	if ag.DragApplyInterval > 0 then
		local ah = os.clock()
		if ah - ag.LastDragApply < ag.DragApplyInterval then
			return
		end
		ag.LastDragApply = ah
	end
	ag.HasPendingDrag = false
	local ah = UDim2.new(
		ag.StartPos.X.Scale,
		ag.StartPos.X.Offset + ag.PendingDragDelta.X,
		ag.StartPos.Y.Scale,
		ag.StartPos.Y.Offset + ag.PendingDragDelta.Y
	)
	if ag.DragProxy and ag.DragProxy.Visible then
		ag.DragProxy.Position = ah
	else
		ag.Root.Position = ah
	end
end
function ae.SetDragFpsCap(ag, ah)
	local ai = tonumber(ah) or 0
	ag.DragFpsCap = ai
	ag.DragApplyInterval = (ai > 0) and (1 / ai) or 0
	ag.LastDragApply = 0
end
function ae.SetUseDragSkeleton(ag, ah)
	ad.SetUseSkeleton(ag, ah)
end
function ae.OnWindowResized(ag, ah, ai)
	ad.OnWindowResized(ag, ah, ai)
end
function ae.Destroy(ag)
	if af == ag then
		af = nil
	end
	if ag.DragWindowActive then
		ag.DragWindowActive = false
		ac.End()
	end
	ag.DragFlagArmed = false
	ad.Destroy(ag)
end
return ae
end
a["UI/WindowFrame"]=function()
local aa = d("Core/Common")
local ab, ac = aa.Creator, d("UI/WindowDesign")
local ad, ae = ab.New, {}
function ae.Build(af)
	local ag, ah, ai
	local aj = (
		ad(
			"CanvasGroup",
			{
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				GroupTransparency = 0,
				Position = af.Position or UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(ac.DESIGN_W + ac.SHADOW_MARGIN * 2, ac.DESIGN_H + ac.SHADOW_MARGIN * 2),
			},
			{
				ad(
					"Frame",
					{
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						ClipsDescendants = true,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(ac.DESIGN_W, ac.DESIGN_H),
						[ab.Ref] = function(aj)
							ag = aj
						end,
						[ab.InputBegan] = af.OnInputBegan,
						[ab.InputEnded] = af.OnInputEnded,
					},
					{
						ad(
							"UICorner",
							{
								CornerRadius = ab.GetThemeProperty("CornerRadiusWindow") or UDim.new(0, 12),
								[ab.ThemeTag] = { CornerRadius = "CornerRadiusWindow" },
							}
						),
						ad(
							"Frame",
							{
								AnchorPoint = Vector2.new(1, 0),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.fromScale(1, 0),
								Size = UDim2.new(1, -60, 1, 0),
								[ab.Ref] = function(aj)
									ah = aj
								end,
							},
							{
								ad("Folder", {
									[ab.Ref] = function(aj)
										ai = aj
									end,
								}),
								ad(
									"Frame",
									{
										BackgroundColor3 = Color3.fromRGB(20, 20, 20),
										BorderColor3 = Color3.fromRGB(0, 0, 0),
										BorderSizePixel = 0,
										Size = UDim2.fromScale(1, 1),
										Visible = false,
										ZIndex = 0,
										[ab.ThemeTag] = { BackgroundColor3 = "BackgroundMain" },
									},
									{
										ad(
											"UICorner",
											{
												CornerRadius = ab.GetThemeProperty("CornerRadiusSection")
													or UDim.new(0, 18),
												[ab.ThemeTag] = { CornerRadius = "CornerRadiusSection" },
											}
										),
										ad(
											"Frame",
											{
												BackgroundColor3 = Color3.fromRGB(20, 20, 20),
												BorderColor3 = Color3.fromRGB(0, 0, 0),
												BorderSizePixel = 0,
												Size = UDim2.new(0, 30, 1, 0),
												ZIndex = 0,
												[ab.ThemeTag] = { BackgroundColor3 = "BackgroundMain" },
											}
										),
									}
								),
							}
						),
						ad(
							"Frame",
							{
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 0,
								[ab.ThemeTag] = {
									BackgroundColor3 = "BackgroundMain",
									BackgroundTransparency = "BackgroundMainTransparency",
								},
							},
							{
								ad(
									"UICorner",
									{
										CornerRadius = ab.GetThemeProperty("CornerRadiusWindow") or UDim.new(0, 12),
										[ab.ThemeTag] = { CornerRadius = "CornerRadiusWindow" },
									}
								),
								ad(
									"ImageLabel",
									{
										Image = "rbxassetid://9968344227",
										ScaleType = Enum.ScaleType.Tile,
										TileSize = UDim2.fromOffset(128, 128),
										BackgroundColor3 = Color3.fromRGB(255, 255, 255),
										BackgroundTransparency = 1,
										BorderColor3 = Color3.fromRGB(0, 0, 0),
										BorderSizePixel = 0,
										Size = UDim2.fromScale(1, 1),
										[ab.ThemeTag] = { ImageTransparency = "NoiseTransparency" },
									},
									{
										ad(
											"UICorner",
											{
												CornerRadius = ab.GetThemeProperty("CornerRadiusNoise")
													or UDim.new(0, 26),
												[ab.ThemeTag] = { CornerRadius = "CornerRadiusNoise" },
											}
										),
									}
								),
							}
						),
					}
				),
				ad(
					"ImageLabel",
					{
						Image = "rbxassetid://8992230677",
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(99, 99, 99, 99),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -100, 1, -100),
						ZIndex = -1,
						[ab.ThemeTag] = { ImageColor3 = "ShadowColor", ImageTransparency = "ShadowTransparencyWindow" },
					}
				),
			}
		)
	)
	return aj, ag, ah, ai
end
return ae
end
a["UI/WindowSizeAdapter"]=function()
local aa, ab = d("UI/WindowDesign"), {}
ab.__index = ab
function ab.New(ac)
	local ad = setmetatable(
		{ Responsive = ac.Responsive, Root = ac.Root, RootContainer = ac.RootContainer, OnSizeChanged = ac.OnSizeChanged, Unsub = nil },
		ab
	)
	ad.Unsub = ad.Responsive.OnChanged(function()
		ad:AdaptSize()
	end)
	ad:AdaptSize()
	return ad
end
function ab.AdaptSize(ac)
	local ad, ae = ac.Responsive.ViewportWidth, ac.Responsive.ViewportHeight
	if ad < 1 or ae < 1 then
		return
	end
	local af, ag
	if ad >= aa.DESIGN_W + 32 and ae >= aa.DESIGN_H + 32 then
		af = aa.DESIGN_W
		ag = aa.DESIGN_H
	else
		local ah, ai = (ad * aa.VIEWPORT_MARGIN) / aa.DESIGN_W, (ae * aa.VIEWPORT_MARGIN) / aa.DESIGN_H
		local aj = math.min(ah, ai, 1)
		af = math.round(aa.DESIGN_W * aj)
		ag = math.round(aa.DESIGN_H * aj)
	end
	ac.RootContainer.Size = UDim2.fromOffset(af, ag)
	ac.Root.Size = UDim2.fromOffset(af + aa.SHADOW_MARGIN * 2, ag + aa.SHADOW_MARGIN * 2)
	if ac.OnSizeChanged then
		ac.OnSizeChanged(af, ag)
	end
end
function ab.Destroy(ac)
	if ac.Unsub then
		ac.Unsub()
		ac.Unsub = nil
	end
end
return ab
end
return d("Library")
