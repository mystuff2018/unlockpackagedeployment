public class TimecardTriggerHandler {
     public Static void SendTimecardDetailsToNovora(List<pse__Timecard_Header__c> newTimeList){
    Set<ID> projectIds = new Set<ID>();
        for(pse__Timecard_Header__c th : newTimeList){
            projectIds.add(th.pse__Project__c);
        }
         
        List<pse__Timecard_Header__c> timecardList = new List<pse__Timecard_Header__c>();
        for(pse__Timecard_Header__c tm : [SELECT id, pse__Project__c,
                                                     pse__Project__r.pse__Start_Date__c, 
                                                     pse__Project__r.pse__End_Date__c, 
                                                     pse__Start_Date__c,
                                                     pse__End_Date__c,
                                                     FBE_IDS_Time_IntegrationStatus__c,
                                                     pse__Status__c FROM pse__Timecard_Header__c 
                                                     WHERE pse__Project__c IN :projectIds
                                                    ]){
              if(tm.pse__Project__c != null){
                System.debug('Project Id ' +tm.pse__Project__c);
                   if(tm.pse__Start_Date__c > tm.pse__Project__r.pse__Start_Date__c && tm.pse__End_Date__c < tm.pse__Project__r.pse__End_Date__c){    
                    System.debug('Start Date ' +tm.pse__Start_Date__c + ' Project Start ' +tm.pse__Project__r.pse__Start_Date__c);
                    System.debug('End Date ' +tm.pse__End_Date__c + 'Project End' +tm.pse__Project__r.pse__End_Date__c);
                    if(tm.pse__Status__c == 'Approved'){
                        System.debug('Status ' +tm.pse__Status__c);
                        System.debug('Before' +tm.FBE_IDS_Time_IntegrationStatus__c ); 
                         tm.FBE_IDS_Time_IntegrationStatus__c = 'Pending Sync';
                        System.debug('@@Siva' +tm.FBE_IDS_Time_IntegrationStatus__c );
                       
                    }
                }
            }          
                                                        
           }
         
    }
}