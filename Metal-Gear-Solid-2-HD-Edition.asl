/*****************************
Autospliter for Metal Gear Solid 2 Master Collection on PC.
Original work by https://github.com/bmn or w00ty.
Expanded, memory corrected by Hau5test.
With help from https://github.com/ShizCalev / Afevis.
******************************/

state("METAL GEAR SOLID2") {
  //splitter data
  uint      GameTime: 0x949340, 0x138;
  uint      StageGameTime: 0x949340, 0xE4;
  ushort    ProgressTanker: 0x949330, 0x6;
  ushort    ProgressPlant: 0x949338, 0x68;
  uint      GameClearCount: 0x949338, 0x0;
  uint      TankerClearCount: 0x949338, 0x02;
  uint      PlantClearCount: 0x949338, 0x04;
  string10  Section: 0x949340, 0x1C;
  string10  RoomCode: 0x949340, 0x2C;
  //player data
  uint      Health: 0x949340, 0xFA;
  uint      Oxygen: 0x949340, 0xFE;
  uint      SnakeChinUp: 0x949340, 0x12E;
  uint      RaidenChinUp: 0x949340, 0x130;
  uint      ContinueCount: 0x949340, 0x132;
  uint      SaveCount: 0x949340, 0x136;
  uint      ShootCount: 0x949340, 0x140;
  uint      AlertCount: 0x949340, 0x142;
  uint      KillCount: 0x949340, 0x144;
  uint      RationUseCount: 0x949340, 0x1590;
  uint      DamageCount: 0x949340, 0x146;
  uint      MechaKillCount: 0x949340, 0x158;
}

gameTime
{
	//Game Time for Metal Gear is at 15fps so to get the correct time we must take the current uint GameTime and divide it by 15
	return TimeSpan.FromMilliseconds(current.GameTime * 1000 /60);
}

init {
  var D = vars.D;
  D.IsMasterCollection = true;
  D.Watchers = null;
  return true;
}

reset {
  return ((current.RoomCode != old.RoomCode) && (current.RoomCode == "n_title"));
}

onReset
{
  vars.CurrentGameTime = "";
  vars.CurrentAreaTime = "";
  vars.CurrentMixedTime = "";
  return true;
}

start {
  var D = vars.D;

  if (current.RoomCode == old.RoomCode) return false;
  if (
    ( (old.RoomCode == "ending") && (!D.Menus.ContainsKey(current.RoomCode)) ) ||
    ( (D.Menus.ContainsKey(old.RoomCode)) && (current.RoomCode != "ending") )
  ) return true;
  return false;
}

