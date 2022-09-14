;/ Decompiled by Champollion V1.0.0
Source   : ccASVSSE001_HerHandTrialScript.psc
Modified : 2021-07-27 20:15:19
Compiled : 2021-12-03 00:26:36
User     : builds
Computer : RKVBGSBUILD08
/;
scriptName ccASVSSE001_HerHandTrialScript extends Quest

import ccasvsse001_CHSupportScript

Int property StageToCheck auto
globalvariable property ccASVSSE001_FightGlobal auto
referencealias[] property myHerHands auto
faction property ccASVSSE001_TempleFactionEnemy auto
perk property ccASVSSE001_MatchingSet auto
faction property ccASVSSE001_TempleFaction auto
faction property WEPlayerEnemy auto
referencealias property Alias_Portcullis auto
dialoguefollowerscript property pDialogueFollower auto

function HerHandLockObservers()

    Int i
    while i < myHerHands.length
        Actor pHerHand = myHerHands[i].GetActorRef()
        pHerHand.SetGhost(true)
        pHerHand.GetActorBase().SetEssential(true)
        pHerHand.SetAV("Aggression", 1 as Float)
        i += 1
    endWhile
    game.GetPlayer().RemovefromFaction(ccASVSSE001_TempleFaction)
    self.SetStage(8)
endFunction

function HerHandReset()

    Int i
    Actor PlayerREF = game.GetPlayer()
    if !self.GetStageDone(95)
        PlayerREF.AddtoFaction(ccASVSSE001_TempleFaction)
    endIf
    while i < myHerHands.length
        Actor pHerHand = myHerHands[i].GetActorRef()
        pHerHand.SetGhost(false)
        pHerHand.GetActorBase().SetEssential(false)
        pHerHand.SetAV("Aggression", 1 as Float)
        pHerHand.SetRestrained(false)
        pHerHand.SetRelationshipRank(PlayerREF, 3)
        i += 1
    endWhile
endFunction

function HerHandTrial(Actor akActor)

    akActor.SetGhost(false)
    akActor.AddtoFaction(WEPlayerEnemy)
    akActor.SetRestrained(false)
    akActor.EvaluatePackage()
    akActor.StartCombat(game.GetPlayer())
endFunction

function HerHandBeaten(Actor akActor)

    akActor.SetGhost(true)
    akActor.RemovefromFaction(WEPlayerEnemy)
    akActor.StopCombat()
    akActor.EvaluatePackage()
    ccASVSSE001_FightGlobal.Mod(1 as Float)
    self.UpdateCurrentInstanceGlobal(ccASVSSE001_FightGlobal)
    if self.GetStageDone(StageToCheck)
        self.SetObjectiveDisplayed(149, false, false)
        self.SetObjectiveDisplayed(149, true, false)
        self.SetObjectiveCompleted(149, true)
        self.SetObjectiveDisplayed(150, true, false)
    else
        self.SetObjectiveDisplayed(149, false, false)
        self.SetObjectiveDisplayed(149, true, false)
    endIf
endFunction

; Skipped compiler generated GotoState

function EveryoneTurnHostile()

    Int i
    self.SetObjectiveDisplayed(120, true, false)
    Actor PlayerREF = game.GetPlayer()
    DismissFactionFollowers(pDialogueFollower, ccASVSSE001_TempleFaction)
    while i < myHerHands.length
        Actor pHerHand = myHerHands[i].GetActorRef()
        pHerHand.SetRelationshipRank(PlayerREF, -3)
        i += 1
    endWhile
    PlayerREF.RemovePerk(ccASVSSE001_MatchingSet)
    PlayerREF.RemovefromFaction(ccASVSSE001_TempleFaction)
    PlayerREF.AddtoFaction(ccASVSSE001_TempleFactionEnemy)
    utility.Wait(1 as Float)
    self.SetObjectiveFailed(105, true)
    self.SetObjectiveFailed(125, true)
    self.SetObjectiveFailed(148, true)
    self.SetObjectiveFailed(149, true)
    self.SetObjectiveFailed(150, true)
    self.SetObjectiveFailed(200, true)
endFunction
