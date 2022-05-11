/*******
* Modified by : Sireesha Myla - Method name[testShare]
 * DellTeam    : Story#9489610 - BDD2[Feb 24th 2021]
                04/26/2021 - [Siva Kumar Valluru]- Renamed the Arc Engagement Request(Case Recordtype Name) into DCWS Engagement Request as per Story #10416631
 * 
 **/
@isTest
public class CaseTriggerHelperTest {
    @isTest
    public static void testMethodCaseTriggerHelper()
    {
        Id rectypeId = [SELECT id, name from Recordtype where name='FBE Support Request' limit 1].Id;
        system.assertNotEquals(null, rectypeId, 'Couldnt retrieve FBE Support Request RecordType');
        
        Id gId = [select Id from Group where  Type = 'Queue' AND NAME = 'FBE Production Support' limit 1].Id ;
        List<Case> insertList = new List<Case>();
        Case c=new Case(origin ='Email', recordtypeId =rectypeId );
        Case warCase = new Case(origin ='Email', recordtypeId =rectypeId, OwnerId=gId);
        insertList.add(c); insertList.add(warCase);
        
        insert insertList;
        
    }
    @isTest
    public static void updateAccountField(){     
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
          System.runAs(lUser[0])
          {
                    
                Case c=new Case();
                List < Account > lAcc = FBE_Test_utility.createAccount(1);
                insert lAcc;
                //Rakesh - inserted Account Team Member for Story#9015984
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = lAcc[0].id;
                atm.UserId = lUser[0].id;
                atm.TeamMemberRole = 'SR';
                atm.AccountAccessLevel = 'Read';
                insert atm;
              
                //Id pricebookId = Test.getStandardPricebookId();
                
                //Instantiate the Pricebook2 record with StandardPricebookId
                Pricebook2 standardPricebook = new Pricebook2(
                 Id = Test.getStandardPricebookId(),
                 IsActive = true
                );
              
                //Execute an update DML on the Pricebook2 record, to make IsStandard to true
                Update standardPricebook;
              
                 //Query for the Pricebook2 record, to check IsStandard field
                standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
                //It should return true
                System.assertEquals(true, standardPricebook.IsStandard);
              
              //Create your product
                   Product2 prod = new Product2(
                        Name = 'Product X',
                        ProductCode = 'Pro-X',
                        isActive = true
                    );
                    insert prod;
              
               //Create the PricebookEntry
                PricebookEntry pbe = new PricebookEntry(
                 Pricebook2Id = standardPricebook.Id,
                 Product2Id = prod.Id,
                 UnitPrice = 1020,
                 IsActive = true
                );
                Insert pbe;
              
/*                    //Create your pricebook entry
                    List < PriceBookEntry > pbe = [Select id from PriceBookEntry where Product2Id =: prod.id and Pricebook2Id =: pricebookId LIMIT 1];
        
                    if (pbe.size() > 0) {
                        pbe[0].UnitPrice = 99;
                        pbe[0].IsActive = true;
                    } else {
                        PriceBookEntry pbeTmp = new PricebookEntry(
                            Pricebook2Id = pricebookId,
                            Product2Id = prod.Id,
                            UnitPrice = 99,
                            isActive = true
                        );
                        pbe.add(pbeTmp);
                    }
                    upsert pbe;
                    //System.debug('pbe:: '+);
                    system.assertEquals(true, pbe[0].isActive, 'no active pricebook entry records found');
                */
                    List < Account > accnt = [select id from account];
                  
                    //create Opportunity
                    Opportunity opp = new Opportunity(
                        Name = 'Opportunity Test',
                        AccountId = accnt[0].Id,
                        StageName = 'Plan - 1%',
                        FBE_Pursuit_Type__c = 'Indirect',
                        FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                        CloseDate = System.today(),
                        FBE_FSI_Account__c = accnt[0].Id,
                        FBE_VAR_Seller__c = accnt[0].Id,
                        FBE_Distributor__c = accnt[0].Id,
                        Pricebook2Id = standardPricebook.id
                    );
                    Insert opp;
                
                c.FBE_Opportunity_Name__c = opp.Id;
                insert c;
              
              }
    }
    
    
    @isTest
    public static void testShare(){
        
        List<Case> caseList = new List<Case>();
        List<Case> updatecaseList = new List<Case>();
        User u1 =[Select Id from User where isActive=true AND FBE_Integration_User__c = true limit 1];
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        Test.startTest();
              Id rectypeId = [SELECT id, name from Recordtype where name='DCWS Engagement Request' limit 1].Id;
              Id rectypeId1 = [SELECT id, name from Recordtype where name='Federal Premier Support' limit 1].Id;
              Id rectypeId2 = [SELECT id, name from Recordtype where name='FBE Support Request' limit 1].Id;
              Id rectypeId3 = [SELECT id, name from Recordtype where name='Partner Support Request' limit 1].Id;
              Case insCase = new Case();
              insCase.RecordTypeId = rectypeId;
              insCase.FBE_Case_Submitter__c = lUsr[0].Id; 
                 caseList.add(insCase);
              
              Case insCase1 = new Case();
              insCase1.RecordTypeId = rectypeId1;
              insCase1.FBE_Case_Submitter__c = lUsr[0].Id;
                caseList.add(insCase1);
              
              Case insCase2 = new Case();
              insCase2.RecordTypeId = rectypeId2;
              insCase2.FBE_Case_Submitter__c = lUsr[0].Id;
                caseList.add(insCase2);
              
              Case insCase3 = new Case();
              insCase3.RecordTypeId = rectypeId3;
              insCase3.FBE_Case_Submitter__c = lUsr[0].Id;
                caseList.add(insCase3);
              INSERT caseList;
              Case c = caseList[0];
              c.OwnerId = u1.Id;
              c.FBE_Case_Submitter__c = u1.Id;
                 updatecaseList.add(c);
              Case c1 = caseList[1];
              c1.OwnerId = u1.Id;
              c1.FBE_Case_Submitter__c = u1.Id;
                 updatecaseList.add(c1);
              Case c2 = caseList[2];
              c2.OwnerId = u1.Id;
              c2.FBE_Case_Submitter__c = u1.Id;
                 updatecaseList.add(c2);
              Case c3 = caseList[3];
              c3.OwnerId = u1.Id;
              c3.FBE_Case_Submitter__c = u1.Id;
                 updatecaseList.add(c3);
              UPDATE updatecaseList;
        
          System.runAs(lUsr[0])
          {
                Case cs =new Case();    
                List < Account > lAcc = FBE_Test_utility.createAccount(1);
                insert lAcc;
                //Rakesh - inserted Account Team Member for Story#9015984
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = lAcc[0].id;
                atm.UserId = lUsr[0].id;
                atm.TeamMemberRole = 'SR';
                atm.AccountAccessLevel = 'Read';
                insert atm;
              
              Pricebook2 standardPricebook = new Pricebook2(
                 Id = Test.getStandardPricebookId(),
                 IsActive = true
                );
              
                //Execute an update DML on the Pricebook2 record, to make IsStandard to true
                Update standardPricebook;
              
                 //Query for the Pricebook2 record, to check IsStandard field
                standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
                //It should return true
                System.assertEquals(true, standardPricebook.IsStandard);
              
              //Create your product
                   Product2 prod = new Product2(
                        Name = 'Product X',
                        ProductCode = 'Pro-X',
                        isActive = true
                    );
                    insert prod;
              
               //Create the PricebookEntry
                PricebookEntry pbe = new PricebookEntry(
                 Pricebook2Id = standardPricebook.Id,
                 Product2Id = prod.Id,
                 UnitPrice = 1020,
                 IsActive = true
                );
                Insert pbe;
              
                List < Account > accnt = [select id from account where id in:lAcc];
                  
                    //create Opportunity
                    Opportunity opp = new Opportunity(
                        Name = 'Opportunity Test',
                        AccountId = accnt[0].Id,
                        StageName = 'Plan - 1%',
                        FBE_Pursuit_Type__c = 'Indirect',
                        FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                        CloseDate = System.today(),
                        FBE_FSI_Account__c = accnt[0].Id,
                        FBE_VAR_Seller__c = accnt[0].Id,
                        FBE_Distributor__c = accnt[0].Id,
                        Pricebook2Id = standardPricebook.id
                    );
                    Insert opp;
                cs.FBE_Opportunity_Name__c = opp.Id;
                insert cs;

          }
          //CaseTeamRole role = [select Id from CaseTeamRole where Name = :'Case Submitter' limit 1];
          /*List<CaseTeamMember> caseTeamlist = new list<CaseTeamMember>();
            caseTeamlist.add(new CaseTeamMember(ParentId=caseList[0].Id,MemberId=lUsr[0].id,TeamRoleId=role.Id));
            caseTeamlist.add(new CaseTeamMember(ParentId=caseList[1].Id,MemberId=lUsr[0].id,TeamRoleId=role.Id));
            caseTeamlist.add(new CaseTeamMember(ParentId=caseList[2].Id,MemberId=lUsr[0].id,TeamRoleId=role.Id));
            caseTeamlist.add(new CaseTeamMember(ParentId=caseList[3].Id,MemberId=lUsr[0].id,TeamRoleId=role.Id));*/
            //insert caseTeamlist;
       Test.stopTest();
    
    }
    @isTest
    public static void testShare1(){
         Case c=new Case();
        Id rectypeId = [SELECT id, name from Recordtype where name='FBE Support Request' limit 1].Id;
        system.assertNotEquals(null, rectypeId, 'Couldnt retrieve FBE Support Request RecordType');
              Case insCase = new Case();
              insCase.RecordTypeId = rectypeId;
              INSERT insCase;
        
        
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        Case updCase = new Case();
        updCase.Id = insCase.Id;
         updCase.OwnerId = lUsr[0].Id;
        UPDATE updCase;

    
    }
    
