/**************
*@ Class Name                                                    : FBE_Test_FBEWorkloadSelectCtrl 
*@ Description                                                   : This Test class is written to cover various scenarios in the class FBEWorkloadSelectCtrl
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 12 - 03 - 2019
*@ Modification Log                                             : 
****************/
@isTest(seeAllData = false)
public class FBE_Test_FBEWorkloadSelectCtrl {
    
    static TestMethod void testOptyOwnerAssignment(){
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<User> lUserTeam = FBE_Test_Utility.createUser('System Administrator', 3, 'ab');
        
        system.runAs(lUser[0]){
            Test.startTest();
            List<Id> wIds = new List<Id>();
            List<Account> lAcc = FBE_Test_Utility.createAccount(1);
            insert lAcc;
            List<FBE_Workloads__c> lw = FBE_Test_Utility.createWorkload(3,lAcc[0].Id);
            insert lw;
            List<Opportunity> o = FBE_Test_Utility.createOpportunity(1,lAcc[0].Id);
            insert o;
            try{
               // OppWorkloadWrapper oppWrapper = new OppWorkloadWrapper();
                FBEWorkloadSelectCtrl.OppWorkloadWrapper wrkldList = FBEWorkloadSelectCtrl.fetchWorkload(o[0].Id);
                system.assertNotEquals(null, wrkldList.workloadList[0].id,'Null check');
                
                for(Integer j=0;j<wrkldList.workloadList.size();j++){
                    wIds.add(wrkldList.workloadList[j].Id);
                }
                
                FBEWorkloadSelectCtrl.AddToOpportunity(o[0].Id, wIds) ;
                FBEWorkloadSelectCtrl.OppWorkloadWrapper wrkldList1 = FBEWorkloadSelectCtrl.fetchWorkload(o[0].Id);
                //system.assertEquals(null, wrkldList1[0].Id);
                FBEWorkloadSelectCtrl.AddToOpportunity('', wIds) ;
                FBEWorkloadSelectCtrl.AddToOpportunity('abc', wIds) ;
                
            }
            catch(Exception e){
                system.debug(e.getMessage());
            } 
            Test.stopTest();
        }
    }
}