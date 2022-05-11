@IsTest
public class MDF_ProjectContactFactory {
	private Project_Contact__c current;

	public MDF_ProjectContactFactory(Project_Contact__c current) {
		this.current = current;
	}

	public static MDF_ProjectContactFactory start() {
		return new MDF_ProjectContactFactory(new Project_Contact__c());
	}

	public Project_Contact__c create() {
		insert current;
		return current;
	}

	public MDF_ProjectContactFactory relatedProject(pse__Proj__c value) {
		current.Project__c = value.Id;
		return this;
	}

	public MDF_ProjectContactFactory relatedContact(Contact value) {
		current.Contact__c = value.Id;
		return this;
	}

	public MDF_ProjectContactFactory contactRole(String value) {
		current.Contact_Role__c = value;
		return this;
	}

	public MDF_ProjectContactFactory contactRoleMultiPicklist(String value) {
		//current.Contact_Role_Multi__c = value;
		return this;
	}

	public MDF_ProjectContactFactory contactType(String value) {
		current.Contact_Type__c = value;
		return this;
	}

}