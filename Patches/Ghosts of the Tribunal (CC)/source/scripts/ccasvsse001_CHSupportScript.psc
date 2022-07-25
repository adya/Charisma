scriptName ccasvsse001_CHSupportScript
{ This script provides functions needed to integrate Charisma support }

Global Function DismissFactionFollowers(DialogueFollowerScript quest, Faction faction)

        ; Check all active followers and dismiss all that are memvers of TempleFaction
        ; Note: This corresponds to original behavior that was only checking for the first follower alias.
        ReferenceAlias follower1 = quest.Follower1
        ReferenceAlias follower2 = quest.Follower2
        ReferenceAlias follower3 = quest.Follower3
        ReferenceAlias follower4 = quest.Follower4

        if follower1.GetActorRef() != None && follower1.GetActorRef().IsInFaction(faction)
            quest.DismissSpecificFollowerAlias(follower1)
        endIf
        if follower2.GetActorRef() != None && follower2.GetActorRef().IsInFaction(faction)
            quest.DismissSpecificFollowerAlias(follower2)
        endIf
        if follower3.GetActorRef() != None && follower3.GetActorRef().IsInFaction(faction)
            quest.DismissSpecificFollowerAlias(follower3)
        endIf
        if follower4.GetActorRef() != None && follower4.GetActorRef().IsInFaction(faction)
            quest.DismissSpecificFollowerAlias(follower4)
        endIf
EndFunction