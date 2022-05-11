//'SKU Number||Description||Sku_Duration||Distinct||Practice||Phase||Task Name||Role||Project Complexity||Estimated Hours||Skill/Certification||WO Description||Delivery Method||Calculation Type||Duration||Threshold||Below Threshold||Above Threshold||Schedule Type||Record Type||DPS Type||WO Create Phase'

public class IDS_DataLoaderWrapper {
	public string skuDescription;
	public string skuNumber;
	public Decimal Sku_Duration;
	public boolean Distinct;
	public string Practice;
	public string Phase;
	public string TaskName;
	public string Role;
	public string ProjectComplexity;
	public Decimal EstimatedHours;
	public string SkillCertification;
	public string WODescription;
    public string srType;
    public string woType;
	public string DeliveryMethod;
	public string CalculationType;
	public Decimal Duration;
	public Decimal Threshold;
	public Decimal BelowThreshold;
	public Decimal AboveThreshold;
	public string ScheduleType;
	public string RecordType;
	public string DPSType;
	public string WOCreatePhase;
    public string callType;
    public boolean onDemand;
    public boolean residency;
	public IDS_DataLoaderWrapper(string dataString){
		//IDS_DataLoaderWrapper loadWrap = new IDS_DataLoaderWrapper();
        //if(dataString.split('~')[1] == 'ProDeploy Add-On: Upgrade to On-Site Delivery (Caribbean Only - Requires 1 per deployment site)_Onsite' ){
        	Map<STRING,STRING> dataMap = new Map<STRING,STRING>();
        string headerString;
        if(Test.isRunningTest()){
          headerString=  'skuNumber~skuDescription~Sku_Duration~Distinct~Practice~Phase~TaskName~Role~ProjectComplexity~EstimatedHours~SkillCertification~WODescription~DeliveryMethod~CalculationType~Duration~Threshold~BelowThreshold~AboveThreshold~ScheduleType~RecordType~DPSType~WOCreatePhase';
        }else{
            headerString =System.Label.SKU_DATA_HEADER;
        }
        	 
        	//string headerString ='skuNumber~skuDescription~Sku_Duration~Distinct~residency~Practice~Phase~TaskName~Role~ProjectComplexity~EstimatedHours~SkillCertification~WODescription~srType~woType~DeliveryMethod~CalculationType~Duration~Threshold~BelowThreshold~AboveThreshold~ScheduleType~RecordType~callType~DPSType~WOCreatePhase~onDemand';
        	system.debug('headerString '+headerString);
            for(integer i=0 ; i<dataString.split('~').size() ; i++){
                dataMap.put(headerString.split('~')[i],dataString.split('~')[i]);
            }
            //system.debug('dataMap '+dataMap);
            if(dataMap.get('skuNumber')!=NULL && dataMap.get('skuNumber')!='')
				skuNumber = dataMap.get(skuNumber);
			if(dataMap.get('skuDescription')!=NULL && dataMap.get('skuDescription') != '')
				skuDescription = dataMap.get('skuDescription');
			if(dataMap.get('Sku_Duration')!=NULL && dataMap.get('Sku_Duration') != '')
				Sku_Duration = Decimal.valueOf(dataMap.get('Sku_Duration'));
            if(dataMap.get('Distinct')!=NULL && dataMap.get('Distinct') != ''){
                Distinct = (! string.isBlank(dataMap.get('Distinct')) && dataMap.get('Distinct') != '0')?true:false;
            }
            if(dataMap.get('Practice')!=NULL && dataMap.get('Practice') != '')
				Practice = dataMap.get('Practice');
			if(dataMap.get('Phase')!=NULL && dataMap.get('Phase') != '')
				Phase = dataMap.get('Phase');
			if(dataMap.get('TaskName')!=NULL && dataMap.get('TaskName') != '')
				TaskName = dataMap.get('TaskName');
			if(dataMap.get('Role')!=NULL && dataMap.get('Role') != '')
				Role = dataMap.get('Role');
			if(dataMap.get('ProjectComplexity')!=NULL && dataMap.get('ProjectComplexity') != '')
				ProjectComplexity = dataMap.get('ProjectComplexity');
            if(dataMap.get('EstimatedHours')!=NULL && dataMap.get('EstimatedHours') != ''){
                EstimatedHours = Decimal.valueOf(dataMap.get('EstimatedHours'));
            }else{
                EstimatedHours=0;
            }
			if(dataMap.get('SkillCertification')!=NULL && dataMap.get('SkillCertification') != '')
				SkillCertification = dataMap.get('SkillCertification');
			if(dataMap.get('WODescription')!=NULL && dataMap.get('WODescription') != '')
				WODescription = dataMap.get('WODescription');
			if(dataMap.get('DeliveryMethod')!=NULL && dataMap.get('DeliveryMethod') != '')
				DeliveryMethod = dataMap.get('DeliveryMethod');
			if(dataMap.get('CalculationType')!=NULL && dataMap.get('CalculationType') != '')
				CalculationType = dataMap.get('CalculationType');
			if(dataMap.get('Duration')!=NULL && dataMap.get('Duration') != '')
				Duration = Decimal.valueOf(dataMap.get('Duration'));
			if(dataMap.get('Threshold')!=NULL && dataMap.get('Threshold') != '')
				Threshold = Decimal.valueOf(dataMap.get('Threshold'));
			if(dataMap.get('BelowThreshold')!=NULL && dataMap.get('BelowThreshold') != '')
				BelowThreshold = Decimal.valueOf(dataMap.get('BelowThreshold'));
			if(dataMap.get('AboveThreshold')!=NULL && dataMap.get('AboveThreshold') != '')
				AboveThreshold = Decimal.valueOf(dataMap.get('AboveThreshold'));
			if(dataMap.get('ScheduleType')!=NULL && dataMap.get('ScheduleType') != '')
				ScheduleType = dataMap.get('ScheduleType');
			if(dataMap.get('RecordType')!=NULL && dataMap.get('RecordType') != '')
				RecordType = dataMap.get('RecordType');
			if(dataMap.get('DPSType')!=NULL && dataMap.get('DPSType') != '')
				DPSType = dataMap.get('DPSType');
			if(dataMap.get('WOCreatePhase')!=NULL && dataMap.get('WOCreatePhase') != '')
				WOCreatePhase = dataMap.get('WOCreatePhase');
            if(dataMap.get('callType')!=NULL && dataMap.get('callType') != '')
				callType = dataMap.get('callType');
            if(dataMap.get('onDemand')!=NULL && dataMap.get('onDemand') != ''){
                onDemand = (! string.isBlank(dataMap.get('onDemand')) && dataMap.get('onDemand') != '0')?true:false;
            }
			if(dataMap.get('residency')!=NULL && dataMap.get('residency') != ''){
                residency = (! string.isBlank(dataMap.get('residency')) && dataMap.get('residency') != '0')?true:false;
            }
        //}
            
	}
    public class SkuMap{
		public string skuDescription;
		public integer Sku_Duration;
		public boolean Distinct;
		public string Practice;
	}
}