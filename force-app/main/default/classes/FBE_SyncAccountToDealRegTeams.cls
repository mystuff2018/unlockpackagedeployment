/**************
 *@ Class Name        : FBE_SyncAccountToDealRegTeams
 *@ Description       : This class is written to synchronize account team member updates to related Deal Reg teams. 
 *@ CreatedBy         : Dell Team
 *@ CreatedOn         : 05-02-2020
 *@ Modification Log  : [Sireesha Myla] :  STORY 8358218 - 
                        Created script to INSERT and DELETE Deal team members based Account teams sync from Siebel
                        This handler invoked in 'FBE_SyncTeamComparator', 'FBE_SyncTeamBatch' where Account to Opty teams batch optimized
 ***************/
public with sharing class FBE_SyncAccountToDealRegTeams 
{
   public void syncDealRegTeams(Set<Id>accIdSet)
   {
   system.debug('inside syncDealRegTeams'+accIdSet);
       try{
           Set<Id> setAccIds = new Set<Id>(accIdSet);
           List<Deal_Registration__c> DealRegList = new List<Deal_Registration__c>();
           Map<Id, List<AccountTeamMember>> mapAccountTeamMember = new Map<Id, List<AccountTeamMember>>();
           Map<Id, List<Id>> AccIdRelatedDealIds = new Map<Id, List<Id>>();
           Set<Id> relatedAccIds = new Set<Id>();
           Map<Id, List<Id>> mapDealAcc = new Map<Id, List<Id>>();
           Map<Id, List<AccountTeamMember>> dealAccTeamMemberMap = new Map<Id, List<AccountTeamMember>>();
           Set<Id> relatedDealIds = new Set<Id>();
           
           List<String> dealRegStatusLOVs = System.Label.FBE_Deal_Reg_Status.split(';');
           Map<Id, List<FBE_Deal_Registration_Team__c>> mapDealDealTeamMember = new Map<Id, List<FBE_Deal_Registration_Team__c>>();
           
           for(Account accObj : [SELECT id, (SELECT id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers) FROM Account where id IN: setAccIds])
                mapAccountTeamMember.put(accObj.id,accObj.AccountTeamMembers);
           
           for(Deal_Registration__c deal : [Select Id, FBE_Account__c, FBE_End_User_Account__c, FBE_OEM_Account__c, FBE_Distributor_Account__c, FBE_FSI_Account__c, FBE_Reseller_VAR_Account__c, FBE_Deal_Registration_Status__c, FBE_Related_Opportunity__c
                                           FROM Deal_Registration__c WHERE ((FBE_Deal_Registration_Status__c = 'Approved' AND FBE_Related_Opportunity__r.StageName != 'Won - 100%' AND FBE_Related_Opportunity__r.StageName != 'Lost - 0%' 
                                                                            AND FBE_Related_Opportunity__r.StageName != 'Cancelled - 0%') OR FBE_Deal_Registration_Status__c = 'Submitted' OR FBE_Deal_Registration_Status__c = 'Hold for Review' 
                                            								OR (FBE_Deal_Registration_Status__c = 'Rejected' AND Days_Since_Created_Date__c < 365) OR (FBE_Deal_Registration_Status__c = 'Returned' AND Days_Since_Created_Date__c < 365))
                                            								AND (FBE_Account__c IN: setAccIds 
                                            									OR FBE_FSI_Account__c IN : setAccIds
                                            									OR FBE_OEM_Account__c IN : setAccIds
                                            									OR FBE_End_User_Account__c IN : setAccIds
                                            									OR FBE_Reseller_VAR_Account__c IN : setAccIds
                                            									OR FBE_Distributor_Account__c IN : setAccIds)])
                                      {
                                          DealRegList.add(deal);
                                          relatedDealIds.add(deal.Id);
                                         
                                      }
           		
                                      
           for(Id AccId: setAccIds)
           {
               List<Id> AccDealIdsList = new List<Id>();
               for(Deal_Registration__c dealReg: DealRegList)
               {
                   if( (dealReg.FBE_Account__c == AccId && String.isNotBlank(dealReg.FBE_Account__c) ) || 
                       (dealReg.FBE_End_User_Account__c == AccId && String.isNotBlank(dealReg.FBE_End_User_Account__c) )|| 
                       (dealReg.FBE_FSI_Account__c == AccId && String.isNotBlank(dealReg.FBE_FSI_Account__c) )||
                       (dealReg.FBE_OEM_Account__c == AccId && String.isNotBlank(dealReg.FBE_OEM_Account__c) )||
                       (dealReg.FBE_Reseller_VAR_Account__c == AccId && String.isNotBlank(dealReg.FBE_Reseller_VAR_Account__c) )||
                       (dealReg.FBE_Distributor_Account__c == AccId && String.isNotBlank(dealReg.FBE_Distributor_Account__c) )
                     )
                   {
                       AccDealIdsList.add(dealReg.Id);
                   }
               }
               //Map to store AccountId and related Deal reg Id
               if(!AccDealIdsList.isEmpty())
               {
                   AccIdRelatedDealIds.put(AccId,AccDealIdsList);
               }
               
           }
           for(Deal_Registration__c deals: DealRegList)
           {
                List<Id> DealRelAcc = new List<Id>();
                relatedAccIds.add(deals.FBE_Account__c);
                relatedAccIds.add(deals.FBE_End_User_Account__c);
                relatedAccIds.add(deals.FBE_FSI_Account__c);
                relatedAccIds.add(deals.FBE_OEM_Account__c);
                relatedAccIds.add(deals.FBE_Reseller_VAR_Account__c);
                relatedAccIds.add(deals.FBE_Distributor_Account__c);
                //System.debug('Set of Accounts' + relatedAccIds);
                
                DealRelAcc.add(deals.FBE_Account__c);
                DealRelAcc.add(deals.FBE_End_User_Account__c);
                DealRelAcc.add(deals.FBE_FSI_Account__c);
                DealRelAcc.add(deals.FBE_OEM_Account__c);
                DealRelAcc.add(deals.FBE_Reseller_VAR_Account__c);
                DealRelAcc.add(deals.FBE_Distributor_Account__c);
                mapDealAcc.put(deals.Id, DealRelAcc);
           }
           //Create a Map of Account Team Members belonging to Deal Reg - related Accounts
           for(Account accObj : [SELECT id, (SELECT id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers) FROM Account where id IN: relatedAccIds])
           {
                dealAccTeamMemberMap.put(accObj.id,accObj.AccountTeamMembers);
           }
           
           //Create a Map of Deal Reg Team Members
            for(Deal_Registration__c dealObj : [Select Id, (Select Id, Deal_Registration__c, User__c, Role__c, FBE_Auto_Created__c FROM Deal_Registration_Team__r) FROM Deal_Registration__c where Id in : relatedDealIds])
            {
                mapDealDealTeamMember.put(dealObj.Id, dealObj.Deal_Registration_Team__r);
            }
           
            //BEGIN - Insert Team Members to Deal Reg script. 
            //For every account - loop over list of related Deal Reg Team Members. If Account Team Member is not in Deal Reg Team Members List - insert record
            List<FBE_Deal_Registration_Team__c> DealTeamMemberInsert = new List<FBE_Deal_Registration_Team__c>();
            for(Id accObj : AccIdRelatedDealIds.keySet())
            {
                 List<AccountTeamMember> accTeamList = mapAccountTeamMember.get(accObj);
                 List<Id> accDealsList =  AccIdRelatedDealIds.get(accObj);
                 //System.debug('AccTeamList '+ accTeamList);
                 //System.debug('AccOptyList '+ accOppList);
                 for(Id dealObj :accDealsList)
                 {
                        Id dealId = dealObj;
                        List<FBE_Deal_Registration_Team__c> dealTeamList_1 = mapDealDealTeamMember.get(dealObj);
                        //System.debug('DealRegTeamList '+ dealTeamList_1);
                        List<String> dealUserId = new List<String>();
                        for(FBE_Deal_Registration_Team__c dealTeamMem : dealTeamList_1)
                        {
                            //System.debug('AccTeamList ' + accTeamList + ' Deal Reg Team List ' + dealTeamList_1);
                            //oppId = oppTeamMem.OpportunityId;
                            dealUserId.add(dealTeamMem.User__c);
                            //System.debug('deal ID' + dealId + ' deal reg Member Id : '+dealRegTeamMem.UserId);
                        }
                        for(AccountTeamMember accMem : accTeamList)
                        {
                            String accMemUserId = accMem.UserId;
                            //System.debug('deal reg User List ' +dealUserId);
                            if(!(dealUserId.contains(accMemUserId)))
                            {
                                //System.debug('Member not found in deal Reg');
                                FBE_Deal_Registration_Team__c dtm = new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealId,
                                                                                     User__c = accMem.UserId,
                                                                                     Role__c = accMem.TeamMemberRole,
                                                                                     Access_level__c = 'Read/Write',
                                                                                     FBE_Auto_Created__c = 'Y', Created_From_Batch__c = True);
                               DealTeamMemberInsert.add(dtm);
                             }
                        }
                        dealUserId = null;
                 }
             }
             //END - Insert Team Members to Deal Reg script
             
             //BEGIN - Delete Team Members from Deal Reg
            //For every Deal reg - loop over list of related Accounts. If Deal Reg Team Member is no longer a part of Account Team Member - delete Deal Reg Team Member  
            List<FBE_Deal_Registration_Team__c> dealTeamMemberDelete = new List<FBE_Deal_Registration_Team__c>();
            for(Id deal : mapDealAcc.keySet())
            {
                List<FBE_Deal_Registration_Team__c> dealTeamList_2 = mapDealDealTeamMember.get(deal);
                List<Id> dealAccList = mapDealAcc.get(deal);
                //System.debug('deal reg List ' + deal + ' deal Acc List ' + dealAccList);
                
                List<String> accTeamUserId = new List<String>();
                for(Id accDeal : dealAccList)
                {
                    List<AccountTeamMember> dealAccTeamList = dealAccTeamMemberMap.get(accDeal);
                    if(accDeal != null) 
                    {
                        for(AccountTeamMember accTeamMem : dealAccTeamList)
                        {
                            String accTeamMemberUserId = accTeamMem.UserId;
                            if(!(accTeamUserId.contains(accTeamMemberUserId)))
                            {
                                accTeamUserId.add(accTeamMem.UserId);                                
                            }
                        }
                    }
                }
                //System.debug('List of Account Team Members ' + accTeamUserId);
                for(FBE_Deal_Registration_Team__c dealTeamMem : dealTeamList_2)
                {
                    String dealTeamMemUserId = null;
                    if(dealTeamMem.FBE_Auto_Created__c == 'Y')
                    { //Retain team members added manually from UI. Auto_created field = N
                        system.debug('am here in y');
                        dealTeamMemUserId = dealTeamMem.User__c;
                    }
                    if(dealTeamMemUserId != null) 
                    {
                        if(!(accTeamUserId.contains(dealTeamMemUserId)))
                        {
                            FBE_Deal_Registration_Team__c dtm = new FBE_Deal_Registration_Team__c(Id = dealTeamMem.Id);
                            dealTeamMemberDelete.add(dtm); 
                        }
                    }
                }
                accTeamUserId = null;
            }
            //END - Delete Team Members from Deal Reg
           
            //INSERT - DELETE Deal Reg Team Members using Database Methods with Partial Success
            System.debug('Deal Reg Team Member to insert ' + DealTeamMemberInsert);
            if(!DealTeamMemberInsert.isEmpty())
            {
                Database.SaveResult[] srList = Database.insert(DealTeamMemberInsert, false);
                
                List<FBE_Configurator__c> logsList= new List<FBE_Configurator__c>();                
                for(Database.SaveResult sr : srList)
                {
                    if(sr.isSuccess())
                    {
                        
                        System.debug('Successfully inserted Deal Reg Team Member. Deal Reg Team Member ID: ' + sr.getId());
                    }
                    else {
                        system.debug('errors :'+ sr.errors);
                            // Operation failed,get all errors logs into FBE_Configurator__c
                            String logName = 'Deal TM INSRT Failed';FBE_Configurator__c logg = FBE_LogHandler.databaseSaveLogInformation(sr, logName);logsList.add(logg);
                        

                        }
                }
                
                
                insert logsList;
            }

            System.debug('Deal Reg Team Member to Delete ' + dealTeamMemberDelete);
            if(!dealTeamMemberDelete.isEmpty())
            {
                List<FBE_Configurator__c> logsList= new List<FBE_Configurator__c>(); 
                Database.DeleteResult[] drList = Database.delete(dealTeamMemberDelete, false);
                
                for(Database.DeleteResult dr : drList)
                {
                    if(dr.isSuccess())
                    {
                        System.debug('Successfully deleted Deal Reg Team Member. Deal Reg Team Member ID: ' + dr.getId());
                    }
                    else{
                             // Operation failed, get all errors logs into FBE_Configurator__c
                             String logName = 'Deal TM DLT Failed';FBE_Configurator__c logg = FBE_LogHandler.databaseDeleteLogInformation(dr, logName);logsList.add(logg);
                        }
                }
                insert logsList;
            }
            
            dealTeamMemberInsert = null;
            dealTeamMemberDelete = null;
       }//END -try block
      Catch(Exception e){
           System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
           String logName = 'Deal TM Exception';FBE_LogHandler.LogException(e, logName);
       }

   }
}