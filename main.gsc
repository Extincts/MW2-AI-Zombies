#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include maps\mp\gametypes\_class;
#include maps\mp\killstreaks\_perkstreaks;
#include maps\mp\perks\_perkfunctions;
#include maps\mp\killstreaks\_littlebird;
#include maps\mp\gametypes\_gamelogic;

init()
{
    level thread onPlayerConnect();
    
    level.strings = [];
    
    level.list = StrTok( "com_two_light_fixture_off com_two_light_fixture_on tv_video_monitor bc_ammo_box_762 projectile_rpg7 head_riot_op_arab foliage_cod5_tallgrass10a foliage_cod5_tallgrass10b foliage_pacific_bushtree01_animated bc_hesco_barrier_med vehicle_little_bird_dest_body1 vehicle_little_bird_dest_body2 com_plasticcase_friendly head_opforce_arab_a me_electricbox4_dest me_electricbox4 me_electricbox4_door", " " );
    foreach( model in level.list ) 
        PreCacheModel( model );

    /* Regular Animations */
    precacheMpAnim("pb_sprint_gundown");
    precacheMpAnim("pb_sprint_akimbo");
    precacheMpAnim("pb_sprint_mg");
    precacheMpAnim("pb_pistol_run_fast");
    precacheMpAnim("pb_sprint_pistol");
    precacheMpAnim("pb_combatrun_forward_loop_stickgrenade");
    precacheMpAnim("pb_sprint_shield"); 
    precacheMpAnim("pb_walk_forward_shield");
    precacheMpAnim("pb_combatwalk_forward_loop_pistol");
    precacheMpAnim("pb_walk_forward_mg");
    /* Bot Animations */
    precacheMpAnim("pb_stand_alert");
    precacheMpAnim("pb_stand_shoot_walk_forward");
    precacheMpAnim("pt_reload_stand_auto_mp40");
    precacheMpAnim("pt_stand_shoot_auto");
    precacheMpAnim("pb_stand_alert_mg");
    precacheMpAnim("pt_reload_stand_mg");
    precacheMpAnim("pt_stand_shoot_mg");
    /* Regular Death Anim */
    precacheMpAnim("pb_stand_death_leg_kickup");
    precacheMpAnim("pb_stand_death_shoulderback");
    precacheMpAnim("pb_death_run_stumble");
    if(getDvar("mapname") == "mp_afghan" || getDvar("mapname") == "mp_trailerpark" || getDvar("mapname") == "mp_estate")
    {
        precacheMpAnim("pb_shotgun_death_front");
        precacheMpAnim("pb_crouch_death_falltohands");
        precacheMpAnim("pb_crouchrun_death_drop");
        precacheMpAnim("pb_death_run_onfront");
        precacheMpAnim("pb_stand_death_head_straight_back");
        precacheMpAnim("pb_crouchrun_death_drop");
    }
    /* Pain Anim */
    precacheMpAnim("pb_stumble_forward");
    /* Crawling Animations */ 
    precacheMpAnim("pb_prone_crawl_akimbo");
    precacheMpAnim("pb_prone_death_quickdeath");
    /* Melee Animation */
    precacheMpAnim("pt_melee_pistol_1");
    
    PreCacheShader("hud_grenadeicon");

    PreCacheModel( @"vehicle_little_bird_dest_body1" );
    PreCacheModel( @"vehicle_little_bird_dest_body2" );
    PreCacheModel( @"mil_tntbomb_mp" ); //"mil_tntbomb_mp" );
    PreCacheModel( @"com_red_toolbox" );
    PreCacheModel( @"com_barrel_tan_rust" );
    
    level._effect[ "nuke_aftermath" ]  = loadfx( "dust/nuke_aftermath_mp" );
    level.headshot_blood = loadfx( "impacts/flesh_hit_body_fatal_exit" );   
    level.bodyshot_blood = loadfx( "impacts/flesh_hit" ); 
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
    level endon("game_ended");
    
    self forceSpawn();
    
    self waittill("spawned_player");
    self thread initial_setup();
}

overflowfix()
{
    level.overflow       = level createserverfontstring( "default", 1 );
    level.overflow.alpha = 0;
    level.overflow setText( "marker" );

    for(;;)
    {
        level waittill("CHECK_OVERFLOW");
        if( level.strings.size >= 40 )
        {
            level.overflow ClearAllTextAfterHudElem();
            level.strings = [];
            level notify("FIX_OVERFLOW");
        }
    }
}