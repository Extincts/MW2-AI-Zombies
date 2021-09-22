zombie_round_monitor()
{
    level endon( "disconnect" );
    
    for(;;)
    {
        level waittill( "round_finished" );
        
        level.round++;
        
        if( level.gamemodeType == "hard" )
            level.zombies += 6;
        else if( level.gamemodeType == "medium")    
            level.zombies += 4;
        else level.zombies += 2;
        
        if( level.zombies_speed < 310 )
            level.zombies_speed += 10;
        level.zombies_health += 20;
        
        if( level.round == 5 && IsDefined( level.toolbox ) )
            level thread cc( "Fuck sake. These flashing lights are really getting on my nerves, try and fix them!" );
        if( level.round == 7 && IsDefined( level.toolbox ) )
            level thread cc( "*Sigh* Fuck it.. Where is my toolbox!" );
            
        wait 1;
        
        foreach( player in level.players )
        {
            equipment = player maps\mp\perks\_perks::validatePerk( 1, "frag_grenade_mp" );
            player maps\mp\perks\_perks::givePerk( equipment );
        }
        
        level.ai_zombies = [];
        level update_rounds();
        wait 3;
        level thread spawn_zombies( level.zombies );
    }
}

//death monitor - reset store paths

player_death_monitor()
{
    self endon( "disconnect" );
    for(;;)
    {
        self waittill( "death" );
        self.store_paths = [];
        //self _changeTeam( "spectator" );
        
        self thread maps\mp\gametypes_playerlogic::spawnSpectator();
        wait .1;
        self _changeTeam("allies");
        
        level waittill( "round_finished" );
        self forceSpawn();
            
        self waittill( "spawned_player" );
        self client_loadout();
        
    }
}

server_set_vision()
{
    level endon( "game_ended" );
    
    for(;;)
    {
        foreach( player in level.players )
            if( IsAlive( player ) )
                player visionSetNakedForPlayer( "icbm", .1 );
        wait .1;
    }
}