spawn_zombies( amount )
{
    level endon( "game_ended" );
    
    for(e=0;e<amount;e++)
    {
        level thread zombie_spawn_logic();
        while( get_zombie_count() >= 15 )
            wait RandomIntRange( 1, 3 );  
        wait RandomIntRange( 1, 3 );     
        if( isDefined( level.zombies_nuked ) )
            wait 5;
    }
    wait .05;
    while( get_zombie_count() != 0 )
        wait .1;
    level notify( "round_finished" );
}

zombie_spawn_logic() 
{
    if( !IsDefined( level.ai_zombies ) )
        level.ai_zombies = [];
        
    points = level.collisions;
    origin = get_ground_position(points[ RandomInt( points.size ) ].origin - ( 144 + RandomInt( 192 ), 0, 0));
    model  = "mp_body_opforce_arab_assault_a";
    head   = "head_opforce_arab_a";
    
    zombie      = SpawnStruct();
    zombie.body = modelSpawner( origin, model );
    zombie.head = modelSpawner( zombie.body GetTagOrigin( @"j_spine4" ), head, zombie.body GetTagAngles( @"j_head" ) );
    zombie.head LinkTo( zombie.body, @"j_spine4" );
    
    zombie.knife = modelSpawner( zombie.body getTagOrigin(@"tag_inhand"), "weapon_parabolic_knife", (0,0,0) );
    zombie.knife linkto( zombie.body, @"tag_inhand" );
    zombie.knife hide();
    
    zombie.collision = modelSpawner( zombie.body GetTagOrigin( @"j_spinelower" ) - (0,0,3), "com_plasticcase_friendly", (270,270,0), undefined, level.airDropCrateCollision );
    zombie.collision  LinkTo( zombie.body, @"j_neck" );
    zombie.collision  hide();
    
    zombie.collision SetCanDamage( true );
    zombie.collision.health    = level.zombies_health;
    zombie.collision.maxhealth = level.zombies_health;
    
    zombie.collision thread zombie_damage_monitor( zombie );
    zombie.collision thread zombie_timeout_monitor( zombie );
    zombie.body thread start_ai_pathing( zombie );
    zombie.body thread zombies_attack_monitor( zombie );
    
    zombie.body ScriptModelPlayAnim( get_walking_anim() );
    
    level.ai_zombies[ level.ai_zombies.size ] = zombie;
    level.spawned_zombies++;
}

zombie_damage_monitor( zombie )
{
    level endon( "game_ended" );
    
    while( IsDefined( self ) )
    {
        self waittill( "damage", damage, attacker, direction_vec, point, meansOfDeath, tagName, modelName, partName, weaponname );
        
        attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "" );  
            
        if( point[2] >= zombie.head.origin[2] )  
        {
            playFx( level.headshot_blood, point ); 
            multiply = (damage * 1.5) - damage;
        }
        else 
            playFx( level.bodyshot_blood, point );  
        
        if( IsExplosiveDamageMOD( meansOfDeath ) )
            multiply = (damage * 1.5) - damage;      
            
        if( IsDefined( level.instaKill ) )
            multiply = 999999;
            
        if( IsDefined( multiply ) )
            self.health -= int( multiply );    
            
        attacker thread update_points( 10 );
        
        if( self.health <= 0 )
        {
            zombie.body notify( "zombie_death" );
            
            points_earned = 20; //amount earned from a body shot kill
            if( point[2] >= zombie.head.origin[2] )
            {
                points_earned += 20;
                zombie.head delete(); 
                playfx( level.headshot_blood, zombie.body GetTagOrigin( "j_spine4" ) );
                attacker playLocalSound( "bullet_impact_headshot_2" );
            }  
            else 
                zombie.body playDeathSound(); 
            
            if( isPlayer( attacker ) && attacker != self )
                attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", 100, weaponname, meansOfDeath );
                
            attacker.kills++;    
            attacker thread update_points( points_earned );    
            
            if( RandomInt( 20 ) == 10 ) 
                level thread drop_powerup( zombie.body.origin );
            
            zombie.collision delete();
            zombie.knife delete();
            
            zombie.body MoveTo( zombie.body.origin, .1 ); //STOPS THE ZOMBIE FROM MOVING WHILE DOING THE ANIMATION
            
            zombie.body ScriptModelPlayAnim( get_random_death_anim() );
            
            level.spawned_zombies--;
            if(IsDefined( zombie.body.zombie_is_meleeing ))
                zombie.body.zombie_is_meleeing = undefined;
                
            zombie.died = true;    
                
            wait 6;
            
            if( IsDefined( zombie.body ) )
                zombie.body delete();
            if( IsDefined( zombie.head ) )
                zombie.head delete(); 
            zombie.died = undefined;      
        }
    } 
}

