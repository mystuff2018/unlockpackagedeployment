@IsTest
public class MDF_BudgetFactory {
	private pse__Budget__c current;

	public MDF_BudgetFactory(pse__Budget__c current) {
		this.current = current;
	}

	public static MDF_BudgetFactory start(pse__Proj__c project){
		return new MDF_BudgetFactory(
			new pse__Budget__c(
				pse__Project__c = project.Id
			)
		);
	}

	public MDF_BudgetFactory type(String type) {
		current.pse__Type__c = type;
		return this;
	}

	public MDF_BudgetFactory status(String status) {
		current.pse__Status__c = status;
		return this;
	}

	public MDF_BudgetFactory includeInFinancials(Boolean value) {
		current.pse__Include_In_Financials__c = value;
		return this;
	}

	public pse__Budget__c create() {
		insert current;
		return current;
	}
}