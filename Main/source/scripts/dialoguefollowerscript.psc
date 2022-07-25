ScriptName DialogueFollowerScript extends Quest Conditional

GlobalVariable Property pPlayerFollowerCount Auto
GlobalVariable Property pPlayerAnimalCount Auto

ReferenceAlias property pAnimalAlias Auto

Faction Property pDismissedFollower Auto
Faction Property pCurrentFollower Auto
Faction Property CurrentHirelingFaction Auto

Message Property  FollowerDismissMessage Auto
Message Property AnimalDismissMessage Auto
Message Property  FollowerDismissMessageWedding Auto
Message Property  FollowerDismissMessageCompanions Auto
Message Property  FollowerDismissMessageCompanionsMale Auto
Message Property  FollowerDismissMessageCompanionsFemale Auto
Message Property  FollowerDismissMessageWait Auto

SetHirelingRehire Property HirelingRehireScript Auto

ReferenceAlias Property Speaker Auto
{Reference to an actor who is speaking to the player at the moment. Used to identify which of the followers it is}

;Property to tell follower to say dismissal line
Int Property iFollowerDismiss Auto Conditional

; PATCH 1.9: 77615: remove unplayable hunting bow when follower is dismissed
Weapon Property FollowerHuntingBow Auto
Ammo Property FollowerIronArrow Auto

;USKP 2.1.3 - For Mjoll's poorly thought out "first time in Windhelm" idle.
int Property USKPMjollInWindhelm = 0 Auto Conditional

;;;;;;;;;;;;;;;;;;;; Followers Handling ;;;;;;;;;;;;;;;;;;;;;;;

ReferenceAlias Property Follower1 Auto
ReferenceAlias Property Follower2 Auto
ReferenceAlias Property Follower3 Auto
ReferenceAlias Property Follower4 Auto

GlobalVariable Property CH_MaximumFollowersCount Auto

; This flag is needed to track custom Serana following mechanism implemented in DLC1_NPCMentalModelScript.
; See SetSeranaFollowing below for more details.
Bool IsSeranaReserved = false
; This flag is needed to track custom Serana following mechanism implemented in CompanionsHousekeepingScript.
; See SetCompanionsFollowing below for more details.
Bool IsCompanionsReserved = false
; This flag is needed to track custom Dark Brotherhood following mechanism implemented in DarkBrotherhood script.
; See SetCiceroFollowing below for more details.
; Note: I wasn't sure whether Dark Brotherhood quest forbids recruiting all three Brotherhood followers at once, so I decided to make them as separate reservations.
Bool IsCiceroReserved = false
; This flag is needed to track custom Dark Brotherhood following mechanism implemented in DarkBrotherhood script.
; See SetDarkBrotherhoodInitiate1Following below for more details.
Bool IsBrotherhoodInitiate1Reserved = false
; This flag is needed to track custom Dark Brotherhood following mechanism implemented in DarkBrotherhood script.
; See SetDarkBrotherhoodInitiate2Following below for more details.
Bool IsBrotherhoodInitiate2Reserved = false

; NOTE: This one is unused yet, probably will be utilized in compatibility stuff with custom followers.
; This is potentially error-prone approach as it is easy to break by not balancing calls to increase and decrease this counter.
; But it is more flexible than having individual flags for each custom follower.
; Counter that tracks number of custom followers, 
; that are not recruited through default followers mechanism (this script).
; This mostly addresses NPCs that are assigned to follow you during quests like Serana.
Int CustomFollowersCount = 0

; Updates PlayerFollowerCount global variable to let the game know if we can still recruit people.
;
; This one is kind of an "event". It should be called whenever there are changes in the followers system.
; Though, such changes should not be done outside of this script. 
; With the exception of LeadershipTracker quest that reacts to Leadership perks.
;
; IMPORTANT: This should be the only place that modifies PlayerFollowerCount global variable.
; If something else modifies PlayerFollowerCount it should be considered as incompatibility
; and corresponding script should be patched accordingly.
; Otherwise you'll end up unable to recruit potential followers even though Leadership allows you to.
Function OnFollowersCountChanged()
    If CanRecruitFollower()
        Debug.Trace("You can recruit additional followers")
        pPlayerFollowerCount.SetValueInt(0)
    Else 
        Debug.Trace("All follower aliases are taken. Current Followers Count = " + CurrentFollowersCount)
        pPlayerFollowerCount.SetValueInt(1)
    EndIf
EndFunction

; Flag indicating whether Player has any active followers.
Bool Property HasFollowers
    Bool Function Get()
        Return CurrentFollowersCount > 0
    EndFunction
EndProperty

