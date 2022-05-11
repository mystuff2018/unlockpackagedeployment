@IsTest
public class MDF_WOSKUEffortMapFactory {
	private WO_SKU_Effort_Map__c current;

	public MDF_WOSKUEffortMapFactory(WO_SKU_Effort_Map__c current) {
		this.current = current;
	}

	public static MDF_WOSKUEffortMapFactory start(){
		return new MDF_WOSKUEffortMapFactory(
			new WO_SKU_Effort_Map__c()
		);
	}

	public WO_SKU_Effort_Map__c create() {
		insert current;
		return current;
	}

	public WO_SKU_Effort_Map__c returnObj(){
		return current;
	}

	public MDF_WOSKUEffortMapFactory calculationType(String value) {
		current.Calculation_Type__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory deliveryMethod(String value) {
		current.Delivery_Method__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory description(String value) {
		current.Description__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory duration(Integer value) {
		current.Duration__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory relatedSKUEffortMappingEntry(SKU_Effort_Map_Entry__c value) {
		current.SKU_Effort_Mapping_Entry__c = value.Id;
		return this;
	}

	public MDF_WOSKUEffortMapFactory woRecordType(String value) {
		current.Wo_Record_Type__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory autoDispatch(Boolean value) {
		current.Auto_Dispatch__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory woType(String value) {
		current.WO_Type__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory eventType(String value) {
		current.Event_Type__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory OnDemand(Boolean value) {
		current.On_Demand_WO_Creation__c = value;
		return this;
	}

	public MDF_WOSKUEffortMapFactory phase(Id value) {
		current.Phase__c = value;
		return this;
	}
    
    public MDF_WOSKUEffortMapFactory template(Id value) {
		current.Template__c = value;
		return this;
	}
}