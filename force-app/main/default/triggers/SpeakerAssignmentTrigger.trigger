trigger SpeakerAssignmentTrigger on Speaker_Assignment__c (before insert, before update) {
    if(Trigger.isBefore) {
        SpeakerAssignmentHandler.checkConflicts(Trigger.new, Trigger.oldMap);
    }
}