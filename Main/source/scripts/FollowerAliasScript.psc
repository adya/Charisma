ScriptName FollowerAliasScript extends ReferenceAlias

Event OnActivate(ObjectReference akActionRef)
	Debug.Trace("OnActivate " + akActionRef)
	If akActionRef != Game.GetPlayer()
		Return
	EndIf
	GetOwningQuestCH().Speaker.ForceRefTo(Self.GetActorRef())
EndEvent

Event OnUpdateGameTime()
	;kill the update if the follower isn't waiting anymore
	If Self.GetActorRef().GetAv("WaitingforPlayer") == 0
		UnRegisterForUpdateGameTime()
	Else
 		Debug.Trace(self + " Dismissing the follower because he is waiting and 3 days have passed.")
		GetOwningQuestCH().DismissSpecificFollowerAlias(self, 5)
	EndIf	
	
EndEvent

Event OnUnload()
	;if follower unloads while waiting for the player, wait three days then dismiss him.
	If Self.GetActorRef().GetAv("WaitingforPlayer") == 1
		GetOwningQuestCH().FollowerWait()
	EndIf

EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	If (akTarget == Game.GetPlayer())
 		Debug.Trace(self + " Dismissing follower because he is now attacking the player")		
		GetOwningQuestCH().DismissSpecificFollowerAlias(self)
	EndIf

EndEvent

Event OnDeath(Actor akKiller)
	Debug.Trace(self + " Clearing the follower because the player killed him.")
	GetOwningQuestCH().Speaker.Clear()
	GetOwningQuestCH().DismissSpecificFollowerAlias(self)
EndEvent

DialogueFollowerScript Function GetOwningQuestCH()
	Return GetOwningQuest() as DialogueFollowerScript
EndFunction