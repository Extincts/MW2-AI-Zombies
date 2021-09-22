giveWeap( result, camo, dual, ignore, justSpawned )
{
    if( isDefined( camo ) )
        self.savedCamo = camo;
        
    finalCamo = 0;    
    if( isDefined( self.savedCamo ) )
        finalCamo = self.savedCamo;
     
    if( !isDefined( result ) )
        result = self GetCurrentWeapon();
        
    if( self hasWeapon( result ) && !isdefined( ignore ) )
        return self switchToWeapon( result );
    
    if( self getWeaponsListPrimaries().size >= 2 || isDefined( camo ) )
        self takeWeapon( self getCurrentWeapon() );
    
    self giveWeapon( result, finalCamo, isInArray( getWeaponAttachments( result ), "akimbo" ) );
    if( IsDefined( justSpawned ) )
        self setSpawnWeapon( result );
    else 
        self switchToWeapon( result );
}

/***    
    START OF WEAPON ATTACHMENTS    
                               ***/

giveAttachment( attachment )
{
    weap = self getCurrentWeapon();
    base = getWeapBaseName( weap );
    
    attachments = getWeaponAttachments( weap );
    camo        = 0;
    
    if( attachments.size >= 2 )
        return self iprintln("^1Error^7: You have exceeded the maximum number of attachments.");
    else if( attachments.size == 1 )
        weapon = self buildWeaponName( base, attachments[0], attachment );
    else 
        weapon = self buildWeaponName( base, attachment, "none" );
    
    if( weapon == base + "_mp" )
        return self iprintln("^1Error^7: Weapon attachment is not supported.");
    
    if( attachments.size > 0 )
        weapon = self buildWeaponName( base, attachments[0], attachment, camo );
    else 
        weapon = self buildWeaponName( base, attachment, "none", camo );
        
    stock = self getWeaponAmmoStock( weap );
    clip  = self getWeaponAmmoClip( weap );
    self takeWeapon( weap );
    
    self giveWeap( weapon, camo, isInArray( getWeaponAttachments( weapon ), "akimbo" ) );
    self setWeaponAmmoStock( weapon, stock );
    self setWeaponAmmoClip( weapon, clip );
    self switchToWeapon( weapon );    
}

weaponHasAttachment( weap, attachment )
{
    if( IsSubStr( weap, attachment ) )
        return true;
    return false;    
}

getWeapBaseName( weap )
{
    for(e=0;e<level.weapons.size;e++)
    {
        foreach( weapon in level.weapons[e] )
        {
            if( IsSubStr( weap, weapon ) )
                return weapon;
        }
    }
}
    
/***
    END OF WEAPON ATTACHMENTS   
                             ***/

findWeaponArray( weapon )
{
    for(e=0;e<self getWeaponsListPrimaries().size;e++)
    {
        if( IsSubStr( self getWeaponsListPrimaries()[e], getWeapBaseName( weapon ) ))
            return self getWeaponsListPrimaries()[e];
    }
    return self getWeaponsListPrimaries()[ self getWeaponsListPrimaries().size -1 ];
} 
