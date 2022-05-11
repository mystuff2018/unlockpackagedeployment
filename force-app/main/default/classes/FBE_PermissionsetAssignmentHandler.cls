/*
*@ Class Name     : FBE_PermissionsetAssignmentHandler
*@ Test Class     : FBE_PermissionsetAssignmentHandlerTest
*@ Description      : This class is used to assign permission set to community user based on 
                                                                       FBE_FPRM_OnlineRole__c field.
*@ CreatedBy        : Deloitte Consulting
*@ CreatedOn        : 03-02-2021 [Uttam Kavitkar]
*@ Modification Log : Sitaram Teki -Story STORY 9911926[April 27 2021]                  
*/
public class FBE_PermissionsetAssignmentHandler {
    
    public static Id dealOptyPSId;
    public static Id delegatedAdminPSId;
    public static Id distyResellerAdminGroupId;
    public static Id dmpAdminGroupId;
    public static Id AdminAlloptyGroupId;
    public static Id AdminAlloptyCaseGroupId;
    
    @AuraEnabled
    public static String getPartnerUser(Id contactId){
        List<User> lstUser = [Select Id,Name,Phone from User where IsActive = true AND ContactId =: contactId limit 1];
        Contact con = [Select FirstName,LastName,AccountId,Email,Phone From Contact where Id =: contactId limit 1];
        List<UserRole> usrRole = [Select Id,Name from UserRole where PortalAccountId =: con.AccountId limit 1];
        contactUserWrapper objWrapper;
        if(!lstUser.isEmpty()){
            //return lstUser[0];
            objWrapper = new contactUserWrapper(con,lstUser[0],usrRole,con.Phone);
        }
        else{
            objWrapper = new contactUserWrapper(con,null,usrRole,con.Phone); 
        }
        return JSON.serialize(objWrapper);
    }
      
    //Call on user creation to assign permission set, Modified by Sitaram Teki -Story STORY 9911926[April 27 2021] 
    @future
    public static void assignPermissionsetOnCreate(List<Id> lstUserIds){
      
        List<User> lstNewUser = [Select Id,IsActive,Name,Profile.Name,FBE_FPRM_OnlineRole__c,ContactId,Contact.AccountId,Contact.FBE_FPRM_Reseller_Account__c
                              From User where Id IN : lstUserIds];
        List<GroupMember>GMList = new List<GroupMember>();
        //Get the permission set Ids
        dealOptyPSId = [SELECT Id FROM Permissionset WHERE Name =  'FBE_FPRM_Deal_Opty_Access' Limit 1].Id;
        delegatedAdminPSId = [SELECT Id FROM Permissionset WHERE Name = 'FBE_FPRM_Delegated_Admin_Access' Limit 1].Id;
        
        //Get public groups
        distyResellerAdminGroupId = [SELECT Id FROM Group WHERE Name = 'FBE_FPRM_Disty_Reseller_Admin' Limit 1].Id;
        dmpAdminGroupId = [SELECT Id FROM Group WHERE Name = 'FBE_FPRM_DMP_Admin' Limit 1].Id;
         //added new groups by Sitaram Teki -Story STORY 9911926[April 27 2021] 
         AdminAlloptyGroupId = [SELECT Id FROM Group WHERE Name = 'FBE_FPRM_SiteAdmin_Allopty_Group' Limit 1].Id;
         AdminAlloptyCaseGroupId = [SELECT Id FROM Group WHERE Name = 'FBE_FPRM_SiteAdmin_Allopty_Case_Group' Limit 1].Id;
            
        //Logic for assigning permission set to user 
        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        List<GroupMember> lstGM = new List<GroupMember>();
        for(User usr : lstNewUser){
            if(usr.FBE_FPRM_OnlineRole__c != null){
                lstPSA.addAll(getPSAssignments(usr.Id,usr.FBE_FPRM_OnlineRole__c)); 
                GroupMember GM = addUserInGroup(usr.Id,usr.FBE_FPRM_OnlineRole__c);
                GMList = addUsersListInGroup(usr.Id,usr.FBE_FPRM_OnlineRole__c);
                if(GM != null){
                    lstGM.add(GM);
                }
            }
        }  
        
        //insert permission set assignment
        if(!lstPSA.isEmpty()){
            insert lstPSA;
        }
        if(!GMList.isEmpty())
        {
            System.debug('Grp members list &&&'+ GMList);
            INSERT GMList;
        }
        //insert user in public group
        if(!lstGM.isEmpty()){
            insert lstGM;
        }
    }

