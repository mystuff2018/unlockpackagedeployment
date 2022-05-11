@IsTest
public class MDF_UserFactory {
	private User current;

	public MDF_UserFactory(User current) {
		this.current = current;
	}

	public static MDF_UserFactory start() {
		return new MDF_UserFactory(new User());
	}

	public User create() {
		insert current;
		return current;
	}

	public MDF_UserFactory userName(String value) {
		current.UserName = value;
		return this;
	}

	public MDF_UserFactory lastName(String value) {
		current.LastName = value;
		return this;
	}

	public MDF_UserFactory email(String value) {
		current.Email = value;
		return this;
	}

	public MDF_UserFactory alias(String value) {
		current.Alias = value;
		return this;
	}

	public MDF_UserFactory communityNickname(String value) {
		current.CommunityNickname = value;
		return this;
	}

	public MDF_UserFactory federalAccess(Boolean value) {
		current.Federal_Access__c = value;
		return this;
	}

	public MDF_UserFactory federationIdentifier(String value) {
		current.FederationIdentifier = value;
		return this;
	}

	public MDF_UserFactory timeZoneSidKey(String value) {
		current.TimeZoneSidKey = value;
		return this;
	}

	public MDF_UserFactory localeSidKey(String value) {
		current.LocaleSidKey = value;
		return this;
	}

	public MDF_UserFactory emailEncodingKey(String value) {
		current.EmailEncodingKey = value;
		return this;
	}

	public MDF_UserFactory relatedProfile(Profile value) {
		current.ProfileId = value.Id;
		return this;
	}

	public MDF_UserFactory languageLocaleKey(String value) {
		current.LanguageLocaleKey = value;
		return this;
	}

	public MDF_UserFactory osp(String value) {
		current.OSP__c = value;
		return this;
	}

	public MDF_UserFactory dellNTUserID(String value) {
		current.Dell_NTUserID__c = value;
		return this;
	}

	public MDF_UserFactory serviceUserType(String value) {
		current.Service_User_Type__c = value;
		return this;
	}

	public MDF_UserFactory externalID(String value) {
		current.External_ID__c = value;
		return this;
	}
    
    public MDF_UserFactory EmployeeNumber(String value) {
		current.EmployeeNumber = value;
		return this;
	}

	public MDF_UserFactory organization(String value) {
		current.Organization__c = value;
		return this;
	}

	public MDF_UserFactory fileSource(String value) {
		current.File_Source__c = value;
		return this;
	}
    
}