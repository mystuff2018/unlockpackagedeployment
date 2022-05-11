/**************
*@ Class Name        : FBE_Test_RoleUtility
*@ Description       : Test Class for RoleUtility Class
*@ CreatedBy         : Deloitte Consulting
*@ CreatedOn         : 06-26-2019
*@ Modification Log  : 
***************/
@isTest
public class FBE_Test_RoleUtility {

    static TestMethod void getRoleSubordinateUsersTest() {
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        set<Id> accIdSet = new set<Id>();
        set<Id> oppIdSet = new set<Id>();
        Id optyId;
        system.runAs(lUser[0]){ 
            Test.startTest();
            //Setup Test Data - Roles
          List<UserRole> roleList= FBE_Test_Utility.createRoles(2);
            insert roleList;  
            system.assertNotEquals(null, roleList[0].id,'Null check');
            roleList[1].ParentRoleId = roleList[0].id;
            update roleList[1];
            //Setup Test Data - Users
            List<User> lUsers = FBE_Test_Utility.createUser('System Administrator', 2, 'ab');          
            //insert lUsers;
            system.assertNotEquals(null, lUsers[0].id,'Null check');
            lUsers[0].UserRoleId = roleList[0].id;
            lUsers[1].UserRoleId = roleList[1].id;
            List<User> lSearchResult = new List<User>();
            try{
                lSearchResult = FBE_RoleUtility.getRoleSubordinateUsers(lUser[0].id) ; 
                system.debug('lSearchResult'+lSearchResult);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
           system.assertNotEquals(null, lSearchResult,'Null check');
            Test.stopTest();
        }
    }    

}