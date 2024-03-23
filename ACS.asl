//assassin's creed syndicate load remover an autosplitter by TpRedNinja w/ DeathHound,AkiloGames, people from the speedrun development tool discord
//Support for Ubisoft Connect
//Support for Steam

//[9188] 157683712
//SHA256: dee8d6e4eee0d749ed0f7dac49421231dad93fb05903b906913890ebcc2fa2ae hash id for ubisoft connect version 
state("ACS", "Ubisoft Connect")
{
    int Loading: 0x073443F8, 0x388, 0x8, 0xF8, 0xBD8; // Detects if loading, 0 is not loading 1 is for loading
    int Endscreen: 0x0732CD70, 0x50, 0x3A0, 0x98; // Detects end mission sceen, 1 for end screen 0 for literally everything else
    int Cutscene: 0x715EBC0; // Detects cutscene value 0 in loading screen 1 no cutscene 2 for cutscene game and dlc is not a pointer just "ACS.exe" +(inserst address here)
    int Eviemain: 0x070E0BE8, 0x3C8, 0x980, 0x18, 0x38, 0x84, 0x330, 0x230; // Detects if your playing evie in the main game. 1 if false 2 if true.
    int Jacob: 0x070E0BE8, 0xD50, 0x18, 0x480, 0x38, 0x84, 0x390, 0x20; // Detects if your jacob. 0 if false 2 if true.
    int Character: 0x07155D78, 0xB20, 0xA0, 0x560, 0x140; // 6 for evie 7 when not in london 8 for jack 9 when not in london.
}

//[10848] 163323904
//SHA256: a2e6ca1504d172ca87f500d1d6cb1de97a2f6687f7ce77f661dce95e90c54e0e hash id for steam version 
state("ACS", "Steam")
{
    int Loading: 0x0710EBB8, 0xB4; // detects if loading 1 for true 0 for false
    // int loadingbackup:0x07154550, 0x904; // same as og but just in case if first one doesnt work
    int Endscreen: 0x07325DB0, 0x78, 0x3D0, 0x68; // 1 for endscreen showing 0 for not
    int Cutscene: 0x7154FE0;  // same as ubi connect
    int Eviemain: 0x070D9A38, 0xD50, 0x2D0, 0x7C0, 0x38, 0x84, 0x108, 0x20; // same as ubi connect
    //int Eviebackup: 0x070D9A38, 0xD50, 0x300, 0x4A0, 0x38, 0x84, 0x3E0, 0x20; // same as ubi connect
    int Jacob: 0x07154AA8, 0x58, 0x6C8, 0x898, 0x78, 0x68, 0x30, 0x230; // same as ubi connect
    int Character: 0x071546C8, 0x18, 0x0, 0x308, 0x158; // same as ubi connect
}

startup
{
    // Asks the user if they want to change to game time if the comparison is set to real time on startup.
    if(timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show(
            "This Autosplitter has a load removal Time without loads. " +
            "LiveSplit is currently set to display and compare against Real Time (including loads).\n\n" +
            "Would you like the timing method to be set to Game Time?",
            "Assassin's Creed Syndicate | LiveSplit",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    };

    // to control when the timer starts for the main game
    settings.Add("base", false, "Main Game");
    settings.Add("new_game", false, "New Game", "base");
    settings.Add("loaded_save", false, "Loaded Game Save", "base");
    settings.Add("levels", false, "Level runs", "base");

    //to control when the timer splist for the dlc and if you want it to autostart
    settings.Add("ripper", false, "Jack the Ripper");
    settings.Add("ripper_enabled", false, "Enabled", "ripper");
    settings.Add("ripper_1", false, "Jack mission 1", "ripper");
    settings.Add("ripper_2", false, "Jack mission 2", "ripper");
    settings.Add("ripper_3", false, "Jack mission 3", "ripper");
}

init
{  
        switch (modules.First().ModuleMemorySize) { //Detects which version of the game is being played
        default:
        version = "Ubisoft Connect";
        break;
        case (163323904):
        version = "Steam";
        break;
    }
    //print(modules.First().ModuleMemorySize.ToString());
}

update
{
    print("Jack;" + "CurrentCharacter:" + current.Character + " OldCharacter:" + old.Character  + " Cutscene:" + current.Cutscene + " Loading:" + current.Loading);
}

start
{
    //starts when first skippable cutscene plays in dlc
    if(settings["ripper_enabled"])
    {
        if(current.Cutscene == 2 && current.Character == 8)
            return true;
    }

    //starts when you gain control of jacob from a fresh save
    if(settings["new_game"])
    {
        if(current.Loading == 0 && old.Loading == 0 && current.Jacob == 2 && current.Eviemain == 2)
            return true;
    }

    //starts when you gain control of jacob from loading a save past the first cutscene
    if(settings["loaded_save"])
    {
        if(old.Loading == 1 && current.Loading == 0 && current.Jacob == 2 && current.Eviemain == 0 )
            return true;
    }

    //starts when starting a level
    if(settings["levels"])
    {
        return old.Cutscene == 0 && (current.Cutscene == 1 || current.Cutscene == 2);
    }
}

/*splits when end mission screen disappears 
note if you want it to split on after the jack missions please select the ripper_# as those will allow it to split after the mission ends as jack*/
split
{
    //splits after end screen appears so when you are able to press "A" button or Spacebar
    if(current.Endscreen == 1 && old.Endscreen == 0)
        return true;

    //Splits after 1st jack mission-ie after jack puts a knife in jacobs eye :)
    if(settings["ripper_1"])
    {
        if(current.Character == 6 && old.Character == 8 && current.Cutscene == 0)  
            return true;
    }

    //splits after 2nd jack mission-ie during the loading screen after you leave the docks as jack
    if(settings["ripper_2"])
    {
       if(current.Character == 7 && old.Character == 9 && current.Loading == 1 && old.Loading == 0)
            return true;
    }

    //splits after 3rd jack mission-ie lambeth mission as jack
    if(settings["ripper_3"])
    {
        if(current.Character == 11 && old.Character == 7 && current.Loading == 0 && current.Cutscene == 2)
            return true;
    }
}

isLoading
{
    //pauses during loading screen and unpauses when out of loading screens note black screens do not count as loading
    return current.Loading == 1;
}
