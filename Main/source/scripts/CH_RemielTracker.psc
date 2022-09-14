Scriptname CH_RemielTracker extends CH_CustomFollowerTracker  

HLIORemiController _quest

HLIORemiController Property RemielQuest Hidden
    HLIORemiController Function Get()
        If _quest == None
            _quest = PO3_SKSEFunctions.GetFormFromEditorID("HLIORemiFollower") as HLIORemiController
        EndIf
        Return _quest
    EndFunction
EndProperty

Function ForceDismiss()
    RemielQuest.DismissFollower()
EndFunction