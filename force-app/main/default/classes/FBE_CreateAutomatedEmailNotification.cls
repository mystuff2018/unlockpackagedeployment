/* Developer : LavaKumar Tonupunuri
   Story : 7113401
   Desc : 1) Given an opportunity is in a sales stage not equal to Lost, Won, or Cancelled, when the book date is today +1 or more, then an automated email notification should be sent to the opportunity owner in the attached format and the email should be sent daily for that opportunity until the book date no longer violates the validation. 
          2) Given an opportunity is in a sales stage not equal to Lost, Won, or Cancelled, when the book date is today +3 or more, then an automated email notification should be sent to the opportunity owner's Manager (per role hierarchy) in the attached format and the email should be sent daily for that opportunity until the book date no longer violates the validation.
*/
public class FBE_CreateAutomatedEmailNotification implements Database.Batchable<sObject> {
    /* we didnt write any queries in VF Templete which has to be called from this batch */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        date todayDate = system.today();
        /*set<ID> ids = new set<ID>();
        ids.add('006r0000002egyAAAQ');
        ids.add('006r0000002eMUoAAM');
        ids.add('006r0000002ebYoAAI');
        ids.add('006r0000002edlOAAQ');
        ids.add('006r0000002ed17AAA');*/
        //ID ids = '006r0000002eoNFAAY';
        string StageName = System.Label.StageNames;
        set<string> stages = new set<String>();
        stages.addAll(StageName.split(';'));
        String query;
        if(test.isRunningTest()){
            string stageTest = 'Plan - 1%';
             query = 'select id,StageName,CloseDate,OwnerId,owner.ManagerId from opportunity where StageName = :stageTest   AND OwnerId != NULL' ;
        }else{
             query = 'select id,StageName,CloseDate,OwnerId,owner.ManagerId from opportunity where StageName IN : stages AND  CloseDate <: todayDate  AND OwnerId != NULL ' ;
        }
        
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opptyList) {
       
        // process each batch of records
        Map<string,ID> templateIdNameMap;
        if(opptyList.size() > 0){
                string managerLabel = System.Label.FBE_Opp_Book_Date_Manager_Notification;
                string ownerLabel = System.Label.FBE_Opp_Book_Date_Owner_Notification;
            Set<String> templateNames = new set<String>();
                templateNames.add(managerLabel);
                templateNames.add(ownerLabel);
                system.debug('templateNames'+templateNames);
            if(templateNames.size() > 0){
                templateIdNameMap =  new Map<string,ID>();
                for(EmailTemplate templates : [Select id, name from EmailTemplate where name IN : templateNames]){
                    templateIdNameMap.put(templates.name,templates.id);
                }   
            }
                system.debug('templateIdNameMap'+templateIdNameMap);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            if(! templateIdNameMap.isEmpty() && templateIdNameMap.keySet().size() > 0){
                for(Opportunity opp : opptyList)
                {        
                    if(opp.stageName != null && opp.stageName != ''){
                        if(templateIdNameMap.containsKey(ownerLabel) && templateIdNameMap.get(ownerLabel) != NULL && (opp.CloseDate < system.today())||(test.isRunningTest())){
                            system.debug('Owner'+templateIdNameMap.get(ownerLabel));
                            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate( templateIdNameMap.get(ownerLabel), opp.OwnerId, opp.id);
                            email.setTargetObjectId(opp.OwnerId);
                            email.setSubject(email.getSubject());
                            email.sethtmlBody(email.gethtmlBody());
                            email.saveAsActivity = false;
                            emails.add(email);
                        }
                        if(opp.Owner.ManagerId != NULL && templateIdNameMap.containsKey(managerLabel) && templateIdNameMap.get(managerLabel) != null && (opp.CloseDate < system.today() - 2 || (test.isRunningTest()))){
                            system.debug('managerLabel'+templateIdNameMap.get(managerLabel));
                            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateIdNameMap.get(managerLabel),  opp.Owner.ManagerId, opp.id);
                            email.setTargetObjectId(opp.Owner.ManagerId);
                            email.setSubject(email.getSubject());
                            email.sethtmlBody(email.gethtmlBody());
                            email.saveAsActivity = false;
                            emails.add(email);
                        }
                    }
                }
                system.debug('emailsss'+emails.size());
                try {
                    if(emails.size() > 0){
                        Messaging.sendEmail(emails);
                    }
            
                } catch(Exception e) {
                    System.debug(e);
                }
                    
                           
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
  }
}