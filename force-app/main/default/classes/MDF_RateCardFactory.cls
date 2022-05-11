@isTest
public class MDF_RateCardFactory {
	private pse__Rate_Card__c current;

	public MDF_RateCardFactory(pse__Rate_Card__c current){
		this.current = current;
	}

	public static MDF_RateCardFactory start() {
		return new MDF_RateCardFactory(new pse__Rate_Card__c());
	}

	public MDF_RateCardFactory role(String value) {
		current.pse__Role__c = value;

		return this;
	}
    
    public MDF_RateCardFactory suggestedBill(Integer value) {
		current.pse__Suggested_Bill_Rate__c = value;

		return this;
	}
    
    public MDF_RateCardFactory averageCostRate(Integer value) {
		current.pse__Average_Cost_Rate__c = value;

		return this;
	}
    
    public MDF_RateCardFactory relatedRegion(pse__Region__c region){
		current.pse__Region__c = region.Id;
		return this;
	}

	public pse__Rate_Card__c create() {
		insert current;
		return current;
	}
}