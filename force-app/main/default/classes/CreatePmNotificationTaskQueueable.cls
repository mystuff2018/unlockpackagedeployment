/***************************************************************************************
* Created By - Mayuri Hegde
* Created On - Jun 30, 2021
* Feature - 10336429
* Purpose - Queueable class to create Project task when ever next billing genrate
****************************************************************************************/
public class CreatePmNotificationTaskQueueable implements Queueable{
	private list<pse__Proj__c> selectedProject ;
    public CreatePmNotificationTaskQueueable(List<pse__Proj__c> lstProjects) {
        this.selectedProject = lstProjects;
    }
    public void execute(QueueableContext context) {
        list<pse__Project_Task__c>lstNotificationTask = new list<pse__Project_Task__c>();
        // get all  PM Activities Task
        map<ID,pse__Project_Task__c>mapProjectIDWithPMActivityTask = new map<ID,pse__Project_Task__c>();
        for(pse__Project_Task__c pt:[Select ID,pse__Project__c,pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c from pse__Project_Task__c where pse__Project__c in: selectedProject and  Name ='PM Activities' and pse__Project__r.pse__Project_Manager__c != null]){
            mapProjectIDWithPMActivityTask.put(pt.pse__Project__c, pt);
        }
        for(pse__Proj__c proj: selectedProject){
            if(mapProjectIDWithPMActivityTask.containsKey(proj.ID)){
                pse__Project_Task__c newTask = new pse__Project_Task__c();
                newTask.pse__Parent_Task__c = mapProjectIDWithPMActivityTask.get(proj.ID).ID;
                //newTask.Assigned_Resource__c = proj.pse__Project_Manager__c;
                newTask.OwnerID = mapProjectIDWithPMActivityTask.get(proj.ID).pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c;
                newTask.pse__Project__c = proj.id;
                Time myTime = Time.newInstance(12, 0, 0, 0);
                DateTime dtGmt = DateTime.newInstance(proj.Next_Billing_Date__c, myTime);
                newTask.pse__Start_Date_Time__c = dtGmt;
                newTask.pse__Description__c  = proj.Billing_Cadence__c;
                newTask.Name = 'Next Billing Cycle:'+ String.valueOf(proj.Next_Billing_Date__c);
                lstNotificationTask.add(newTask);
            }
            
        }
        // create pm task
        TriggerHandler.bypass(FFProjectTaskTriggerHandler.class.getName());
        TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
        //TriggerHandler.bypass(ESProjectTriggerHandler.class.getName());
        insert lstNotificationTask;
        System.debug('lstNotificationTask'+lstNotificationTask);
        TriggerHandler.clearbypass(FFProjectTriggerHandler.class.getName());
        //TriggerHandler.clearbypass(ESProjectTriggerHandler.class.getName());
        TriggerHandler.clearbypass(FFProjectTaskTriggerHandler.class.getName());
    }
}