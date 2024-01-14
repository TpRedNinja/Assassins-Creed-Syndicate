//assassin's creed syndicate load remover as of rn. address found by akilogames code by TpRedNinja me.
state("ACS", "Ubisoft Connect")
{
int loading: 0x073443F8, 0x388, 0x8, 0xF8, 0xBD8; //detects if loading, 0 is not loading 1 is for loading
int endscreen: 0x0732CD70, 0x50, 0x3A0, 0x98; //detcets end mission sceen, 1 for end screen 0 for literally everything else
int cutscene: 0x070DE700, 0x8, 0x4D0, 0xBF4; /* detects first cutscene, 0 for cutscene playing some super high number for not playing a cutscene. 
note is for jack the ripper*/
}

init
{
    //SHA256: dee8d6e4eee0d749ed0f7dac49421231dad93fb05903b906913890ebcc2fa2ae hash id for ubisoft connect version
}
startup
{
settings.Add("Categories", true, "select which category you doing ripper or base game");

settings.Add("MainGame", true, "MainGame","Categories");
settings.SetToolTip("MainGame", "click this is you are playing the main game and not jack the ripper");
settings.Add("DLC", true, "DLC", "Categories");
settings.SetToolTip("DLC", "click this if you are running jack the ripper dlc otherwise do MainGame");
}

start
//starts when first skippable cutscene plays
{
if(settings["DLC"]){
    if(current.loading == 0 && old.loading == 1 && current.cutscene == 0){
        return true;
        }
    }
if(settings["MainGame"]){
    if(current.loading == 0 && old.loading == 0 && current.cutscene > 0 && old.cutscene == 0){
        return true;
    }
}
}

split
/*splits when end mission screen starts note it does not split after 
and missions that involve jack at the end as their is no end screen for that*/
{
    if(current.endscreen == 1 && old.endscreen == 0){
        return true;
    }
}

isLoading
//pauses during loading screen and unpauses when out of loading screens note black screens do not count as loading
{
    if(current.loading == 1){
        return true;
    }else {
        return false;
    }
}