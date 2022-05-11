public class FBE_AccountTeamTrigger_Handler {
    public static void updateChannelSalesRep(List<AccountTeamMember> acctmem){
        List<id> acntIds = new List<id>();
        for(AccountTeamMember atm: acctmem){
            acntIds.add(atm.AccountId);
        }
        Map<Id,Id> acntIdWithSalesRepId = new Map<Id,Id>();
        for(AccountTeamMember atm : [SELECT AccountID,UserId,TeamMemberRole,user.EmployeeNumber FROM AccountTeamMember WHERE AccountID IN:acntIds AND TeamMemberRole ='SR' 
               ORDER BY user.EmployeeNumber Desc]){
                   if(atm.user.EmployeeNumber != null){
                       acntIdWithSalesRepId.put(atm.AccountId , atm.UserId);
                   }
        }
        List<Account> updList = new List<Account>();
        if(!acntIdWithSalesRepId.isEmpty()){
            for(Id actId : acntIdWithSalesRepId.keySet()){
                if(acntIdWithSalesRepId.get(actId) != null){
                    updList.add(new Account(Id =actId, FBE_FPRM_Channel_Sales_Rep__c = acntIdWithSalesRepId.get(actId)));
                }
            }
        }
        try{
            UPDATE updList;
        }catch(Exception e){
            System.debug('exception in updating Account with channale Sales Rep '+ e);
        }
    }
}