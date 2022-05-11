/**
 * Created by Bruno_Frosi on 1/20/2020.
 */
public class CreateProjectFieldMapper {
    public static Set<pse.SObjectCloneMapper.Field> getFields(CreateProjectDataContext context, Order order, Account account, pse__Proj__c template, String groupingKey){

        OrderItemGroupingCompositeKey compositeKey = new OrderItemGroupingCompositeKey(groupingKey);

        return new Set<pse.SObjectCloneMapper.Field>{
                setCurrencyMapField(order),
                setRegionMapField(context, order),
                setIsTemplateMapField(),
                setStartDateMapField(),
                setEndDateMapField(),
                setAccountMapField(account),
                setNameMapField(account),
                setUniqueNameMapField(account),
                setProjectManagerMapField(context.defaultProjectManager),
                setProjectVisibilityMapField(order),
                setPONumberMapField(order),
                setDPIdMapField(order),
                setDealIdMapField(order),
                setIsTemplateMappField(),
                setBillingAccountMapField(order),
                setProjectTypeMapField(compositeKey),
                setDealTypeMapField(compositeKey),    
                setDistinctSkuEffortMap(compositeKey),
                setCreatedAutomaticallyField(),
                setShoudUpdateNameField(),
                setResidencyField(compositeKey)
        };
    }

