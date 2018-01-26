ScriptName _CC_Compatibility Extends ReferenceAlias
{The main compatibility script used to handle compatibility with other mods.}

; General
Actor           Property PlayerRef Auto
{The player reference.}

; Internals
bool            Property IsDone = false Auto Hidden
{Whether or not the compatibility checks have run.}

; Globals
GlobalVariable  Property DDIMinVersion Auto
{The lowest version of DDI required in order to use this mod.}
GlobalVariable  Property DDIMaxVersion Auto
{The highest version of DDI that can be used with this mod.}
GlobalVariable  Property DDIDisableMaxVersionWarning Auto
{Whether or not to disable the DDI version 'too new' warning.}

; Messages
Message         Property MessageChecksStarted Auto
{The message shown to the player when the compatibility checks have started running.}
Message         Property MessageChecksFinished Auto
{The message shown to the player when the compatibility checks have finished running.}
Message         Property MessageCalcelmosCyborgMissing Auto
{The warning shown to the player when CalcelmosCyborg.esp could not be found.}
Message         Property MessageDDIMissing Auto
{The warning shown to the player when DDI could not be found.}
Message         Property MessageDDIOutdated Auto
{The warning shown to the player when the installed DDI version is too old.}
Message         Property MessageDDITooNew Auto
{The warning shown to the player when the installed DDI version is too new.}

; DDI
zadLibs         Property ddiLib Auto
{The DDI library. Used only to determine the version here.}

; Mod Information
; TODO Place optional dependencies here

Event OnInit()
    RegisterForSingleUpdate(5.0)
EndEvent

Event OnUpdate()
    ; Ensure that we are ingame before running the compatibility checks
    If(PlayerRef.Is3DLoaded())
        RunAllChecks(true)
    Else
        RegisterForSingleUpdate(5.0)
    EndIf
EndEvent

Event OnPlayerLoadGame()
    Debug.Trace("[CalcelmosCyborg] Game load detected - running checks.")
    RunAllChecks(false)
    Debug.Trace("[CalcelmosCyborg] Game load checks completed")
EndEvent

Function RunAllChecks(bool showMessages)
    {Runs all compatibility checks and logs appropriately.}
    IsDone = false
    Debug.Trace("[CalcelmosCyborg] Starting compatibility checks - errors are normal and expected.")
    If(showMessages)
        MessageChecksStarted.Show()
    EndIf

    ; Make sure that CalcelmosCyborg's esp and version are available
    CheckCalcelmosCyborg()

    ; Make sure that our dependencies are available and up to date
    CheckDDI()

    ; Check for any other mods here
    ; TODO Add those here

    If(showMessages)
        MessageChecksFinished.Show()
    EndIf
    Debug.Trace("[CalcelmosCyborg] Compatibility checks done.")
    IsDone = true
EndFunction

; ----- CALCELMO'S CYBORG ----- ;
Function CheckCalcelmosCyborg()
    {Makes sure that CalcelmosCyborg's esp is available (i.e. has not been merged into a different esp) and that its version number can be found.}
    If(!Game.GetFormFromFile(0x0097F3, "CalcelmosCyborg.esp") as GlobalVariable)
        ; If the warning property was filled (a newer version might have changed its name), use that
        If(MessageCalcelmosCyborgMissing)
            MessageCalcelmosCyborgMissing.Show()
        Else
            ; Otherwise, we'll have to use this method
            Debug.MessageBox("CalcelmosCyborg.esp could not be found. This is a SEVERE error - CalcelmosCyborg will not able to continue running.\n\nLikely reasons are:\n - An incomplete, corrupt or outdated installation of CalcelmosCyborg.\n - CalcelmosCyborg has been merged into a different esp file.\n\nPlease make sure that you have the latest version of CalcelmosCyborg installed and that it is NOT merged into a different esp before reporting this issue.")
        EndIf
    EndIf
EndFunction

; ---- DDI ---- ;
Function CheckDDI()
    {Checks whether or not DDI is loaded and shows a warning if it isn't.}
    If(Game.GetModByName("Devious Devices - Integration.esm") == 255)
        ; DDI is missing
        MessageDDIMissing.Show()
    ElseIf(ddiLib.GetVersion() < DDIMinVersion.GetValue())
        ; DDI is outdated
        MessageDDIOutdated.Show(ddiLib.GetVersionString() as float)
    ElseIf(ddiLib.getVersion() > DDIMaxVersion.GetValue() && DDIDisableMaxVersionWarning.GetValue() == 0)
        ; DDI is too new
        MessageDDITooNew.Show()
    EndIf
EndFunction