; Checks that given Actor is one of the active followers.
Bool Function IsFollower(Actor candidate)
    Return FollowerAliasFor(candidate) != None
EndFunction

; Checks whether we've reached either the maximum number of supported followers or soft limit of maximum followers we can recruit (e.g. Leadership perk bonuses).
Bool Function CanRecruitFollower()
    Return CurrentFollowersCount < CH_MaximumFollowersCount.GetValueInt() && EmptyFollowerAlias() != None
EndFunction

; Counts currently occupied aliases, including reserved by custom followers.
Int Property CurrentFollowersCount Hidden
    Int Function Get()
        Int count = 0
        If Follower1.GetActorRef() != None
            count += 1
        EndIf
        If Follower2.GetActorRef() != None
            count += 1
        EndIf
        If Follower3.GetActorRef() != None
            count += 1
        EndIf
        If Follower4.GetActorRef() != None
            count += 1
        EndIf

        ; Treat custom follower reservations as additional phantom followers.
        If IsSeranaReserved
            count += 1 
        EndIf
        If IsBrotherhoodInitiate1Reserved
            count += 1 
        EndIf
        If IsBrotherhoodInitiate2Reserved
            count += 1
        EndIf
        If IsCiceroReserved
            count += 1
        EndIf
        If IsCompanionsReserved
            count += 1
        EndIf
        Return count
    EndFunction
EndProperty

; Finds an alias that references current Speaker.
ReferenceAlias Function SpeakerFollowerAlias()
    If Speaker == None
    ; If no speaker detected, then there is no need to search for it. Actually it will match the first empty follower slot as None == None.
        Return None
    ElseIf Follower1.GetActorRef() == Speaker.GetActorRef()
        Return Follower1
    ElseIf Follower2.GetActorRef() == Speaker.GetActorRef()
        Return Follower2
    ElseIf Follower3.GetActorRef() == Speaker.GetActorRef()
        Return Follower3
    ElseIf Follower4.GetActorRef() == Speaker.GetActorRef()
        Return Follower4
    Else
        Return None
    EndIf
EndFunction
        
; Finds the first empty alias suitable for new follower.
ReferenceAlias Function EmptyFollowerAlias()
    If Follower1.GetActorRef() == None
        Debug.Trace("Found Empty Follower Alias: Follower1")
        Return Follower1
    ElseIf Follower2.GetActorRef() == None
        Debug.Trace("Found Empty Follower Alias: Follower2")
        Return Follower2
    ElseIf Follower3.GetActorRef() == None
        Debug.Trace("Found Empty Follower Alias: Follower3")
        Return Follower3
    ElseIf Follower4.GetActorRef() == None
        Debug.Trace("Found Empty Follower Alias: Follower4")
        Return Follower4
    Else
        Debug.Trace("No Empty Follower Aliases")
        Return None
    Endif
EndFunction
        
; Finds the first alias that references currently active follower.
ReferenceAlias Function FirstFollowerAlias()
    If Follower1.GetActorRef() != None
        Debug.Trace("Found first active Follower Alias: Follower1 " + Follower1.GetActorRef())
        Return Follower1
    ElseIf Follower2.GetActorRef() != None
        Debug.Trace("Found first active Follower Alias: Follower2 " + Follower2.GetActorRef())
        Return Follower2
    ElseIf Follower3.GetActorRef() != None
        Debug.Trace("Found first active Follower Alias: Follower3 " + Follower3.GetActorRef())
        Return Follower3
    ElseIf Follower4.GetActorRef() != None
        Debug.Trace("Found first active Follower Alias: Follower4 " + Follower4.GetActorRef())
        Return Follower4
    Else
        Debug.Trace("No Active Follower Aliases")
        Return None
    Endif
EndFunction

; Finds the first alias that references given Follower.
ReferenceAlias Function FollowerAliasFor(Actor Follower)
    If Follower == None
        ; If given Follower is None, then there is no need to search for it. Actually it will match the first empty follower slot as None == None.
        Return None
    ElseIf Follower1.GetActorRef() == Follower
        Debug.Trace("Found first active Follower Alias: Follower1 " + Follower)
        Return Follower1
    ElseIf Follower2.GetActorRef() == Follower
        Debug.Trace("Found first active Follower Alias: Follower2 " + Follower)
        Return Follower2
    ElseIf Follower3.GetActorRef() == Follower
        Debug.Trace("Found first active Follower Alias: Follower3 " + Follower)
        Return Follower3
    ElseIf Follower4.GetActorRef() == Follower
        Debug.Trace("Found first active Follower Alias: Follower4 " + Follower)
        Return Follower4
    Else
        Debug.Trace("No Active Follower Aliases")
        Return None
    Endif
