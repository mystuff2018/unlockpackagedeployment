public class UserHandlerForAddingToGroup {
    public static void addingusersTorespectiveGroups(boolean isInsert, boolean isUpdate, Map<ID,User> newMap, Map<ID,User> oldMap){
        set<ID> usersToAddFBE_IDS_PSA_PM_PDM_INTAKE_GRP = new set<ID>();
		set<ID> usersToRemoveFBE_IDS_PSA_PM_PDM_INTAKE_GRP = new set<ID>();
		set<ID> usersToAddFBE_IDS_AccountSharePM_SL = new set<ID>();
		set<ID> usersToRemoveFBE_IDS_AccountSharePM_SL = new set<ID>();
		Map<ID,String> profileIds = new Map<ID,String>();
		Set<String> profileNames  = new Set<String>();
        Set<String> profileNamesforFBEidspsapmpdmintake  = new Set<String>();
        Map<ID,ID> userWithProfileIds = new Map<ID,ID>();
        
	for(USER u : newMap.values()){
        if(u.IsActive && isInsert){ 
            userWithProfileIds.put(u.id,u.profileId);
        }else if(u.profileId != oldMap.get(u.id).profileId){
			userWithProfileIds.put(u.id,u.profileId);
		}
	}
	if(! userWithProfileIds.isEmpty()){
		
		profileNames.add('PSA Project Manager');
		profileNames.add('PSA Intake');
        profileNames.add('PSA Resource Manager');
        profileNames.add('PSA Direct Manager');
        profileNamesforFBEidspsapmpdmintake.add('PSA Project Manager');
        profileNamesforFBEidspsapmpdmintake.add('PSA Intake');
        profileNamesforFBEidspsapmpdmintake.add('PSA Direct Manager');
        profileNamesforFBEidspsapmpdmintake.add('PSA Project Administrator');
        profileNamesforFBEidspsapmpdmintake.add('PSA Resource Manager');
		for(Profile p : [SELECT Id, Name FROM Profile WHERE Name IN('PSA Project Manager','PSA Intake','PSA Direct Manager','PSA Project Administrator','PSA Resource Manager')]){
			profileIds.put(p.Id,p.Name);
		}
		if(! profileIds.isEmpty()){
			for(Id uId : userWithProfileIds.keySet()){
                if(isInsert && (profileIds.keySet().contains(newMap.get(uId).profileId))){
                    if(profileNamesforFBEidspsapmpdmintake.contains(profileIds.get(newMap.get(uId).profileId))){
                    usersToAddFBE_IDS_PSA_PM_PDM_INTAKE_GRP.add(uId);
                    }
                    if(profileNames.contains(profileIds.get(newMap.get(uId).profileId))){
						usersToAddFBE_IDS_AccountSharePM_SL.add(uId);
                    }
                }else if(isUpdate){        
					if(profileIds.keySet().contains(newMap.get(uId).profileId) && ! profileIds.keySet().contains(oldMap.get(uId).profileId)){
                        if(profileNamesforFBEidspsapmpdmintake.contains(profileIds.get(newMap.get(uId).profileId))){
                    	usersToAddFBE_IDS_PSA_PM_PDM_INTAKE_GRP.add(uId);
                        }
                        if(profileNames.contains(profileIds.get(newMap.get(uId).profileId))){
					     usersToAddFBE_IDS_AccountSharePM_SL.add(uId);
						}
					}else if(! profileIds.keySet().contains(newMap.get(uId).profileId) && profileIds.keySet().contains(oldMap.get(uId).profileId)){
                        if(!profileNamesforFBEidspsapmpdmintake.contains(profileIds.get(newMap.get(uId).profileId))){
						usersToRemoveFBE_IDS_PSA_PM_PDM_INTAKE_GRP.add(uId);
                        }
                        if(!profileNames.contains(profileIds.get(newMap.get(uId).profileId))){
							usersToRemoveFBE_IDS_AccountSharePM_SL.add(uId);
                        }
					}
                }
            }
        }
    }
                
				
	if(usersToAddFBE_IDS_PSA_PM_PDM_INTAKE_GRP.size() > 0 || usersToRemoveFBE_IDS_PSA_PM_PDM_INTAKE_GRP.size() > 0 || usersToAddFBE_IDS_AccountSharePM_SL.size() > 0 || usersToRemoveFBE_IDS_AccountSharePM_SL.size() > 0){
		List<Group> grpList = new List<Group>(2);
		for( Group grup : [SELECT Id,Name FROM Group WHERE Name LIKE '%FBE IDS PSA PM PDM INTAKE GRP%' OR Name LIKE '%FBE_IDS_AccountSharePM_SL%']){
			if(grup.Name == 'FBE IDS PSA PM PDM INTAKE GRP'){
				grpList.add(0,grup);
			}
            if(grup.Name == 'FBE_IDS_AccountSharePM_SL'){
				grpList.add(1,grup);
			}
            //grpList.add(grup);
		}
		
		if(grpList.size() > 0){
			if(usersToAddFBE_IDS_PSA_PM_PDM_INTAKE_GRP.size() > 0){
				addUsersToGroup(grpList[0].ID,usersToAddFBE_IDS_PSA_PM_PDM_INTAKE_GRP);
			}
			if(usersToRemoveFBE_IDS_PSA_PM_PDM_INTAKE_GRP.size() > 0){
				removeUsersFromGroupNew(grpList[0].ID,usersToRemoveFBE_IDS_PSA_PM_PDM_INTAKE_GRP);
			}
			if(usersToAddFBE_IDS_AccountSharePM_SL.size() > 0){
				addUsersToGroup(grpList[1].Id,usersToAddFBE_IDS_AccountSharePM_SL );
			}
			if(usersToRemoveFBE_IDS_AccountSharePM_SL.size() > 0){
				removeUsersFromGroupNew(grpList[1].Id, usersToRemoveFBE_IDS_AccountSharePM_SL);
			}
		}
	}
}
    
    @future
    private static void removeUsersFromGroupNew(Id groupId, Set<Id> userIds) {
        List<GroupMember> groupMembers = [SELECT Id FROM GroupMember WHERE GroupId = :groupId AND UserOrGroupId in :userIds];
        if (!groupMembers.isEmpty() || groupMembers.size()>0) { //Added size check as a part of chekMarx
            delete groupMembers;
        }
        system.debug('delete groupMembers:::'+groupMembers);
    }
     @Future
    private static void addUsersToGroup(Id groupId, Set<Id> userIds) {
       List<GroupMember> listGroupMember = new List<GroupMember>();
       for(Id userId : userIds){
                GroupMember gm= new GroupMember(); 
                gm.GroupId = groupId;
                gm.UserOrGroupId = userId;
                listGroupMember.add(gm);  
            }
            if(listGroupMember.size()>0 || !listGroupMember.isEmpty()){ //Added isEmpty() check as a part of checkMarx
            system.debug('Insert group222');
             Insert listGroupMember;
            }       
    }
 }