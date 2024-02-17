//assassin's creed syndicate load remover an autosplitter works for ubisoft connect for now working on steam version as of now
state("ACS", "Ubisoft Connect")
{
int loading: 0x073443F8, 0x388, 0x8, 0xF8, 0xBD8; //Detects if loading, 0 is not loading 1 is for loading
int endscreen: 0x0732CD70, 0x50, 0x3A0, 0x98; //Detcets end mission sceen, 1 for end screen 0 for literally everything else
int cutscene: 0x715EBC0; //Detects cutscene value 0 in loading screen 1 no cutscene 2 for cutscene game and dlc
int Eviemain: 0x070E0BE8, 0x3C8, 0x980, 0x18, 0x38, 0x84, 0xE8, 0x80; // Detects if your playing evie in the main game. 1 if false 2 if true.
int Eviebackup: 0x070E0BE8, 0x3C8, 0x980, 0x18, 0x38, 0x84, 0x330, 0x230; // Same as main just in case if the main doesnt work
int Jacob: 0x070E0BE8, 0xD50, 0x18, 0x480, 0x38, 0x84, 0x390, 0x20; //Detects if your jacob. 0 if false 2 if true.
int Character: 0x07155D78, 0xB20, 0xA0, 0x560, 0x140; //6 for evie 7 when not in london 8 for jack 9 when not in london.

}
state("ACS", "Steam")
{
int loading:0x0710EBB8, 0xB4;
//int loadingbackup:0x07154550, 0x904;-use only if first one isint working
//int endscreen:; currently need to find 
int cutscene:0x7154FE0;  
//int Eviemain:0x;
//int Jacob:0x;
//int character:; currently need to find
}

startup
{
//SHA256: a2e6ca1504d172ca87f500d1d6cb1de97a2f6687f7ce77f661dce95e90c54e0e hash id for steam version
vars.acsSteam = new byte[32]{0xa2, 0xe6, 0xca, 0x15, 0x04, 0xd1, 0x72, 0xca, 0x87, 0xf5, 0x00, 0xd1, 0xd6, 0xcb, 0x1d, 0xe9, 0x7a, 0x2f, 0x66, 0x87, 0xf7, 0xce, 0x77, 0xf6, 0x61, 0xdc, 0xe9, 0x5e, 0x90, 0xc5, 0x4e, 0x0e};
//SHA256: dee8d6e4eee0d749ed0f7dac49421231dad93fb05903b906913890ebcc2fa2ae hash id for ubisoft connect version
vars.acsubisoftconnect = new byte[32]{0xde, 0xe8, 0xd6, 0xe4, 0xee, 0xe0, 0xd7, 0x49, 0xed, 0x0f, 0x7d, 0xac, 0x49, 0x42, 0x12, 0x31, 0xda, 0xd9, 0x3f, 0xb0, 0x59, 0x03, 0xb9, 0x06, 0x91, 0x38, 0x90, 0xeb, 0xcc, 0x2f, 0xa2, 0xae};
//Calculates the hash id for the current module credit to the re2r autosplitter & deathHound on discord for this code 
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
            "This Autosplitter has a load removal Time without loads. "+
            "LiveSplit is currently set to display and compare against Real Time (including loads).\n\n"+
            "Would you like the timing method to be set to Game Time?",
            "Assassin's Creed Syndicate | LiveSplit",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
    };
//these settings will allow the code to know which start code to use
settings.Add("Categories", true, "select which category you doing ripper or base game");
//to control when the timer starts for the main game
settings.Add("Main Game", false, "Main Game","Categories");
settings.SetToolTip("Main Game", "click this to reveal options bellow");
settings.Add("Fresh Save", false, "Fresh Save","Main Game");
settings.SetToolTip("Fresh Save", "click this to make timer start upon loading up first save at normal timer start point");
settings.Add("From Save", false, "From Save","Main Game");
settings.SetToolTip("From Save", "click this to make timer start upon loading into a save already where you have gained control of jacob");
settings.Add("Level runs", false, "Level runs","Main Game");
settings.SetToolTip("Level runs", "Click this to see the options bellow");
//to control when the timer splist for the dlc and if you want it to autostart
settings.Add("DLC", false, "DLC", "Categories");
settings.SetToolTip("DLC", "click this if you are running jack the ripper dlc otherwise do MainGame");
settings.Add("Start", false, "Start", "DLC");
settings.SetToolTip("Start", "click this if you want timer to start automatically");
settings.Add("1", false, "1", "DLC");
settings.SetToolTip("1", "click this if you want it to split after the 1st jack the ripper mission");
settings.Add("2", false, "2", "DLC");
settings.SetToolTip("2", "click this if you want it to split after the 2nd jack the ripper mission");
settings.Add("3", false, "3", "DLC");
settings.SetToolTip("3", "click this if you want it to split after 3rd jack the ripper mission");
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
if(settings["Start"]){
    if(current.loading == 0 && old.loading == 1 && current.cutscene == 2 ){
        return true;
        }
}

//starts when you gain control of jacob from a fresh save    
if(settings["Fresh Save"]){
    if(current.loading == 0 && old.loading == 0 && current.Jacob == 2 && current.Eviemain == 2){
        return true;
    }
}

//starts when you gain control of jacob from loading a save past the first cutscene
if(settings["From Save"]){
    if(old.loading == 1 && current.loading == 0 && current.Jacob == 2 && current.Eviemain == 0 || current.Eviebackup == 0){
        return true;
    }
}
//starts when starting a level 
if(settings["Level runs"]){
    if(old.cutscene == 0 && current.cutscene == 2){
        return true;
    } else if(old.cutscene == 0 && current.cutscene == 1){
        return true;
    }
}


}

split
/*splits when end mission screen starts 
note it does not split after missions that involve jack at the end as their is no end screen for that*/
{
    //splits when the endscreen shows up aka the thing that allows you to complete the mission by pressing "a" or "space"
    if(current.endscreen == 1 && old.endscreen == 0){
        return true;
    }
    //Splits after 1st jack mission-ie after jack puts a knife in jacobs eye :)
    if(settings["1"]){
        if(old.character == 8 && current.character == 6 && current.cutscene == 2 ){
            return true;
        } 
    }
    //splits after 2nd jack mission-ie after evie the mission where you kill jacks warden
    if(settings["2"]){
       if(old.character == 9 && current.character == 6 && old.cutscene == 1 && current.loading == 1){
            return true;
        }
    }
    //splits after 3rd jack mission-ie lambeth mission as jack
    if(old.character == 7 && current.chracter == 11 && old.cutscene == 1 && current.cutscene == 2){
            return true;
        }
}

isLoading
{
    //pauses during loading screen and unpauses when out of loading screens note black screens do not count as loading
    if(current.loading == 1){
        return true;
    }else {
        return false;
    }
}