    @isTest
    public static void testShare2(){
         Case c=new Case();
        Id rectypeId = [SELECT id, name from Recordtype where name='Partner Support Request' limit 1].Id;
        system.assertNotEquals(null, rectypeId, 'Couldnt retrieve Partner Support Request RecordType');
              Case insCase = new Case();
              insCase.RecordTypeId = rectypeId;
              INSERT insCase;
        
        
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        Case updCase = new Case();
        updCase.Id = insCase.Id;
         updCase.OwnerId = lUsr[0].Id;
        UPDATE updCase;

    
    }
    
    //Pramith: 08/07/2020: Added for Feature#7622821 for Fed Premier Support
    @isTest
    public static void testFederaleSalesCase()
    {
        Id recTypeId = [SELECT id, name from Recordtype where name='Federal Premier Support' limit 1].Id;
        system.assertNotEquals(null, recTypeId, 'Couldnt retrieve Federal Premier Support RecordType');
        
        User intUser = [select id from User where FBE_Integration_User__c = true limit 1];
        Id groupId = [select Id from Group where  Type = 'Queue' AND NAME = 'Premier Page Assistance Cases' limit 1].Id ;
    
        List<Case> eSalesCaseList = new List<Case>();
        Case c1 = new Case(RecordTypeId =recTypeId, Type='Premier Page Assistance');
        eSalesCaseList.add(c1); 
        
        insert eSalesCaseList;
        Id c1Id = eSalesCaseList[0].Id;
        Case c1Created = [select Origin, OwnerId from Case where Id=:c1Id];
        String c1Origin = c1Created.Origin;
        Id c1Owner = c1Created.OwnerId;
        system.assertEquals('SFDC', c1Origin, 'Incorrect Case Origin');
        //system.assertEquals(groupId, c1Owner, 'Incorrect Case owner Group');
         
        system.RunAs(intUser)
        {
            List<Case> eSalesCaseList2 = new List<Case>();
            Case c2 = new Case(RecordTypeId =recTypeId, Type='Premier Page Assistance');
          eSalesCaseList2.add(c2);
            insert eSalesCaseList2;
            Id c2Id = eSalesCaseList2[0].Id;
            Case c2Created = [select Origin, OwnerId from Case where Id=:c2Id];
            String c2Origin = c2Created.Origin;
            Id c2Owner = c2Created.OwnerId;
            
            //system.assertEquals('eSales', c2Origin, 'Incorrect Case Origin');
            //system.assertEquals(groupId, c2Owner, 'Incorrect Case owner Group');
        }
    }
    
