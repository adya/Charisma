;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__0003AA79 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
DarkBrotherhood DBScript = GetOwningQuest() as DarkBrotherhood
AKSpeaker.SetPlayerTeammate(False)
DialogueFollower.SetBrotherhoodInitiate1Following(false)
DBScript.Initiate1Follower = 0
DBScript.Initiate1State = 1
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

DialogueFollowerScript Property DialogueFollower Auto 
