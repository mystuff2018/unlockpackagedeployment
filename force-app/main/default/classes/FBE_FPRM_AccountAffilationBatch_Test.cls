@isTest
public class FBE_FPRM_AccountAffilationBatch_Test {
    @isTest
    static void testAccountSharing(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            
            List<Account> accountList = FBE_Test_Utility.createAccount(2);
            insert accountList;
            accountList[0].FBE_Partner_Type__c = 'Distributor';
            accountList[0].FBE_FPRM_Partner_Reg_Status__c ='Registered';
            accountList[1].FBE_Partner_Type__c = 'Reseller';
            accountList[1].FBE_FPRM_Partner_Reg_Status__c ='Registered';
            
            update accountList;
            
            
            List<Contact> contactList = FBE_Test_Utility.createContact(1, accountList[0].Id);
            contactList[0].Email = 'genelia.dsouza@gmail.com';
            insert contactList;
            
            List<contact> contactList2= FBE_Test_Utility.createContact(1, accountList[1].Id);
            contactList2[0].Email = 'genelia.dsouza@gmail.com';
            insert contactList2;
            
            
            Account_Affiliation__c aff = new Account_Affiliation__c();
            aff.FBE_Account__c = accountList[0].Id;
            aff.FBE_Affilitated_Account__c = accountList[1].Id;
            aff.FBE_Relationship__c ='Reseller';
            aff.FBE_Start_Date__c = System.today() - 2;
            aff.FBE_End_Date__c = System.today();
            insert aff;
            
            Account_Affiliation__c aff2 = new Account_Affiliation__c();
            aff2.FBE_Account__c = accountList[1].Id;
            aff2.FBE_Affilitated_Account__c = accountList[0].Id;
            aff2.FBE_Relationship__c ='Distributor';
            aff2.FBE_Start_Date__c = System.today() -2;
            aff2.FBE_End_Date__c = System.today();
            insert aff2;
            
            Account_Affiliation__c aff3 = new Account_Affiliation__c();
            aff3.FBE_Account__c = accountList[0].Id;
            aff3.FBE_Affilitated_Account__c = accountList[1].Id;
            aff3.FBE_Relationship__c ='Disty Managed';
            aff3.FBE_Start_Date__c = System.today()-2;
            aff2.FBE_End_Date__c = System.today();
            insert aff3; 
            
            Test.startTest();
            FBE_FPRM_AccountAffilationStatusBatch afb = new FBE_FPRM_AccountAffilationStatusBatch ();
            Id batchJobId = database.executeBatch(afb,10);
            FBE_FPRM_AccountAffilationStatus_SCH reminder = new FBE_FPRM_AccountAffilationStatus_SCH();
            //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String sch = '0 0 * * * ?';
            String jobID = System.schedule('Remind Opp', sch, reminder);  
            Test.stopTest();
            AsyncApexJob apexjob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchJobId ];
            System.assertEquals('Completed', apexjob.Status, 'Batch did not run');
        }
        
    }
    
}