    //Call on user's Online role field update, Sitaram Teki -Story STORY 9911926[April 27 2021] 
    @future
    public static void assignPermissionsetOnUpdate(List<Id> lstUserIds){
         
        List<User> lstNewUser = [Select Id,Name,Profile.Name,FBE_FPRM_OnlineRole__c,ContactId
                              From User where Id IN : lstUserIds];
            
        //Fetch the permission set Ids
        dealOptyPSId = [Select Id from Permissionset where Name =  'FBE_FPRM_Deal_Opty_Access' Limit 1].Id;
        delegatedAdminPSId = [Select Id from Permissionset where Name = 'FBE_FPRM_Delegated_Admin_Access' Limit 1].Id;
        set<id> setPSIds = new set<Id>{dealOptyPSId,delegatedAdminPSId};
        
        distyResellerAdminGroupId = [SELECT Id FROM Group WHERE Name = 'FBE_FPRM_Disty_Reseller_Admin' Limit 1].Id;
        dmpAdminGroupId = [SELECT Id FROM Group WHERE Name = 'FBE_FPRM_DMP_Admin' Limit 1].Id;
        
        //added new groups by Sitaram Teki -Story STORY 9911926[April 27 2021] 
        AdminAlloptyGroupId = [SELECT Id FROM Group WHERE Name = 'FBE_FPRM_SiteAdmin_Allopty_Group' Limit 1].Id;
        AdminAlloptyCaseGroupId = [SELECT Id FROM Group WHERE Name = 'FBE_FPRM_SiteAdmin_Allopty_Case_Group' Limit 1].Id;
        //set<id> setGroupIds = new set<Id>{distyResellerAdminGroupId,dmpAdminGroupId};
        
           set<id> setGroupIds = new set<Id>{distyResellerAdminGroupId,dmpAdminGroupId,AdminAlloptyGroupId,AdminAlloptyCaseGroupId};
        
        //Logic for assigning permission set based on Online Role field
                           //List<PermissionSetAssignment> lstDelPSA = new List<PermissionSetAssignment>();        
        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        List<GroupMember> lstGM = new List<GroupMember>();
        List<GroupMember> GMList = new List<GroupMember>();
        for(User usr : lstNewUser){
            GroupMember GM = addUserInGroup(usr.Id,usr.FBE_FPRM_OnlineRole__c);
            GMList = addUsersListInGroup(usr.Id,usr.FBE_FPRM_OnlineRole__c);
            
            if(GM != null){
                lstGM.add(GM);
            }
            lstPSA.addAll(getPSAssignments(usr.Id,usr.FBE_FPRM_OnlineRole__c));  
        }
        
        //Remove user from public group and permission set
        if(!lstUserIds.isEmpty()){
            
            List<GroupMember> ListGM = [Select Id from GroupMember where UserOrGroupID IN :lstUserIds AND GroupId IN : setGroupIds];
            if(!ListGM.isEmpty()) { delete ListGM; }
            
            List<PermissionSetAssignment> lstDelPSA = [Select Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment 
                                                   where AssigneeId IN :lstUserIds AND PermissionSetId IN :setPSIds AND PermissionSet.IsOwnedByProfile = false];
            if(!lstDelPSA.isEmpty()) { delete lstDelPSA; }
        }
        
        //Add new permission set on update
        if(!lstPSA.isEmpty()){
            insert lstPSA;
        }
        if(!GMList.isEmpty())
        {
            System.debug('Grp members list &&&'+ GMList);
            INSERT GMList;
        }
            
            
        //insert user in public group
        if(!lstGM.isEmpty()){
            insert lstGM;
        }
    } 
    
