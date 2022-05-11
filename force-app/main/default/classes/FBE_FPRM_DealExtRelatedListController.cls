public with sharing class FBE_FPRM_DealExtRelatedListController {  

    @AuraEnabled  
    public static RelatedListResult fetchRecs( String recId, String sObjName, String parentFldNam, String strCriteria ) {  
        
        String strTitle = ' (';           
        List < sObject > listsObjects = new List < sObject >();  
        RelatedListResult obj = new RelatedListResult();  
        String strSOQL = 'SELECT Id FROM ' + sObjName + ' WHERE ' + parentFldNam + ' = \'' + recid + '\'';  
        if ( String.isNotBlank( strCriteria ) )  
            strSOQL += ' ' + strCriteria;  
        strSOQL += ' LIMIT 4';  
        listsObjects = Database.query( strSOQL );    
        Integer intCount = listsObjects.size();  
        if ( intCount > 3 ) {  
            
            List < sObject > tempListsObjects = new List < sObject >();  
            for ( Integer i = 0; i <3; i++ )  
                tempListsObjects.add( listsObjects.get( i ) );  
            
            obj.listsObject = tempListsObjects;  
            strTitle += '3+';  
            
        } else {  
            
            obj.listsObject = listsObjects;  
            strTitle += String.valueOf( intCount );  
            
        }  
        strTitle += ')';        
        obj.strTitle = strTitle;  
        return obj;  
        
    }  
    
    public class RelatedListResult {  
        
        @AuraEnabled  
        public String strTitle;  
        @AuraEnabled  
        public List < sObject > listsObject;  
        
    }  
     @AuraEnabled
    public static list<Deal_Extension__c> fetchRecords(String recordIds){
        return [select id,Name,FBE_Extension_Request_Reason__c,FBE_Sequence_Number__c,FBE_Approved_Rejected_By__r.Name,FBE_Approved_Rejected_By_Text__c,FBE_Deal_Registration__c,FBE_Extension_Request_Status__c,FBE_Approval_Rejection_Reason__c from Deal_Extension__c where FBE_Deal_Registration__c =: recordIds ORDER BY CreatedDate DESC];        
    }
    
    @AuraEnabled
    public static boolean getRecords(String recIds){
        if(recIds.startsWith('a02')){
        boolean bln = [select FBE_Eligible_for_Extension__c from Deal_Registration__c where id =: recIds][0].FBE_Eligible_for_Extension__c;
        return bln;  
        }
        else
            return false;
    }
    
}