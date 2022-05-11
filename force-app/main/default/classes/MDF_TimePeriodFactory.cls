@IsTest
public class MDF_TimePeriodFactory {
	private pse__Time_Period__c current;

	public MDF_TimePeriodFactory(pse__Time_Period__c current) {
		this.current = current;
	}

	public static MDF_TimePeriodFactory start() {
		return new MDF_TimePeriodFactory(new pse__Time_Period__c());
	}

	public pse__Time_Period__c create() {
		insert current;
		return current;
	}

	public MDF_TimePeriodFactory name(String value) {
		current.Name = value;
		return this;
	}

	public MDF_TimePeriodFactory currencyIsoCode(String value) {
		current.CurrencyIsoCode = value;
		return this;
	}

	public MDF_TimePeriodFactory startDate(Date value) {
		current.pse__Start_Date__c = value;
		return this;
	}

	public MDF_TimePeriodFactory endDate(Date value) {
		current.pse__End_Date__c = value;
		return this;
	}

	public MDF_TimePeriodFactory type(String value) {
		current.pse__Type__c = value;
		return this;
	}
}