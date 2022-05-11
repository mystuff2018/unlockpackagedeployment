/**
* Thomas Davis
* 2018-12-19
* FinancialForce.com, Inc.
* thdavis@financialforce.com
*
* This trigger prevents adding duplicate skills to the same WorkOrder as the Click FSE API does not accept duplicate skills in
* request payloads.
*/
trigger WorkOrderSkillTrigger on Work_Order_Skill__c (before insert,after insert, before update, after update)
{
    if (Trigger.isInsert && Trigger.isBefore){
        WorkOrderSkillHandler.setSkillDescription((List<Work_Order_Skill__c>) trigger.new);
    }
    
    //[Deloitte - Abhishek Kawle] : Added code as part of Feature #7946971 to maintain sync between Work Order Skill and Skills Requirement object.
    if(Trigger.isAfter){
        WorkOrderSkillHandler.syncSkillRequirements((List<Work_Order_Skill__c>) trigger.new);
    }
    Set<Id> workOrderIds = new Set<Id>();
    
    for (Work_Order_Skill__c skill : Trigger.new)
    {
        workOrderIds.add(skill.Work_Order__c);
    }
    
    Map<Id, List<Work_Order_Skill__c>> workOrderToWorkOrderSkillsMap;
    
    if (workOrderToWorkOrderSkillsMap == null || workOrderToWorkOrderSkillsMap.isEmpty())
    {
        workOrderToWorkOrderSkillsMap = new Map<Id, List<Work_Order_Skill__c>>();
        
        List<Work_Order_Skill__c> workOrderSkills =
            [
                SELECT Work_Order__c, Skill_Certification__c
                FROM Work_Order_Skill__c
                WHERE Work_Order__c IN :workOrderIds
                
            ];
        
        for (Work_Order_Skill__c skill : workOrderSkills)
        {
            if (!workOrderToWorkOrderSkillsMap.containsKey(skill.Work_Order__c))
            {
                workOrderToWorkOrderSkillsMap.put(skill.Work_Order__c, new List<Work_Order_Skill__c>());
            }
            workOrderToWorkOrderSkillsMap.get(skill.Work_Order__c).add(skill);
        }
    }
    
    for (Work_Order_Skill__c skill : Trigger.new)
    {
        List<Work_Order_Skill__c> existingSkills = workOrderToWorkOrderSkillsMap.get(skill.Work_Order__c);
        
        if (existingSkills != null && !existingSkills.isEmpty())
        {
            for (Work_Order_Skill__c existingSkill : existingSkills)
            {
                if (skill.Skill_Certification__c == existingSkill.Skill_Certification__c &&
                    skill.Id != existingSkill.Id)
                {
                    skill.addError('You cannot add duplicate skills.');
                }
            }
        }
    }
}