;/ Decompiled by Champollion V1.0.0
Source   : ccASVSSE001_TempleFactionScript.psc
Modified : 2021-07-27 20:15:19
Compiled : 2021-12-03 00:26:37
User     : builds
Computer : RKVBGSBUILD08
/;
scriptName ccASVSSE001_TempleFactionScript extends activemagiceffect

import ccasvsse001_CHSupportScript

dialoguefollowerscript property pDialogueFollower auto
quest property myQuest auto
Int property StageToCheck auto
faction property ccASVSSE001_TempleFaction auto

function OnEffectStart(Actor akTarget, Actor akCaster)

    myQuest.SetObjectiveCompleted(105, true)
    game.GetPlayer().AddtoFaction(ccASVSSE001_TempleFaction)
endFunction

function OnEffectFinish(Actor akTarget, Actor akCaster)

    if !myQuest.GetStageDone(StageToCheck)
        myQuest.SetObjectiveCompleted(105, false)
        myQuest.SetObjectiveDisplayed(105, true, false)
        Actor PlayerREF = game.GetPlayer()
        PlayerREF.RemovefromFaction(ccASVSSE001_TempleFaction)

        DismissFactionFollowers(pDialogueFollower, ccASVSSE001_TempleFaction)
    endIf
endFunction
