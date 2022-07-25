Scriptname DLC1VQ06LockInScript extends ObjectReference  


Quest Property DLC1VQ06 auto
GlobalVariable Property VampireLine auto
DLC1_NPCMentalModelScript Property MM Auto
ReferenceAlias Property Serana auto
DialogueFollowerScript Property dfScript auto

Event OnTriggerEnter(ObjectReference akActivator)
    if (akActivator == Game.GetPlayer() && DLC1VQ06.GetStage() == 10)
        Serana.GetReference().MoveTo(Game.GetPlayer())
        ; If Player cannot recruit more followers and Serana is not one of the current followers,
        ; then we dismiss the first follower to make room for Serana. 
        ; (this is Vanilla logic, we only adjusted it for multiple followers setup)
        if !dfScript.CanRecruitFollower() && !dfScript.IsFollower(Serana.GetActorRef())
            dfScript.DismissFirstFollower()
        endif
        MM.LockIn()
        if (VampireLine.GetValueInt() != 0)
            MM.SetHomeMarker(2)
        else
            MM.SetHomeMarker(1)
        endif
        Delete()
    endif
EndEvent
