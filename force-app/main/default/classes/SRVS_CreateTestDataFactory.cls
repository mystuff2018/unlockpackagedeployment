/**
 *    @author R.Hari Krishna
 *    @date   17th Jan 18
 *    @description  Class for creating test data                            
 *     
 *     Modification Log:
 *------------------------------------------------------------------------------------
 *       Developer             Date                Description
 *------------------------------------------------------------------------------------
 *       R.Hari Krishna       17th Jan 18         Original Version
         Brundha              06/22/2019          FY200802
	[Deloitte] - Abhishek K	  07/15/2020		  Added EmployeeNumber for createUser
 */
 @isTest
 public class SRVS_CreateTestDataFactory {
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Role record
// *  @params          : N/A
// *  @returns         : User Role
// */
    // public static UserRole createRole(){
        // UserRole RolUser = new UserRole(Name='Test Role');
        // return RolUser;
    // }
    
 /*
 *  @author          : R.Hari Krishna
 *  @description     : Method to create Single User record
 *  @params          : Standard Profile Name
 *  @returns         : User record
 */
    
     public static User createUser(String stdProfileName, string federalIdentifier) {
        
         Profile objProfile = [SELECT Id FROM Profile WHERE Name=:stdProfileName ];                 
         String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
         User objUser;
         system.debug('objProfile ' + objProfile.Id);
         if(String.isNotBlank(objProfile.Id)){
             //string federationId = String.valueOf(system.now().minuteGMT()) + String.valueOf(System.now().yearGMT()) + String.valueOf(System.now().hourGMT());
             objUser  = new User(Alias = 'auser',FirstName='Test', Email='adminuser@dell.com',IsActive=True,
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 FederationIdentifier=federalIdentifier,Dell_NTUserID__c='TEST_T',Service_User_Type__c='Service Account',
                                 External_ID__c=federalIdentifier,Organization__c='Dell',File_Source__c='AMS - System Admin',
                                 LocaleSidKey='en_US', ProfileId = objProfile.id,
                                 TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName, OSP__c='Yes',
                                 //Added due to DFN Validation Rule on User > Employee Number field.
                                 EmployeeNumber='1234'+federalIdentifier
                                 /*,
// External_ID__c = String.valueOf(DateTime.now().getTime())*/);
            
         }
         return objUser;
     }
    
    
 /*
 *  @author          : R.Hari Krishna
 *  @description     : Method to create Single User record
 *  @params          : Standard Profile Name
 *  @returns         : User record
 */
    
     public static User createUser(String stdProfileName) {
        
         Profile objProfile = [SELECT Id FROM Profile WHERE Name=:stdProfileName ];                 
         String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
         User objUser;
         if(String.isNotBlank(objProfile.Id)){
             //string federationId = String.valueOf(system.now().minuteGMT()) + String.valueOf(System.now().yearGMT()) + String.valueOf(System.now().hourGMT());
             objUser  = new User(Alias = 'auser',FirstName='Test', Email='adminuser@dell.com',IsActive=True,
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 FederationIdentifier='1234569',Dell_NTUserID__c='TEST_T',Service_User_Type__c='Service Account',
                                 External_ID__c='1234569',Organization__c='Dell',File_Source__c='AMS - System Admin',
                                 LocaleSidKey='en_US', ProfileId = objProfile.id,
                                 TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName, OSP__c='Yes',
                                 //Added due to DFN Validation Rule on User > Employee Number field.
                                 EmployeeNumber='12345'
                                 /*,
 External_ID__c = String.valueOf(DateTime.now().getTime())*/);
            
         } 
         return objUser;
     }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Single Group record
// *  @params          : N/A
// *  @returns         : Group record
// */
    // public static Group createGroup(){        
        // Group grp = new Group(Name = 'Test Group',DeveloperName = 'Test_Group',Type = 'Queue');
        // return grp;
    // }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Single GroupMember record
// *  @params          : GroupId, Owner Id
// *  @returns         : GroupMember record
// */
    // public static GroupMember createMember(Id groupId,Id ownerId)
    // {
        // GroupMember grpMember = new  GroupMember(GroupId = groupId,UserOrGroupId = ownerId); 
        // return grpMember;
    // }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to Create Single ExceptionLogger Record
// *  @Param           : N/A
// *  @returns         : ExceptionLogger Record
// */
    // public static ExceptionLogger__c createSingleExceptionLoggerRecord(){
        // ExceptionLogger__c excObj = new ExceptionLogger__c();
        // excObj.Description__c = 'TestError';
        // excObj.Object_Name__c = 'Test';
        // excObj.Apex_Class__c = 'ClassName';
        // excObj.Exception_Dated__c = system.now();
        // excObj.Error_Record_SF_Id__c = 'Test';
        // excObj.User_Name__c = 'Testuser';
        // excObj.Method_Name__c = 'Testmethod';
        // excObj.Module__c = 'Testmodule';
        // return excObj;
    // }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to Create Multiple ExceptionLogger Records
// *  @Param           : numberOfRecrds
// *  @returns         : ExceptionLogger Records
// */
    public static List<ExceptionLogger__c> createMultipleExceptionLoggerRecords(Integer numberOfRecrds){
       List<ExceptionLogger__c> lstTestExcptLoggers = new List<ExceptionLogger__c>();
        for(Integer count=0;count<numberOfRecrds;count++){
            ExceptionLogger__c excObj = new ExceptionLogger__c();
            excObj.Description__c = 'TestError' + count;
            excObj.Object_Name__c = 'Test' + count;
            excObj.Apex_Class__c = 'ClassName' + count;
            excObj.Exception_Dated__c = system.now();
            excObj.Error_Record_SF_Id__c = 'Test' + count;
            excObj.User_Name__c = 'Testuser' + count;
            excObj.Method_Name__c = 'Testmethod' + count;
            excObj.Module__c = 'Testmodule' + count;
            lstTestExcptLoggers.add(excObj);
        }
        return lstTestExcptLoggers;
     }
    
 /*
 *  @author          : R.Hari Krishna
 *  @description     : Method to Create Single Account Record
 *  @Param           : N/A
 *  @returns         : Account Record
 */
     public static Account createSingleAccountRecord(){
         String uniqueAccName = 'accName' + DateTime.now().getTime();
         Account testAccount = new Account(
             Name = uniqueAccName,            
             Type = 'Prospect'
             //PM_Name__c = 'PM_Name__c',
             //PM_Email__c = 'PM_Email__c@test.com'
         );
         return testAccount;
     }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to Create Multiple Account Records
// *  @Param           : Number of Account Records
// *  @returns         : Account Records
// */
    // public static List<Account> createMultipleAccountRecords(Integer numberOfAccRecrds){
        // String uniqueConName = 'accName' + DateTime.now().getTime();
        // List<Account> lstTestAccounts = new List<Account>();
        // for(Integer i=0;i<numberOfAccRecrds;i++){
            // Account testAccount = new Account(
                // Name = uniqueConName+i,            
                // Type = 'Prospect'
                // //PM_Name__c = 'PM_Name__c',
                // //PM_Email__c = 'PM_Email__c@test.com'
            // );
            // lstTestAccounts.add(testAccount);
        // }
        // return lstTestAccounts;
    // } 
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Single Task record
// *  @params          : ContactId,Case Id, Past due and Status
// *  @returns         : Task record
// */
    // public static Task createTaskRecord(Id conId, Id caseId, Integer pastDue, String sStatus){
        // Date currTaskTime = Date.today();
        // Task testTaskPastDue90 = new Task (
            // Subject = 'Test Task Past Due date by 90',
            // WhoId = conId,
            // WhatId = caseId,
            // Status = sStatus,
            // ActivityDate = currTaskTime.addDays(pastDue)
        // );
        // return testTaskPastDue90;
    // }
    // /*
// *  @author          : Srikanth Parvathareddy
// *  @description     : Method to create Multiple Task records
// *  @params          : ContactId,Case Id,Status,Number of records
// *  @returns         : Task records
// */  
    // public static List<Task> createMultipleTaskRecords(Id conId, Id caseId,String sStatus,Integer numofrecords){
        // List<Task> lstoftasks = new List<Task>();
        // for(Integer i=0;i<numofrecords;i++)
        // {
            // Task testTask= new Task (
                // Subject = 'Test Task' + i,
                // WhoId = conId,
                // WhatId = caseId,
                // Status = sStatus,
                // ActivityDate =Date.today());
            // lstoftasks.add(testTask);
            
        // }
        // return lstoftasks;
    // }
    // /*
// *  @author          : Srikanth Parvathareddy
// *  @description     : Method to create Livechatvisitor records
// *  @params          : None
// *  @returns         : LiveChatVisitor record
// */ 
    // public static LiveChatVisitor createLiveChatVisitor(){
        // LiveChatVisitor visitor=new LiveChatVisitor();
        // return visitor;
    // }
    
    // /*
// *  @author          : Srikanth Parvathareddy
// *  @description     : Method to create LiveChatTranscript records
// *  @params          : LiveChatVisitor and Asset
// *  @returns         : LiveChatTranscript record
// */ 
    // public static LiveChatTranscript createLiveChatTranscript(LiveChatVisitor v,Asset ast){
        // LiveChatTranscript testlivechat=new LiveChatTranscript(Asset__c=ast.Id,LiveChatVisitorId=v.Id);
        // return testLiveChat;
    // }
    
    
    
    
    // /*
// *  @author          : Manisha
// *  @description     : Method to create AgentWork records
// *  @params          : None
// *  @returns         : AgentWork record
// */ 
    
    // public static AgentWork createAgentWork(){
        // AgentWork testagentwork = new AgentWork();
        // return testagentwork;
    // }
    
    
    
    
    
 /*
 *  @author          : R.Hari Krishna
 *  @description     : Method to create Single Contact record
 *  @params          : Account Object
 *  @returns         : Contact record
 */
     public static Contact createContactRecord(Account acc){
         Contact testContact = new Contact (FirstName = 'firstName', LastName = 'lastName', accountId = acc.id, email='abc@dell.com', country_code__c= 'USA & Canada (1)', Primary_Phone__c='1234567890', Phone='1234567890');
         return testContact;
     }
    
 /*
 *  @author          : R.Hari Krishna
 *  @description     : Method to create Multiple Contact records
 *  @params          : Account Object,NumOfContRecrds
 *  @returns         : Contact records
 */
     public static List<Contact> createMultipleContactRecords(Account acc,Integer NumOfContRecrds){
         List<Contact> lstTestContacts = new List<Contact>();
         for(Integer i=0;i<NumOfContRecrds;i++) {
             Contact testContact = new Contact (FirstName = 'firstName', LastName = 'lastName'+i, Email = 'abc@dell.com',country_code__c= 'USA & Canada (1)',Primary_Phone__c='1234567890', accountId = acc.id,Phone='1234567890');
             lstTestContacts.add(testContact);
         }
         return lstTestContacts;
     }
    
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Single EmailTemplate record
// *  @params          : N/A
// *  @returns         : EmailTemplate
// */
    // public static EmailTemplate createStdEmailTemplate(){        
        // EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = Userinfo.getUserId(), TemplateType= 'Text', Name = 'test');
        // return e;
    // }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Single Asset record
// *  @params          : Account Id
// *  @returns         : Asset Record
// */  
    // public static Asset createSingleAsset(Id AccountId){
        // Asset testAsset =  new Asset(Name = 'Sample Asset',AccountId = AccountId,InstallDate = System.today());
        // return testAsset; 
    // }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Multiple Asset records
// *  @params          : Account Id,NumOfAssetRecrds
// *  @returns         : Asset Records
// */  
    // public static List<Asset> createMultipleAssets(Id AccountId,Integer NumOfAssetRecrds){
        // List<Asset> lstTestAssets = new List<Asset>();
        // for(Integer i=0;i<NumOfAssetRecrds;i++) {
            // Asset testAsset =  new Asset(Name = 'Sample Asset',AccountId = AccountId,InstallDate = System.today());
            // lstTestAssets.add(testAsset);
        // }
        // return lstTestAssets;         
    // }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Single Case record
// *  @params          : AssetId,Account Id, Contact Id
// *  @returns         : Case Record
// */    
    // public static Case createSingleCase(Id AssetId,Id AccId,Id ContId){        
        // Case testCase =  new Case(AssetId = AssetId,
                                  // AccountId= AccId,
                                  // ContactId= ContId,
                                  // Origin = 'Chat',
                                  // Status = 'In Progress',
                                  // Priority = 'Medium');
        // return testCase; 
    // }
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Multiple Case records
// *  @params          : AssetId,Account Id, Contact Id,NumOfCaseRecrds
// *  @returns         : Case Records
// */    
    // public static List<Case> createMultipleCases(Id AssetId,Id AccId,Id ContId,Integer NumOfCaseRecrds){        
        // List<Case> lstTestCases = new List<Case>();
        // for(Integer i=0;i<NumOfCaseRecrds;i++) {
            // Case testCase =  new Case(AssetId = AssetId,
                                      // AccountId= AccId,
                                      // ContactId= ContId,
                                      // Origin = 'Chat',
                                      // Status = 'In Progress',
                                      // Priority = 'Medium');
            // lstTestCases.add(testCase);
        // }
        // return lstTestCases; 
    // }
    
    
    // /*
// *  @author          : R.Hari Krishna
// *  @description     : Method to create Single Solution record
// *  @params          : N/A
// *  @returns         : Solution Record
// */  
    // public static Solution createSolution(){
        // Solution sol =  new Solution(SolutionName = 'Sample Solution');
        // return sol; 
    // }   
    
    // /*
// *  @author          : Surya Subramanian
// *  @description     : Method to create Contentversion
// *  @params          : N/A
// *  @returns         : Contentversion Record
// */  
    // public static Contentversion createContentversion(String Path){
        
        // Contentversion testContentvrs = new Contentversion();
        // testContentvrs.Title ='ABC';
        // testContentvrs.PathOnClient= Path;
        // testContentvrs.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        // return testContentvrs;
    // }
    // /*
// *  @author          : Roselin Hephzibah
// *  @description     : Method to create Attachment
// *  @params          : File Name, Parent Id
// *  @returns         : Attachment Record
// */  
    // public static Attachment createAttachment(String fileName, Id pId){
        
        // Attachment testAttachment = new Attachment();
        // testAttachment.Name = fileName;
        // Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        // testAttachment.body = bodyBlob;
        // testAttachment.parentId = pId;
        // return testAttachment;
    // }
    // /*
// *  @author          : Roselin Hephzibah
// *  @description     : Method to create EmailMessage
// *  @params          : N/A
// *  @returns         : EmailMessage Record
// */  
    // public static EmailMessage createEmailMessage(ID caseId){
        // EmailMessage testEmail = new EmailMessage(FromAddress='FromSfdc@test.com', 
                                                  // ToAddress='ToUser@dell.com', 
                                                  // Subject='Sample Subject', 
                                                  // TextBody='Creation of email message',
                                                  // relatedtoId = caseId);
        // return testEmail;
    // }
    // /*
// *  @author          : Roselin Hephzibah
// *  @description     : Method to create Custom Setting Liveagent_Support__c
// *  @params          : N/A
// *  @returns         : Liveagent_Support__c Record
// */  /*
// public static Liveagent_Support__c createLiveAgentSupport(){
// Liveagent_Support__c objSupport = new Liveagent_Support__c(Name='eSupport', deployment_id__c= 'deploymentId');
// return objSupport;
// }
// */  
    // /*
// *  @author          : Roselin Hephzibah
// *  @description     : Method to create Product2 record
// *  @params          : N/A
// *  @returns         : Product2 Record
// */  
    // public static Product2 createProduct2(){
        // Product2 prod = new Product2(Name='AH129', ProductCode= 'AH129', LOB_Code__c = 'AH129', External_Id__c = 'AH129', LOB_Description__c = 'AH129', Description = 'AH129 TEST Product');
        // return prod;
    // }
    
    // /*
// *  @description     : Method to create work order Record
// *  @params          : AssetId,  AccountId, ContactId, caseId
// *  @returns         : WorkOrder Record
// */  
    // public static WorkOrder createSingleWorkOrder(Id AssetId,Id AccId,Id ContId, Id csId){        
        // WorkOrder testWorkOrder =  new WorkOrder(AssetId = AssetId,
                                                 // AccountId= AccId,
                                                 // ContactId= ContId,
                                                 // caseId = csId, City='Round Rock',
                                                 // Region__c='1',PostalCode='786664',AdditionalContactId__c=ContId,CountryCode='US',
                                                 // subject='testing Work Order', stateCode='TX', Street= 'Ring Road', Dispatch_Country__c='US and EMEA');
        // return testWorkOrder; 
    // }
   
     
     // /*
     // * *  @author          : Shivank Jaiveer Singh
// *  @description     : Method to create Multivalue Routing Rule Record
// *  @returns         : Multivalue Routing Rule Record
// */      

    // public static MultiValue_Routing_Rules__c createMultivalueRoutingRuleRecord2(){
         // MultiValue_Routing_Rules__c mrr = new MultiValue_Routing_Rules__c();
       // mrr.Language__c ='EN;FR';
        // mrr.Region__c = '1';
        // mrr.Country__c = 'Indonesia';
        // mrr.Product_LOB__c = '3WS';
        // mrr.Control_Support_Strategy__c = 'Non-BRICE';
        // mrr.Product_Name__c = ',Avamar,';
        // mrr.Product_Family__c = ',Avamar,Dlm800,Test2,';
        // mrr.Premium_Type__c = 'PP';
        // mrr.Issue_Type__c = 'Licensing';
            // return mrr;
    // } 
    // /*
     // * *  @author          : Shivank Jaiveer Singh
// *  @description     : Method to create Multivalue Routing Rule Record
// *  @returns         : Multivalue Routing Rule Record
// */      

    // public static MultiValue_Routing_Rules__c createMultivalueRoutingRuleRecord(){
         // MultiValue_Routing_Rules__c mrr = new MultiValue_Routing_Rules__c();
        // mrr.Language__c ='EN;FR';
        // mrr.Region__c = '1';
        // mrr.Country__c = 'Indonesia';
        // mrr.Product_LOB__c = '3WS';
        // mrr.Control_Support_Strategy__c = 'Non-BRICE';
        // mrr.Product_Name__c = '';
        // mrr.Product_Family__c = '';
        // mrr.Premium_Type__c = 'PP';
        // mrr.Issue_Type__c = 'Licensing';
            // return mrr;
    // }
   
   
       
     // /*
     // *  @author      : Shivank Jaiveer Singh
// *  @description     : Method to create Source Onboarding Record for Multivalue
// *  @returns         : Source Onboarding Record
// */   
    
    // public static Source_Onboarding__c createSourceOnboarding(){
        // Source_Onboarding__c source = new Source_Onboarding__c();
        // source.Source__c = 'OIM';
        // source.Onboarded__c = True;
        // return source;
    // }
    // /*
     // * 
     // *   @author      : Shivank Jaiveer Singh
// *  @description     : Method to create Routing Rule Record for Multivalue
// *  @returns         : Routing Rule Record
// */   
    
    // public static Routing_Rules__c createProductOnboarding(){
        // Routing_Rules__c rr = new Routing_Rules__c();
        // rr.Onboarded_Flag__c = True;
        // rr.Product_Name__c = 'Avamar';
        // rr.RecordTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('HES Product Onboarding').getRecordTypeId();
        // rr.Source__c = 'DialHome';
        // return rr;
    // }
    
  // /*
  // *  @author      : Shivank Jaiveer Singh
// *  @description     : Method to create Priority Mapping Record for Multivalue
// *  @returns         : Priority Mapping Record
// */  
    // public static Priority_Mapping__c createSinglePriorityMappingRecordForMultivalueRouting(){        
        // Priority_Mapping__c priorityMapping = new Priority_Mapping__c();
        // priorityMapping.Name = 'Test Multivalue';
        // priorityMapping.Priority__c = 1;
        // priorityMapping.Source__c = 'DialHome';
        // priorityMapping.RecordTypeId = Schema.SObjectType.Priority_Mapping__c.getRecordTypeInfosByName().get('MultiValue Priority').getRecordTypeId();
        // priorityMapping.Product_Name__c =  true;
        // priorityMapping.Active__c =  true;
        // priorityMapping.Control_Support_Strategy__c = true;
        // priorityMapping.Country__c = true;
        // return priorityMapping; 
    // }
    // /*
    // *  @author      : Shivank Jaiveer Singh
// *  @description     : Method to create Priority Mapping Record
// *  @returns         : Priority Mapping Record
// */  
    // public static Priority_Mapping__c createSinglePriorityMappingRecord(){        
        // Priority_Mapping__c priorityMapping = new Priority_Mapping__c();
        // priorityMapping.Name = 'Chat Main';
        // priorityMapping.RecordTypeId = Schema.SObjectType.Priority_Mapping__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
        // priorityMapping.Active__c =  true;
        // priorityMapping.BUID__c = true;
        // priorityMapping.Region__c = true;
        // return priorityMapping; 
    // }
    
       // /*
 // *  *  @author      : Shivank Jaiveer Singh
// *  @description     : Method to create Multivalue Routing Rule Record
// *  @returns         : Multivalue Routing Rule Record
// */   
    
       // public static MultiValue_Routing_Rules__c createSingleMultiValueRoutingRules(){ 
         // MultiValue_Routing_Rules__c MultiroutingRule = new MultiValue_Routing_Rules__c ();
        // LiveChatButton lct = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='EMEA_TS_CLI_CHAT_EN_CORE'];
        // MultiroutingRule.Source__c='DialHome';
        // MultiroutingRule.Channel__c='Chat';
        // MultiroutingRule.Product_Name__c = ',Avamar,';
        // MultiroutingRule.Queue_Name__c = 'EMEA_TS_CLI_CHAT_EN_CORE';
        // MultiroutingRule.Chat_Button_Id__c = lct.Id;
        // MultiroutingRule.Country__c = 'Indonesia';
        // MultiroutingRule.Control_Support_Strategy__c='Non-BRICE';
        // return MultiroutingRule; 
    // }
    
    // /*
    // *  @author      : Shivank Jaiveer Singh
// *  @description     : Method to create Routing Rule Record
// *  @returns         : Routing Rule Record
// */   
    // public static Routing_Rules__c createSingleRoutingRuleRecord(){   
        // LiveChatButton lct = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='EMEA_TS_CLI_CHAT_EN_CORE'];
        // LiveChatButton lctResume = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='EMEA_TS_CLI_CHAT_EN_CORE_RESUME'];  
        // Routing_Rules__c routingRule = new Routing_Rules__c ();
        // routingRule.Active__c=true;
        // routingRule.BUID__c = '11';
        // routingRule.Country__c = 'USA';
        // routingRule.Queue_Name__c = 'EMEA_TS_CLI_CHAT_EN_CORE';
        // routingRule.Region__c = '1';
        // //routingRule.Rule_Name__c = priorityMapping.Id;
        // routingRule.Source__c = 'OIM';
        // routingRule.Chat_Button_Id__c = lct.Id;
        // routingRule.Resume_Chat_Button_Id__c = lctResume.Id;
        // routingRule.OOH_Queue_Name__c = null;
        // routingRule.RecordTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId();  
        
        // return routingRule; 
    // }

        // /*
         // *  @author          : Venkatesh Raydurg
// *  @description     : STORY 6576779 Added test method to Cover Skill Based Routing changes-Method to Create Skill Based Rules with Sequence H>M>L
// *  @params          : N/A
// *  @returns         : Routing Rule record for Skill Based Routing
// */  
    // public static Routing_Rules__c createSingleSkillBasedRoutingHMLRuleRecord(){   
        // /*LiveChatButton lct = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='HDD_1_USA_EN_4SV'];
        // LiveChatButton HighSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='HDD_1_USA_EN_4SV_HIGH'];
        // LiveChatButton MediumSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='HDD_1_USA_EN_4SV_MEDIUM'];
        // LiveChatButton LowSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='HDD_1_USA_EN_4SV_LOW'];*/
        
        // Routing_Rules__c routingRule = new Routing_Rules__c ();
        // routingRule.Active__c=true;
        // routingRule.BUID__c = '11';
        // routingRule.Country__c = 'USA';
        // routingRule.Queue_Name__c = 'US_24X7';
        // routingRule.Region__c = '1';
        // routingRule.Rule_Type__c ='Chat';
        // routingRule.Source__c = 'OIM';
        // routingRule.Line_of_Business__c ='4SV';
        // RoutingRule.Premier_Type__c = 'PROSUPPORT';
        // routingRule.Chat_Button_Id__c = '572M00000008PIjIAR';
        // routingRule.OOH_Queue_Name__c = null;
        // routingRule.Issue_Type__c = 'VIDEO_DISPLAY';
        // routingRule.High_Skill_Button_ID__c = '572M00000008PK4IAR';
        // routingRule.Medium_Skill_Button_ID__c = '572M00000008PK4IAS';
        // routingRule.Low_Skill_Button_ID__c = '572M00000008PK4IAT';
        // routingRule.Skill_Sequence__c = 'H>M>L';
        // routingRule.Routing_Model__c ='Skill Based';
        // routingRule.Country_Code__c = 'US';
        // routingRule.Language__c = 'EN';
        // system.debug('SkillroutingModel' +routingRule.Routing_Model__c);
        // system.debug('Country_Code__c' +routingRule.Country_Code__c);
        // routingRule.RecordTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('Skill Based').getRecordTypeId();  
        
        // return routingRule; 
    // }
    // /*
         // *  @author          : Venkatesh Raydurg
// *  @description     : STORY 6576779 Added test method to Cover Skill Based Routing changes-Method to Create Skill Based Rules with Sequence H>L>M
// *  @params          : N/A
// *  @returns         : Routing Rule record for Skill Based Routing
// */  
    // public static Routing_Rules__c createSingleSkillBasedRoutingHLMRuleRecord(){   
        // /*LiveChatButton lct = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='FAN_1_USA_EN_4SV'];
        // LiveChatButton HighSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='FAN_1_USA_EN_4SV_HIGH'];
        // LiveChatButton MediumSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='FAN_1_USA_EN_4SV_MEDIUM'];
        // LiveChatButton LowSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='FAN_1_USA_EN_4SV_LOW'];*/
        
        // Routing_Rules__c routingRule = new Routing_Rules__c ();
        // routingRule.Active__c=true;
        // routingRule.BUID__c = '11';
        // routingRule.Country__c = 'USA';
        // routingRule.Queue_Name__c = 'US_24X7';
        // routingRule.Region__c = '1';
        // routingRule.Rule_Type__c ='Chat';
        // routingRule.Source__c = 'OIM';
        // routingRule.Line_of_Business__c ='4SV';
        // RoutingRule.Premier_Type__c = 'PROSUPPORT';
        // routingRule.Chat_Button_Id__c = '572P00000008PIjIAR';
        // routingRule.OOH_Queue_Name__c = null;
        // routingRule.Issue_Type__c = 'STATUS_UPDATE';
        // routingRule.High_Skill_Button_ID__c ='572P00000008PK4IAR';
        // routingRule.Medium_Skill_Button_ID__c = '572P00000008PK4IAS';
        // routingRule.Low_Skill_Button_ID__c = '572P00000008PK4IAT';
        // routingRule.Skill_Sequence__c = 'H>L>M';
        // routingRule.Routing_Model__c ='Skill Based';
        // routingRule.Country_Code__c = 'US';
        // routingRule.Language__c = 'EN';
        // system.debug('SkillroutingModel' +routingRule.Routing_Model__c);
        // system.debug('Country_Code__c' +routingRule.Country_Code__c);
        // routingRule.RecordTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('Skill Based').getRecordTypeId();  
        
        // return routingRule; 
    // }
        // /*
         // *  @author          : Venkatesh Raydurg
// *  @description     : STORY 6576779 Added test method to Cover Skill Based Routing changes-Method to Create Skill Based Rules with Sequence M>H>L
// *  @params          : N/A
// *  @returns         : Routing Rule record for Skill Based Routing
// */  
    // public static Routing_Rules__c createSingleSkillBasedRoutingMHLRuleRecord(){   
        // /*LiveChatButton lct = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='MEMORY_1_USA_EN_4SV'];
        // LiveChatButton HighSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='MEMORY_1_USA_EN_4SV_HIGH'];
        // LiveChatButton MediumSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='MEMORY_1_USA_EN_4SV_MEDIUM'];
        // LiveChatButton LowSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='MEMORY_1_USA_EN_4SV_LOW'];*/
        
        // Routing_Rules__c routingRule = new Routing_Rules__c ();
        // routingRule.Active__c=true;
        // routingRule.BUID__c = '11';
        // routingRule.Country__c = 'USA';
        // routingRule.Queue_Name__c = 'US_24X7';
        // routingRule.Region__c = '1';
        // routingRule.Rule_Type__c ='Chat';
        // routingRule.Source__c = 'OIM';
        // routingRule.Line_of_Business__c ='4SV';
        // RoutingRule.Premier_Type__c = 'PROSUPPORT';
        // routingRule.Chat_Button_Id__c = '572Q00000008PIjIAR';
        // routingRule.OOH_Queue_Name__c = null;
        // routingRule.Issue_Type__c = 'OS_BSOD';
        // routingRule.High_Skill_Button_ID__c ='572Q00000008PK4IAR';
        // routingRule.Medium_Skill_Button_ID__c = '572Q00000008PK4IAS';
        // routingRule.Low_Skill_Button_ID__c = '572Q00000008PK4IAT';
        // routingRule.Skill_Sequence__c = 'M>H>L';
        // routingRule.Routing_Model__c ='Skill Based';
        // routingRule.Country_Code__c = 'US';
        // routingRule.Language__c = 'EN';
        // system.debug('SkillroutingModel' +routingRule.Routing_Model__c);
        // system.debug('Country_Code__c' +routingRule.Country_Code__c);
        // routingRule.RecordTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('Skill Based').getRecordTypeId();  
        
        // return routingRule; 
    // }
            // /*
         // *  @author          : Venkatesh Raydurg
// *  @description     : STORY 6576779 Added test method to Cover Skill Based Routing changes-Method to Create Skill Based Rules with Sequence M>L>H
// *  @params          : N/A
// *  @returns         : Routing Rule record for Skill Based Routing
// */  
    // public static Routing_Rules__c createSingleSkillBasedRoutingMLHRuleRecord(){   
       // /* LiveChatButton lct = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='PSU_1_USA_EN_4SV'];
        // LiveChatButton HighSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='PSU_1_USA_EN_4SV_HIGH'];
        // LiveChatButton MediumSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='PSU_1_USA_EN_4SV_MEDIUM'];
        // LiveChatButton LowSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='PSU_1_USA_EN_4SV_LOW'];*/
        
        // Routing_Rules__c routingRule = new Routing_Rules__c ();
        // routingRule.Active__c=true;
        // routingRule.BUID__c = '11';
        // routingRule.Country__c = 'USA';
        // routingRule.Queue_Name__c = 'US_24X7';
        // routingRule.Region__c = '1';
        // routingRule.Rule_Type__c ='Chat';
        // routingRule.Source__c = 'OIM';
        // routingRule.Line_of_Business__c ='4SV';
        // RoutingRule.Premier_Type__c = 'PROSUPPORT';
        // routingRule.Chat_Button_Id__c = '572R00000008PIjIAR';
        // routingRule.OOH_Queue_Name__c = null;
        // routingRule.Issue_Type__c = 'THIRDPARTY_APP1';
        // routingRule.High_Skill_Button_ID__c ='572R00000008PK4IAR';
        // routingRule.Medium_Skill_Button_ID__c = '572R00000008PK4IAS';
        // routingRule.Low_Skill_Button_ID__c = '572R00000008PK4IAT';
        // routingRule.Skill_Sequence__c = 'M>L>H';
        // routingRule.Routing_Model__c ='Skill Based';
        // routingRule.Country_Code__c = 'US';
        // routingRule.Language__c = 'EN';
        // system.debug('SkillroutingModel' +routingRule.Routing_Model__c);
        // system.debug('Country_Code__c' +routingRule.Country_Code__c);
        // routingRule.RecordTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('Skill Based').getRecordTypeId();  
        
        // return routingRule; 
    // }
    // /*
         // *  @author          : Venkatesh Raydurg
// *  @description     : STORY 6576779 Added test method to Cover Skill Based Routing changes-Method to Create Skill Based Rules with Sequence L>M>H
// *  @params          : N/A
// *  @returns         : Routing Rule record for Skill Based Routing
// */  
    // public static Routing_Rules__c createSingleSkillBasedRoutingLMHRuleRecord(){   
       // /* LiveChatButton lct = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='NOBOOT_1_USA_EN_4SV'];
        // LiveChatButton HighSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='NOBOOT_1_USA_EN_4SV_HIGH'];
        // LiveChatButton MediumSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='NOBOOT_1_USA_EN_4SV_MEDIUM'];
        // LiveChatButton LowSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='NOBOOT_1_USA_EN_4SV_LOW'];*/
        
        // Routing_Rules__c routingRule = new Routing_Rules__c ();
        // routingRule.Active__c=true;
        // routingRule.BUID__c = '11';
        // routingRule.Country__c = 'USA';
        // routingRule.Queue_Name__c = 'US_24X7';
        // routingRule.Region__c = '1';
        // routingRule.Rule_Type__c ='Chat';
        // routingRule.Source__c = 'OIM';
        // routingRule.Line_of_Business__c ='4SV';
        // RoutingRule.Premier_Type__c = 'PROSUPPORT';
        // routingRule.Chat_Button_Id__c = '572S00000008PIjIAR';
        // routingRule.OOH_Queue_Name__c = null;
        // routingRule.Issue_Type__c = 'OTHER_ISSUES';
        // routingRule.High_Skill_Button_ID__c ='572S00000008PK4IAR';
        // routingRule.Medium_Skill_Button_ID__c = '572S00000008PK4IAS';
        // routingRule.Low_Skill_Button_ID__c = '572S00000008PK4IAT';
        // routingRule.Skill_Sequence__c = 'L>M>H';
        // routingRule.Routing_Model__c ='Skill Based';
        // routingRule.Country_Code__c = 'US';
        // routingRule.Language__c = 'EN';
        // system.debug('SkillroutingModel' +routingRule.Routing_Model__c);
        // system.debug('Country_Code__c' +routingRule.Country_Code__c);
        // routingRule.RecordTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('Skill Based').getRecordTypeId();  
        
        // return routingRule; 
    // }
    // /*  @author          : Venkatesh Raydurg
// *  @description     : STORY 6576779 Added test method to Cover Skill Based Routing changes-Method to Create Skill Based Rules with Sequence L>H>M
// *  @params          : N/A
// *  @returns         : Routing Rule record for Skill Based Routing
// */  
    // public static Routing_Rules__c createSingleSkillBasedRoutingLHMRuleRecord(){   
        // /*LiveChatButton lct = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='NOPOWER_1_USA_EN_4SV'];
        // LiveChatButton HighSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='NOPOWER_1_USA_EN_4SV_HIGH'];
        // LiveChatButton MediumSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='NOPOWER_1_USA_EN_4SV_MEDIUM'];
        // LiveChatButton LowSkillButton = [SELECT Id, DeveloperName FROM LiveChatButton where DeveloperName='NOPOWER_1_USA_EN_4SV_LOW'];*/
        
        // Routing_Rules__c routingRule = new Routing_Rules__c ();
        // routingRule.Active__c=true;
        // routingRule.BUID__c = '11';
        // routingRule.Country__c = 'USA';
        // routingRule.Queue_Name__c = 'US_24X7';
        // routingRule.Region__c = '1';
        // routingRule.Rule_Type__c ='Chat';
        // routingRule.Source__c = 'OIM';
        // routingRule.Line_of_Business__c ='4SV';
        // RoutingRule.Premier_Type__c = 'PROSUPPORT';
        // routingRule.Chat_Button_Id__c = '572T00000008PIjIAR';
        // routingRule.OOH_Queue_Name__c = null;
        // routingRule.Issue_Type__c = 'SYSTEM_HARDWARE'; 
        // routingRule.High_Skill_Button_ID__c ='572T00000008PK4IAR';
        // routingRule.Medium_Skill_Button_ID__c = '572T00000008PK4IAS';
        // routingRule.Low_Skill_Button_ID__c = '572T00000008PK4IAT';
        // routingRule.Skill_Sequence__c = 'L>H>M';
        // routingRule.Routing_Model__c ='Skill Based';
        // routingRule.Country_Code__c = 'US';
        // routingRule.Language__c = 'EN';
        // system.debug('SkillroutingModel' +routingRule.Routing_Model__c);
        // system.debug('Country_Code__c' +routingRule.Country_Code__c);
        // routingRule.RecordTypeId = Schema.SObjectType.Routing_Rules__c.getRecordTypeInfosByName().get('Skill Based').getRecordTypeId();  
        
        // return routingRule; 
    // }
    // /*
// *  @description     : Method to query custom metadata-MapQueueBH Record
// *  @returns         : MapQueueBH Record
// */  
    // public static MapQueueBH__mdt QuerySingleMapQueueBHRecord(string QueueName){        
        // MapQueueBH__mdt mq = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, ShiftTwo__c,Shift_Starting_Day__c, Business_Hours_Record_Name__c FROM MapQueueBH__mdt where DeveloperName=:QueueName LIMIT 1];
        
        // return mq; 
    // }
    
    // /*
// *  @description     : Method to create Holiday Record
// *  @returns         : MapQueueBH Record
// */  
    // public static Holiday createSingleHolidayRecord(string HolidayName){        
        // Holiday h =new Holiday();
        // h.ActivityDate = Date.today();
        // h.Name= HolidayName;
        // h.StartTimeInMinutes = 500;
        // h.EndTimeInMinutes = 700;
        // h.IsAllDay = true;
        
        // return h; 
    // }
    
    // /*
// *  @description     : Method to query Business Hours Record
// *  @returns         : Business Hour Record
// */  
    // public static BusinessHours querySingleBusinessHoursRecord(string BusinessHourRecordName){        
        // BusinessHours bh = [SELECT Name,SundayStartTime, SundayEndTime, 
                            // MondayStartTime, MondayEndTime, 
                            // TuesdayStartTime, TuesdayEndTime, 
                            // WednesdayStartTime, WednesdayEndTime, 
                            // ThursdayStartTime, ThursdayEndTime, 
                            // FridayStartTime, FridayEndTime, 
                            // SaturdayStartTime, SaturdayEndTime,
                            // Id, TimeZoneSidKey FROM BusinessHours where Name=:BusinessHourRecordName LIMIT 1] ;
        
        // return bh; 
    // }
    
    // /*
// *  @description     : Method to create Ticket
// *  @params          : AssetId,CaseId
// *  @returns         : Ticket Record
// */  
    // /*public static Ticket__c createTicket(Id AssetId,Id CaseId){        
// Ticket__c ticket=new Ticket__c(Queueid__c='QueueId',Ticket_status__c='Open',Case__c=CaseId,Asset__c=AssetId,Title__c='TITLE',Ticket_Reason__c='REASON');        
// return ticket; 

// }*/
    
    // /* 
// *  @author          : Sneha Reddy K
// *  @description     : Method to create Call Transcript
// *  @returns         : Call Transcript Record
// */
    // public static Call_Transcript__c createcallTranscript(){
        // Call_Transcript__c callTranscript=new Call_Transcript__c(Name='Sample Transcript',Agent_ID__c='6221202'); 
        // return callTranscript;
    // } 
    
    
    // /*
// *  @author          : Sneha Reddy K
// *  @description     : Method to create Call Transfer
// *  @params          : Call Transcript Id
// *  @returns         : Call Transfer records
// */  
    // public static Call_Transfer_Attributes__c createcallTransAttr(Id id){
        // Call_Transfer_Attributes__c callTransAttr=new Call_Transfer_Attributes__c(
            // Call_Transcript__c=id,Name='Sample CTA',Category__c='One Time Support and Solutions',Detail__c='Secure Payment IVR',
            // Service_Tag__c='Q17A027',Local_Channel__c='Retail',Product_Line__c='Cloud Servers',Notes__c='notes',Product_Shipped_Date__c=date.today(),AssetUpdated__c='Y',Caller_Location__c='US - United States of America');
        // return callTransAttr;
    // } 
    
    
    // /*
// *  @author          : Sneha Reddy K
// *  @description     : Method to test AgentCallTransferDetails external obj
// *  @returns         : AgentCallTransferDetails records
// */ 
    // public static AgentCallTransferDetails__x createTransferDetails(){
        // AgentCallTransferDetails__x agentCall = new AgentCallTransferDetails__x(
            // AgentId__c = 'TESTTAG',AgentName__c = 'TESTTAG',AliasId__c = 'TESTTAG',ContactMethodID__c = 'TESTTAG',CurrencyIsoCode = 'TESTTAG',
            // CustomerName__c = 'TESTTAG',CustomerNumber__c = 'TESTTAG',DisplayUrl = 'TESTTAG',ExternalId = 'TESTTAG',InteractionType__c = 'TESTTAG',
            // ProductLine__c = 'TESTTAG',ServiceTag__c = 'TESTTAG',TransferCount__c = '1',TransferReason__c = 'TESTTAG',ResponseCode__c = '100',ResponseDetails__c = 'TESTTAG',
            // ResponseMessage__c = 'TESTTAG'); 
        
        // return agentCall;
    // }  
    
    
    // /*
// *  @author          : Sneha Reddy K 
// *  @description     : Method to test AgentCallTransferUpdate external obj
// *  @returns         : AgentCallTransferUpdate records
// */ 
    // public static AgentCallTransferUpdate__x createTransferUpdateDetails(){
        // AgentCallTransferUpdate__x agentCallUpdate = new AgentCallTransferUpdate__x(
            // AgentId__c = 'TESTTAG',AgentName__c = 'TESTTAG',AliasId__c = 'TESTTAG',CurrencyIsoCode = 'TESTTAG',DisplayUrl = 'TESTTAG',
            // ExternalId = 'TESTTAG',InteractionType__c = 'TESTTAG',TransferCount__c = '1',TransferReason__c = 'TESTTAG',ResponseCode__c = '100',
            // ResponseDetails__c = 'TESTTAG',ResponseMessage__c = 'StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254Status'); 
        
        // return agentCallUpdate;
    // } 
    
          // /*
// *  @author          : Pavan Samanthapudi 
// *  @Params          : BUID and CCN as Strings
// *  @returns         : returns the single record instance for the object : BUID_Local_Channel_Lookup__c
// */   
    // public static BUID_Local_Channel_Lookup__c createBUID_LocalChannelLookup(){
        // BUID_Local_Channel_Lookup__c BUID_LocalChannelLookup=new BUID_Local_Channel_Lookup__c(Region__c='1', BUID__c='11', CCN__c='05', Customer_Type__c='Consumer', Type__c = 'Customer Type'); 
        // return BUID_LocalChannelLookup;
    // } 
    
// /*
// *  @author          : Brundha Rajkumar
// *  @description     : Method to create Order recoed
// *  @params          : Account Id
// *  @returns         : Order Record
// */    
    // public static Order createOrder(Id AccId){        
        // Order testOrder =  new Order(AccountId= AccId,
                                  // BUID__C= '11',
                                  // OrderNumber__c = '1122334',
                                  // Status = 'BK',                                  
                                  // EffectiveDate = system.today());
        // return testOrder; 
    // }
    
    
    // /*
// *  @author          : Sneha Reddy
// *  @description     : Method to create VoiceVDNQueueNameMapping custom object
// *  @params          : Account Id
// *  @returns         : Order Record
// */    
    // public static VoiceVDNQueueNameMapping__mdt createVDNQueueNameList(){        
        // VoiceVDNQueueNameMapping__mdt VDNQueueNameList= new VoiceVDNQueueNameMapping__mdt(MasterLabel='6166002',QueueName__c='Test_tag');               
        // return VDNQueueNameList; 
    // }
        // /*
// *  @author          : Prasanthi Mukku
// *  @description     : Method to test GetMicroCodes external obj
// *  @returns         : GetMicroCodes records
// */ 
    // public static GetMicroCodes__x getMicroDetails(){
        // GetMicroCodes__x microCall = new GetMicroCodes__x(
            // AssetId__c = 'TESTTAG',MicroCodeDateOne__c = 'TESTTAG',MicroCodeDateTwo__c = 'TESTTAG',MicroCodeOne__c = 'TESTTAG',MicroCodeTwo__c = 'TESTTAG',
            // SerialNumber__c = 'TESTTAG',ServiceTag__c = 'TESTTAG',UUID__c = 'TESTTAG',ResponseCode__c = '100',ResponseDetails__c = 'TESTTAG',
            // ResponseMessage__c = 'TESTTAG'); 
        
        // return microCall;
    // }  
    
// /*    
// *  @author          : Sneha Reddy
// *  @description     : Method to test ManageAutoRecord external obj with status as 100
// *  @returns         : ManageAutoRecord records
// */ 
    // public static ManageAutoRecord__x ManageAutoRecord(){
        // ManageAutoRecord__x manageAutoRecord = new ManageAutoRecord__x(
            // AcdLogin__c = 'TESTTAG',Operation__c = 'TESTTAG',ResponseCode__c = '100',ResponseDetails__c = 'TESTTAG',
            // ResponseMessage__c = 'StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254Status'); 
        
        // return manageAutoRecord;
    // } 
// /*    
// *  @author          : Sneha Reddy
// *  @description     : Method to test ManageAutoRecord external obj with status as 521
// *  @returns         : ManageAutoRecord records
// */ 
    // public static ManageAutoRecord__x ManageAutoRecord1(){
        // ManageAutoRecord__x manageAutoRecord = new ManageAutoRecord__x(
            // AcdLogin__c = 'TESTTAG',Operation__c = 'TESTTAG',ResponseCode__c = '521',ResponseDetails__c = '521TTAG',
            // ResponseMessage__c = 'StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254Status'); 
        
        // return manageAutoRecord;
    // } 
// /*    
// *  @author          : Sneha Reddy
// *  @description     : Method to test ManageAutoRecord external obj with status as 200
// *  @returns         : ManageAutoRecord records
// */ 
    // public static ManageAutoRecord__x ManageAutoRecord2(){
        // ManageAutoRecord__x manageAutoRecord = new ManageAutoRecord__x(
            // AcdLogin__c = 'TESTTAG',Operation__c = 'TESTTAG',ResponseCode__c = '200',ResponseDetails__c = '200TTAG',
            // ResponseMessage__c = 'StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254Status'); 
        
        // return manageAutoRecord;
    // } 
    
    // /*    
// *  @author          : Sudha Jena
// *  @description     : Method to test InteractionType external obj
// *  @returns         : InteractionType records
// */ 
   // public static InteractionType__x InteractionType(){
        // InteractionType__x InteractionType = new InteractionType__x(
            // AliasId__c = 'TESTTAG',TouchPoint__c = 'TESTTAG',ResponseCode__c = '100',ResponseDetails__c = 'TESTTAG',
            // ResponseMessage__c = 'StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254StatusStringMoreThan254Status'); 
        
        // return InteractionType;
    // } 
// /*    
// *  @author          : Arpita Patra
// *  @description     : Method to test MultiValue Routing Rules
// *  @returns         : MultiValue_Routing_Rules__c records
// */ 
    
    // public static MultiValue_Routing_Rules__c multiValueRoutingTestData(){
       // MultiValue_Routing_Rules__c mrr = new MultiValue_Routing_Rules__c (Source__c = 'DialHome;OLS', 
                                                                           // Channel__c = 'Chat', 
                                                                           // Customer_Type__c = 'Elite', 
                                                                           // Country__c='Argentina', 
                                                                           // Language__c= '',
                                                                           // SR_Type__c='Technical Support',
                                                                           // Severity__c = 'High',
                                                                           // Premium_Type__c = 'B',
                                                                           // Product_Family__c = '', 
                                                                           // Product_LOB__c = '', 
                                                                           // Product_Name__c='', 
                                                                           // Active_Flag_Check__c= true,
                                                                           // Chat_Button_Id__c ='TestButtonId',
                                                                           // Queue_Name__c = 'GL_DB_ISG_HES_VW_EN_BLND_DLM ',
                                                                           // Region__c = '1',
                                                                           // Issue_Type__c= 'Licensing',
                                                                           // Symptom_Code__c ='',
                                                                           // Control_Support_Strategy__c  = 'Unrestricted'
                                                                          // );
        // return mrr;
    // }
// /*  
// *  @description     : Method to query custom metadata-CareQueueAssignment Record
// *  @returns         : CAREQueueAssignSingleRecord
// */
   // /*( public static CareQueueAssignment__mdt CAREQueueAssignSingleRecord(string emailAddr){        
       // CareQueueAssignment__mdt mc = [SELECT Id, DeveloperName, MasterLabel, Label, Queue_Label__c , EmailAddress__c ,ActiveQueue__c   FROM CareQueueAssignment__mdt where EmailAddress__c =:emailAddr LIMIT 1];        
       // return mc; 
    // }
   // */
   
}