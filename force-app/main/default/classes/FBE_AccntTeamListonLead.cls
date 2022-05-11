public without sharing class FBE_AccntTeamListonLead {

    @AuraEnabled
    public static List<AccountTeamMember> returnAccMember(Id LeadId){
        set<string> AccntId = new set<string>();
        List<AccountTeamMember> AccTeamList = new List<AccountTeamMember>();
        
                 if(LeadId != null){
                 Lead ld = [SELECT id, FBE_Account_Name__c, FBE_End_User_Account__c FROM Lead WHERE id= :LeadId LIMIT 1];
                 system.debug('ld ==> ' +ld);
                 string str = ld.FBE_Account_Name__c;
                 AccntId.add(str);
                 system.debug('str ' +str);      
                     
                     ATMSkipValidation__c tempSkipValidation =  [SELECT Name,Skip_Validation__c FROM ATMSkipValidation__c LIMIT 1];

                     tempSkipValidation.Skip_Validation__c = true;
                     upsert tempSkipValidation;
                 
                 if(str != null && str != ''){  
                     system.debug('str inside if ' +str); 
                     for(AccountTeamMember ATM : [SELECT Id, AccountId, UserId, User.Name, FBE_User_Name__c, TeamMemberRole FROM AccountTeamMember
                                              WHERE AccountId = :AccntId])
                     {
                         ATM.FBE_User_Lookup__c = ATM.UserId;
                         AccTeamList.add(ATM);
                     }
                     
                     system.debug('AccTeamList Before Update ' +AccTeamList);
                     update AccTeamList;
                     tempSkipValidation.Skip_Validation__c = false;
                     update tempSkipValidation;
                     return AccTeamList;
                 }
                 
                 
                 else{
                     return AccTeamList;
                 }
             }
             else{
                 return null;
             }
    }
    
    @AuraEnabled   
    public static List<AccountTeamMember> getAccTeam(Id accountId){
        system.debug('accountId in getRelatedOppty ' +accountId);
        List<AccountTeamMember> ATMList = new List<AccountTeamMember>();
        
        ATMSkipValidation__c tempSkipValidation =  [SELECT Name,Skip_Validation__c FROM ATMSkipValidation__c LIMIT 1];

                     tempSkipValidation.Skip_Validation__c = true;
                     upsert tempSkipValidation;
        
        if(accountId != null){
            List<AccountTeamMember> ATM = [SELECT Id, AccountId, UserId, User.Name, FBE_User_Name__c,TeamMemberRole FROM AccountTeamMember WHERE AccountId = :accountId];
            for(AccountTeamMember TeamMem : ATM){
                TeamMem.FBE_User_Lookup__c = TeamMem.UserId;
                ATMList.add(TeamMem);
            }
            update ATMList;
         //   return [SELECT Id, AccountId, UserId, User.Name, FBE_User_Name__c, TeamMemberRole FROM AccountTeamMember
                                         //     WHERE AccountId = :accountId];   
            system.debug('ATMList ' +ATMList );
            
            tempSkipValidation.Skip_Validation__c = false;
            update tempSkipValidation;
            return ATMList;       
        }
        else{
            return null;
        }
     }
    
    
        @AuraEnabled
    public static List<AccountTeamMember> returnEndUserAccMember(Id LeadId){
        set<string> AccntId = new set<string>();
        List<AccountTeamMember> AccTeamList = new List<AccountTeamMember>();
        
                 if(LeadId != null){
                 Lead ld = [SELECT id, FBE_Account_Name__c, FBE_End_User_Account__c FROM Lead WHERE id= :LeadId LIMIT 1];
                 system.debug('ld ==> ' +ld);
                 string str = ld.FBE_End_User_Account__c;
                 AccntId.add(str);
                 system.debug('str ' +str);  
                     
                     ATMSkipValidation__c tempSkipValidation =  [SELECT Name,Skip_Validation__c FROM ATMSkipValidation__c LIMIT 1];

                     tempSkipValidation.Skip_Validation__c = true;
                     upsert tempSkipValidation;
                 
                 if(str != null && str != ''){  
                     system.debug('str inside if ' +str); 
                     for(AccountTeamMember ATM : [SELECT Id, AccountId, UserId, User.Name, FBE_User_Name__c, TeamMemberRole FROM AccountTeamMember
                                              WHERE AccountId = :AccntId])
                     {
                         ATM.FBE_User_Lookup__c = ATM.UserId;
                         AccTeamList.add(ATM);
                     }
                     update AccTeamList;
                     tempSkipValidation.Skip_Validation__c = false;
                     update tempSkipValidation;
                     return AccTeamList;
                 }
                 
                 
                 else{
                     return AccTeamList;
                 }
             }
             else{
                 return null;
             }
    }
    
}