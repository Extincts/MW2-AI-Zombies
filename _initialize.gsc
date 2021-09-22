initial_setup()
{
    self FreezeControls( false );
    self client_variables();
    self client_loadout();
    
    //if( self IsHost() )
    //self thread runDebugScripts(); 
    
    if( !IsDefined( level.initialize_done ) )
    {
        level.initialize_done = true;
            
        level thread overflowfix();    
        
        //Global Initialize Functions
        level initial_dvars();
        level increaseEntitySpace();
        level remove_deathBarriers();
        level spawn_map_edits();
        level global_variables();
        level loadarrays();
        
        //Global Threads
        level thread server_set_vision();
        
        //Global Huds 
        level notify( "match_start_timer_beginning" );
        level wait_until_all_connected();
        
        self helicopter_fly_in();
        level thread update_rounds( level.round );
    }
    
    self thread track_ai_pathing();
    self thread player_death_monitor();
    self thread player_weapon_hud();
    self thread update_points( 0 );
    
    if( self IsHost() )
    {
        level thread zombie_round_monitor();
        level thread mystry_box( (-2219, -97, -1455), (0,90,0) );
        level thread power_up_box( (-1728.16, -1074.43, -1455.88), (0,90,0) );
        level thread do_smoke( 4, (-1770, -900, -1455) );
        level thread power_monitor();
        wait 1; //ALLOWS EVERYTHING TO BE LOADED BEFORE ANY ZOMBIES SPAWN
        level thread spawn_zombies( level.zombies );
        level thread cc( "Let's try and dull this fog." );
    }
}

global_variables()
{
    level.gamemodeType    = "medium"; //easy, medium, hard
    level.round           = 1;
    level.zombies         = 10;
    level.spawned_zombies = 0;
    level.zombies_speed   = 150;
    level.zombies_health  = 100;
}

client_variables()
{
    self.points = 500;
}

client_loadout()
{
    self SetOrigin( (-1770, -900, -1455) );
    self TakeAllWeapons();
    //self _clearPerks();
    self giveWeap( "beretta_mp", 0, false, undefined, true ); 
}

initial_dvars()
{
    //makeDvarServerInfo( "ui_allow_teamchange", 0 );
    //SetDvar( "ui_allow_teamchange", 0 );
    
    setDvar("g_TeamName_Allies", "^2Humans");
    setDvar("g_TeamName_Axis", "^1Zombies");
    
    /*setDvar( "ui_maxclients", 4 );
    makeDvarServerInfo("ui_maxclients", 4 );
    setDvar( "sv_maxclients", 4 );
    makeDvarServerInfo( "sv_maxclients", 4 );*/
    
    setDvar( "g_hardcore", 1 );
    makeDvarServerInfo( "g_hardcore", 1 );
    
    level.killstreakRewards           = false;
    level.doPrematch                  = false;
    level.teambalance                 = false;
    level.intermission                = false;
    level.teamBased                   = true;
    level.blockWeaponDrops            = true;
    level.maxClients                  = 4;
    level.teamLimit                   = 4;
    level.prematchPeriod              = 0;
    level.postGameNotifies            = 0;
    level.matchRules_damageMultiplier = 0;
}