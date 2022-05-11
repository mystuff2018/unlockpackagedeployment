/**
 * @description       : this call will take Approval record id and returns the object name for which the approavl belongs to.
 * @author            : Sitaram Teki
 * @Stroy/Feature#    : Feature 9745379: FPRM SFDC - Hide or make a comment with the Reassign button inside the approval workflow object (Story 9746581: Prevent users from using the 'Reassign Button' in the deal registration workflow approval screen)
 * @last modified on  : 10-13-2021
 * @last modified by  : Sitaram Teki
**/
public with sharing class FBE_FPRM_GetObject_Name_Approval_Cls {
    @AuraEnabled(cacheable=true)
    public static String getobjectnameofapprovalrecord(Id recordId) {
try {
        if (recordId !=null)
        {  String rowid = recordId;

           /* List<ProcessInstanceWorkitem> results = [Select ProcessInstance.Status, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Id FROM ProcessInstanceWorkitem where Id = :recordId LIMIT 1];*/

           List<ProcessInstanceWorkitem> results = Database.query('Select ProcessInstance.Status, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Id FROM ProcessInstanceWorkitem where Id = :rowid LIMIT 1');

            System.debug('results  --->'+ results);
            List<Id> targetObjectIds = new List<Id>();
            for(ProcessInstanceWorkitem result : results)
                {
                targetObjectIds.add(result.ProcessInstance.TargetObject.Id);
                }
                        String objecttype = String.valueOf((targetObjectIds[0] == null) ? null : targetObjectIds[0].getSObjectType());
                        System.debug('dealid ' +targetObjectIds[0]);
                        System.debug('objecttype ' +objecttype);
                        return objecttype;
            }       
        else
        {
            return null;
        } 
}
catch (Exception ex) {
        System.debug('exception:' + ex);
        return null;    
        }
    }
}