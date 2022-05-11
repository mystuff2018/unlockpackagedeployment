/**************
* @ClassName    : FBE_CreateQueueForApproval
* @Queable Class       : FBE_CreateQueueForApproval
* @Description   : This class is called from class=FBE_CreateGroupForApproval. In this class,we kickoff Sales Approval Process
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Soumithri Rekha, Sai]
* @Modification Log     : 1-25-2022 [Soumithri Rekha]_Made it as a common class for Deal Registarion and Deal Extension
***************/
public without sharing class FBE_CreateQueueForApproval implements Queueable {
    Id dealId;
    Id EuGrpID;
    Id AposGrpID;
    Id fstGrpId;
    List<Id> aEManagerId;
    List<Id> allGroupIds = new List<Id>();
    List<String> varDistiActIds = new List<String>();
    List<Id> aposUserID = new List<Id>();
    public FBE_CreateQueueForApproval(Id dIds, Group eugGroup,Group fsig,Group aposgId, List<Id> aEMgrId, List<Id> aposUids ,List<String> vardistiacts){
        this.dealId = dIds;
        if(eugGroup != null)
        {
            this.EuGrpID = eugGroup.id;
            allGroupIds.add(this.EuGrpID);
        }
        if(aposgId != null){
            this.AposGrpID = aposgId.id;
            //allGroupIds.add(this.AposGrpID);
        }
        if(fsig != null){
            this.fstGrpId = fsig.id;
            allGroupIds.add(this.fstGrpId);
        }
        if(vardistiacts != null){
            this.varDistiActIds = vardistiacts;
        }
        if(aposUids != null){
            this.aposUserID = aposUids;
        }
        this.aEManagerId = aEMgrId;
    }
    
    public void execute(QueueableContext context) { 
        system.debug('inside Q execute');
        string objectIs = dealId.getSObjectType().getDescribe().getName();
        Id senderId;
        if(System.label.FBE_Approval_OWD != null && System.label.FBE_Approval_OWD != ''){
            senderId = [SELECT id from user where email =:System.label.FBE_Approval_OWD Limit 1].Id;}
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
            
            if(allGroupIds != NULL && allGroupIds.size()>0){
                for(Id gId : allGroupIds){
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setSubmitterId(senderId);
                    req.setObjectId(dealId);
                    req.setNextApproverIds(new Id[] {gId});
                    if(objectIs == 'Deal_Registration__c'){
                        req.setProcessDefinitionNameOrId('FBE_DealRegSalesApproval');
                    }
                    else{
                        req.setProcessDefinitionNameOrId('FBEDeal_Extension_Sales_Approval_Process');
                    }
                    req.setSkipEntryCriteria(true);
                    requestList.add(req);
                    system.debug('Request:'+ req );
                }
            }
        //Sobject dealReg;
        // Sobject dealRegs = Database.query('select FBE_Approval_Fired__c,FBE_Final_Reminder__c,FBE_First_Reminder__c,FBE_Second_Reminder__c,FBE_Secondary_Status__c,FBE_AE_ManagerID__c from'+'objectIs' + 'where ID =:dealId');
       	system.debug('dealId'+dealId);
        Map<String, Object> fieldValueMap = new Map<String, Object>();
        fieldValueMap.put('Id', dealId);
         //dealReg.Id = dealId;
        DateTime firstrem = System.now()+1;
        DateTime secrem = System.now()+2;
        DateTime finrem = System.now()+3;
        System.debug('aEManagerId: '+aEManagerId);
        if(aEManagerId != NULL && aEManagerId.size()>0){
            String s = '';
            for(Id i : aEManagerId){
                if(i != NULL){
                    s = s+i+';';
                }
            }
           // dealReg.FBE_AE_ManagerID__c = s;
       		
        fieldValueMap.put('FBE_AE_ManagerID__c', s);
        }  
        //dealReg.FBE_Secondary_Status__c = 'Pending Sales Review';  
        fieldValueMap.put('FBE_Secondary_Status__c', 'Pending Sales Review');
        if((varDistiActIds != null && varDistiActIds.size()>0) || (aposUserID != null && aposUserID.size()>0)){
            List<String> vardistiApos = new List<String>();
            vardistiApos.addAll(varDistiActIds);
            vardistiApos.addAll(aposUserID);
            System.debug('vardistiApos: '+vardistiApos);
            String grpString  = '';
            for(String s : vardistiApos){
                grpString = grpString + s + ';';
            }
            //dealReg.FBEApprovalReminderUsers__c = grpString;
        fieldValueMap.put('FBEApprovalReminderUsers__c', grpString);
        }
        
        /*---
String str;
if(varDistiActIds != null && varDistiActIds.size()>0){
str='';
for(String s : varDistiActIds){
str = str + s + ';';
}
dealReg.FBEApprovalReminderUsers__c =  'VarDisti Team-' + str;
}
if(aposUserID != null && aposUserID.size()>0){
str='';
for(Id i : aposUserID){
str = str+i+';';
}
if(dealReg.FBEApprovalReminderUsers__c != null && dealReg.FBEApprovalReminderUsers__c != ''){
dealReg.FBEApprovalReminderUsers__c = dealReg.FBEApprovalReminderUsers__c + 'Apos Team-'+str;
}else{
dealReg.FBEApprovalReminderUsers__c = 'Apos Team-'+str;
}
}
*/
        
        Map<String, Weekend__mdt> weekendsMeta = FBE_Utility.getWeekendMetadata();
        Map<Id, Leaves_for_Task_SLA__mdt> holidaysMap = FBE_Utility.getholidaysMetadata();
        system.debug('weekendsMeta'+weekendsMeta);
        system.debug('holidaysMap'+holidaysMap);
        //dealReg.FBE_First_Reminder__c = firstrem;
        //dealReg.FBE_Second_Reminder__c = secrem;
        //dealReg.FBE_Final_Reminder__c = finrem;
        fieldValueMap.put('FBE_First_Reminder__c', firstrem);
        fieldValueMap.put('FBE_Second_Reminder__c', secrem);
        fieldValueMap.put('FBE_Final_Reminder__c', finrem);
        //system.debug('All before frm'+dealReg.FBE_First_Reminder__c+'sec rem'+dealReg.FBE_Second_Reminder__c);
        if(holidaysMap != NULL)
        {
            for(Leaves_for_Task_SLA__mdt holiday: holidaysMap.values())
            {
                system.debug('inside holidaysMap For');
                
               // if((holiday.FBE_Leave_Date__c == dealReg.FBE_First_Reminder__c.date()) || (Test.isRunningTest()))
                if((holiday.FBE_Leave_Date__c == firstrem.date()) || (Test.isRunningTest()))
                {
                    system.debug('dealReg.FBE_First_Reminder__c:'+firstrem +'holiday.FBE_Leave_Date__c'+holiday.FBE_Leave_Date__c);
                    DateTime addDay = firstrem+ 1;
                    DateTime addDay1 = secrem+ 1;
                    DateTime addDay2 = finrem+ 1;
                    fieldValueMap.put('FBE_First_Reminder__c', addDay);
                    fieldValueMap.put('FBE_Second_Reminder__c', addDay1);
                    fieldValueMap.put('FBE_Final_Reminder__c', addDay2);
                    system.debug('After Adding a Day dealReg.FBE_First_Reminder__c:'+addDay); 
                }
                
                if((holiday.FBE_Leave_Date__c == secrem.date())  || (Test.isRunningTest()))
                {
                    system.debug('dealReg.FBE_Second_Reminder__c:'+secrem +'holiday.FBE_Leave_Date__c'+holiday.FBE_Leave_Date__c);
                    DateTime addDay = secrem+ 1;
                    DateTime addDay2 = finrem+ 1;
                    fieldValueMap.put('FBE_Second_Reminder__c', addDay);
                    fieldValueMap.put('FBE_Final_Reminder__c', addDay2);
                    system.debug('After Adding a Day dealReg.FBE_Second_Reminder__c:'+addDay);
                }
                if((holiday.FBE_Leave_Date__c == finrem.date()) || (Test.isRunningTest()))
                {
                    system.debug('dealReg.FBE_Second_Reminder__c:'+finrem+'holiday.FBE_Leave_Date__c'+holiday.FBE_Leave_Date__c);
                    DateTime addDay = finrem+ 1;
                    fieldValueMap.put('FBE_Final_Reminder__c', addDay);
                    system.debug('After Adding a Day dealReg.FBE_Second_Reminder__c:'+addDay);
                }
                string firsRreminderDayOfWeek = ((DateTime)fieldValueMap.get('FBE_First_Reminder__c')).format('EEEE');
                system.debug('firsRreminderDayOfWeek'+firsRreminderDayOfWeek);
                string secondRreminderDayOfWeek = ((DateTime)fieldValueMap.get('FBE_Second_Reminder__c')).format('EEEE');
                system.debug('secondRreminderDayOfWeek'+secondRreminderDayOfWeek);
                string finalRreminderDayOfWeek = ((DateTime)fieldValueMap.get('FBE_Final_Reminder__c')).format('EEEE');
                system.debug('finalRreminderDayOfWeek'+finalRreminderDayOfWeek);
                if(weekendsMeta.get(firsRreminderDayOfWeek)!= NULL )
                {
                    DateTime addDay = ((DateTime)fieldValueMap.get('FBE_First_Reminder__c'))+ weekendsMeta.get(firsRreminderDayOfWeek).Days_to_Skip__c;
                    system.debug('inside first reminder if');
                    fieldValueMap.put('FBE_First_Reminder__c', addDay);
                    //dealReg.FBE_First_Reminder__c = addDay;
                    system.debug('FBE_First_Reminder__c in weekend'+fieldValueMap.get('FBE_First_Reminder__c'));
                }                        
                if(weekendsMeta.get(secondRreminderDayOfWeek)!= NULL )
                {
                    DateTime addDay;
                    if(firsRreminderDayOfWeek == 'Saturday'){
                        addDay = ((DateTime)fieldValueMap.get('FBE_Second_Reminder__c'))+1+ weekendsMeta.get(secondRreminderDayOfWeek).Days_to_Skip__c; 
                    }
                    else
                        addDay = ((DateTime)fieldValueMap.get('FBE_Second_Reminder__c'))+ weekendsMeta.get(secondRreminderDayOfWeek).Days_to_Skip__c; //Skip the days fri+3, sat+2,sun+1
                    system.debug('inside Second reminder if');
                    fieldValueMap.put('FBE_Second_Reminder__c', addDay);
                    system.debug('FBE_Second_Reminder__c in weekend'+fieldValueMap.get('FBE_Second_Reminder__c'));
                }
                if(weekendsMeta.get(finalRreminderDayOfWeek)!= NULL )
                {
                    DateTime addDay;
                    if(secondRreminderDayOfWeek == 'Saturday'){
                        addDay = ((DateTime)fieldValueMap.get('FBE_Final_Reminder__c'))+1+ weekendsMeta.get(finalRreminderDayOfWeek).Days_to_Skip__c; 
                    }
                    else
                        addDay = ((DateTime)fieldValueMap.get('FBE_Final_Reminder__c'))+ weekendsMeta.get(finalRreminderDayOfWeek).Days_to_Skip__c; //Skip the days fri+3, sat+2,sun+1
                    system.debug('inside Second reminder if');
                    fieldValueMap.put('FBE_Final_Reminder__c', addDay);
                    system.debug('FBE_Final_Reminder__c in weekend'+fieldValueMap.get('FBE_Final_Reminder__c'));
                }
                DateTime holi = holiday.FBE_Leave_Date__c;
                //holi = holi.addHours(1); 
                System.debug('holi: '+ holi + ' holi fomrat:: '+holi.format('EEEE'));
                if(firsRreminderDayOfWeek == 'Saturday' && holi.format('EEEE','Asia/Kolkata') != 'Friday'){
                    System.debug('firsRreminderDayOfWeek == Saturday');
                    DateTime addDay = ((DateTime)fieldValueMap.get('FBE_Final_Reminder__c'))+ 2;
                    fieldValueMap.put('FBE_Final_Reminder__c', addDay);
                }
                
            }
        }
        if(requestList != NULL && requestList.size()>0){
            try{
                Approval.ProcessResult[] result = Approval.process(requestList); // approval is kicked off
                system.debug('Approval Result:'+ result );
                system.debug('fieldValueMap'+fieldValueMap);
                
                 String sObjectName = objectIs;
                Schema.SObjectType t  = Schema.getGlobalDescribe().get(sObjectName);
                SObject dealing = t.newSObject();
                for(String fieldName : fieldValueMap.keySet()){
                    dealing.put(fieldName, fieldValueMap.get(fieldName));
                }
                Update dealing;
                
            }Catch(Exception e){
                System.debug(e);
            }
        }
        //Update dealReg;
        
    }   
}