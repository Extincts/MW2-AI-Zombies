can_purchase( price, noSale )
{
    if( isDefined( level.megasale ) && self.points >= 10 && !IsDefined( noSale ) )
        return true;
    else if( self.points >= price )
        return true;
    return false;    
}

mystry_box( location, forwardvector )
{
    box = spawnstruct();
    box.crates = [];
    
    box.crates[0] = modelSpawner( (location + ((cos(forwardvector[0]), sin(forwardvector[0]), 1) * (-25,-25,0))), "com_plasticcase_friendly", ( forwardvector - (0,90,0) ), undefined, level.airDropCrateCollision );
    box.crates[1] = modelSpawner( (location + ((cos(forwardvector[0]), sin(forwardvector[0]), 1) * (25,25,0))), "com_plasticcase_friendly", ( forwardvector - (0,90,0) ), undefined, level.airDropCrateCollision );
    box.crates[2] = modelSpawner( (location + ((cos(forwardvector[0]), sin(forwardvector[0]), 1) * (-25,-25,12.5))), "com_plasticcase_friendly", ( forwardvector - (0,90,0) ), undefined, level.airDropCrateCollision );
    box.crates[3] = modelSpawner( (location + ((cos(forwardvector[0]), sin(forwardvector[0]), 1) * (25,25,12.5))), "com_plasticcase_friendly", ( forwardvector - (0,90,0) ), undefined, level.airDropCrateCollision );
    
    box.forwardvector = forwardvector;
    box.location      = location;
    box.inuse         = false; 
    
    foreach( crate in box.crates )
    {
        crate SetModel("com_plasticcase_friendly");
        crate.angles = ( forwardvector - (0,90,0) );
    }
    
    foreach( player in level.players )
        box.crates[0] thread mystry_box_trigger( player );
        
    level.thebox = box; 
}

mystry_box_trigger( player ) 
{
    while( IsDefined( self ) )
    {
        while( Distance( player.origin, level.thebox.location ) < 128 && isAlive( player ) && !level.thebox.inuse && bullettracepassed( level.thebox.location, player GetEye(), 0, level.thebox.crates[2] ))
        {
            player thread doHintString( "Hold [{+usereload}] for mystery box (Cost: 950)", level.thebox.location, 128 );
            if( player useButtonPressed() && player can_purchase( 950 ) )
            {
                wait .25;
                if( !player usebuttonpressed() )
                    break;
                level.thebox.inuse = true;
                player.hintString destroy();
                player update_points( -950 );
                player thread do_mystry_box();
            }
            wait .05;
        }
        wait .05;
    }
}

do_mystry_box()
{
    theboxweapon = modelSpawner( level.thebox.location + (0,0,12.5), "", level.thebox.forwardvector - (0,90,0));
    level.thebox.crates[2] MoveTo( level.thebox.crates[2] GetOrigin() + ((cos(level.thebox.forwardvector[0]) * -35),(sin(level.thebox.forwardvector[0]) * -35),0), .4);
    level.thebox.crates[3] MoveTo( level.thebox.crates[3] GetOrigin() + ((cos(level.thebox.forwardvector[0]) * 35),(sin(level.thebox.forwardvector[0]) * 35),0), .4);
    theboxweapon MoveZ( 25, 5 );
    
    weapon    = "";
    oldWeapon = self GetCurrentWeapon();
    for( i = 0; i < 23; i++ )
    {
        wait .2;
        while( weapon == oldWeapon || self HasWeapon( weapon ) )
        {
            ary    = RandomInt( level.weapons.size );
            val    = RandomInt( level.weapons[ ary ].size );
            weapon = level.weapons[ ary ][ val ] + "_mp";
            wait .05;
        }
        oldWeapon = weapon;
        theboxweapon SetModel( getWeaponModel( weapon ) ); 
    }
    theboxweapon MoveZ( -25, 10 );
    
    for(time=0;time<100;time++)
    { 
        if( Distance( self.origin, level.thebox.location ) < 128 && isAlive( self ) && bullettracepassed( level.thebox.location, self GetEye(), 0, level.thebox.crates[2] ))
        {
            self thread doHintString( "Hold [{+usereload}] for weapon", level.thebox.location, 128 );
            if( self UseButtonPressed() )
            {
                wait .25;
                if( self UseButtonPressed() )
                {
                    self giveWeap( weapon );   
                    break 3;
                }
            }
        }
        wait .1;
    }
    
    level.thebox.crates[2] MoveTo( level.thebox.crates[2].origin - ((cos(level.thebox.forwardvector[0]) * -35),(sin(level.thebox.forwardvector[0]) * -35),0), .4);
    level.thebox.crates[3] MoveTo( level.thebox.crates[3].origin - ((cos(level.thebox.forwardvector[0]) * 35),(sin(level.thebox.forwardvector[0]) * 35),0), .4);
    theboxweapon delete();
    wait .5;
    level.thebox.inuse = false;
}

power_up_box( location, forwardvector )
{
    power_up        = spawnstruct();
    power_up.crates = [];
    
    power_up.crates[0] = modelSpawner( (location + ((cos(forwardvector[0]), sin(forwardvector[0]), 1) * (0,0,17))), "com_plasticcase_friendly", ( forwardvector - (0,90,0) ), undefined, level.airDropCrateCollision );
    power_up.crates[1] = modelSpawner( (location + ((cos(forwardvector[0]), sin(forwardvector[0]), 1) * (0,0,40))), "com_plasticcase_friendly", ( forwardvector - (0,90,0) ), undefined, level.airDropCrateCollision );

    power_up.forwardvector = forwardvector;
    power_up.location      = location + (0,0,20);
    power_up.inuse         = false; 
    
    foreach( crate in power_up.crates )
        crate.angles = ( forwardvector - (0,90,0) );
    
    foreach( player in level.players )
        power_up.crates[0] thread power_up_box_trigger( player );
        
    level.power_up_box = power_up; 
}

power_up_box_trigger( player ) 
{
    while( IsDefined( self ) )
    { 
        while( Distance( player.origin, level.power_up_box.location ) < 80 && isAlive( player ) && !level.power_up_box.inuse )
        {
            player thread doHintString( "Hold [{+usereload}] for mystery power up (Cost: 2000)", level.power_up_box.location, 80 );
            if( player useButtonPressed() && player can_purchase( 2000, true ) )
            {
                wait .25;
                if( !player usebuttonpressed() )
                    break;
                level.power_up_box.inuse = true;
                player.hintString destroy();
                player update_points( -2000, true );
                player thread do_power_up_box();
            }
            wait .05;
        }
        wait .05;
    }
}

do_power_up_box()
{
    power_up = drop_powerup( level.power_up_box.location - (0,0,30) );
    level.power_up_box.crates[1] MoveTo( level.power_up_box.crates[1] GetOrigin() + (0,0,40), .4);
    power_up MoveZ( 15, .4 );
    wait .5;
    while( IsDefined( power_up  ) )
        wait .05;
    level.power_up_box.crates[1] MoveTo( level.power_up_box.crates[1] GetOrigin() - (0,0,40), .4);
    wait .5;
    level.power_up_box.inuse = false;
    self.hintString destroy();
}

doHintString( message, dist, range )
{
    if(isDefined(self.hintString)) 
        self.hintString destroy();
    self.hintString = createText("objective", 1, "BOTTOM", "BOTTOM", 0, 0, 3, 1, message, (1, 1, 1));   
    
    if( !IsDefined( dist ) )
        dist = self.origin;
    while( IsDefined( self.hintString ) )
    {
        if( distance( dist, self.origin ) > range )
            self.hintString destroy();
        wait .05;
    }
}