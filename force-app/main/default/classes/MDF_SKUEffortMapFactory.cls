@IsTest
public class MDF_SKUEffortMapFactory {
	private SKU_Effort_Map__c current;

	public MDF_SKUEffortMapFactory(SKU_Effort_Map__c current) {
		this.current = current;
	}

	public static MDF_SKUEffortMapFactory start() {
		return new MDF_SKUEffortMapFactory(
				new SKU_Effort_Map__c(Active__c = true, Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification')
		);
	}

	public SKU_Effort_Map__c create() {
		insert current;
		return current;
	}

	public MDF_SKUEffortMapFactory overrideDescription(String value) {
		current.Description__c = value;
		return this;
	}

}