update_points( points, noSale )
{
    if(IsDefined( self.points_hud ))   
        self.points_hud destroy();
    
    //Double Points 
    if( IsDefined( level.double_points ) && points > 0 )
        points += points;
    //Mega Sale 
    if( IsDefined( level.megasale ) && points < 0 && !IsDefined( noSale ) )
        points = -10;
        
    self.points += points; 
    self.score            = self.points;
    self.points_hud       = createText("small", 1.4, "RIGHT", "TOPLEFT", 0, 0, 1, 1, undefined, (1,1,1));
    self.points_hud.label = &"$";
    self.points_hud SetValue( self.points );
    self thread points_anim( points );
}

points_anim( points )
{
    if( !IsDefined( self.points_amount ) )
        self.points_amount = [];
    if( self.points_amount.size > 4 )
    {
        self.points_amount[0] destroy();
        self.points_amount = resortArray( self.points_amount );
    }
    
    self.points_amount[ self.points_amount.size ] = createText("small", 1.1, "LEFT", "TOPLEFT", 6, 0, 1, 1, undefined, (1,1,1));  
    
    size = self.points_amount.size - 1;
    self.points_amount[ size ].label = "";    
    
    colour = (1,1,0);
    if( points < 0 )
    {
        colour = (1,0,0);
        self.points_amount[ size ].label = &"-";
    }
    else
        self.points_amount[ size ].label = &"+";
    self.points_amount[ size ].color = colour;
    self.points_amount[ size ] setValue( abs( points ) );
    
    self.points_amount[ size ] fadeovertime(.25);
    self.points_amount[ size ].alpha = 0;
    
    self.points_amount[ size ] moveovertime(.25);
    self.points_amount[ size ].y += RandomIntRange( -30, 30 );
    self.points_amount[ size ].x += RandomIntRange( 10, 20 );
    
    wait .25;
    self.points_amount[ size ] destroy();
}

update_rounds()
{
    if(!IsDefined( level.rounds_hud ))
        level.rounds_hud = level createText("small", 3, "RIGHT", "BOTTOMLEFT", 0, -6, 1, 1, undefined, (1,1,1), true);
    level.rounds_hud setValue( level.round );
    
    foreach( player in level.players )
        player playLocalSound( "mp_challenge_complete" ); //mp_challenge_complete mp_level_up
    
    for(e=0;e<5;e++)
    {
        level.rounds_hud fadeovertime(.75);
        level.rounds_hud.color = (1,1,1);
        wait .75;
        level.rounds_hud fadeovertime(.75);
        level.rounds_hud.color = (1,0,0);
        wait .75;
    }
    level.rounds_hud fadeovertime( .25 );
    level.rounds_hud.color = (.5,0,0);
    wait .3;
}

player_weapon_hud()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    
    self.weapon_huds = [];
    self.weapon_huds[0] = createText("small", 1.4, "RIGHT", "BOTTOMRIGHT", 0, -15, 1, 1, "", (1,1,1)); //weapon name
    self.weapon_huds[1] = createText("small", 1.4, "RIGHT", "BOTTOMRIGHT", 0, 0, 1, 1, "", (1,1,1)); //weapon ammo 
    self.weapon_huds[2] = createRectangle("LEFT", "BOTTOMLEFT", 10, -1, 15, 15, (1,1,1), "hud_grenadeicon", 1, 1);
    self.weapon_huds[3] = createRectangle("LEFT", "BOTTOMLEFT", 28, -1, 15, 15, (1,1,1), "hud_grenadeicon", 1, 1);
    
    for(;;)
    {
        while( !IsAlive( self ) )
            wait .05;
        
        weapon    = self getCurrentWeapon();
        clipRight = self getWeaponAmmoClip( weapon, "right" );
        clipLeft  = self getWeaponAmmoClip( weapon, "left" );
        stock     = self getWeaponAmmoStock( weapon );
        offhand   = self getWeaponAmmoStock( "frag_grenade_mp" ); 

        for(e=2;e<4;e++)
        {
            self.weapon_huds[e].alpha = 0;
            if( offhand == (e-1) )
                self.weapon_huds[e].alpha = 1;
        }   
            
        self.weapon_huds[0] setSafeText( returnWeaponName( weapon ) ); 
        if( isInArray( getWeaponAttachments( weapon ), "akimbo" ) )
            self.weapon_huds[1] setSafeText( clipLeft + " | " + clipRight + " / " + stock );
        else 
            self.weapon_huds[1] setSafeText( clipRight + " / " + stock );
            
        if( self IsSwitchingWeapon() )
        {
            self.weapon_huds[0] thread hudFade( 0, .3 );
            self.weapon_huds[1] thread hudFade( 0, .3 );
            while( self IsSwitchingWeapon() )
                wait .05;
            self.weapon_huds[0] thread hudFade( 1, .2 );
            self.weapon_huds[1] thread hudFade( 1, .2 );
        }
            
        wait .1;
    }
} 

returnWeaponName( weaponId )
{
    return tableLookupIString("mp/statstable.csv", 0, int( tableLookup("mp/statstable.csv", 4, strTok( weaponId, "_" )[0], 0) ), 3);
}

wait_until_all_connected()
{
    black = level createRectangle( "CENTER", "CENTER", 0, 0, 999, 999, (0,0,0), "white", 10, 1, true );
    text  = level createText( "small", 1.6, "CENTER", "CENTER", 0, 0, 11, 1, "waiting for players to connect", (1,1,1), true );
    
    connected = 0;
    timeout   = 0;
    for(;;)
    {
        timeout++;
        if( level.players.size != connected )
        {
            timeout = 0;
            connected++;
        }
        if( timeout > 10 )
            break;
        wait .5;
    }
    black thread hudFadeDestroy( 0, .3 );
    text thread hudFadeDestroy( 0, .3 );
} 

cc( text )
{
    if ( !isdefined( level.cc ) )
    {
        level.cc = spawnstruct();
        level.cc.line = 0;
    }

    subtitle = newHudElem();
    subtitle.x = 0;
    subtitle.y = -80 + ( level.cc.line * 14 );
    subtitle setSafeText( text ); 
    subtitle.fontScale = 1.46;
    subtitle.alignX = "center";
    subtitle.alignY = "middle";
    subtitle.horzAlign = "center";
    subtitle.vertAlign = "bottom";
    subtitle.sort = 1;
    subtitle.dbtext = text;

    my_line = level.cc.line;
    subtitle thread cc_move( my_line );

    level.cc.line++;
    waittime = ( ( text.size + 1 ) / 50 ) + 2;
    wait waittime;

    subtitle FadeOverTime( .5 );
    subtitle.alpha = 0;
    level.cc.line--;
    wait .5;

    level.cc notify( "move", my_line );
    subtitle notify( "destoyed" );
    subtitle destroy();
}

cc_move( my_line )
{
    self endon( "destoyed" );
    while( true )
    {
        level.cc waittill( "move", line );
        if ( line > my_line || my_line == 0 )
            continue;
        self MoveOverTime(.5);
        self.y = self.y - 14;
        my_line--;
    }
}
