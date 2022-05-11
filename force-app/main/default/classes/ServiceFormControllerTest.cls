@isTest
public class ServiceFormControllerTest {

    @IsTest
    static void testTechSupportEmailCase() {      
        PageReference pageRef = Page.ServiceEmailTechSupport;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('first-name','john'); 
        ApexPages.currentPage().getParameters().put('last-name','john');
        ApexPages.currentPage().getParameters().put('email','john@johndoe.com');
        ApexPages.currentPage().getParameters().put('phone','1111111111');
        ApexPages.currentPage().getParameters().put('alt-phone','2222222222');
        ApexPages.currentPage().getParameters().put('issue','Audio [TS]');
        ApexPages.currentPage().getParameters().put('description','My description');
        ApexPages.currentPage().getParameters().put('service-tag','123456');
        ApexPages.currentPage().getParameters().put('form-type','tech-support');

        ServiceFormController sfc = new ServiceFormController();
        sfc.fileName = 'my test file';
        sfc.file = Blob.valueOf('my test file');

        sfc.saveEmailCase();
        system.assertEquals('john', [select firstname from contact][0].firstname);
        system.assertEquals('My description', [select subject from case][0].subject);
    }

    @IsTest
    static void testOrderSupportEmailCase() {
        
        PageReference pageRef = Page.ServiceEmailOrderSupport;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('first-name','john');
        ApexPages.currentPage().getParameters().put('last-name','john');
        ApexPages.currentPage().getParameters().put('email','john@johndoe.com');
        ApexPages.currentPage().getParameters().put('phone','1111111111');
        ApexPages.currentPage().getParameters().put('alt-phone','2222222222');
        ApexPages.currentPage().getParameters().put('issue','Change, Return or Cancel an Order [OS]');
        ApexPages.currentPage().getParameters().put('description','My description');
        ApexPages.currentPage().getParameters().put('service-tag','123456');
        ApexPages.currentPage().getParameters().put('form-type','order-support');

        ServiceFormController sfc = new ServiceFormController();
        sfc.fileName = 'my test file';
        sfc.file = Blob.valueOf('my test file');

        sfc.saveEmailCase();
        system.assertEquals('john', [select firstname from contact][0].firstname);
        system.assertEquals('My description', [select subject from case][0].subject);
    }

    @IsTest
    static void shouldGetPicklistOptions(){

        Case caseRecord = new Case();
        insert caseRecord;

        PageReference pageRef = Page.ServiceChatFirstSupport;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('first-name','john'); 
        ApexPages.currentPage().getParameters().put('last-name','john');
        ApexPages.currentPage().getParameters().put('email','john@johndoe.com');
        ApexPages.currentPage().getParameters().put('phone','1111111111');
        ApexPages.currentPage().getParameters().put('alt-phone','2222222222');
        ApexPages.currentPage().getParameters().put('issue','Audio [TS]');
        ApexPages.currentPage().getParameters().put('description','My description');
        ApexPages.currentPage().getParameters().put('service-tag','123456');
        ApexPages.currentPage().getParameters().put('form-type','tech-support');
        ApexPages.currentPage().getParameters().put('id',caseRecord.Id);

        Test.startTest();

        ServiceFormController formController = new ServiceFormController();
        formController.getReasons();
        formController.getTechSupportReasons();
        formController.getCountries();
        formController.getStates();
        formController.getSupportRoles();
        formController.getBaseUrl(); 
        formController.getOrgId();
        formController.getButtonId();
        formController.getQueueName();
        formController.getChatDeploymentId();
        formController.getCaseNumber();
        formController.getCaseRecordTypeId();

        Test.stopTest();
        
    }
}