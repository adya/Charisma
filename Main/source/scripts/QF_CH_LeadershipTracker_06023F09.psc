;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname QF_CH_LeadershipTracker_06023F09 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
CH_MaximumFollowersCount.SetValueInt(2)
CH_DialogueFollower.OnFollowersCountChanged()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
CH_MaximumFollowersCount.SetValueInt(3)
CH_DialogueFollower.OnFollowersCountChanged()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
CH_MaximumFollowersCount.SetValueInt(4)
CH_DialogueFollower.OnFollowersCountChanged()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property CH_MaximumFollowersCount Auto

DialogueFollowerScript Property CH_DialogueFollower Auto
