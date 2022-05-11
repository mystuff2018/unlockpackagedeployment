@IsTest
public class MDF_WorkCalendarFactory {
	private pse__Work_Calendar__c current;

	public MDF_WorkCalendarFactory(pse__Work_Calendar__c current) {
		this.current = current;
	}

	public static MDF_WorkCalendarFactory start() {
		return new MDF_WorkCalendarFactory(new pse__Work_Calendar__c());
	}

	public MDF_WorkCalendarFactory name(String value) {
		current.Name = value;
		return this;
	}

	public pse__Work_Calendar__c create() {
		insert current;
		return current;
	}

}