CreateClientConVar( "voicebalancer_enabled", 1, true, true, "Is VoiceBalancer enabled?", 0, 1 )
CreateClientConVar( "voicebalancer_volume", 23, true, true, "Preferred voice volume", 0, 100 )
CreateClientConVar( "voicebalancer_graph_enabled", 1, true, true, "Enable/disable the line graph on player mic boxes", 0, 1 )
CreateClientConVar( "voicebalancer_graph_alpha", 60, true, true, "Alpha for the line graph", 0, 255 )
CreateClientConVar( "voicebalancer_percent_enabled", 1, true, true, "Enable/disable the voice percentage on player mic boxes", 0, 1 )
CreateClientConVar( "voicebalancer_samples", 225, true, true, "How many historic samples to store", 33, 1200 )
CreateClientConVar( "voicebalancer_percent_font", "DermaDefaultBold", true, true, "What font to use for the voice percentages" )
CreateClientConVar( "voicebalancer_increase_rate", 0.5, true, true, "How much to modify the rate of volume-increase for player voice", 0.1, 1 )

local function populatePanel( panel )
    panel:ControlHelp( "" )
    panel:ControlHelp( "Features" )
    panel:CheckBox( "VoiceBalancer Enabled", "voicebalancer_enabled" )
    panel:CheckBox( "Voice Graph Enabled", "voicebalancer_graph_enabled" )
    panel:CheckBox( "Voice Percentage Enabled", "voicebalancer_percent_enabled" )

    panel:ControlHelp( "" )
    panel:ControlHelp( "" )
    panel:ControlHelp( "Settings" )
    panel:ControlHelp( "" )

    panel:Help( "Voice Volume sets your preferred volume to hear other players at. All player voices will be adjusted to this value. 50 is the average player voice volume.")
    panel:NumSlider( "Voice Volume", "voicebalancer_volume", 0, 100, 1 )

    panel:Help( "Sample Size determines how many historic samples to keep. This affects the length of the line graph and the averaging of the percentage. Larger values can affect performance.")
    panel:NumSlider( "Sample Size", "voicebalancer_samples", 33, 1200, 0 )

    panel:NumSlider( "Line Graph Alpha", "voicebalancer_graph_alpha", 0, 255, 0 )

    panel:Help( "Regeneration Rate determines how quickly loud players regain their volume. Lower values means they stay quieter for longer.")
    panel:NumSlider( "Regeneration Rate", "voicebalancer_increase_rate", 0.1, 1, 2 )
end

hook.Add( "AddToolMenuCategories", "VoiceBalancer_Config", function()
    spawnmenu.AddToolCategory( "Options", "Voice Balancer", "Voice Balancer" )
end )

hook.Add( "PopulateToolMenu", "VoiceBalancer_Config", function()
    spawnmenu.AddToolMenuOption( "Options", "Voice Balancer", "voicebalancer_options", "Config", "", "", function( panel )
        populatePanel( panel )
    end )
end )
