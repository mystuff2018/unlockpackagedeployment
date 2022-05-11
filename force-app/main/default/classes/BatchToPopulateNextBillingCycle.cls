/***************************************************************************************
* Created By - Mayuri Hegde
* Created On - Jun 29, 2021
* Feature - 10336429
* Purpose - Batch class to advance the next billing date
****************************************************************************************/
global class BatchToPopulateNextBillingCycle implements Database.Batchable<SObject>,Schedulable {    
    global void execute(SchedulableContext sc) {
      BatchToPopulateNextBillingCycle b = new BatchToPopulateNextBillingCycle(); 
      database.executebatch(b); 
   }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string query = ''; 
        return Database.getQueryLocator([Select ID,pse__Project_Manager__c,Next_Billing_Date__c,Billing_Cadence__c,Billing_Period__c from pse__Proj__c where pse__Is_Active__c = true and Next_Billing_Date__c = TODAY and (pse__Billing_Type__c = 'Time and Materials'
               or Deal_Type__c = 'Custom')]);
        //return Database.getQueryLocator([Select ID,pse__Project_Manager__c,Next_Billing_Date__c,Billing_Cadence__c,Billing_Period__c from pse__Proj__c where ID ='a2U050000004nbGEAQ']);
    }
    global void execute(Database.BatchableContext bc, List<pse__Proj__c> lstProjects) {
        list<pse__Project_Task__c>lstNotificationTask = new list<pse__Project_Task__c>();
        // get all  PM Activities Task
        map<ID,pse__Project_Task__c>mapProjectIDWithPMActivityTask = new map<ID,pse__Project_Task__c>();
        for(pse__Project_Task__c pt:[Select ID,pse__Project__c,pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c from pse__Project_Task__c where pse__Project__c in: lstProjects and  Name ='PM Activities' and pse__Project__r.pse__Project_Manager__c != null]){
            mapProjectIDWithPMActivityTask.put(pt.pse__Project__c, pt);
        }
        Date nextMonth15 = date.newInstance(Date.today().year(), Date.today().month()+1, 15); 
        for (pse__Proj__c proj : lstProjects) {
            // update next bill date
            if(proj.Billing_Cadence__c != null ){
                if(proj.Billing_Cadence__c == 'Weekly'){
                    proj.Next_Billing_Date__c = proj.Next_Billing_Date__c.addDays(7);
                }else if(proj.Billing_Cadence__c == 'Monthly'){
                    proj.Next_Billing_Date__c = proj.Next_Billing_Date__c.addMonths(1);
                }else if(proj.Billing_Cadence__c == 'Quarterly'){
                    proj.Next_Billing_Date__c = proj.Next_Billing_Date__c.addMonths(3);
                    System.debug('Quarterly'+proj.Next_Billing_Date__c);
                }
            }else{
                // set next month 15
                proj.Next_Billing_Date__c = nextMonth15;
            }
            if(mapProjectIDWithPMActivityTask.containsKey(proj.ID)){
                pse__Project_Task__c newTask = new pse__Project_Task__c();
                newTask.pse__Parent_Task__c = mapProjectIDWithPMActivityTask.get(proj.ID).ID;
                newTask.OwnerID = mapProjectIDWithPMActivityTask.get(proj.ID).pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c;
                newTask.pse__Project__c = proj.id;
                //anewTask.Assigned_Resource__c = proj.pse__Project_Manager__c;
                Time myTime = Time.newInstance(12, 0, 0, 0);
                DateTime dtGmt = DateTime.newInstance(proj.Next_Billing_Date__c, myTime);
                newTask.pse__Start_Date_Time__c = dtGmt;
                newTask.pse__Description__c  = proj.Billing_Cadence__c;
                newTask.Name = 'Next Billing Cycle:'+ String.valueOf(proj.Next_Billing_Date__c);
                system.debug('newTask:::'+newTask);
                lstNotificationTask.add(newTask);
            }
        }
        // update project
        TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
        //TriggerHandler.bypass(ESProjectTriggerHandler.class.getName());
        Update lstProjects;
        
        // create pm task
        TriggerHandler.bypass(FFProjectTaskTriggerHandler.class.getName());
        if(Test.isRunningTest()){
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
            Account duplicateAccount = new Account(Name='dupe'); 
            list<Database.SaveResult> sr = Database.insert(lstNotificationTask, dml); 
        }else{
            insert lstNotificationTask;
        }
        TriggerHandler.clearbypass(FFProjectTaskTriggerHandler.class.getName()); 
        TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName());
        //TriggerHandler.clearBypass(ESProjectTriggerHandler.class.getName());
    }
    global void finish(Database.BatchableContext bc) {

    }
}