startup {
  vars.CurrentGameTime = "0:00.000";
  vars.CurrentAreaTime = "0:00.000";
  vars.CurrentMixedTime = "0:00.000 | 0:00.000";
  vars.SplitCode = "";

  vars.D = new ExpandoObject();
  var D = vars.D;

  D.TimeFormat = @"h\:mm\:ss\.ff";
  D.LastAreaLoadTime = null;
  
  D.Menus = new Dictionary<string, bool>() {
    { "n_title", true },
    { "mselect", true },
    { "sselect", true },
    { "select", true },
    { "tales", true }
  };

  D.Except = new Dictionary< string, Func<bool> >();
  D.Watch = new Dictionary< string, Func<bool> >();
  D.InitInit = false;
  D.UpdateInit = false;

// add one more split between met the ninja and reach hall (enter shell 1 core)
// end of sniping -> move below vamp 2 fight (end of sniping?)

  settings.Add("splits", true, "Split Points");
    settings.CurrentDefaultParent = "tanker";
    settings.Add("tanker", true, "Tanker", "splits");
      settings.Add("r_tnk_26", true, "Olga");
      settings.CurrentDefaultParent = "r_tnk_26";
        settings.Add("r_tnk_14", false, "Start of After Deck");
        settings.Add("r_tnk_15", false, "Enter Inside Tanker");
        settings.Add("r_tnk_24", false, "Start Olga Encounter");
      settings.CurrentDefaultParent = "tanker";

      settings.Add("r_tnk_33", true, "Guard Rush");
      settings.CurrentDefaultParent = "r_tnk_33";
        settings.Add("r_tnk_30", false, "Shot final sensor in Engine Room");
        settings.Add("r_tnk_32", false, "Start Guard Rush Encounter");
      settings.CurrentDefaultParent = "tanker";

    settings.Add("r_tnk_56", true, "Results (Tanker Only)");
      settings.CurrentDefaultParent = "r_tnk_56";
      settings.Add("r_tnk_42", false, "Enter Holds 1");
      settings.SetToolTip("r_tnk_42", "This will split when the last codec before holds 1 is over");
      settings.Add("r_tnk_43", false, "Enter Holds 3");
      settings.SetToolTip("r_tnk_56", "You can keep this enabled if playing Tanker-Plant. It will not trigger.");
    settings.CurrentDefaultParent = "tanker";
      settings.Add("r_tnk_58", true, "Tanker (Tanker-Plant)");
    
    settings.CurrentDefaultParent = "splits";
    settings.Add("plant", true, "Plant", "splits");
    settings.CurrentDefaultParent = "plant";
    settings.Add("r_plt_115", true, "Fortune");
    settings.CurrentDefaultParent = "r_plt_115";
      settings.Add("r_plt_9", false, "Enter Docks");
      settings.Add("r_plt_29", false, "Enter Strut-A Roof");
      settings.Add("r_plt_37", false, "Reached Pliskin/Vamp");
      settings.Add("r_plt_63", false, "Reach Stillman");
      settings.Add("r_plt_92", false, "Start Bomb Defusal");
      settings.Add("r_plt_100", false, "End of Bomb Defusal / Start of Countdown");
      settings.Add("r_plt_106", false, "Defuse Docks Bomb");
      settings.Add("r_plt_110", false, "Start Fortune Encounter");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_119", true, "Fatman");
    settings.CurrentDefaultParent = "r_plt_119";
      settings.Add("r_plt_118", false, "Start Fatman Encounter");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_155", true, "Found Ames");
    settings.CurrentDefaultParent = "r_plt_155";
      settings.Add("r_plt_148", false, "Met The Ninja");
      settings.Add("r_plt_150", false, "Entered Shell 1 Core");
      settings.Add("r_plt_153", false, "Reach B1 Hall");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_190", true, "Harrier");
      settings.CurrentDefaultParent = "r_plt_190";
        settings.Add("r_plt_180", false, "Leave B1 Hall");
        settings.Add("r_plt_182", false, "Start 1-2 Bridge Sniping");
        settings.Add("r_plt_189", false, "Start Harrier Encounter");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_254", true, "Vamp 1");
      settings.CurrentDefaultParent = "r_plt_254";
        settings.Add("r_plt_194", false, "Enter Shell 2 Core");
        settings.Add("r_plt_205", false, "Panel Destroyed");
        settings.Add("r_plt_206", false, "Reach President Johnson");
        settings.Add("r_plt_253", false, "Start Vamp 1 Encounter");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_318", true, "Vamp 2");
      settings.CurrentDefaultParent = "r_plt_318";
        settings.Add("r_plt_297", false, "Start Emma Escort");
        settings.Add("r_plt_313", false, "Reach Sniping");
        settings.Add("r_plt_317", false, "Reach Vamp 2");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_397", true, "Start Tengus 1"); // Late split at 400
      settings.CurrentDefaultParent = "r_plt_397";
        settings.Add("r_plt_327", false, "Countdown Start");
        settings.Add("r_plt_328", false, "Reach Arsenal Gear");
        settings.Add("r_plt_375", false, "Escape Cell");
        settings.Add("r_plt_382", false, "Reach Snake");
        settings.Add("r_plt_389", false, "Swung Sword");
        settings.Add("r_plt_390", false, "Start of Tengus 1 Encounter");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_404", true, "Tengus 2");
    settings.CurrentDefaultParent = "r_plt_404";
      settings.Add("r_plt_403", false, "Start of Tengus 2");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_412", true, "Rays");
      settings.CurrentDefaultParent = "r_plt_412";
      settings.Add("r_plt_411", false, "Start of Rays");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_470", true, "Solidus");
    settings.CurrentDefaultParent = "r_plt_470";
      settings.Add("r_plt_469", false, "Start of Solidus");

    settings.CurrentDefaultParent = "plant";
      settings.Add("r_plt_487", true, "Results");
  
  print("Startup complete");
}

