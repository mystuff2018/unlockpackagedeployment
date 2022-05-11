/**************
 * @ Trigger Name      : SkillCertificationRatingTrigger
 * @ Description       : Created as part of Feature #7946971.
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 08-27-2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/
trigger SkillCertificationRatingTrigger on pse__Skill_Certification_Rating__c (after insert, after update, after Delete ) {
	if(Trigger.isAfter){
        if(Trigger.isInsert){
            FBE_IDS_SkillCertificationRatingHandler.syncServiceResourceSkills((Map<ID,pse__Skill_Certification_Rating__c>) trigger.newMap);
        }else if(Trigger.isUpdate){
            FBE_IDS_SkillCertificationRatingHandler.syncServiceResourceSkills((Map<ID,pse__Skill_Certification_Rating__c>) trigger.newMap);
        }else if(Trigger.isDelete){
            FBE_IDS_SkillCertificationRatingHandler.syncServiceResourceSkills((Map<ID,pse__Skill_Certification_Rating__c>) trigger.oldMap);
        }
    }
}