
 -- GPT-Hook v3.1c
-- fully made with GPT4
-- features table
local features = {
  esp_enabled = true,
  triggerbot_key = KEY_NONE,
  aimbot_key = KEY_NONE,
  aimFOV = 1.0,
  aimSmooth = 150,
  DrawCircle = false,
  silent_enabled = false,
  recoil_enabled = false,
  bhop_enabled = false,
  autostrafe_enabled = false,
  water_enabled = false,
  speclist_enabled = false,
  freecam_key = KEY_NONE,
  freecam_active = false,
  name = false,
  box = false,
  health_bar = false,
  health_text = false,
  rank_text = false,
  weapon_text = false,
  skeleton = false,
  ignore_staff = false,
  ignore_noclip = true,
  ignore_team = false,
}
local frameColor = Color(40, 40, 40, 255)
local tabBackgroundColor = Color(50, 50, 50, 255)
local tabContentBackgroundColor = Color(50, 50, 50, 255)
local activeTabColor = Color(50, 50, 50, 255)
local inactiveTabColor = Color(40, 40, 40, 255)
local render_distance_limit = 3000
local friends = {}
--ESP
local function drawHpBar(x, y, width, height, health, max_health)
  if not features.health_bar then return end
  local health_fraction = math.Clamp(health / max_health, 0, 1)
  surface.SetDrawColor(0, 0, 0, 255)
  surface.DrawOutlinedRect(x, y, width, height)
  local filled_height = (height - 2) * health_fraction
  surface.SetDrawColor(255 * (1 - health_fraction), 255 * health_fraction, 0, 255)
  surface.DrawRect(x + 1, y + 1 + (height - 2 - filled_height), width - 2, filled_height)
end
local function drawBoundingBoxHealth(x, y, health, max_health)
   if not features.health_text then return end
   surface.SetTextColor(127, 255, 0, 255)
   surface.SetFont("DefaultSmall")
   local text = tostring(health) .. "/" .. tostring(max_health)
   local text_width, text_height = surface.GetTextSize(text)
   surface.SetTextPos(x, y - text_height) -- Change the position to the top right
   surface.DrawText(text)
end
local function drawPlayerName(x, y, name)
  if not features.name then return end
  surface.SetTextColor(0, 0, 0, 255)
  surface.SetFont("DefaultSmall")
  for i = -1, 1 do
    for j = -1, 1 do
      local text_width, text_height = surface.GetTextSize(name)
        surface.SetTextPos(x - text_width / 2 + i, y - text_height - 2 + j)
      surface.DrawText(name)
    end
end
  surface.SetTextColor(255, 255, 255, 255)
  local text_width, text_height = surface.GetTextSize(name)
  surface.SetTextPos(x - text_width / 2, y - text_height - 2)
  surface.DrawText(name)
end
local function drawPlayerRank(x, y, rank)
  if not features.rank_text then return end
  surface.SetTextColor(255, 255, 255, 255)
  surface.SetFont("DefaultSmall")
  local text_width, text_height = surface.GetTextSize(rank)
  surface.SetTextPos(x - text_width / 2, y + text_height + 1)
  surface.DrawText(rank)
end
local function drawPlayerTeam(x, y, team)
  if not features.team_text then return end
  surface.SetTextColor(210, 210, 0, 255)
  surface.SetFont("DefaultSmall")
  local text_width, text_height = surface.GetTextSize(team)
  surface.SetTextPos(x - text_width / 2, y - text_height + 14)
  surface.DrawText(team)
end
hook.Add("HUDPaint", "DrawBoundingBoxes", function()
local local_pos = LocalPlayer():GetPos()
for _, ply in ipairs(player.GetAll()) do
  if ply == LocalPlayer() or not ply:Alive() then continue end
  local pos = ply:GetPos()
  local distance = local_pos:Distance(pos)
  if distance > render_distance_limit then continue end
  local screen_pos = pos:ToScreen()
  if not screen_pos.visible then continue end
  local min, max = ply:OBBMins(), ply:OBBMaxs()
  local corners = {
    pos + Vector(min.x, min.y, min.z),
    pos + Vector(min.x, max.y, min.z),
    pos + Vector(max.x, max.y, min.z),
    pos + Vector(max.x, min.y, min.z),
    pos + Vector(min.x, min.y, max.z),
    pos + Vector(min.x, max.y, max.z),
    pos + Vector(max.x, max.y, max.z),
    pos + Vector(max.x, min.y, max.z),
  }
local min_x, max_x, min_y, max_y = math.huge, -math.huge, math.huge, -math.huge
  for _, corner in ipairs(corners) do
  local screen_corner = corner:ToScreen()
    if not screen_corner.visible then break end
      min_x = math.min(min_x, screen_corner.x)
      max_x = math.max(max_x, screen_corner.x)
      min_y = math.min(min_y, screen_corner.y)
      max_y = math.max(max_y, screen_corner.y)
    end
if features.box then
  surface.SetDrawColor(255, 0, 0, box_alpha)
  surface.DrawOutlinedRect(min_x, min_y, max_x - min_x, max_y - min_y)
end
drawPlayerName((min_x + max_x) / 2, min_y, ply:Name())
local health = ply:Health()
local max_health = ply:GetMaxHealth()
local rank = ply:GetUserGroup() -- Get the player's rank
drawPlayerRank((min_x + max_x) / 2, max_y, rank) -- Call the new drawPlayerRank function
local team = team.GetName(ply:Team()) -- Get the player's team name
drawPlayerTeam((min_x + max_x) / 2, max_y, team) -- Call the new drawPlayerTeam function
drawBoundingBoxHealth(max_x + 1, min_y, health, max_health)
drawHpBar(max_x + 1, min_y, 5, max_y - min_y, health, max_health)
end
end)
 
