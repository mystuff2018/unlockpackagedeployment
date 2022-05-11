@isTest
public class FBE_IDS_LeadStateCodeUpdateLogicTest {
	 @isTest public static void setup() {
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
        List<Lead> insLeadList = new List<Lead>();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
        for(Integer i=0 ;i <lAcc.size() ; i++){
            lAcc[i].name = 'SFDC Test Account'+i;
        }
         test.startTest();
        system.runAs(lUsr[0]) {
            //Create an Account
            
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id, 'Account Record not found');
            system.assertNotEquals(null, lAcc[1].id, 'Account Record not found');
            
            
            List < Campaign > campaignList = FBE_UtilityFactory_Test.createCampaign(1);
            insert campaignList;
            for(Integer i=0 ;i<=3 ;i ++){
                Lead leadRecord = new Lead();
                leadRecord.Company = 'Company_Test'+i;
                leadRecord.FirstName = 'Lead Fname'+i;
                leadRecord.LastName = 'Lead LName'+i;
                leadRecord.FBE_Lead_Type__c = 'Inbound';
                leadRecord.Email = 'testleadabc@abc.com';
                leadRecord.Phone = '1232789';
                leadRecord.FBE_Sales_Role__c = 'SR';
                leadRecord.FBE_Campaign__c = campaignList[0].Id;
                leadRecord.FBE_Account_Name__c = lAcc[0].id;
                leadRecord.FBE_End_User_Account__c = lAcc[1].id;
                leadRecord.ownerid = lUsrNonIntegration[0].id;
                leadRecord.Opportunity_Product_Classification__c = 'Dell Products';
                leadRecord.LeadSource = 'Email';
                leadRecord.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
                leadRecord.FBE_Lead_Type__c ='Inbound';
                if(i==0){
                    leadRecord.FBE_IDS_Dell_Main_State__c = 'Texas';
                }else if(i==1){
                    leadRecord.FBE_IDS_Dell_Main_State__c = 'TX';
                }else if(i==2){
                    leadRecord.FBE_IDS_Dell_Main_State__c = 'Texus';
                }
                insLeadList.add(leadRecord);
            }
            insert insLeadList;
            test.stopTest();
        }
    } 
}