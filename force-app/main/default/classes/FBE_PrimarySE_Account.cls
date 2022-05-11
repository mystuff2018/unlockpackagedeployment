public class FBE_PrimarySE_Account {
    public static void PrimarySEUserToAccount(List<AccountTeamMember> acctmem){
        try{
            List<id> atmact = new List<id>();
            if(acctmem != null){
                for(AccountTeamMember atv: acctmem){
                    atmact.add(atv.AccountId);
                }
            }
            if(atmact != Null && atmact.size()>0){
            List<AccountTeamMember> atm = [Select AccountID,UserId,TeamMemberRole from AccountTeamMember where Account.ID in:atmact order by CreatedDate Asc];
            Map<id,List<String>> AccountidPrimarySE = new Map<id,List<String>>();
            Map<String,List<id>> userRole =  new Map<String,List<id>>();
            if(atm  != null && atm.size()>0){
                for(AccountTeamMember at : atm){
                    if(!AccountidPrimarySE.containsKey(at.AccountId)){
                        AccountidPrimarySE.put(at.AccountId, new List<String>{at.TeamMemberRole});
                    }else
                        AccountidPrimarySE.get(at.AccountId).add(at.TeamMemberRole);
                    if(!userRole.containsKey(at.TeamMemberRole)){
                        userRole.put(at.TeamMemberRole, new List<id>{at.UserId});
                    }else
                        userRole.get(at.TeamMemberRole).add(at.UserId);	
                    system.debug('AccountidPrimarySE'+AccountidPrimarySE+'userRole'+userRole);
                    
                }
            }
        
            
            List<Account> acct = [select id,Primary_SE__c from Account where id in:AccountidPrimarySE.keySet()];
            system.debug('acct'+acct);
            List<Account> at = new List<Account>();
            if(acct != null && acct.size()>0){
                system.debug('Inside null check');
                for(Account acc : acct){
                    system.debug('Inside for loop acc'+acc);
                    system.debug('Outside IF:'+AccountidPrimarySE.get(acc.id).contains('Primary_SE'));
                    if(AccountidPrimarySE.get(acc.id).contains('Primary_SE')){
                        
                        for(String roles : AccountidPrimarySE.get(acc.id)){
                            System.debug('Inside For roles:'+roles);
                            if(roles == 'Primary_SE'){
                                system.debug('userRole.get(roles)'+userRole.get(roles));
                                acc.Primary_SE__c = userRole.get(roles)[0];
                                system.debug('inside if');
                                
                            }
                            
                        }
                        at.add(acc);
                    }
                    else{
                        acc.Primary_SE__c = Null;
                        at.add(acc);
                    }
                    
                }
                
                system.debug('at'+at);
            }
            
            update at;
            }
        }catch(exception e){
            system.debug('error: '+e.getCause()+ 'at Line'+e.getLineNumber());
        }
        
    }
}