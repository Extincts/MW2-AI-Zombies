power_monitor()
{
    level endon( "game_ended" );
    origin        = (-2448, -1097, -1430);
    box_dest      = modelSpawner( origin + (0,0,50), "me_electricbox4_dest", (0,180,0));
    box_dest_door = modelSpawner( origin + (-12,20,50), "me_electricbox4_door", (0,180,0) );
    
    while( IsDefined( box_dest ) )
    {
        foreach( player in level.players )
        { 
            while( Distance( player.origin, box_dest.origin ) < 128 && isAlive( player ) && bullettracepassed( box_dest.origin, player GetEye(), 0, box_dest ))
            {
                player thread doHintString( "Hold [{+usereload}] To Activate Power", box_dest.origin, 128 );
                if( player useButtonPressed() )
                {
                    wait .25;
                    if( !player usebuttonpressed() )
                        break;
                    player playsound("mouse_click");
                    player.hintString destroy();
                    box_dest_door RotateYaw( -90, .4 );
                    box_dest_door MoveTo( box_dest_door.origin + (12,-13,0), .4 ); 
                    wait .5;
                    break 4;
                }
                wait .05;
            }
        }
        wait .05; 
    }
    
    level.power_active = true;
    level thread light_monitor();
    earthquake( 0.3, 2, box_dest.origin , 100000 );
    level.smoke_spawned[2] delete(); 
    level.smoke_spawned[3] delete();
    foreach( player in level.players )
        player leaderDialogOnPlayer( "winning_score" );
    level thread cc( "Power Activated." );
    level thread cc( "About time! Now I can see clearly, do we have a electrician around here?" );
}

toolbox_monitor()
{  
    while( !IsDefined( level.power_active ) )
        wait .05;
    self setCanDamage( true );
    while( IsDefined( self ) )
    {
        self waittill( "damage", damage, attacker, direction_vec, point, meansOfDeath, tagName, modelName, partName, weaponname );
        if( !isDefined( meansOfDeath ) && meansOfDeath != "MOD_GRENADE_SPLASH" && !IsDefined( level.power_active ))
            continue;
            
        level thread nuke_all( true );
        self.origin += (0,60,-150);
            
        while( IsDefined( self ) )    
        {
            foreach( player in level.players )
            {
                if( Distance2D( self.origin, player.origin ) < 30 )
                {
                    player thread doHintString( "Hold [{+usereload}] To Pickup Toolbox", self.origin, 30 );
                    while( player UseButtonPressed() )
                    {
                        if( player UseButtonPressed() )
                        {
                            player.hintString destroy();
                            break 4;
                        }
                        wait .05;
                    }    
                }
            }
            wait .05;
        }
    }
    self Delete();
    level thread cc( "Welldone, Now it's time to fix these dodgy lights." );
}

light_monitor()
{
    level endon( "game_ended" );
    
    lights = level.global_lights;
    foreach( light in lights )
    {
        if(!IsDefined( light.active ))
            light.active = false;
        light SetModel( "com_two_light_fixture_on" );
        light SetCanDamage( true );
        wait .5;
    }
    
    for(;;)
    {
        count = 0;
        foreach( light in lights ) //CREATES RANDOM FLICKER
        { 
            if( RandomIntRange( 0, 10 ) == 5 && cointoss() && !light.active )
            {
                light thread light_active_monitor();
                light light_flicker();
            }
            if( light.active )
                count++;
        }

        if( count > 3 )
            break;
        wait .05;
    }
    level thread cc( "YES, YES, YES! All of this hard work has paid off!" );
    wait 4;
    level thread cc( "We need some stronger fucking guns around here." );
    level thread cc( "Try and extract the power from the zombie's.'" );
    level thread pack_a_punch_open();
}

light_flicker()
{
    amount = RandomInt( 20 );
    for(f=0;f<amount;f++)
    {
        self SetModel( "com_two_light_fixture_off" );
        wait RandomFloatRange( .2, .8 );
        self SetModel( "com_two_light_fixture_on" );
        wait RandomFloatRange( .4, .8 );
        if( self.active )
            break;
    }
    self notify( "stop_being_active" );
}