zombies_attack_monitor( zombie ) //self = zombie.body
{
    level endon( "game_ended" );
    self endon( "zombie_death" );
    
    while( IsDefined( self ) )
    {
        foreach( player in level.players )
        {
            if( Distance( self.origin, player.origin ) < 70 && IsAlive( player ) && BulletTracePassed( self.origin, player.origin, false, self ) )
            {
                self.zombie_is_meleeing = true;
                zombie.knife show();
                self ScriptModelPlayAnim( "pt_melee_pistol_1" );
                wait .15;
                if( Distance( self.origin, player.origin ) < 70 && BulletTracePassed( self.origin, player.origin, false, self ) ) //Double check so we dont get damaged and moved if we arent in range
                {
                    self playSound("melee_knife_stab");
                    playFx(level.bodyshot_blood, self.origin + (0,0,30));
                    player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper( self, self, 35, 0, "MOD_MELEE", "none", player.origin, player.origin, "none", 0, 0 );
                    forward = anglesToForward(self.angles);
                    player setVelocity((forward[0]*300, forward[1]*300, 70));
                }
                wait .4;
                zombie.knife hide();
                self ScriptModelPlayAnim( get_walking_anim() );
                self.zombie_is_meleeing = undefined;
                wait .3;
            }
        }
        wait .15;
    }
}
    
/*** 
    AI PATHING
              ***/

start_ai_pathing( zombies ) //self = zombie.body
{
    level endon( "game_ended" );
    self endon( "zombie_death" );
    
    while( IsDefined( self ) )
    {
        if(!IsDefined( self.zombie_is_meleeing ))
        {
            point = self get_best_ai_path();
            if(IsDefined( point ))
            {
                if( IsDefined( self.zombie_anim ) && self.zombie_anim != "walk" )
                {
                    self ScriptModelPlayAnim( get_walking_anim() );
                    self.zombie_anim = undefined;
                }
                
                time   = calcDistance( level.zombies_speed, self.origin, point );
                ground = get_ground_position( self.origin, "com_plasticcase_friendly" );
                
                vec = vectorToAngles( self getTagOrigin( @"j_head" ) - (point + (0,0,50)) );
                self rotateTo( (0,vec[1] + 180,0), .1 );
                self.origin = (self.origin[0], self.origin[1], ground[2]);
                self MoveTo( (point[0], point[1], self.origin[2]), time );
                
                closest = [];
                closest[0] = self.origin;
                foreach( zombie in level.ai_zombies ) //STOPS THE ZOMBIES FROM COLLIDING
                {
                    if( Distance2D( self.origin, zombie.body.origin ) < 22 && self != zombie.body && IsDefined( zombie.collision ))
                    {
                        closest[closest.size] = zombie.body.origin;
                        if( get_Closest(point, closest) != self.origin ) 
                            self MoveTo( self.origin, .1 );
                    }
                }
                wait .1;
            }
            else 
            {
                self.zombie_anim = "idle";
                self ScriptModelPlayAnim( "pb_stand_alert" );
                self MoveTo( self.origin, .1 );
            }
        }
        wait .05;
    }
}

track_ai_pathing()
{
    level endon( "game_ended" );
    self endon("disconnect");
    
    self.store_paths = [];
    self.store_paths[self.store_paths.size] = self.origin;
    
    dist = 200;
    for(;;)
    {
        while( IsAlive( self ) )
        {
            for( node = self.store_paths.size; node > -1; node-- ) 
            {
                foreach( path in self.store_paths )
                    if( Distance( path, self.origin ) < dist )
                        break 2;
                if( Distance( self.store_paths[node], self.origin ) > dist && self IsOnGround() )
                {
                    self.store_paths[self.store_paths.size] = self.origin;
                    wait .1;
                    if( self.store_paths.size > 200 )
                    {
                        self.store_paths[node] = undefined;
                        self.store_paths = resortArray( self.store_paths );
                    }
                }
            }
            wait .05;
        }
        wait .05;
    }
}

/* Start Debugging 
if( !IsDefined( closest[1] ) )
    closest[1] = (0,0,0);
return_closest = get_Closest( self.origin, closest );
IPrintLn( closest[0], " ", closest[1], " closest: ", return_closest, " person: ", get_player_from_path_origin( return_closest ).name);
   End Debugging */

