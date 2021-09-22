// self playLocalSound( "mp_suitcase_pickup" ); scavenger_pack_pickup
// ammo_crate_use
insta_kill()
{
    level notify("insta_kill");
    level endon("insta_kill");
    
    level.instaKill = true;
    wait 29;
    level remove_power_up( "Insta Kill" );
    level.instaKill = undefined;
}

double_points()
{
    level notify("double_points");
    level endon("double_points");
    
    level.double_points = true;
    wait 29; 
    level remove_power_up( "Double Points" );
    level.double_points = undefined;
}

max_ammo()
{
    IPrintLnBold( "Max Ammo!" );
    foreach( player in level.players )
    {
        weaponList = player GetWeaponsListAll();
        foreach( weaponName in weaponList )
        {        
            if ( isSubStr( weaponName, "grenade" ) )
            {
                if ( player getAmmoCount( weaponName ) >= 1 )
                    continue;
            } 
            player giveMaxAmmo( weaponName );
        }
        player playLocalSound( "ammo_crate_use" );
    }
}

nuke_all( ignore )
{
    if( !IsDefined( ignore ) )
        IPrintLnBold( "KABOOM!" );
    level.zombies_nuked = true;    
    fadetowhite         = createRectangle("CENTER", "CENTER", 0, 0, 999, 999, (1,1,1), "white", 0, 0, true);
    earned_points       = RandomIntRange( 250, 500 );
    foreach( player in level.players )
    {
        player thread update_points( earned_points ); 
        player playlocalsound( "nuke_explosion" );
        player playlocalsound( "nuke_wave" );
    }   
    foreach( zombie in level.ai_zombies )
        level thread kill_zombie( zombie );
    
    fadetowhite fadeovertime( 0.2 );
    fadetowhite.alpha = 0.8;    
    wait 0.5;
    fadetowhite fadeovertime( 1 );
    fadetowhite.alpha = 0;
    wait 1.1;
    fadetowhite destroy();
    wait 3;
    level.zombies_nuked = undefined;
}

mega_sale()
{
    level notify("mega_sale");
    level endon("mega_sale");
    
    level.megasale = true;
    wait 29;
    level remove_power_up( "Mega Sale" );
    level.megasale = undefined;
}

drop_powerup( origin )
{ 
    drops  = [];
    drops[0] = [::insta_kill, "Insta Kill", "head_riot_op_arab" ];
    drops[1] = [::nuke_all, "Skip", "projectile_rpg7" ];
    drops[2] = [::double_points, "Double Points", "prop_suitcase_bomb" ];
    drops[3] = [::max_ammo, "Skip", "bc_ammo_box_762" ]; 
    drops[4] = [::mega_sale, "Mega Sale", "tv_video_monitor" ];
    
    random = RandomInt( drops.size );
    id     = drops[random][0];
    name   = drops[random][1];
    model  = drops[random][2]; 
    
    powerup = modelSpawner( origin + (0,0,40), model );
    fx      = SpawnFx( loadFX("misc/flare_ambient_green"), powerup.origin );
    TriggerFX( fx );
    
    powerup thread monitor_powerup_dropped( name, id, fx );
    powerup thread powerup_wobble();
    powerup thread powerup_timeout( fx );
    return powerup;
}

powerup_wobble()
{
    while ( isDefined( self ) )
    {
        waittime = randomfloatrange( 2.5, 5 );
        yaw = randomint( 360 );
        if ( yaw > 300 )
            yaw = 300;
        else
        {
            if ( yaw < 60 )
                yaw = 60;
        }
        yaw = self.angles[ 1 ] + yaw;
        new_angles = ( -60 + randomint( 120 ), yaw, -45 + randomint( 90 ) );
        self rotateto( new_angles, waittime, waittime * 0.5, waittime * 0.5 );
        wait randomfloat( waittime - 0.1 );
    }
}

monitor_powerup_dropped( name, id, fx )
{
    while( IsDefined( self ) )
    {
        foreach( player in level.players )
        { 
            if( Distance2D( player.origin, self.origin ) < 60 )
            {
                player playLocalSound( "mp_suitcase_pickup" );
                if( name == "Skip" )
                    level thread add_power_up( name, id, true );
                else 
                    level thread add_power_up( name, id );
                fx Delete();    
                return self Delete();
            }
        }
        wait .1;
    }
}

powerup_timeout( fx )
{
    self endon("death");
    for(e=0;e<20;e++)
        wait 1;
    
    for(e=0;e<8;e++)
    {
        self hide();
        wait .2;
        self Show();
        wait .2;
    }
    
    fx Delete();
    self Delete();
}

add_power_up( name, id, skip ) //::instaKill
{
    if( !IsDefined( level.power_ups ) )     
        level.power_ups = [];
    
    foreach( powerUp in level.power_ups )
        if( powerUp.text == name )
            drawn = true;
            
    if( !IsDefined( drawn ) && !IsDefined( skip ) )        
        level.power_ups[ level.power_ups.size ] = createText("small", 1.4, "RIGHT", "TOPRIGHT", 0, (level.power_ups.size * 15), 1, 1, name, (1,1,1), true); //+15 spacing
    level thread [[ id ]]();
}

remove_power_up( name )
{
    foreach( powerUp in level.power_ups )
    {
        if( powerUp.text == name )
        {
            powerUp hudFlash( 3 );
            powerUp destroy();
            level.power_ups = resortArray( level.power_ups );
        }
    }
    level thread resort_power_ups();
}

resort_power_ups()
{
    for(e=0;e<level.power_ups.size;e++)
        if( IsDefined( level.power_ups[e] ) )
            level.power_ups[e].y = (e * 15);
}