EndFunction

;;;;;;;;;;;;; Main functions to manipulate followers. These are used to add or remove actors as Player's followers.

Function SetFollower(ObjectReference FollowerRef)
    Actor FollowerActor = FollowerRef as Actor
    Debug.Trace("SetFollower " + FollowerActor + ". Current followers: " + CurrentFollowersCount)
    If FollowerActor == None || FollowerAliasFor(FollowerActor) != None
        Debug.Trace("SetFollower: Attempted to set either not an actor or already active follower - " + FollowerRef, 2)
        Return
    EndIf

    ReferenceAlias pFollowerAlias = EmptyFollowerAlias()
    ; If we were unable to find an empty alias for follower (reached maximum supported count)
    ; or we are not allowed to get more followers then we should skip.
    If pFollowerAlias && CurrentFollowersCount < CH_MaximumFollowersCount.GetValueInt()
        
        FollowerActor.RemoveFromFaction(pDismissedFollower)
        If FollowerActor.GetRelationshipRank(Game.GetPlayer()) < 3 && FollowerActor.GetRelationshipRank(Game.GetPlayer()) >= 0
            FollowerActor.SetRelationshipRank(Game.GetPlayer(), 3)
        EndIf
        FollowerActor.SetPlayerTeammate()
        ;FollowerActor.SetAV("Morality", 0)
        pFollowerAlias.ForceRefTo(FollowerActor)
        OnFollowersCountChanged()
    Else
        Debug.Trace("SetFollower: Couldn't set another follower - You've reached the limit.", 1)
    EndIf
    
EndFunction

Function FollowerWait()
    ReferenceAlias pFollowerAlias = SpeakerFollowerAlias()
    Debug.Trace("FollowerWait " + pFollowerAlias.GetActorRef())
    actor FollowerActor = pFollowerAlias.GetActorReference()
    FollowerActor.SetAv("WaitingForPlayer", 1)
    ;SetObjectiveDisplayed(10, abforce = true)
    ;follower will wait 3 days
    pFollowerAlias.RegisterForUpdateGameTime(72)
    
EndFunction

Function FollowerFollow()
    ReferenceAlias pFollowerAlias = SpeakerFollowerAlias()
    Debug.Trace("FollowerFollow " + pFollowerAlias.GetActorRef())
    actor FollowerActor = pFollowerAlias.GetActorReference()
    If FollowerActor
        FollowerActor.SetAv("WaitingForPlayer", 0)
    EndIf
    SetObjectiveDisplayed(10, abdisplayed = false)
    pFollowerAlias.UnregisterForUpdateGameTime() ; USKP 2.0.1 - Follower should no longer be running this timer if picked up before the 3 days are up.
    
EndFunction

; Use this method instead of DismissFollower when you need to dismiss a specific follower.
; This method is useful mostly in FollowerAliasScript and FollowerDeathScript, to ensure that followers are clean up.
; For other cases see DismissSpecificFollower.
Function DismissSpecificFollowerAlias(ReferenceAlias Follower, Int iMessage = 0, Int iSayLine = 1)
    Debug.Trace("DismissSpecificFollowerAlias: " + Follower.GetActorRef())
    Actor FollowerActor = Follower.GetActorRef()
    If FollowerActor && FollowerActor.IsInFaction(pCurrentFollower)
        
        If !FollowerActor.IsDead()
            If iMessage == 0
                FollowerDismissMessage.Show()
            ElseIf iMessage == 1
                FollowerDismissMessageWedding.Show()
            ElseIf iMessage == 2
                FollowerDismissMessageCompanions.Show()
            ElseIf iMessage == 3
                FollowerDismissMessageCompanionsMale.Show()
            ElseIf iMessage == 4
                FollowerDismissMessageCompanionsFemale.Show()
            ElseIf iMessage == 5
                FollowerDismissMessageWait.Show()
            Else
                ;failsafe
                FollowerDismissMessage.Show()
            EndIf
        EndIf
        ; Deliberatly perform the same routine regardless of wheather given actor is dead or not
        ; This should (theoretically) be more compatible with ressurections as it will perform all routines, so that resurrected actor could be recruited again.

        Follower.UnregisterForUpdateGameTime() ; USKP 2.0.1 - A dismissed follower should no longer be running this timer.
        FollowerActor.StopCombatAlarm()
        FollowerActor.AddToFaction(pDismissedFollower)
        FollowerActor.SetPlayerTeammate(false)
        FollowerActor.RemoveFromFaction(CurrentHirelingFaction)
        FollowerActor.SetAV("WaitingForPlayer", 0)
        
        ; PATCH 1.9: 77615: remove unplayable hunting bow when follower is dismissed
        FollowerActor.RemoveItem(FollowerHuntingBow, 999, true)
        FollowerActor.RemoveItem(FollowerIronArrow, 999, true)
        ; END Patch 1.9 fix
        
        ;hireling rehire function
        HirelingRehireScript.DismissHireling(FollowerActor.GetActorBase())

        If !FollowerActor.IsDead() && iSayLine == 1
            iFollowerDismiss = 1
            FollowerActor.EvaluatePackage()
            ;Wait for follower to say line
            Utility.Wait(2)
        EndIf
         
        ; Received Follower alias is already one of the tracked follower aliases.
        Follower.Clear()
        iFollowerDismiss = 0

        OnFollowersCountChanged()
        
    EndIf
