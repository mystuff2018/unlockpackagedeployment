public with sharing class FBE_OpportunityAuraHandler {
    
    @AuraEnabled
    public static List<OpportunityLineItem> getOptyLineItems(String opId){
        System.debug('inside getOptyLineItems ');
        return [SELECT Id, Product2.Name, Quantity,UnitPrice,FBE_Margin_Percent__c,Description,FBE_Quote_Number_Line__c, 
                FBE_Siebel_Revenue_Id__c FROM OpportunityLineItem WHERE OpportunityId =: opId];
    }
    
    @AuraEnabled
    public static Decimal updateOptyLineItems(List<OpportunityLineItem> actList){
        System.debug('inside updateOptyLineItems');
        Decimal optyAmount;
        if(actList.size()>0){
            try{
                update actList;
            }catch(Exception e){
                System.debug('Exception in updateOptyLineItems: '+e);
            }
        }
        
        if(actList.size()>0){
            OpportunityLineItem opl = [SELECT Id, Product2.Name,opportunity.Amount 
                                       FROM OpportunityLineItem where id=:actList[0].Id];
            System.debug('opl:  '+opl.opportunity.Amount);
            optyAmount = opl.opportunity.Amount;
        }
        return optyAmount;
    }
    
    @AuraEnabled
    public static void updateRevenueCheckBox(String optyId , boolean boo){
        System.debug('inside updateRevenueCheckBox '+optyId);
        Opportunity op = new Opportunity();
        op.Id = optyId;
        op.FBE_Revenue_Alert_Popup__c = boo;
        Update op;
    }
    
    @AuraEnabled
    public static void deleteOptyLineItem(String oplId){
        System.debug('inside delOpl'+oplId);
        Delete new OpportunityLineItem(Id=oplId);
    }
    
    @AuraEnabled
    public static String getOptyId(String oplId){
        System.debug('inside getOptyId'+oplId);
        OpportunityLineItem opl = [SELECT OpportunityId from OpportunityLineItem WHERE Id=:oplId];
        System.debug('optyId: '+opl.OpportunityId);
        return opl.OpportunityId;
    }
    
    @AuraEnabled
    public static string getRecordTypeName(String recordTypeId, String objectName) {
        system.debug('recordType'+Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(recordTypeId).getname());
        return Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(recordTypeId).getname();
    }
}