--AimBot
desiredBones = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine3","ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_L_UpperArm"}
priorityBones = {"ValveBiped.Bip01_Head1"}
local boneChoices = {
    ["1_All"] = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine3","ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_L_UpperArm"},
    ["2_Head"] = {"ValveBiped.Bip01_Head1"},
    ["3_Body"] = {"ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine3", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4"},
    ["4_Center"] = {"ValveBiped.Bip01_Spine","ValveBiped.Bip01_Pelvis"},
    ["5_Arms"] = {"ValveBiped.Bip01_L_Clavicle", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_R_Clavicle", "ValveBiped.Bip01_R_UpperArm"},
    ["6_Legs"] = {"ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_R_Calf"}
}
local bonePriority = {
    ["None"] = {"nil"},
    ["Head"] = {"ValveBiped.Bip01_Head1"},
    ["Upper Body"] = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4"},
    ["Lower Body"] = {"ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_Spine"},
}
local function GetFov(ply, targetPos)
    local eyePos = ply:GetShootPos()
    local eyeAngles = ply:EyeAngles()
    local targetDir = (targetPos - eyePos):GetNormalized()
    local targetAngles = targetDir:Angle()
    local deltaAngles = eyeAngles - targetAngles
    deltaAngles:Normalize()
    local baseFov = ply:GetFOV() * 0.5
    local hFov = math.abs(deltaAngles.yaw)
    local vFov = math.abs(deltaAngles.pitch)
    local fov = 2 * math.deg(math.atan(math.sqrt(math.tan(math.rad(hFov))^2 + math.tan(math.rad(vFov))^2)))
    fov = math.Clamp(fov, 0, 180)
    return fov
end
local function IsValidTarget(ply, target, targetPos)
  if not IsValid(target) or not target:IsPlayer() then
    return false
  end
  local eyePos = ply:GetShootPos()
  local traceData = {
    start = eyePos,
    endpos = targetPos,
    filter = {ply}
  }
  local traceRes = util.TraceLine(traceData)
  -- Check if the target is set as a friend
  if friends[target:SteamID()] then
    return false
  end
  -- Check if the target is a staff member (superadmin or admin)
  if features.ignore_staff and (target:IsUserGroup("superadmin") or target:IsUserGroup("admin")) then
    return false
  end
  -- Check if the target is in the same team as the player
  if features.ignore_team and ply:Team() == target:Team() then
    return false
  end
  -- Check if the target is in NoClip mode
  if features.ignore_noclip and target:GetMoveType() == MOVETYPE_NOCLIP then
    return false
  end
  return traceRes.Entity == target
end
local originalRoll = 0
local function AimAtNearestPlayer()
    local ply = LocalPlayer()
    local eyePos = ply:GetShootPos()
    local aimTarget = nil
    local targetPos = nil
    local bestFov = math.huge
 
    for _, target in ipairs(player.GetAll()) do
        if target ~= ply and target:Alive() then
            local tempTargetPos = nil
            local tempBoneList = {}
            for _, boneName in ipairs(priorityBones) do
                local boneID = target:LookupBone(boneName)
                if boneID then
                    local pos = target:GetBonePosition(boneID)
                    if IsValidTarget(ply, target, pos) then
                        table.insert(tempBoneList, boneName)
                    end
                end
            end
 
            if #tempBoneList == 0 then
                tempBoneList = desiredBones
            end
 
            for _, boneName in ipairs(tempBoneList) do
                local boneID = target:LookupBone(boneName)
                if boneID then
                    local pos = target:GetBonePosition(boneID)
                    local fov = GetFov(ply, pos)
                    if fov < bestFov and IsValidTarget(ply, target, pos) then
                        aimTarget = target
                        targetPos = pos
                        bestFov = fov
                    end
                end
            end
        end
    end
 
    if aimTarget then
        local currentAngles = ply:EyeAngles()
        local targetAngles = (targetPos - eyePos):Angle()
        local smoothFactor = features.aimSmooth * 0.01
        local newAngles = LerpAngle(smoothFactor, currentAngles, targetAngles)
        ply:SetEyeAngles(newAngles)
    end
end
hook.Add("Think", "AimAtNearestPlayer", function()
    local ply = LocalPlayer()
    if input.IsMouseDown(features.aimbot_key) and not ply:IsTyping() then
        AimAtNearestPlayer()
    else
        local eyeAngles = ply:EyeAngles()
        eyeAngles.roll = 0
        ply:SetEyeAngles(eyeAngles)
    end
end)
--TriggerBot
local triggerbotDelay = 0.04
local function TriggerBot()
  local ply = LocalPlayer()
  local trace = ply:GetEyeTrace()
  local target = trace.Entity
 
  if IsValid(target) and target:IsPlayer() and target:Alive() then
    local boneID = target:TranslatePhysBoneToBone(trace.PhysicsBone)
    local boneName = target:GetBoneName(boneID)
 
    if input.IsMouseDown(features.triggerbot_key) then
      if not ply.triggerbotTimerActive then
        ply.triggerbotTimerActive = true
        timer.Create("triggerbotTimer", triggerbotDelay, 0, function()
          local updatedTrace = ply:GetEyeTrace()
          local updatedTarget = updatedTrace.Entity
          local updatedBoneID = updatedTarget:TranslatePhysBoneToBone(updatedTrace.PhysicsBone)
          local updatedBoneName = updatedTarget:GetBoneName(updatedBoneID)
 
          if input.IsMouseDown(features.triggerbot_key) and IsValid(updatedTarget) and updatedTarget:IsPlayer() and table.HasValue(_G.desiredBones, updatedBoneName) then
            ply:ConCommand("+attack")
            timer.Simple(0.01, function() ply:ConCommand("-attack") end)
          else
            timer.Remove("triggerbotTimer")
            ply.triggerbotTimerActive = false
          end
        end)
      end
    else
      if ply.triggerbotTimerActive then
        timer.Remove("triggerbotTimer")
        ply.triggerbotTimerActive = false
      end
    end
  elseif ply.triggerbotTimerActive then
    timer.Remove("triggerbotTimer")
    ply.triggerbotTimerActive = false
  end
end
 
hook.Add("Think", "TriggerBot", TriggerBot)
-- GUI implementation
local gui_open = false
local gui
local insert_key_released = true
local function createGUI()
  gui = vgui.Create("DFrame")
  gui:SetSize(300, 250)
  gui:SetTitle("GPT-Hook v3.1c")
  gui:Center()
  gui:SetVisible(false)
  gui:SetDeleteOnClose(false)
  gui.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, frameColor)
  end
  local menuTab = vgui.Create("DPanel", gui)
  menuTab:SetSize(0, 0)
  menuTab:SetPos(0, 0)
  menuTab.Paint = function()
 end
local sheet = vgui.Create("DPropertySheet", gui)
sheet:Dock(FILL)
sheet.Paint = function(self, w, h)
   draw.RoundedBox(4, 0, 0, w, h, tabBackgroundColor)
end
local sheet = vgui.Create("DPanel", gui)
sheet:SetSize(280, 185)
sheet:SetPos(10, 55)
sheet.Paint = function(self, w, h)
   draw.RoundedBox(4, 0, 0, w, h, tabBackgroundColor)
end
-- Aim Tab
local aim_panel = vgui.Create("DPanel", sheet)
aim_panel:SetSize(sheet:GetWide(), sheet:GetTall())
aim_panel.Paint = function(self, w, h)
   draw.RoundedBox(0, 0, 0, w, h, tabContentBackgroundColor)
end
aim_panel:SetVisible(true)
-- ESP Tab
local esp_panel = vgui.Create("DPanel", sheet)
esp_panel:SetSize(sheet:GetWide(), sheet:GetTall())
esp_panel.Paint = function(self, w, h)
  draw.RoundedBox(0, 0, 0, w, h, tabContentBackgroundColor)
end
esp_panel:SetVisible(false)
-- Misc Tab
local misc_panel = vgui.Create("DPanel", sheet)
misc_panel:SetSize(sheet:GetWide(), sheet:GetTall())
misc_panel.Paint = function(self, w, h)
  draw.RoundedBox(0, 0, 0, w, h, tabContentBackgroundColor)
end
misc_panel:SetVisible(false)
-- Custom tab buttons
local function createCustomTab(parent, text, panelToShow, iconPath)
  local button = vgui.Create("DButton", parent)
  button:SetText(text)
  button:SetTextColor(Color(255, 255, 255))
  button:SetSize(80, 25)
  local icon = vgui.Create("DImage", button)
  icon:SetPos(6, 5)
  icon:SetSize(16, 16)
  icon:SetImage(iconPath)
  button.Paint = function(self, w, h)
  if panelToShow:IsVisible() then
    draw.RoundedBox(4, 0, 0, w, h, activeTabColor)
  else
    draw.RoundedBox(4, 0, 0, w, h, inactiveTabColor)
  end
end
  button.DoClick = function()
    aim_panel:SetVisible(false)
    esp_panel:SetVisible(false)
    misc_panel:SetVisible(false)
    panelToShow:SetVisible(true)
  end
  return button
end
local aim_tab = createCustomTab(gui, "   AimBot", aim_panel, "icon16/user.png")
aim_tab:SetPos(5, 29)
local esp_tab = createCustomTab(gui, "   ESP", esp_panel, "icon16/eye.png")
esp_tab:SetPos(85, 29)
local misc_tab = createCustomTab(gui, "   Misc", misc_panel, "icon16/wrench.png")
misc_tab:SetPos(165, 29)
--Entity list button (place-holder)
local entityButton = vgui.Create("DImageButton", gui)
entityButton:SetSize(16, 16)
entityButton:SetPos(gui:GetWide() - 48, 33)
entityButton:SetImage("icon16/table_add.png")
--Friend list button (place-holder)
local friendli_button = vgui.Create("DImageButton", aim_panel)
friendli_button:SetPos(255, 2)
friendli_button:SetSize(16, 16)
friendli_button:SetImage("icon16/user_add.png")
--Create the cog button
local cogButton = vgui.Create("DImageButton", gui)
cogButton:SetSize(16, 16)
cogButton:SetPos(gui:GetWide() - 26, 33)
cogButton:SetImage("icon16/cog.png")
--Color picker popup menu
function createColorPickerMenu()
  local colorPickerMenu = vgui.Create("DFrame")
  colorPickerMenu:SetSize(330, 570)
  colorPickerMenu:SetTitle("Color Picker")
  colorPickerMenu:SetVisible(false)
  colorPickerMenu:Center()
  colorPickerMenu:SetDeleteOnClose(false)
  colorPickerMenu.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, frameColor)
  end
  return colorPickerMenu