EndFunction

; Dismisses 
Function DismissSpecificFollower(Actor FollowerActor, Int iMessage = 0, Int iSayLine = 1)
    Debug.Trace("DismissSpecificFollower: " + FollowerActor)
    ReferenceAlias Follower = FollowerAliasFor(FollowerActor)

    If Follower
        DismissSpecificFollowerAlias(Follower, iMessage, iSayLine)
    Else
        Debug.Trace("DismissSpecificFollowerActor: Given actor is not an active follower " + FollowerActor)
    EndIf
EndFunction

Function DismissFirstFollower(Int iMessage = 0, Int iSayLine = 1)
    ReferenceAlias pFollowerAlias = FirstFollowerAlias()
    If pFollowerAlias != None
        Debug.Trace("DismissFirstFollower: Dismissing " + pFollowerAlias.GetActorRef())
        DismissSpecificFollowerAlias(pFollowerAlias, iMessage, iSayLine)
    EndIf
EndFunction

; IMPORTANT: THIS FUNCTION SHOULD NOT BE USED OUTSIDE OF DIALOGUES WITH REGULAR FOLLOWERS.
;
; It is replaced with alternatives:
;   - DismissSpecificFollower(Actor) - dismisses specified actor if they are in a followers list.
;   - DismissSpecificFollowerAlias(Alias) - dismisses follower that specified alias holds. This is internal function.
;   - DismissFirstFollower() - dismisses the first follower in the list. This is used when.
; 
; When dimissing regular followers through dialogue, DialogueFollowerScript will keep track of who you're speaking to,
; so that DismissFollower will be performed on the desired follower.
; If no Speaker found, this method will do nothing.
Function DismissFollower(Int iMessage = 0, Int iSayLine = 1)
    Debug.Trace("Using DismissFollower is discouraged, it has been replaced with other variants to support multi-follower setup", 1)
    ReferenceAlias pFollowerAlias = SpeakerFollowerAlias()

    If pFollowerAlias != None
        Debug.Trace("DismissFollower: Dismissing the Speaker")
        DismissSpecificFollowerAlias(pFollowerAlias, iMessage, iSayLine)
        ; If Speaker is detected, then we should reset this alias, 
        ; so that any future calls to DialogueFollower won't try to use invalid Speaker.
        Speaker.Clear()
    Else
        Debug.Trace("DismissFollower: Speaker is either not specified or not an active follower. No one will be dismissed.", 1)
    EndIf
EndFunction

;;;;;;;;;;;;; Below are handling of Vanilla "custom followers".
;;;;;;;;;;;;; These are followers that would force following you, dismissing any active followers to make room if needed.

; This is specific function for DLC1_NPCMentalModelScript, 
; to ensure that Serana reserves spot for one follower without actually occupying it.
; This is needed to track custom Serana following mechanism implemented in DLC1_NPCMentalModelScript.
; IDK, why custom following mechanism is needed, but I'm not willing to make assumptions and change that :)
Function SetSeranaFollowing(Bool isFollowing)
    ; Handle cases when Serana joins the Player, but all available follower spots are taken - dismiss the first one to make room.
    If !IsSeranaReserved && isFollowing && !CanRecruitFollower()
        DismissFirstFollower()
    EndIf
    IsSeranaReserved = isFollowing
    OnFollowersCountChanged()
EndFunction

; This is specific function for DarkBrotherhood, 
; to ensure that Brotherhood followers reserve spot for one follower without actually occupying it.
; This is needed to track custom Brotherhood following mechanism implemented in DarkBrotherhood.
; IDK, why custom following mechanism is needed, but I'm not willing to make assumptions and change that :)
Function SetCiceroFollowing(Bool isFollowing)
    ; Handle cases when Cicero joins the Player, but all available follower spots are taken - dismiss the first one to make room.
    If !IsCiceroReserved && isFollowing && !CanRecruitFollower()
        DismissFirstFollower()
    EndIf
    IsCiceroReserved = isFollowing
    OnFollowersCountChanged()
