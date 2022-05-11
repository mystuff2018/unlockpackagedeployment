public virtual class OrderProjectComplexity {
    private Map<Id, Decimal> projectIdToTotalAmountUSD {get; set;}
    private Map<String, Project_Complexity_Threshold__c> countryToComplexityThreshouldMap { get; set; }
    private Map<String, String> complexityMap { get; set; }
    private Map<Id, List<pse__Budget__c>> projectIdToAllBudgetListMap { get; set; }
    private List<pse__Proj__c> projectList { get; set; }
    private Map<String, Sku_Effort_Map__c> skuEffortMap  { get; set; }
    private Map<Id, List<OrderItem>> projectWithAllOrderItems { get; set; }
    
	private static final string DEAL_TYPE_CUSTOM = 'Custom';
    private final string CUSTOMER_PURCHASE_ORDER = 'Customer Purchase Order';
    private final string COMPLEXITY_LOW = 'Low';
    private final string COMPLEXITY_MEDIUM = 'Medium';
    private final string COMPLEXITY_HIGH = 'High';

    //protected virtual Map<Id, List<pse__Budget__c>> createMapWithAllBudgets();
	
    public OrderProjectComplexity (List<pse__Proj__c> projectList, Map<Id, List<pse__Budget__c>> projectIdToAllBudgetListMap, Map<Id, List<OrderItem>> projectWithAllOrderItems, Map<String, Sku_Effort_Map__c> skuEffortMap ) {
        this.projectList = projectList;
        this.projectIdToAllBudgetListMap = projectIdToAllBudgetListMap;
        this.skuEffortMap = skuEffortMap;
        this.projectWithAllOrderItems = projectWithAllOrderItems;
    }
    
    
    public void calculateProjectComplexity() {
        setComplexityMap();
        setTotalAmountByProject();
        setThresholdByProjectRegion();
        
		for(pse__Proj__c project : projectList) {
            
            string budgetThreshold = getComplexityThresholdFromProject(project);

            if (project.Deal_Type__c == DEAL_TYPE_CUSTOM) {
                project.Project_Complexity__c = budgetThreshold;
            } 
            else {
                OrderAssociationPMComplexity.setPMComplexity(project, this.projectWithAllOrderItems.get(project.Id), this.skuEffortMap);
                project.Project_Complexity__c = getProjectComplexityFromStandartProject(project, budgetThreshold);
            }
        }
    }

    private String getProjectComplexityFromStandartProject(pse__Proj__c project, string budgetThreshold) {
        String key = (project.PM_Complexity__c != null ? project.PM_Complexity__c : budgetThreshold) + ':' + budgetThreshold;
        return complexityMap.get(key);
    }

    private string getComplexityThresholdFromProject(pse__Proj__c project) {
        Decimal amount = projectIdToTotalAmountUSD.get(project.Id);
        system.debug('test amount');
        system.debug(amount);
        Project_Complexity_Threshold__c complexityThreshold = getComplexityThreshold(getIsoCountryCodeFromRegionOrParent(project));
        system.debug(complexityThreshold);

        if (amount == null || complexityThreshold == null) {
            return COMPLEXITY_LOW;
        }

        if(amount >= complexityThreshold.High_Threshold__c){
            return COMPLEXITY_HIGH;
        }
        else if(amount > complexityThreshold.Low_Threshold__c && amount < complexityThreshold.High_Threshold__c)
        {
            return COMPLEXITY_MEDIUM;
        }

        return COMPLEXITY_LOW;
    }

    private Project_Complexity_Threshold__c getComplexityThreshold(string regionName) {
        Project_Complexity_Threshold__c result;

        if (countryToComplexityThreshouldMap != null && countryToComplexityThreshouldMap.containsKey(regionName)) {
            result = countryToComplexityThreshouldMap.get(regionName);
        }

        return result;
    }
    
    private void setComplexityMap() {
        complexityMap = new map<String,String>();        
        for(Project_Complexity_Mapping__c pcm : [SELECT PM_Complexity__c, Revenue_Threshold__c,Overall_Project_Complexity__c
									            FROM Project_Complexity_Mapping__c]) {
            complexityMap.put( pcm.PM_Complexity__c + ':' +  pcm.Revenue_Threshold__c,
            pcm.Overall_Project_Complexity__c);
        }
    }

    private void setTotalAmountByProject() {
        projectIdToTotalAmountUSD = new Map<Id, Decimal>();
        for (Id projectId : this.projectIdToAllBudgetListMap.keySet()) {
            Decimal amount = 0;
            for (pse__Budget__c budget : this.projectIdToAllBudgetListMap.get(projectId)) {
                if (budget.pse__Type__c == CUSTOMER_PURCHASE_ORDER && budget.Amount_USD__c != null) {
                    amount = amount + budget.Amount_USD__c;
                }
            }
            projectIdToTotalAmountUSD.put(projectId, amount);
        }
    }
    
    private void setThresholdByProjectRegion() {
        List<String> isoCountryCodes = getIsoContryCodesFromProjects(this.projectList);
        List<Project_Complexity_Threshold__c> countryThresholds = [SELECT Name, Low_Threshold__c, High_Threshold__c FROM Project_Complexity_Threshold__c WHERE Name IN :isoCountryCodes];
        if (!countryThresholds.isEmpty()) {
            countryToComplexityThreshouldMap = new Map<String, Project_Complexity_Threshold__c>();
            for(Project_Complexity_Threshold__c countryThreshold : countryThresholds) {
                countryToComplexityThreshouldMap.put(countryThreshold.Name, countryThreshold);
            }
        }
    }

    private List<String> getIsoContryCodesFromProjects(List<pse__Proj__c> projects) {
        List<String> isoCountryCodes = new List<String>();
        for (pse__Proj__c project : projects) {
            isoCountryCodes.add(getIsoCountryCodeFromRegionOrParent(project));
        }
        return isoCountryCodes;
    }

    private String getIsoCountryCodeFromRegionOrParent(pse__Proj__c project) {
		return project.pse__Region__r.is_State__c ? project.pse__Region__r.pse__Parent_Region__r.ISO_Country_Code__c : project.pse__Region__r.ISO_Country_Code__c;
    }
}