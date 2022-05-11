@IsTest
public class MDF_ProjectFactory {
	public pse__Proj__c current;

	public MDF_ProjectFactory(pse__Proj__c current) {
		this.current = current;
	}

	// Entry point builder method to start composing object attributes
	public static MDF_ProjectFactory start() {
		return new MDF_ProjectFactory(
				new pse__Proj__c()
		);
	}

	// Composable Functions

	public pse__Proj__c create() {
		insert current;
		return current;
	}

	public MDF_ProjectFactory asAnEngagement() {
		current.RecordTypeId = Schema.pse__Proj__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Parent_Project').recordTypeId;
		return this;
	}

	public MDF_ProjectFactory asAnChildProject(pse__Proj__c value) {
		current.RecordTypeId = Schema.pse__Proj__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Tier_1').recordTypeId;
		current.pse__Parent_Project__c = value.Id;
		return this;
	}

	public MDF_ProjectFactory relatedProjectManager(Id managerId) {
		current.pse__Project_Manager__c = managerId;
		return this;
	}

	public MDF_ProjectFactory relatedRegion(Id regionId) {
		current.pse__Region__c = regionId;
		return this;
	}

	public MDF_ProjectFactory relatedPratice(Id praticeId) {
		current.pse__Practice__c = praticeId;
		return this;
	}

	public MDF_ProjectFactory isBilliable(Boolean isBilliable) {
		current.pse__Is_Billable__c = isBilliable;
		return this;
	}

	public MDF_ProjectFactory isTemplate(Boolean isTemplate) {
		current.pse__Is_Template__c = isTemplate;
		return this;
	}

	public MDF_ProjectFactory isActive(Boolean isActive) {
		current.pse__Is_Active__c = isActive;
		return this;
	}

	public MDF_ProjectFactory withSetupPhase() {
		current.pse__Start_Date__c = System.today();
        current.pse__End_Date__c = System.today() + 7;
        current.pse__Project_Phase__c = 'Setup';
        current.pse__Project_Type__c = 'Standard';
		current.pse__Stage__c = 'Draft';
		return this;
	}

	public MDF_ProjectFactory withDealType(String value) {
        current.Deal_Type__c = value;
		return this;
	}

	public MDF_ProjectFactory name(String value) {
		current.Name = value;
		return this;
	}

	public MDF_ProjectFactory projectVisibility(String value) {
		current.Project_Visibility__c = value;
		return this;
	}

	public MDF_ProjectFactory pmComplexity(String value) {
		current.PM_Complexity__c = value;
		return this;
	}

	public MDF_ProjectFactory projectComplexity(String value) {
		current.Project_Complexity__c = value;
		return this;
	}

	public MDF_ProjectFactory initiateCustomerContact(Boolean value) {
		current.Initiate_Customer_Contact__c = value;
		return this;
	}

	public MDF_ProjectFactory planningAndDesign(Boolean value) {
		current.Planning_and_Design__c = value;
		return this;
	}

	public MDF_ProjectFactory deliveryAndImplementation(Boolean value) {
		current.Delivery_and_Implementation__c = value;
		return this;
	}

	public MDF_ProjectFactory closureReason(String value) {
		current.Closure_Reason__c = value;
		return this;
	}

	public MDF_ProjectFactory relatedProjectSupportAnalyst(Contact value) {
		current.Project_Support_Analyst__c = value.Id;
		return this;
	}

	public MDF_ProjectFactory relatedAccount(Account value) {
		current.pse__Account__c = value.Id;
		return this;
	}

	public MDF_ProjectFactory projectPhase(String value) {
		current.pse__Project_Phase__c = value;
		return this;
	}

	public MDF_ProjectFactory poNumber(String value) {
		current.PO_Number__c = value;
		return this;
	}

	public MDF_ProjectFactory dpId(String value) {
		current.DP__c = value;
		return this;
	}

	public MDF_ProjectFactory projectStage(String value) {
		current.pse__Stage__c = value;
		return this;
	}

	public MDF_ProjectFactory buid(String value){
		current.BUID__c = value;
		return this;
	}

	public MDF_ProjectFactory localChannel(String value){
		current.Local_Channel__c = value;
		return this;
	}

    public MDF_ProjectFactory closeForTimeEntry(Boolean value){
		current.pse__Closed_for_Time_Entry__c = value;
		return this;
	} 
}