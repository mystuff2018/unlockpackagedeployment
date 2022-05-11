/**
* @description       : DealTriggerHandler is entry class for Deal Extension Trigger Context Variabes called from FBE_DealExtensionTrigger class
* @author            : Soumithri Rekha v
* @group             : 
* @last modified on  : 01-26-2022
* @last modified by  : 
**/
public class DealTriggerHandler {
    public static void handleTrigger(List<Deal_Extension__c> newRecordList, List<Deal_Extension__c> oldRecordList,Map<Id,Deal_Extension__c> newRecordMap, Map<Id,Deal_Extension__c> OldRecordMap, System.TriggerOperation triggerEvent ) {
        
        FBE_DealExtnApprl handlers = new FBE_DealExtnApprl(Trigger.isExecuting, Trigger.size);
        switch on triggerEvent {
            
            when BEFORE_INSERT {
            }
            when BEFORE_DELETE {
            }
            when BEFORE_UPDATE {
                handlers.updateApproveDeclineComments(newRecordList,OldRecordMap);
            }
            when AFTER_INSERT {
                FBE_FPRM_DealExtnHandler.handleAfterInsert(newRecordList);
            }
            when AFTER_UPDATE {
                FBE_FPRM_DealExtnHandler.handleAfterUpdate(newRecordList,OldRecordMap);
                handlers.allApproveCall(newRecordMap,OldRecordMap);
            }
            when AFTER_DELETE {
            }
            when AFTER_UNDELETE {
            }
        }
    }
}