/**************
* @ Class Name        : FBE_UpdateDealShareBatch
* @ Description       : This is a batch class written for creating share records for deal team mebers
* @ CreatedBy         : Dell
* @ CreatedOn         : 09-27-2020
* @ Modification Log  : 
*********/


public class FBE_UpdateDealShareBatch implements Database.Batchable<sObject> {
    DateTime soqlRunDate;
    //constructor 
    List<id> dealids = new List<id>();
    /*
    public FBE_UpdateDealShareBatch(List<id> listofdeal){
        this.dealids = listofdeal;
    }*/
    String dealSharingReason = Schema.Deal_Registration__Share.RowCause.Deal_Team_Sharing__c;
    Map<Id,Deal_Registration__Share> sharesToDelete= new Map<id,Deal_Registration__Share>();
    Map<id,list<string>> DealRegTeamMap = new Map<id,list<string>>();
    List<FBE_Deal_Registration_Team__c> sharesToAdd= new List<FBE_Deal_Registration_Team__c>();
    map<id,list<FBE_Deal_Registration_Team__c>> dealwithTeam = new map<id,list<FBE_Deal_Registration_Team__c>>();
    map<id,list<string>> dealwithShare = new map<id,list<string>>();
    Map<id,List<Deal_Registration__Share>> DealRegShareMap = new Map<id,List<Deal_Registration__Share>>();
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //String strQuery = 'Select Id from Deal_Registration__c where id in :[\'a02r000000327ZiAAI\',\'a02r000000329kxAAA\']';
        //String strQuery = 'Select Id from Deal_Registration__c where id in :dealids';
        
        //String strQuery = 'Select Id from Deal_Registration__c where LastModifiedDate = :dt';
        return Database.getQueryLocator([Select Id from Deal_Registration__c where LastModifiedDate >= :System.now().addSeconds(-7200)]);
    }
    public void execute(Database.BatchableContext bc, List<Deal_Registration__c> scope) {
        List<FBE_Deal_Registration_Team__c> dtm = [Select Id,User__c,Access_level__c,Deal_Registration__c from FBE_Deal_Registration_Team__c where Deal_Registration__c in: scope];
        for(FBE_Deal_Registration_Team__c dt : dtm){
            if(!dealwithTeam.containsKey(dt.Deal_Registration__c)){
              system.debug('YES####');
                dealwithTeam.put(dt.Deal_Registration__c,new List<FBE_Deal_Registration_Team__c>{dt});
                DealRegTeamMap.put(dt.Deal_Registration__c,new List<string>{dt.User__c});
            }else{
                dealwithTeam.get(dt.Deal_Registration__c).add(dt);
                 DealRegTeamMap.get(dt.Deal_Registration__c).add(dt.User__c);
            }
            
              
            
        }
        List<Deal_Registration__Share> drs = [SELECT id,UserOrGroupId,parentid FROM Deal_Registration__Share WHERE RowCause =:dealSharingReason and parentid in: dealwithTeam.Keyset()];
        for(Deal_Registration__Share ds : drs){
            
            if(!dealwithShare.containskey(ds.parentid)){
                DealRegShareMap.put(ds.parentid,new List<Deal_Registration__Share>{ds});
                dealwithShare.put(ds.parentid,new List<string>{ds.UserOrGroupId});
            }else{
                dealwithShare.get(ds.parentid).add(ds.UserOrGroupId);
                DealRegShareMap.get(ds.parentid).add(ds);
            }
        }
        
        system.debug('dealwithShare'+dealwithShare);
        system.debug('dealwithTeam'+dealwithTeam);
        if(dealwithTeam != null && !dealwithTeam.isEmpty()){
        for(id deals : dealwithTeam.Keyset()){
            for(FBE_Deal_Registration_Team__c dealteamRec : dealwithTeam.get(deals)){
                //system.debug('doesnot contain'+!dealwithShare.get(deals).contains(dealteamRec.Deal_Registration__c));
                //system.debug('dealwithShare.get(deals)'+dealwithShare.get(deals));
               //system.debug('dealteamRec.User__c'+dealteamRec.User__c);
                List<string> shres = dealwithShare.get(deals);
                system.debug('shres#####'+shres);
                if(shres != null && shres.size()>0){
                 system.debug('shresnotnull#####'+shres);
                    if(!dealwithShare.get(deals).contains(dealteamRec.User__c)){
                    sharesToAdd.add(dealteamRec);
                    }
                }else if(shres == null){
                 system.debug('shresnull#####'+shres);
                    sharesToAdd.add(dealteamRec);
                }
                
            }
            system.debug('DealRegTeamMap'+DealRegTeamMap);
            if(DealRegShareMap != null && !DealRegShareMap.isEmpty() && DealRegShareMap.containsKey(deals)){
            for(Deal_Registration__Share DRegShare:DealRegShareMap.get(deals)){ 
                system.debug('DealRegTeamMap.get(deals)'+DealRegTeamMap.get(deals));
                system.debug('UserOrGroupId'+DRegShare.UserOrGroupId);
                system.debug('DealRegTeamMap.get(deals).contains(DRegShare.UserOrGroupId)'+(!DealRegTeamMap.get(deals).contains(DRegShare.UserOrGroupId)));
                if(!DealRegTeamMap.get(deals).contains(DRegShare.UserOrGroupId)){                    
                    sharesToDelete.put(DRegShare.id,DRegShare);
                }
            }
            }
        }
        }
        
        System.debug(' Shares to ADd'+sharesToAdd.size());
        system.debug('added shares'+sharesToAdd);
        System.debug(' delete list size'+sharesToDelete.size());
        system.debug('sharesToDelete'+sharesToDelete);
        try {
            if(sharesToDelete.values() != null && sharesToDelete.values().size()>0){
                system.debug('delshare'+sharesToDelete);
                delete (sharesToDelete.values());
            }
        }catch(Exception e){
            system.debug('Exception in deletion'+e);
        }
        if(sharesToAdd != null && sharesToAdd.size()>0){
            system.debug('insideshare');
        FBE_DealHelper dh = new FBE_DealHelper();
        dh.createDealTeamMemberShare(sharesToAdd);
        }
    }   
    public void finish(Database.BatchableContext bc) {
    }
}