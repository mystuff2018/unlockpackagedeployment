/******************************************************************************/
/* Developer : LavaKumar (Dell)                                               */
/* Requirment : Displaying Account team, account and opportunity as hierarchy.*/
/* Story : 7972134                                                            
*@ Modification Log                                              :[Siva Kumar Valluru-Dell] Defect #11296995- Added the lines 29-35 . 
******************************************************************************/
public class FBE_Manager_Tree {
    @AuraEnabled
    public static String getTreeGridData(){
        Set<id> uid = new set<id>();
        List < String > precondition = new list<string>();
        List < String > fnlcondition = new list<string>();
        Map<ID,User> userMap = new Map<ID,User>();
        Map<ID,Account> accMap = new Map<ID,Account>();
        Map<ID,List<Opportunity>> accOpps = new Map<ID,List<Opportunity>>();
        list<Opportunity> lstoppties;
        List<AccountTeamMember> accTeamMemList = new List<AccountTeamMember>();
        Map<string,List<Items>> acwrapMap = new Map<string,List<Items>>();
        Map<String,ID> userNameWithId = New Map<String,ID>();
        for(user u : [select id,name,managerId from user where managerId = :UserInfo.getUserId() OR ID =: UserInfo.getUserId()]){
            userMap.put(u.id,u);
            system.debug('userMap '+userMap);
        }
       
        if(! userMap.isEmpty()){
            for(Account accs : [Select Id ,Name,Type,(Select Id , Name,StageName,closeDate,Amount,FBE_Sales_Stage_Duration__c from Opportunities),(select id,user.name,TeamMemberRole,AccountId from AccountTeamMembers where UserId IN :userMap.keySet()) from Account where ID IN (select Accountid from Accountteammember where userID =:userMap.keySet())]){
                accMap.put(accs.id,accs);
                accTeamMemList.addAll(accs.AccountTeamMembers);
                if(accs.opportunities.size()>0){
                lstoppties = new list<Opportunity>();
                for(Opportunity opp: accs.opportunities){
                    lstoppties.add(opp);
                    accOpps.put(accs.id,lstoppties);
                   }
                }  
                system.debug('accTeamMemList##### '+accTeamMemList.size());
                system.debug('accOpps#####'+accOpps.size());
            }
        }
        List<AccountWrapper> aooo = new List<AccountWrapper>();
        if(accTeamMemList.size() > 0){
            
            for(AccountTeamMember accTeam : accTeamMemList){
                List<Items> aItems = new List<Items>();
                    Items aIII = new Items();
                    aIII.nameL = accMap.get(accTeam.AccountId).Name;
                    aIII.teamMemRole = accTeam.TeamMemberRole;
                    aIII.name =  '/'+accTeam.AccountId;
                    aIII.accType = accMap.get(accTeam.AccountId).Type;
                    
                    //aIII.teamname = accTeam.user.name;
                    List<oppItems> oppItems = new List<oppItems>();
                    decimal amnt = 0;
                    if(accOpps.get(accTeam.AccountId) != NULL){
                        for(Opportunity opp : accOpps.get(accTeam.AccountId)){
                            if(opp.Amount != NULL){
                                amnt += opp.Amount;
                            }
                            oppItems opWr = new oppItems();
                            opWr.oppname = opp.Name;
                            opWr.oppstage = opp.StageName;
                            opWr.amount = (string.valueOf(opp.Amount)==NULL?' ':string.valueOf(opp.Amount));
                            opWr.oppLink = '/'+opp.Id;
                            opWr.stageDuration = opp.FBE_Sales_Stage_Duration__c;
                            opWr.closeDate = opp.closeDate;
                            opWr.stage = opp.StageName;
                            oppItems.add(opWr);
                        }
                    }
                    aIII.amount = string.valueOf(amnt);
                    aIII.Items = oppItems;
                    //aItems.add(aIII);
                if(acwrapMap.get(accTeam.user.name) == NULL){
                    acwrapMap.put(accTeam.user.name,new List<Items>{aIII});
                }else{
                    acwrapMap.get(accTeam.user.name).add(aIII);
                }
                userNameWithId.put(accTeam.user.name,accTeam.userId);
                //aooo.add(acWrap);
            }
            
        }
        if(! acwrapMap.isEmpty()){
            AccountWrapper acWrapManager = new AccountWrapper();
            if(acwrapMap.get(userInfo.getName()) != NULL){
                //acWrapManager.role = 'Manager';
                acWrapManager.nameL = userInfo.getName();
                if(userNameWithId.get(userInfo.getName()) != NULL){
                    acWrapManager.name = '/'+userNameWithId.get(userInfo.getName());
                }
                acWrapManager.items = acwrapMap.get(userInfo.getName());
                aooo.add(acWrapManager);
                acwrapMap.remove(userInfo.getName());
            }
            for(String str : acwrapMap.keySet()){
                AccountWrapper acWrap = new AccountWrapper();
                acWrap.nameL = str;
                if(userNameWithId.get(str) != NULL){
                    acWrap.name = '/'+userNameWithId.get(str);
                }
                if(acwrapMap.get(str) != NULL){
                    //acWrap.role = 'SalesRep';
                    acWrap.items = acwrapMap.get(str);
                }
                aooo.add(acWrap);
            }
            
        }
        system.debug('aooo'+aooo);
        
        return JSON.Serialize(aooo) ;
    } 
    public Class AccountWrapper{
        @AuraEnabled
        public String role {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String nameL {get;set;}
        @AuraEnabled
        public String nameLink {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }
    public Class Items{
        @AuraEnabled
        public String teamMemRole {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String nameL {get;set;}
        @AuraEnabled
        public String accType {get;set;}
        @AuraEnabled
        public string amount {get;set;}
        @AuraEnabled
        public List<oppItems> items {get;set;}
    }
    public class oppItems{
        @AuraEnabled
        public String oppname {get;set;}
        @AuraEnabled
        public String oppstage {get;set;}
        @AuraEnabled
        public String oppLink{get;set;}
        @AuraEnabled
        public string amount {get;set;}
        @AuraEnabled
        public decimal stageDuration {get;set;}
        @AuraEnabled
        public Date closeDate {get;set;}
        @AuraEnabled
        public string Stage{get;set;}
    }
    
}