/* Autosplitter-lite for Metal Gear Solid 2: Substance (PC) with V's Fix */

state("mgs2_sse") {
  // 601F34 > D8ADC0
  uint      GameTime: 0xD8AEF8; // 0x601F34, 0x138;
  string10  Section: 0xD8C374; // 0x601F34, 0x15B4;
  string10  RoomCode: 0xD8ADEC; // 0x601F34, 0x2C;
  ushort    ProgressTanker: 0xD8D93C; // 0x601F34, 0x2B7C;
  ushort    ProgressPlant: 0xD8D912; // 0x601F34, 0x2B52;
  uint      ResultsComplete: 0x65397C;
}
state("METAL GEAR SOLID2") {
  // 94E7C0 > ???
  /*
  uint      GameTime: 0x94E7C0, 0x138;
  string10  Section: 0x94E7C0, 0x1C;
  string10  RoomCode: 0x94E7C0, 0x2C;
  ushort    ProgressTanker: 0x94E7B0, 0x6;
  ushort    ProgressPlant: 0x94E7B8, 0x68;
  uint      ResultsComplete: 0x1543B38; // will probably only work on 1.2.0
  byte      GameplayActive: 0x85C458; // same
  */
}
state("METAL GEAR SOLID2.unpacked") {}

init {
  var D = vars.D;
  D.IsMasterCollection = false;
  D.Watchers = null;

  if (!D.InitInit) {
    D.IsRtaLoadlessEnabled = (Func<bool>)(() => (settings["opt.RTALoadless"] && D.IsMasterCollection));

    D.TimerModel = new TimerModel { CurrentState = timer };
    D.RTALLTimerModel = new TimerModel { CurrentState = (LiveSplitState)timer.Clone() };

    D.FindReference = (Func<int, string, IntPtr>)((patternOffset, pattern) => {
      var module = modules.First();
      var sigScanner = new SignatureScanner(game, module.BaseAddress, (int)module.ModuleMemorySize);
      return sigScanner.Scan(new SigScanTarget(patternOffset, pattern));
    });

    D.FindRelativePointer = (Func<int, string, int, string, bool, IntPtr>)((patternOffset, pattern, pointerOffset, name, failOut) => {
      IntPtr refLocation = D.FindReference(patternOffset, pattern);
      if (refLocation == IntPtr.Zero) {
        if (failOut) {
          Thread.Sleep(1000);
          throw new Exception(name + " reference not found by signature scan");
        }
        else return refLocation;
      }

      int relativePointer = memory.ReadValue<int>(refLocation);
      IntPtr absolutePointer = IntPtr.Add(refLocation, relativePointer + pointerOffset);
      print("Found reference to " + name + " at " + refLocation.ToString("X") + " value " + relativePointer.ToString("X") + " > " + absolutePointer.ToString("X"));
      return absolutePointer;
    });
    
    D.InitInit = true;
  }

  if (game.ProcessName == "mgs2_sse") return true;

  IntPtr mainDataPtr = D.FindRelativePointer(11, "81 F9 34 03 00 11 75 ?? 48 8B 05 ?? ?? ?? 00", 4, "MC2 main game data", true);  
/*
                             undefined  FUN_14001e430 ()
             undefined         AL:1           <RETURN>
                             FUN_14001e430                                   XREF[1]:     FUN_140090300:140090333 (c)   
       14001e430 81  f9  34       CMP        ECX ,0x11000334
                 03  00  11
       14001e436 75  5b           JNZ        LAB_14001e493
       14001e438 48  8b  05       MOV        RAX ,qword ptr [MainGameData_PTR_DAT_14094e7c0 ]  = 1417d80a0
                 81  03  93  00
*/
  IntPtr tankerDataPtr = IntPtr.Subtract(mainDataPtr, 0x10);
  IntPtr plantDataPtr = IntPtr.Subtract(mainDataPtr, 0x8);
  print("Pointers: " + mainDataPtr.ToString("X") + "/" + tankerDataPtr.ToString("X") + "/" + plantDataPtr.ToString("X"));

  IntPtr gameplayStatusPtr = D.FindRelativePointer(5,
    "89 73 38 81 25 ?? ?? ?? ?? FF FF FF EF E9 ?? ?? 00 00 C7 43 3C 01 00 00 00 E9 ?? ?? 00 00", 8, "MC2 gameplay status", true);  
/*
                               LAB_1400540c0                                   XREF[1]:     14005408d (j)   
       1400540c0 89  73  38       MOV        dword ptr [RBX  + 0x38 ],ESI
       1400540c3 81  25  6b       AND        dword ptr [DAT_141543b38 ],0xefffffff            = ??
                 fa  4e  01 
                 ff  ff  ff  ef
       1400540cd e9  1f  01       JMP        LAB_1400541f1
                 00  00
                             LAB_1400540d2                                   XREF[1]:     140053fbb (j)   
       1400540d2 c7  43  3c       MOV        dword ptr [RBX  + 0x3c ],0x1
                 01  00  00  00
       1400540d9 e9  13  01       JMP        LAB_1400541f1
                 00  00
*/

  IntPtr gameplayActivePtr = D.FindRelativePointer(7,
    "E8 ?? ?? ?? 00 83 3D ?? ?? ?? 00 00 74 ?? 66 0F 2F 05 ?? ?? ?? ?? 73 ?? 33 C0 48 83 C4 28 C3", 5, "MC2 gameplay active status", false);
/* 1.2.2
                             undefined  FUN_14000e790 ()
             undefined         AL:1           <RETURN>
                             FUN_14000e790                                   XREF[2]:     FUN_14000b810:14000b890 (c) , 
                                                                                          1417e3900 (*)   
       14000e790 48  83  ec  28    SUB        RSP ,0x28
       14000e794 e8  17  63       CALL       FUN_140094ab0                                    undefined FUN_140094ab0()
                 08  00
       14000e799 83  3d  b8       CMP        dword ptr [DAT_14085c458 ],0x0                   = 01h
                 dc  84  00  00
       14000e7a0 74  11           JZ         LAB_14000e7b3
       14000e7a2 66  0f  2f       COMISD     XMM0 ,qword ptr [DAT_1407392b8 ]                  = 11h
                 05  0e  ab 
                 72  00
       14000e7aa 73  07           JNC        LAB_14000e7b3
       14000e7ac 33  c0           XOR        EAX ,EAX
       14000e7ae 48  83  c4  28    ADD        RSP ,0x28
       14000e7b2 c3              RET
*/
  if (gameplayActivePtr == IntPtr.Zero)
    gameplayActivePtr = D.FindRelativePointer(7,
      //"E8 ?? ?? ?? 00 83 3D ?? ?? ?? 00 00 74 10 0F 2F 05 ?? ?? ?? ?? 73 07 33 C0 48 83 C4 28 C3", 5, "MC2 gameplay active status");
      "E8 ?? ?? ?? 00 83 3D ?? ?? ?? 00 00 74 ?? 0F 2F 05 ?? ?? ?? ?? 73 ?? 33 C0 48 83 C4 28 C3", 5, "MC2 gameplay active status", true);
/* 1.0.0
                                              LAB_14000e7ad                                   XREF[1]:     14000e7a2 (j)   
       14000e7ad e8  3e  63       CALL       FUN_140094af0                                    undefined FUN_140094af0()
                 08  00
       14000e7b2 83  3d  9f       CMP        dword ptr [DAT_14085c458 ],0x0                   = 00000001h
                 dc  84  00  00
       14000e7b9 74  10           JZ         LAB_14000e7cb
       14000e7bb 0f  2f  05       COMISS     XMM0 ,dword ptr [DAT_1407392b0 ]                  = B9h
                 ee  aa  72  00
       14000e7c2 73  07           JNC        LAB_14000e7cb
       14000e7c4 33  c0           XOR        EAX ,EAX
       14000e7c6 48  83  c4  28    ADD        RSP ,0x28
       14000e7ca c3              RET
*/


  D.Watchers = new MemoryWatcherList() {
    new MemoryWatcher<uint>(
      new DeepPointer(mainDataPtr, 0x138)) { Name = "GameTime" },
    new StringWatcher(
      new DeepPointer(mainDataPtr, 0x1C), 10) { Name = "Section" },
    new StringWatcher(
      new DeepPointer(mainDataPtr, 0x2C), 10) { Name = "RoomCode" },
    new MemoryWatcher<ushort>(
      new DeepPointer(tankerDataPtr, 0x6)) { Name = "ProgressTanker" },
    new MemoryWatcher<ushort>(
      new DeepPointer(plantDataPtr, 0x68)) { Name = "ProgressPlant" },
    new MemoryWatcher<uint>(gameplayStatusPtr) { Name = "ResultsComplete" },
    new MemoryWatcher<byte>(gameplayActivePtr) { Name = "GameplayActive" },
  };

  D.IsMasterCollection = true;

  return true;
}

