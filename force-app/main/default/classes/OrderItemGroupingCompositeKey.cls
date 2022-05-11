/**
 * Created by Bruno_Frosi on 4/7/2020.
 */

public with sharing class OrderItemGroupingCompositeKey {
    public String engagementId;
    public String practice {get;set;}
    public String buid {get;set;}
    public String localChannel {get;set;}
    public String skuEffortMapping {get;set;}
    public String visibility {get;set;}
    public String projectType {get;set;}
    public String dealType {get;set;}
	public Boolean skuResidency {get;set;}
    public String currencyIsoCode {get;set;}

    public OrderItemGroupingCompositeKey(string pPracticeId, pse__Proj__c project)
    {
        this.engagementId = project.pse__Parent_Project__c;
        this.practice = pPracticeId;
        this.buid = project.buid__c;
        this.localChannel = project.Local_Channel__c;
        this.visibility = project.Project_Visibility__c;
        this.projectType = project.pse__Project_Type__c;
        this.dealType = project.Deal_Type__c;
        this.currencyIsoCode = project.CurrencyIsoCode;

        if(project.Distinct_SKU_Effort_Mapping__c != null){
            this.skuEffortMapping = project.Distinct_SKU_Effort_Mapping__c;
        }
    }

    public OrderItemGroupingCompositeKey(pse__Proj__c project)
    {
        this.engagementId = project.pse__Parent_Project__c;
        this.practice = project.pse__Practice__c;
        this.buid = project.buid__c;
        this.localChannel = project.Local_Channel__c;
        this.visibility = project.Project_Visibility__c;
        this.projectType = project.pse__Project_Type__c;
        this.dealType = project.Deal_Type__c;
        this.currencyIsoCode = project.CurrencyIsoCode;

        if(project.Distinct_SKU_Effort_Mapping__c != null){
            this.skuEffortMapping = project.Distinct_SKU_Effort_Mapping__c;
        }
    }
    
    public OrderItemGroupingCompositeKey(string pPracticeId, Order order, Sku_Effort_Map__c skuEffort, String engagementId, String projectType, String orderItemType, Boolean skuResidency)
    {
        this.engagementId = engagementId;
        this.practice = pPracticeId;
        this.buid = order.buid__c;
        this.localChannel = order.Local_Channel__c;
        this.visibility = order.OPR_Is_Federal__c;
        this.projectType = projectType;
        this.dealType = orderItemType;
		this.skuResidency = skuResidency;
        this.currencyIsoCode = order.CurrencyIsoCode;

        if(skuEffort != null && skuEffort.Distinct_Project__c){
			this.skuResidency = skuEffort.Residency__c;
            this.skuEffortMapping = skuEffort.Id;
        }
    }

    public OrderItemGroupingCompositeKey(string compositeKey)
    {
        List<string> keys = compositeKey.split(';');

        this.practice = keys[0];
        this.buid = keys[1];
        this.localChannel = keys[2];
        this.visibility = keys[3];
        this.skuEffortMapping = String.isNotBlank(keys[4]) ? keys[4] : null;
        this.engagementId = keys[5];
        this.projectType = keys[6];
        this.dealType = keys[7];
		this.skuResidency = Boolean.valueOf(keys[8]);
        this.currencyIsoCode = keys[9];
    }

    // this method should not compare practices. It will compare all other attributes from the composite key
    public Boolean isKeyCompatible(OrderItemGroupingCompositeKey key)
    {

        return (this.buid == key.buid && 
                this.localChannel == key.localChannel && 
                this.visibility == key.visibility && 
                this.skuEffortMapping == key.skuEffortMapping &&
                this.engagementId == key.engagementId &&
                this.projectType == key.projectType &&
                this.dealType == key.dealType && 
                this.currencyIsoCode == key.currencyIsoCode);

    }

    public override string toString()
    {
        return practice + ';' + buid + ';' + localChannel + ';'+ visibility  + ';' + (skuEffortMapping != null ?  + skuEffortMapping : '') + ';' + engagementId + ';' + projectType + ';' + dealType + ';' + skuResidency + ';' + currencyIsoCode;
    }
}