end
colorPickerMenu = createColorPickerMenu()
--Friendlist
function createFriendListMenu()
  local friendlistMenu = vgui.Create("DFrame")
  friendlistMenu:SetSize(500, 250)
  friendlistMenu:SetTitle("Player List")
  friendlistMenu:SetVisible(false)
  friendlistMenu:Center()
  friendlistMenu:SetDeleteOnClose(false)
  friendlistMenu.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, frameColor)
  end
  return friendlistMenu
end
friendlistMenu = createFriendListMenu()
--Entity List
local function CreateEntityListMenu()
  local entityMenu = vgui.Create("DFrame")
  entityMenu:SetSize(500, 250)
  entityMenu:SetTitle("Entity List")
  entityMenu:SetVisible(false)
  entityMenu:Center()
  entityMenu:SetDeleteOnClose(false)
  entityMenu.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, frameColor)
  end
  return entityMenu
end
entityMenu = CreateEntityListMenu()
--show/hide Color picker popup menu when player_add button is clicked
cogButton.DoClick = function()
  colorPickerMenu:SetVisible(not colorPickerMenu:IsVisible())
end
-- Show/hide Friend List popup menu when the cog button is clicked
friendli_button.DoClick = function()
  friendlistMenu:SetVisible(not friendlistMenu:IsVisible())
