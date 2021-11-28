if SERVER then
    AddCSLuaFile( "voice_balance/client/init.lua" )
    AddCSLuaFile( "voice_balance/client/config.lua" )
    AddCSLuaFile( "voice_balance/client/balancer.lua" )
else
    include( "voice_balance/client/init.lua" )
end
