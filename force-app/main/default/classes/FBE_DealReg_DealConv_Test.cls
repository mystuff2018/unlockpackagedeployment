@isTest
public class FBE_DealReg_DealConv_Test {
    static TestMethod void FBE_DealReg_DealConv_Test_EMC(){
        List<Deal_Registration__c> Dr = FBE_UtilityFactory_Test.createDeal(20);
        insert Dr;
        List<Deal_Registration__c> Dreg = new List<Deal_Registration__c> ();
        for(Deal_Registration__c d: Dr){
          d.FBE_Deal_Product_Classification__c = 'EMC Products';
            d.FBE_Approval_Rejection_Reason__c = 'Test';
            d.FBE_Extension_Request_Status__c = 'Approved';
            d.FBE_Approver_Email_Address__c = 'test@test.com';
            d.FBE_Extension_Request_Reason__c = 'Test';
            Dreg.add(d);
            }
        Test.startTest();
        update Dreg;
                                    
                try{
                    FBE_DealReg_DealConv DrDc = new FBE_DealReg_DealConv ();
                    Database.executeBatch(DrDc,20);
                    }
                catch(Exception e){
                    system.debug(e.getMessage());
                }          
                Test.stopTest();
    }
    static TestMethod void FBE_DealReg_DealConv_Test_Dell(){
       List < Deal_Registration__c > DealList = new List < Deal_Registration__c > ();
        for (Integer i = 0; i < 5; i++) {
            Deal_Registration__c DealRecord = new Deal_Registration__c();
            DealRecord.Name = 'Test Deal';           
            DealRecord.FBE_Deal_Product_Classification__c = 'Dell Products';
            DealRecord.FBE_Approval_Rejection_Reason__c = 'Test';
            DealRecord.FBE_Extension_Request_Status__c = 'Approved';
            DealRecord.FBE_Approver_Email_Address__c = 'test@test.com';
            DealRecord.FBE_Extension_Request_Reason__c = 'Test';
           // DealRecord.FBE_Price_Book_Id__c = '01sr00000004tlYAAQ';
            DealRecord.FBE_Customer__c = '65000909';
            DealRecord.FBE_Deal_Reg_Partner_Direct__c = '65000909'+i;
            DealRecord.FBE_Solution_Domain__c = 'Business Solutions';
            DealList.add(DealRecord);
        }
        Test.startTest();
        insert DealList;
        
                            
                try{
                    FBE_DealReg_DealConv DrDc = new FBE_DealReg_DealConv ();
                    Database.executeBatch(DrDc,20);
                    }
                catch(Exception e){
                    system.debug(e.getMessage());
                }          
                Test.stopTest();
    }
    
}