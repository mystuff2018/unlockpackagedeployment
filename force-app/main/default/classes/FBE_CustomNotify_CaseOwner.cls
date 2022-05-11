/**************
*@ Class Name                                                    : FBE_CustomNotify_CaseOwner
*@ Description                                                   : This class is written to invoke handler methods.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 19-05-2021 [Siva Kumar Valluru]
*@ Modification Log                                              : 
***************/ 
public class FBE_CustomNotify_CaseOwner
{

// Method used to update the CaseId upon task creation
 public static void InsertCaseId(List<Task> TaskRec){
     
    ID TaskFPSRecId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('FPS Task Request').getRecordTypeId(); 
    String sObjName;
     
     for(Task t: TaskRec){
         if(t.Whatid != Null && t.RecordTypeId == TaskFPSRecId){
             Schema.SObjectType sobjectType = t.Whatid.getSObjectType();
             sObjName = sobjectType.getDescribe().getName();
             system.debug('Object Name is ' + sObjName); 
            if(sObjName == 'Case'){
                t.FBE_Case__c = t.Whatid;
                
            }
             
         }
     }    
 
 }
 
 // Method used to update the CaseId if whatid is updated
 public static void UpdateCaseId(List<Task> newList, Map<Id,Task> oldMap){
     
     ID TaskFPSRecId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('FPS Task Request').getRecordTypeId(); 
     String sObjName;
     
     for(Task t: newList){
         
         if(t.RecordTypeId == TaskFPSRecId && t.Whatid != oldMap.get(t.id).Whatid){
             Schema.SObjectType sobjectType = t.Whatid.getSObjectType();
             sObjName = sobjectType.getDescribe().getName();
            system.debug('Object Name is ' + sObjName); 
            if(sObjName == 'Case'){
                t.FBE_Case__c = t.Whatid;        
            }
            else
             t.FBE_Case__c =null;
         } 
     }
 }
 


}