get_best_ai_path() 
{
    self endon( "zombie_death" );
    closest = [];
    foreach( player in level.players )
    {
        if( IsAlive( player ) )
        {
            temp  = []; 
            paths = player.store_paths;
            
            for( pointA = 0; pointA < paths.size; pointA++ ) 
            {
                if( BulletTracePassed(self.origin + (0,0,90), paths[ pointA ] + (0,0,90), false, self) )
                    temp[ temp.size ] = paths[ pointA ];
            }
            if(BulletTracePassed(self.origin + (0,0,90), player.origin + (0,0,90), false, self)) //TO GO TO PLAYER INSTEAD OF NODES IF PLAYER IS IN VIEW
                temp[ temp.size ] = player.origin;
            if( temp.size > 0 )
                closest[ closest.size ] = getClosest( player.origin, temp );  
        }
    }   

    if( closest.size > 0 )
        return get_Closest( self.origin, closest );  
    return undefined;    
}

/***
    AI ANIMATIONS
                 ***/

get_random_death_anim()
{
    types = ["pb_stand_death_leg_kickup", "pb_stand_death_shoulderback", "pb_death_run_stumble", "pb_stand_death_head_straight_back" ];
    return types[ RandomInt( types.size ) ];
}

get_walking_anim()
{
    if( level.zombies_speed <= 170 )
        return "pb_walk_forward_shield";
    if( level.zombies_speed > 170 && level.zombies_speed < 250 )
        return "pb_sprint_shield";
    else    
        return "pb_sprint_akimbo";
}
    
zombie_timeout_monitor( zombie )
{
    level endon( "disconnect" );
    zombie.body endon( "zombie_death" );
    
    while( IsDefined( self ) )
    {
        count = 0;
        for(e=0;e<30;e++) //3 Second wait 
        {
            origin = self.origin;
            wait .1;
            if( origin == self.origin )
                count++;
        }
        if( count >= 30 )
            thread kill_zombie( zombie );
        wait .1;
    }
}

kill_zombie( zombie )
{
    level endon( "disconnect" );
    
    if( IsDefined( zombie.collision ) )
    {
        zombie.body notify( "zombie_death" );
        
        zombie.collision delete();
        zombie.knife delete();
        
        zombie.body MoveTo( zombie.body.origin, .1 ); //STOPS THE ZOMBIE FROM MOVING WHILE DOING THE ANIMATION
        zombie.body ScriptModelPlayAnim( get_random_death_anim() );
        
        level.spawned_zombies--;
        if(IsDefined( zombie.body.zombie_is_meleeing ))
            zombie.body.zombie_is_meleeing = undefined;
        
        wait 6;
        
        zombie.body delete();
        zombie.head delete(); 
    }
}

//FRIENDLY AI 
ai_spawn_logic() 
{
    if( !IsDefined( level.ai_spawned ) )
        level.ai_spawned = [];
        
    points = self.player;
    origin = get_ground_position(points.origin - ( 144 + RandomInt( 192 ), 0, 0));
    model  = "mp_body_opforce_arab_assault_a";
    head   = "head_opforce_arab_a";
    
    ai          = SpawnStruct();
    ai.body = modelSpawner( origin, model );
    ai.head = modelSpawner( zombie.body GetTagOrigin( @"j_spine4" ), head, zombie.body GetTagAngles( @"j_head" ) );
    ai.head LinkTo( zombie.body, @"j_spine4" );
    
    ai.knife = modelSpawner( zombie.body getTagOrigin(@"tag_inhand"), "weapon_parabolic_knife", (0,0,0) );
    ai.knife linkto( zombie.body, @"tag_inhand" );
    ai.knife hide();
    
    ai.collision = modelSpawner( zombie.body GetTagOrigin( @"j_spinelower" ) - (0,0,3), "com_plasticcase_friendly", (270,270,0), undefined, level.airDropCrateCollision );
    ai.collision  LinkTo( zombie.body, @"j_neck" );
    ai.collision  hide();
    
    ai.collision SetCanDamage( true );
    ai.collision.health    = level.zombies_health;
    ai.collision.maxhealth = level.zombies_health;
    
    ai.collision thread zombie_damage_monitor( zombie );
    ai.collision thread zombie_timeout_monitor( zombie );
    ai.body thread start_ai_pathing( zombie );
    ai.body thread zombies_attack_monitor( zombie );
    
    ai.body ScriptModelPlayAnim( get_walking_anim() );
    
    level.ai_spawned[ level.ai_spawned.size ] = ai;
}