end
-- Show/hide Entity List popup menu when the table_add button is clicked
entityButton.DoClick = function()
  entityMenu:SetVisible(not entityMenu:IsVisible())
end
--Frame color picker
local frameColorPicker = vgui.Create("DColorMixer", colorPickerMenu)
frameColorPicker:SetPos(10, 30)
frameColorPicker:SetSize(150, 170)
frameColorPicker:SetPalette(true)
frameColorPicker:SetAlphaBar(true)
frameColorPicker:SetWangs(true)
frameColorPicker:SetColor(frameColor)
frameColorPicker.ValueChanged = function(self, color)
frameColor = color
  gui.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, frameColor)
  end
end
--Background1 color picker
local tabBackgroundColorPicker = vgui.Create("DColorMixer", colorPickerMenu)
tabBackgroundColorPicker:SetPos(170, 30)
tabBackgroundColorPicker:SetSize(150, 170)
tabBackgroundColorPicker:SetPalette(true)
tabBackgroundColorPicker:SetAlphaBar(true)
tabBackgroundColorPicker:SetWangs(true)
tabBackgroundColorPicker:SetColor(tabBackgroundColor)
tabBackgroundColorPicker.ValueChanged = function(self, color)
tabBackgroundColor = color
  sheet.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, tabBackgroundColor)
  end
end
--Background2 color picker
local tabContentBackgroundColorPicker = vgui.Create("DColorMixer", colorPickerMenu)
tabContentBackgroundColorPicker:SetPos(85, 210)
tabContentBackgroundColorPicker:SetSize(150, 170)
tabContentBackgroundColorPicker:SetPalette(true)
tabContentBackgroundColorPicker:SetAlphaBar(true)
tabContentBackgroundColorPicker:SetWangs(true)
tabContentBackgroundColorPicker:SetColor(tabContentBackgroundColor)
tabContentBackgroundColorPicker.ValueChanged = function(self, color)
tabContentBackgroundColor = color
  aim_panel.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, tabContentBackgroundColor)
  end
  esp_panel.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, tabContentBackgroundColor)
  end
  misc_panel.Paint = function(self, w, h)
    draw.RoundedBox(4, 0, 0, w, h, tabContentBackgroundColor)
  end
