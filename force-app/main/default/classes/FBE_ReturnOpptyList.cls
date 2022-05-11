/**************
*@ Class Name                                                    : FBE_ReturnOpptyList
*@ Description                                                   : class to return list of open opportunities to display as a related list on Lead Page
                                                                   Created for Story 9887060, Story 9886920.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 03-23-2021
*@ Modification Log                                              : [Siva Kumar Valluru - 5th Aug ] - FBE_Formatted_Book_Date__c appeneded this field for Story #10598980
                                                                 : [Siva Kumar Valluru-Dell] Defect #11317030 - Appended the FBE_Formatted_Amount__c in the SOQL queries.   
***************/

public class FBE_ReturnOpptyList {
    
    Id StandardRecTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Standard Opportunity').RecordTypeId;
    
         @AuraEnabled   
         public static List<opportunity> getOpptyList(Id LeadId){
             system.debug('LeadId in passed in Controller ' +LeadId);
             set<string> storeAccId = new set<string>();
             List<opportunity> opptyList = new List<opportunity>();
             Map<string,List<opportunity>> AccOpptyListMap = new Map<string,List<opportunity>>();
             
             if(LeadId != null){
                 Lead ld = [SELECT id, FBE_End_User_Account__c FROM Lead WHERE id= :LeadId LIMIT 1];
                 system.debug('ld ==> ' +ld);
                 string str = ld.FBE_End_User_Account__c;
                 storeAccId.add(str);
                 system.debug('storeAccId##### ' +storeAccId);            
                 
                 if(str != null && str != ''){  
                     system.debug('str inside if ' +str); 
                     for(opportunity opp : [SELECT Id,OwnerId,Owner.Name,Name,FBE_End_User__c,StageName,FBE_End_User__r.Name
                                            FROM Opportunity where FBE_End_User__c = :storeAccId AND 
                                            StageName NOT IN('Won - 100%','Lost - 0%','Cancelled - 0%') AND
                                            RecordType.developername = 'FBE_Standard_Opportunity'])
                     {
                         system.debug('Entered Loop #####');
                         opptyList.add(opp);
                     }
                     return opptyList;
                 }
                 
                 
                 else{
                     return opptyList;
                 }
             }
             else{
                 return null;
             }
         }
   
    
    
    @AuraEnabled   
    public static List<Opportunity> getRelatedOppty(Id accountId){
        system.debug('accountId in getRelatedOppty ' +accountId);
        if(accountId != null){
            return [SELECT Id, OwnerId,Owner.Name,FBE_End_User__r.Name,AccountId,Account.Name, Name,FBE_Opportunity_Number__c,Amount,FBE_Formatted_Amount__c, RecordTypeId,RecordType.Name,StageName,CloseDate,FBE_Formatted_Book_Date__c
                    FROM Opportunity 
                    where StageName NOT IN('Won - 100%','Lost - 0%','Cancelled - 0%') 
                    and FBE_End_User__c=:accountId
                    and RecordType.developername = 'FBE_Standard_Opportunity'];          
        }
        else{
            return null;
        }
     }
    @AuraEnabled    
    public static List<Opportunity> getSearchedOppty(Id accountId,String sname){         
         List<Opportunity> opptyList = new List<Opportunity>();
        String queryString = 'SELECT Id, OwnerId,Owner.Name,AccountId,Account.Name,Name,FBE_Opportunity_Number__c,FBE_End_User__r.Name,StageName,CloseDate,FBE_Formatted_Book_Date__c,'
            +'Amount,FBE_Formatted_Amount__c, RecordTypeId,RecordType.Name FROM Opportunity where '+
            'StageName NOT IN(\'Won - 100%\',\'Lost - 0%\',\'Cancelled - 0%\') and FBE_End_User__c=:accountId and RecordType.developername = \'FBE_Standard_Opportunity\'';
        String filterCondition = '';
                           
         if(sname!=null && sname!=''){
             filterCondition = filterCondition+' and (Name like \'%'+String.escapeSingleQuotes(sname)+'%\' OR FBE_Opportunity_Number__c like \'%'+String.escapeSingleQuotes(sname)+'%\')';
         }
         queryString = queryString + filterCondition ;
            System.debug('queryString '+queryString);
            try{
                opptyList = Database.query(queryString);
            }
            catch(Exception e){
                system.debug('Error '+e.getMessage());
            }   

        return opptyList;
    }    
}