    public static pse.SObjectCloneMapper.Field setDistinctSkuEffortMap(OrderItemGroupingCompositeKey compositeKey) {  
        pse.SObjectCloneMapper.Field CurrencyMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Distinct_SKU_Effort_Mapping__c);
        CurrencyMappField.defaultValue = compositeKey.skuEffortMapping;
        return CurrencyMappField;
    }
    
    public static pse.SObjectCloneMapper.Field setResidencyField(OrderItemGroupingCompositeKey compositeKey) {  
        pse.SObjectCloneMapper.Field fieldMap = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.FBE_IDS_Residency__c);
        fieldMap.defaultValue = compositeKey.skuResidency;
        return fieldMap;
    }

    public static pse.SObjectCloneMapper.Field setProjectTypeMapField(OrderItemGroupingCompositeKey compositeKey) {
        pse.SObjectCloneMapper.Field ProjectTypeMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Project_Type__c);
        ProjectTypeMappField.defaultValue = compositeKey.projectType;
        return ProjectTypeMappField;
    }
    
	public static pse.SObjectCloneMapper.Field setDealTypeMapField(OrderItemGroupingCompositeKey compositeKey) {
        pse.SObjectCloneMapper.Field DealTypeMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Deal_Type__c);
        DealTypeMappField.defaultValue = compositeKey.dealType;
        return DealTypeMappField;
    }
    
    public static pse.SObjectCloneMapper.Field setBillingAccountMapField(Order order) {
        pse.SObjectCloneMapper.Field CurrencyMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Billing_Account__c);
        CurrencyMappField.defaultValue = Order.Billing_Account__c;
        return CurrencyMappField;
    }

    public static pse.SObjectCloneMapper.Field setCurrencyMapField(Order order) {
        pse.SObjectCloneMapper.Field CurrencyMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.CurrencyIsoCode);
        CurrencyMappField.defaultValue = Order.CurrencyIsoCode;
        return CurrencyMappField;
    }
    public static pse.SObjectCloneMapper.Field setIsTemplateMapField() {
        pse.SObjectCloneMapper.Field IsTemplateMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Is_Template__c);
        IsTemplateMappField.defaultValue = False;
        return IsTemplateMappField;
    }
    public static pse.SObjectCloneMapper.Field setRegionMapField(CreateProjectDataContext context, Order order) {	 	
        pse__region__c regionState;	
        System.debug('@@CPFMregionState@@'+regionState);
        pse__region__c regionCountry;	
        System.debug('@@regionCountry@@'+regionCountry);
        pse.SObjectCloneMapper.Field RegionMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Region__c);		
        List<pse__region__c> listRegionsByBUID = context.buidToRegion.get(order.BUID__c);	
        pse__region__c regionBUID;	
        if (listRegionsByBUID != null && listRegionsByBUID.size() > 0) {	
            regionBUID = listRegionsByBUID[0];	
        }	
        	
        if(regionState != null) {	
            RegionMappField.defaultValue = regionState.Id;	
        } else if (regionCountry != null) {	
            RegionMappField.defaultValue = regionCountry.Id;	
        } else if (regionBUID != null) {	
            RegionMappField.defaultValue = regionBUID.Id;	
        } else {	
            RegionMappField.defaultValue = null;        	
        }	
        System.debug('@@CPFMRegionMappField@@'+RegionMappField);
        return RegionMappField;	
    }
    
    public static pse.SObjectCloneMapper.Field setStartDateMapField() {
        pse.SObjectCloneMapper.Field StartDateMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Start_Date__c);
        StartDateMappField.defaultValue = Date.today();
        return StartDateMappField;
    }
    public static pse.SObjectCloneMapper.Field setEndDateMapField() {
        pse.SObjectCloneMapper.Field EndDateMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__End_Date__c);
        EndDateMappField.defaultValue = Date.today().addDays(7);
        return EndDateMappField;
    }
    public static pse.SObjectCloneMapper.Field setAccountMapField(Account account) {
        pse.SObjectCloneMapper.Field AccountMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Account__c);
        AccountMappField.defaultValue = account.Id;
        return AccountMappField;
    }
    public static pse.SObjectCloneMapper.Field setNameMapField(Account account) {
        pse.SObjectCloneMapper.Field NameMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Name);
        NameMappField.defaultValue = account.Name.left(60) + ' ' + Datetime.now().format('MMM dd yyyy HHmmss');
        return NameMappField;
    }
    public static pse.SObjectCloneMapper.Field setUniqueNameMapField(Account account) {
        pse.SObjectCloneMapper.Field UniqueNameMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Project_Name_Unique__c);
        UniqueNameMappField.defaultValue = account.Name.left(60) + ' ' + Datetime.now().format('MMM dd yyyy HHmmss');
        return UniqueNameMappField;
    }
    public static pse.SObjectCloneMapper.Field setProjectManagerMapField(Id pm) {
        pse.SObjectCloneMapper.Field ProjectManagerMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Project_Manager__c);
        ProjectManagerMappField.defaultValue = pm;
        return ProjectManagerMappField;
    }
    public static pse.SObjectCloneMapper.Field setProjectVisibilityMapField(Order order) {
        pse.SObjectCloneMapper.Field ProjectVisibilityMapField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Project_Visibility__c);
        if ((!string.isEmpty(order.OCI_Order_Type__c) && order.OCI_Order_Type__c.containsIgnoreCase('FED'))
            || (!string.isEmpty(order.Sales_Channel__c) && order.Sales_Channel__c.containsIgnoreCase('FED'))) {
            ProjectVisibilityMapField.defaultValue = 'Federal';
        } else {
            ProjectVisibilityMapField.defaultValue = 'All';
        }
        return ProjectVisibilityMapField;
    }
    
    public static pse.SObjectCloneMapper.Field setPONumberMapField(Order order) {
        pse.SObjectCloneMapper.Field PoNumberMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.PO_Number__c);
        PoNumberMappField.defaultValue = Order.PoNumber;
        return PoNumberMappField;
    }
    public static pse.SObjectCloneMapper.Field setDPIdMapField(Order order) {
        pse.SObjectCloneMapper.Field DPIdMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.DP__c);
        DPIdMappField.defaultValue = Order.DPID__c;
        return DPIdMappField;
    }
    public static pse.SObjectCloneMapper.Field setDealIdMapField(Order order) {
        pse.SObjectCloneMapper.Field DealIdMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Deal__c);
        DealIdMappField.defaultValue = Order.Deal_ID__c;
        return DealIdMappField;
    }
    public static pse.SObjectCloneMapper.Field setIsTemplateMappField() {
        pse.SObjectCloneMapper.Field IsTemplateMappField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.pse__Is_Template__c);
        IsTemplateMappField.defaultValue = False;
        return IsTemplateMappField;
    }

    public static pse.SObjectCloneMapper.Field setCreatedAutomaticallyField() {
        pse.SObjectCloneMapper.Field createdAutomaticallyField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Created_Automatically__c);
        createdAutomaticallyField.defaultValue = true;
        return createdAutomaticallyField;
    }

    public static pse.SObjectCloneMapper.Field setShoudUpdateNameField() {
        pse.SObjectCloneMapper.Field shouldUpdateNameField = new pse.SObjectCloneMapper.Field(Schema.pse__Proj__c.Should_Update_Name__c);
        shouldUpdateNameField.defaultValue = true;
        return shouldUpdateNameField;
    }
}