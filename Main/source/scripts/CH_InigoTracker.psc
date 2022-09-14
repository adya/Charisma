; Inigo uses this trick with "WaitingForPlayer = -1" for fake dismissal, but Inigo always stays player's teammate.
Scriptname CH_InigoTracker extends CH_CustomFollowerTracker  

Bool Function IsFollowing()
    Return self.GetActorValue("WaitingForPlayer") != -1
EndFunction

Function ForceDismiss()
    self.StopCombatAlarm()
	self.SetActorValue("WaitingForPlayer", -1.00000)
	self.EvaluatePackage()
EndFunction