update {
  var D = vars.D;
  D.old = old;

  if (!D.UpdateInit) {
    Func<bool> WatTengus1 = () => (current.RoomCode == "w45a");
    D.Watch.Add("r_plt_397", WatTengus1);
    
    D.UpdateInit = true;
    return false;
  }

  if (D.Watchers != null) {
    var cur = current as IDictionary<string, object>;
    D.Watchers.UpdateAll(game);
    foreach (var watcher in D.Watchers) {
      cur[watcher.Name] = watcher.Current;
    }
  }

  // set filteredSection to current.Section value
  string filteredSection = current.Section;
  // remove 0 from r_plt
  char lastChar = filteredSection[filteredSection.Length - 1];
  // TBD
  if ((lastChar >= '0') && (lastChar <= '9'))
    filteredSection = filteredSection.Substring(0, filteredSection.Length - 1);
  /* Set Code (for splitting) based on
  the section (r_tnk or r_plt)
  and the progress number of the current tanker or plant section
  for example: r_tnk_56 or r_plnt_486
  */
  string Code = filteredSection + "_" +
    ( (filteredSection.Equals("r_tnk")) ? current.ProgressTanker : current.ProgressPlant );
  
  // for testing
  vars.SplitCode = Code;

  //if game time is past 1 hr mark, add the hr to the string
  if(current.GameTime > 216000) {
    vars.CurrentGameTime = TimeSpan.FromMilliseconds(current.GameTime * 1000 /60).ToString("h\\:mm\\:ss\\.fff");
  //else show only minutes, seconds and milliseconds
  } else vars.CurrentGameTime = TimeSpan.FromMilliseconds(current.GameTime * 1000 /60).ToString("mm\\:ss\\.fff");
  //if game time is past 1 hr mark, add the hr to the string
  if(current.StageGameTime > 3600) {
    vars.CurrentAreaTime = TimeSpan.FromMilliseconds(current.StageGameTime * 1000 /60).ToString("mm\\:ss\\.fff");
  //else show only minutes, seconds and milliseconds
  } else vars.CurrentAreaTime = TimeSpan.FromMilliseconds(current.StageGameTime * 1000 /60).ToString("ss\\.fff");
  vars.CurrentMixedTime = vars.CurrentAreaTime + " | " + vars.CurrentGameTime;

    if(old.Section != current.Section)
  {
      print("Section ID: " + old.Section + " -> " + current.Section);
  }

  if(old.RoomCode != current.RoomCode)
  {
      print("RoomCode String: " + old.RoomCode + " -> " + current.RoomCode);
  }

  if(old.ProgressTanker != current.ProgressTanker)
  {
      print("TankerStory Progress: " + old.ProgressTanker + " -> " + current.ProgressTanker);
  }

  if(old.ProgressPlant != current.ProgressPlant)
  {
    print("PlantStory Progress: " + old.ProgressPlant + " -> " + current.ProgressPlant);
  }
  return true;
}

split {
  var D = vars.D;

  // logic to log if a code has been used already or not
  // to D.Watch
  if (D.Watch.ContainsKey(vars.SplitCode)) {
    if (D.Watch[vars.SplitCode]()) {
      D.Watch.Remove(vars.SplitCode);
      return true;
    }
    return false;
  }
  
  // back up, if no change happens then don't split!
  if (
    (current.Section == old.Section) &&
    (current.ProgressTanker == old.ProgressTanker) &&
    (current.ProgressPlant == old.ProgressPlant)
  ) return false;
  
  // back up, if code was not found or code was not in settings, then don't split
  if ( (!settings.ContainsKey(vars.SplitCode)) || (!settings[vars.SplitCode]) ) return false;
  // TBD
  if (D.Except.ContainsKey(vars.SplitCode)) return D.Except[vars.SplitCode]();
  // else always split
  return true;
}