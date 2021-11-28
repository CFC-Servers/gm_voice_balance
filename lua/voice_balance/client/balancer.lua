local IsValid = IsValid
local Clamp = math.Clamp
local Round = math.Round
local tableInsert = table.insert
local tableRemove = table.remove
local tostring = tostring
local tonumber = tonumber
local tobool = tobool

local RoundedBox = draw.RoundedBox
local SimpleTextOutlined = draw.SimpleTextOutlined
local SetDrawColor = surface.SetDrawColor
local DrawLine = surface.DrawLine

local TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

local addCB = function( cvar, cb )
    cvars.AddChangeCallback( cvar:GetName(), function( _, old, new )
        if new == old then return end

        cb( new )
    end, "VoiceBalancer" )
end

-- Set at the bottom
local setup
local teardown

-- Cvars --
local enabled = GetConVar( "voicebalancer_enabled" )
addCB( enabled, function( n, o )
    enabled = tobool( n )

    if enabled then
        setup()
    else
        teardown()
    end
end )
enabled = enabled:GetBool()

-- Treats 1 to 100 as 0 to 0.4
local translateVolume = function( n )
    return ( n / 100 ) * 0.4
end

local volume = GetConVar( "voicebalancer_volume" )
addCB( volume, function(n) volume = translateVolume( n ) end )
volume = translateVolume( volume:GetFloat() )

local sampleCount = GetConVar( "voicebalancer_samples" )
addCB( sampleCount, function(n) sampleCount = tonumber(n) end  )
sampleCount = sampleCount:GetInt()

local increaseRate = GetConVar( "voicebalancer_increase_rate" )
addCB( increaseRate, function(n) increaseRate = tonumber(n) end  )
increaseRate = increaseRate:GetFloat()

local graphEnabled = GetConVar( "voicebalancer_graph_enabled" )
addCB( graphEnabled, function(n) graphEnabled = tobool(n) end )
graphEnabled = graphEnabled:GetBool()

local graphAlpha = GetConVar( "voicebalancer_graph_alpha" )
addCB( graphAlpha, function(n) graphAlpha = tonumber(n) end )
graphAlpha = graphAlpha:GetInt()

local percentEnabled = GetConVar( "voicebalancer_percent_enabled" )
addCB( percentEnabled, function(n) percentEnabled = tobool(n) end )
percentEnabled = percentEnabled:GetBool()

local percentFont = GetConVar( "voicebalancer_percent_font" )
addCB( percentFont, function(n) percentFont = tostring(n) end )
percentFont = percentFont:GetString()


--
-- Voice Balancing
--

local tracked = {}

local checkVoice = function( ply )
    local unscaled = ply:VoiceVolume()
    local scale = ply:GetVoiceVolumeScale()

    -- The "effective" volume
    local vol = unscaled * scale

    local scaleMod = volume / vol
    if scaleMod > 1 then
        scaleMod = scaleMod * increaseRate
    end

    local newScale = scale * scaleMod
    newScale = Clamp( newScale, 0, tracked[ply] )
    newScale = Round( newScale, 4 )

    ply:SetVoiceVolumeScale( newScale )
end

local function resetTimerName( ply )
    return "VoiceBalance_Reset_" .. ply:SteamID64()
end


--
-- Hooks
--

-- PlayerStartVoice
local function voiceStartWatcher( ply )
    timer.Remove( resetTimerName( ply ) )

    -- Keep track of the volume they started at
    tracked[ply] = ply:GetVoiceVolumeScale()
    checkVoice( ply )
end


-- PlayerEndVoice
local function voiceEndWatcher( ply )
    local p = tracked[ply]

    if p then
        timer.Create( resetTimerName( ply ), 1, 1, function()
            ply:SetVoiceVolumeScale( p )
        end )
    end

    tracked[ply] = nil
end


-- Think
local function thinkWatcher()
    for ply in pairs( tracked ) do
        if IsValid( ply ) then
            checkVoice( ply )
        else
            tracked[ply] = nil
        end
    end
