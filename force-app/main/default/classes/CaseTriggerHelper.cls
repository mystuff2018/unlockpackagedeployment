/*
*@ Class Name                                                    : CaseTriggerHelper 
*@ Description                                                   : case trigger helper
*@ CreatedBy                                                     : Deloitte Consulting
*@ Modification Log                                              : 13-12-2019 [AK] Fire assignment rules for integration cases;12-03-2020 [Chaitanya Gayapu] emailToCaseFieldsUpdate;  04-04-2020 [GC] emailToCaseFieldsUpdate; 09-07-2020 [Rakesh] Added shareCaseToSubmitter,updateSubmitter Methods; 
                                                                  12/23/2020 -Sireesha Myla[Story#8817647], Feb 24th 2021-Sireesha Myla[Story#9489610 - BDD2], Defect 10229208 - Sireesha Myla
                                                                  04/26/2021 - [Siva Kumar Valluru]- Renamed the Arc Engagement Request(Case Recordtype Name) into DCWS Engagement Request as per Story #10416631
*/
Public with sharing class CaseTriggerHelper {
    public static CaseTeamRole role = [select Id from CaseTeamRole where Name = :'Case Submitter' limit 1];
    public static void emailToCaseFieldsUpdate(List<Case> newList){
        ID supportReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FBE Support Request').getRecordTypeId();
        Set<Id> queueIds = new Set<Id>();
        for(Case c : newList){
            if(c.ownerid.getsobjecttype() == Group.SobjectType){
                queueIds.add(c.ownerid);
            }
        }   
        Map<Id,Group> queueIdWithName = new Map<Id,Group>([SELECT Id,name from Group where type='Queue'  AND Id IN : queueIds]);
        for(Case c : newList){
            if(c.origin == 'Email' && c.recordtypeId == supportReqRecId ){
                system.debug('@@@21');
                if(queueIdWithName.containsKey(c.OwnerId) && queueIdWithName.get(c.OwnerId).name == 'FBE Production Support' ){
                    system.debug('@@@23'+queueIdWithName.get(c.OwnerId).name);
                        System.debug('inside War room');
                        c.type = 'FBE Production Support';
                        c.FBE_Issue_Classification__c = 'Other';
                    
                }else {
                    System.debug('inside general Inquiry');
                    c.type = 'General Inquiry';
                }
                system.debug('@@@32'+c.type);
            }
        }
    }
    
   public static void updateAccountField(List<Case> newList){
        Id serviceCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();

        Set<Id> oppIds = new Set<Id>();
        for(Case c : newList){
            if((serviceCaseId != c.RecordTypeId) && c.FBE_Opportunity_Name__c != NULL && c.AccountId == NULL){
                oppIds.add(c.FBE_Opportunity_Name__c);
            }
        }
        Map<Id,Id>  oppIdwithActId = new Map<Id,Id>();
        for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN : oppIds]){
            oppIdwithActId.put(opp.Id , opp.AccountId);
        }
        for(Case c : newList){
            if((serviceCaseId != c.RecordTypeId) && oppIdwithActId.containsKey(c.FBE_Opportunity_Name__c)){
                c.AccountId = oppIdwithActId.get(c.FBE_Opportunity_Name__c);
            }
        }
    }
    
    //Method updated by Uttam Kavitkar to Update submitter field on case creation
     public static void updateSubmitter(List<Case> newCaseList){
         //FeatureManagement.checkPermission('FBE_FPRM_Skip_Process_Builder');
         Boolean isFPRMUser = FeatureManagement.checkPermission('FBE_FPRM_Skip_Process_Builder');
         
        Id serviceCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        for(Case c : newCaseList){
            if(c.origin != 'Email' && (serviceCaseId != c.RecordTypeId)){
                if(isFPRMUser = false && !UserInfo.getName().contains('Boomi Prod IntUser') && c.FBE_Case_Submitter__c == NULL){
                    system.debug('current userId : ' + UserInfo.getUserId()); 
                    c.FBE_Case_Submitter__c = UserInfo.getUserId();
                }  
            }
        }   
         
    }


    /* Method added by Abhishek Kawle to fire assignment Rules for Integration cases */ 
    @future
    public static void fireAssignmentRulesOnCases(List<Id> lstCaseIds) {
           
        List<Case> newList = [Select Id,RecordTypeId,FBE_Assign_using_active_assignment_rules__c,Origin from Case 
                              where Id IN : lstCaseIds];
        List<Case> lstCasesToUpdate = new List<Case>();
        //Create a DMLOption for assignment using active rule
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        //dmlOpts.EmailHeader.triggerAutoResponseEmail = true; 
        dmlOpts.EmailHeader.triggerUserEmail = true; 
        Id recTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Partner_Support_Request').getRecordTypeId();
        //Pramith: 08/07/2020: Modified for Feature#7622821 for Fed Premier Support
        Id eSalesRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Federal_Premier_Support').getRecordTypeId();
        User userRec = [select id,FBE_Integration_User__c,ContactId from User where id =: UserInfo.getUserId() limit 1];
        if(recTypeID != null && eSalesRecTypeID != null){  
            for(Case c : newList){
                if((c.RecordTypeId == recTypeID || c.RecordTypeId == eSalesRecTypeID) && c.FBE_Assign_using_active_assignment_rules__c == true) {
                    c.setOptions(dmlOpts);
                    if(userRec != null && (userRec.FBE_Integration_User__c == true || userRec.ContactId != null )  && c.RecordTypeId == recTypeID) //Saumya: 3/1/2021: Modified for Feature#9911769 for SFDC
                        lstCasesToUpdate.add(new Case(Id = c.Id,Origin = 'PRM',FBE_Assign_using_active_assignment_rules__c = false));
                    else if(userRec != null && userRec.FBE_Integration_User__c == true && c.RecordTypeId == eSalesRecTypeID)
                        lstCasesToUpdate.add(new Case(Id = c.Id,Origin = 'eSales',FBE_Assign_using_active_assignment_rules__c = false));
                    else
                        lstCasesToUpdate.add(new Case(Id = c.Id,Origin = 'SFDC',FBE_Assign_using_active_assignment_rules__c = false));
                }
            }
        }
        try {
            Database.update(lstCasesToUpdate,dmlOpts);
        }catch(Exception e) {
            System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        }
    }   
     
    //Method created by Sireesha Myla, Fetch existing Case Teams as part of
    // Defect 10229208: PRODUCTION SFDC Defect Historical Case Submitter sharing - Sireesha Myla
    public static Map<String,CaseTeamMember> getCaseTeams(List<Case> newList)
    {
        Map<String, CaseTeamMember> existingCaseMembers = new Map<String, CaseTeamMember>(); 
        List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>([SELECT MemberId,ParentId from CaseTeamMember where ParentId IN :newList ]);
        if(caseTeamList.size()>0 )
        {
            for(CaseTeamMember cs: caseTeamList)
            {
                existingCaseMembers.put(cs.MemberId+':'+cs.ParentId, cs);
                //Map Key as MemberId(UserId) and ParentId(CaseId) seperated by ':'
            }
        }
        return existingCaseMembers;
    }
    //Defect 10229208: PRODUCTION SFDC Defect Historical Case Submitter sharing - Sireesha Myla
    public static Map<Id,CaseTeamMember> createTeam(Id caseId, Id userId)
    {
        Map<Id, CaseTeamMember> caseTeamMap = new Map<Id, CaseTeamMember>();
         CaseTeamMember csm =  new CaseTeamMember();
            csm.ParentId = caseId;
            csm.MemberId = userId;
            csm.TeamRoleId = role.Id;
            caseTeamMap.put(csm.Id, csm);
        return caseTeamMap;
    }
    
    // Rakesh: 08/13/2020 Modified for story#8908478 to include partner support record type
    // Add Federal Premier Support RecordType- Story 9489610: FBE DFN Salesforce: Fed Premier Case Visibility [Sireesha Myla]
    // Defect 10229208: PRODUCTION SFDC Defect Historical Case Submitter sharing - Sireesha Myla[Prevented Duplicate Case Teams & Bulkified] - [15 March 2021] 
    public static void shareCaseRecord(List<Case> newList , Map<Id,Case> oldMap) {
        ID supportReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FBE Support Request').getRecordTypeId();
        //Story #10416631
        ID dcwsReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DCWS Engagement Request').getRecordTypeId();
        ID partnerReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Partner Support Request').getRecordTypeId();
        ID fedPremierSupRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Federal Premier Support').getRecordTypeId();
        List<CaseTeamMember> caseMemberList = new List<CaseTeamMember>();
        Map<Id,CaseTeamMember> caseTeamMap = new Map<Id,CaseTeamMember>();
        Boolean isFPRMUser = FeatureManagement.checkPermission('FBE_FPRM_Skip_Process_Builder');
        for(Case css : newList){
            if( ((css.RecordTypeId==supportReqRecId && oldMap.get(css.Id).ownerId != css.OwnerId) ||
                (css.RecordTypeId== dcwsReqRecId && oldMap.get(css.Id).ownerId != css.OwnerId) ||
                (css.RecordTypeId== partnerReqRecId && oldMap.get(css.Id).ownerId != css.OwnerId ) ||
                (css.RecordTypeId== fedPremierSupRecId && oldMap.get(css.Id).ownerId != css.OwnerId ))
               && isFPRMUser == false
              )
              {
                  system.debug('#### CreatedBy user Team Access');
                 caseTeamMap = createTeam(css.Id, css.CreatedById);
              }
            
        }
        Map<Id,CaseTeamMember> caseTeamsInsertMap = new Map<Id,CaseTeamMember>();
        Map<String,CaseTeamMember> existingCaseMembers = getCaseTeams(newList);
        if(caseTeamMap.size()>0)
        {
          for(CaseTeamMember ctm: caseTeamMap.values()) 
          {
              String caseKey = ctm.memberId+':'+ctm.ParentId;
              system.debug('#### caseKey '+caseKey);
              if(!existingCaseMembers.containskey(caseKey))
                 caseTeamsInsertMap.put(ctm.Id, ctm); 
          }
        }
        
        if(caseTeamsInsertMap.size()>0){
            try{
                insert caseTeamsInsertMap.values();
                system.debug('#### Case CreatedBy User Map size' +caseTeamsInsertMap.size());
                // Rakesh - [12-08-2020] Invoking shareToAccountTeam Method from here
                shareToAccountTeam(newList); 
            }catch(Exception e){
                System.debug(e);
            }
            
        }
    }
    
    //Rakesh: Added this Method for story#8908478 to provide access for case submitter after case submitter is updated
    // Sharing is not revoked after case submitter field is updated as per the requirement. Hence no unsharing logic created.
    // Added Federal Premier Support RecordType- Story 9489610: FBE DFN Salesforce: Fed Premier Case Visibility [Sireesha Myla]
    // Defect 10229208: PRODUCTION SFDC Defect Historical Case Submitter sharing - Sireesha Myla[Prevented Duplicate Case Teams & Bulkified] - [15 March 2021]
    public static void shareCaseToSubmitter(List<Case> newList , Map<Id,Case> oldMap) {
        ID supportReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FBE Support Request').getRecordTypeId();
        //Story #10416631
        ID dcwsReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DCWS Engagement Request').getRecordTypeId();
        ID partnerReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Partner Support Request').getRecordTypeId();
        ID fedPremierSupRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Federal Premier Support').getRecordTypeId();
        Map<Id,CaseTeamMember> caseTeamMap = new Map<Id,CaseTeamMember>();
        //CaseTeamRole role = [select Id from CaseTeamRole where Name = :'Case Submitter' limit 1];
        Boolean isFPRMUser = FeatureManagement.checkPermission('FBE_FPRM_Skip_Process_Builder');
        for(Case css : newList){
            if((((css.RecordTypeId==supportReqRecId && oldMap.get(css.Id).FBE_Case_Submitter__c != css.FBE_Case_Submitter__c) || (css.RecordTypeId==supportReqRecId && css.FBE_Case_Submitter__c != NULL) )||
               ((css.RecordTypeId==dcwsReqRecId && oldMap.get(css.Id).FBE_Case_Submitter__c != css.FBE_Case_Submitter__c) || (css.RecordTypeId==dcwsReqRecId && css.FBE_Case_Submitter__c != NULL)) ||
               ((css.RecordTypeId==partnerReqRecId && oldMap.get(css.Id).FBE_Case_Submitter__c != css.FBE_Case_Submitter__c) || (css.RecordTypeId==partnerReqRecId && css.FBE_Case_Submitter__c != NULL)) ||
               ((css.RecordTypeId==fedPremierSupRecId && oldMap.get(css.Id).FBE_Case_Submitter__c != css.FBE_Case_Submitter__c) || (css.RecordTypeId==fedPremierSupRecId && css.FBE_Case_Submitter__c != NULL))) 
               && isFPRMUser == false
              )
              {
                 system.debug('#### Case Submitter User access' );
                 caseTeamMap = createTeam(css.Id, css.FBE_Case_Submitter__c);               
              }
            
        }
        Map<Id,CaseTeamMember> caseTeamsInsertMap = new Map<Id,CaseTeamMember>();
        Map<String,CaseTeamMember> existingCaseMembers = getCaseTeams(newList);
        if(caseTeamMap.size()>0)
        {
          for(CaseTeamMember ctm: caseTeamMap.values()) 
          {
              String caseKey = ctm.memberId+':'+ctm.ParentId;
              system.debug('#### caseKey '+caseKey);
              if(!existingCaseMembers.containskey(caseKey))
                 caseTeamsInsertMap.put(ctm.Id, ctm); 
          }
        }
        
        if(caseTeamsInsertMap.size()>0){
            try{
                system.debug('#### Case Submitter Insert Map size' +caseTeamsInsertMap.size());
                insert caseTeamsInsertMap.values();
            }catch(Exception e){
                System.debug(e);
            }
            
        }
    }
    
    // Rakesh: 08/13/2020 created this method for story#8908478 to Auto-populate Case Submitter Field 
   /* public static void updateSubmitter(List<Case> newCaseList){
        Id serviceCaseId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        List<Case> updList = new List<Case>();        
        List<Case> newList = [SELECT Id,origin,suppliedEmail,CreatedById,CreatedBy.Name,FBE_Case_Submitter__c FROM Case WHERE Id IN : newCaseList and RecordTypeId != :serviceCaseId];
        System.debug('newList: '+newList);
        for(Case c : newList){
            if(c.origin != 'Email' && (c.FBE_Case_Submitter__c == NULL  || c.FBE_Case_Submitter__c != NULL)){
                system.debug('Boomi User' +c.CreatedBy.name);
                if(! c.CreatedBy.name.contains('Boomi Prod IntUser')){
                    system.debug('c.FBE_Case_Submitter__c : ' +c.FBE_Case_Submitter__c);
                    if(c.FBE_Case_Submitter__c != NULL){
                        updList.add(c);
                    }   
                    if(c.FBE_Case_Submitter__c == NULL ){
                        c.FBE_Case_Submitter__c = c.createdById;
                        updList.add(c);
                    }
                }  
            }
        }   
        System.debug('updList: '+updList);
        System.debug('updList.size() '+updList.size());
            if(updList.size()>0){
                try{
                    UPDATE updList;
                }
                catch(Exception e){
                    System.debug('Exception : '+e);
                }
            }
    }*/
  
    //Rakesh - [12/08/2020] story#9015984 When a partner case is created, 'ShareToAccountTeam' Method grants 'Read' access to the associated AccountTeam Members
    public static void shareToAccountTeam(List<Case> newList){
        ID partnerReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Partner Support Request').getRecordTypeId();
        List<Id> accountIds =  new List<Id>();
        List<case> partnercaseList = new List<case>(); 
        Map<Id,set<Id>> MapofAcctoAccTeam = new Map<Id,set<Id>>();
        
        for(case cse : newList){
            if(cse.RecordTypeId==partnerReqRecId){
                partnercaseList.add(cse);
                accountIds.add(cse.AccountId);
            }            
        }
        
        List<AccountTeamMember> accTeam = [SELECT Id, AccountId, UserId, TeamMemberRole 
                                           FROM AccountTeamMember 
                                           WHERE AccountId IN : accountIds];
        
        system.debug('accTeam ' +accTeam);
        
        if(accTeam != NULL){
            for(AccountTeamMember atm : accTeam){
                if(!MapofAcctoAccTeam.keySet().contains(atm.AccountId)){
                    MapofAcctoAccTeam.put(atm.AccountId, new set<Id>{atm.UserId});
                }
                MapofAcctoAccTeam.get(atm.AccountId).add(atm.UserId);
            }     
        }        
        system.debug('MapofAcctoAccTeam ' +MapofAcctoAccTeam);  
        List<CaseShare> CaseShareRecordList = new List<CaseShare>();
        CaseShare CaseShareRecord;
        for(case css : partnercaseList){
            if(MapofAcctoAccTeam.containsKey(css.AccountId)){
            for(Id atmUserId : MapofAcctoAccTeam.get(css.AccountId)){
                CaseShareRecord=new CaseShare();
                CaseShareRecord.CaseId=css.Id;
                CaseShareRecord.UserOrGroupId= atmUserId;
                CaseShareRecord.CaseAccessLevel='Read';
                CaseShareRecordList.add(CaseShareRecord);
              }
            }
        }
        if(CaseShareRecordList.size()>0){
            try{
                insert CaseShareRecordList;
            }catch(Exception e){
                System.debug(e);
            }
            
        }
        
    }
    
    //[Story#8817647]-BDD7
    public static void emailNotificationifNoCaseModifiedUpdate(List<Case> newRecords,List<Case> oldRecords)
    {
        
        Map<String, Weekend__mdt> weekendsMeta = FBE_Utility.getWeekendMetadata();
        Map<Id, Leaves_for_Task_SLA__mdt>holidaysMap = FBE_Utility.getholidaysMetadata();
        List<Case> caseMapToUpdate = new List<Case>();
        ID supportReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FBE Support Request').getRecordTypeId();
        DateTime noActvitysetDate ;
        
        Map<Integer, String> countSLAdaysMap = new Map<Integer, String>();
              countSLAdaysMap.put(5,'Monday;Tuesday;Wednesday;Thursday;Friday');
              countSLAdaysMap.put(4,'Tuesday;Wednesday;Thursday;Friday');
              countSLAdaysMap.put(3,'Wednesday;Thursday;Friday');
              countSLAdaysMap.put(2,'Thursday;Friday');
              countSLAdaysMap.put(1,'Friday');
        
        for(Case newCase: newRecords) 
        {
            String dayOfWeek = System.now().format('EEEE');
            system.debug(' &&day case modified &&'+dayOfWeek);     
            // DateTime noActvitysetDate ;
            DateTime caseLastModDate = System.now();
            Time timeToSetup = Time.newInstance(9,0,0,0);
            // Time caseUpdatedTime = caseLastModDate.time();
            if(oldRecords !=null ||
               (oldRecords == null && newCase.RecordTypeId == supportReqRecId)  )                   
            {
                //Verify Saturday,Sunday  
                if(weekendsMeta.get(dayOfWeek)!= NULL )
                {
                    DateTime addDay = caseLastModDate + weekendsMeta.get(dayOfWeek).Days_to_Skip__c; //Skip the days fri+3, sat+2,sun+1
                    noActvitysetDate = addDay + 3 ;
                    system.debug('&&&& if weekened then skip weeked, add three days'+noActvitysetDate);
                }
                else if(!weekendsMeta.containsKey(dayOfWeek) )
                {
                    noActvitysetDate = caseLastModDate + 3;
                    system.debug('&&&& if no weekened then add three days'+noActvitysetDate);
                }
                else if(!countSLAdaysMap.isEmpty() && countSLAdaysMap.get(3)!=null && countSLAdaysMap.get(3).contains(dayOfWeek))
                {
                    noActvitysetDate = caseLastModDate + 3 + 2;
                }
                
                //noActvitysetDate =  newCase.LastModifiedDate + 3; 
                // Skip public Holiday falls
                if(noActvitysetDate != null && holidaysMap != NULL)
                {
                    for(Leaves_for_Task_SLA__mdt holiday: holidaysMap.values())
                    {
                        if(holiday.FBE_Leave_Date__c >= caseLastModDate.Date() && holiday.FBE_Leave_Date__c <= noActvitysetDate.date() )
                        {
                            noActvitysetDate = noActvitysetDate + 1; 
                            system.debug('public holiday Skip&&&'+noActvitysetDate);
                        }
                        if(noActvitysetDate != null && weekendsMeta.containsKey(noActvitysetDate.format('EEEE')))
                        {
                            noActvitysetDate = noActvitysetDate + weekendsMeta.get(noActvitysetDate.format('EEEE')).Days_to_Skip__c;
                            system.debug('public holiday Skip and check any weekend again %% &&&'+noActvitysetDate);
                        }
                    }
                } 
                
                if(noActvitysetDate != null && noActvitysetDate.time() <= timeToSetup){
                    newCase.FBE_Inactivity_Notification_Date__c = noActvitysetDate;  
                    system.debug('&&& Final Inactivity days to update'+newCase.FBE_Inactivity_Notification_Date__c);
                }
               
                // Adding Logic to Handle Cases that fall after 9am
                
                else if(noActvitysetDate != null && noActvitysetDate.time() > timeToSetup){
                    noActvitysetDate = noActvitysetDate + 1;
                    system.debug('&&& Adding 1 day for post 9am cases ' +noActvitysetDate);
                    //newCase.FBE_Inactivity_Notification_Date__c = noActvitysetDate;
                    String updatedDay = noActvitysetDate.format('EEEE');
                    //Verify Saturday,Sunday  
                    if(weekendsMeta.get(updatedDay)!= NULL )
                    {
                        DateTime addDay = noActvitysetDate + weekendsMeta.get(updatedDay).Days_to_Skip__c; //Skip the days fri+3, sat+2,sun+1
                        noActvitysetDate = addDay ;
                        system.debug('&&&& if weekened then skip weeked for 9am case '+noActvitysetDate);
                    }
                    // Skip public Holiday falls
                    if(noActvitysetDate != null && holidaysMap != NULL)
                    {
                        for(Leaves_for_Task_SLA__mdt holiday: holidaysMap.values())
                        {
                            if(holiday.FBE_Leave_Date__c == noActvitysetDate.date() )
                            {
                                noActvitysetDate = noActvitysetDate + 1; 
                                system.debug('public holiday Skip for 9am case &&& '+noActvitysetDate);
                            }
                            if(noActvitysetDate != null && weekendsMeta.containsKey(noActvitysetDate.format('EEEE')))
                            {
                                noActvitysetDate = noActvitysetDate + weekendsMeta.get(noActvitysetDate.format('EEEE')).Days_to_Skip__c;
                                system.debug('public holiday Skip and check any weekend again for 9am case %% &&& '+noActvitysetDate);
                            }
                        }
                    }
                    
                    //if(noActvitysetDate != null && noActvitysetDate.time() <= timeToSetup){
                    if(noActvitysetDate != null){
                        newCase.FBE_Inactivity_Notification_Date__c = noActvitysetDate;                     
                        system.debug('&&& Final Inactivity days to update after 9am'+newCase.FBE_Inactivity_Notification_Date__c);
                    }                    
                }             
            }  
        }
        
    }
    
    
}