light_active_monitor() //self == light
{
    self endon( "stop_being_active" );
    
    if( IsDefined( level.toolbox ) )
        return;
    for(;;)
    {
        self waittill( "damage", damage, attacker, direction_vec, point, meansOfDeath, tagName, modelName, partName, weaponname );
        if( meansOfDeath != "MOD_MELEE" )
            continue;
        self.active = true;
        level thread nuke_all( true );
    }
}

pack_a_punch_open()
{
    total  = 0;
    target = level.barrier48x64[ (13 * 3) + 4 ].origin - (24,0,0);
    while( true )
    {
        foreach( zombie in level.ai_zombies ) 
        {   
            if( Distance( target, zombie.body.origin ) < 600 && IsDefined( zombie.died ) )
            {
                wait 1.2;
                ent = zombie.body;
                ent moveTo( target, calcDistance(250, ent.origin, target) );
                playSoundAtPos( ent.origin, "veh_b2_sonic_boom" );
                
                while( ent.origin != target )
                {
                    fx = SpawnFx(loadFX("misc/flare_ambient"), ent.origin);
                    triggerFx( fx );
                    wait .03;
                    fx Delete();
                    if( !IsDefined( ent ) )
                        break;
                }
                
                ent Delete();
                zombie.died = undefined;  
                
                total++;
                if( total > level.players.size * 24 )
                    break 3;
            }
        }
        wait .05;
    } 
    
    level thread nuke_all( true );
    earthQuake( 1.4, 1, target, 9999 );
    
    weapon_table = modelSpawner( level.barrier48x64[ (13 * 3) + 0 ].origin + (-22,0,10), "com_plasticcase_enemy", (0,180,0), undefined, level.airDropCrateCollision ); 
    weapon_table thread trade_weap_monitor();
    
    level.barrier48x64[ (13 * 3) + 0 ].origin -= (0,40,0);
    level.barrier48x64[ (13 * 3) + 1 ].origin -= (0,40,0);
    level.barrier48x64[ (13 * 3) + 3 ].origin -= (0,40,0);
    level.barrier48x64[ (13 * 3) + 4 ].origin -= (0,40,0);
    
    level thread cc( "We're getting smarter by each day... goodjob." );
    level thread cc( "Packapunch is now discovered!" );
}

trade_weap_monitor( pers )
{
    table_status = "place";
    while(isDefined( self ))
    {
        foreach( player in level.players )
        {
            if( Distance( player.origin, self.origin ) < 60 )
            {
                player thread doHintString( "Press [{+usereload}] to " + table_status + " weapon.", self.origin, 60 );
                if(player useButtonPressed() && IsDefined( player.hintString ))
                {
                    if(table_status == "place")
                    {
                        weapon_placed = player getCurrentWeapon();
                        
                        amount = -8;
                        if( weaponClass(weapon_placed) != "sniper" )
                            amount = 6;
                        
                        placed_weapon = modelSpawner( self.origin + (0,0,29) - AnglesToForward( self.angles ) * amount, getWeaponModel(weapon_placed), self.angles + (0,180,90));
                        
                        player PlaySoundToPlayer( "player_refill_all_ammo", player );    
                        player takeWeapon( player getCurrentWeapon() );
                        player SwitchToWeapon( player GetWeaponsListPrimaries()[0] );
                        
                        placed_weapon RotateRoll(720, 1, .3, .3);
                        wait 1.2;
                        placed_weapon moveTo( placed_weapon.origin + (0,0,-13), .2, .1, .1);
                        wait .2;
                        fx = SpawnFx( level._effect["ac130_flare"], placed_weapon.origin ); 
                        TriggerFX( fx );
                        player PlaySound( "ac130_flare_burst" );
                        wait .2;
                        table_status = "pick up";
                    }
                    else 
                    {
                        player PlaySoundToPlayer( "weap_pickup", player );
                        player giveWeap( weapon_placed );
                        placed_weapon delete();
                        wait .3;
                        table_status = "place";
                    }
                }
            }
        }
        wait .05;
    }
    if(IsDefined( placed_weapon ))
        placed_weapon delete();
    self delete();
}   






