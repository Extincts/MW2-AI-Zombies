_changeTeam( team )
{
    self.switching_teams = true;
    self.joining_team = team;
    self.leaving_team = self.pers["team"];
    
    self.pers["team"] = team;
    self.team = team;
    self.sessionteam = team;
    
    self.pers["class"] = undefined;
    self.class = undefined;
    
    self updateObjectiveText();
    waittillframeend;

    self updateMainMenu();
    
    if(team == "spectator")
        self notify("joined_spectators");
    else
        self notify("joined_team");
        
    self notify("end_respawn");
}

forceSpawn()
{
    self _changeTeam( "allies" );
    wait .05;
    self notify("menuresponse", "changeclass", "CLASS_ASSAULT");   
}