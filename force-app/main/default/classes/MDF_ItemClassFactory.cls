@IsTest
public class MDF_ItemClassFactory {
	private Item_Class__c current;

	public MDF_ItemClassFactory(Item_Class__c current){
		this.current = current;
	}

	public static MDF_ItemClassFactory start() {
		return new MDF_ItemClassFactory(
			new Item_Class__c(Item_Class_Description__c = 'SVC Consulting')
		);
	}

	public MDF_ItemClassFactory itemClassDescription(String value) {
		current.Item_Class_Description__c = value;
		return this;
	}

	public MDF_ItemClassFactory relatedPractice(pse__Practice__c value) {
		current.Practice__c = value.Id;
		return this;
	}

	public MDF_ItemClassFactory keyPractice(Boolean value) {
		current.Key_Practice__c = value;
		return this;
	}

	public MDF_ItemClassFactory tower(String value) {
		current.Tower__c = value;
		return this;
	}

	public Item_Class__c returnObj() {
		return current;
	}

	public Item_Class__c create() {
		insert current;
		return current;
	}
}