isLoading {
  var D = vars.D;

  if (!D.IsMasterCollection)
    return true;

  if (D.RTALLTimerModel.CurrentState.StartTime != D.TimerModel.CurrentState.StartTime) {
    D.RTALLTimerModel = new TimerModel { CurrentState = (LiveSplitState)timer.Clone() };
    D.LastAreaLoadTime = D.RTALLTimerModel.CurrentState.CurrentTime.RealTime;
  }

  var rtallState = D.RTALLTimerModel.CurrentState;

  if (current.GameplayActive != D.old.GameplayActive) {
    if (current.GameplayActive == 1)
      rtallState.CurrentPhase = TimerPhase.Paused; // will become Running
    else {
      rtallState.CurrentPhase = TimerPhase.Running; // will become Paused
      vars.LastAreaTime = (rtallState.CurrentTime.RealTime - D.LastAreaLoadTime).ToString(@"m\:ss\.ff");
      D.LastAreaLoadTime = rtallState.CurrentTime.RealTime;
    }
    D.RTALLTimerModel.Pause();
  }

  vars.RTALoadless = rtallState.CurrentTime.RealTime.ToString(D.TimeFormat);

  return ((!settings["opt.RTALoadless"]) || (current.GameplayActive != 1));
}

gameTime {
  var D = vars.D;

  TimeSpan gameTime = TimeSpan.FromMilliseconds(current.GameTime * 1000 / 60);
  vars.GameTime = gameTime.ToString(D.TimeFormat);

  return (D.IsRtaLoadlessEnabled()) ? D.RTALLTimerModel.CurrentState.CurrentTime.RealTime : gameTime;
}

