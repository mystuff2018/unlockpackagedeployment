public  class deactivateUsersNotLoggedInFor90Days implements Database.Batchable<sObject>{
    
    public  Database.QueryLocator start (Database.BatchableContext bc) {
        System.debug('InsideStart');
        return Database.getQueryLocator([SELECT Id,ManagerId,userRoleId FROM USER Where isActive =: True AND LastLoginDate >=: System.Today() - 90]);
        //LastLoginDate >=: System.Today() - 90' Name = 'Test Fed User'
    }
    public  void execute (Database.BatchableContext bc, List<User> userRecords){
        //Map<Id, Id> userRoleUserId = new Map<Id, Id>();
        System.debug('10 userRecords-->>'+userRecords);
        Map<Id, Id> userIdUserRole = new Map <Id, Id>();
        Map<Id, Id> newUserRoleUserId = new Map<Id, Id>();
        List<Opportunity> updateOpportunityOwner = new List<Opportunity>();
        if(!userRecords.isEmpty()){
            For(User identifiedUser :  userRecords){
                
                userIdUserRole.put(identifiedUser.Id,identifiedUser.userRoleId);
            }
            System.debug('userIdUserRole-->>'+userIdUserRole);
            List<User> newUsers = [SELECT Id, UserRoleId FROM User WHERE UserRoleId IN: userIdUserRole.values()];
            for (User newUser : newUsers){
                if(!newUserRoleUserId.ContainsKey(newUser.UserRoleId)){
                    newUserRoleUserId.put(newUser.UserRoleId,newUser.Id);
                }
            }
            System.debug('25 newUserRoleUserId -->>'+newUserRoleUserId);
            List<Opportunity> listOfOpportunity = [SELECT Id, ownerId FROM Opportunity WHERE StageName != 'Closed' AND ownerId IN: userIdUserRole.Keyset()];
            for(Opportunity openOpportunities : listOfOpportunity){
                if(!newUserRoleUserId.isEmpty() && userIdUserRole.containsKey(openOpportunities.OwnerId) && newUserRoleUserId.containsKey(userIdUserRole.get(openOpportunities.OwnerId))){
                    openOpportunities.OwnerId = newUserRoleUserId.get(userIdUserRole.get(openOpportunities.OwnerId));
                    updateOpportunityOwner.add(openOpportunities);
                }
            }
            update updateOpportunityOwner;
            List<OpportunityTeamMember> opptyTeamMember = [SELECT Id, OpportunityId, UserId, Name, PhotoUrl, Title, TeamMemberRole, OpportunityAccessLevel, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted, FBE_Assigned_By_User__c, FBE_Primary_Secondary_Specialty_SE__c FROM OpportunityTeamMember WHERE UserId IN: userIdUserRole.keyset()];
            List<AccountTeamMember> accTeamMember = [SELECT id, UserId FROM AccountTeamMember WHERE userId IN: userIdUserRole.keyset()];
            List<CaseTeamMember> caseTeamMemberRec = [SELECT Id, MemberId FROM CaseTeamMember WHERE MemberId IN: userIdUserRole.keyset()];
            System.debug(' opptyTeamMember ' + opptyTeamMember + ' accTeamMember '+accTeamMember + ' caseTeamMemberRec '+ caseTeamMemberRec);
            if(!opptyTeamMember.isEmpty())
                delete opptyTeamMember;
            if(!accTeamMember.isEmpty())
                delete accTeamMember;
            if(!caseTeamMemberRec.isEmpty())
                delete caseTeamMemberRec;
        }
    }
    public  void finish (Database.BatchableContext bc){
        // execute any post-processing operations
        List<User> UserList = [SELECT Id,ManagerId,userRoleId FROM USER Where isActive =: True AND LastLoginDate >=: System.Today() - 90];
        List <User> deactivateUserList = new List <User>();    
        For(User identifiedUser :  UserList){
            identifiedUser.isActive = FALSE;
            identifiedUser.ManagerId = null;
            identifiedUser.UserRoleId = null;
            deactivateUserList.add(identifiedUser);
        }
        System.debug('deactivateUserList From Finish Method'+deactivateUserList);
        update deactivateUserList;
    }
}