end
-- Active tab color picker
local activeTabColorPicker = vgui.Create("DColorMixer", colorPickerMenu)
activeTabColorPicker:SetPos(10, 390)
activeTabColorPicker:SetSize(150, 170)
activeTabColorPicker:SetPalette(true)
activeTabColorPicker:SetAlphaBar(true)
activeTabColorPicker:SetWangs(true)
activeTabColorPicker:SetColor(activeTabColor)
activeTabColorPicker.ValueChanged = function(self, color)
  activeTabColor = color
end
-- Inactive tab color picker
local inactiveTabColorPicker = vgui.Create("DColorMixer", colorPickerMenu)
inactiveTabColorPicker:SetPos(170, 390)
inactiveTabColorPicker:SetSize(150, 170)
inactiveTabColorPicker:SetPalette(true)
inactiveTabColorPicker:SetAlphaBar(true)
inactiveTabColorPicker:SetWangs(true)
inactiveTabColorPicker:SetColor(inactiveTabColor)
inactiveTabColorPicker.ValueChanged = function(self, color)
  inactiveTabColor = color
end
--Player List
local playerList = vgui.Create("DListView", friendlistMenu)
playerList:SetSize(350, 215)
playerList:SetPos(10, 25)
playerList:AddColumn("Name")
playerList:AddColumn("SteamID"):SetFixedWidth(150)
playerList:AddColumn("Rank"):SetFixedWidth(80)
playerList:AddColumn("Index"):SetFixedWidth(40)
local function updatePlayerList()
  playerList:Clear()
  for _, ply in ipairs(player.GetAll()) do
    playerList:AddLine(ply:Nick(), ply:SteamID(), ply:GetUserGroup(), ply:EntIndex())
  end
end
local function refreshPlayerList()
  updatePlayerList()
  timer.Simple(2, refreshPlayerList)
end
refreshPlayerList()
local friendToggles = {
  {text = "Set Friend"},
  {text = "Ignore NoClip", feature = "ignore_noclip"},
  {text = "Ignore Staff", feature = "ignore_staff"},
  {text = "Ignore Team", feature = "ignore_team"},
}
for i, t in ipairs(friendToggles) do
  local toggle = vgui.Create("DCheckBoxLabel", friendlistMenu)
  toggle:SetPos(375, 35 + (i - 1) * 20)
  toggle:SetText(t.text)
  toggle:SetChecked(false)
  toggle:SizeToContents()
  t.toggle = toggle
end
local function setFriend(steamID, checked)
  if checked then
    friends[steamID] = true
  else
    friends[steamID] = nil
  end
end
playerList.OnRowSelected = function(_, _, row)
  local steamID = row:GetValue(2)
 
  for i, t in ipairs(friendToggles) do
    local toggle = t.toggle
    toggle.OnChange = nil
    if i == 1 then
      toggle:SetChecked(friends[steamID] or false)
      toggle.OnChange = function(_, checked)
        setFriend(steamID, checked)
      end
    else
      toggle:SetChecked(features[t.feature] or false)
      toggle.OnChange = function(_, checked)
        features[t.feature] = checked
      end
    end
  end
end
---AimBot (gui)
local fovSlider = vgui.Create("DNumSlider", aim_panel)
fovSlider:SetPos(-95, 135)
fovSlider:SetSize(380, 20)
fovSlider:SetMin(1.0)
fovSlider:SetMax(180.0)
fovSlider:SetDecimals(1)
fovSlider:SetValue(1.0)
fovSlider.OnValueChanged = function(self, value)
  features.aimFOV = value
end
local fovs_text = vgui.Create("DLabel", aim_panel)
fovs_text:SetText("FoV°")
fovs_text:SetPos(10, 135)
local function DrawFOVCircle()
    if not features.DrawCircle then return end
    local centerX, centerY = ScrW() * 0.5, ScrH() * 0.5
    local center = {x = centerX, y = centerY}
    local radius = math.tan(math.rad(features.aimFOV) * 0.5) * ScrH() * 0.5 / math.tan(math.rad(LocalPlayer():GetFOV()) * 0.5)
    surface.SetDrawColor(150, 150, 230, 200)
    for i = 0, 360, 1 do
        local a = math.rad(i)
        local b = math.rad(i + 1)
        local x1, y1 = center.x + math.cos(a) * radius, center.y - math.sin(a) * radius
        local x2, y2 = center.x + math.cos(b) * radius, center.y - math.sin(b) * radius
        surface.DrawLine(x1, y1, x2, y2)
    end
end
hook.Add("HUDPaint", "DrawFOVCircle", DrawFOVCircle)
local function InvertSliderDisplay(value, minValue, maxValue)
    return maxValue - value + minValue