reset {
  return ((current.RoomCode != old.RoomCode) && (current.RoomCode == "n_title"));
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
  vars.GameTime = "0:00:00.00";
  vars.RTALoadless = "0:00:00.00";
  vars.LastAreaTime = "0:00.00";

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

  settings.Add("opt", true, "Options");
    settings.Add("opt.RTALoadless", false, "Change Game Time style to RTA Loadless (MC only)", "opt");
  
  settings.Add("splits", true, "Split Points");
    settings.CurrentDefaultParent = "tanker";
    settings.Add("tanker", true, "Tanker", "splits");
      settings.Add("r_tnk_24", false, "Reach Olga");
      settings.Add("r_tnk_26", true, "Olga");
      settings.Add("r_tnk_31", false, "Reach Guard Rush");
      settings.Add("r_tnk_33", true, "Guard Rush");
      settings.Add("r_tnk_56", true, "Results (Tanker Only)");
      settings.SetToolTip("r_tnk_56", "You can keep this enabled if playing Tanker-Plant. It will not trigger.");
      settings.Add("r_tnk_58", true, "Tanker (Tanker-Plant)");
    
    settings.CurrentDefaultParent = "plant";
    settings.Add("plant", true, "Plant", "splits");
      settings.Add("r_plt_63", true, "Reach Stillman");
      settings.Add("r_plt_109", false, "Reach Fortune");
      settings.Add("r_plt_115", true, "Fortune");
      settings.Add("r_plt_117", false, "Reach Fatman");
      settings.Add("r_plt_119", true, "Fatman");
      settings.Add("r_plt_153", false, "Reach B1 Hall");
      settings.Add("r_plt_155", true, "Ames");
      settings.Add("r_plt_188", false, "Reach Harrier");
      settings.Add("r_plt_190", true, "Harrier");
      settings.Add("r_plt_206", true, "Reach Prez");
      settings.Add("r_plt_246", false, "Reach Vamp 1");
      settings.Add("r_plt_254", true, "Vamp 1");
      settings.Add("r_plt_302", false, "Reach Sniping");
      settings.Add("r_plt_316", false, "Reach Vamp 2");
      settings.Add("r_plt_318", true, "Vamp 2");
      settings.Add("r_plt_328", false, "Reach Arsenal Gear");
      settings.Add("r_plt_382", false, "Reach Snake");
      settings.Add("r_plt_397", true, "Tengus 1"); // Late split at 400
      settings.Add("r_plt_404", true, "Tengus 2");
      settings.Add("r_plt_412", true, "Rays");
      settings.Add("r_plt_470", true, "Solidus");
      settings.Add("r_plt_result", true, "Results");
  
  print("Startup complete");
}

update {
  var D = vars.D;
  D.old = old;

  if (!D.UpdateInit) {
    Func<bool> WatTengus1 = () => (current.RoomCode == "w45a");
    D.Watch.Add("r_plt_397", WatTengus1);
    
    //Func<bool> WatResults = () => ( (current.ResultsComplete != D.old.ResultsComplete) && ( (current.ResultsComplete & 0x200) == 0x200) );
    Func<bool> WatResults = () => ((current.ResultsComplete & 0x200) == 0x200);
    D.Watch.Add("r_tnk_56", WatResults);
    D.Watch.Add("r_plt_result", WatResults);
    
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

  return true;
}

split {
  var D = vars.D;

  string filteredSection = current.Section;
  char lastChar = filteredSection[filteredSection.Length - 1];
  if ((lastChar >= '0') && (lastChar <= '9'))
    filteredSection = filteredSection.Substring(0, filteredSection.Length - 1);

  string Code = filteredSection + "_" +
    ( (filteredSection.Equals("r_tnk")) ? current.ProgressTanker : current.ProgressPlant );

  if (D.IsMasterCollection) {
    if (Code.Equals("r_plt_487")) Code = "r_plt_result";
  }
  else if (Code.Equals("r_plt_486")) Code = "r_plt_result";
  
  if (D.Watch.ContainsKey(Code)) {
    if (D.Watch[Code]()) {
      D.Watch.Remove(Code);
      return true;
    }
    return false;
  }
  
  if (
    (current.Section == old.Section) &&
    (current.ProgressTanker == old.ProgressTanker) &&
    (current.ProgressPlant == old.ProgressPlant)
  ) return false;
  
  if ( (!settings.ContainsKey(Code)) || (!settings[Code]) ) return false;
  if (D.Except.ContainsKey(Code)) return D.Except[Code]();
  return true;
}
