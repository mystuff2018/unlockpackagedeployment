/**************
 *@ Class Name        : FBE_AccountTriggerHandler
 *@ Description       : This class is written to handle the Trigger related updates. 
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 04-10-2017
 *@ Modification Log  :                     
 ***************/
public with sharing class FBE_AccountTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public FBE_AccountTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /**************
     * @MethodName    : onAfterUpdate
     * @Trigger       : FBE_AccountTrigger
     * @Description   : This method is called in the above trigger.
                        This basically updates the child AccountTeamMemberRecords
                        and change there account level access to edit. 
     ***************/
    public void onAfterUpdate(list<Account> updatedAccountList) {
         Boolean isIntegrationUser = (Boolean)[SELECT id, FBE_Integration_User__c FROM User where id =: UserInfo.getUserId()].FBE_Integration_User__c;
         if(isIntegrationUser){
            list <Account> listAccount = new list<Account>();
            set<id> setAccIds = new set<id>();
            map<id,list<AccountTeamMember>> mapAccAccountTeamMember = new map<id,list<AccountTeamMember>>();
            for(Account acc :  updatedAccountList) {
                if(acc.FBE_Set_Account_Access_Level__c)
                setAccIds.add(acc.id);
            }
            
            list<Account> newListAccount = new list<Account> ();
            for(Account accObj : [SELECT id, FBE_Set_Account_Access_Level__c, (SELECT id, AccountAccessLevel FROM AccountTeamMembers) FROM Account where id IN: setAccIds]){
                mapAccAccountTeamMember.put(accObj.id,accObj.AccountTeamMembers);
                accObj.FBE_Set_Account_Access_Level__c = false;
                newListAccount.add(accObj);
            }
            
            list<AccountTeamMember> memberToUpdate = new list<AccountTeamMember>();
            
            for(Id accObjId : mapAccAccountTeamMember.keySet()){
                if(!mapAccAccountTeamMember.get(accObjId).isEmpty()){
                    for(AccountTeamMember accTeamMemberObj : mapAccAccountTeamMember.get(accObjId)){
                        accTeamMemberObj.AccountAccessLevel = 'Edit';
                        memberToUpdate.add(accTeamMemberObj);    
                    }
                    
                }
            }
            
            update memberToUpdate;
            system.debug(newListAccount + '*************' + memberToUpdate);
            //update account flag to false
            if(!newListAccount.isEmpty() && !memberToUpdate.isEmpty()){
                update newListAccount;
            }
            
    
        }
              
    }

}