end
local smoothSlider = vgui.Create("DNumSlider", aim_panel)
smoothSlider:SetPos(-95, 160)
smoothSlider:SetSize(380, 20)
smoothSlider:SetMin(0.00)
smoothSlider:SetMax(50.00)
smoothSlider:SetDecimals(2)
smoothSlider:SetValue(0.00)
smoothSlider.OnValueChanged = function(self, value)
  if value == 0.00 then
    features.aimSmooth = 150
  elseif value > 0.01 and value <= 0.5 then
    features.aimSmooth = 100
  elseif value > 0.51 and value <= 1 then
    features.aimSmooth = 80
  elseif value == 10 then
    features.aimSmooth = 50
  elseif value == 15 then
    features.aimSmooth = 35
  elseif value == 20 then
    features.aimSmooth = 20
  elseif value == 25 then
    features.aimSmooth = 8
  elseif value == 37.5 then
    features.aimSmooth = 4
  elseif value > 49.5 and value <= 50 then
    features.aimSmooth = 0.5
  else
    local invertedValue = InvertSliderDisplay(value, 0, 50)
    features.aimSmooth = invertedValue
  end
end
local smooth_text = vgui.Create("DLabel", aim_panel)
smooth_text:SetText("Smoothing")
smooth_text:SetPos(10, 160)
local aimbot_key_text = vgui.Create("DLabel", aim_panel)
aimbot_key_text:SetText("Aimbot Key:")
aimbot_key_text:SetPos(10, 7)
local aimbot_key = vgui.Create("DBinder", aim_panel)
aimbot_key:SetPos(10, 27)
aimbot_key:SetSize(100, 25)
aimbot_key:SetValue(features.aimbot_key)
aimbot_key.OnChange = function(_, value)
  features.aimbot_key = value
end
local target_text = vgui.Create("DLabel", aim_panel)
target_text:SetText("Target")
target_text:SetPos(150, 7)
local selection_text = vgui.Create("DLabel", aim_panel)
selection_text:SetText("Selection:")
selection_text:SetPos(185, 7)
local boneComboBox = vgui.Create("DComboBox", aim_panel)
boneComboBox:SetPos(150, 27)
boneComboBox:SetSize(100, 25)
for labelText, _ in pairs(boneChoices) do
    boneComboBox:AddChoice(labelText)
end
boneComboBox:SetText("1_All")
_G.desiredBones = boneChoices["1_All"]
boneComboBox.OnSelect = function(_, _, value)
    _G.desiredBones = boneChoices[value]
end
local priority_text = vgui.Create("DLabel", aim_panel)
priority_text:SetText("Priority")
priority_text:SetPos(150, 50)
local pselection_text = vgui.Create("DLabel", aim_panel)
pselection_text:SetText("Selection:")
pselection_text:SetPos(188, 50)
local pboneComboBox = vgui.Create("DComboBox", aim_panel)
pboneComboBox:SetPos(150, 68)
pboneComboBox:SetSize(100, 25)
for labelText, _ in pairs(bonePriority) do
    pboneComboBox:AddChoice(labelText)
end
pboneComboBox:SetText("Head") -- Set the default text to "Head"
_G.priorityBones = bonePriority["Head"] -- Set the desiredBones to the corresponding bone for "Head"
pboneComboBox.OnSelect = function(_, _, value)
    _G.priorityBones = bonePriority[value]
end
local silentCheckbox = vgui.Create("DCheckBoxLabel", aim_panel)
silentCheckbox:SetPos(10, 106)
silentCheckbox:SetText("Enable Silent-Aim")
silentCheckbox:SetValue(features.silent_enabled)
silentCheckbox:SizeToContents()
silentCheckbox.OnChange = function(panel, value)
  features.silent_enabled = value
end
local vis_recoilCheckbox = vgui.Create("DCheckBoxLabel", aim_panel)
vis_recoilCheckbox:SetPos(150, 106)
vis_recoilCheckbox:SetText("Disable Visual Recoil")
vis_recoilCheckbox:SetValue(features.recoil_enabled)
vis_recoilCheckbox:SizeToContents()
--TriggerBot (gui)
local triggerbot_key_text = vgui.Create("DLabel", aim_panel)
triggerbot_key_text:SetText("Triggerbot")
triggerbot_key_text:SetPos(10, 50)
local triggerbot2_key_text = vgui.Create("DLabel", aim_panel)
triggerbot2_key_text:SetText("Key:")
triggerbot2_key_text:SetPos(63, 50)
local triggerbot_key = vgui.Create("DBinder", aim_panel)
triggerbot_key:SetPos(10, 68)
triggerbot_key:SetSize(100, 25)
triggerbot_key:SetValue(features.triggerbot_key)
triggerbot_key.OnChange = function(_, value)
  features.triggerbot_key = value