    //Assign Permission set based on role
    private static List<PermissionSetAssignment> getPSAssignments(Id userId,String roleName){
        
        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>(); 
        if(roleName == 'Site Admin' || roleName == 'Disty Managed Site Admin'){
            PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = userId,PermissionSetId = delegatedAdminPSId);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = userId,PermissionSetId = dealOptyPSId);
            lstPSA.add(psa1);  
            lstPSA.add(psa2);  
        }
        else if(roleName == 'Sales Rep All Opty' || roleName == 'Sales Rep My Opty'
                || roleName == 'Disty Managed Sales Rep All Opty' || roleName == 'Disty Managed Sales Rep My Opty' )
        {
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = userId,PermissionSetId = dealOptyPSId);
            lstPSA.add(psa);           
        }
        return lstPSA;
    }
    
    //Populate sharing account field on Contact based on Online role and profile
    @future
    public static void populateSharingAccountOnContact(List<Id> lstUserIds){
        
        List<User> lstNewUser = [Select Id,IsActive,Username,Name,Profile.Name,FBE_FPRM_OnlineRole__c,ContactId,Contact.AccountId,Contact.FBE_FPRM_Reseller_Account__c
                              From User where Id IN : lstUserIds];
        List<contact> lstContact = new List<contact>();
        
        for(User usr : lstNewUser){
            
            String profile = usr.Profile.Name;
            String roleName = usr.FBE_FPRM_OnlineRole__c;
            //Update user field on contact
            Contact con = new Contact(Id = usr.ContactId,FBE_FPRM_Partner_Online_Role__c = roleName,
                                      FBE_FPRM_Partner_User_Name__c = usr.Username);
            //Assign Primary and reseller account value to Sharing account field   
            if(profile == 'FBE FPRM Partner Distributor' || profile == 'FBE FPRM Partner Reseller'){
				con.FBE_FPRM_Contact_Case_Sharing_Account__c = usr.Contact.AccountId;
				if(roleName == 'Site Admin' || roleName == 'Sales Rep All Opty'){
					con.FBE_FPRM_Sharing_Account__c = usr.Contact.AccountId;
				}

			}
            else if( profile == 'FBE FPRM Partner Disty Managed'){
				con.FBE_FPRM_Contact_Case_Sharing_Account__c = usr.Contact.FBE_FPRM_Reseller_Account__c;
				if(roleName == 'Disty Managed Site Admin' || roleName == 'Disty Managed Sales Rep All Opty'){
					con.FBE_FPRM_Sharing_Account__c = usr.Contact.FBE_FPRM_Reseller_Account__c;
				}
			}else{
				con.FBE_FPRM_Contact_Case_Sharing_Account__c = null;
                con.FBE_FPRM_Sharing_Account__c = null;
            }
            lstContact.add(con);                 
        } 
        
        //Update contact sharing Account lookup field
        if(!lstContact.isEmpty()){
            update lstContact; 
        }               
    }
      
    //Added by uttam on 19-Apr-2021 to assign/revoke Deal/Opty access to My Opty Role users 
    @future
    public static void shareDealOptyWithPartnerUser(List<Id> lstUserIds,String jsonOldUserMap){
          
        set<Id> myOptyUserIds = new set<Id>();
        set<Id> nonMyOptyUserIds = new set<Id>();
        set<String> setMyOptyRoles = new Set<String>{'Sales Rep My Opty','Disty Managed Sales Rep My Opty'};
        /*set<String> setNonMyOptyRoles = new Set<String>{'Site Admin', 'Sales Rep All Opty', 
                                                       'Disty Managed Site Admin','Disty Managed Sales Rep All Opty'};*/
            
        Map<Id,user> oldUserMap = (Map<Id,user>)System.JSON.deserialize(jsonOldUserMap, Map<Id,user>.class);
        for(User usr : [Select Id,FBE_FPRM_OnlineRole__c,ContactId From User where Id IN : lstUserIds]){
            User oldUser = oldUserMap.get(usr.Id);
            if(setMyOptyRoles.contains(usr.FBE_FPRM_OnlineRole__c)){
                myOptyUserIds.add(usr.Id);
            }
                                         //else if(setMyOptyRoles.contains(oldUser.FBE_FPRM_OnlineRole__c) && setNonMyOptyRoles.contains(usr.FBE_FPRM_OnlineRole__c)){
            else if(setMyOptyRoles.contains(oldUser.FBE_FPRM_OnlineRole__c)){
                nonMyOptyUserIds.add(usr.Id);
            }           
        }
        
        //Assign Deals/Opty permission to my Opty Users
        if(!myOptyUserIds.isEmpty()){
            List<Deal_Registration__c> deals = [SELECT Id,Name,FBE_FPRM_Partner_Owner__c,FBE_FPRM_Partner_Sales_Rep__c FROM Deal_Registration__c 
                                                 WHERE FBE_FPRM_Partner_Owner__c IN : myOptyUserIds OR FBE_FPRM_Partner_Sales_Rep__c IN : myOptyUserIds];
            if(deals != null && !deals.isEmpty()){
                FBE_FPRM_DealHandler.shareDealRecordWithPartnerUser(deals,null);
            }
            
            List<Opportunity> oppts = [SELECT Id,Name,FBE_FPRM_Partner_Owner_Lookup__c,FBE_FPRM_Partner_Sales_Rep__c FROM Opportunity 
                                                 WHERE FBE_FPRM_Partner_Owner_Lookup__c IN : myOptyUserIds OR FBE_FPRM_Partner_Sales_Rep__c IN : myOptyUserIds];
            if(oppts != null && !oppts.isEmpty()){
                FBE_OpportunityTriggerHandler.shareOpptyRecordWithPartnerUser(oppts,null);
            }
        }
        
        //Revoke Deal/Opty permission for my opty users.
        if(!nonMyOptyUserIds.isEmpty()){
            List<Deal_Registration__Share> lstDealShare = [SELECT Id,ParentId FROM Deal_Registration__Share 
                                                           WHERE UserOrGroupId IN : nonMyOptyUserIds AND RowCause = 'PRM_Record_Sharing__c'];                                                                                                     
            if(!lstDealShare.isEmpty()){
                Database.delete(lstDealShare, false);
            }
            
            List<OpportunityShare> lstOpptyShare = [SELECT Id,OpportunityId FROM OpportunityShare 
                                                    WHERE UserOrGroupId IN : nonMyOptyUserIds AND RowCause = 'Manual'];                                                                                                         
            if(!lstOpptyShare.isEmpty()){
              Database.delete(lstOpptyShare, false);
            }
        }
        
    }
    
    //Add Admin partner user in respective public group 
    private static GroupMember addUserInGroup(Id userId,String roleName){
        GroupMember GM;
        if(roleName == 'Site Admin'){
            GM = new GroupMember();
            GM.GroupId = distyResellerAdminGroupId;
            GM.UserOrGroupId = userId;                                          
        }
        else if(roleName == 'Disty Managed Site Admin'){
            GM = new GroupMember();
            GM.GroupId = dmpAdminGroupId;
            GM.UserOrGroupId = userId;
        }
       
        return GM;
    }
     // Add Sitaram Teki -Story STORY 9911926[April 27 2021]
    private static List<GroupMember> addUsersListInGroup(Id userId,String roleName){
        List<GroupMember>groupMemberList = new List<GroupMember>() ;
       
         if(roleName == 'Site Admin' || roleName == 'Sales Rep All Opty' || roleName == 'Sales Rep My Opty' || 
            roleName == 'Sales Rep Case' || roleName == 'Disty Managed Site Admin' || roleName == 'Disty Managed Sales Rep All Opty'||
            roleName == 'Disty Managed Sales Rep My Opty' || roleName == 'Disty Managed Sales Rep Case'  )
         {
             GroupMember GM = new GroupMember();
             GM.GroupId = AdminAlloptyCaseGroupId;
             GM.UserOrGroupId = userId;
             groupMemberList.add(GM);             
         }
        if(roleName == 'Site Admin' || roleName == 'Sales Rep All Opty' || roleName == 'Sales Rep My Opty' ||
           roleName == 'Disty Managed Site Admin' || roleName == 'Disty Managed Sales Rep All Opty'|| 
           roleName == 'Disty Managed Sales Rep My Opty')
        { 
            GroupMember GM1 = new GroupMember();
            GM1.GroupId = AdminAlloptyGroupId;
            GM1.UserOrGroupId = userId;
            groupMemberList.add(GM1); 
        }
        return groupMemberList;
    } 
    
    @future
    public static void removeUserFromPermissionSetAndGroup(List<Id> lstUserIds){
        //Remove user from permission set when user Inactive
        if(!lstUserIds.isEmpty()){ 
            
            List<GroupMember> ListGM = [Select Id from GroupMember where UserOrGroupID IN :lstUserIds];
            if(!ListGM.isEmpty()) { delete ListGM; }
            system.debug('ListGM ==' + ListGM);
            List<PermissionSetAssignment> lstDelPSA = [Select Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment 
                                                       where AssigneeId IN :lstUserIds AND PermissionSet.IsOwnedByProfile = false];
            if(!lstDelPSA.isEmpty()) { delete lstDelPSA; }
            system.debug('lstDelPSA ==' + lstDelPSA);
        } 
    }
    
    @future
    public static void updateContactFieldsToNull(List<Id> lstUserIds,String jsonOldUserMap){
        system.debug('updateContactFieldsToNull is called');
        List<User> lstNewUser = [Select Id,Name,Profile.Name,FBE_FPRM_OnlineRole__c,ContactId
                                 From User where Id IN : lstUserIds];
        Map<Id,user> oldUserMap = (Map<Id,user>)System.JSON.deserialize(jsonOldUserMap, Map<Id,user>.class);
        //Update contact field to null when user Inactive
        List<Contact> lstContact = new List<Contact>();
        for(User usr : lstNewUser){
            User oldUser = oldUserMap.get(usr.Id);
            Contact con = new Contact(Id = oldUser.ContactId, FBE_FPRM_Partner_Online_Role__c = null, FBE_FPRM_Partner_User_Name__c = null,
                                      FBE_FPRM_Sharing_Account__c = null, FBE_FPRM_Contact_Case_Sharing_Account__c = null);
            lstContact.add(con);
        }
        system.debug('lstContact ==' + lstContact);
        if(!lstContact.isEmpty()) { update lstContact; } 
    }

    //Store log information while partner user is activated/deactivated 
              @future
    public static void createPartnerUserLog(List<Id> lstUserIds,String jsonOldUserMap){
        
        List<Partner_User_Log__c> lstPUL = new List<Partner_User_Log__c>();
        if(String.isEmpty(jsonOldUserMap)){
            for(User usr : [Select Id,Name,Profile.Name,FBE_FPRM_OnlineRole__c,ContactId From User where Id IN : lstUserIds])
            {
                Partner_User_Log__c objPUL = new Partner_User_Log__c(
                            FBE_FPRM_Action__c = 'Activated',
                    FBE_FPRM_Contact__c  = usr.ContactId,
                    FBE_FPRM_Partner_User__c = usr.Id
                );
                lstPUL.add(objPUL);
            }
        }
        else{
            Map<Id,user> oldUserMap = (Map<Id,user>)System.JSON.deserialize(jsonOldUserMap, Map<Id,user>.class);
            for(User usr : oldUserMap.values()){
                Partner_User_Log__c objPUL = new Partner_User_Log__c(
                            FBE_FPRM_Action__c = 'Deactivated',
                    FBE_FPRM_Contact__c  = usr.ContactId,
                    FBE_FPRM_Partner_User__c = usr.Id
                );
                lstPUL.add(objPUL);
            }
        }
          
        if(!lstPUL.isEmpty()){
            Database.insert(lstPUL,false);
        }
        
    }
        
    //Wrapper class to send multiple object information to lighting component    
    public class contactUserWrapper {
        public String contPhone {get;set;}
        public contact contact {get; set;}
        public User user {get; set;}
        public List<UserRole> userRole {get; set;}

        //This is the contructor method. 
        public contactUserWrapper(contact con,User usr,List<UserRole> usrRole, String conPhone) {
            this.contPhone = conPhone;
            this.contact = con;
            this.user = usr;
            this.userRole = usrRole;  
        }
    }
    
}