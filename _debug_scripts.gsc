runDebugScripts()
{
    self thread debugInfo();
    self thread godmode();
    self thread infiniteAmmo( "reload" );
    //self thread createMapEdit();
    //self thread noClipExt();
}

debugInfo()
{
    info = createText("objective", 1, "LEFT", "LEFT", 50, -225, 3, 1, "", (1, 1, 1));   
    
    while(true)
    {
        /*info setSafeText( "ORIGINS:" + 
        "\n[0] " + self.origin[0] +
        "\n[1] " + self.origin[1] +
        "\n[2] " + self.origin[2] +
        "\nANGLES:" +
        "\n[0] " + self.angles[0] +
        "\n[1] " + self.angles[1] +
        "\n[2] " + self.angles[2]);
        wait .2;*/
        if( self UseButtonPressed() )
        {
            LogPrint( self.origin );
            wait .3;
        }
        
        wait .05;
    }
}

createMapEdit()
{
    ent   = modelSpawner( self.origin, "tag_origin" );
    count = 0;
    while( true )
    {
        if( self UseButtonPressed() )
        {
            spawned = modelSpawner( ent.origin, ent.model );
            LogPrint( spawned.origin );
            wait .2;
        }
        if( self AttackButtonPressed() )
        {
            ent SetModel( level.list[ count ] );
            count++;
            if( count > level.list.size )
                count = 0;
            IPrintLnBold( level.list[ count ] );   
        }
        
        ent moveTo(bulletTrace(self getEye(),self getEye() + vectorScale(anglesToforward(self getPlayerAngles()),240),false, ent)["position"],.1);
        wait .1;
    }
}
    
noClipExt()
{
    self endon("disconnect");
    self endon("game_ended");
    
    if(!isDefined( self.noclipBind ))
    {
        self.noclipBind = true;
        self IPrintLn( "Press [{+frag}] To Use NoClip" );
        while(isDefined( self.noclipBind ))
        {
            if(self fragButtonPressed())
            {
                if(!isDefined(self.noclipExt))
                    self thread doNoClipExt();
            }
            wait .05;
        }
    }
    else 
    {
        self IPrintLn( "Noclip: Disabled" );
        self.noclipBind = undefined;
    }
}

doNoClipExt()
{
    self endon("disconnect");
    self endon("noclip_end");
    self disableWeapons();
    self disableOffHandWeapons();
    clip = spawn("script_origin", self.origin);
    self playerLinkTo(clip);
    self.noclipExt = true;
    while(true)
    {
        vec = anglesToForward(self getPlayerAngles()); 
        end = (vec[0]*60,vec[1]*60,vec[2]*60);
        if(self attackButtonPressed()) clip.origin = clip.origin+end;
        if(self adsButtonPressed()) clip.origin = clip.origin-end;
        if(self meleeButtonPressed()) break;
        wait .05;
    }
    clip delete();
    self enableWeapons();
    self enableOffHandWeapons();
    self.noclipExt = undefined;
}

infiniteAmmo( reload )
{
    self endon("disconnect");
    level endon("game_ended");

    if( !isDefined( self.infAmmo ) )
    {
        self.infAmmo = true;
        while( isDefined( self.infAmmo ) )
        {
            weapon = self getcurrentweapon();
            if( weapon != "none" && reload == "reload" ) 
                self givemaxammo( weapon );
            else if( reload != "reload" ) 
                self setWeaponAmmoClip( weapon, weaponclipsize( weapon ));
            wait .05;
        }
    }
    else self.infAmmo = undefined;
}

vectorScale(vec, scale)
{
    return (vec[0] * scale, vec[1] * scale, vec[2] * scale);
}