end
--ESP (gui)
local toggles = {
  {name = "Name ESP", feature = "name"},
  {name = "Bounding Box", feature = "box"},
  {name = "Health Bar", feature = "health_bar"},
  {name = "Health Text", feature = "health_text"},
}
for i, toggle in ipairs(toggles) do
    local checkbox = vgui.Create("DCheckBoxLabel", esp_panel)
    checkbox:SetText(toggle.name)
    checkbox:SetValue(features[toggle.feature] and 1 or 0)
    checkbox:SetPos(10, 10 + (i - 1) * 20)
    checkbox.OnChange = function(_, value)
    features[toggle.feature] = value
  end
end
local toggles2 = {
  {name = "Team ESP", feature = "team_text"},
  {name = "Rank ESP", feature = "rank_text"},
  {name = "Weapon ESP", feature = "weapon_text"},
  {name = "Skeleton ESP", feature = "skeleton"},
}
for i, toggle in ipairs(toggles2) do
    local checkbox = vgui.Create("DCheckBoxLabel", esp_panel)
    checkbox:SetText(toggle.name)
    checkbox:SetValue(features[toggle.feature] and 1 or 0)
    checkbox:SetPos(150, 10 + (i - 1) * 20)
    checkbox.OnChange = function(_, value)
    features[toggle.feature] = value
  end
end
local renderDistanceSlider = vgui.Create("DNumSlider", esp_panel)
renderDistanceSlider:SetPos(10, 160)
renderDistanceSlider:SetSize(280, 20)
renderDistanceSlider:SetText("Render Distance Limit")
renderDistanceSlider:SetMin(500)
renderDistanceSlider:SetMax(10000)
renderDistanceSlider:SetDecimals(0)
renderDistanceSlider:SetValue(3000)
renderDistanceSlider.OnValueChanged = function(self, value)
  render_distance_limit = value
end
--Movement
local bhopCheckbox = vgui.Create("DCheckBoxLabel", misc_panel)
bhopCheckbox:SetPos(10, 10)
bhopCheckbox:SetText("Enable Bhop")
bhopCheckbox:SetValue(features.bhop_enabled)
bhopCheckbox:SizeToContents()
local autostrafeCheckbox = vgui.Create("DCheckBoxLabel", misc_panel)
autostrafeCheckbox:SetPos(10, 30)
autostrafeCheckbox:SetText("Enable Auto-Strafe")
autostrafeCheckbox:SetValue(features.autostrafe_enabled)
autostrafeCheckbox:SizeToContents()
local updatingCheckboxes = false
local function updateCheckboxes()
  if updatingCheckboxes then return end
  updatingCheckboxes = true
  bhopCheckbox:SetValue(features.bhop_enabled)
  autostrafeCheckbox:SetValue(features.autostrafe_enabled)
  updatingCheckboxes = false
end
bhopCheckbox.OnChange = function(self, value)
  features.bhop_enabled = value
  updateCheckboxes()
end
autostrafeCheckbox.OnChange = function(self, value)
  if features.bhop_enabled then
    features.autostrafe_enabled = value
  else
    features.autostrafe_enabled = true
    features.bhop_enabled = true
end
updateCheckboxes()
end
hook.Add("CreateMove", "GPT_Bhop_Autostrafe", function(cmd)
  if features.bhop_enabled and input.IsKeyDown(KEY_SPACE) then
    if not LocalPlayer():IsOnGround() then
      cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
  end
  if features.autostrafe_enabled then
    cmd:SetForwardMove(0)
  if(cmd:GetMouseX() > 0) then
    cmd:SetSideMove(10000)
  elseif(cmd:GetMouseX() < 0) then
    cmd:SetSideMove(-10000)
  else
    cmd:SetSideMove(0)
   end
  end
 end
end)
--"Watermark" (gui)
local water_checkbox = vgui.Create("DCheckBoxLabel", misc_panel)
water_checkbox:SetText("Watermark")
water_checkbox:SetPos(10, 50)
water_checkbox.OnChange = function(_, value)
  features.water_enabled = value
end
local water = {
    chars = {"卐"},
    speed = 120,
    centerX = ScrW() / 2,
    centerY = ScrH() / 2,
    radius = 40,
    rainbowSpeed = 60,
    rainbowPos = 0,
}
local function DrawWater()
    local time = CurTime()
    local rainbowColor = HSVToColor((water.rainbowPos + time * water.rainbowSpeed) % 360, 1, 1)
    if features.water_enabled then
        for i = 1, #water.chars do
            local char = water.chars[i]
            surface.SetFont("DermaDefault")
            surface.SetTextColor(rainbowColor)
            local charWidth, charHeight = surface.GetTextSize(char)
            local angle = i / #water.chars * 360 + time * water.speed
            local radian = math.rad(angle)
            local x = water.centerX + math.cos(radian) * water.radius
            local y = water.centerY + math.sin(radian) * water.radius
 
            -- Clamp the X and Y coordinates within the screen dimensions
            x = math.Clamp(x, 0, ScrW() - charWidth)
            y = math.Clamp(y, 0, ScrH() - charHeight)
 
            surface.SetTextPos(x - charWidth / 2, y - charHeight / 2)
            surface.DrawText(char)
        end
    end
