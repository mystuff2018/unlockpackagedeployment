@IsTest
public class MDF_RegionFactory {
	private pse__Region__c current;

	public MDF_RegionFactory(pse__Region__c current){
		this.current = current;
	}

	public static MDF_RegionFactory start() {
		return new MDF_RegionFactory(
			new pse__Region__c(
				Name = 'Global'
			)
		);
	}

	public MDF_RegionFactory isoCountryCode(String value) {
		current.ISO_Country_Code__c = value;

		return this;
	}

	public MDF_RegionFactory relatedParentRegion(Id value) {
		current.pse__Parent_Region__c = value;
		return this;
	}

	public MDF_RegionFactory name(String value) {
		current.Name = value;
		return this;
	}

	public pse__Region__c create() {
		insert current;
		return current;
	}

}