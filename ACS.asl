//assassin's creed syndicate load remover an autosplitter by TpRedNinja w/ DeathHound,AkiloGames, people from the speedrun development tool discord
//Support for Ubisoft Connect
//Support for Steam

state("ACS", "Ubisoft Connect")
{
    int loading: 0x073443F8, 0x388, 0x8, 0xF8, 0xBD8; // Detects if loading, 0 is not loading 1 is for loading
    int endscreen: 0x0732CD70, 0x50, 0x3A0, 0x98; // Detects end mission sceen, 1 for end screen 0 for literally everything else
    int cutscene: 0x715EBC0; // Detects cutscene value 0 in loading screen 1 no cutscene 2 for cutscene game and dlc is not a pointer just "ACS.exe" +(inserst address here)
    int Eviemain: 0x070E0BE8, 0x3C8, 0x980, 0x18, 0x38, 0x84, 0x330, 0x230; // Detects if your playing evie in the main game. 1 if false 2 if true.
    int Jacob: 0x070E0BE8, 0xD50, 0x18, 0x480, 0x38, 0x84, 0x390, 0x20; // Detects if your jacob. 0 if false 2 if true.
    int Character: 0x07155D78, 0xB20, 0xA0, 0x560, 0x140; // 6 for evie 7 when not in london 8 for jack 9 when not in london.
}

state("ACS", "Steam")
{
    int loading: 0x0710EBB8, 0xB4; // detects if loading 1 for true 0 for false
    // int loadingbackup:0x07154550, 0x904; // same as og but just in case if first one doesnt work
    int endscreen: 0x07325DB0, 0x78, 0x3D0, 0x68; // 1 for endscreen showing 0 for not
    int cutscene: 0x7154FE0;  // same as ubi connect
    int Eviemain: 0x070D9A38, 0xD50, 0x2D0, 0x7C0, 0x38, 0x84, 0x108, 0x20; // same as ubi connect
    //int Eviebackup: 0x070D9A38, 0xD50, 0x300, 0x4A0, 0x38, 0x84, 0x3E0, 0x20; // same as ubi connect
    int Jacob: 0x07154AA8, 0x58, 0x6C8, 0x898, 0x78, 0x68, 0x30, 0x230; // same as ubi connect
    int character: 0x071546C8, 0x18, 0x0, 0x308, 0x158; // same as ubi connect
}

startup
{
    //SHA256: a2e6ca1504d172ca87f500d1d6cb1de97a2f6687f7ce77f661dce95e90c54e0e hash id for steam version
    vars.acsSteam = new byte[32]{ 0xa2, 0xe6, 0xca, 0x15, 0x04, 0xd1, 0x72, 0xca, 0x87, 0xf5, 0x00, 0xd1, 0xd6, 0xcb, 0x1d, 0xe9, 0x7a, 0x2f, 0x66, 0x87, 0xf7, 0xce, 0x77, 0xf6, 0x61, 0xdc, 0xe9, 0x5e, 0x90, 0xc5, 0x4e, 0x0e };
    //SHA256: dee8d6e4eee0d749ed0f7dac49421231dad93fb05903b906913890ebcc2fa2ae hash id for ubisoft connect version
    vars.acsubisoftconnect = new byte[32] {0xde, 0xe8, 0xd6, 0xe4, 0xee, 0xe0, 0xd7, 0x49, 0xed, 0x0f, 0x7d, 0xac, 0x49, 0x42, 0x12, 0x31, 0xda, 0xd9, 0x3f, 0xb0, 0x59, 0x03, 0xb9, 0x06, 0x91, 0x38, 0x90, 0xeb, 0xcc, 0x2f, 0xa2, 0xae };


    // Calculates the hash id for the current module credit to the RE2R autosplitter & deathHound246 on discord for this code
    Func<ProcessModuleWow64Safe, byte[]> CalcModuleHash = (module) => {
        print("Calculating hash of " + module.FileName);
        byte[] checksum = new byte[32];
        using (var hashFunc = System.Security.Cryptography.SHA256.Create())
            using (var fs = new FileStream(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete))
                checksum = hashFunc.ComputeHash(fs);
        return checksum;
    }; 
    vars.CalcModuleHash = CalcModuleHash;

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
    settings.Add("base", true, "Main Game");
    settings.Add("new_game", true, "New Game", "base");
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
    // Detecting the game version based on SHA-256 hash
    byte[] checksum = vars.CalcModuleHash(modules.First());
    if (Enumerable.SequenceEqual(checksum, vars.acsSteam))
        version = "Steam";
    else if(Enumerable.SequenceEqual(checksum, vars.acsubisoftconnect)) 
        version = "Ubisoft Connect";
}

start
{
    //starts when first skippable cutscene plays in dlc
    if(settings["ripper_enabled"])
    {
        if(current.loading == 0 && old.loading == 1 && current.cutscene == 2)
            return true;
    }

    //starts when you gain control of jacob from a fresh save
    if(settings["new_game"])
    {
        if(current.loading == 0 && old.loading == 0 && current.Jacob == 2 && current.Eviemain == 2)
            return true;
    }

    //starts when you gain control of jacob from loading a save past the first cutscene
    if(settings["loaded_save"])
    {
        if(old.loading == 1 && current.loading == 0 && current.Jacob == 2 && current.Eviemain == 0 )
            return true;
    }

    //starts when starting a level
    if(settings["levels"])
    {
        return old.cutscene == 0 && (current.cutscene == 1 || current.cutscene == 2);
    }
}

/*splits when end mission screen disappears 
note if you want it to split on after the jack missions please select the ripper_# as those will allow it to split after the mission ends as jack*/
split
{
    //splits after end screen disappears so when you press "A" button or Spacebar
    if(current.endscreen == 1 && old.endscreen == 0)
        return true;

    //Splits after 1st jack mission-ie after jack puts a knife in jacobs eye :)
    if(settings["ripper_1"])
    {
        if(old.character == 8 && current.character == 6 && current.cutscene == 2 || 1 )
            return true;
    }

    //splits after 2nd jack mission-ie during the loading screen after you leave the docks as jack
    if(settings["ripper_2"])
    {
       if(old.character == 9 && current.character == 6 && current.loading == 1)
            return true;
    }

    //splits after 3rd jack mission-ie lambeth mission as jack
    if(settings["ripper_3"])
    {
        if(old.character == 7 && current.character == 11)
            return true;
    }
}

isLoading
{
    //pauses during loading screen and unpauses when out of loading screens note black screens do not count as loading
    return current.loading == 1;
}