end
hook.Add("HUDPaint", "DrawWater", function()
    DrawWater()
end)
-- Spec List
local speclistCheckbox = vgui.Create("DCheckBoxLabel", misc_panel)
speclistCheckbox:SetPos(10, 70)
speclistCheckbox:SetText("Spectator List")
speclistCheckbox:SetValue(features.speclist_enabled)
speclistCheckbox:SizeToContents()
speclistCheckbox.OnChange = function(panel, value)
  features.speclist_enabled = value
end
-- Freecam
local freecam_key = vgui.Create("DBinder", misc_panel)
freecam_key:SetPos(10, 100)
freecam_key:SetSize(80, 25)
freecam_key:SetValue(features.freecam_key)
freecam_key.OnChange = function(_, value)
  features.freecam_key = value
end
--Unload button
local unload_button = vgui.Create("DButton", misc_panel)
unload_button:SetText("UnLoad")
unload_button:SetSize(80, 25)
unload_button:SetPos(10, 133)
-- Function to handle unloading the script
local function unloadScript()
  local hookTable = hook.GetTable()
  if hookTable["HUDPaint"] and hookTable["HUDPaint"]["DrawBoundingBoxes"] then
    hook.Remove("HUDPaint", "DrawBoundingBoxes")
  else
    print("DEBUG1 wasn't properly hooked.")
  end
  if hookTable["HUDPaint"] and hookTable["HUDPaint"]["ToggleGUI"] then
    hook.Remove("HUDPaint", "ToggleGUI")
  else
    print("DEBUG2 wasn't properly hooked.")
  end
  if hookTable["CreateMove"] and hookTable["CreateMove"]["GPT_Bhop_Autostrafe"] then
    hook.Remove("CreateMove", "GPT_Bhop_Autostrafe")
  else
    print("DEBUG3 wasn't properly hooked.")
  end
  if hookTable["Think"] and hookTable["Think"]["AimAtNearestPlayer"] then
    hook.Remove("Think", "AimAtNearestPlayer")
  else
    print("DEBUG4 wasn't properly hooked!")
  end
  if hookTable["Think"] and hookTable["Think"]["AimAtNearestPlayerNormal"] then
    hook.Remove("Think", "AimAtNearestPlayerNormal")
  else
    print("DEBUG5 wasn't properly hooked!")
  end
  if hookTable["Think"] and hookTable["Think"]["TriggerBot"] then
    hook.Remove("Think", "TriggerBot")
  else
    print("DEBUG6 wasn't properly hooked!")
  end
  if hookTable["HUDPaint"] and hookTable["HUDPaint"]["DrawFOVCircle"] then
    hook.Remove("HUDPaint", "DrawFOVCircle")
  else
    print("DEBUG7 wasn't properly hooked!")
  end
  if hookTable["HUDPaint"] and hookTable["HUDPaint"]["DrawWater"] then
    hook.Remove("HUDPaint", "DrawWater")
  else
    print("DEBUG8 wasn't properly hooked!")
  end
  if colorPickerMenu:IsValid() and colorPickerMenu:IsVisible() then
    colorPickerMenu:SetVisible(false)
  end
  if friendlistMenu:IsValid() and friendlistMenu:IsVisible() then
    friendlistMenu:SetVisible(false)
  end
  if entityMenu:IsValid() and entityMenu:IsVisible() then
    entityMenu:SetVisible(false)
  end
  gui:Close()
  print("Script has been unloaded.")
end
-- Add console command to unload the script
concommand.Add("gpthook_unload", function()
  unloadScript()
end)
-- Set the DoClick method for the unload button
unload_button.DoClick = function()
  unloadScript()
end
--GPT4 credits
  local author_label = vgui.Create("DLabel", misc_panel)
  author_label:SetText("Author: GPT4 :)")
  author_label:SizeToContents()
  author_label:SetPos(10, 163)
end
createGUI()
hook.Add("HUDPaint", "ToggleGUI", function()
  if input.IsKeyDown(KEY_INSERT) and insert_key_released then
    insert_key_released = false
    gui_open = not gui_open
    features.DrawCircle = gui_open
    if gui_open then
      gui:SetVisible(true)
      gui:MakePopup()
    else
      gui:SetVisible(false)
      if colorPickerMenu:IsValid() and colorPickerMenu:IsVisible() then
        colorPickerMenu:SetVisible(false)
      end
      if friendlistMenu:IsValid() and friendlistMenu:IsVisible() then
        friendlistMenu:SetVisible(false)
      end
      if entityMenu:IsValid() and entityMenu:IsVisible() then
        entityMenu:SetVisible(false)
      end
    end
  elseif not input.IsKeyDown(KEY_INSERT) then
  insert_key_released = true
 end
end)
