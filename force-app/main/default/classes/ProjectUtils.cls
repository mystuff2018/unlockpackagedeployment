/***************************************************************************************
* Created By - Mithun Naik (DELL Team)
* Created On - December 03, 2021
* Story/Feature - 11440432,11295344.
* Purpose - DFN - Automate Project Group from PDM Selection - Enhancement.
* Note:- Commented class brought from dellmain is being commented, because it will not take care of bulk records, so created new code.
****************************************************************************************/
/*public class ProjectUtils {
    public static void updateGroup(Map<Id, pse__Proj__c> TriggerNewMap, List<pse__Proj__c> TriggerOld){
        List<Id> c = new List<Id>();
        pse__Proj__c p = new pse__Proj__c();
        Map<Id,pse__Proj__c> projLocalPdmId = new Map<Id,pse__Proj__c>();
        for(pse__Proj__c pr : TriggerOld){
            if(pr.pse__Group__c == null){
                p = TriggerNewMap.get(pr.id);
                c.add(TriggerNewMap.get(pr.id).PDM_Resource__c);
            } else if(pr.pse__Group__c != null && TriggerNewMap.get(pr.id).pse__Group__c == null){
                TriggerNewMap.get(pr.id).addError('The field Group cannot be blank');
            }
        }
        if(c.size() > 0 && TriggerNewMap.get(p.id).PDM_Resource__c != null){
            Contact selectContact = [SELECT pse__Group__c FROM Contact WHERE id IN :c LIMIT 1];
            p.pse__Group__c = selectContact.pse__Group__c;
        }
    }
}*/
public class ProjectUtils {
    public static void updateGroup(Map<Id, pse__Proj__c> oldRecords, List<pse__Proj__c> newRecords){
        //Map<Id, Id> mapProjIdIdToConId = new Map<Id, Id> ();
        Set<Id> conIdSet = new  Set<Id>();
        Map<Id, Contact> mapConIdToContact = new Map<Id, Contact>();
        
        for(pse__Proj__c pr : newRecords) {
            if(pr.pse__Group__c == null && oldRecords.get(pr.id).pse__Group__c != null){
                pr.addError('The field Group cannot be blank');
            } else if (pr.pse__Group__c == null && pr.PDM_Resource__c != null){
                //mapProjIdIdToConId.put(pr.Id, pr.PDM_Resource__c);
                conIdSet.add(pr.PDM_Resource__c);
            }
        }
        if (!conIdSet.isEmpty()) {
            mapConIdToContact =  New Map<Id, Contact>([SELECT Id, pse__Group__c FROM Contact WHERE Id =: conIdSet]);
        }
        if ( mapConIdToContact != null && !mapConIdToContact.isEmpty()) {
            for(pse__Proj__c pr : newRecords) {
                if (pr.pse__Group__c == null && pr.PDM_Resource__c != null && mapConIdToContact.containskey(pr.PDM_Resource__c)) {
                    pr.pse__Group__c = mapConIdToContact.get(pr.PDM_Resource__c).pse__Group__c;
                }
            }
        }    
    }
}