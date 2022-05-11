public class FBE_FPRM_DealExtnHandler {
    
    public static void handleAfterInsert(List<Deal_Extension__c> newList){
        System.debug('handlerAfterInsert');
        FBE_FPRM_Notification_Switch__c cms = FBE_FPRM_Notification_Switch__c.getOrgDefaults();
        List<Deal_Extension__c> apprDealExtnList = new List<Deal_Extension__c>();
        for(Deal_Extension__c dealExn : newList){
            if(dealExn.FBE_Extension_Request_Status__c == 'Approved' && cms.Send_Deal_Extn_Approval_Emails__c == true){
                apprDealExtnList.add(dealExn);
            }
        }
        if(apprDealExtnList.size() > 0){
            FBE_FPRM_DealExtnHelper.notifyPartnerUsers(apprDealExtnList , cms);
        }
    }
    
    public static void handleAfterUpdate(List<Deal_Extension__c> newList, Map<id,Deal_Extension__c> oldMap){
        System.debug('handleAfterUpdate');
        FBE_FPRM_Notification_Switch__c cms = FBE_FPRM_Notification_Switch__c.getOrgDefaults();
        List<Deal_Extension__c> approrRejectDealExtnList = new List<Deal_Extension__c>();
        for(Deal_Extension__c dealExn : newList){
            if((dealExn.FBE_Extension_Request_Status__c == 'Approved' && oldMap.get(dealExn.Id).FBE_Extension_Request_Status__c != 'Approved' && cms.Send_Deal_Extn_Approval_Emails__c == true) ||
               (dealExn.FBE_Extension_Request_Status__c == 'Rejected' && oldMap.get(dealExn.Id).FBE_Extension_Request_Status__c != 'Rejected' && cms.Send_Deal_Extn_Approval_Emails__c == true)){
                   approrRejectDealExtnList.add(dealExn);
               }
        }
        if(approrRejectDealExtnList.size() > 0){
            FBE_FPRM_DealExtnHelper.notifyPartnerUsers(approrRejectDealExtnList , cms);
        }
    }  
}