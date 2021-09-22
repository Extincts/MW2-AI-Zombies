loadarrays()
{
    level.weapons = [];
    level.weapons[0] = strTok( "fal;m4;m16;famas;scar;ak47;aug;masada;fn2000", ";" ); //Assault Rifles
    level.weapons[1] = StrTok( "uzi;ump45;mp5k;p90;tavor;kriss", ";" ); //Submachine Guns
    level.weapons[2] = StrTok( "model1887;aa12;ranger;spas12;m1014", ";" ); //Shotguns
    level.weapons[3] = StrTok( "m240;rpd;sa80;mg4", ";" ); //Light Machine Guns
    level.weapons[4] = StrTok( "m21;cheytac;wa2000;barrett", ";" ); //Sniper Rifles
    level.weapons[5] = StrTok( "at4;rpg;javelin;stinger;m79", ";" ); //Launchers
    level.weapons[6] = StrTok( "beretta;coltanaconda;usp;deserteagle", ";" ); //Pistols
    level.weapons[7] = StrTok( "pp2000;glock;tmp", ";" ); //Auto Pistols
    
    level.attachments     = strtok( "acog;grip;gl;tactical;reflex;silencer;akimbo;thermal;shotgun;heartbeat;fmj;rof;dtap;xmags;mags;eotech",";" );
    level.attachmentNames = StrTok( "Acog;Grip;Grenade Launcher;Tactical;Reflex;Silencer;Akimbo;Thermal;Shotgun;Heartbeat;Fmj;Rapid Fire;Dtap;Extended Mags;Fast Mags;Eotech", ";" );
}

returnDisplayName( name, contains, altContains )
{
    if( isDefined(altContains) && !IsSubStr( name, contains ) )
        contains = altContains;
    if( IsSubStr( name, contains ) )
    {
        for(e = name.size - 1; e >= 0; e--)
            if(name[e] == contains[contains.size-1])
                break;
        return(getSubStr(name, e + 1));        
    }
    return name;
}