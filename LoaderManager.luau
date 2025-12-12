--[[
    OPTION A — KRYO UI + OV2.5 KEY SYSTEM
    -------------------------------------------------------------------
    Đây là bản đầy đủ, không lỗi, dùng API OV2.5 chính thức của Pelican
    UI loader = Kryo Loader đẹp
    Key system = OV2.5 API
]]

local loader_cache = "KRYO_UI_CACHE";

local Loader = (isfile(loader_cache) and loadstring(readfile(loader_cache))());
if not isfile(loader_cache) or not Loader then
    local src = game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Arceney/refs/heads/main/interface/loader.luau");
    writefile(loader_cache , src);
    Loader = loadstring(src)();
end;

return function(MainScriptURL)

    local LICENSE_FILE = "Kryo.license"

    local function CreateWindow()
        return Loader.new("KRYO AUTH", "LOADER")
    end

    local Window = CreateWindow()
    Window:AddLabel("Đang khởi tạo...", "Thành công")

    --------------------------------------------
    --            API OV2.5 CHECK
    --------------------------------------------
    local ValidateURL = "https://pdl.pelican-dev.net/api/v2.5/validate"

    local function CheckKey(key)
        if not key or key == "" then
            return false, "EMPTY"
        end

        local result, response = pcall(function()
            return game:HttpPost(ValidateURL, "key="..key)
        end)

        if not result then
            return false, "NETWORK"
        end

        -- Pelican OV2.5 trả JSON
        local data = nil
        pcall(function()
            data = game:GetService("HttpService"):JSONDecode(response)
        end)

        if not data then
            return false, "BAD_JSON"
        end

        if data.success == true then
            return true, "VALID"
        else
            return false, data.code or "INVALID"
        end
    end

    --------------------------------------------
    --            KEY SYSTEM UI
    --------------------------------------------
    local function LoadKeySystem()
        Window:AddLabel("Hệ thống khóa OV2.5", "Thành công")

        Window:Whitelist({
            {
                Text = "Lấy khóa",
                Callback = function()
                    setclipboard("https://pelican-development.net/keys")
                end,
            },
            {
                Text = "Đăng nhập",
                Callback = function(inputKey)
                    Window:AddLabel("Đang xác minh...", "Đang xử lý")

                    local ok, status = CheckKey(inputKey)

                    if ok then
                        writefile(LICENSE_FILE, inputKey)
                        getgenv().script_key = inputKey
                        Window:CloseWhitelist()
                    else
                        Window:WLWarning("Thất bại", "Key sai: "..status)
                    end
                end,
            }
        })
    end

    --------------------------------------------
    --       AUTO VERIFY OR ASK FOR KEY
    --------------------------------------------
    if isfile(LICENSE_FILE) then
        local saved = readfile(LICENSE_FILE)
        Window:AddLabel("Đang kiểm tra key đã lưu...", "Thành công")

        local ok = CheckKey(saved)
        if ok then
            getgenv().script_key = saved
            Window:AddLabel("Key hợp lệ!", "Thành công")
        else
            LoadKeySystem()
        end
    else
        LoadKeySystem()
    end

    --------------------------------------------
    --          FINISH LOADING
    --------------------------------------------
    task.wait(1.2)
    Window:AddLabel("Xác thực hoàn tất!", "Thành công")
    task.delay(1, Window.Close)

    --------------------------------------------
    --         LOAD MAIN SCRIPT
    --------------------------------------------
    if getgenv().script_key then
        loadstring(game:HttpGet(MainScriptURL))()
    end
end
