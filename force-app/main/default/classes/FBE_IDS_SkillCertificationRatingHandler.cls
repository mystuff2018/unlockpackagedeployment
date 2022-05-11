/**************
 * @ Class Name        : FBE_IDS_SkillCertificationRatingHandler
 * @ Description       : This is a handler class for SkillCertificationRatingTrigger. It has following methods:
 * 						 1) syncServiceResourceSkills - Upserts the Service Resource Skill object based on changes in Skill Certification Rating records.
 * 						 Created as part of Feature #7946971.
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 08-27-2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/
public class FBE_IDS_SkillCertificationRatingHandler {
	public static List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
    
    public static void syncServiceResourceSkills(Map<ID,pse__Skill_Certification_Rating__c> newSCRatingsMap){
        List<pse__Skill_Certification_Rating__c> newSCRatings = newSCRatingsMap.values();
        Set<String> skillCertSet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>(); //To store the contact lookup on pse__Skill_Certification_Rating__c > pse__Resource__c
        //Set<Id> resourceIdSet = new Set<Id>();
        Set<Id> skillCertIdSet = new Set<Id>();
        Map<Id, String> skillCertsMap;
        Map<String, Id> skillsMap;
        Map<Id, Id> contactToUserMap;
        Map<ServiceResource, List<ServiceResourceSkill>> serviceResourcetoSRSMap;
        List<ServiceResourceSkill> srsUpserList = new List<ServiceResourceSkill>();
        //List<ServiceResourceSkill> srsSkillsToDelete = new List<ServiceResourceSkill>();
        for(pse__Skill_Certification_Rating__c eaSCR : newSCRatings){
            contactIdSet.add(eaSCR.pse__Resource__c);
            skillCertIdSet.add(eaSCR.pse__Skill_Certification__c);
        }       
        
        if(skillCertIdSet != null){
            for(pse__Skill__c eachSkill : [SELECT Id, Name FROM pse__Skill__c WHERE Id IN :skillCertIdSet]){
                skillCertSet.add(eachSkill.Name);
                if(skillCertsMap == null || skillCertsMap.isEmpty()){
                    skillCertsMap = new Map<Id, String>();
                }
                if(!skillCertsMap.containsKey(eachSkill.Id)){
                    skillCertsMap.put(eachSkill.Id, eachSkill.Name);
                }
            }
        }
        //System.debug('pse__skill__c Records List: '+skillCertsMap);
        
        if(skillCertSet != null){
            for(Skill eachSkill : [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel IN :skillCertSet]){
                if(skillsMap == null || skillsMap.isEmpty()){
                    skillsMap = new Map<String, Id>();
                }
                if(!skillsMap.containsKey(eachSkill.MasterLabel)){
                    skillsMap.put(eachSkill.MasterLabel, eachSkill.Id);
                }
            }
        }
        //System.debug('Skills Records List: '+skillsMap);
        
        for(Contact eaCon : [SELECT Id, pse__Salesforce_User__c FROM Contact WHERE Id IN :contactIdSet]){
            
            if(contactToUserMap == null || contactToUserMap.isEmpty()){
                contactToUserMap = new Map<Id, String>();
            }
            if(!contactToUserMap.containsKey(eaCon.Id)){
                contactToUserMap.put(eaCon.Id, eaCon.pse__Salesforce_User__c);
            }
            
        }
        
        if((serviceResourcetoSRSMap == null || serviceResourcetoSRSMap.isEmpty()) && contactToUserMap != null){
            serviceResourcetoSRSMap = new Map<ServiceResource, List<ServiceResourceSkill>>();
            
            for(ServiceResource eachSR : [SELECT Id, RelatedRecordId, (SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId, SkillId, Skill.MasterLabel
                                                                       FROM ServiceResourceSkills)
                                          FROM ServiceResource
                                          WHERE RelatedRecordId IN :contactToUserMap.values()]){
                                              
                  serviceResourcetoSRSMap.put(eachSR, eachSR.ServiceResourceSkills);
				//srsSkillsToDelete.addAll(eachSR.ServiceResourceSkills);
            }
        }
        //System.debug('Service Resource to SRS Map: '+serviceResourcetoSRSMap);
		for(pse__Skill_Certification_Rating__c eachSCR : newSCRatings){
				if(contactToUserMap.containsKey(eachSCR.pse__Resource__c)){
					System.debug('Contact To User Map record for User: ' +eachSCR.pse__Resource__c+ ' User record: ' +contactToUserMap.get(eachSCR.pse__Resource__c)); 
					
					boolean srsExists = false;
					String scrSkillName = skillCertsMap.get(eachSCR.pse__Skill_Certification__c);
					//System.debug('Skills Map contains scr skill: ' +scrSkillName+ ' >>> ' +skillsMap.containsKey(scrSkillName));
					
					if(skillsMap.containsKey(scrSkillName)){
						
						if(serviceResourcetoSRSMap != null && !serviceResourcetoSRSMap.isEmpty()){
							for(ServiceResource eaSRObj : serviceResourcetoSRSMap.keyset()){
								if(contactToUserMap.get(eachSCR.pse__Resource__c) == eaSRObj.RelatedRecordId){
									List<ServiceResourceSkill> existingSRS = serviceResourcetoSRSMap.get(eaSRObj);
									//System.debug('Service Resource Skills for resource: '+eachSCR.pse__Resource__c+ ' are: '+ existingSRS);
									if(existingSRS != null  && !existingSRS.isEmpty()){
										for(ServiceResourceSkill eaSRS : existingSRS){
											if(scrSkillName.equalsIgnoreCase(eaSRS.Skill.MasterLabel) && 
											   contactToUserMap.get(eachSCR.pse__Resource__c) == eaSRS.ServiceResource.RelatedRecordId){
												   //System.debug('Updating Service Resource Skill: '+eaSRS.Skill.MasterLabel+' for SR: ' +eaSRObj);
												   
												   ServiceResourceSkill srsObj = new ServiceResourceSkill();
												   srsObj.Id = eaSRS.Id;
												   srsObj.SkillLevel= eachSCR.pse__Numerical_Rating__c;
												   srsObj.EffectiveEndDate = eachSCR.pse__Expiration_Date__c;                 
												   srsObj.EffectiveStartDate = eachSCR.pse__Evaluation_Date__c == null ? Datetime.now() : eachSCR.pse__Evaluation_Date__c;
												   srsUpserList.add(srsObj);
												   srsExists = true;
												   break;
											   }
										}
									}
									
									//Create new Service Resource Skill
									if((existingSRS == null || existingSRS.isEmpty()) || !srsExists){
									   // System.debug('Inserting new Service Resource Skill:'+ skillsMap.get(scrSkillName) +' for Service Resource: '+eaSRObj);
										ServiceResourceSkill srsObj = new ServiceResourceSkill();
										srsObj.ServiceResourceId = eaSRObj.Id;
										srsObj.SkillId = skillsMap.get(scrSkillName);
										srsObj.SkillLevel= eachSCR.pse__Numerical_Rating__c;
										srsObj.EffectiveEndDate = eachSCR.pse__Expiration_Date__c;
										srsObj.EffectiveStartDate = eachSCR.pse__Evaluation_Date__c == null ? Datetime.now() : eachSCR.pse__Evaluation_Date__c;
										srsUpserList.add(srsObj);
									}
								}
							}
						}   
					}
				}
			}
			if(!srsUpserList.isEmpty() || srsUpserList.size()>0 ){ //Added size check as a part of checkmarx
                if(Trigger.isDelete){
                	List<Database.DeleteResult> srsDeleteListResult = Database.Delete(srsUpserList,false);
                }else{
                    List<Database.UpsertResult> srsUpserListResult = Database.upsert(srsUpserList, false);
					exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(srsUpserList, srsUpserListResult, 'FBE_IDS_SkillCertificationRatingHandler', 'syncServiceResourceSkills'));
				
                    if(!exceptionLoggers.isEmpty()){
                        upsert exceptionLoggers;
                    }
                }
			}
		
    }
}