    @isTest
    public static void noActivityBatchTest(){ 
        Test.startTest();
        Case c=new Case();
        Id rectypeId = [SELECT id, name from Recordtype where name='FBE Support Request' limit 1].Id;
        system.assertNotEquals(null, rectypeId, 'Couldnt retrieve FBE Support Request RecordType');
              Case insCase = new Case();
              insCase.RecordTypeId = rectypeId;
              insCase.Status = 'Open';
              insCase.FBE_Case_Manager_Comments__c = 'Please Check Asap'; 
              INSERT insCase;

        List<case> cse = [Select id, CaseNumber,
                                         FBE_Age_In_Days__c,
                                         Status,
                                         FBE_Case_Manager_Comments__c,
                                         LastModifiedDate,
                                         OwnerId FROM Case where RecordTypeId=:rectypeId];
        system.debug('case record ' +cse);
        FBE_CaseInactivity_EmailBatch job = new FBE_CaseInactivity_EmailBatch();
        Database.executeBatch(job, 200);
        
        FBE_CaseInactivityEmail_sch reminder = new FBE_CaseInactivityEmail_sch();
                    //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
                    String sch = '0 0 9 * * ?';
                    String jobID = System.schedule('Remind Opp', sch, reminder);  
        
        Test.stopTest();
    }
    
}