//CINEMATICS
helicopter_fly_in()
{
    pathStart = (11171.1, 1135.87, 900); // CHANGE THIS
    pathGoal  = (-2690.65, -1065.25, 900);
    forward   = vectorToAngles( pathGoal - pathStart );
    lb        = spawnHelicopter( self, pathStart, forward, "littlebird_mp" , "vehicle_little_bird_armed" );
    
    level thread pulse_screen( 9 );
    level thread missile_barrage( lb );
    camera = modelSpawner( lb GetTagOrigin( "tag_driver" ) - (0,0,15) + AnglesToForward( lb.angles ) * -8, "tag_origin", lb GetTagAngles( "tag_driver" ) );
    camera LinkTo( lb, "tag_driver" );
    
    thread godmode();
    foreach( player in level.players )
    {
        player SetModel( "" );
        player SetStance( "crouch" );
        player PlayerLinkToAbsolute( camera, "tag_origin" );
    }

    lb SetMaxPitchRoll( 45, 45 );   
    lb Vehicle_SetSpeed( 60, 60 );
    
    totalDist = Distance2d( pathStart, pathGoal );
    midTime   = ( totalDist / 60 ) / 2 * .1 + 2.5;
    
    lb setVehGoalPos( pathGoal, 1 );
    setObjectiveHintText( "allies", "Survive The Zombie Outbreak!" );
    setObjectiveHintText( "axis", "Survive The Zombie Outbreak!" );
    
    wait( midTime - 1 );
    lb heliDestroyed();
    level thread flash_screen();
    foreach( player in level.players )
    {
        player SetStance( "prone" );
        player Unlink();
        player SetOrigin( (-1770, -900, -1455) );
        player changeAppearance( "SMG", self.team );
        player thread runDebugScripts(); 
    }
    level._intermission = true;
}

flash_screen()
{
    fadetowhite         = createRectangle("CENTER", "CENTER", 0, 0, 999, 999, (1,1,1), "white", 0, 0, true);
    foreach( player in level.players )
    {
        player playlocalsound( "nuke_explosion" );
        player playlocalsound( "nuke_wave" );
    }   
    
    fadetowhite fadeovertime( 0.2 );
    fadetowhite.alpha = 1;    
    wait 0.7;
    fadetowhite fadeovertime( 1.2 );
    fadetowhite.alpha = 0;
    wait 1.3;
    fadetowhite destroy();
} 

pulse_screen( amount )
{
    fadetoblack = createRectangle("CENTER", "CENTER", 0, 0, 999, 999, (0,0,0), "white", 0, 0, true);    
    for(e=0;e<amount;e++)
    {
        foreach( player in level.players )
            player playLocalSound( "breathing_hurt" );
        fadetoblack fadeovertime( 0.2 );
        fadetoblack.alpha = 1;    
        wait 0.7;
        fadetoblack fadeovertime( 1.2 );
        fadetoblack.alpha = 0;
        wait 1.3;
    }
    fadetoblack destroy();
}

missile_barrage( ent )
{
    while( IsDefined( ent ) )
    {
        x = randomIntRange( -200, 800 );
        y = randomIntRange( -200, 800 );
        z = randomIntRange( 200, 800 ); 
        r = RandomIntRange( -100, 1200 );
        MagicBullet("ac130_40mm_mp", ent.origin + AnglesToForward( ent.angles ) * r + (x, y, z), ent.origin + AnglesToForward( ent.angles ) * r + (x, y, -999) );
        wait .1;
    }
}

heliDestroyed()
{
    self endon( "gone" );
    
    if (!isDefined(self) )
        return;
        
    self Vehicle_SetSpeed( 25, 5 );
    self thread lbSpin( RandomIntRange(180, 220) );
    wait( RandomFloatRange( 3, 4 ) );
    
    lbExplode();
}

lbExplode()
{
    forward = ( self.origin + ( 0, 0, 1 ) ) - self.origin;
    playfx ( level.chopper_fx["explode"]["air_death"], self.origin, forward );

    deathAngles = self getTagAngles( "tag_deathfx" );       
    playFx( level.chopper_fx["explode"]["air_death"]["littlebird"], self getTagOrigin( "tag_deathfx" ), anglesToForward( deathAngles ), anglesToUp( deathAngles ) );
    
    self playSound( "cobra_helicopter_crash" );
    
    self delete();
}

lbSpin( speed )
{
    self endon( "explode" );
    
    // tail explosion that caused the spinning
    playfxontag( level.chopper_fx["explode"]["medium"], self, "tail_rotor_jnt" );
    self thread trail_fx( level.chopper_fx["smoke"]["trail"], "tail_rotor_jnt", "stop tail smoke" );
    
    self setyawspeed( speed, speed, speed );
    while ( isdefined( self ) )
    {
        self settargetyaw( self.angles[1]+(speed*0.9) );
        wait ( 1 );
    }
}

trail_fx( trail_fx, trail_tag, stop_notify )
{
    // only one instance allowed
    self notify( stop_notify );
    self endon( stop_notify );
    self endon( "death" );
        
    for ( ;; )
    {
        playfxontag( trail_fx, self, trail_tag );
        wait( 0.05 );
    }
}

godmode()
{
    while( !IsDefined( level._intermission ) )
    {
        foreach( player in level.players )
        {
            player.health    = 99999;
            player.maxhealth = 99999;
        }
        wait .05;
    }
    foreach( player in level.players )
    {
        player.health    = 100;
        player.maxhealth = 100;
    }
}

changeAppearance( kit, team )
{
    self DetachAll();
    if(isDefined( game[team+"_model"][ kit ] ))
        [[game[team+"_model"][ kit ]]]();
    self notify ( "changed_kit" );
}