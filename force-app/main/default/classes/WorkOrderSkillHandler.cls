/**************
 * @ Class Name        : WorkOrderSkillHandler
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle - Deloitte] 08/26/2020 : Added method syncSkillRequirements to sync data between Work Order Skills
 * 						 and Skill Requirements Object. Feature #7946971 
*********/
public with sharing class WorkOrderSkillHandler {
	public static List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
    
    public static void setSkillDescription(List<Work_Order_Skill__c> newWOSkill) {
        List<Id> skillsId = New List<Id>();
        for (Work_Order_Skill__c WOSkill : newWOSkill) {
            skillsId.add(WOSkill.Skill_Certification__c);
        }
        Map<Id, pse__skill__c> skills = new Map<Id, pse__skill__c>([SELECT Id,Long_Description__c FROM pse__Skill__c WHERE Id IN :skillsId]);

        for (Work_Order_Skill__c WOSkillNew : newWOSkill ) {
                if (WOSkillNew.Skill_Certification__c != null)
                    if(skills.get(WOSkillNew.Skill_Certification__c)!=null)
                        if (skills.get(WOSkillNew.Skill_Certification__c).Long_Description__c !=null )
                            WOSkillNew.Skill_Long_Description__c = skills.get(WOSkillNew.Skill_Certification__c).Long_Description__c;
            }
        }
 
    
    public static void syncSkillRequirements(List<Work_Order_Skill__c> newWOSkill){
        Set<String> skillSet = new Set<String>();
        Set<Id> workOrderSkillId = new Set<Id>();
        Set<Id> workOrderIdSet = new Set<Id>();
        Map<Id, List<SkillRequirement>> woToWOSkillRequirementMap;
        List<SkillRequirement> skillReqUpsert = new List<SkillRequirement>();
        
        for(Work_Order_Skill__c eachWOSkill : newWOSkill){
            workOrderIdSet.add(eachWOSkill.Work_Order__c);
            workOrderSkillId.add(eachWOSkill.Skill_Certification__c);
        }
        
        Map<Id, String> woSkillsMap; 
		if(workOrderSkillId.size() > 0){
			for(pse__Skill__c eachSkill : [SELECT Id, Name FROM pse__Skill__c WHERE Id IN :workOrderSkillId]){
				skillSet.add(eachSkill.Name);
				if(woSkillsMap == null || woSkillsMap.isEmpty()){
					woSkillsMap = new Map<Id, String>();
				}
				if(!woSkillsMap.containsKey(eachSkill.Id)){
					woSkillsMap.put(eachSkill.Id, eachSkill.Name);
				}
			}
		}
        
        
        Map<String, Id> skillsMap;        
        for(Skill eachSkill : [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel IN :skillSet]){
            if(skillsMap == null || skillsMap.isEmpty()){
                skillsMap = new Map<String, Id>();
            }
            if(!skillsMap.containsKey(eachSkill.MasterLabel)){
                skillsMap.put(eachSkill.MasterLabel, eachSkill.Id);
            }
        }
        
        if(woToWOSkillRequirementMap == null || woToWOSkillRequirementMap.isEmpty()){
            woToWOSkillRequirementMap = new Map<Id, List<SkillRequirement>>();
            List<SkillRequirement> woSkillReqList = [SELECT RelatedRecordId, SkillId, Skill.MasterLabel
                                                    FROM SkillRequirement
                                                    WHERE RelatedRecordId IN :workOrderIdSet];
            for(SkillRequirement eachSkillReq : woSkillReqList){
                if(!woToWOSkillRequirementMap.containsKey(eachSkillReq.RelatedRecordId)){
                    woToWOSkillRequirementMap.put(eachSkillReq.RelatedRecordId, new List<SkillRequirement>());
                }
                woToWOSkillRequirementMap.get(eachSkillReq.RelatedRecordId).add(eachSkillReq);
            }
        }

        for(Work_Order_Skill__c eachWoSkill : newWOSkill){
            List<SkillRequirement> existingSkillReqList = woToWOSkillRequirementMap.get(eachWoSkill.Work_Order__c);
            boolean skillReqExists = false;
            String woSkillName;
            if(woSkillsMap != null){
               woSkillName = woSkillsMap.get(eachWoSkill.Skill_Certification__c);
            }
            
            if(woSkillName != null && skillsMap != NULL && skillsMap.containsKey(woSkillName)){
                Id skillReqId = skillsMap.get(woSkillName);
                
                if(existingSkillReqList != null && !existingSkillReqList.isEmpty()){
                    
                    for(SkillRequirement eachSkillReq : existingSkillReqList){                        
                        if(woSkillName.equalsIgnoreCase(eachSkillReq.Skill.MasterLabel)){
                            SkillRequirement skReq = new SkillRequirement();
                            skReq.Id = eachSkillReq.Id;
                            skReq.SkillLevel = Integer.valueOf(eachWoSkill.Minimum_Rating__c);
                            skReq.FBE_IDS_Skill_Long_Description__c = eachWoSkill.Skill_Long_Description__c;
                            skillReqUpsert.add(skReq);
                            skillReqExists = true;
                            break;
                        }
                    }      
                }
                
                if(!skillReqExists){
                    SkillRequirement skReq = new SkillRequirement();
                    skReq.RelatedRecordId = eachWoSkill.Work_Order__c;
                    skReq.SkillId = skillReqId;
                    skReq.SkillLevel = Integer.valueOf(eachWoSkill.Minimum_Rating__c);
                    skReq.FBE_IDS_Skill_Long_Description__c = eachWoSkill.Skill_Long_Description__c;
                    skillReqUpsert.add(skReq);
                }
            }
        }

        if(!skillReqUpsert.isEmpty() || skillReqUpsert.size()>0 ){ //Added a size check as a part of chekMarx
            List<Database.UpsertResult> skillReqUpsertResult = Database.upsert(skillReqUpsert, false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(skillReqUpsert, skillReqUpsertResult, 'WorkOrderSkillHandler', 'syncSkillRequirements'));
            
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
        }       
    }
}