CreateClientConVar( "voicebalancer_enabled", 1, true, true, "Is VoiceBalancer enabled?", 0, 1 )
CreateClientConVar( "voicebalancer_volume", 0.2, true, true, "Preferred voice volume", 0, 1 )
CreateClientConVar( "voicebalancer_graph_enabled", 1, true, true, "Enable/disable the line graph on player mic boxes", 0, 1 )
CreateClientConVar( "voicebalancer_percent_enabled", 1, true, true, "Enable/disable the voice percentage on player mic boxes", 0, 1 )
CreateClientConVar( "voicebalancer_percent_font", "DermaDefaultBolt", true, true, "What font to use for the voice percentages" )
CreateClientConVar( "voicebalancer_samples", 200, true, true, "How many historic samples to store", 33, 1200 )
CreateClientConVar( "voicebalancer_increase_rate", 0.65, true, true, "How much to modify the rate of volume-increase for player voice", 0.1, 1 )

local function populatePanel( panel )
    panel:ControlHelp( "" )
    panel:ControlHelp( "Features" )
    panel:CheckBox( "VoiceBalancer Enabled", "voicebalancer_enabled" )
    panel:CheckBox( "Voice Graph Enabled", "voicebalancer_graph_enabled" )
    panel:CheckBox( "Voice Percentage Enabled", "voicebalancer_percent_enabled" )

    panel:ControlHelp( "" )
    panel:ControlHelp( "" )
    panel:ControlHelp( "Settings" )
    panel:NumSlider( "Preferred Voice Volume", "voicebalancer_volume", 0, 1, 3 )
    panel:NumSlider( "Sample Size", "voicebalancer_samples", 33, 1200, 0 )
end

hook.Add( "AddToolMenuCategories", "VoiceBalancer_Config", function()
    spawnmenu.AddToolCategory( "Options", "Voice Balancer", "Voice Balancer" )
end )

hook.Add( "PopulateToolMenu", "VoiceBalancer_Config", function()
    spawnmenu.AddToolMenuOption( "Options", "Voice Balancer", "voicebalancer_options", "Config", "", "", function( panel )
        populatePanel( panel )
    end )
end )
