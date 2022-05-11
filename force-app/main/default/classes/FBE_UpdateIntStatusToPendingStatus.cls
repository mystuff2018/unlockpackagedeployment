/**************
*@ Trigger Name                                                  : FBE_UserTrigger
*@ Description                                                   : Update user integration status to Pending synch.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 10-6-2020 [LavaKumar T]
*@ Modification Log                                              : 
***************/ 
public class FBE_UpdateIntStatusToPendingStatus {
    public static void FBE_UpdateIntegrationStatusToPendingStatus(List<User> userList,Map<ID,User> oldMap){
        boolean isInsert = (oldMap == NULL);
        for(User u : userList){
            if((isInsert && u.FBE_Siebel_User_Id__c != NULL) || (! isInsert && (u.FBE_Siebel_User_Id__c != NULL && oldMap.get(u.id).FBE_Siebel_User_Id__c != u.FBE_Siebel_User_Id__c || u.EmployeeNumber != NULL && oldMap.get(u.id).EmployeeNumber != u.EmployeeNumber))){
                u.FBE_Integration_Status__c = 'Pending Sync';
                u.FBE_Integration_Message__c = '';
            }
        }
    }
}