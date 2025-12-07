--[[
        Trình Quản Lý Tải
    Arceney.cc bởi 4lpaca
]]

local loader_cache = "ARCENEY_LOADER_CACHE";
local loader_cache = "KRYOFREE_LOADER_CACHE";

local Loader = (isfile(loader_cache) and loadstring(readfile(loader_cache))());

if not isfile(loader_cache) or not Loader then
    local src = game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/KryoFree/refs/heads/main/interface/loader.luau");

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
    local LoaderWindow = Loader.new("KRYOFREE","LOADER");
    local LicenseKeyCache = "KryoFree.license";

    LoaderWindow:AddLabel("Đang khởi tạo","Thành công");

    if not isfolder("KryoFree") then
        makefolder("KryoFree");

        LoaderWindow:AddLabel("Tạo thư mục \"KryoFree\"","Thành công");
    end;

    if not isfolder("KryoFree-bin") then
        makefolder("KryoFree-bin");

        LoaderWindow:AddLabel("Tạo thư mục \"KryoFree-bin\"","Thành công");
    end;

    if not isfolder("KryoFree-Cache") then
        makefolder("KryoFree-Cache");

        LoaderWindow:AddLabel("Tạo thư mục \"KryoFree-Cache\"","Thành công");
    end;

    if not isfolder("Arceney-bin") then
        makefolder("Arceney-bin");

        LoaderWindow:AddLabel("Tạo thư mục \"Arceney-bin\"","Thành công");
    end;

    if not isfolder("Arceney-Cache") then
        makefolder("Arceney-Cache");

        LoaderWindow:AddLabel("Tạo thư mục \"Arceney-Cache\"","Thành công");
    end;

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

    local sdk_api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))();
    local LoaderLink = (IsInternal and MainLoader) or SecondLoader;
    local ScriptId = string.match(LoaderLink, "https://api.luarmor.net/files/v3/loaders/(%w+).lua");

    sdk_api.script_id = ScriptId;

    local CheckKey = function(LicenseKey)
        if not LicenseKey:byte() then
            task.wait()

            return false;
        end;

        local test , message = pcall(sdk_api.check_key , tostring(LicenseKey));

        if test then
            
            if message.code == "KEY_VALID" then
                pcall(function()
                    LoaderWindow:WLWarning("Thành công","KẾT NỐI VỚI MÁY CHỦ");
                end);

                return true;
            elseif message.code == "KEY_EXPIRED" then
                pcall(function()
                    LoaderWindow:WLWarning("Cảnh báo","Khóa cấp phép đã hết hạn.");
                end);
            elseif message.code == "KEY_BANNED" then
                pcall(function()
                    LoaderWindow:WLWarning("Lỗi","Bạn bị cấm");
                end);
            elseif message.code == "KEY_HWID_LOCKED" then
                pcall(function()
                    LoaderWindow:WLWarning("Lỗi","ID phần cứng không hợp lệ");
                end);
            elseif message.code == "KEY_INCORRECT" then
                pcall(function()
                    LoaderWindow:WLWarning("Lỗi","Khóa không chính xác. Nhấp vào lấy khóa bên dưới");
                end);
            elseif message.code == "KEY_INVALID" then
                pcall(function()
                    LoaderWindow:WLWarning("Lỗi","Khóa cấp phép không hợp lệ");
                end);
            end;

            return false;
        end;

        LoaderWindow:WLWarning("Lỗi","MỘT LỖI");

        return false;
    end;

    local LoadKeySystem = function()
        local RateLimit = false;

        LoaderWindow:AddLabel("Hệ thống khóa","Thành công");

        LoaderWindow:Whitelist({
            {
                Text = "Lấy khóa",
                Callback = function()
                    (setclipboard or toclipboard)("https://arceney.cc/key")
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

    LoaderWindow:AddLabel("Đang tải script ...","Thành công");

    task.delay(1.5,LoaderWindow.Close);

    loadstring(game:HttpGet(LoaderLink))({
        script_key = getgenv().script_key
    });

    return true;
end;