end


--
-- VGUI
--

-- TODO: Configurable colors
local GREEN = Color( 0, 225, 0 )
local YELLOW = Color( 225, 225, 0 )
local ORANGE = Color( 225, 145, 0 )
local RED = Color( 225, 0, 0 )
local BLACK = Color( 0, 0, 0 )
local VOICE_BG = Color( 0, 0, 0, 240 )

local function getScaleColor( scale )
    if scale > 0.85 then return GREEN end
    if scale > 0.70 then return YELLOW end
    if scale > 0.65 then return ORANGE end

    return RED
end


--
-- VoiceNotify Wraps
--

local VN = VoiceNotify

VN._Init = VN._Init or VN.Init
VN.Init = function( self )
    self:_Init()
    self.scaleHistory = {}
    self.scaleSum = 0
end

VN.updateAvgScale = function( self )
    local scale = self.ply:GetVoiceVolumeScale()

    tableInsert( self.scaleHistory, scale )
    self.scaleSum = self.scaleSum + scale

    if #self.scaleHistory > sampleCount then
        local removed = tableRemove( self.scaleHistory, 1 )
        self.scaleSum = self.scaleSum - removed
    end

    return self.scaleSum / #self.scaleHistory
end

local customPaint = function( self, w, h )
    if not IsValid( self.ply ) then return end

    if graphEnabled then
        RoundedBox( 4, 0, 0, w, h, VOICE_BG )
    else
        RoundedBox( 4, 0, 0, w, h, Color( 0, self.ply:VoiceVolume() * 255, 0, 240 ) )
    end

    local avg = self:updateAvgScale()

    if percentEnabled then
        local scale = Round( avg * 100 )
        local scaleStr = tostring( scale ) .. "%"
        local scaleColor = getScaleColor( avg )

        local x = w - 8
        local y = 20

        SimpleTextOutlined(
            scaleStr, percentFont, x, y, scaleColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, BLACK
        )
    end

    if not graphEnabled then return end

    -- TODO: Store this somewhere
    local perSegment = w / sampleCount

    local lastX = nil
    local lastY = nil
    local lastScale = nil
    local historyCount = #self.scaleHistory

    for i = historyCount, 1, -1 do
        local scale = self.scaleHistory[i]

        local x = w - ( i * perSegment )
        local y = ( h - 2 ) * scale

        if lastX and lastY and lastScale then
            local median = ( scale + lastScale ) / 2
            local col = getScaleColor( median )
            local r, g, b = col:Unpack()

            SetDrawColor( r, g, b, graphAlpha )
            DrawLine( lastX, lastY, x, y )
        end

        lastX = x
        lastY = y
        lastScale = scale
    end
end

--
-- Init
--

VN._Paint = VN._Paint or VN.Paint

local function addHooks()
    if not enabled then return end
    hook.Add( "PlayerStartVoice", "VoiceBalancer", voiceStartWatcher )
    hook.Add( "PlayerEndVoice", "VoiceBalancer", voiceEndWatcher )
    hook.Add( "Think", "VoiceBalancer", thinkWatcher )
end

local function removeHooks()
    hook.Remove( "Think", "VoiceBalancer" )
    hook.Remove( "PlayerStartVoice", "VoiceBalancer" )
    hook.Remove( "PlayerEndVoice", "VoiceBalancer" )
end

local function updateCurrentPaint( paint )
    if not g_VoicePanelList then return end

    for _, v in ipairs( g_VoicePanelList:GetChildren() ) do
        v.Paint = paint
    end
end


setup = function()
    VN.Paint = customPaint
    updateCurrentPaint( customPaint )
    addHooks()
end

teardown = function()
    VN.Paint = VN._Paint
    updateCurrentPaint( VN._Paint )
    removeHooks()

    for ply, vol in pairs( tracked ) do
        ply:SetVoiceVolumeScale( vol )
        timer.Remove( resetTimerName( ply ) )
    end
end

if enabled then setup() end
