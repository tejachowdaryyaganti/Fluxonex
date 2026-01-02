public class SpeakerAssignmentHandler {

    public static void checkConflicts(List<Speaker_Assignment__c> newList,Map<Id, Speaker_Assignment__c> oldMap){
        Set<Id> speakerIds = new Set<Id>();
        Set<Id> sessionIds = new Set<Id>();

        for(Speaker_Assignment__c sa : newList){
            if(sa.Speaker__c != null && sa.Session__c != null){
                speakerIds.add(sa.Speaker__c);
                sessionIds.add(sa.Session__c);
            }
        }

        Map<Id, Session__c> newSessions = new Map<Id, Session__c>([SELECT Id, Session_Date__c, Start_Time__c, End_Time__c 
                                                                   FROM Session__c WHERE Id IN :sessionIds]);

        List<Speaker_Assignment__c> existingAssignments = [SELECT Id, Speaker__c, Session__r.Session_Date__c,Session__r.Start_Time__c, Session__r.End_Time__c
                                                        FROM Speaker_Assignment__c WHERE Speaker__c IN :speakerIds];

        Map<Id, List<Speaker_Assignment__c>> speakerMap = new Map<Id, List<Speaker_Assignment__c>>();

        for(Speaker_Assignment__c sa : existingAssignments){
            if(!speakerMap.containsKey(sa.Speaker__c)){
                speakerMap.put(sa.Speaker__c, new List<Speaker_Assignment__c>());
            }
            speakerMap.get(sa.Speaker__c).add(sa);
        }

        for(Speaker_Assignment__c sa : newList){

            Session__c newSession = newSessions.get(sa.Session__c);
            if(newSession == null) continue;

            List<Speaker_Assignment__c> existing = speakerMap.get(sa.Speaker__c);
            if(existing == null) continue;

            for(Speaker_Assignment__c old : existing){

                if(oldMap != null && oldMap.containsKey(sa.Id) && old.Id == sa.Id) continue;

                if(old.Session__r.Session_Date__c == newSession.Session_Date__c){

                    Boolean overlap =newSession.Start_Time__c < old.Session__r.End_Time__c && newSession.End_Time__c > old.Session__r.Start_Time__c;

                    if(overlap){
                        sa.addError('Speaker is already booked for this time.');
                        break;
                    }
                }
            }
        }
    }
}