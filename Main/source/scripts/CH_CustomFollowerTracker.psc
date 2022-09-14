Scriptname CH_CustomFollowerTracker extends Actor  
{Abstract script that can be registered in DialogueFollowerScript script to support custom followers}

DialogueFollowerScript Property CH_DialogueFollower Auto

Bool wasFollowing

Event OnInit()
    Debug.Trace("CHARISMA: Initializing for " + self.GetDisplayName())
    If CH_DialogueFollower == None
        CH_DialogueFollower = Game.GetForm(0x000750BA) as DialogueFollowerScript
        If CH_DialogueFollower != None
            Debug.Trace("CHARISMA: Found DialogueFollowerScript")
        EndIf
    EndIf
EndEvent

; Event received when this actor starts a new package
; Event OnPackageStart(Package akNewPackage)
;     Debug.Trace("CHARISMA: OnPackageStart for " + self.GetDisplayName())
;     InvalidateFollowingState()
; EndEvent

Event OnPackageChange(Package akOldPackage)
    Debug.Trace("CHARISMA: OnPackageChange for " + self.GetDisplayName())
    InvalidateFollowingState()
EndEvent

; Event OnPackageEnd(Package akNewPackage)
;     Debug.Trace("CHARISMA: OnPackageEnd for " + self.GetDisplayName())
;     InvalidateFollowingState()
; EndEvent

Function InvalidateFollowingState()
    Debug.Trace("CHARISMA: Detecting follower status for " + self.GetDisplayName())
    Bool following = IsFollowing()
    Debug.Trace("CHARISMA: " + self.GetDisplayName() + Either(following, " is", " is not") + " following you. (" + Either(wasFollowing, "Was", "Was not") + " following before)")
    If wasFollowing && !following
        Debug.Trace("CHARISMA: " + self.GetDisplayName() + " Unregistering as custom follower")
        CH_DialogueFollower.UnregisterCustomFollower(self)
        wasFollowing = false
    ElseIf !wasFollowing && following
        Debug.Trace("CHARISMA: " + self.GetDisplayName() + " Registering as custom follower")
        If CH_DialogueFollower.RegisterCustomFollower(self)
            wasFollowing = true
        Else
            Debug.Trace("CHARISMA: " + self.GetDisplayName() + " can't follow you - Leadership is too low")
            Debug.Notification(self.GetDisplayName() + " can't follow you - Leadership is too low")
            ForceDismiss()
        EndIf

    EndIf
EndFunction


; Checks whether tracked actor is following the player.
; Override this method to provide custom conditions.
; Base function simply checks IsPlayerTeammate()
Bool Function IsFollowing()
    ; General check for teammates. This is a preferred way of detecting whether an actor is following you.
    Return self.IsPlayerTeammate()
EndFunction

; Forcefully dismisses currently tracked actor if they can't follow the player.
; Override this function to provide custom dismissal behavior.
; Base function performs default dismissal.
Function ForceDismiss()
    self.SetPlayerTeammate(false, false)
    self.SetActorValue("WaitingForPlayer", 0)
    self.EvaluatePackage()
EndFunction

; Returns either the first or second string based on evaluated condition.
String Function Either(Bool condition, String first, String second)
    If condition
        Return first
    Else
        Return second
    EndIf
EndFunction
