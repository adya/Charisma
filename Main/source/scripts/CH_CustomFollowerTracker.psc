Scriptname CH_CustomFollowerTracker extends activemagiceffect  
{Abstract script that can be registered in DialogueFollowerScript script to support custom followers}

DialogueFollowerScript Property base Auto


Actor _trackedFollower

Actor Property TrackedFollower
    Actor Function Get()
        Return _trackedFollower
    EndFunction
EndProperty

Bool Property IsFollowing
    Bool Function Get()
        If trackedFollower == None
            Return false   
        EndIf
        Return trackedFollower.IsPlayerTeammate()
    EndFunction
EndProperty

Bool wasFollowing

Event OnEffectStart(Actor akTarget, Actor akCaster)
    _trackedFollower = akTarget
    base.RegisterCustomFollower(self)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    _trackedFollower = None
    base.UnregisterCustomFollower(self)
EndEvent

; Checks whether given 
Bool Function IsFollowing(Actor akFollower)
    Debug.Trace("CHARISMA: " + akFollower.GetDisplayName() + ". IsPlayerTeammate = " + akFollower.IsPlayerTeammate())

    ; General check for teammates. This is a preferred way of detecting whether an actor is following you.
    If !akFollower.IsPlayerTeammate()
        Return false
    EndIf

    Debug.Trace("CHARISMA: " + akFollower.GetDisplayName() + ". WaitingForPlayer = " + akFollower.GetActorValue("WaitingForPlayer"))

    ; Inigo uses this trick for "dismissal", but always stays player's teammate
    If akFollower.GetActorValue("WaitingForPlayer") == -1
        Return false
    EndIf

    Return true
EndFunction

Event OnPackageChange(Package akOldPackage)
    Debug.Trace("CHARISMA: Changing the package! To: " + akOldPackage)

    Bool following = IsFollowing
    If wasFollowing != following
        base.OnFollowersCountChanged()
    EndIf

    wasFollowing = following

    Actor akTarget = GetTargetActor()

    If akTarget != None
        Bool follows = IsFollowing(akTarget)
        Debug.Trace("CHARISMA: " + akTarget.GetDisplayName() + Either(follows, " is following you", " no longer follows you"))

        If follows && !base.CanRecruitFollower()
            Debug.Notification(akTarget.GetDisplayName() + " can't follow you - Leadership is too low")
            ForceDismiss(akTarget)
        EndIf
    EndIf
EndEvent

; Forcefully dismisses given actor if they can't follow the player.
Function ForceDismiss(Actor akFollower)
    ; Inigo uses this -1 as an indicator of following status, 
    ; so we emulate the same dismissing process for him.
    If akFollower.HasKeywordString("CH_Inigo")
        akFollower.SetActorValue("WaitingForPlayer", -1)
    Else
        akFollower.SetPlayerTeammate(false, false)
        akFollower.SetActorValue("WaitingForPlayer", 0)
    EndIf
    akFollower.EvaluatePackage()

    akFollower.GetNthReferenceAlias(0)

    akFollower.
EndFunction

; Returns either the first or second string based on evaluated condition.
String Function Either(Bool condition, String first, String second)
    If condition
        Return first
    Else
        Return second
    EndIf
EndFunction


Scriptname CH_CustomFollowerBase

CH_CustomFollowerTracker Property 

; Checks whether this CH_CustomerFollower is tracking given Actor.
; Subclasses should 
Bool Function IsTracked(Actor akActor)
    Return False
EndFunction

ScriptName CH_InigoTracker extends CH_CustomFollowerBase

Bool Function IsFollowing(Actor akFollower)
EndFunction