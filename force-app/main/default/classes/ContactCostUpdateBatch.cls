global class ContactCostUpdateBatch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id PSArecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PSA_Resource').getRecordTypeId();
    	return Database.getQueryLocator([SELECT Id, pse__Region__c, pse__Resource_Role__c, pse__Default_Cost_Rate__c FROM Contact WHERE pse__Region__c != null AND pse__Resource_Role__c != null AND RecordTypeId =:PSArecordTypeId]);
    }
    
    global void execute(Database.BatchableContext BC, list<Contact> contactList){
        try{
            list<Contact> contactCostList = new list<Contact>();

            for(pse__Rate_Card__c r : [SELECT Id, pse__Role__c, pse__Region__c, pse__Average_Cost_Rate__c FROM pse__Rate_Card__c WHERE pse__Role__c != null AND pse__Region__c != null]){                  
                for(Contact c : contactList){                   
                    if(c.pse__Region__c == r.pse__Region__c && c.pse__Resource_Role__c == r.pse__Role__c && c.pse__Default_Cost_Rate__c != r.pse__Average_Cost_Rate__c){  
                        c.pse__Default_Cost_Rate__c = r.pse__Average_Cost_Rate__c;
                        contactCostList.add(c);
                    }                              
                }
            }
            
            if(!contactCostList.isEmpty()){
                Database.update(contactCostList);
            }
        }
        catch(Exception e){
            System.debug('Error : '+e.getMessage());
        }
    } 
    
    global void finish(Database.BatchableContext BC){}
    
}