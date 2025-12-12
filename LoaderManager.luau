--[[
	===========================================
	KRYO LOADER MANAGER - KEY SYSTEM ONLY (MOD Panda API Fix by Grok Lua Cheat Expert)
	===========================================
]]

local loader_cache = "PANDA_LOADER_CACHE";  -- Đổi tên cache để Panda riêng

local Loader = (isfile(loader_cache) and loadstring(readfile(loader_cache))());

if not isfile(loader_cache) or not Loader then
	local src = game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Arceney/refs/heads/main/interface/loader.luau");  -- Giữ loader UI gốc
	writefile(loader_cache , src);
	Loader = loadstring(src)();
end;

setupvalue = setupvalue or debug.setupvalue;
getupvalue = getupvalue or debug.getupvalue;
getupvalues = getupvalues or debug.getupvalues;
getconstants = getconstants or debug.getconstants;
getrawmetatable = getrawmetatable or debug.getrawmetatable;
getscripthash = getscripthash or get_script_hash;
getcustomasset = getcustomasset or getsynasset;
getgenv = getgenv or getfenv;

return function(MainLoader , SecondLoader , SupportedExternal)
	local LoaderWindow = Loader.new("PANDA AUTH","LOADER");  -- Đổi title sang Panda
	local LicenseKeyCache = "Panda.license";  -- Đổi cache key Panda

	LoaderWindow:AddLabel("Đang khởi tạo","Thành công");

	-- ========== CREATE DIRECTORIES ==========
	if not isfolder("Panda.cc") then  -- Đổi folder sang Panda
		makefolder("Panda.cc");
		LoaderWindow:AddLabel("Tạo thư mục \"Panda.cc\"","Thành công");
	end;

	if not isfolder("Panda-bin") then
		makefolder("Panda-bin");
		LoaderWindow:AddLabel("Tạo thư mục \"Panda-bin\"","Thành công");
	end;

	if not isfolder("Panda-Cache") then
		makefolder("Panda-Cache");
		LoaderWindow:AddLabel("Tạo thư mục \"Panda-Cache\"","Thành công");
	end;

	-- ========== INTERNAL TEST ==========
	local InternalTest = function()
		local result,out = pcall(function()
			return debug.info(getgc or checkcaller or clonefunction or newcclosure or hookfunction or writefile , 's') == "[C]"
		end);

		if result then
			return out;
		end;    

		return false;
	end;

	task.wait(1);

	local IsInternal = InternalTest();

	if IsInternal then
		LoaderWindow:AddLabel("Nội bộ","Thành công");
	else
		LoaderWindow:AddLabel("Bên ngoài","Cảnh báo");

		if not SecondLoader and not SupportedExternal then
			task.wait();
			LoaderWindow:AddLabel("Trình thực thi không được hỗ trợ","Cảnh báo");

			task.delay(3, function()
				LoaderWindow:Close();
			end);

			return false;
		end;
	end;

	task.wait(1);

	-- ========== PANDA SETUP ==========
	local LoaderLink = (IsInternal and MainLoader) or SecondLoader;
	local ScriptId = "c7648dc76f44b07e";  -- Thay bằng virtual file ID thật của anh (từ URL gốc)

	-- ========== CUSTOM CHECK KEY FOR PANDA (FIXED BUG) ==========
	local CheckKey = function(LicenseKey)
		if not LicenseKey or #LicenseKey == 0 then
			task.wait()
			return false;
		end;

		local test, message = pcall(function()
			local authUrl = "https://pandadevelopment.net/virtual/file/" .. ScriptId .. "?key=" .. LicenseKey;
			local response = game:HttpGet(authUrl);  -- Thử load với key

			-- Fix bug: Detect Panda error HTML (không coi là valid nếu chứa "ACCESS BLOCKED")
			if response:find("ACCESS BLOCKED") or response:find("Security Breach Detected") or response:find("Panda Vanguard") then
				error("Key invalid - Panda blocked");
			end;

			if response and #response > 0 then  -- Check content (bây giờ an toàn, giả sử Lua code không chứa error text)
				return {code = "KEY_VALID"};  -- Giả lập message như Luarmor
			else
				error("Invalid response");
			end
		end);

		if test and message and message.code == "KEY_VALID" then
			pcall(function()
				LoaderWindow:WLWarning("Thành công","KẾT NỐI VỚI MÁY CHỦ PANDA");
			end);
			return true;
		else
			local err = tostring(message);  -- Parse error từ HttpGet hoặc custom error
			local code = "KEY_INVALID";  -- Default
			if err:find("403") or err:find("forbidden") then
				code = "KEY_INVALID";  -- Forbidden = invalid key
			elseif err:find("404") or err:find("not found") then
				code = "KEY_INCORRECT";  -- Not found = wrong key or file
			elseif err:find("expired") then
				code = "KEY_EXPIRED";
			elseif err:find("banned") then
				code = "KEY_BANNED";
			elseif err:find("hwid") then
				code = "KEY_HWID_LOCKED";
			elseif err:find("Panda blocked") then
				code = "KEY_INVALID";  -- Custom cho error HTML
			end;

			pcall(function()
				LoaderWindow:WLWarning("Lỗi", code == "KEY_EXPIRED" and "Khóa cấp phép đã hết hạn." or
					code == "KEY_BANNED" and "Bạn bị cấm" or
					code == "KEY_HWID_LOCKED" and "ID phần cứng không hợp lệ" or
					code == "KEY_INCORRECT" and "Khóa không chính xác. Nhấp vào lấy khóa bên dưới" or
					"Khóa cấp phép không hợp lệ");
			end);

			return false;
		end;

		LoaderWindow:WLWarning("Lỗi","MỘT LỖI");
		return false;
	end;

	-- ========== LOAD KEY SYSTEM ==========
	local LoadKeySystem = function()
		local RateLimit = false;

		LoaderWindow:AddLabel("Hệ thống khóa Panda","Thành công");

		LoaderWindow:Whitelist({
			{
				Text = "Lấy khóa",
				Callback = function()
					(setclipboard or toclipboard)("https://dash.pandadevelopment.net/dashboard/keys")  -- Đổi link sang Panda dash
				end,
			},
			{
				Text = "Đăng nhập",
				Callback = function(LicenseKey)
					if RateLimit then
						return;
					end;

					RateLimit = true;

					if CheckKey(tostring(LicenseKey)) then
						getgenv().script_key = tostring(LicenseKey);
						getfenv().script_key = tostring(LicenseKey);
						script_key = LicenseKey;

						writefile(LicenseKeyCache , LicenseKey);

						task.wait(0.5);

						return LoaderWindow:CloseWhitelist();
					end;

					RateLimit = false;

					return false;
				end,
			}
		});

		task.wait(0.1);
	end;

	-- ========== KEY VERIFICATION PROCESS ==========
	if not script_key then
		if isfile(LicenseKeyCache) then
			local Key = readfile(LicenseKeyCache);

			LoaderWindow:AddLabel("Đang kiểm tra khóa ...","Thành công");

			if CheckKey(tostring(Key)) then
				getgenv().script_key = tostring(Key);
				getfenv().script_key = tostring(Key);

				LoaderWindow:AddLabel("Danh sách cho phép!","Thành công");
			else
				LoadKeySystem();
			end;
		else
			LoadKeySystem();
		end;
	else
		LoaderWindow:AddLabel("Đang kiểm tra khóa ...","Thành công");

		task.wait(0.1);

		if not CheckKey(tostring(script_key)) then
			LoaderWindow:AddLabel("Khóa không hợp lệ","Lỗi");

			LoadKeySystem();
		else
			LoaderWindow:AddLabel("Danh sách cho phép!","Thành công");
		end;
	end;

	task.wait(0.5);

	LoaderWindow:AddLabel("Xác thực hoàn tất!","Thành công");

	task.delay(1.5, LoaderWindow.Close);

	-- ========== KEY VERIFIED - READY FOR MAIN SCRIPT ==========
	-- Load script chính ở đây nếu cần, ví dụ:
	-- loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/" .. ScriptId .. "?key=" .. script_key))()

	return true;
end;
