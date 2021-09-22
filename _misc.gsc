increaseEntitySpace()
{
    array     = [];
    arrayEnts = strtok("script_origin,script_model", ","); //script_model
    for(e = 0; e < arrayEnts.size; e++)
        array[e] = getEntArray(arrayEnts[e], "classname");
    for(e = 0; e < arrayEnts.size; e++)   
        foreach( ent in array[e] )
            if( ent.model != "com_plasticcase_friendly" )
                ent delete();
}
            
get_ground_position( origin, ignore )
{
    ground = BulletTrace( origin + ( 0, 0, 50 ), origin + ( 0, 0, -100 ), false, false );
    if( IsDefined( ignore ) && ground["entity"].model == ignore || IsDefined( ignore ) && IsAlive( ground["entity"] ) )
        ground = BulletTrace( origin + ( 0, 0, 50 ), origin + ( 0, 0, -100 ), false, ground["entity"] );  
    return ground["position"];
} 

getClosest( origin, array )
{
    closestEnt       = array[0];
    smallestDistance = distance(array[0].origin, origin);

    for(e=1;e<array.size;e++)
    {
        if(distance(array[e].origin,origin) < smallestDistance)
        {
            smallestDistance = distance(array[e].origin, origin);
            closestEnt       = array[e];
        }
    }
    return closestEnt;
}

get_Closest( origin, array )
{
    closestEnt       = array[0];
    smallestDistance = distance(array[0], origin);

    for(e=1;e<array.size;e++)
    {
        if(distance(array[e],origin) < smallestDistance)
        {
            smallestDistance = distance(array[e], origin);
            closestEnt       = array[e];
        }
    }
    return closestEnt;
}

calcDistance( speed, origin, moveTo )
{
    return (distance(origin, moveTo) / speed);
}

resortArray( array )
{
    tempArray = [];
    for(e=0;e<array.size;e++)
        if(isDefined(array[e]))
            tempArray[tempArray.size] = array[e];
    return tempArray;
}

get_zombie_count()
{
    return level.spawned_zombies;        
}

get_player_from_path_origin( origin )
{
    foreach( player in level.players )
    {
        if( isInArray(player.store_paths, origin) )
            return player;
    }
    return undefined;
}