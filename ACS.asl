//assassin's creed syndicate load remover an autosplitter works for ubisoft connect for now working on steam version as of now
state("ACS", "Ubisoft Connect")
{
int loading: 0x073443F8, 0x388, 0x8, 0xF8, 0xBD8; //Detects if loading, 0 is not loading 1 is for loading
int endscreen: 0x0732CD70, 0x50, 0x3A0, 0x98; //Detcets end mission sceen, 1 for end screen 0 for literally everything else
int cutscene: 0x073446E8, 0x260,0x9B0,0x58,0x824; //Detects cutscene value in main game not dlc 7 for not in a cutscene and 8 for in a cutscene
int Eviemain: 0x070E0BE8, 0xD50, 0x0, 0x98, 0x188; // Detects if your playing evie in the main game. 1 if false 2 if true.
int Jacob: 0x07331920, 0x568, 0x2B0, 0x290, 0x260; //Detects if your jacob. 0 if false 2 if true.
/*
int Evieripper: need to find
int Jack: need to find
*/
}
state("ACS", "Steam")
{
int loading:0x0710EBB8, 0xB4;
//int loadingbackup:0x07154550, 0x904;-use only if first one isint working
//int endscreen:; currently need to refind 
//int cutscene:; currently need to refind 
int Eviemain:0x07162178, 0x120, 0xBD8;
int Jacob:0x0DAEF418, 0x1C8, 0x3C0, 0x238, 0xB30;
/*
int Evieripper: need to find
int Jack: need to find
*/
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
            "This game uses Game Time (without loads) as the main timing method. "+
            "LiveSplit is currently set to display and compare against Real Time (including loads).\n\n"+
            "Would you like the timing method to be set to Game Time?",
            "Assassin's Creed Syndicate | LiveSplit",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
    };
//these settings will allow the code to know which start code to use
settings.Add("Categories", true, "select which category you doing ripper or base game");

settings.Add("Main Game", false, "Main Game","Categories");
settings.SetToolTip("Main Game", "click this to reveal options bellow");
settings.Add("Fresh Save", false, "Fresh Save","Main Game");
settings.SetToolTip("Fresh Save", "click this to make timer start upon loading up first save at normal timer start point");
settings.Add("From Save", false, "From Save","Main Game");
settings.SetToolTip("From Save", "click this to make timer start upon loading into a save already where you have gained control of jacob");
settings.Add("Level runs", false, "Level runs","Main Game");
settings.SetToolTip("Level runs", "Starts the timer upon any missions first cutscene showing regardless if its skippable or not");

settings.Add("DLC", false, "DLC", "Categories");
settings.SetToolTip("DLC", "click this if you are running jack the ripper dlc otherwise do MainGame");
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
//starts when first skippable cutscene plays in dlc
{
if(settings["DLC"]){
    if(current.loading == 0 && old.loading == 1 && current.cutscene == 8){
        return true;
        }
}

//starts when you gain control of jacob from a fresh save    
if(settings["Fresh Save"]){
    if(current.loading == 0 && old.loading == 0 && current.Jacob == 2 && current.Eviemain > 2){
        return true;
    }
}

//starts when you gain control of jacob from loading a save past the first cutscene
if(settings["From Save"]){
    if(old.loading == 1 && current.loading == 0 && current.Jacob == 2 && current.Eviemain > 0){
        return true;
    }
}
//starts when starting a level 
if(settings["Level runs"]){
    if(current.cutscene == 8){
        return true;
    }
}


}

split
/*splits when end mission screen starts 
note it does not split after missions that involve jack at the end as their is no end screen for that*/
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