EndFunction

; This is specific function for DarkBrotherhood, 
; to ensure that Brotherhood followers reserve spot for one follower without actually occupying it.
; This is needed to track custom Brotherhood following mechanism implemented in DarkBrotherhood.
; IDK, why custom following mechanism is needed, but I'm not willing to make assumptions and change that :)
Function SetBrotherhoodInitiate1Following(Bool isFollowing)
    ; Handle cases when 1st Brotherhood Initiate joins the Player, but all available follower spots are taken - dismiss the first one to make room.
    If !IsBrotherhoodInitiate1Reserved && isFollowing && !CanRecruitFollower()
        DismissFirstFollower()
    EndIf
    IsBrotherhoodInitiate1Reserved = isFollowing
    OnFollowersCountChanged()
EndFunction

; This is specific function for DarkBrotherhood, 
; to ensure that Brotherhood followers reserve spot for one follower without actually occupying it.
; This is needed to track custom Brotherhood following mechanism implemented in DarkBrotherhood.
; IDK, why custom following mechanism is needed, but I'm not willing to make assumptions and change that :)
Function SetBrotherhoodInitiate2Following(Bool isFollowing)
    ; Handle cases when 2nd Brotherhood Initiate joins the Player, but all available follower spots are taken - dismiss the first one to make room.
    If !IsBrotherhoodInitiate2Reserved && isFollowing && !CanRecruitFollower()
        DismissFirstFollower()
    EndIf
    IsBrotherhoodInitiate2Reserved = isFollowing
    OnFollowersCountChanged()
EndFunction

; This is specific function for CompanionsHousekeepingScript, 
; to ensure that Companions reserve spot for one follower without actually occupying it.
; This is needed to track custom Companions following mechanism implemented in CompanionsHousekeepingScript.
; IDK, why custom following mechanism is needed, but I'm not willing to make assumptions and change that :)
Function SetCompanionsFollowing(Bool isFollowing)
     ; Handle cases when Companion joins the Player, but all available follower spots are taken - dismiss the first one to make room.
     If !IsCompanionsReserved && isFollowing && !CanRecruitFollower()
        DismissFirstFollower()
    EndIf
    IsCompanionsReserved = isFollowing
    OnFollowersCountChanged()
EndFunction

Bool Function IsCompanionsFollowing()
    Return IsCompanionsReserved
EndFunction

    
;;;;;;;;;;;;;;;;;;;; Animals Handling ;;;;;;;;;;;;;;;;;;;;;;;
    
Function SetAnimal(ObjectReference AnimalRef)
    actor AnimalActor = AnimalRef as Actor
    ;don't allow lockpicking
    AnimalActor.SetAV("Lockpicking", 0)
    AnimalActor.SetRelationshipRank(Game.GetPlayer(), 3)
    AnimalActor.SetPlayerTeammate(abCanDoFavor = false)
    pAnimalAlias.ForceRefTo(AnimalActor)
    ;AnimalActor.AllowPCDialogue(True)
    pPlayerAnimalCount.SetValue(1)
EndFunction

Function AnimalWait()
    
    actor AnimalActor = pAnimalAlias.GetActorReference()
    AnimalActor.SetAv("WaitingForPlayer", 1)
    ;SetObjectiveDisplayed(20, abforce = true)
    ;follower will wait 3 days
    pAnimalAlias.RegisterForUpdateGameTime(72)
    
EndFunction
Function AnimalFollow()
    
    actor AnimalActor = pAnimalAlias.GetActorReference()
    AnimalActor.SetAv("WaitingForPlayer", 0)
    SetObjectiveDisplayed(20, abdisplayed = false)
    pAnimalAlias.UnregisterForUpdateGameTime() ; USKP 2.0.1 - Animal should no longer be running this timer if picked up before the 3 days are up.
    
EndFunction
Function DismissAnimal()
    
    If pAnimalAlias.GetActorReference() && pAnimalAlias.GetActorReference().IsDead() == False
        actor DismissedAnimalActor = pAnimalAlias.GetActorReference()
        pAnimalAlias.UnregisterForUpdateGameTime() ; USKP 2.0.1 - A dismissed animal should no longer be running this timer.
        DismissedAnimalActor.SetActorValue("Variable04", 0)
        ;DismissedAnimalActor.AllowPCDialogue(False)
        pPlayerAnimalCount.SetValue(0)
        pAnimalAlias.Clear()
        AnimalDismissMessage.Show()
    EndIf
    
EndFunction