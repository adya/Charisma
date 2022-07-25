ScriptName FollowerDeathScript extends ReferenceAlias

Event OnDeath(Actor akKiller)
	(GetOwningQuest() as DialogueFollowerScript).DismissSpecificFollowerAlias(Self)
EndEvent