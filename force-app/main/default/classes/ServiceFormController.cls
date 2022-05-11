public without sharing class ServiceFormController {

    private static final String chatDeployment = 'Dell_Chat_Deployment';
    private static final String defaultChatQueue = 'US_TS_CPS_Federal';
    private static final String defaultTechSupportQueue = 'US_Comm_Federal_TS_Email';
    private static final String defaultCustomerCareQueue = 'US_CC_Fed_Support_Email';
    public Blob file {get; set;}
    public String fileName {get; set;}

    public PageReference saveEmailCase() {
        
        String issue = getParam('issue');
        String email = getParam('email');
        String firstName = getParam('first-name');
        String lastName = getParam('last-name');
        String phone = getParam('phone');
        String phoneExt = getParam('phone-extension');
        String description = getParam('description');
        String serviceTag = getParam('service-tag');
        String formType = getParam('form-type');

        Contact ctc = null;
        List<Contact> contacts = new List<Contact>([select accountid, id from Contact where email = :email limit 1]);
        if (contacts.size() == 1) {
            ctc = contacts[0];
        }
        else {
            ctc = new Contact();
            ctc.email = email;
            ctc.firstName = firstName;
            ctc.lastName = lastName;
            ctc.phone = phone;
            ctc.Primary_Phone__c = phone;
            ctc.Primary_Phone_Ext__c = phoneExt;
            ctc.RecordTypeId = [select id from RecordType where DeveloperName = 'New_Contact' and sobjecttype = 'Contact'][0].id;
            if (formType == 'tech-support') {
                ctc.Secondary_Phone__c = getParam('alt-phone');
                ctc.Secondary_Phone_Ext__c = getParam('alt-phone-extension');
            }
            insert ctc;
        }

        Case c = new Case();
        c.Status = 'Open';
        c.Origin = 'Web';
        c.ContactId = ctc.id;
        c.AccountId = ctc.accountId;
        c.Description = description;
        c.Secondary_Reason__c = issue;
        c.Service_Tag__c = serviceTag;
        c.Customer_Phone__c = phone;
        c.Customer_Phone_Extension__c = phoneExt;
        c.Subject = description.length() <= 255 ? description : description.substring(0,252) + '...';
        c.Customer_Street__c = getParam('street');
        c.Customer_City__c = getParam('city');
        c.Customer_State__c = getParam('state');
        c.Customer_Postal_Code__c = getParam('zip-code');
        c.Customer_Country__c = getParam('country');
        c.RecordTypeId = getCaseRecordTypeId();

        if (formType == 'tech-support') {
            c.Customer_Alternate_Phone__c = getParam('alt-phone');
            c.Customer_Alternate_Phone_Extension__c = getParam('alt-phone-extension');
            c.Reason = ServiceConstants.CASE_REASON_TECHNICAL_SUPPORT;
            String queueName = defaultTechSupportQueue;
            if (getParam('queuename') != null) {
                String queueNameParam = getParam('queuename') + '_Email';
                if (new List<Group>([select id from Group where DeveloperName = :queueNameParam]).size() > 0) {
                    queueName = queueNameParam;
                }
            }
            c.OwnerId = [select id from group where developername = :queueName].id;
            c.Service_Queue__c = queueName;
           
        }
        else if (formType == 'order-support') {
            c.Customer_Company__c = getParam('company');
            c.Order_Number__c = getParam('order-number');
            c.Account_Number__c = getParam('account-number');
            c.Reason = 'Customer Care';
            String queueName = defaultCustomerCareQueue;
            c.OwnerId = [select id from group where developername = :defaultCustomerCareQueue].id;
            c.Service_Queue__c = queueName;
           
        }

        insert c;

        if (formType == 'tech-support' && fileName != null) {
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient = fileName;
            cv.Title = fileName;
            cv.VersionData = file;
            cv.FirstPublishLocationId = c.id;
            insert cv;
             
        }
            PageReference ref;
            if(formType == 'tech-support'){
                ref=Page.ServiceTechnicalSupportEmailConfirmation;
                ref.setRedirect(true);
                ref.getParameters().put('id', c.id);
            }
            else if(formType == 'order-support'){
                ref=Page.ServiceCustomerCareEmailConfirmation;
                ref.setRedirect(true);
                ref.getParameters().put('id', c.id);
            }
            
         return ref;        
    }

    public PageReference searchOrders() {
        return null;
    }

    private List<SelectOption> getPicklistValues(Schema.SObjectField f, String filter) {
        List<SelectOption> options = new List<SelectOption>();
        SelectOption so = new SelectOption();
        so.value = ''; so.label = '';
        options.add(so);
        List<Schema.PicklistEntry> ple = f.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry e : ple) {
            if (filter == null || e.getValue().contains(filter)) {
                so = new SelectOption();
                so.value = e.getValue(); so.label = e.getLabel();
                options.add(so);
            }
        }       
        return options;
    }

    public List<SelectOption> getReasons() {      
        return getPicklistValues(Case.Secondary_Reason__c, '[OS]');
    }

    public List<SelectOption> getTechSupportReasons() {      
        return getPicklistValues(Case.Secondary_Reason__c, '[TS]');
    }

    public List<SelectOption> getCountries() {
        return getPicklistValues(Case.Customer_Country__c, null);
    }

    public List<SelectOption> getStates() {
        return getPicklistValues(Case.Customer_State__c, null);
    }

    public List<SelectOption> getSupportRoles() {
        return getPicklistValues(Case.Support_Role__c, null);
    }

    public String getBaseUrl() {
        return System.URL.getSalesforceBaseUrl().getHost();
    }

    public String getOrgId() {
        return String.valueOf([select id from organization].id).substring(0,15);
    }
    
    public String getButtonId() {
        String queueName = defaultChatQueue;
        String pageName = ApexPages.currentPage().getUrl().toLowerCase();
        if (pageName.contains('servicechatfirstsupport')) {
            queueName = 'FIRST_Helpdesk';
        }
        else if (pageName.contains('servicechattechsupport')) {
            queueName = 'Internal_Tech_Support';
        }
        return String.valueOf([select id from LiveChatButton where developername = :queueName].id).substring(0,15);
    }

    public String getQueueName() {
        return getParam('queuename') != null ? getParam('queuename') : '';
    }
    
    public String getChatDeploymentId() {
        return String.valueOf([select id from LiveChatDeployment where DeveloperName = :chatDeployment].id).substring(0,15);
    }

    public String getCaseNumber() {
        return [select caseNumber from case where id = :getParam('id') limit 1].caseNumber;
    }

    public String getCaseRecordTypeId() {
        return [select id from RecordType where DeveloperName = 'Service' and sobjecttype = 'Case'].id;
    }

    private String getParam(String param) {
        String val = ApexPages.currentPage().getParameters().get(param);
        return (val != null && val != '') ? val : null;
    }

    public class SelectOption {
        public String value {get;set;}
        public String label {get;set;}
    }
}