public class IDS_SKU_Loader_Logic {
    public static void ids_SKu_Loader(List<SKU_Effort_Map__c> SkuList){
        //List<SKU_Effort_Map__c> SkuList = (List<SKU_Effort_Map__c>) JSON.deserialize(SkuListJson, List<SKU_Effort_Map__c>.class);
        Map<String,Id> projTask = new Map<String,Id>();
        Map<String,Id> skillCert = new Map<String,Id>();
        Map<String,Id> dpsType = new Map<String,Id>();
		Map<String,pse__Skill__c> skillNameWithId = new Map<String,pse__Skill__c>();
		Map<String,String> woWithSkill = new Map<String,String>();
		List<Skill_SKU_Effort_Map_Entry__c> skillSkuToUpsert = new List<Skill_SKU_Effort_Map_Entry__c>();
		List<SKU_Effort_Map__c> skuMapToUpsert = new List<SKU_Effort_Map__c>();
		Map<STRING,ID> practiceNameWithTemplateId = new Map<STRING,ID>();
		Map<STRING,pse__Practice__c> practiceNameWithId = new Map<STRING,pse__Practice__c>();
		Map<ID,List<pse__Project_Task__c>> templateWithTasks = new Map<ID,List<pse__Project_Task__c>>();
        set<ID> templateIds = new set<ID>();
		for(pse__Practice__c practices :[select id, name,Standard_Project_Template__c from pse__Practice__c]){
			practiceNameWithId.put(practices.Name,practices);
			//system.debug('practiceNameWithId '+practices.Name+'____'+practices.Standard_Project_Template__c);
		}
        
        for(SKU_Effort_Map__c skuMap : SkuList){
            IDS_DataLoaderWrapper wrapData = new IDS_DataLoaderWrapper(skuMap.IDS_SKU_Combination__c.split('\r')[0]);
			skuMap.Distinct_Project__c = wrapData.Distinct;
			skuMap.Residency__c = wrapData.residency;
			skuMap.Duration_Days__c = wrapData.Sku_Duration;
			if(practiceNameWithId.get(wrapData.Practice)!=NULL){
				skuMap.Practice__c = practiceNameWithId.get(wrapData.Practice).Id;
                if(practiceNameWithId.get(wrapData.Practice).Standard_Project_Template__c != NULL)
                	templateIds.add(practiceNameWithId.get(wrapData.Practice).Standard_Project_Template__c);
			}
			skuMapToUpsert.add(skuMap);
			
			system.debug('templateIds '+templateIds);
        }
        /*******************************************/
        if(skuMapToUpsert.size() > 0){
			database.update(skuMapToUpsert,false);
		}
		/*******************************************/
		for(Pse__Proj__c phasedProj : [Select id,(select id,Name from pse__Project_Tasks__r) from Pse__Proj__c where ID IN : templateIds]){
			templateWithTasks.put(phasedProj.id,phasedProj.pse__Project_Tasks__r);
		}
		system.debug('templateWithTasks '+templateWithTasks);
		/*for(pse__Project_Task__c prjTask : phasedProj.pse__Project_Tasks__r){
			projTask.put(prjTask.Name,prjTask.Id);
		}
		system.debug('projTask '+projTask);*/
		/*******************************************/
        for(pse__Skill__c skilCert : [select id,name from pse__Skill__c]){
            skillCert.put(skilCert.Name,skilCert.Id);
        }
        /*******************************************/
		for(DPS_Type__c dps : [select id,name from DPS_Type__c]){
			dpsType.put(dps.Name,dps.Id);
		}
		/*******************************************/
		for(pse__Skill__c skills : [select id, name from pse__Skill__c]){
			skillNameWithId.put(skills.Name,skills);
		}
        Map<ID,STRING> skuWithSkuNumbers = new Map<ID,STRING>();
        Map<ID,SKU_Effort_Map__c> skuIdwithDescription = new Map<ID,SKU_Effort_Map__c>();
        Map<STRING,STRING> skuIdWithEntries = new Map<STRING,STRING>();
        List<STRING> preventDuplicateTasks = new List<STRING>();
        List<STRING> preventDuplicateWoSkus = new List<STRING>();
        List<SKU_Effort_Map_Entry__c> entriesToUpsert = new List<SKU_Effort_Map_Entry__c>();
        for(SKU_Effort_Map__c sku : SkuList){
            skuIdwithDescription.put(sku.ID,sku);
            /*<------------ SKU NUMBERS ------------------------->*/
            if(sku.IDS_SKU_Combination__c != NULL){
                //system.debug('sku.IDS_SKU_Combination__c '+sku.IDS_SKU_Combination__c);
                skuWithSkuNumbers.put(sku.ID,(sku.IDS_SKU_Combination__c.split('\r')[0]).split('~')[0]);
            
            
            /*<------------ SKU ENTRIES ------------------------->*/
            for(STRING skuData : sku.IDS_SKU_Combination__c.split('\r')){
                IDS_DataLoaderWrapper wrapData = new IDS_DataLoaderWrapper(skuData);
                if(practiceNameWithId.get(wrapData.Practice) != NULL && practiceNameWithId.get(wrapData.Practice).Standard_Project_Template__c != NULL){
                    if(wrapData.SkillCertification != NULL){
						woWithSkill.put(wrapData.TaskName+'~'+wrapData.skuDescription,wrapData.SkillCertification);
					}
                    system.debug('wrapData '+wrapData.Practice);
                	system.debug('wrapData '+wrapData.Phase);
                    if(! preventDuplicateTasks.contains(wrapData.TaskName)){
                        SKU_Effort_Map_Entry__c skuEntry = new SKU_Effort_Map_Entry__c(
                        Name__c = wrapData.TaskName,
                        Role__c=wrapData.Role,
                        SKU_Effort_Map__c = sku.ID,
                        Project_Complexity_Tier__c=wrapData.ProjectComplexity,
                        Estimated_Hours__c=wrapData.EstimatedHours,
                        FBE_IDS_SKU_Desc_With_TaskName__c=wrapData.TaskName+'~'+wrapData.skuDescription,
                        project__c=practiceNameWithId.get(wrapData.Practice).Standard_Project_Template__c,
                        Phase__c= getIdByPhaseName(templateWithTasks.get(practiceNameWithId.get(wrapData.Practice).Standard_Project_Template__c) ,wrapData.Phase)
                        );
                        preventDuplicateTasks.add(wrapData.TaskName);
                        entriesToUpsert.add(skuEntry);                    
                    }
                }
			}
        }
            preventDuplicateTasks.clear();
        }
        //system.debug('skuWithSkuNumbers '+skuWithSkuNumbers.keySet().Size());
        system.debug('entriesToUpsert '+entriesToUpsert);
        if(! skuWithSkuNumbers.isEmpty()){
            List<SKU_Number__c> skuNumbersToUpsert = new List<SKU_Number__c>();
            for(ID skuId : skuWithSkuNumbers.keySet()){
                for(STRING str : skuWithSkuNumbers.get(skuId).split(';')){
                    SKU_Number__c skuN = new SKU_Number__c();
                	skuN.SKU_Number__c = str;
                    skuN.Sku_Name__c = skuIdwithDescription.get(skuId).Description__c;
                    skuN.SKU_to_Effort_Mapping__c = skuId;
                    skuNumbersToUpsert.add(skuN);
                }
            }
            if(skuNumbersToUpsert.size() > 0){
                //UPSERT skuNumbersToUpsert SKU_Number__c;
                List<Database.upsertResult> skuMapResult = Database.upsert(skuNumbersToUpsert,SKU_Number__c.Fields.SKU_Number__c,false);
            }
        }
        if(entriesToUpsert.size() > 0){
            //UPSERT entriesToUpsert FBE_IDS_SKU_Desc_With_TaskName__c;
            List<Database.upsertResult> skuEntrypResult = Database.upsert(entriesToUpsert,SKU_Effort_Map_Entry__c.Fields.FBE_IDS_SKU_Desc_With_TaskName__c,false);
			List<WO_SKU_Effort_Map__c> woSkuToUpsert = new List<WO_SKU_Effort_Map__c>();
			for(SKU_Effort_Map_Entry__c skuEntry : entriesToUpsert){
				for(STRING str : skuIdwithDescription.get(skuEntry.SKU_Effort_Map__c).IDS_SKU_Combination__c.split('\r')){
					IDS_DataLoaderWrapper wrapData = new IDS_DataLoaderWrapper(str);
					if(wrapData.TaskName != 'PM Time Entry'){
                        if(wrapData.TaskName == skuEntry.Name__c && ! preventDuplicateWoSkus.contains(wrapData.WODescription)){
                            WO_SKU_Effort_Map__c skuWo = new WO_SKU_Effort_Map__c(
                            SKU_Effort_Mapping_Entry__c = skuEntry.id,
                            Description__c=wrapData.WODescription,
                            Delivery_Method__c=wrapData.DeliveryMethod,
                            Calculation_Type__c=wrapData.CalculationType,
                            Duration__c=wrapData.Duration,
                            Threshold_Value__c=wrapData.Threshold,
                            High_Threshold_Duration__c=wrapData.AboveThreshold,
                            Low_Threshold_Duration__c=wrapData.BelowThreshold,
                            Schedule_Type__c=wrapData.ScheduleType,
                            WO_Record_Type__c=wrapData.RecordType,
                            DPS_Type__c=dpsType.containsKey(wrapData.DPSType)?dpsType.get(wrapData.DPSType):NULL,
                            Template__c = practiceNameWithId.get(wrapData.Practice).Standard_Project_Template__c,
                            Event_Type__c = wrapData.TaskName,
                            CallType__c = wrapData.callType,
                            On_Demand_WO_Creation__c = wrapData.onDemand,
                            Phase__c=getIdByPhaseName(templateWithTasks.get(practiceNameWithId.get(wrapData.Practice).Standard_Project_Template__c) ,wrapData.Phase),
                            FBE_IDS_SkuDescWithTaskName__c=wrapData.skuDescription+'~'+wrapData.TaskName+'~'+wrapData.WODescription
                            );
                            system.debug('skuWo '+skuWo);
                            woSkuToUpsert.add(skuWo);
                            preventDuplicateWoSkus.add(wrapData.WODescription);
                        }
					}
				}
				preventDuplicateWoSkus.clear();
				/**************************************************************************************************************/
				if(woWithSkill.containsKey(skuEntry.FBE_IDS_SKU_Desc_With_TaskName__c)){
					for(STRING skillRatingSku : woWithSkill.get(skuEntry.FBE_IDS_SKU_Desc_With_TaskName__c).split(';')){
						if(skillNameWithId.containsKey(skillRatingSku.split(',')[0])){
							Skill_SKU_Effort_Map_Entry__c skillSku = new Skill_SKU_Effort_Map_Entry__c();
							skillSku.Minimum_Rate__c = skillRatingSku.split(',')[1];
							skillSku.Skill_Certification__c = skillNameWithId.get(skillRatingSku.split(',')[0]).ID;
							skillSku.FBE_IDS_Skill_Sku_Entries__c = skuEntry.FBE_IDS_SKU_Desc_With_TaskName__c+'~'+skillRatingSku;
							skillSku.SKU_Effort_Map_Entry__c = skuEntry.Id;
                            skillSkuToUpsert.add(skillSku);
						}
					}
				}
				
 			}
			if(woSkuToUpsert.size() > 0){
				//UPSERT woSkuToUpsert FBE_IDS_SkuDescWithTaskName__c;
				List<Database.upsertResult> woSkuResult = Database.upsert(woSkuToUpsert,WO_SKU_Effort_Map__c.Fields.FBE_IDS_SkuDescWithTaskName__c,false);
			}
			if(skillSkuToUpsert.size() > 0){
				//UPSERT woSkuToUpsert FBE_IDS_SkuDescWithTaskName__c;
				List<Database.upsertResult> woSkuResult = Database.upsert(skillSkuToUpsert,Skill_SKU_Effort_Map_Entry__c.Fields.FBE_IDS_Skill_Sku_Entries__c,false);
			}
        }
    }
	public static ID getIdByPhaseName(List<pse__Project_Task__c> projTasks,STRING PhaseName){
        system.debug('projTasks '+projTasks);
        system.debug('PhaseName '+PhaseName);
		ID phaseId;
		if(projTasks != NULL){
			for(pse__Project_Task__c prjTask : projTasks){
				if(prjTask.Name == PhaseName){
					phaseId = prjTask.ID;
				}
			
			}
		}
		
		system.debug('phaseId '+phaseId);
		return phaseId;
	}
}