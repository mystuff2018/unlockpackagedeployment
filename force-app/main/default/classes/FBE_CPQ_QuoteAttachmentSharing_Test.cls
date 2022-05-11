/*
*@ Trigger Name                                                  : FBE_CPQ_QuoteAttachmentSharing ####11432375
*Description                                                     : Test Class for sharing Quote Attachment with partner users- 
*@ CreatedBy                                                     : Varsha Singh            
*/
@isTest
public class FBE_CPQ_QuoteAttachmentSharing_Test {
    
    public static testMethod  void quotefileTriggerHandler(){
        
        User usr = [Select Id from user where Userrole.Name  = 'Integration Role'];
        
        try{
            system.runAs(usr)
            {
                //Create Accounts    
            Account acc = new Account();
            acc.Name = 'TestDistributorAccount01';
            acc.Type = 'Customer';
            acc.FBE_Account_Class__c = 'Direct';
            acc.FBE_Status__c = 'Active';
            acc.FBE_Partner__c = true;
            acc.FBE_Partner_Type__c = 'Distributor';
            acc.FBE_Partner_Relationship__c = 'Titanium';
            acc.FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            insert acc;
            system.debug('acc'+acc);
            
            List < Opportunity > lOpp = FBE_UtilityFactory_Test.createOpportunity(1, acc.id,null,null,null,null,null);
            insert lOpp;
            
            system.assertNotEquals(null, lOpp, 'Opportunity not created');
        
            Quote qot=new Quote(Name='test',OpportunityId=lOpp[0].id);
            insert qot;
            
               Test.startTest();
                ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   =  'pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
                insert contentVersion; 
                
                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
                //create ContentDocumentLink  record 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = qot.id;
                cdl.ContentDocumentId = documents[0].Id;
                cdl.shareType = 'V';
                insert cdl;
                Test.stopTest(); 
            }
        }catch(exception e){
            system.debug('Message'+e.getMessage());
            system.debug('Cause'+e.getCause());
            system.debug('Line No'+e.getLineNumber());
        }
        
    }
}