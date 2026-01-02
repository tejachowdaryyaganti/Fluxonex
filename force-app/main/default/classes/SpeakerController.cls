public with sharing class SpeakerController {

    @AuraEnabled(cacheable=true)
    public static List<Speaker__c> searchSpeakers(String nameKey, String speciality) {

        String key = '%' + (nameKey == null ? '' : nameKey) + '%';

        List<Speaker__c> speakers = [
            SELECT Id, Name, Email__c, Bio__c, Speciality__c
            FROM Speaker__c
            WHERE (Name = NULL OR Name LIKE :key)
            AND (Speciality__c = NULL OR Speciality__c = :speciality)
            ORDER BY Name
        ];

        return speakers;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isAvailable(Id speakerId, Date sessionDate) {

        Integer cnt = [
            SELECT Count()
            FROM Speaker_Assignment__c
            WHERE Speaker__c = :speakerId
            AND Session__r.Session_Date__c = :sessionDate
        ];

        return cnt == 0;
    }

    @AuraEnabled
    public static Id createAssignment(Id speakerId, Id sessionId) {

        Speaker_Assignment__c sa = new Speaker_Assignment__c(
            Speaker__c = speakerId,
            Session__c = sessionId
        );

        insert sa;
        return sa.Id;
    }

    @AuraEnabled(cacheable=true)
    public static Speaker__c getSpeaker(Id speakerId) {

        return [
            SELECT Id, Name, Bio__c, Speciality__c
            FROM Speaker__c
            WHERE Id = :speakerId
        ];
    }


@AuraEnabled(cacheable=true)
public static List<Session__c> getSessionsByDate(Id speakerId, Date sessionDate) {

    // Find sessions already booked by this speaker on that day
    Set<Id> booked = new Set<Id>();

    for (Speaker_Assignment__c sa : [
        SELECT Session__c
        FROM Speaker_Assignment__c
        WHERE Speaker__c = :speakerId
        AND Session__r.Session_Date__c = :sessionDate
    ]) {
        booked.add(sa.Session__c);
    }

    // Return ONLY free sessions for that date
    return [
        SELECT Id, Title__c, Start_Time__c, End_Time__c
        FROM Session__c
        WHERE Session_Date__c = :sessionDate
        AND Id NOT IN :booked
        ORDER BY Start_Time__c
    ];
}

@AuraEnabled
public static Id createAssignmentByDate(Id speakerId, Date sessionDate) {

    List<Session__c> sessions = [
        SELECT Id
        FROM Session__c
        WHERE Session_Date__c = :sessionDate
        LIMIT 1
    ];

    if(sessions.isEmpty()){
        throw new AuraHandledException('No sessions exist on this date. Please choose another date.');
    }

    Speaker_Assignment__c sa = new Speaker_Assignment__c(
        Speaker__c = speakerId,
        Session__c = sessions[0].Id
    );
    insert sa;
    return sa.Id;
}

}