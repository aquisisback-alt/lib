--[[
    Made by samet

    example/documentation is at the bottom
    date: 4/16/2026 12:09 AM

    If you have any issues or bugs, please let me know in the ticket or dms.
]]

if getgenv().Library and getgenv().Library.Exit then
    getgenv().Library:Exit()
end

-- Bad executor support (atleast by a bit)
cloneref = cloneref or function(Object) return Object end 

--#region Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local CoreGui = cloneref(game:GetService("CoreGui"))
--#endregion

gethui = gethui or function() return CoreGui end

--#region Variables 
local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled or false
local Camera = Workspace.CurrentCamera
local GuiInset = GuiService:GetGuiInset().Y
local Mouse = cloneref(LocalPlayer:GetMouse())
--#endregion

local Library = { 
    Flags = { },
    MenuKeybind = tostring(Enum.KeyCode.X),

    Directory = "samethub",
    Folders = {
        Assets = "/Assets",
        Configs = "/Configs"
    },

    FontSize = 17,

    Animation = {
        Time = 0.3,
        Style = "Quint",
        Direction = "Out"
    },

    ZIndexOrder = {
        ["OptionHolder"] = 4,
        ["KeybindWindow"] = 4,
        ["ColorpickerWindow"] = 6
    },

    Theme = nil,

    -- Ignore below
    Threads = { },
    Connections = { },
    SetFlags = { },

    ThemingStuff = { },
    ThemeMap = { },

    OpenFrames = { },

    Holder = nil,
    UnusedHolder = nil,

    Font = nil
} do 
    Library.__index = Library

    local Flags = Library.Flags 
    local SetFlags = Library.SetFlags

    local Keys = {
        ["Unknown"]           = "Unknown",
        ["Backspace"]         = "Back",
        ["Tab"]               = "Tab",
        ["Clear"]             = "Clear",
        ["Return"]            = "Return",
        ["Pause"]             = "Pause",
        ["Escape"]            = "Escape",
        ["Space"]             = "Space",
        ["QuotedDouble"]      = '"',
        ["Hash"]              = "#",
        ["Dollar"]            = "$",
        ["Percent"]           = "%",
        ["Ampersand"]         = "&",
        ["Quote"]             = "'",
        ["LeftParenthesis"]   = "(",
        ["RightParenthesis"]  = " )",
        ["Asterisk"]          = "*",
        ["Plus"]              = "+",
        ["Comma"]             = ",",
        ["Minus"]             = "-",
        ["Period"]            = ".",
        ["Slash"]             = "`",
        ["Three"]             = "3",
        ["Seven"]             = "7",
        ["Eight"]             = "8",
        ["Colon"]             = ":",
        ["Semicolon"]         = ";",
        ["LessThan"]          = "<",
        ["GreaterThan"]       = ">",
        ["Question"]          = "?",
        ["Equals"]            = "=",
        ["At"]                = "@",
        ["LeftBracket"]       = "LeftBracket",
        ["RightBracket"]      = "RightBracked",
        ["BackSlash"]         = "BackSlash",
        ["Caret"]             = "^",
        ["Underscore"]        = "_",
        ["Backquote"]         = "`",
        ["LeftCurly"]         = "{",
        ["Pipe"]              = "|",
        ["RightCurly"]        = "}",
        ["Tilde"]             = "~",
        ["Delete"]            = "Delete",
        ["End"]               = "End",
        ["KeypadZero"]        = "Keypad0",
        ["KeypadOne"]         = "Keypad1",
        ["KeypadTwo"]         = "Keypad2",
        ["KeypadThree"]       = "Keypad3",
        ["KeypadFour"]        = "Keypad4",
        ["KeypadFive"]        = "Keypad5",
        ["KeypadSix"]         = "Keypad6",
        ["KeypadSeven"]       = "Keypad7",
        ["KeypadEight"]       = "Keypad8",
        ["KeypadNine"]        = "Keypad9",
        ["KeypadPeriod"]      = "KeypadP",
        ["KeypadDivide"]      = "KeypadD",
        ["KeypadMultiply"]    = "KeypadM",
        ["KeypadMinus"]       = "KeypadM",
        ["KeypadPlus"]        = "KeypadP",
        ["KeypadEnter"]       = "KeypadE",
        ["KeypadEquals"]      = "KeypadE",
        ["Insert"]            = "Insert",
        ["Home"]              = "Home",
        ["PageUp"]            = "PageUp",
        ["PageDown"]          = "PageDown",
        ["RightShift"]        = "RightShift",
        ["LeftShift"]         = "LeftShift",
        ["RightControl"]      = "RightControl",
        ["LeftControl"]       = "LeftControl",
        ["LeftAlt"]           = "LeftAlt",
        ["RightAlt"]          = "RightAlt"
    }

    -- Folders
    if not isfolder(Library.Directory) then 
        makefolder(Library.Directory)
    end

    for _, Folder in Library.Folders do 
        if not isfolder(Library.Directory .. Folder) then 
            makefolder(Library.Directory .. Folder)
        end
    end

    local Themes = {
        ["Preset"] = {
            ["Background"] = Color3.fromRGB(16, 17, 20),
            ["Inline"] = Color3.fromRGB(27, 28, 33),
            ["Top"] = Color3.fromRGB(31, 33, 38),
            ["Outline"] = Color3.fromRGB(29, 31, 36),
            ["Text"] = Color3.fromRGB(255, 255, 255),
            ["Inactive Text"] = Color3.fromRGB(140, 141, 143),
            ["Hovered Element"] = Color3.fromRGB(37, 38, 43),
            ["Element"] = Color3.fromRGB(23, 23, 26),
            ["Accent"] = Color3.fromRGB(137, 188, 255)
        }
    }

    Library.Theme = Themes.Preset

    -- Custom Font
    local CustomFont = { } do
        function CustomFont:New(Name, Weight, Style, Data)
            if not isfile(Data.Id) then 
                writefile(Data.Id, game:HttpGet(Data.Url))
            end

            local Data = {
                name = Name,
                faces = {
                    {
                        name = Name,
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(Data.Id)
                    }
                }
            }

            writefile(`{Library.Directory .. Library.Folders.Assets}/{Name}.font`, HttpService:JSONEncode(Data))
            return Font.new(getcustomasset(`{Library.Directory .. Library.Folders.Assets}/{Name}.font`))
        end

        Library.Font = CustomFont:New("Figtree", 400, "Regular", {
            Id = "Figtree",
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/Figtree-SemiBold.ttf"
        })
    end

    Library.Exit = function(Self)
        for _, Connection in Library.Connections do 
            Connection:Disconnect()
        end

        for _, Thread in Library.Threads do 
            coroutine.close(Thread)
        end

        if Self.Holder then 
            Self.Holder.Instance:Destroy()
        end

        if Self.UnusedHolder then 
            Self.UnusedHolder.Instance:Destroy()
        end

        Library = nil
        getgenv().Library = nil
    end

    Library.Create = function(Self, Class, Properties)
        local Data = {
            Class = Class,
            Properties = Properties,
            Instance = Instance.new(Class)
        }

        for Index, Property in Properties do 
            if Property == "FontFace" then
                Data.Instance[Property] = Library.Font
                continue
            end

            if Property == "TextSize" then 
                Data.Instance[Property] = Library.FontSize
                continue
            end

            if Property == "Name" then 
                Data.Instance[Property] = "\0"
                continue
            end

            if Class == "TextButton" then 
                if Property == "AutoButtonColor" then 
                    Data.Instance[Property] = false
                    continue
                end

                if Property == "Text" then 
                    Data.Instance[Property] = ""
                    continue
                end
            end

            Data.Instance[Index] = Property
        end

        return setmetatable(Data, Library)
    end

    Library.Thread = function(Self, Function)
        local NewThread = coroutine.create(Function)
        
        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()

        table.insert(Library.Threads, NewThread)
        return NewThread
    end

    Library.Connect = function(Self, Signal, Callback)
        local Connection

        if Self.Instance then
            if Self.Instance[Signal] then 
                if IsMobile and Signal == "MouseButton1Down" then 
                    Connection = Self.Instance.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            Callback(Input)
                        end
                    end)

                    return
                end
                
                Connection = Self.Instance[Signal]:Connect(Callback)
            else
                Connection = Signal:Connect(Callback)
            end
        else
            Connection = Signal:Connect(Callback)
        end

        table.insert(Library.Connections, Connection)
        return Connection
    end

    Library.Tween = function(Self, Properties, Info, IsRawItem)
        local Object = Self.Instance or IsRawItem
        Info = Info or TweenInfo.new(Library.Animation.Time, Enum.EasingStyle[Library.Animation.Style], Enum.EasingDirection[Library.Animation.Direction])

        if not Object then 
            return 
        end

        local NewTween = TweenService:Create(Object, Info, Properties)
        NewTween:Play()

        return NewTween
    end

    Library.GetTweenProperty = function(Self, IsRawItem)
        local Object = Self.Instance or IsRawItem

        if not Object then 
            return { }
        end

        if Object:IsA("Frame") then
            return { "BackgroundTransparency" }
        elseif Object:IsA("TextLabel") or Object:IsA("TextButton") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
            return { "BackgroundTransparency", "ImageTransparency" }
        elseif Object:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Object:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Object:IsA("UIStroke") then 
            return { "Transparency" }
        end
    end

    Library.Fade = function(Self, Property, Visibility, IsRawItem)
        local Object = Self.Instance or IsRawItem

        if not Object then 
            return 
        end

        local OldTransparency = Object[Property]
        Object[Property] = Visibility and 1 or OldTransparency

        local NewTween = Library:Tween({
            [Property] = Visibility and OldTransparency or 1
        }, nil, Object)

        Library:Connect(NewTween.Completed, function()
            if not Visibility then 
                task.wait()
                Object[Property] = OldTransparency
            end
        end)

        return NewTween
    end

    Library.FadeDescendants = function(Self, Visibility, Callback)
        if Visibility then 
            Self.Instance.Visible = true 
        end

        local NewTween 

        local Children = Self.Instance:GetDescendants()
        table.insert(Children, Self.Instance)

        for _, Child in Children do 
            local TransparencyProperty = Library:GetTweenProperty(Child)

            if not TransparencyProperty then 
                continue 
            end

            if type(TransparencyProperty) == "table" then
                for _, Property in TransparencyProperty do
                    NewTween = Library:Fade(Property, Visibility, Child)
                end
            else
                NewTween = Library:Fade(TransparencyProperty, Visibility, Child)
            end
        end

        Library:Connect(NewTween.Completed, function()
            if Callback and type(Callback) == "function" then 
                Callback()
            end

            Self.Instance.Visible = Visibility
        end)
    end

    Library.MakeDraggable = function(Self)
        if not Self.Instance then 
            return
        end
    
        local Gui = Self.Instance
        local Dragging = false 
        local DragStart
        local StartPosition 
    
        local Set = function(Input)
            local DragDelta = Input.Position - DragStart
            local NewX = StartPosition.X.Offset + DragDelta.X
            local NewY = StartPosition.Y.Offset + DragDelta.Y

            local ScreenSize = Gui.Parent.AbsoluteSize
            local GuiSize = Gui.AbsoluteSize
    
            NewX = math.clamp(NewX, 0, ScreenSize.X - GuiSize.X)
            NewY = math.clamp(NewY, 0, ScreenSize.Y - GuiSize.Y)
    
            Self:Tween({Position = UDim2.new(0, NewX, 0, NewY)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        end
    
        local InputChanged
    
        Self:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position
                StartPosition = Gui.Position
    
                if InputChanged then 
                    return
                end
    
                InputChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                        InputChanged:Disconnect()
                        InputChanged = nil
                    end
                end)
            end
        end)
    
        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if Dragging then
                    Set(Input)
                end
            end
        end)
    
        return Dragging
    end

    Library.MakeResizeable = function(Self, Minimum)
        if not Self.Instance then 
            return
        end

        local Gui = Self.Instance

        local Resizing = false 
        local CurrentSide = nil

        local StartMouse = nil 
        local StartPosition = nil 
        local StartSize = nil
        
        local EdgeThickness = 2

        local MakeEdge = function(Name, Position, Size)
            local Button = Library:Create("TextButton", {
                Name = "\0",
                Size = Size,
                Position = Position,
                BackgroundColor3 = Color3.fromRGB(166, 147, 243),
                BackgroundTransparency = 1,
                Text = "",
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Parent = Gui,
                ZIndex = 99999,
            })  Button:AddToTheme({BackgroundColor3 = "Accent"})

            return Button
        end

        local Edges = {
            {Button = MakeEdge(
                "Left", 
                UDim2.new(0, 0, 0, 0), 
                UDim2.new(0, EdgeThickness, 1, 0)), 
                Side = "L"
            },

            {Button = MakeEdge(
                "Right", 
                UDim2.new(1, -EdgeThickness, 0, 0), 
                UDim2.new(0, EdgeThickness, 1, 0)), 
                Side = "R"
            },

            {Button = MakeEdge(
                "Top", UDim2.new(0, 0, 0, 0), 
                UDim2.new(1, 0, 0, EdgeThickness)), 
                Side = "T"
            },

            {Button = MakeEdge(
                "Bottom", 
                UDim2.new(0, 0, 1, -EdgeThickness), 
                UDim2.new(1, 0, 0, EdgeThickness)), 
                Side = "B"
            },
        }

        local BeginResizing = function(Side)
            Resizing = true 
            CurrentSide = Side 

            StartMouse = UserInputService:GetMouseLocation()

            StartPosition = Vector2.new(Gui.Position.X.Offset, Gui.Position.Y.Offset)
            StartSize = Vector2.new(Gui.Size.X.Offset, Gui.Size.Y.Offset)
            
            for Index, Value in Edges do 
                Value.Button.Instance.BackgroundTransparency = (Value.Side == Side) and 0 or 1
            end
        end

        local EndResizing = function()
            Resizing = false 
            CurrentSide = nil

            for Index, Value in Edges do 
                Value.Button.Instance.BackgroundTransparency = 1
            end
        end

        for Index, Value in Edges do 
            Value.Button:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    BeginResizing(Value.Side)
                end
            end)
        end

        Library:Connect(UserInputService.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if Resizing then
                    EndResizing()
                end
            end
        end)

        Library:Connect(RunService.RenderStepped, function()
            if not Resizing or not CurrentSide then 
                return 
            end

            local MouseLocation = UserInputService:GetMouseLocation()
            local dx = MouseLocation.X - StartMouse.X
            local dy = MouseLocation.Y - StartMouse.Y
        
            local x, y = StartPosition.X, StartPosition.Y
            local w, h = StartSize.X, StartSize.Y

            if CurrentSide == "L" then
                x = StartPosition.X + dx
                w = StartSize.X - dx
            elseif CurrentSide == "R" then
                w = StartSize.X + dx
            elseif CurrentSide == "T" then
                y = StartPosition.Y + dy
                h = StartSize.Y - dy
            elseif CurrentSide == "B" then
                h = StartSize.Y + dy
            end
        
            if w < Minimum.X then
                if CurrentSide == "L" then
                    x = x - (Minimum.X - w)
                end
                w = Minimum.X
            end
            if h < Minimum.Y then
                if CurrentSide == "T" then
                    y = y - (Minimum.Y - h)
                end
                h = Minimum.Y
            end
        
            Self:Tween({Position = UDim2.fromOffset(x, y)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            Self:Tween({Size = UDim2.fromOffset(w, h)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        end)
    end

    Library.IsMouseOverFrame = function(Self)
        if not Self.Instance then 
            return 
        end

        local Object = Self.Instance

        local MousePosition = Vector2.new(Mouse.X, Mouse.Y)

        return MousePosition.X >= Object.AbsolutePosition.X and MousePosition.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X 
        and MousePosition.Y >= Object.AbsolutePosition.Y and MousePosition.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y
    end

    Library.SafeCall = function(Self, Function, ...)
        local Arguements = { ... }
        local Success, Result = pcall(Function, table.unpack(Arguements))

        if not Success then
            warn(Result)
            return false
        end

        return Success, Result
    end

    Library.Round = function(Self, Number, Float)
        Number = tonumber(Number) or 0
        Float = tonumber(Float) or 0
        if Number ~= Number then Number = 0 end
        
        if Float <= 0 then 
            return math.floor(Number + 0.5) 
        end
        
        local Multiplier = 1 / Float
        return math.floor(Number * Multiplier + 0.5) / Multiplier
    end

    Library.GetConfig = function(Self)
        local Config = { }

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Library.Flags do 
                if type(Value) == "table" and Value.Key then
                    Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                elseif type(Value) == "table" and Value.Color then
                    Config[Index] = {Color = "#" .. Value.HexValue, Alpha = Value.Alpha}
                else
                    Config[Index] = Value
                end
            end
        end)

        if not Success then
            warn("Failed to get config:\n"..Result)
            return
        end

        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(Self, Config)
        local Decoded = HttpService:JSONDecode(Config)

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Decoded do 
                local SetFunction = Library.SetFlags[Index]

                if not SetFunction then
                    continue
                end

                if type(Value) == "table" and Value.Key then 
                    SetFunction(Value)
                elseif type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
        end)

        return Success, Result
    end

    Library.GetConfigsList = function(Self, Element)
        local List = { }
        local ReturnList = { }

        List = listfiles(Library.Directory .. Library.Folders.Configs)

        for Index = 1, #List do 
            local File = List[Index]

            if File:sub(-5) == ".json" then
                local Position = File:find(".json", 1, true)
                local StartPosition = Position

                local Character = File:sub(Position, Position)
                while Character ~= "/" and Character ~= "\\" and Character ~= "" do
                    Position = Position - 1
                    Character = File:sub(Position, Position)
                end

                if Character == "/" or Character == "\\" then
                    table.insert(ReturnList, File:sub(Position + 1, StartPosition - 1))
                end
            end
        end

        Element:Refresh(ReturnList)
    end

    Library.AddToTheme = function(Self, Properties)
        local Object = Self.Instance

        local ThemeData = {
            Item = Object,
            Properties = Properties,
        }

        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                if not Library.Theme[Value] then
                    Object[Property] = Value 
                end

                Object[Property] = Library.Theme[Value]
            else
                Object[Property] = Value()
            end
        end

        table.insert(Library.ThemingStuff, ThemeData)
        Library.ThemeMap[Object] = ThemeData
        return Self
    end

    Library.ChangeItemTheme = function(Self, Properties)
        local Object = Self.Instance

        if not Library.ThemeMap[Object] then 
            return
        end

        Library.ThemeMap[Object].Properties = Properties
        Library.ThemeMap[Object] = Library.ThemeMap[Object]
    end

    Library.ChangeTheme = function(Self, Theme, Color)
        Library.Theme[Theme] = Color

        for _, Item in Library.ThemingStuff do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    Library.OnHover = function(Self, OnHoverEnter, OnHoverLeave)
        local Object = Self.Instance

        if not Object then 
            return 
        end 

        Library:Connect(Object.MouseEnter, OnHoverEnter)
        Library:Connect(Object.MouseLeave, OnHoverLeave)
    end

    Library.GetCalculatedRayPosition = function(Self, Position, Normal, Origin, Direction)
        local N = Normal
        local D = Direction
        local V = Origin - Position

        local Number = (N.x * V.x) + (N.y * V.y) + (N.z * V.z)
        local Den = (N.x * D.x) + (N.y * D.y) + (N.z * D.z)
        local A = -Number / Den

        return Origin + (A * Direction)
    end

    Library.MakeBlurred = function(Self, Window)
        local BlurItem = Self.Instance 

        if not BlurItem then 
            return 
        end

        local Part = Library:Create("Part", {
            Material = Enum.Material.Glass,
            Transparency = 1,
            Reflectance = 1,
            CastShadow = false,
            Anchored = true,
            CanCollide = false,
            CanQuery = false,
            CollisionGroup = " ",
            Size = Vector3.new(1, 1, 1) * 0.01,
            Color = Color3.fromRGB(0,0,0),
            Parent = Camera
        })
            
        local BlockMesh = Library:Create("BlockMesh", {Parent = Part.Instance})

        local DepthOfField = Library:Create("DepthOfFieldEffect", {
            Parent = Lighting,
            Enabled = true,
            FarIntensity = 0,
            FocusDistance = 0,
            InFocusRadius = 1000,
            NearIntensity = 1,
            Name = ""
        })

        Library:Connect(RunService.RenderStepped, function()
            if Window.IsOpen then
                DepthOfField:Tween({NearIntensity = 1})

                Part:Tween({Transparency = 0.97})
                Part:Tween({Size = Vector3.new(1, 1, 1) * 0.01})

                local Corner0 = BlurItem.AbsolutePosition;
                local Corner1 = Corner0 + BlurItem.AbsoluteSize;
                    
                local Ray0 = Camera.ScreenPointToRay(Camera, Corner0.X, Corner0.Y, 1);
                local Ray1 = Camera.ScreenPointToRay(Camera, Corner1.X, Corner1.Y, 1);

                local Origin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ);

                local Normal = Camera.CFrame.LookVector;

                local Position0 = Library:GetCalculatedRayPosition(Origin, Normal, Ray0.Origin, Ray0.Direction)
                local Position1 = Library:GetCalculatedRayPosition(Origin, Normal, Ray1.Origin, Ray1.Direction)

                Position0 = Camera.CFrame:PointToObjectSpace(Position0)
                Position1 = Camera.CFrame:PointToObjectSpace(Position1)

                local Size = Position1 - Position0
                local Center = (Position0 + Position1) / 2

                BlockMesh.Instance.Offset = Center
                BlockMesh.Instance.Scale  = Size / 0.0101

                Part.Instance.CFrame = Camera.CFrame
            else
                DepthOfField:Tween({NearIntensity = 0})

                BlockMesh.Instance.Offset = Vector3.new(0, 0, 0)
                BlockMesh.Instance.Scale  = Vector3.new(0, 0, 0)
            end
        end)
    end

    Library.Holder = Library:Create("ScreenGui", {
        Parent = gethui(),
        IgnoreGuiInset = true,
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Library:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        Enabled = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Library:Create("Frame", {
        Name = "\0",
        Parent = Library.Holder.Instance,
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X
    })
    
    Library:Create("UIListLayout", {
        Name = "\0",
        Parent = Library.NotifHolder.Instance,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8)
    })

    Library:Create("UIPadding", {
        Name = "\0",
        Parent = Library.NotifHolder.Instance,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8)
    })

    do
        Library.CreateColorpicker = function(Self, Data)
            local Colorpicker = {
                Hue = 0,
                Saturation = 0,
                Value = 0,

                Alpha = 0,

                Color = Color3.fromRGB(255, 255, 255),
                HexValue = "#FFFFFF",

                Flag = Data.Flag,
                IsOpen = false,


                Items = { }
            }

            local Items = { } do 
                Items["ColorpickerButton"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Data.Parent.Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2.new(0, 20, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 0, 4)
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["ColorpickerButton"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 229, 229))
                }
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["ColorpickerButton"].Instance
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["ColorpickerButton"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})     
                
                Items["ColorpickerWindow"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Library.UnusedHolder.Instance,
                    Visible = false,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2.new(0, 40, 0, 321),
                    Size = UDim2.new(0, 222, 0, 222),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Background"]
                }):AddToTheme({BackgroundColor3 = 'Background'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["ColorpickerWindow"].Instance
                })
                
                Items["Palette"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["ColorpickerWindow"].Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -50, 1, -92),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Palette"].Instance
                })
                
                Items["Saturation"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Palette"].Instance,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Saturation"].Instance
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Saturation"].Instance,
                    Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                }
                })
                
                Items["Value"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Palette"].Instance,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Value"].Instance
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Value"].Instance,
                    Rotation = 90,
                    Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                }
                })
                
                Items["PaletteDragger"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Palette"].Instance,
                    Size = UDim2.new(0, 5, 0, 5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["PaletteDragger"].Instance
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["PaletteDragger"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Background"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["ColorpickerWindow"].Instance,
                    Active = true,
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 0.10000000149011612,
                    Position = UDim2.new(0, 10, 1, -10),
                    Size = UDim2.new(1, -20, 0, 30),
                    Selectable = true,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Background"].Instance
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Background"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 229, 229))
                }
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["Background"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Input"] = Library:Create("TextBox", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Background"].Instance,
                    Active = false,
                    Selectable = false,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    PlaceholderColor3 = Library.Theme["Inactive Text"],
                    Size = UDim2.new(0, 0, 0, 15),
                    TextColor3 = Library.Theme["Text"],
                    Text = "255, 0, 0",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Hue"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["ColorpickerWindow"].Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -10, 0, 10),
                    Size = UDim2.new(0, 20, 1, -61),
                    BorderSizePixel = 0
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Hue"].Instance
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Hue"].Instance,
                    Rotation = 90,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }
                })
                
                Items["HueDragger"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Hue"].Instance,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(1, 0, 0, 4),
                    ZIndex = 3,
                    BorderSizePixel = 0
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["HueDragger"].Instance
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["HueDragger"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Alpha"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["ColorpickerWindow"].Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 10, 1, -51),
                    Size = UDim2.new(1, -50, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Alpha"].Instance
                })
                
                Items["Checkers"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["Alpha"].Instance,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 6, 0, 6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Image = "http://www.roblox.com/asset/?id=18274452449",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Checkers"].Instance,
                    Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.37, 0.5),
                    NumberSequenceKeypoint.new(1, 0)
                }
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Checkers"].Instance
                })
                
                Items["AlphaDragger"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Alpha"].Instance,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(0, 4, 1, 0),
                    ZIndex = 3,
                    BorderSizePixel = 0
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["AlphaDragger"].Instance
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["AlphaDragger"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})                

                Colorpicker.Items = Items
            end

            Colorpicker.Holder = Items["ColorpickerWindow"]

            function Colorpicker:SetVisibility(Bool)
                Items["ColorpickerButton"].Instance.Visible = Bool
            end

            function Colorpicker:Update(IsFromAlpha)
                local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
                Colorpicker.Color = Color3.fromHSV(Hue, Saturation, Value)
                Colorpicker.HexValue = Colorpicker.Color:ToHex()
        
                Items["ColorpickerButton"]:Tween({BackgroundColor3 = Colorpicker.Color})
                Items["Palette"]:Tween({BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)})

                Flags[Colorpicker.Flag] = {
                    Alpha = Colorpicker.Alpha,
                    Color = Colorpicker.Color,
                    HexValue = Colorpicker.HexValue,
                    Transparency = 1 - Colorpicker.Alpha
                }

                local Red, Green, Blue = math.floor(Colorpicker.Color.R * 255), math.floor(Colorpicker.Color.G * 255), math.floor(Colorpicker.Color.B * 255)
    
                Items["Input"].Instance.Text = tostring(Red)..", "..tostring(Green)..", "..tostring(Blue)
    
                if not IsFromAlpha then 
                    Items["Alpha"]:Tween({BackgroundColor3 = Colorpicker.Color})
                end
    
                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)
                end
            end

            local Debounce = false 
            local ColorpickerWindow = Items["ColorpickerWindow"].Instance
            local ColorpickerButton = Items["ColorpickerButton"].Instance

            local IsSettings = Data.Section and Data.Section.IsSettings

            function Colorpicker:SetOpen(Bool)
                if Debounce then 
                    return 
                end

                Colorpicker.IsOpen = Bool

                Debounce = true 
                
                if Colorpicker.IsOpen then 
                    ColorpickerWindow.Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y + GuiInset)

                    ColorpickerWindow.Parent = Library.Holder.Instance
                    ColorpickerWindow.Visible = true
                    Items["ColorpickerWindow"]:Tween({Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y + 10 + GuiInset)})
                    
                    Items["ColorpickerWindow"]:FadeDescendants(true, function()
                        Debounce = false
                    end)

                    for Index, Value in Library.OpenFrames do
                        if Value ~= IsSettings then
                            Value:SetOpen(false)
                        end
                    end

                    Library.OpenFrames[Colorpicker] = Colorpicker 
                else
                    Items["ColorpickerWindow"]:Tween({Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y - 10 + GuiInset)})
                    Items["ColorpickerWindow"]:FadeDescendants(false, function()
                        ColorpickerWindow.Parent = Library.UnusedHolder.Instance
                        Debounce = false
                    end)

                    if Library.OpenFrames[Colorpicker] then 
                        Library.OpenFrames[Colorpicker] = nil
                    end
                end

                local Descendants = ColorpickerWindow:GetDescendants()
                table.insert(Descendants, ColorpickerWindow)

                for Index, Value in Descendants do 
                    if Value.ClassName:find("UI") then
                        continue
                    end

                    if IsSettings then
                        Value.ZIndex = Colorpicker.IsOpen and Library.ZIndexOrder.ColorpickerWindow + 4 or 1
                    else
                        Value.ZIndex = Colorpicker.IsOpen and Library.ZIndexOrder.ColorpickerWindow or 1
                    end
                end
            end
    
            local SlidingPalette = false
            local PaletteChanged
            
            function Colorpicker:SlidePalette(Input)
                if not Input or not SlidingPalette then
                    return
                end
    
                local ValueX = math.clamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
                local ValueY = math.clamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)
    
                Colorpicker.Saturation = ValueX
                Colorpicker.Value = ValueY
    
                local SlideX = math.clamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.98)
                local SlideY = math.clamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.98)
    
                Items["PaletteDragger"]:Tween({Position = UDim2.new(SlideX, 0, SlideY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                Colorpicker:Update()
            end
            
            local SlidingHue = false
            local HueChanged
    
            function Colorpicker:SlideHue(Input)
                if not Input or not SlidingHue then
                    return
                end
                
                local ValueY = math.clamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 1)
    
                Colorpicker.Hue = ValueY
    
                local SlideY = math.clamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 0.985)
    
                Items["HueDragger"]:Tween({Position = UDim2.new(0, 0, SlideY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                Colorpicker:Update()
            end
    
            local SlidingAlpha = false 
            local AlphaChanged
    
            function Colorpicker:SlideAlpha(Input)
                if not Input or not SlidingAlpha then
                    return
                end
    
                local ValueX = math.clamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 1)
    
                Colorpicker.Alpha = ValueX
    
                local SlideX = math.clamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 0.98)
    
                Items["AlphaDragger"]:Tween({Position = UDim2.new(SlideX, 0, 0, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                Colorpicker:Update(true)
            end
    
            function Colorpicker:Set(Color, Alpha)
                if type(Color) == "table" then
                    Color = Color3.fromRGB(Color[1], Color[2], Color[3])
                elseif type(Color) == "string" then
                    Color = Color3.fromHex(Color)
                else
                    Color = Color -- lul
                end 

                Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
                Colorpicker.Alpha = Alpha or 0  
    
                local PaletteValueX = math.clamp(1 - Colorpicker.Saturation, 0, 0.985)
                local PaletteValueY = math.clamp(1 - Colorpicker.Value, 0, 0.985)
    
                local AlphaPositionX = math.clamp(Colorpicker.Alpha, 0, 0.99)
                    
                local HuePositionY = math.clamp(Colorpicker.Hue, 0, 0.98)
    
                Items["PaletteDragger"]:Tween({Position = UDim2.new(PaletteValueX, 0, PaletteValueY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                Items["HueDragger"]:Tween({Position = UDim2.new(0, 0, HuePositionY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                Items["AlphaDragger"]:Tween({Position = UDim2.new(AlphaPositionX, 0, 0, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                Colorpicker:Update()
            end

            Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
                Colorpicker:SetOpen(not Colorpicker.IsOpen)
            end)
    
            Items["Palette"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingPalette = true 
    
                    Colorpicker:SlidePalette(Input)
    
                    if PaletteChanged then
                        return
                    end
    
                    PaletteChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingPalette = false
    
                            PaletteChanged:Disconnect()
                            PaletteChanged = nil
                        end
                    end)
                end
            end)
    
            Items["Hue"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingHue = true 
    
                    Colorpicker:SlideHue(Input)
    
                    if HueChanged then
                        return
                    end
    
                    HueChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingHue = false
    
                            HueChanged:Disconnect()
                            HueChanged = nil
                        end
                    end)
                end
            end)
    
            Items["Alpha"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingAlpha = true 
    
                    Colorpicker:SlideAlpha(Input)
    
                    if AlphaChanged then
                        return
                    end
    
                    AlphaChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingAlpha = false
    
                            AlphaChanged:Disconnect()
                            AlphaChanged = nil
                        end
                    end)
                end
            end)

            Items["Input"]:Connect("FocusLost", function()
                local RGBText = Items["Input"].Instance.Text
                local R, G, B = RGBText:match("(%d+),%s*(%d+),%s*(%d+)")
                R, G, B = tonumber(R), tonumber(G), tonumber(B)

                Colorpicker:Set({R, G, B}, Colorpicker.Alpha)
            end)
    
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if SlidingPalette then 
                        Colorpicker:SlidePalette(Input)
                    end
    
                    if SlidingHue then
                        Colorpicker:SlideHue(Input)
                    end
    
                    if SlidingAlpha then
                        Colorpicker:SlideAlpha(Input)
                    end
                end
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Colorpicker.IsOpen then
                        if Items["ColorpickerWindow"]:IsMouseOverFrame() then 
                            return 
                        end

                        Colorpicker:SetOpen(false)
                    end
                end
            end)

            if Data.Default then
                Colorpicker:Set(Data.Default, Data.Alpha)
            end
    
            SetFlags[Colorpicker.Flag] = function(Value, Alpha)
                Colorpicker:Set(Value, Alpha)
            end

            return Colorpicker, Items 
        end

        Library.CreateKeybind = function(Self, Data)
            local Keybind = {
                Flag = Data.Flag,
                IsOpen = false,

                Key = "",
                Mode = "",
                Value = "",

                Toggled = false,
                Picking = false,

                Items = { },
            }

            local Items = { } do
                Items["KeyButton"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Data.Parent.Instance,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.5,
                    Text = "Space",
                    AutoButtonColor = false,
                    Size = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Icon"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["KeyButton"].Instance,
                    ImageTransparency = 0.5,
                    Image = "rbxassetid://123270284055054",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 50, 0, 2),
                    Size = UDim2.new(0, 18, 0, 18),
                    BorderSizePixel = 0
                }):AddToTheme({ImageColor3 = 'Text'})

                Items["KeybindWindow"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Library.UnusedHolder.Instance,
                    Visible = false,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2.new(0, 40, 0, 563),
                    Size = UDim2.new(0, 222, 0, 75),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Background"]
                }):AddToTheme({BackgroundColor3 = 'Background'})

                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["KeybindWindow"].Instance
                })                
                
                Keybind.Items = Items
            end

            Keybind.Holder = Items["KeybindWindow"]

            local Debounce = false
            local KeybindWindow = Items["KeybindWindow"].Instance
            local KeyButton = Items["KeyButton"].Instance

            local IsSettings = Data.Section and Data.Section.IsSettings

            function Keybind:SetOpen(Bool)
                if Debounce then 
                    return 
                end

                Keybind.IsOpen = Bool

                Debounce = true 
                
                if Keybind.IsOpen then 
                    KeybindWindow.Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y + GuiInset)

                    KeybindWindow.Parent = Library.Holder.Instance
                    KeybindWindow.Visible = true
                    Items["KeybindWindow"]:Tween({Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y + 10 + GuiInset)})
                    
                    Items["KeybindWindow"]:FadeDescendants(true, function()
                        Debounce = false 
                    end)

                    for Index, Value in Library.OpenFrames do 
                        if Value ~= IsSettings then
                            Value:SetOpen(false)
                        end
                    end

                    Library.OpenFrames[Keybind] = Keybind 
                else
                    Items["KeybindWindow"]:Tween({Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y - 10 + GuiInset)})
                    Items["KeybindWindow"]:FadeDescendants(false, function()
                        Items["KeybindWindow"].Instance.Parent = Library.UnusedHolder.Instance
                        Debounce = false
                    end)

                    if Library.OpenFrames[Keybind] then 
                        Library.OpenFrames[Keybind] = nil
                    end
                end

                local Descendants = KeybindWindow:GetDescendants()
                table.insert(Descendants, KeybindWindow)

                for Index, Value in Descendants do 
                    if Value.ClassName:find("UI") then
                        continue
                    end

                    if IsSettings then 
                        Value.ZIndex = Keybind.IsOpen and Library.ZIndexOrder.KeybindWindow or 1
                    else
                        Value.ZIndex = Keybind.IsOpen and Library.ZIndexOrder.KeybindWindow + 1 or 1
                    end
                end
            end
    
            function Keybind:SetMode(Mode)
                Flags[Keybind.Flag] = {
                    Mode = Keybind.Mode,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }
    
                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end
            end

            local ModeDropdown = Library:Dropdown({
                Name = "Mode",
                Flag = Keybind.Flag .. "ModeDropdown",
                Parent = Items["KeybindWindow"],
                Items = { "Toggle", "Hold", "Always" },
                Default = "Toggle",
                Callback = function(Value)
                    Keybind.Mode = Value

                    Keybind:SetMode(Value)
                end
            })
    
            ModeDropdown.Items.Dropdown.Instance.Position = UDim2.new(0, 10, 0, 10)
            ModeDropdown.Items.Dropdown.Instance.Size = UDim2.new(1, -20, 0, 55)

            function Keybind:Press(Bool)
                if Keybind.Mode == "Toggle" then 
                    Keybind.Toggled = not Keybind.Toggled
                elseif Keybind.Mode == "Hold" then 
                    Keybind.Toggled = Bool
                elseif Keybind.Mode == "Always" then 
                    Keybind.Toggled = true
                end
    
                Flags[Keybind.Flag] = {
                    Mode = Keybind.Mode,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }
    
                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end
            end
    
            function Keybind:Set(Key)
                if string.find(tostring(Key), "Enum") then 
                    Keybind.Key = tostring(Key)
    
                    Key = Key.Name == "Backspace" and "None" or Key.Name
    
                    local KeyString = Keys[Keybind.Key] or string.gsub(Key, "Enum.", "") or "None"
                    local TextToDisplay = string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"
    
                    Keybind.Value = TextToDisplay
                    Items["KeyButton"].Instance.Text = TextToDisplay
    
                    Flags[Keybind.Flag] = {
                        Mode = Keybind.Mode,
                        Key = Keybind.Key,
                        Toggled = Keybind.Toggled
                    }
    
                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Items["Icon"].Instance.Position = UDim2.new(0, Items["KeyButton"].Instance.TextBounds.X + 8, 0, 2)
                elseif type(Key) == "table" then
                    local RealKey = Key.Key == "Backspace" and "None" or Key.Key
                    Keybind.Key = tostring(Key.Key)
    
                    if Key.Mode then
                        Keybind.Mode = Key.Mode
                        Keybind:SetMode(Key.Mode)
                    else
                        Keybind.Mode = "Toggle"
                        Keybind:SetMode("Toggle")
                    end
    
                    local KeyString = Keys[Keybind.Key] or string.gsub(tostring(RealKey), "Enum.", "") or RealKey
                    local TextToDisplay = KeyString and string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"
    
                    TextToDisplay = string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "")
    
                    Keybind.Value = TextToDisplay
                    Items["KeyButton"].Instance.Text = TextToDisplay
    
                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Items["Icon"].Instance.Position = UDim2.new(0, Items["KeyButton"].Instance.TextBounds.X + 8, 0, 2)
                elseif table.find({"Toggle", "Hold", "Always"}, Key) then
                    Keybind.Mode = Key
                    Keybind:SetMode(Key)
    
                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end
                end

                Keybind.Picking = false
            end
    
            Items["KeyButton"]:Connect("MouseButton1Click", function()
                Keybind.Picking = true 
    
                Items["KeyButton"].Instance.Text = ". . ."
                Items["Icon"].Instance.Position = UDim2.new(0, Items["KeyButton"].Instance.TextBounds.X + 8, 0, 2)
    
                local InputBegan
                InputBegan = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Keyboard then 
                        Keybind:Set(Input.KeyCode)
                    else
                        Keybind:Set(Input.UserInputType)
                    end
    
                    InputBegan:Disconnect()
                    InputBegan = nil
                end)
            end)
    
            Library:Connect(UserInputService.InputBegan, function(Input, GPE)
                if Keybind.Value == "None" then
                    return
                end
    
                if not GPE then
                    if tostring(Input.KeyCode) == Keybind.Key then
                        if Keybind.Mode == "Toggle" then 
                            Keybind:Press()
                        elseif Keybind.Mode == "Hold" then 
                            Keybind:Press(true)
                        elseif Keybind.Mode == "Always" then 
                            Keybind:Press(true)
                        end
                    elseif tostring(Input.UserInputType) == Keybind.Key then
                        if Keybind.Mode == "Toggle" then 
                            Keybind:Press()
                        elseif Keybind.Mode == "Hold" then 
                            Keybind:Press(true)
                        elseif Keybind.Mode == "Always" then 
                            Keybind:Press(true)
                        end
                    end
                end
            end)
    
            Library:Connect(UserInputService.InputEnded, function(Input, GPE)
                if GPE then
                    return
                end

                if Keybind.Value == "None" then
                    return
                end
    
                if tostring(Input.KeyCode) == Keybind.Key then
                    if Keybind.Mode == "Hold" then 
                        Keybind:Press(false)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                elseif tostring(Input.UserInputType) == Keybind.Key then
                    if Keybind.Mode == "Hold" then 
                        Keybind:Press(false)
                    elseif Keybind.Mode == "Always" then 
                        Keybind:Press(true)
                    end
                end
            end)
    
            Items["KeyButton"]:Connect("MouseButton2Down", function()
                Keybind:SetOpen(not Keybind.IsOpen)
            end)
    
            if Data.Default then 
                Keybind:Set({
                    Mode = Data.Mode or "Toggle",
                    Key = Data.Default,
                })
            end
    
            SetFlags[Keybind.Flag] = function(Value)
                Keybind:Set(Value)
            end

            return Keybind, Items 
        end

        Library.Notification = function(Self, Name, Description, Duration)
            local Items = { } do 
                Items["Notification"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Library.NotifHolder.Instance,
                    Position = UDim2.new(-0.14000000059604645, 0, 0.7889317870140076, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundColor3 = Library.Theme["Background"]
                }):AddToTheme({BackgroundColor3 = 'Background'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Notification"].Instance
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Notification"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Name,
                    AnchorPoint = Vector2.new(1, 0),
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Library:Create("UIPadding", {
                    Name = "\0",
                    Parent = Items["Notification"].Instance,
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10)
                })
                
                Items["Description"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Notification"].Instance,
                    TextColor3 = Library.Theme["Inactive Text"],
                    Text = Description,
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 24),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Inactive Text'})                
            end

            for Index, Value in Items do 
                if Value.Instance:IsA("Frame") then
                    Value.Instance.BackgroundTransparency = 1
                elseif Value.Instance:IsA("TextLabel") then 
                    Value.Instance.TextTransparency = 1
                end
            end 

            local GetSize = function()
                local AbsSize = Items["Notification"].Instance.AbsoluteSize
                Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.None
                task.wait()
                Items["Notification"].Instance.Size = UDim2.new(0, AbsSize.X, 0, AbsSize.Y)
                return AbsSize
            end

            local Size = GetSize()
            task.wait()
            Items["Notification"].Instance.Size = UDim2.new(0, 0, 0, Size.Y)

            local Info = TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)

            Library:Thread(function()
                for Index, Value in Items do 
                    if Value.Instance:IsA("Frame") then
                        Value:Tween({BackgroundTransparency = 0}, Info)
                    elseif Value.Instance:IsA("TextLabel") then 
                        Value:Tween({TextTransparency = 0}, Info)
                    end
                end

                Items["Notification"]:Tween({Size = UDim2.new(0, Size.X, 0, Size.Y)}, Info)

                task.delay(Duration + 0.1, function()
                    for Index, Value in Items do 
                        if Value.Instance:IsA("Frame") then
                            Value:Tween({BackgroundTransparency = 1})
                        elseif Value.Instance:IsA("TextLabel") then 
                            Value:Tween({TextTransparency = 1})
                        end
                    end

                    Items["Notification"]:Tween({Size = UDim2.new(0, 0, 0, 0)}, Info)
                    task.wait(0.5)
                    Items["Notification"].Instance:Destroy()
                end)
            end)
        end

        Library.Watermark = function(Self, Params)
            if IsMobile then return end
            Params = Params or { }
            
            local Watermark = {
                Name = Params.Name or Params.name or "Watermark",
                Logo = Self.Logo,

                Items = { }
            }

            local Items = { } do 
                Items["Watermark"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Library.Holder.Instance,
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 15),
                    Size = UDim2.new(0, 0, 0, 40),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Items["Watermark"]:MakeDraggable()
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Watermark"].Instance
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Watermark"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 229, 229))
                }
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["Watermark"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Value"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Watermark"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Watermark.Name,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 35, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Library:Create("UIPadding", {
                    Name = "\0",
                    Parent = Items["Watermark"].Instance,
                    PaddingRight = UDim.new(0, 12),
                    PaddingLeft = UDim.new(0, 12)
                })
                
                Items["Logo"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["Watermark"].Instance,
                    ImageColor3 = Library.Theme["Accent"],
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = Watermark.Logo,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(0, 24, 0, 24),
                    BorderSizePixel = 0
                }):AddToTheme({ImageColor3 = 'Accent'})                

                Watermark.Items = Items 
            end

            function Watermark:SetVisibility(Bool)
                Items["Watermark"].Instance.Visible = Bool
            end

            function Watermark:SetText(Text)
                Items["Text"].Instance.Text = Text
            end

            function Watermark:Center()
                local AbsPos = Items["Watermark"].Instance.AbsolutePosition
                task.wait()
                Items["Watermark"].Instance.AnchorPoint = Vector2.new(0, 0)
                Items["Watermark"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
            end

            Watermark:Center()
            Self.Watermark = Watermark

            return setmetatable(Watermark, Library)
        end
        
        Library.Window = function(Self, Params)
            Params = Params or { }

            local Window = {
                Name = Params.Name or Params.name or "Window",
                Logo = Params.Logo or Params.logo or "rbxassetid://73982265927441",

                IsOpen = true,
                Current = nil,
                Pages = { },
                Items = { }
            }

            local Items = { } do 
                Items["MainFrame"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Library.Holder.Instance,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 0.10000000149011612,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = IsMobile and UDim2.new(0, 1100, 0, 601) or UDim2.new(0, 878, 0, 601),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Background"]
                }):AddToTheme({BackgroundColor3 = 'Background'})

                if IsMobile then 
                    Library:Create("UIScale", {
                        Parent = Items["MainFrame"].Instance,
                        Scale = 0.55 -- Scale down to fit mobile screens
                    })
                end
                
                Items["MainFrame"]:MakeDraggable()
                Items["MainFrame"]:MakeResizeable(Vector2.new(Items["MainFrame"].Instance.AbsoluteSize.X, Items["MainFrame"].Instance.AbsoluteSize.Y))
                
                Items["MainFrame"]:MakeBlurred(Window)

                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["MainFrame"].Instance,
                    CornerRadius = UDim.new(0, 14)
                })
                
                Items["Side"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["MainFrame"].Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 200, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Text"]
                })
                
                Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Side"].Instance,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 1, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Outline"]
                }):AddToTheme({BackgroundColor3 = 'Outline'})
                
                Items["Top"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Side"].Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 60),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Text"]
                })
                
                Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Top"].Instance,
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Outline"]
                }):AddToTheme({BackgroundColor3 = 'Outline'})
                
                Items["Logo"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["Top"].Instance,
                    ImageColor3 = Library.Theme["Accent"],
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = Window.Logo,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0.5, 0),
                    Size = UDim2.new(0, 30, 0, 30),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Text"]
                }):AddToTheme({ImageColor3 = 'Accent'})
                
                Items["Title"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = 18,
                    Parent = Items["Top"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Window.Name,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 10, 0.5, -2),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Library.Theme["Text"]
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Pages"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Side"].Instance,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 60),
                    Size = UDim2.new(1, 0, 1, -60),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Text"]
                })
                
                Library:Create("UIPadding", {
                    Name = "\0",
                    Parent = Items["Pages"].Instance,
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10)
                })
                
                Library:Create("UIListLayout", {
                    Name = "\0",
                    Parent = Items["Pages"].Instance,
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Items["Topbar"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["MainFrame"].Instance,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 200, 0, 0),
                    Size = UDim2.new(1, -200, 0, 60),
                    BorderSizePixel = 0
                })
                
                Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Topbar"].Instance,
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Outline"]
                }):AddToTheme({BackgroundColor3 = 'Outline'})
                
                Items["Searchbar"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Topbar"].Instance,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(0, 40, 1, -20),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Inline"]
                }):AddToTheme({BackgroundColor3 = 'Inline'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Searchbar"].Instance
                })
                
                Items["Icon"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["Searchbar"].Instance,
                    ImageColor3 = Color3.fromRGB(155, 155, 155),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = "rbxassetid://130663768058348",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 22, 0, 22),
                    BorderSizePixel = 0
                })
                
                Items["SearchInput"] = Library:Create("TextBox", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Searchbar"].Instance,
                    Visible = false,
                    AnchorPoint = Vector2.new(0, 0.5),
                    PlaceholderColor3 = Color3.fromRGB(155, 155, 155),
                    PlaceholderText = "Search in this tab..",
                    Size = UDim2.new(0, 0, 0, 15),
                    TextColor3 = Library.Theme["Text"],
                    Text = "",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 45, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})   
                
                Items["Content"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["MainFrame"].Instance,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 200, 0, 60),
                    Size = UDim2.new(1, -200, 1, -60),
                    BorderSizePixel = 0
                })

                Window.Items = Items
            end

            local Debounce = false

            function Window:SetOpen(Bool)
                if Debounce then 
                    return 
                end

                Debounce = true 

                Window.IsOpen = Bool
                Items["MainFrame"]:FadeDescendants(Bool, function()
                    Debounce = false
                end)

                for Index, Value in Library.OpenFrames do 
                    Value:SetOpen(false)
                end
            end

            function Window:Center()
                local AbsPos = Items["MainFrame"].Instance.AbsolutePosition
                Items["MainFrame"].Instance.AnchorPoint = Vector2.new(0, 0)
                task.wait()
                Items["MainFrame"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
            end

            Library:Connect(UserInputService.InputBegan, function(Input)
                if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
                    if UserInputService:GetFocusedTextBox() then
                        return
                    end

                    Window:SetOpen(not Window.IsOpen)
                end
            end)

            if IsMobile then
                local MobileToggle = Library:Create("TextButton", {
                    Name = "\0",
                    Parent = Library.Holder.Instance,
                    Size = UDim2.new(0, 45, 0, 45),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "F",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 24,
                    FontFace = Library.Font,
                    BorderSizePixel = 0,
                    AutoButtonColor = true,
                    ZIndex = 100
                })

                Library:Create("UICorner", {
                    Parent = MobileToggle.Instance,
                    CornerRadius = UDim.new(1, 0)
                })

                Library:Create("UIStroke", {
                    Parent = MobileToggle.Instance,
                    Color = Library.Theme["Accent"],
                    Thickness = 2
                }):AddToTheme({Color = 'Accent'})

                MobileToggle:Connect("MouseButton1Click", function()
                    Window:SetOpen(not Window.IsOpen)
                end)

                MobileToggle:Connect("TouchTap", function()
                    Window:SetOpen(not Window.IsOpen)
                end)

                MobileToggle:MakeDraggable()
            end

            Window:Center()
            return setmetatable(Window, Library)
        end

        Library.Page = function(Self, Params)
            Params = Params or { }

            local Page = {
                Name = Params.Name or Params.name or "Page",
                Icon = Params.Icon or Params.icon or "rbxassetid://97387794662218",

                Window = Self,
                Debounce = false,
                ColumnsData = { },
                Items = { },
                Active = false
            }

            local Items = { } do 
                Items["Inactive"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Page.Window.Items["Pages"].Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Inline"]
                }):AddToTheme({BackgroundColor3 = 'Inline'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Inactive"].Instance
                })
                
                Items["Icon"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["Inactive"].Instance,
                    ImageTransparency = 0.5,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = Page.Icon,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Inactive"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.5,
                    Text = Page.Name,
                    Size = UDim2.new(0, 0, 0, 15),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 38, 0.5, -1),
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})         
                
                Items["Page"] = Library:Create("Frame", {
                    Name = "\0",
                    Visible = false,
                    Parent = Library.UnusedHolder.Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0
                })
                
                Library:Create("UIListLayout", {
                    Name = "\0",
                    Parent = Items["Page"].Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Items["LeftColumn"] = Library:Create("ScrollingFrame", {
                    Name = "\0",
                    Parent = Items["Page"].Instance,
                    ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.new(0, 0, 0, 0)
                })
                
                Library:Create("UIPadding", {
                    Name = "\0",
                    Parent = Items["LeftColumn"].Instance,
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 1),
                    PaddingLeft = UDim.new(0, 10)
                })
                
                Library:Create("UIListLayout", {
                    Name = "\0",
                    Parent = Items["LeftColumn"].Instance,
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })                

                Items["RightColumn"] = Library:Create("ScrollingFrame", {
                    Name = "\0",
                    Parent = Items["Page"].Instance,
                    ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.new(0, 0, 0, 0)
                })
                
                Library:Create("UIPadding", {
                    Name = "\0",
                    Parent = Items["RightColumn"].Instance,
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 1)
                })
                
                Library:Create("UIListLayout", {
                    Name = "\0",
                    Parent = Items["RightColumn"].Instance,
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Page.ColumnsData[1] = Items["LeftColumn"]
                Page.ColumnsData[2] = Items["RightColumn"]

                Page.Items = Items
            end

            function Page:Turn(Bool)
                local Old = Page.Window.Current 

                if Old == Page then 
                    return 
                end

                if Page.Debounce then 
                    return
                end

                if Old and Old.Debounce then 
                    return
                end

                Page.Debounce = true 
                
                if Old then 
                    Old.Items["Inactive"]:Tween({BackgroundTransparency = 1})

                    Old.Items["Text"]:Tween({TextTransparency = 0.5})
                    Old.Items["Icon"]:Tween({ImageTransparency = 0.5})

                    Old.Items["Page"]:FadeDescendants(false, function()
                        Old.Items["Page"].Instance.Parent = Library.UnusedHolder.Instance
                    end)
                end

                Items["Page"].Instance.Parent = Page.Window.Items["Content"].Instance
                Items["Page"].Instance.Visible = true
                Items["Page"]:FadeDescendants(true, function()
                    Page.Debounce = false
                end)

                Items["Inactive"]:Tween({BackgroundTransparency = 0})

                Items["Text"]:Tween({TextTransparency = 0})
                Items["Icon"]:Tween({ImageTransparency = 0})

                Page.Window.Current = Page
            end

            Items["Inactive"]:Connect("MouseButton1Down", function()
                Page:Turn()
            end)

            if #Page.Window.Pages == 0 then 
                Page:Turn()
            end

            table.insert(Page.Window.Pages, Page)
            return setmetatable(Page, Library)
        end

        Library.Section = function(Self, Params)
            Params = Params or { } 

            local Section = {
                Name = Params.Name or Params.name or "Section",
                Side = Params.Side or Params.side or 1,

                Window = Self.Window,
                Page = Self,
                Items = { },
            }

            local Items = { } do 
                Items["Section"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Section.Page.ColumnsData[Section.Side].Instance,
                    BackgroundTransparency = 0.30000001192092896,
                    Size = UDim2.new(1, 0, 0, 50),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Library.Theme["Inline"]
                }):AddToTheme({BackgroundColor3 = 'Inline'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Section"].Instance
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["Section"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Topbar"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Section"].Instance,
                    Size = UDim2.new(1, 0, 0, 35),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Top"]
                }):AddToTheme({BackgroundColor3 = 'Top'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Topbar"].Instance
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Topbar"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Section.Name,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Topbar"].Instance,
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 8),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Top"]
                }):AddToTheme({BackgroundColor3 = 'Top'})
                
                Items["Content"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Section"].Instance,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 35),
                    Size = UDim2.new(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                
                Library:Create("UIListLayout", {
                    Name = "\0",
                    Parent = Items["Content"].Instance,
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Library:Create("UIPadding", {
                    Name = "\0",
                    Parent = Items["Content"].Instance,
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10)
                })

                Section.Items = Items
            end 

            return setmetatable(Section, Library)
        end

        Library.Toggle = function(Self, Params)
            Params = Params or { }

            local Toggle = {
                Name = Params.Name or Params.name or "Toggle",
                Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                Default = Params.Default or Params.default or false,
                Callback = Params.Callback or Params.callback or function() end,

                Window = Self.Window,
                Page = Self.Page,
                Section = Self,

                Value = false,
                Items = { }
            }

            local Parent 

            if Params.Parent then 
                Parent = Params.Parent
            else
                Parent = Toggle.Section.Items["Content"]
            end

            local Items = { } do 
                Items["Toggle"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Parent.Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Toggle"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.5,
                    Text = Toggle.Name,
                    Size = UDim2.new(0, 0, 0, 15),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Indicator"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Toggle"].Instance,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 0.10000000149011612,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 40, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Indicator"].Instance,
                    CornerRadius = UDim.new(1, 0)
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["Indicator"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Indicator"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 163, 163))
                }
                })
                
                Items["Circle"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Indicator"].Instance,
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 0.6000000238418579,
                    Position = UDim2.new(0, 3, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    BorderSizePixel = 0
                }):AddToTheme({BackgroundColor3 = function()
                    return Color3.fromRGB(255, 255, 255)
                end})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Circle"].Instance,
                    CornerRadius = UDim.new(1, 0)
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Circle"].Instance,
                    Rotation = -180,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 163, 163))
                }
                })           
                
                Items["CheckImage"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["Circle"].Instance,
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = "rbxassetid://74901569057026",
                    BackgroundTransparency = 1,
                    ImageTransparency = 1,
                    Rotation = 180,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    BorderSizePixel = 0
                })                

                Items["Toggle"]:OnHover(function()
                    Items["Indicator"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                end, function()
                    Items["Indicator"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                end)
            
                Toggle.Items = Items
            end

            function Toggle:Set(Bool)
                Toggle.Value = Bool 

                if Bool then 
                    Items["Circle"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                    Items["Circle"]:Tween({
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -3, 0.5, 0),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Library.Theme.Accent
                    })

                    Items["CheckImage"]:Tween({ImageTransparency = 0, Rotation = 0})
                    Items["Text"]:Tween({TextTransparency = 0})
                else
                    Items["Circle"]:ChangeItemTheme({BackgroundColor3 = function()
                        return Color3.fromRGB(255, 255, 255)
                    end})
                    Items["Circle"]:Tween({
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 3, 0.5, 0),
                        BackgroundTransparency = 0.6,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    })

                    Items["CheckImage"]:Tween({ImageTransparency = 1, Rotation = 180})
                    Items["Text"]:Tween({TextTransparency = 0.5})
                end

                Flags[Toggle.Flag] = Bool
                Library:SafeCall(Toggle.Callback, Bool)
            end

            function Toggle:SetVisibility(Bool)
                Items["Toggle"].Instance.Visible = Bool 
            end

            function Toggle:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            Items["Toggle"]:Connect("MouseButton1Down", function()
                Toggle:Set(not Toggle.Value)
            end)

            Toggle:Set(Toggle.Default)

            SetFlags[Toggle.Flag] = function(Value)
                Toggle:Set(Value)
            end

            return setmetatable(Toggle, Library)
        end

        Library.Button = function(Self, Params)
            Params = Params or { }

            local Button = {
                Name = Params.Name or Params.name or "Button",
                Callback = Params.Callback or Params.callback or function() end,

                Window = Self.Window,
                Page = Self.Page,
                Section = Self,
                Items = { }
            }

            local Parent 

            if Params.Parent then 
                Parent = Params.Parent
            else
                Parent = Button.Section.Items["Content"]
            end

            local Items = { } do 
                Items["RealButton"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Parent.Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 0.10000000149011612,
                    Size = UDim2.new(1, 0, 0, 30),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["RealButton"].Instance
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["RealButton"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["RealButton"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 229, 229))
                }
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["RealButton"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Button.Name,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, -1),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})       
                
                Items["RealButton"]:OnHover(function()
                    Items["RealButton"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                end, function()
                    Items["RealButton"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                end)

                Button.Items = Items
            end

            function Button:Press()
                Items["RealButton"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                Items["RealButton"]:Tween({BackgroundColor3 = Library.Theme.Accent})
                task.wait(0.1)
                Items["RealButton"]:ChangeItemTheme({BackgroundColor3 = "Element"})
                Items["RealButton"]:Tween({BackgroundColor3 = Library.Theme.Element})
                
                Library:SafeCall(Button.Callback)
            end

            function Button:SetVisibility(Bool)
                Items["Button"].Instance.Visible = Bool
            end

            function Button:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            Items["RealButton"]:Connect("MouseButton1Down", function()
                Button:Press()
            end)

            return setmetatable(Button, Library)
        end

        Library.Slider = function(Self, Params)
            Params = Params or { }

            local Slider = {
                Name = Params.Name or Params.name or "Slider",
                Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                Default = Params.Default or Params.default or 0,
                Min = Params.Min or Params.min or 0,
                Max = Params.Max or Params.max or 100,
                Callback = Params.Callback or Params.callback or function() end,
                Decimals = Params.Decimals or Params.decimals or 0,
                Suffix = Params.Suffix or Params.suffix or "",

                Window = Self.Window,
                Page = Self.Page,
                Section = Self,

                Value = 0,
                Sliding = false,
                Items = { }
            }

            local Parent 

            if Params.Parent then 
                Parent = Params.Parent
            else
                Parent = Slider.Section.Items["Content"]
            end

            local Items = { } do 
                Items["Slider"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Parent.Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 39),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Slider"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Slider.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["RealSlider"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Slider"].Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 0.10000000149011612,
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 10),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["RealSlider"].Instance,
                    CornerRadius = UDim.new(0, 6)
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["RealSlider"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 229, 229))
                }
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["RealSlider"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Accent"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["RealSlider"].Instance,
                    Size = UDim2.new(0.5, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Accent"]
                }):AddToTheme({BackgroundColor3 = 'Accent'})
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Accent"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 229, 229))
                }
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Accent"].Instance,
                    CornerRadius = UDim.new(0, 6)
                })
                
                Items["Dragger"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Accent"].Instance,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 5, 0.5, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0
                })
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Dragger"].Instance,
                    CornerRadius = UDim.new(1, 0)
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["Dragger"].Instance
                }):AddToTheme({Color = 'Outline'})
                
                Items["Value"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Slider"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = "50%",
                    AnchorPoint = Vector2.new(1, 0),
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["Value"].Instance,
                    Transparency = 0.6800000071525574
                })               
                
                Items["RealSlider"]:OnHover(function()
                    Items["RealSlider"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                end, function()
                    Items["RealSlider"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                end)

                Slider.Items = Items 
            end

            function Slider:Set(Value)
                Value = tonumber(Value) or Slider.Default or Slider.Min or 0
                if Value ~= Value then Value = Slider.Default or 0 end
                
                Slider.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Decimals)
                if Slider.Value ~= Slider.Value then Slider.Value = Slider.Default or 0 end

                local Range = Slider.Max - Slider.Min
                local Progress = (Range == 0) and 0 or (Slider.Value - Slider.Min) / Range
                if Progress ~= Progress then Progress = 0 end
                
                Items["Accent"]:Tween({Size = UDim2.new(Progress, 0, 1, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                Items["Value"].Instance.Text = string.format("%s%s", Slider.Value, Slider.Suffix)

                if Slider.Value == Slider.Min then
                    Items["Dragger"]:Tween({Position = UDim2.new(1, 10, 0.5, 0)})
                else
                    Items["Dragger"]:Tween({Position = UDim2.new(1, 5, 0.5, 0)})
                end

                Flags[Slider.Flag] = Slider.Value
                Library:SafeCall(Slider.Callback, Slider.Value)
            end

            function Slider:SetVisibility(Bool)
                Items["Slider"].Instance.Visible = Bool
            end

            function Slider:GetSize(Input)
                local AbsSize = Items["RealSlider"].Instance.AbsoluteSize.X
                local SizeX = (AbsSize == 0) and 0 or (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / AbsSize
                local Value = ((Slider.Max - Slider.Min) * math.clamp(SizeX, 0, 1)) + Slider.Min

                return Value
            end

            function Slider:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            local InputChanged 
            
            Items["RealSlider"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Sliding = true

                    local Value = Slider:GetSize(Input)

                    Slider:Set(Value)

                    if InputChanged then
                        return
                    end

                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Slider.Sliding = false

                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Slider.Sliding then
                        local Value = Slider:GetSize(Input)

                        Slider:Set(Value)
                    end
                end
            end)

            Slider:Set(Slider.Default)

            SetFlags[Slider.Flag] = function(Value)
                Slider:Set(Value)
            end

            return setmetatable(Slider, Library)
        end

        Library.Dropdown = function(Self, Params)
            Params = Params or { }

            local Dropdown = {
                Name = Params.Name or Params.name or "Dropdown",
                OptionItems = Params.Items or Params.items or { },
                Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                Default = Params.Default or Params.default or "",
                MaxSize = Params.MaxSize or Params.maxsize or 120,
                Callback = Params.Callback or Params.callback or function() end,
                Multi = Params.Multi or Params.multi or false,

                Window = Self.Window,
                Page = Self.Page,
                Section = Self,

                Value = { },
                Options = { },
                IsOpen = false,
                Items = { }
            }

            local Parent 

            if Params.Parent then 
                Parent = Params.Parent
            else
                Parent = Dropdown.Section.Items["Content"]
            end

            local Items = { } do 
                Items["Dropdown"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Parent.Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 55),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Dropdown"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Dropdown.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["RealDropdown"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Dropdown"].Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 0.10000000149011612,
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 30),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["RealDropdown"].Instance
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["RealDropdown"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 229, 229))
                }
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["RealDropdown"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Value"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["RealDropdown"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = "...",
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Icon"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["RealDropdown"].Instance,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Image = "rbxassetid://125099720033465",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    BorderSizePixel = 0
                })                

                Items["RealDropdown"]:OnHover(function()
                    Items["RealDropdown"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                end, function()
                    Items["RealDropdown"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                end)

                Items["OptionHolder"] = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Library.UnusedHolder.Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2.new(0, 50, 0, 154),
                    Size = UDim2.new(0, 200, 0, 150),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Background"]
                }):AddToTheme({BackgroundColor3 = 'Background'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["OptionHolder"].Instance
                })
                
                Items["Searchbar"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["OptionHolder"].Instance,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 0, 30),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Inline"]
                }):AddToTheme({BackgroundColor3 = 'Inline'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Searchbar"].Instance,
                    CornerRadius = UDim.new(0, 6)
                })
                
                Items["SearchIcon"] = Library:Create("ImageLabel", {
                    Name = "\0",
                    Parent = Items["Searchbar"].Instance,
                    ImageColor3 = Color3.fromRGB(155, 155, 155),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = "rbxassetid://130663768058348",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0.5, 0),
                    Size = UDim2.new(0, 22, 0, 22),
                    BorderSizePixel = 0
                }):AddToTheme({ImageColor3 = 'Inactive Text'})
                
                Items["SearchInput"] = Library:Create("TextBox", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Searchbar"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = "",
                    Size = UDim2.new(0, 0, 0, 15),
                    Position = UDim2.new(0, 40, 0.5, -1),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    PlaceholderColor3 = Color3.fromRGB(155, 155, 155),
                    AutomaticSize = Enum.AutomaticSize.X,
                    PlaceholderText = "Search.."
                }):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})
                
                Items["Holder"] = Library:Create("ScrollingFrame", {
                    Name = "\0",
                    Parent = Items["OptionHolder"].Instance,
                    ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 0,
                    Size = UDim2.new(1, -20, 1, -55),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 45),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.new(0, 0, 0, 0)
                })
                
                Library:Create("UIListLayout", {
                    Name = "\0",
                    Parent = Items["Holder"].Instance,
                    Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Dropdown.Items = Items 
            end

            Dropdown.Holder = Items["OptionHolder"]

            function Dropdown:Set(Value)
                if Dropdown.Multi then 
                    if type(Value) ~= "table" then 
                        return
                    end

                    Dropdown.Value = Value

                    for Index, Value in Value do
                        local OptionData = Dropdown.Options[Value]
                         
                        if not OptionData then
                            continue
                        end

                        OptionData.IsSelected = true 
                        OptionData:ToggleState("Active")
                    end

                    Flags[Dropdown.Flag] = Value
                    Items["Value"].Instance.Text = table.concat(Value, ", ")
                else
                    if not Dropdown.Options[Value] then
                        return
                    end

                    local OptionData = Dropdown.Options[Value]

                    Dropdown.Value = Value

                    for Index, Value in Dropdown.Options do
                        if Value ~= OptionData then
                            Value.IsSelected = false 
                            Value:ToggleState("Inactive")
                        else
                            Value.IsSelected = true 
                            Value:ToggleState("Active")
                        end
                    end

                    Flags[Dropdown.Flag] = Value
                    Items["Value"].Instance.Text = Value
                end

                Library:SafeCall(Dropdown.Callback, Dropdown.Value)
            end

            function Dropdown:Add(Value)
                local OptionButton = Library:Create("TextButton", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Holder"].Instance,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Inline"]
                }):AddToTheme({BackgroundColor3 = 'Inline'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = OptionButton.Instance,
                    CornerRadius = UDim.new(0, 4)
                })
                
                local OptionText = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = OptionButton.Instance,
                    TextColor3 = Library.Theme["Text"],
                    TextTransparency = 0.5,
                    Text = Value,
                    Size = UDim2.new(0, 0, 0, 15),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})                

                local OptionData = {
                    Button = OptionButton,
                    Name = Value,
                    Text = OptionText,
                    IsSelected = false
                }

                OptionButton:OnHover(function()
                    if OptionData.IsSelected then 
                        return 
                    end

                    OptionData.Text:Tween({TextTransparency = 0})
                end, function()
                    if OptionData.IsSelected then 
                        return 
                    end

                    OptionData.Text:Tween({TextTransparency = 0.5})
                end)
                
                function OptionData:ToggleState(Value)
                    if Value == "Active" then
                        OptionData.Button:Tween({BackgroundTransparency = 0})
                        OptionData.Text:Tween({TextTransparency = 0})
                    else
                        OptionData.Button:Tween({BackgroundTransparency = 1})
                        OptionData.Text:Tween({TextTransparency = 0.5})
                    end
                end

                function OptionData:Set()
                    OptionData.IsSelected = not OptionData.IsSelected

                    if Dropdown.Multi then 
                        local Index = table.find(Dropdown.Value, OptionData.Name)

                        if Index then 
                            table.remove(Dropdown.Value, Index)
                        else
                            table.insert(Dropdown.Value, OptionData.Name)
                        end

                        OptionData:ToggleState(Index and "Inactive" or "Active")

                        Flags[Dropdown.Flag] = Dropdown.Value

                        local TextFormat = #Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or "..."
                        Items["Value"].Instance.Text = TextFormat
                    else
                        if OptionData.IsSelected then 
                            Dropdown.Value = OptionData.Name
                            Flags[Dropdown.Flag] = OptionData.Name

                            OptionData.IsSelected = true
                            OptionData:ToggleState("Active")

                            for Index, Value in Dropdown.Options do 
                                if Value ~= OptionData then
                                    Value.IsSelected = false 
                                    Value:ToggleState("Inactive")
                                end
                            end

                            Items["Value"].Instance.Text = OptionData.Name
                        else
                            Dropdown.Value = nil
                            Flags[Dropdown.Flag] = nil

                            OptionData.IsSelected = false
                            OptionData:ToggleState("Inactive")

                            Items["Value"].Instance.Text = "..."
                        end
                    end

                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end

                OptionData.Button:Connect("MouseButton1Down", function()
                    OptionData:Set()
                end)

                Dropdown.Options[OptionData.Name] = OptionData
                return OptionData
            end

            function Dropdown:Remove(Option)
                if Dropdown.Options[Option] then
                    Dropdown.Options[Option].Button.Instance:Destroy()
                    Dropdown.Options[Option] = nil
                end
            end

            function Dropdown:Refresh(List)
                for Index, Value in Dropdown.Options do 
                    Dropdown:Remove(Value.Name)
                end

                for Index, Value in List do 
                    Dropdown:Add(Value)
                end
            end

            function Dropdown:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            function Dropdown:SetVisibility(Bool)
                Items["Dropdown"].Instance.Visible = Bool 
            end

            local Debounce = false 
            local OptionHolder = Items["OptionHolder"].Instance
            local RealDropdown = Items["RealDropdown"].Instance

            local IsSettings = Dropdown.Section and Dropdown.Section.IsSettings

            function Dropdown:SetOpen(Bool)
                if Debounce then 
                    return 
                end

                Dropdown.IsOpen = Bool

                Debounce = true 
                
                if Dropdown.IsOpen then 
                    Items["Icon"]:Tween({Rotation = -90})
                    OptionHolder.Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y + GuiInset)
                    OptionHolder.Size = UDim2.new(0, RealDropdown.AbsoluteSize.X, 0, Dropdown.MaxSize)
                    
                    OptionHolder.Parent = Library.Holder.Instance
                    OptionHolder.Visible = true
                    Items["OptionHolder"]:Tween({Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y + 10 + GuiInset)})
                    
                    Items["OptionHolder"]:FadeDescendants(true, function()
                        Debounce = false 
                    end)

                    for Index, Value in Library.OpenFrames do 
                        if Value ~= IsSettings and not Params.Parent then
                            Value:SetOpen(false)
                        end
                    end

                    Library.OpenFrames[Dropdown] = Dropdown 
                else
                    Items["Icon"]:Tween({Rotation = 0})
                    Items["OptionHolder"]:Tween({Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y - 10 + GuiInset)})
                    Items["OptionHolder"]:FadeDescendants(false, function()
                        OptionHolder.Parent = Library.UnusedHolder.Instance
                        Debounce = false
                    end)

                    if Library.OpenFrames[Dropdown] then 
                        Library.OpenFrames[Dropdown] = nil
                    end
                end

                local Descendants = OptionHolder:GetDescendants()
                table.insert(Descendants, OptionHolder)

                for Index, Value in Descendants do 
                    if Value.ClassName:find("UI") then
                        continue
                    end

                    if not Params.Parent then
                        Value.ZIndex = Dropdown.IsOpen and Library.ZIndexOrder.OptionHolder or 1
                    else
                        Value.ZIndex = Dropdown.IsOpen and Library.ZIndexOrder.OptionHolder + 3 or 1
                    end
                end
            end

            Items["RealDropdown"]:Connect("MouseButton1Down", function()
                Dropdown:SetOpen(not Dropdown.IsOpen)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dropdown.IsOpen then
                        if Items["OptionHolder"]:IsMouseOverFrame() then 
                            return 
                        end

                        Dropdown:SetOpen(false)
                    end
                end
            end)

            Items["SearchInput"]:Connect("Focused", function()
                Items["SearchIcon"]:ChangeItemTheme({ImageColor3 = "Text"})
                Items["SearchIcon"]:Tween({ImageColor3 = Library.Theme.Text})
            end)

            Items["SearchInput"]:Connect("Changed", function(Property)
                if Property == "Text" then
                    for Index, Value in Dropdown.Options do 
                        if string.find(string.lower(Value.Name), string.lower(Items["SearchInput"].Instance.Text)) then
                            Value.Button.Instance.Visible = true
                        else
                            Value.Button.Instance.Visible = false
                        end
                    end
                end
            end)

            Items["SearchInput"]:Connect("FocusLost", function()
                Items["SearchIcon"]:ChangeItemTheme({ImageColor3 = "Inactive Text"})
                Items["SearchIcon"]:Tween({ImageColor3 = Library.Theme["Inactive Text"]})
            end)

            for Index, Value in Dropdown.OptionItems do 
                Dropdown:Add(Value)
            end

            Dropdown:Set(Dropdown.Default)

            SetFlags[Dropdown.Flag] = function(Value)
                Dropdown:Set(Value)
            end

            return setmetatable(Dropdown, Library)
        end

        Library.Label = function(Self, Params)
            Params = Params or { }

            local Label = {
                Name = Params.Name or Params.name or "Label",

                Window = Self.Window,
                Page = Self.Page,
                Section = Self,

                Items = { }
            }

            local Parent 

            if Params.Parent then 
                Parent = Params.Parent
            else
                Parent = Label.Section.Items["Content"]
            end

            local Items = { } do 
                Items["Label"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Parent.Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Label"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Label.Name,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["SubElements"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Label"].Instance,
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                })
                
                Library:Create("UIListLayout", {
                    Name = "\0",
                    Parent = Items["SubElements"].Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Label.Items = Items 
            end

            function Label:SetVisibility(Bool)
                Items["Label"].Instance.Visible = Bool 
            end

            function Label:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            function Label:Colorpicker(Data)
                Data = Data or { }

                local Colorpicker = {
                    Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Label.Name),
                    Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                    Callback = Data.Callback or Data.callback or function() end,
                    Alpha = Data.Alpha or Data.alpha or 0,

                    Window = Label.Window,
                    Page = Label.Page,
                    Section = Label.Section,
                }

                local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                    Parent = Items["SubElements"],
                    Page = Colorpicker.Page,
                    Section = Colorpicker.Section,
                    Flag = Colorpicker.Flag,
                    Default = Colorpicker.Default,
                    Callback = Colorpicker.Callback,
                    Alpha = Colorpicker.Alpha
                })

                return NewColorpicker
            end

            function Label:Keybind(Data)
                Data = Data or { }

                local Keybind = {
                    Name = Data.Name or Data.name or Label.Name,
                    Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Label.Name),
                    Default = Data.Default or Data.default or Enum.KeyCode.E,
                    Callback = Data.Callback or Data.callback or function() end,
                    Mode = Data.Mode or Data.mode or "Toggle",

                    Window = Label.Window,
                    Page = Label.Page,
                    Section = Label.Section,
                }

                local NewKeybind, KeybindItems = Library:CreateKeybind({
                    Parent = Items["SubElements"],
                    Name = Keybind.Name,
                    Page = Keybind.Page,
                    Section = Keybind.Section,
                    Flag = Keybind.Flag,
                    Default = Keybind.Default,
                    Mode = Keybind.Mode,
                    Callback = Keybind.Callback
                })

                return NewKeybind
            end

            Label:SetText(Label.Name)

            return setmetatable(Label, Library)
        end

        Library.Textbox = function(Self, Params)
            Params = Params or { }

            local Textbox = {
                Name = Params.Name or Params.name or "Textbox",
                Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                Default = Params.Default or Params.default or "",
                Callback = Params.Callback or Params.callback or function() end,
                Finished = Params.Finished or Params.finished or false,
                Placeholder = Params.Placeholder or Params.placeholder or "",
                Numeric = Params.Numeric or Params.numeric or false,

                Window = Self.Window,
                Page = Self.Page,
                Section = Self,
                Value = "",

                Items = { },
            }

            local Parent 

            if Params.Parent then 
                Parent = Params.Parent
            else
                Parent = Textbox.Section.Items["Content"]
            end

            local Items = { } do 
                Items["Textbox"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Parent.Instance,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 55),
                    BorderSizePixel = 0
                })
                
                Items["Text"] = Library:Create("TextLabel", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Textbox"].Instance,
                    TextColor3 = Library.Theme["Text"],
                    Text = Textbox.Name,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X
                }):AddToTheme({TextColor3 = 'Text'})
                
                Items["Background"] = Library:Create("Frame", {
                    Name = "\0",
                    Parent = Items["Textbox"].Instance,
                    ClipsDescendants = true,
                    AnchorPoint = Vector2.new(0, 1),
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 0.10000000149011612,
                    Position = UDim2.new(0, 0, 1, 0),
                    Selectable = true,
                    Active = true,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme["Element"]
                }):AddToTheme({BackgroundColor3 = 'Element'})
                
                Library:Create("UICorner", {
                    Name = "\0",
                    Parent = Items["Background"].Instance
                })
                
                Library:Create("UIGradient", {
                    Name = "\0",
                    Parent = Items["Background"].Instance,
                    Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(229, 229, 229))
                }
                })
                
                Library:Create("UIStroke", {
                    Name = "\0",
                    Parent = Items["Background"].Instance,
                    Color = Library.Theme["Outline"],
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = 'Outline'})
                
                Items["Input"] = Library:Create("TextBox", {
                    Name = "\0",
                    FontFace = Library.Font,
                    TextSize = Library.FontSize,
                    Parent = Items["Background"].Instance,
                    Active = false,
                    Selectable = false,
                    AnchorPoint = Vector2.new(0, 0.5),
                    PlaceholderColor3 = Library.Theme["Inactive Text"],
                    PlaceholderText = Textbox.Placeholder,
                    Size = UDim2.new(1, -20, 0, 15),
                    TextColor3 = Library.Theme["Text"],
                    Text = "",
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    CursorPosition = -1,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    BorderSizePixel = 0
                }):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})     
                
                Items["Background"]:OnHover(function()
                    Items["Background"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                end, function()
                    Items["Background"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                end)
                
                Textbox.Items = Items
            end

            function Textbox:SetVisibility(Bool)
                Items["Textbox"].Instance.Visible = Bool
            end

            function Textbox:SetText(Text)
                Items["Text"].Instance.Text = tostring(Text)
            end

            function Textbox:Set(Value)
                if Textbox.Numeric then
                    if (not tonumber(Value)) and string.len(tostring(Value)) > 0 then
                        Value = Textbox.Value
                    end
                end

                Textbox.Value = Value
                Items["Input"].Instance.Text = Value
                Flags[Textbox.Flag] = Value

                Library:SafeCall(Textbox.Callback, Value)
            end

            if Textbox.Finished then 
                Items["Input"]:Connect("FocusLost", function(PressedEnterQuestionMark)
                    if PressedEnterQuestionMark then
                        Textbox:Set(Items["Input"].Instance.Text)
                    end
                end)
            else
                Library:Connect(Items["Input"].Instance:GetPropertyChangedSignal("Text"), function()
                    Textbox:Set(Items["Input"].Instance.Text)
                end)
            end

            Textbox:Set(Textbox.Default)

            SetFlags[Textbox.Flag] = function(Value)
                Textbox:Set(Value)
            end
            
            return setmetatable(Textbox, Library)
        end

        Library.InitWindow = function(Self)
            local SettingsPage = Self:Page({Name = "Settings", Icon = "rbxassetid://122377900702229"})

            local ConfigsSection = SettingsPage:Section({Name = "Configs", Side = 1})
            local ThemingSection = SettingsPage:Section({Name = "Theming", Side = 2})

            local ConfigName 
            local ConfigSelected 
            local ConfigsFolder = Library.Directory .. Library.Folders.Configs .. "/"

            do
                local ConfigsDropdown = ConfigsSection:Dropdown({
                    Name = "Configs",
                    Flag = "ConfigsDropdown",
                    MaxSize = 150,
                    Items = { },
                    Multi = false,
                    Callback = function(Value)
                        ConfigSelected = Value 
                    end
                })

                ConfigsSection:Textbox({
                    Name = "Config name",
                    Flag = "ConfigName",
                    Placeholder = "Config name",
                    Callback = function(Value)
                        ConfigName = Value 
                    end
                })

                ConfigsSection:Button({
                    Name = "Create",
                    Callback = function()
                        if ConfigName then 
                            if ConfigName == "" then 
                                return
                            end
    
                            writefile(ConfigsFolder .. ConfigName .. ".json", Library:GetConfig())
                            Library:GetConfigsList(ConfigsDropdown)
    
                            Library:Notification("Success", "Created config ".. ConfigName .. " succesfully", 3)
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Delete",
                    Callback = function()
                        if ConfigSelected then 
                            if isfile(ConfigsFolder .. ConfigSelected .. ".json") then
                                delfile(ConfigsFolder .. ConfigSelected .. ".json")
                                Library:GetConfigsList(ConfigsDropdown)

                                Library:Notification("Success", "Deleted config ".. ConfigSelected .. " succesfully", 3)
                            end
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Load",
                    Callback = function()
                        if ConfigSelected then 
                            if isfile(ConfigsFolder.. ConfigSelected .. ".json") then
                                local ConfigContent = readfile(ConfigsFolder.. ConfigSelected .. ".json")
                                local Success, Error = Library:LoadConfig(ConfigContent)
                                
                                if Success then 
                                    Library:Notification("Success", "Loaded config ".. ConfigSelected .. " succesfully", 3)
                                else
                                    Library:Notification("Error", "Failed to load config ".. ConfigSelected .. "\n" .. Error, 3)
                                end
                            end
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Save",
                    Callback = function()
                        if ConfigSelected then
                            if isfile(ConfigsFolder.. ConfigSelected .. ".json") then
                                local Success, Error = pcall(function()
                                    writefile(ConfigsFolder .. ConfigSelected .. ".json", Library:GetConfig())
                                end)

                                if Success then 
                                    Library:Notification("Success", "Saved config ".. ConfigSelected .. " succesfully", 3)
                                else
                                    Library:Notification("Error", "Failed to save config ".. ConfigSelected .. "\n" .. Error, 3)
                                end
                            end
                        end
                    end
                })

                ConfigsSection:Button({
                    Name = "Refresh",
                    Callback = function()
                        Library:GetConfigsList(ConfigsDropdown)
                    end
                })

                ConfigsSection:Label({Name = "UI Bind"}):Keybind({Flag = "UIBind", Mode = "Toggle", Default = Enum.KeyCode.RightShift, Callback = function(Value)
                    Library.MenuKeybind = Flags["UIBind"].Key
                end})

                ConfigsSection:Button({
                    Name = "Unload",
                    Callback = function()
                        Library:Exit()
                    end
                })

                ConfigsSection:Toggle({
                    Name = "Watermark",
                    Flag = "Watermark",
                    Default = true,
                    Callback = function(Value)
                        Self.Watermark:SetVisibility(Value)
                    end
                })

                Library:GetConfigsList(ConfigsDropdown)
            end

            do
                for Index, Value in Library.Theme do
                    ThemingSection:Label({Name = Index}):Colorpicker({
                        Name = Index,
                        Flag = Index,
                        Default = Value,
                        Callback = function(Value)
                            Library.Theme[Index] = Value
                            Library:ChangeTheme(Index, Value)
                        end
                    })
                end
            end
        end
    end
end

getgenv().Library = Library
return Library 
