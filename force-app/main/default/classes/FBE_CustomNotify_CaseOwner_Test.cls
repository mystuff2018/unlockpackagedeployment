/**************
*@ Class Name                                                    : FBE_CustomNotify_CaseOwner_Test
*@ Description                                                   : Test Class for FBE_CustomNotify_CaseOwner
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 05-25-2021 [Siva Kumar Valluru]
*@ Modification Log                                              : 
***************/  
@isTest
public class FBE_CustomNotify_CaseOwner_Test {
    @isTest 
    public static void CustomNotification_CaseOwner(){
        
        List<User> usr = FBE_UtilityFactory_Test.createUser('System Administrator', 1, 'sys' ,null );       
        List<User> ProposalUser = FBE_UtilityFactory_Test.createUser('Federal Core Sales Group', 2, 'Pmg' ,null);       
        User u = FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(u){
            
            Account Acc = new Account(Name='Test Account',FBE_Account_Class__c='Direct',FBE_Status__c='Active');
            insert Acc;
            system.debug('TestSetup-Acc===> ' +Acc); 
         
          ID CaseFBERecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FBE Support Request').getRecordTypeId(); 
          List<case> lstcases = new List<case>(); 
           
              
          for(integer i=0; i <2 ; i++){
              Case c = new Case();
              c.RecordTypeId = CaseFBERecId;
              lstcases.add(c);
          }
          
          Insert lstcases;
           
           ID TaskFPSRecId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('FPS Task Request').getRecordTypeId(); 
            List<Task> pTskList = new List<Task>();
            Task pTsk1 = new Task();
            pTsk1.RecordTypeId = TaskFPSRecId;
            pTsk1.FBE_End_Date_del__c = System.Today();
            pTsk1.Description = 'TestTask1';
            pTsk1.Status = 'Draft';
            pTsk1.OwnerId = usr[0].Id;
            pTsk1.Type = 'Proposal';
            pTsk1.ActivityDate = System.Today();
            pTsk1.whatId = lstcases[0].Id;
            pTsk1.fbe_assigned_To__c = usr[0].Id;  
            pTskList.add(pTsk1);
            Insert pTskList;
            
            map<id,Task> oldmap = new map<id,task>();
            oldmap.put(pTskList[0].id,pTskList[0]);
            pTskList[0].whatId = lstcases[1].Id;
            update pTskList;
          
           Test.startTest();
            FBE_CustomNotify_CaseOwner.InsertCaseId(pTskList);
            FBE_CustomNotify_CaseOwner.UpdateCaseId(pTskList,oldmap);
           Test.stopTest();
            
          
        }
    }       
   
}