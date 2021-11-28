if SERVER then
    AddCSLuaFile( "voice_balancer/client/init.lua" )
    AddCSLuaFile( "voice_balancer/client/config.lua" )
    AddCSLuaFile( "voice_balancer/client/balancer.lua" )
else
    include( "voice_balancer/client/init.lua" )
end
