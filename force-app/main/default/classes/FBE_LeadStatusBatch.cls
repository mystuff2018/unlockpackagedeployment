/**************
* @Class       : FBE_LeadStatusBatch
* @Description   : This is Batch class to send automated emails to Lead owner's and their respected mangers on 
					every Monday
* @CreatedBy     : DeLL Team
* @CreatedOn     : 03-04-2020 [Soumithri Rekha, Sai]
***************/

global class FBE_LeadStatusBatch implements Database.Batchable<sObject>, Database.Stateful{
	
	public Map<id,List<id>> ownerLeadID = new Map<id,List<id>>();
	public Map<id,List<id>> mangerLeadID = new Map<id,List<id>>();
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id,ownerID,FBE_LeadOwnerMangerId__c from lead where Status in('New','Working') and FBE_Lead_Type__c = 'Inbound']);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        for(Lead lDetails : (List<Lead>)scope){
            if(lDetails.FBE_LeadOwnerMangerId__c!= null){
                if(!mangerLeadID.containsKey(lDetails.FBE_LeadOwnerMangerId__c)){
                    mangerLeadID.put(lDetails.FBE_LeadOwnerMangerId__c,new List<id>{lDetails.id});
                }
                else
                    mangerLeadID.get(lDetails.FBE_LeadOwnerMangerId__c).add(lDetails.id);
            }
            if(lDetails.OwnerId.getsobjecttype() != Group.SobjectType){
                if(!ownerLeadID.containsKey(lDetails.ownerID)){
                    ownerLeadID.put(lDetails.ownerID,new List<id>{lDetails.id});
                }
                else
                    ownerLeadID.get(lDetails.ownerID).add(lDetails.id);
            }
        }
		
    }
    global void finish(Database.BatchableContext BC){
		
		OrgWideEmailAddress owea;
		if(!Test.isRunningTest()){
			owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Case_Lead_Notification_OWD limit 1];
		}
        List<EmailTemplate> temp = [select id,name from EmailTemplate where name IN ('FBE_LeadStatusManagerNotification','FBE_LeadStatusOwnerNotification')
                                    Order By Name];
		
		List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        system.debug('mangerLeadID'+mangerLeadID);
        system.debug('ownerLeadID'+ownerLeadID);
        List<String> toAddressList = new List<String>();
        for(ID managerDetails : mangerLeadID.Keyset()){ 
            if(temp[0].id != null){
                toAddressList.add(managerDetails);
                Messaging.singleEmailMessage email = Messaging.renderStoredEmailTemplate(temp[0].id, null, mangerLeadID.get(managerDetails)[0]);
                email.toAddresses =  toAddressList;
                if(!Test.isRunningTest()){
				email.setOrgWideEmailAddressId(owea.Id);
				}
                email.setSaveAsActivity(false);
                emailList.add(email);
                toAddressList.clear();
            }
        }
        system.debug('emailList'+emailList);
        List<String> toOwnerAddressList = new List<String>();
        for(ID ownerDetails : ownerLeadID.Keyset()){ 
            if(temp[1] != null){
                toOwnerAddressList.add(ownerDetails);
                Messaging.singleEmailMessage emailnew = Messaging.renderStoredEmailTemplate(temp[1].id, null, ownerLeadID.get(ownerDetails)[0]);
                emailnew.toAddresses =  toOwnerAddressList;
				if(!Test.isRunningTest()){
                emailnew.setOrgWideEmailAddressId(owea.Id);
				}
                emailnew.setSaveAsActivity(false);
                emailList.add(emailnew);
                toOwnerAddressList.clear();
            }
        }
        system.debug('emailList'+emailList);
        if(emailList.size()>0){
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            }catch(Exception e){
                System.debug('Exception:: '+e + ' Exception cause::'+e.getCause());
            }
        }
		
		
	}
}