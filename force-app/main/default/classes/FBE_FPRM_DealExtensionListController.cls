/**
 * @description       : 
 * @author            : Sitaram Teki
 * @group             : 
 * @last modified on  : 02-24-2022
 * @last modified by  : Sitaram Teki
**/
public with sharing class FBE_FPRM_DealExtensionListController {
    @AuraEnabled(cacheable=true)
    public static List<Deal_Extension__c> getDealExtensionlist(String dealId) {
        // Getting the list of Deal Extension from where Id is in dealId
        if(string.isNotBlank(dealId)){
            string sql1 = 'SELECT Id, Name, FBE_Approval_Rejection_Reason__c, FBE_Approved_Rejected_By_Text__c,FBE_Approved_Rejected_By__c,FBE_Extension_Request_Reason__c,FBE_Extension_Request_Status__c,FBE_Deal_Registration__c FROM Deal_Extension__c WHERE FBE_Deal_Registration__c =:dealId ORDER BY Id DESC LIMIT 6';
            List<Deal_Extension__c> dealextensionList = Database.query(sql1);
           /* List<Deal_Extension__c> dealextensionList = [SELECT Id, Name, FBE_Approval_Rejection_Reason__c, FBE_Approved_Rejected_By_Text__c,FBE_Approved_Rejected_By__c,FBE_Extension_Request_Reason__c,FBE_Extension_Request_Status__c,FBE_Deal_Registration__c FROM Deal_Extension__c WHERE FBE_Deal_Registration__c =:dealId ORDER BY Id DESC LIMIT 6];*/
        return  dealextensionList;
        }
        else{
            return NULL;
        }
        
    }
    @AuraEnabled
    public static List<Deal_Extension__c> getDealExtlistnew(String dealId) {
        // Getting the list of Deal Extension from where Id is in dealId
        if(string.isNotBlank(dealId)){
            string sql2 = 'SELECT Id, Name, FBE_Approval_Rejection_Reason__c, FBE_Approved_Rejected_By_Text__c,FBE_Approved_Rejected_By__c,FBE_Extension_Request_Reason__c,FBE_Extension_Request_Status__c,FBE_Deal_Registration__c FROM Deal_Extension__c WHERE FBE_Deal_Registration__c =:dealId ORDER BY Id DESC';
            List<Deal_Extension__c> dealexnewList = Database.query(sql2);
           /* List<Deal_Extension__c> dealexnewList = [SELECT Id, Name, FBE_Approval_Rejection_Reason__c, FBE_Approved_Rejected_By_Text__c,FBE_Approved_Rejected_By__c,FBE_Extension_Request_Reason__c,FBE_Extension_Request_Status__c,FBE_Deal_Registration__c FROM Deal_Extension__c WHERE FBE_Deal_Registration__c =:dealId ORDER BY Id DESC];*/
        return  dealexnewList;
        }
        else{
            return NULL;
        }
        
    }
    @AuraEnabled
    public static List<Deal_Extension__c> refreshdealext(String dealId) {
        // Getting the list of Deal Extension from where Id is in dealId
        if(string.isNotBlank(dealId)){
            string sql3 ='SELECT Id, Name, FBE_Approval_Rejection_Reason__c, FBE_Approved_Rejected_By_Text__c,FBE_Approved_Rejected_By__c,FBE_Extension_Request_Reason__c,FBE_Extension_Request_Status__c,FBE_Deal_Registration__c FROM Deal_Extension__c WHERE FBE_Deal_Registration__c =:dealId ORDER BY Id DESC LIMIT 6';
            List<Deal_Extension__c> refreshdealextList =Database.query(sql3);
            /*List<Deal_Extension__c> refreshdealextList = [SELECT Id, Name, FBE_Approval_Rejection_Reason__c, FBE_Approved_Rejected_By_Text__c,FBE_Approved_Rejected_By__c,FBE_Extension_Request_Reason__c,FBE_Extension_Request_Status__c,FBE_Deal_Registration__c FROM Deal_Extension__c WHERE FBE_Deal_Registration__c =:dealId ORDER BY Id DESC LIMIT 6];*/
        return  refreshdealextList;
        }
        else{
            return NULL;
        }
        
    }

    @AuraEnabled
    public static Integer getsubmiteddealext(String dealId) {
        // Getting the count of Deal Extension from where Id is in dealId and Status is Submitted
        if(string.isNotBlank(dealId)){
        return  [SELECT COUNT() FROM Deal_Extension__c WHERE FBE_Deal_Registration__c =:dealId AND FBE_Extension_Request_Status__c='Submitted'];
        }
        else{
            return 0;
        }
        
    }
}