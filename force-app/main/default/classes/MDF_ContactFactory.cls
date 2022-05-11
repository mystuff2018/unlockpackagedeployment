@IsTest
public class MDF_ContactFactory {
    private Contact current;

    public MDF_ContactFactory(Contact current) {
        this.current = current;
    }

    public static MDF_ContactFactory start() {
        return new MDF_ContactFactory(
            new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'test@email.com',
                Phone = '6342567345'
            )
        );
    }

    public Contact create(){
        insert current;
        return current;
    }

    public MDF_ContactFactory overrideFirstName(String value) {
        current.FirstName = value;
        return this;
    }

    public MDF_ContactFactory overrideLastName(String value) {
        current.LastName = value;
        return this;
    }

    public MDF_ContactFactory overrideEmail(String value) {
        current.Email = value;
        return this;
    }

    public MDF_ContactFactory primaryPhone(String phone) {
        current.Primary_Phone__c = phone;
        return this;
    }

    public MDF_ContactFactory phone(String phone) {
        current.Phone = phone;
        return this;
    }

    public MDF_ContactFactory timeZone(String timeZone) {
        current.TimeZone__c = timeZone;
        return this;
    }

    public MDF_ContactFactory badgeId(String badgeId) {
        current.Badge_ID__c = badgeId;
        return this;
    }

    public MDF_ContactFactory isResource(Boolean resource) {
        current.pse__Is_Resource__c = resource;
        return this;
    }

    public MDF_ContactFactory isResourceActive(Boolean resourceActive) {
        current.pse__Is_Resource_Active__c = resourceActive;
        return this;
    }

    public MDF_ContactFactory relatedSalesforceUser(Id sfUser) {
        current.pse__Salesforce_User__c = sfUser;
        return this;
    }

    public MDF_ContactFactory relatedRegion(pse__Region__c region){
        current.pse__Region__c = region.Id;
        return this;
    }

    public MDF_ContactFactory relatedPractice(pse__Practice__c practice) {
        current.pse__Practice__c = practice.Id;
        return this;
    }

    public MDF_ContactFactory relatedAccount(Account acc) {
        current.AccountId = acc.Id;
        return this;
    }

    public MDF_ContactFactory relatedWorkCalendar(pse__Work_Calendar__c work_calendar) {
        current.pse__Work_Calendar__c = work_calendar.Id;
        return this;
    }
    public MDF_ContactFactory resourceRole(String value) {
        current.pse__Resource_Role__c = value;
        return this;
    }
}