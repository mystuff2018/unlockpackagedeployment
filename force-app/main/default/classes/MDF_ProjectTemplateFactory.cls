@IsTest
public class MDF_ProjectTemplateFactory {
	private pse__Proj__c current;

	public MDF_ProjectTemplateFactory(pse__Proj__c current) {
		this.current = current;
	}

	public static MDF_ProjectTemplateFactory start() {
		return new MDF_ProjectTemplateFactory(
			new pse__Proj__c(
				Name = 'Test Template',
				pse__Is_Template__c = true,
				pse__Start_Date__c = Date.today(),
				pse__End_Date__c = Date.today() + 7
			)
		);
	}

	public MDF_ProjectTemplateFactory startDate(Date d) {
		current.pse__Start_Date__c = d;
		return this;
	}

	public MDF_ProjectTemplateFactory endDate(Date d) {
		current.pse__End_Date__c = d;
		return this;
	}

	public MDF_ProjectTemplateFactory projectPhase(String value) {
		current.pse__Project_Phase__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory projectType(String value) {
		current.pse__Project_Type__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory stage(String value) {
		current.pse__Stage__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory isActive(Boolean value) {
		current.pse__Is_Active__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory name(String value) {
		current.Name = value;
		return this;
	}

	public MDF_ProjectTemplateFactory relatedRegion(pse__Region__c value) {
		current.pse__Region__c = value.Id;
		return this;
	}

	public MDF_ProjectTemplateFactory projectVisibility(String value) {
		current.Project_Visibility__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory pmComplexity(String value) {
		current.PM_Complexity__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory projectComplexity(String value) {
		current.Project_Complexity__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory poNumber(String value) {
		current.PO_Number__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory deal(String value) {
		current.Deal__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory dp(String value) {
		current.DP__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory initiateCustomerContact(Boolean value) {
		current.Initiate_Customer_Contact__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory buid(String value) {
		current.BUID__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory localChannel(String value) {
		current.Local_Channel__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory planningAndDesign(Boolean value) {
		current.Planning_and_Design__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory deliveryAndImplementation(Boolean value) {
		current.Delivery_and_Implementation__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory closureReason(String value) {
		current.Closure_Reason__c = value;
		return this;
	}

	public MDF_ProjectTemplateFactory relatedProjectManager(Contact value) {
		current.pse__Project_Manager__c = value.Id;
		return this;
	}

	public MDF_ProjectTemplateFactory relatedProjectSupportAnalyst(Contact value) {
		current.Project_Support_Analyst__c = value.Id;
		return this;
	}

	public MDF_ProjectTemplateFactory relatedAccount(Account value) {
		current.pse__Account__c = value.Id;
		return this;
	}

	public pse__Proj__c create() {
		insert current;
		return current;
	}
}