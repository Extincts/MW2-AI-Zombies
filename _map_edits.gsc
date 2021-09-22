remove_deathBarriers()
{
    ents = getEntArray();
    for(index=0;index<ents.size;index++)
        if(isSubStr(ents[index].classname, "trigger_hurt"))
            ents[index].origin = (0,0,9999999);
}

spawn_map_edits()
{
    bushes = [ -2291.09, -437.309, -1456, -2361.17, -441.051, -1456, -2423.99, -438.552, -1456, -2495.32, -440.32, -1456, -2570.46, -440.622, -1456, -2825.41, -522.983,
    -1455.83, -2868.65, -561.404, -1455.63, -2955.35, -569.69, -1456, -2993.67, -624.621, -1456.42, -3023.71, -734.628, -1456.56, -3004.18, -795.648, -1456.34, 
    -2988.21, -846.106, -1456.15, -2984.52, -925.511, -1456.1, -2974.29, -994.817, -1456.63, -2325.89, -352.292, -1456, -2341.98, -260.585, -1456.02, -2371.95, -187.768, -1456,
    -2377.15, -98.1612, -1456, -2321.24, -28.2292, -1456, -2256.86, -8.3612, -1456, -2174.36, -17.0424, -1456, -2611.75, -331.117, -1456, -2571.36, -388.122, -1456,
    -2919.44, -571.994, -1446.91, -2972.17, -617.013, -1455.9, -3014.66, -681.484, -1454.54, -2995.39, -926.919, -1453.17, -2967.8, -1002.41, -1454.35
    -2958.23, -1081.61, -1457.31, -2972.96, -1061.55, -1457.23, 1627.93, 381.058, 278.326, 1627.93, 381.058, 278.324, 1627.93, 381.058, 278.324, 1627.93, 381.058, 278.326,
    -2752.21, -484.252, -1456.01, -2839.93, -1106.29, -1456.86, -2963.31, -1017.81, -1456.78 ];
    
    level.bushes = [];
    for(e=0;e<(bushes.size / 3);e++)
        level.bushes[level.bushes.size] = modelSpawner( (bushes[3*e], bushes[(3*e) + 1], bushes[(3*e) + 2]), "foliage_cod5_tallgrass10b" );
    
    bushes = [ 2779.5, -487.771, -1449.35, -2736.56, -442.051, -1447.9, -2684.04, -410.013, -1446.67, -2782.92, -1182.24, -1456.73, -2851.79, -1177.58, -1453.75, -2910.7, -1154.92, -1451.09, 
    -2972.41, -1104.19, -1454.29, -2992.01, -1035.4, -1457.11, -3022.55, -972.031, -1404.62, -3026.58, -913.615, -1398.61, -3021.51, -858.152, -1396.84, -3031.06, -787.308, -1396.32, 
    -3054.55, -712.06, -1393.54, -3030.7, -643.946, -1390.5, -2982.58, -585.46, -1398.1, -2934.44, -551.657, -1397.59, -2883.5, -543.624, -1398.62, -2830.17, -521.661, -1396.27,
    -2805.2, -481.538, -1404.67, -2754.16, -445.621, -1406.56, -2579.54, -420.85, -1394.46, -2508.02, -412.721, -1399.73, -2436.46, -411.343, -1387.43, -2362.6, -416.688, -1388.99, 
    -2358.75, -356.871, -1386.61, -2345.63, -313.424, -1385.42, -2372.98, -236.934, -1391.71, -2389.59, -158.599, -1400.84, -2348.42, -71.4716, -1408.52, -2276.95, -4.24641, -1445.5,
    -2226.25, 7.09407, -1439.63, -2990.89, -1014.87, -1394.29, -2872.61, -525.131, -1454.66, -3055.55, -783.059, -1457.01, -3021.74, -631.176, -1355.25, -2374.78, -119.572, -1397.85,
    -2322.53, -48.6284, -1390.14, 1627.93, 381.058, 278.326, 1627.93, 381.058, 278.324 ];
    
    level.bushesA = [];
    for(e=0;e<(bushes.size / 3);e++)
        level.bushes[level.bushes.size] = modelSpawner( (bushes[3*e], bushes[(3*e) + 1], bushes[(3*e) + 2]), "foliage_cod5_tallgrass10a" );  
        
    bushtree       = [-2657.21, -456.75, -1456, -2936.83, -1074.43, -1457.14, -2761.67, -1097.28, -1456.31, -2864.05, -1105.44, -1456.99];
    
    level.bushtree = [];
    for(e=0;e<(bushtree.size / 3);e++)
        level.bushtree[level.bushtree.size] = modelSpawner( (bushtree[3*e], bushtree[(3*e) + 1], bushtree[(3*e) + 2]), "foliage_pacific_bushtree01_animated" );    

    level.barrier48x64 = [];
    for(e=0;e<23;e++) for(i=0;i<3;i++)
        level.barrier48x64[level.barrier48x64.size] = modelSpawner( (-1633 - (e*48), -1120, -1455 + (48*i)), "bc_hesco_barrier_med", undefined, undefined, level.airDropCrateCollision );   
    for(e=0;e<10;e++) for(i=0;i<2;i++)
        level.barrier48x64[level.barrier48x64.size] = modelSpawner( (-2380, -409 + (e*48), -1455 + (48*i)), "bc_hesco_barrier_med", undefined, undefined, level.airDropCrateCollision );   
            
    helifront = modelSpawner( (-2690.65, -1065.25, -1407.41), "vehicle_little_bird_dest_body2" );
    heliback  = modelSpawner( (-2569.1, -1060.7, -1409.36), "vehicle_little_bird_dest_body1" );
    helifire  = PlayLoopedFX( loadfx("props/barrelExp"), 2, (-2640.65, -1065.25, -1407.41));
    
    collisions = [-2734.38, -1123.24, -1456.39, -2778.89, -1128.43, -1456.7, -2826.26, -1128.75, -1456.98, -2874.86, -1128.61, -1455.6, -2929.5, -1135.08, -1457.65, -2969.22, -1090.01, -1457.47, 
    -2984.92, -1041.14, -1457.12, -2997.37, -987.126, -1456.7, -3004.49, -927.777, -1456.31, -3017.1, -877.935, -1455.54, -3019.16, -826.925, -1456.51, -3027.45, -802.942, -1456.61, 
    -3006.32, -758.949, -1456.36, -3005.77, -713.3, -1456.34, -3008.12, -670.672, -1456.36, -2986.99, -622.325, -1456.13, -2946.93, -586.616, -1456, -2909.45, -551.527, -1456, 
    -2861.47, -550.393, -1456, -2815.93, -521.464, -1456, -2814.84, -476.256, -1456.01, -2769.81, -445.058, -1455.64, -2730.58, -433.75, -1456, -2682.21, -450.661, -1455.99, 
    -2630.57, -451.637, -1456, -2587.64, -421.361, -1456, -2544.57, -425.073, -1456, -2500.78, -422.676, -1456, -2457.87, -422.729, -1455.99, -2415.27, -421.432, -1456.11, 
    -2372.32, -424.714, -1455.99, -2325.7, -429.801, -1455.93, -2282.14, -429.474, -1456, -2316.17, -379.009, -1456, -2347.27, -331.676, -1456, -2368.41, -286.367, -1456, 
    -2383.59, -241.657, -1456, -2399.86, -195.797, -1455.99, -2411.16, -150.11, -1455.03, -2401.04, -105.289, -1456.01, -2378.71, -92.5639, -1455.99, -2350.88, -60.941, -1456,
    -2295.6, -27.2936, -1456, -2249.85, -28.1786, -1456, -2205.76, -24.1503, -1456, -2162.14, -27.7192, -1456, -2115.65, -27.3431, -1456 ];
    
    level.collisions = [];
    for(e=0;e<(collisions.size / 3);e++)
        for(i=0;i<3;i++)
            level.collisions[level.collisions.size] = modelSpawner( (collisions[3*e], collisions[(3*e) + 1], collisions[(3*e) + 2] + (48*i)), "tag_origin", undefined, undefined, level.airDropCrateCollision );    

    level.global_lights = [];
    light_origins       = [ -2917.42, -972.414, -1456.01, -2962.64, -696.006, -1455.96, -2890.75, -614.751, -1455.96, -2628.29, -483.262, -1455.94, -2434.6, -487.528, -1455.94 ];
    for(e=0;e<(light_origins.size / 3);e++) 
        level.global_lights[level.global_lights.size] = modelSpawner( (light_origins[3*e], light_origins[(3*e) + 1], light_origins[(3*e) + 2]), "com_two_light_fixture_off", (vectorToAngles( (-2419, -796, -1455) - (light_origins[3*e], light_origins[(3*e) + 1], light_origins[(3*e) + 2]) ) + (0,90,0)) );    
    level.global_lights[level.global_lights.size] = modelSpawner( (-2142, -97, -1455), "com_two_light_fixture_off", (0, -15, 0) );    
    
    level.toolbox = modelSpawner( level.barrier48x64[0].origin + (0,10,150), "com_red_toolbox", (0,140,0) );
    level.toolbox thread toolbox_monitor();
}

do_smoke( amount, origin )
{
    afermathEnt = getEntArray( "mp_global_intermission", "classname" );
    afermathEnt = afermathEnt[0];
    up = anglestoup( afermathEnt.angles );
    right = anglestoright( afermathEnt.angles );
      
    if(!IsDefined( level.smoke_spawned ))
        level.smoke_spawned = [];
    for(e = 0; e < amount; e++)
    {
        level.smoke_spawned[ level.smoke_spawned.size ] = spawnFx( level._effect[ "nuke_aftermath" ], origin, up, right );
        triggerFx( level.smoke_spawned[ level.smoke_spawned.size -1 ] );
    }
}

modelSpawner(origin, model, angles, time, collision)
{
    if(isDefined(time))
        wait time;
    obj = spawn( "script_model", origin );
    obj setModel( model );
    if(isDefined( angles ))
        obj.angles = angles;
    if(isDefined( collision ))
        obj cloneBrushmodelToScriptmodel( collision );
    return obj;
}