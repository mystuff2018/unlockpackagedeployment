global class BatchToPopulateCurrency implements Database.Batchable<SObject>,Schedulable{
    
    global void execute(SchedulableContext sc) {
        BatchToPopulateCurrency b = new BatchToPopulateCurrency(); 
        database.executebatch(b,50); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id, CurrencyIsoCode,Cost_Rate__c,Bill_Rate__c,Planned_Cost__c,Actual_Cost__c,pse__Estimated_Hours__c,pse__Actual_Hours__c, Cost_Rate_Card__c, Cost_Rate_Card__r.id from pse__Project_Task__c where CurrencyIsoCode!= null and Cost_Rate_Card__c!=null and Cost_Rate_Card__r.CurrencyIsoCode !=null]);
        
    }
    global void execute(Database.BatchableContext bc, List<pse__Project_Task__c > records){
        set<id> setRateCrdID = new set<id>();
        for(pse__Project_Task__c pt:records){
            setRateCrdID.add(pt.Cost_Rate_Card__c);
        }
        
        TriggerHandler.bypass(FFProjectTaskTriggerHandler.class.getName());
        TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
       // TriggerHandler.bypass(ESProjectTriggerHandler.class.getName());
       // TriggerHandler.bypass(CsProjectTaskHandler.class.getName());
        list<pse__Project_Task__c> selectedTask = new list<pse__Project_Task__c>();
        map<id,pse__Rate_Card__c>mapRateCards = new map<id,pse__Rate_Card__c>([Select ID,CurrencyIsoCode,pse__Average_Cost_Rate__c,pse__Suggested_Bill_Rate__c from pse__Rate_Card__c where id in :setRateCrdID]);
        for(pse__Project_Task__c projectTask : records){
            if(mapRateCards.containsKey(projectTask.Cost_Rate_Card__c) && projectTask.CurrencyIsoCode != mapRateCards.get(projectTask.Cost_Rate_Card__c).CurrencyIsoCode){
                pse__Rate_Card__c rateCrad = mapRateCards.get(projectTask.Cost_Rate_Card__c);
                projectTask.CurrencyIsoCode =  rateCrad.CurrencyIsoCode;
                projectTask.Cost_Rate__c = rateCrad.pse__Average_Cost_Rate__c;
                projectTask.Bill_Rate__c = rateCrad.pse__Suggested_Bill_Rate__c;
                projectTask.Planned_Cost__c = projectTask.pse__Estimated_Hours__c * rateCrad.pse__Average_Cost_Rate__c; 
                projectTask.Actual_Cost__c = projectTask.pse__Actual_Hours__c * rateCrad.pse__Average_Cost_Rate__c; 
                selectedTask.add(projectTask);
            }
        }
        if(!selectedTask.isEmpty()){
            update selectedTask;
            system.debug(':::::Task is updated with new Currency::::::');
        }
        TriggerHandler.clearbypass(FFProjectTaskTriggerHandler.class.getName());
        TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName());
      //  TriggerHandler.clearBypass(ESProjectTriggerHandler.class.getName());
      //  TriggerHandler.clearBypass(CsProjectTaskHandler.class.getName());
    }    
    global void finish(Database.BatchableContext bc){
        
    }  
    
    
}