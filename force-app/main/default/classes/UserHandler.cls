/*
      Purpose:
            Maintain membership of a group / queue that represents users who should be able to access
            Federal projects, based on the value of the checkbox field User.Federal_Access__c.
            
      Initiative: Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    8/1/18
*/

public class UserHandler {
    public static void maintainFederalGroupMembership(boolean isInsert, boolean isUpdate, Map<Id,User> triggerNewMap, Map<Id,User> triggerOldMap) {
        Federal_Project_Security__c groupSetting = Federal_Project_Security__c.getInstance();
        if (groupSetting.Federal_User_Queue_Or_Group_Name__c != null && groupSetting.Enable_Trigger__c) {
            List<Group> groups = [SELECT Id FROM Group WHERE Name = :groupSetting.Federal_User_Queue_Or_Group_Name__c];
            if (groups.size() == 1) {
                Group fedGroup = groups[0];
                Set<Id> idsOfUsersToAddToGroup = new Set<Id>();
                Set<Id> idsOfUsersToRemoveFromGroup = new Set<Id>();
                for (User user:triggerNewMap.values()) {
                    if (user.Federal_Access__c) {
                        if (isInsert || !triggerOldMap.get(user.Id).Federal_Access__c) {
                            idsOfUsersToAddToGroup.add(user.Id);
                        }
                    }
                    if (!user.Federal_Access__c && isUpdate && triggerOldMap.get(user.Id).Federal_Access__c) {
                        idsOfUsersToRemoveFromGroup.add(user.Id);
                    }
                }
                if (!idsOfUsersToAddToGroup.isEmpty()) {
                    addUsersToGroup(fedGroup.Id,idsOfUsersToAddToGroup);
                }
                if (!idsOfUsersToRemoveFromGroup.isEmpty()) {
                    removeUsersFromGroup(fedGroup.Id,idsOfUsersToRemoveFromGroup);
                }
            }
        }
    }
    @Future
    private static void removeUsersFromGroup(Id groupId, Set<Id> userIds) {
        List<GroupMember> groupMembers = [SELECT Id FROM GroupMember WHERE GroupId = :groupId AND UserOrGroupId in :userIds];
        if (!groupMembers.isEmpty() || groupMembers.size()>0) { //Added size check as a part of CheckMarx
            delete groupMembers;
        }
    }
    @Future
    private static void addUsersToGroup(Id groupId, Set<Id> userIds) {
        List<GroupMember> groupMembers = [SELECT Id FROM GroupMember WHERE GroupId = :groupId AND UserOrGroupId in :userIds];
        Set<Id> usersAlreadyInGroup = new Set<Id>();
        for (GroupMember groupMember:groupMembers) {
            usersAlreadyInGroup.add(groupMember.UserOrGroupId);
        }
        Set<Id> idsOfUsersToAdd = new Set<Id>();
        idsOfUsersToAdd.addAll(userIds);
        idsOfUsersToAdd.removeAll(usersAlreadyInGroup);
        List<GroupMember> groupMemberShipsToAdd = new List<GroupMember>();
        for (Id userIdToAdd:idsOfUsersToAdd) {
            GroupMember groupMember = new GroupMember(GroupId=groupId,UserOrGroupId=userIdToAdd);
            groupMemberShipsToAdd.add(groupMember);
        }
        if (!groupMemberShipsToAdd.isEmpty() || groupMemberShipsToAdd.size()>0) { //Added size check as part of CheckMarx
            insert groupMemberShipsToAdd;
        }
    }
    
    //--------------------------------------------------------------------
    //							Modification	
    //--------------------------------------------------------------------
    //	Purpose	: Update Resource fields when User gets deactivated
    //  Author	: Pawan K
    //  Company	: OAC Services, INC.
    //  Created	: 1/3/19
    
    //Update Handler
    public static void beforeUpdate( boolean isUpdate, Map<Id,User> triggerNewMap, Map<Id,User> triggerOldMap )
    {
        Trigger_Execution_Control__c triggerControl = Trigger_Execution_Control__c.getOrgDefaults();
        if(isUpdate)
        {
            if( triggerControl.Skip_Resource_Update__c != NULL && !triggerControl.Skip_Resource_Update__c )
            {
                UserResourceController.updateResource(triggerNewMap,triggerOldMap);
            }
   		}
    }
}