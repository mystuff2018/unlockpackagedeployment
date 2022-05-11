/*
      Purpose:
            When possible, set the Project lookup on Service Appointment upon creation, so that all project
            related service appointments will be easily visible to the project manager.
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/13/18

    =============================================================================================================
    Modification History:
    ----------------------------------------------------------------------------------------------------------------
  Name            Date        Company             Description
    ----------------------------------------------------------------------------------------------------------------
  Pawan K         1/8/19      OAC Services INC.   Added Before Updated event to clone
                                                    related Work Orders.
                                                    Method : workOrderCloneController

    Thomas D          2/7/19      FinancialForce.com  Modified workOrderCloneController method
                                                    to make sure the correct Schedule Type is
                                                    set on cloned Work Orders
    
    Luis V        20190612  FF.com        New method to update PSA_Execution_Site_TimeZone__c
                              with converted datetime                                                  
    ----------------------------------------------------------------------------------------------------------------
*/
public class FFServiceAppointmentTriggerHandler extends TriggerHandler {
    public static Boolean preventRecursion = false; // added by tdavis 2019-01-29 - used in the populateAssignment method to prevent unwanted recursion.
    // public static Boolean runOnce = false;
    private static String WORK_ORDER_ID_PREFIX = WorkOrder.SObjectType.getDescribe().getKeyPrefix();

    public Map<Id, ServiceAppointment> TriggerNewMap {get;set;}
    public Map<Id, ServiceAppointment> TriggerOldMap {get;set;}
    public List<ServiceAppointment> TriggerNew {get;set;}
    public List<ServiceAppointment> TriggerOld {get;set;}
	
    //public static Map<Id, WorkOrder> saIdToWOMapNew = new Map<Id, WorkOrder>();
    //public static Map<Id, WorkOrder> saIdToWOMapOld = new Map<Id, WorkOrder>();
    public FFServiceAppointmentTriggerHandler() {
        filterRecordsByRecordType();
    }

    public override void beforeInsert() {
        populateProjectLookup(this.TriggerNew);
       // populateExecutionSiteStartDate(this.TriggerNew);
        setAppointmentType(this.TriggerNew);
        populateTimeZone(this.TriggerNew,null);        
    }

    public override void afterInsert() {
        if (!getClickMdtSettings().Disable_ServiceAppointmentTrigger__c) {
            setNumberField(this.TriggerNew);    
            
        }
        
    }

    public override void beforeUpdate() {
        setAppointmentType(this.TriggerNew);
        workOrderCloneController( this.TriggerNew, this.TriggerOldMap);  
        physicalHelperRequested(this.TriggerOldMap, this.TriggerNew); 
        //populateExecutionSiteStartDate( this.TriggerNew);
        SADateRollupHandler.rollupDatesToProjectTask(this.TriggerOldMap, this.TriggerNewMap);
        populatePMRequestedTime(this.TriggerNew, this.TriggerOldMap);
        populateTimeZone(this.TriggerNew, this.TriggerOldMap);
    }

    public override void afterUpdate() {
        if (!getClickMdtSettings().Disable_ServiceAppointmentTrigger__c) {
           /* for (ServiceAppointment sa : this.TriggerNew)
            {
                if ((String) this.TriggerOldMap.get(sa.Id).get('Status') != (String) this.TriggerNewMap.get(sa.Id).get('Status')
                        && sa.Status == 'Canceled')
                {
                    cancelClickTask(sa.Id);
                }
            } */
        
            if (!preventRecursion)
            {                
               // changeAssigneeOnSA(this.TriggerOldMap, this.TriggerNewMap);
                assignmentDateUpdate(this.TriggerOldMap, this.TriggerNewMap);
                synchronizeWorkOrderStatus(this.TriggerOldMap, this.TriggerNewMap);
                //populateAssignment(this.TriggerOldMap, this.TriggerNewMap);
                changeAssigneeOnSA(this.TriggerOldMap, this.TriggerNewMap);
            }
           
                updateSA(this.TriggerOldMap, this.TriggerNew);
                //synchronizeWorkOrderStatus(this.TriggerOldMap, this.TriggerNewMap);
                populateAssignment(this.TriggerOldMap, this.TriggerNewMap);
                //changeAssigneeOnSA(this.TriggerOldMap, this.TriggerNewMap);
                updateAssignmentStatus(this.TriggerOldMap, this.TriggerNewMap);
                createTimeSheetforSA(this.TriggerNew, this.TriggerOldMap);
            
           /*  Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            if(profileName == 'PSA Project Manager' || profileName == 'PSA Resource Manager'){
                  unpopulateAssignment(this.TriggerOldMap, this.TriggerNewMap); 
            } */
            
           // FFScheduleService.run(FFScheduleService.getServiceAppointmentProjectIds(this.TriggerNew, this.TriggerOldMap)); // tdavis - 2020-05-12 - TFS Stories 8040168, 8329857, 8329865
            
        }
        
    }

    private void filterRecordsByRecordType() {
        Set<Id> ffRecordTypes = RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('WorkOrder', FFServiceAppointmentTriggerHandler.class.getName()));
        //System.debug('ffRecordTypes: ' + ffRecordTypes);
        //System.debug('Trigger.new: ' + Trigger.new);
        //System.debug('Trigger.old: ' + Trigger.old);

        Boolean hasFFRT = false;

        this.TriggerNewMap = new Map<Id, ServiceAppointment>();
        this.TriggerOldMap = new Map<Id, ServiceAppointment>();
        this.TriggerNew = new List<ServiceAppointment>();
        this.TriggerOld = new List<ServiceAppointment>();
        
        Map<Id, WorkOrder> saIdToWOMapNew = getSaIDWorkOrderMap(Trigger.new);
        Map<Id, WorkOrder> saIdToWOMapOld = getSaIDWorkOrderMap(Trigger.old);
        /*if(saIdToWOMapNew.values().isEmpty()){
            saIdToWOMapNew = new Map<Id, WorkOrder>();
            saIdToWOMapNew = getSaIDWorkOrderMap(Trigger.new);
        }
        if(saIdToWOMapOld.values().isEmpty()){
            saIdToWOMapOld = new Map<Id, WorkOrder>();
            saIdToWOMapOld = getSaIDWorkOrderMap(Trigger.old);
        }*/

        //mount triggerNewMap
        if(Trigger.NewMap != null) {
            for (Id saId : Trigger.NewMap.keySet()) {
                ServiceAppointment saNew = (ServiceAppointment) Trigger.NewMap.get(saId);
                if (saNew.AppointmentType == 'Shadow Appointment'
                    || saIdToWOMapNew.containsKey(saNew.Id) &&  ffRecordTypes.contains(saIdToWOMapNew.get(saNew.Id).RecordTypeId)) {
                    hasFFRT = true;
                    this.TriggerNewMap.put(saId, saNew);
                } 
            }
        }
        //mount triggerOldMap
        if(Trigger.OldMap != null) {
            for (Id saId : Trigger.OldMap.keySet()) {
                ServiceAppointment saOld = (ServiceAppointment) Trigger.OldMap.get(saId);
                if (saOld.AppointmentType == 'Shadow Appointment'
                    ||saIdToWOMapOld.containsKey(saOld.Id) && ffRecordTypes.contains(saIdToWOMapOld.get(saOld.Id).RecordTypeId)) {
                    hasFFRT = true;
                    this.TriggerOldMap.put(saId, saOld);
                } 
            }
        }
         //mount triggerNew
         if(Trigger.New != null) {
            for (ServiceAppointment saNew : (List<ServiceAppointment>)Trigger.New) {
                if (saNew.AppointmentType == 'Shadow Appointment'
                    ||saIdToWOMapNew.containsKey(saNew.Id) && ffRecordTypes.contains(saIdToWOMapNew.get(saNew.Id).RecordTypeId)) {
                    hasFFRT = true;
                    this.TriggerNew.add(saNew);
                } 
            }
        }
        //mount triggerOld
        if(Trigger.Old != null) {
            for (ServiceAppointment saOld : (List<ServiceAppointment>)Trigger.Old) {
                if (saOld.AppointmentType == 'Shadow Appointment'
                    ||saIdToWOMapOld.containsKey(saOld.Id) && ffRecordTypes.contains(saIdToWOMapOld.get(saOld.Id).RecordTypeId)) {
                    hasFFRT = true;
                    this.TriggerOld.add(saOld);
                } 
            }
        }

        system.debug('this.TriggerNewMap: ' + this.TriggerNewMap);
        system.debug('this.TriggerOldMap: ' + this.TriggerOldMap);
        system.debug('this.TriggerNew: ' + this.TriggerNew);
        system.debug('this.TriggerOld: ' + this.TriggerOld);
      
        if(hasFFRT) {
            system.debug('Continue with FFServiceAppointmentHandler. Other handlers should be bypassed.');
        } else {
            TriggerHandler.bypass(FFServiceAppointmentTriggerHandler.class.getName());
        }
    }

    private Click_Integration_Settings__mdt getClickMdtSettings() {
        return [
                SELECT Disable_ServiceAppointmentTrigger__c
                FROM Click_Integration_Settings__mdt
                WHERE DeveloperName = 'Settings'
                LIMIT 1
                ];
    }

    private Map<Id, WorkOrder> getSaIDWorkOrderMap(List<ServiceAppointment> serviceAppointmentList) {
        Set<Id> workOrderIds = new Set<Id>();
        Map<Id, WorkOrder> saIdToWOMap = new Map<Id, WorkOrder>();

        if (serviceAppointmentList != null && serviceAppointmentList.size() > 0) {
            for (ServiceAppointment sa : serviceAppointmentList)
            {
                workOrderIds.add(sa.ParentRecordId);
            }

            List<WorkOrder> workOrders =
            [
                    SELECT Id, RecordTypeId
                    FROM WorkOrder
                    WHERE Id IN :workOrderIds
            ];

            for (ServiceAppointment sa : serviceAppointmentList)
            {
                for (WorkOrder wo : workOrders)
                {
                    if (sa.ParentRecordId == wo.Id)
                    {
                        saIdToWOMap.put(sa.Id, wo);
                    }
                }
            }
        }
        return saIdToWOMap;
    }
    
    @future
    public static void updateCustomerNameOnSA(string saListString){
        system.debug('updateCustomerNameOnSA ');
		List<ServiceAppointment> saList = (List<ServiceAppointment>)System.JSON.deserialize(saListString, List<ServiceAppointment>.class);		
        set<ID> accId = new set<ID>();
        List<ServiceAppointment> saFilterList = new List<ServiceAppointment>();
        Map<ID,Account> accMap = new Map<ID,Account>();
        for(ServiceAppointment sA : saList){
            if((sA.AccountId != NULL)){
                accId.add(sA.AccountId);
                saFilterList.add(sA);
            }
        }
        system.debug('accId '+accId);
        if(accId.size() > 0){
            for(Account acc : [select ID, Name from Account where ID IN : accId]){
                accMap.put(acc.ID,acc);
            }
        }
        system.debug('accMap '+accMap);
        List<ServiceAppointment> serviceAtoUpdate= new List<ServiceAppointment>();
        if(! accMap.isEmpty()){
            for(ServiceAppointment sA : saFilterList){
                sA.FBE_IDS_Customer_Name__c = accMap.get(sA.AccountId).Name;
                system.debug('Cutomer Name '+sA.FBE_IDS_Customer_Name__c);
                serviceAtoUpdate.add(sA);
            }
        }
        if(serviceAtoUpdate.size() > 0){
            try{
           		UPDATE serviceAtoUpdate;
            }
            catch(Exception e){
            	System.debug('Error in updating Customer Name'+e.getMessage());
        	}
        }
	}
    public static void setAppointmentType(List<ServiceAppointment> newSAList){
        for(ServiceAppointment sappt :newSAList){
            if((sappt.AppointmentType=='' || sappt.AppointmentType==NULL) && (sappt.FSL__Related_Service__c==NULL)){              
                sappt.AppointmentType = 'Primary Appointment';
            }
            
        }               
    }
    
    //When SA gets Canceled, auto Cancel its related shadow SA #feature 7886156
    public static void updateSA(Map<Id, ServiceAppointment> oldAppointments,List<ServiceAppointment> newSAList)
    {
        Map <Id,ServiceAppointment> mapSA = new Map <Id,ServiceAppointment >();
        for (ServiceAppointment sappt : newSAList) {   
            if (sappt.Status != oldAppointments.get(sappt.Id ).get('Status') && sappt.Status == 'Canceled'){
                mapSA.put( sappt.Id, sappt );
            }
                
        } 
        if ( mapSA.size() > 0 ) {
            List<ServiceAppointment> updatechildList = new List<ServiceAppointment>();
            updatechildList = [ SELECT Id, FSL__Related_Service__c, Status FROM ServiceAppointment WHERE FSL__Related_Service__c IN : mapSA.keySet() ]; 
            system.debug('updatechildList '+updatechildList);
            if  ( updatechildList.size() > 0  )  {
                for  (  ServiceAppointment con : updatechildList  )  {
                    con.Status  = mapSA.get( con.FSL__Related_Service__c ).Status;
                }
                try{
                update updatechildList;
                }catch(Exception e){ system.debug('Error in updateSA '+e.getMessage());}
            } 
        }
    }
   
    public static void populateProjectLookup(List<ServiceAppointment> triggerNew) {
        Set<Id> workOrderIds = new Set<Id>();
        List<ServiceAppointment> woSas = new List<ServiceAppointment>();
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        projList =[SELECT Id, Name
                  FROM pse__Proj__c 
                  WHERE Name = 'Job Shadowing' and pse__Allow_Timecards_Without_Assignment__c = true limit 1];
        for (ServiceAppointment sa:triggerNew) {
            if(sa.ParentRecordId != null)
            {
                String parentIdString = sa.ParentRecordId;
                if (parentIdString.startsWith(WORK_ORDER_ID_PREFIX)) 
                {
                    if(sa.AppointmentType == 'Shadow Appointment'){    //In case of Shadow Service Appointment, populate the project lookup with Global project value.
                        if(projList != null && projList.size() > 0)
                            sa.Project__c = projList[0].id;
                        sa.Work_Order__c = sa.ParentRecordId;
                    }
                    else{
                        workOrderIds.add(sa.ParentRecordId);
                        woSas.add(sa);
                    }   
                }
            }

        }
        if (!woSas.isEmpty()) {
            Map<Id,WorkOrder> workOrderMap = new Map<Id,WorkOrder>([SELECT Project_Task__c FROM WorkOrder WHERE Id in :workOrderIds AND Project_Task__c != NULL]);
            Set<Id> projectTaskIds = new Set<Id>();
            for (WorkOrder wo:workOrderMap.values()) {
                projectTaskIds.add(wo.Project_Task__c);
            }
            Map<Id,pse__Project_Task__c> projectTaskMap =
                    new Map<Id,pse__Project_Task__c>(
                    [SELECT pse__Project__c FROM pse__Project_Task__c WHERE Id IN :projectTaskIds]);
            for (ServiceAppointment sa: woSas) {
                WorkOrder wo = workOrderMap.get(sa.ParentRecordId);
                if (wo != null) {
                    pse__Project_Task__c pt = projectTaskMap.get(wo.Project_Task__c);
                    if (pt != null) {
                        sa.Project__c = pt.pse__Project__c;
                        sa.Work_Order__c = wo.Id;
                    }
                }
            }
        }
    }


    /****************************************************************************************************************
     *  Populate Execution Site Start Date
     *  ----------------------------------
     *  @auth    -    Luis Valenzuela [20190612]
     *  @desc    -    Populate the text version of the scheduled start date in the Execution site's timezone.
     *            Note: Following existing format of separating trigger components by function.
     */
  /**  public static void populateExecutionSiteStartDate(   list<ServiceAppointment> servApp_lst )
    {

        Set<String> siteTimezone_set = new Set<String>();
        list<ServiceAppointment> updateServApp_lst = new list<ServiceAppointment>();

        for( ServiceAppointment sa : servApp_lst )
        {
            // Gather Timezones
            siteTimezone_set.add( sa.PSA_Execution_Site_TimeZone__c );
            updateServApp_lst.add(sa);
        }

        // Populate Execution site start times
        map<String,String> timeZone_map = TimeZoneHelper.getTimeZones(siteTimezone_set);
        for( ServiceAppointment sa : updateServApp_lst )
        {
            if( sa.SchedStartTime == null )
            {
                sa.ScheduleStart_SiteTimeZone__c = '';
            }
            else
            {
                try
                {
                    Timezone siteTz = TimeZoneHelper.getTimeZone( timeZone_map.get(sa.PSA_Execution_Site_TimeZone__c) );
                    DateTime startDT = sa.SchedStartTime;
                    sa.ScheduleStart_SiteTimeZone__c = startDT.format( 'MM/dd/yyyy hh:mm a', siteTz.getID() );
                }
                catch( Exception Ex )
                {
                    sa.ScheduleStart_SiteTimeZone__c = 'Timezone ['+ sa.PSA_Execution_Site_TimeZone__c +'] not configured in Timezone custom MDT.';
                }
            }
        }
    }
**/

    /**
    * Thomas Davis
    * 2018-11-01
    * FinancialForce.com, Inc.
    * thdavis@financialforce.com
    *
    * This method is called from ServiceAppointmentTrigger.trigger. It is a future method that calls out to Click FSE
    * to cancel the task within the Click FSE system. If a successful cancellation occurs within Click FSE, the
    * Click_Task_Cancelled__c field on the ServiceAppointment record is set to true.
    */
/**    @Future(callout=true)
    public static void cancelClickTask(Id saId)
    {
        /*Click_Integration_Settings__mdt settings =
        [
                SELECT Development_Username__c, Development_Password__c, Production_Username__c, Production_Password__c,
                        Is_Production__c, ProcessTaskEx_Endpoint_URL__c
                FROM Click_Integration_Settings__mdt
                WHERE DeveloperName = 'Settings'
                LIMIT 1
        ];

        String username = settings.Is_Production__c ? settings.Production_Username__c : settings.Development_Username__c;
        String password = settings.Is_Production__c ? settings.Production_Password__c : settings.Development_Password__c;
        

        ServiceAppointment sa =
        [
                SELECT Work_Order__r.WorkOrderNumber, Work_Order__r.ContactId, Duration, Work_Order__r.Contact.Phone,
                        EarliestStartTime, DueDate, SchedEndTime, SchedStartTime, Work_Order__r.Project_Task__r.pse__Project__r.pse__Practice__r.Name,
                        Work_Order__r.AssetId, Description, Work_Order__r.Project_Task__r.pse__Project__r.Pre_Implementation_Validation__c,
                        Work_Order__r.Id, Number__c, Work_Order__r.Latitude, Work_Order__r.Longitude, DurationType, Work_Order__c,
                        Work_Order__r.Contact.Time_Zone__c, City, State, Street, PostalCode, Country, Integration_Message__c,
                        Status, Assignee__c, Click_Task_Cancelled__c
                FROM ServiceAppointment
                WHERE Id = :saId
        ];

        CancelTaskRequest ctr = new CancelTaskRequest();
        ctr.Task.objectType = 'Task';
        ctr.Task.createOrUpdate = true;
        ctr.Task.CallID = sa.Work_Order__r.Id;
        ctr.Task.ExternalRefID = sa.Id;
        ctr.Task.Number_Z = Integer.valueOf(sa.Number__c);
        ctr.Task.Status.Name = 'Cancelled';
        ctr.ReturnAssignment = false;
        ctr.ReturnSchedulingError = true;
        ctr.TaskRequestedProperties.addAll(new List<String>
        {
                'CallID', 'Number', 'ExternalRefID'
        });
        ctr.AssignmentRequestedProperties.addAll(new List<String>
        {
                'Key'
        });

        HttpRequest request;
        CancelTaskResponse deserializedResponse;

        try
        {
            request = new HttpRequest();
            request.setEndpoint('callout:Click_FSE_ProcessTaskEx');
            request.setHeader('Content-Type', 'application/json');
            //request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)));
            request.setBodyAsBlob(Blob.valueOf(JSON.serialize(ctr)
                    .replace('objectType', '@objectType')
                    .replace('createOrUpdate', '@createOrUpdate')
                    .replace('Number_Z', 'Number')
            ));
            request.setMethod('POST');

            System.debug('Request: ' + request.getBody());

            HttpResponse response = new Http().send(request);

            System.debug('Response: ' + response.getBody());

            deserializedResponse = CancelTaskResponse.parse(response.getBody()
                    .replace('@objectType', 'objectType'));
        }
        catch (Exception e)
        {
            ExceptionLogger__c log = new ExceptionLogger__c(
                    Apex_Class__c = 'FFServiceAppointmentHandler',
                    Method_Name__c = 'cancelClickTask',
                    API_PayLoad__c = request.getBody(),
                    Description__c = e.getMessage()
            );
            insert log;
        }

        if (deserializedResponse.ReturnCode == 'ScheduleFailed')
        {
            sa.Click_Task_Cancelled__c = true;
        }

        update sa; 
    } **/

    /**
    * Thomas Davis
    * 2018-11-01
    * FinancialForce.com, Inc.
    * thdavis@financialforce.com
    *
    * This method is called from ServiceAppointmentTrigger.trigger. Its purpose is to set the Number__c field on
    * ServiceAppointment records. This method ensures that sibling ServiceAppointments do not contain the same value in
    * the Number__c field as it is required to be unique across sibling ServiceAppointments in the Click FSE system.
    */
    public static void setNumberField(List<ServiceAppointment> serviceAppointments)
    {
        Map<Id, List<ServiceAppointment>> workOrderToServiceAppointmentMap = new Map<Id, List<ServiceAppointment>>();
        Set<Id> workOrderIds = new Set<Id>();
        List<ServiceAppointment> serviceAppointmentUpdates = new List<ServiceAppointment>();

        for (ServiceAppointment sa : serviceAppointments)
        {
            workOrderIds.add(sa.Work_Order__c);
        }

        for (ServiceAppointment sa : [ SELECT Number__c, Work_Order__c FROM ServiceAppointment WHERE Work_Order__c IN :workOrderIds ])
        {
            if (!workOrderToServiceAppointmentMap.containsKey(sa.Work_Order__c))
            {
                workOrderToServiceAppointmentMap.put(sa.Work_Order__c, new List<ServiceAppointment>());
            }

            workOrderToServiceAppointmentMap.get(sa.Work_Order__c).add(sa);
        }

        List<ServiceAppointment> sasToUpdate = [ SELECT Number__c FROM ServiceAppointment WHERE Id IN :serviceAppointments];
        for (ServiceAppointment sa : serviceAppointments)
        {
            Integer numberOfServiceAppointments = workOrderToServiceAppointmentMap.get(sa.Work_Order__c).size();

            for (ServiceAppointment saToUpdate : sasToUpdate)
            {
                if (numberOfServiceAppointments > 1)
                {
                    saToUpdate.Number__c = numberOfServiceAppointments - 1;
                    serviceAppointmentUpdates.add(saToUpdate);
                }
            }
        }

        update serviceAppointmentUpdates;
    }

    public static void workOrderCloneController( List<ServiceAppointment> serviceAppointments, map<Id,ServiceAppointment> oldMapServiceAppointments)
    {
        Map<Id, String> workOrderIdToScheduleTypeMap = new Map<Id, String>();

        //Custom Setting
        Trigger_Execution_Control__c triggerControl = Trigger_Execution_Control__c.getOrgDefaults();

        //trigger is active?
        if( !triggerControl.Skip_Work_Order_Cloning__c )
        {
            //Get valid Work Orders
            for( ServiceAppointment objSA : serviceAppointments )
            {
               // if( (objSA.Status == 'Click_Complete' || objSA.Status == 'Click_Incomplete')
               // Changed the below status as FSL standard vAlues. Added by Namrata for Feature #8844917
                if( (objSA.Status == 'Completed' || objSA.Status == 'Cannot Complete')
                        && objSA.Additional_Effort__c != 'No Additional Effort Required'
                        && objSA.Additional_Effort__c != null
                        && objSA.Status != oldMapServiceAppointments.get(objSA.Id).Status )
                {
                    if (objSA.Additional_Effort__c == 'Activity for Doc/Admin Time')
                    {
                        workOrderIdToScheduleTypeMap.put(objSA.Work_Order__c, 'Activity');
                    }

                    if (objSA.Additional_Effort__c == 'Appointment Task')
                    {
                        workOrderIdToScheduleTypeMap.put(objSA.Work_Order__c, 'Appointment');
                    }
                }
            }

            //callout to clone work orders
            if( !workOrderIdToScheduleTypeMap.isEmpty() )
            {
                ServiceAppointmentCloneWorkOrders.cloneWorkOrders(workOrderIdToScheduleTypeMap);
            }
        }
    }

    /**
    * Thomas Davis
    * 2019-01-28
    * FinancialForce.com, Inc.
    * thdavis@financialforce.com
    *
    * This method is called from ServiceAppointmentTrigger.trigger. Its purpose is to create a pse__Assignment__c record
    * and tie it to the ServiceAppointment.Assignment__c field if the Assignee__c field on ServiceAppointment changes
    * from null to not null and the Assignment__c field is currently null.
    * Modified by Orlando Monsalve
    * 2019-12-06
    * FinancialForce.com, Inc.
    * omonsalve.p@financialforce.com
    */
    public static void populateAssignment(Map<Id, ServiceAppointment> oldAppointments, Map<Id, ServiceAppointment> newAppointments)
    {
        System.debug('In method');
        //preventRecursion = true; // commented so that Assignment records get created when SA is changed from New to Scheduled
        System.debug('oldAppointments ==='+oldAppointments);
        System.debug('newAppointments ==='+newAppointments);
        Map<String, Map<String,ServiceAppointment>> mpPrjXServiceAppointments = new Map<String, Map<String,ServiceAppointment>>();
        Map<String, Map<String,pse__Assignment__c>> mpPrjXAssignments = new Map<String, Map<String,pse__Assignment__c>>();
        Map<String, List<pse__Project_Task_Assignment__c>> mpAssignXPTAssignment = new Map<String, List<pse__Project_Task_Assignment__c>>();
        Map<String, List<ServiceAppointment>> mpAssignmentXlistSAs = new Map<String, List<ServiceAppointment>>();
        Map<String,ServiceAppointment> mpUpdateSAs = new  Map<String,ServiceAppointment>();
        Set<String> stProjectIds = new Set<String>();
        System.debug('newAppointments.values()'+newAppointments.values());
        
        for (ServiceAppointment objSA : [SELECT Assignee__c, Assignee__r.pse__Resource_Role__c, Assignment__c, Project__r.pse__Start_Date__c, Project__r.pse__End_Date__c, Project__r.Id, /* omonsalve added field */
                                                Work_Order__r.Project_Task__r.Id, Id, SchedStartTime, SchedEndTime, Duration,
                                                Assignment__r.pse__Schedule__c, Assignment__r.pse__Project__c, Assignment__r.pse__Resource__c, Assignment__r.pse__Role__c, /* omonsalve added field */
                                                Assignment__r.pse__Bill_Rate__c, Assignment__r.pse__Cost_Rate_Amount__c /* omonsalve added field */
                                        FROM ServiceAppointment
                                        WHERE Id IN :newAppointments.values()
                                        AND Status != 'Canceled' AND AppointmentType != 'Shadow Appointment']) //Added filter for shadow SA here
      
         
        {   
             System.debug('objSA ==='+objSA);
        System.debug('objSA.Assignee__c'+objSA.Assignee__c);
            if(objSA.Assignee__c != null)
            {
                if (mpPrjXServiceAppointments.containsKey(objSA.Project__r.Id))
                {
                    mpPrjXServiceAppointments.get(objSA.Project__r.Id).put(objSA.Assignee__c,objSA);
                }   
                else
                {
                    mpPrjXServiceAppointments.put(objSA.Project__r.Id, new Map<String,ServiceAppointment>{objSA.Assignee__c => objSA});
                }
                stProjectIds.add(objSA.Project__r.Id);
            }
        }

        for (pse__Assignment__c objAssignment : [SELECT pse__Schedule__c, pse__Project__c, pse__Resource__c, pse__Role__c, Id,
                                                        pse__Bill_Rate__c, pse__Cost_Rate_Amount__c, (SELECT Id, Work_Order__r.Project_Task__r.Id FROM Service_Appointments__r),
                                                        (SELECT pse__Assignment__c ,pse__Resource_Role__c, Id, pse__Project_Task__c, pse__Resource__c FROM pse__Project_Task_Assignments__r)
                                                FROM pse__Assignment__c
                                                WHERE pse__Project__c IN :stProjectIds])
           
        {
            if (mpPrjXAssignments.containsKey(objAssignment.pse__Project__c))
            {
                mpPrjXAssignments.get(objAssignment.pse__Project__c).put(objAssignment.pse__Resource__c,objAssignment);
            }
            else
            {
                mpPrjXAssignments.put(objAssignment.pse__Project__c, new Map<String,pse__Assignment__c>{objAssignment.pse__Resource__c => objAssignment});
            }

            if(mpAssignmentXlistSAs.containsKey(objAssignment.Id))
            {
                mpAssignmentXlistSAs.get(objAssignment.Id).addAll(objAssignment.Service_Appointments__r);
            }
            else 
            {
                List<ServiceAppointment> lstSAtemp = new List<ServiceAppointment>();
                lstSAtemp.addAll(objAssignment.Service_Appointments__r);
                mpAssignmentXlistSAs.put(objAssignment.Id, lstSAtemp);
            }

            if(mpAssignXPTAssignment.containsKey(objAssignment.Id))
            {
                mpAssignXPTAssignment.get(objAssignment.Id).addAll(objAssignment.pse__Project_Task_Assignments__r);
            }
            else 
            {
                List<pse__Project_Task_Assignment__c> lstPTAtemp = new List<pse__Project_Task_Assignment__c>();
                lstPTAtemp.addAll(objAssignment.pse__Project_Task_Assignments__r);
                mpAssignXPTAssignment.put(objAssignment.Id, lstPTAtemp);
            }
        }

        System.debug('POP - mpPrjXServiceAppointments------> ' + mpPrjXServiceAppointments);
        System.debug('POP - mpPrjXAssignments------> ' + mpPrjXAssignments);
        System.debug('POP - mpAssignmentXlistSAs------> ' + mpAssignmentXlistSAs);
        System.debug('POP - mpAssignXPTAssignment------> ' + mpAssignXPTAssignment);

        if(mpPrjXServiceAppointments != null)
        {
            for (String strProjectId  : mpPrjXServiceAppointments.keySet())
            {
                for (String strAssignee : mpPrjXServiceAppointments.get(strProjectId).keySet() )
                {
                    pse__Assignment__c objAssignmentAux;
                    ServiceAppointment objSAAux;
                    List<ServiceAppointment> lstSAaux;

                    if(mpPrjXAssignments.containsKey(strProjectId))
                    {
                        objAssignmentAux = mpPrjXAssignments.get(strProjectId).containsKey(strAssignee) ? mpPrjXAssignments.get(strProjectId).get(strAssignee) : null;

                    }
                    else
                    {
                        objAssignmentAux = null;
                    }

                    if(mpPrjXServiceAppointments.containsKey(strProjectId))
                    {
                        objSAAux = mpPrjXServiceAppointments.get(strProjectId).containsKey(strAssignee) ? mpPrjXServiceAppointments.get(strProjectId).get(strAssignee) : null;
                    }
                    else
                    {
                        objSAAux = null;
                    }

                    System.debug('POP - objAssignmentAux-----> '+ objAssignmentAux);
                    System.debug('POP - objSAAux-----> '+ objSAAux);
                    System.debug('POP - newAppointments.get(objSAAux.Id).Status-----> '+ newAppointments.get(objSAAux.Id).Status);
                    System.debug('POP - oldAppointments.get(objSAAux.Id).Assignee__c-----> '+ oldAppointments.get(objSAAux.Id).Assignee__c);
                    System.debug('POP - newAppointments.get(objSAAux.Id).Assignee__c-----> '+ newAppointments.get(objSAAux.Id).Assignee__c);
                    
                    //scenario 1 uncomment below If condition it is according to existing flow
                    //if (objSAAux.Assignee__c != null && objAssignmentAux == null && newAppointments.get(objSAAux.Id).Status == 'Click_Assigned' && (( oldAppointments.get(objSAAux.Id).Status != 'Click_Assigned')  || (oldAppointments.get(objSAAux.Id).Assignee__c == null && newAppointments.get(objSAAux.Id).Assignee__c != null)))
                    if (objSAAux.Assignee__c != null && objAssignmentAux == null && newAppointments.get(objSAAux.Id).Status == 'Scheduled' && (( oldAppointments.get(objSAAux.Id).Status != 'Scheduled')  || (oldAppointments.get(objSAAux.Id).Assignee__c == null && newAppointments.get(objSAAux.Id).Assignee__c != null)))                   {
                        pse__Schedule__c schedule = new pse__Schedule__c();
                        schedule.pse__Start_Date__c = objSAAux.SchedStartTime.date();
                        schedule.pse__End_Date__c = objSAAux.SchedEndTime.date();
                        schedule.pse__Monday_Hours__c = 0.00;
                        schedule.pse__Tuesday_Hours__c = 0.00;
                        schedule.pse__Wednesday_Hours__c = 0.00;
                        schedule.pse__Thursday_Hours__c = 0.00;
                        schedule.pse__Friday_Hours__c = 0.00;
                        schedule.pse__Saturday_Hours__c = 0.00;
                        schedule.pse__Sunday_Hours__c = 0.00;
                        insert schedule;
                         System.debug(' @@ schedule ==='+schedule);
                        
                        pse__Assignment__c assignment = new pse__Assignment__c();
                        assignment.pse__Schedule__c = schedule.Id;
                        assignment.pse__Project__c = objSAAux.Project__r.Id;
                        assignment.pse__Resource__c = objSAAux.Assignee__c;
                        assignment.pse__Role__c   = objSAAux.Assignee__r.pse__Resource_Role__c; /* omonsalve added field */
                        assignment.pse__Bill_Rate__c = 0.00;
                        assignment.pse__Cost_Rate_Amount__c = 0.00;
                        insert assignment;
                        System.debug(' @@ assignment ==='+assignment);

                        pse__Project_Task_Assignment__c pta = new pse__Project_Task_Assignment__c();
                        pta.pse__Project_Task__c = objSAAux.Work_Order__r.Project_Task__r.Id;
                        pta.pse__Resource__c = objSAAux.Assignee__c;
                        pta.pse__Resource_Role__c = objSAAux.Assignee__r.pse__Resource_Role__c; /* omonsalve added field */
                        pta.pse__Assignment__c = assignment.Id;
                        pta.FBE_IDS_Assignment_IntegrationStatus__c = 'Pending Sync';
                        insert pta;
                        
                          System.debug(' @@ pta ==='+pta);
                        objSAAux.Assignment__c = assignment.Id;
                        mpUpdateSAs.put(objSAAux.Id, objSAAux);
                    }

                    // if ( objSAAux.Assignee__c != null && oldAppointments.get(objSAAux.Id).Assignee__c == null   && objAssignmentAux != null)
                    //uncomment below If condition as it is according to existing flow
                    // if (objSAAux.Assignee__c != null && objAssignmentAux != null && newAppointments.get(objSAAux.Id).Status == 'Click_Assigned' && (( oldAppointments.get(objSAAux.Id).Status != 'Click_Assigned')  || (oldAppointments.get(objSAAux.Id).Assignee__c == null && newAppointments.get(objSAAux.Id).Assignee__c != null)))
             
                    if (objSAAux.Assignee__c != null && objAssignmentAux != null && newAppointments.get(objSAAux.Id).Status == 'Scheduled' && (( oldAppointments.get(objSAAux.Id).Status != 'Scheduled')  || (oldAppointments.get(objSAAux.Id).Assignee__c == null && newAppointments.get(objSAAux.Id).Assignee__c != null)))                    {
                        List<pse__Project_Task_Assignment__c> lstPTAaux =  mpAssignXPTAssignment.get(objAssignmentAux.Id);
                        //System.debug('POP -  lstPTAaux-------> '+ lstPTAaux);
                        //scenario 2
                        if(lstPTAaux.isEmpty() || lstPTAaux == null)
                        {
                            pse__Project_Task_Assignment__c pta = new pse__Project_Task_Assignment__c();
                            pta.pse__Project_Task__c = objSAAux.Work_Order__r.Project_Task__r.Id;
                            pta.pse__Resource__c = objSAAux.Assignee__c;
                            pta.pse__Resource_Role__c = objSAAux.Assignee__r.pse__Resource_Role__c;
                            pta.pse__Assignment__c = objAssignmentAux.Id;
                            pta.FBE_IDS_Assignment_IntegrationStatus__c = 'Pending Sync';
                            insert pta;

                            objSAAux.Assignment__c = objAssignmentAux.Id;
                            mpUpdateSAs.put(objSAAux.Id, objSAAux);
                        }
                        //scenario 3
                        if(!lstPTAaux.isEmpty() && lstPTAaux != null)
                        {
                            Boolean boolNewPTA = true;
                            for(pse__Project_Task_Assignment__c objPTAaux : lstPTAaux)
                            {
                                if(objPTAaux.pse__Project_Task__c == objSAAux.Work_Order__r.Project_Task__r.Id)
                                {
                                    objSAAux.Assignment__c = objAssignmentAux.Id;
                                    mpUpdateSAs.put(objSAAux.Id, objSAAux);
                                    boolNewPTA = false;
                                }
                            }

                            if(boolNewPTA != false)
                            {
                                pse__Project_Task_Assignment__c pta = new pse__Project_Task_Assignment__c();
                                pta.pse__Project_Task__c = objSAAux.Work_Order__r.Project_Task__r.Id;
                                pta.pse__Resource__c = objSAAux.Assignee__c;
                                pta.pse__Resource_Role__c = objSAAux.Assignee__r.pse__Resource_Role__c;
                                pta.pse__Assignment__c = objAssignmentAux.Id;
                                pta.FBE_IDS_Assignment_IntegrationStatus__c = 'Pending Sync';
                                insert pta;

                                objSAAux.Assignment__c = objAssignmentAux.Id;
                                mpUpdateSAs.put(objSAAux.Id, objSAAux);
                            }
                        }
                    }
                }
            }
        }

        if (mpUpdateSAs.values() != null)
        {
            //System.debug('mpUpdateSAs'+mpUpdateSAs);
            update mpUpdateSAs.values();
        }
        //System.debug('POP - Limits--------->' + Limits.getDMLStatements());
    }

    

    /**
    * Orlando Monsalve
    * 2019-12-17
    * FinancialForce.com, Inc.
    * omonsalve.p@financialforce.com
    *
    * This method is called from FFServiceAppointmentTrigger.trigger. Its purpose is to delete a pse__Assignment__c record and 
    * pse__Project_Task_Assignment__c records
    */
  /**  public static void unpopulateAssignment(Map<Id, ServiceAppointment> oldAppointments, Map<Id, ServiceAppointment> newAppointments)
    {
        preventRecursion = true;

        Map<String, Map<String,ServiceAppointment>> mpPrjXServiceAppointments = new Map<String, Map<String,ServiceAppointment>>();
        Map<String, Map<String,pse__Assignment__c>> mpPrjXAssignments = new Map<String, Map<String,pse__Assignment__c>>();
        Map<String, List<pse__Project_Task_Assignment__c>> mpAssignXPTAssignment = new Map<String, List<pse__Project_Task_Assignment__c>>();
        Map<String, List<ServiceAppointment>> mpAssignmentXlistSAs = new Map<String, List<ServiceAppointment>>();
        Map<String,ServiceAppointment> mpUpdateSAs = new  Map<String,ServiceAppointment>();
        Set<String> stProjectIds = new Set<String>();

        for (ServiceAppointment objSA : [SELECT Assignee__c, Assignee__r.pse__Resource_Role__c, Assignment__c, Project__r.pse__Start_Date__c, Project__r.pse__End_Date__c, Project__r.Id, 
                                                Work_Order__r.Project_Task__r.Id, Id, SchedStartTime, SchedEndTime, Status,
                                                Assignment__r.pse__Schedule__c, Assignment__r.pse__Project__c, Assignment__r.pse__Resource__c, Assignment__r.pse__Role__c, 
                                                Assignment__r.pse__Bill_Rate__c, Assignment__r.pse__Cost_Rate_Amount__c 
                                        FROM ServiceAppointment
                                        WHERE Id IN :newAppointments.values()
                                        AND Status != 'Canceled'])
        {
            if(objSA.Project__c != null)
            {
                if (mpPrjXServiceAppointments.containsKey(objSA.Project__r.Id))
                {
                    mpPrjXServiceAppointments.get(objSA.Project__r.Id).put(objSA.Assignee__c,objSA);
                }
                else
                {
                    mpPrjXServiceAppointments.put(objSA.Project__r.Id, new Map<String,ServiceAppointment>{objSA.Assignee__c => objSA});
                }
                stProjectIds.add(objSA.Project__r.Id);
            }
        }
    
        if(stProjectIds.size() > 0)
        {
            for (pse__Assignment__c objAssignment : [SELECT pse__Schedule__c, pse__Project__c, pse__Resource__c, pse__Role__c, Id,
                                                     pse__Bill_Rate__c, pse__Cost_Rate_Amount__c, (SELECT Id, Work_Order__r.Project_Task__r.Id, Assignment__c FROM Service_Appointments__r),
                                                     (SELECT pse__Assignment__c ,pse__Resource_Role__c, Id, pse__Project_Task__c, pse__Resource__c FROM pse__Project_Task_Assignments__r)
                                                     FROM pse__Assignment__c
                                                     WHERE pse__Project__c IN :stProjectIds])
            {
                if (mpPrjXAssignments.containsKey(objAssignment.pse__Project__c))
                {
                    mpPrjXAssignments.get(objAssignment.pse__Project__c).put(objAssignment.pse__Resource__c,objAssignment);
                }
                else
                {
                    mpPrjXAssignments.put(objAssignment.pse__Project__c, new Map<String,pse__Assignment__c>{objAssignment.pse__Resource__c => objAssignment});
                }
                
                if(mpAssignmentXlistSAs.containsKey(objAssignment.Id))
                {
                    mpAssignmentXlistSAs.get(objAssignment.Id).addAll(objAssignment.Service_Appointments__r);
                }
                else 
                {
                    List<ServiceAppointment> lstSAtemp = new List<ServiceAppointment>();
                    lstSAtemp.addAll(objAssignment.Service_Appointments__r);
                    mpAssignmentXlistSAs.put(objAssignment.Id, lstSAtemp);
                }
                
                if(mpAssignXPTAssignment.containsKey(objAssignment.Id))
                {
                    mpAssignXPTAssignment.get(objAssignment.Id).addAll(objAssignment.pse__Project_Task_Assignments__r);
                }
                else 
                {
                    List<pse__Project_Task_Assignment__c> lstPTAtemp = new List<pse__Project_Task_Assignment__c>();
                    lstPTAtemp.addAll(objAssignment.pse__Project_Task_Assignments__r);
                    mpAssignXPTAssignment.put(objAssignment.Id, lstPTAtemp);
                }
            }
        }

        System.debug('UN - mpPrjXServiceAppointments------> ' + mpPrjXServiceAppointments);
        System.debug('UN - mpPrjXAssignments------> ' + mpPrjXAssignments);
        System.debug('UN - mpAssignmentXlistSAs------> ' + mpAssignmentXlistSAs);
        System.debug('UN - mpAssignXPTAssignment------> ' + mpAssignXPTAssignment);

        for (String strProjectId  : mpPrjXServiceAppointments.keySet())
        {
            System.debug('strProjectId-----> ' + strProjectId);

            for (String strAssignee : mpPrjXServiceAppointments.get(strProjectId).keySet() )
            {

                System.debug('strAssignee-----> ' + strAssignee);

                pse__Assignment__c objAssignmentAux;
                ServiceAppointment objSAAux;
                List<ServiceAppointment> lstSAaux;

                if(mpPrjXAssignments.containsKey(strProjectId))
                {
                    objAssignmentAux = mpPrjXAssignments.get(strProjectId).containsKey(strAssignee) ? mpPrjXAssignments.get(strProjectId).get(strAssignee) : null;

                    System.debug('objAssignmentAux------> '+objAssignmentAux);

                    if(objAssignmentAux != null)
                    {
                        if (mpAssignmentXlistSAs.containsKey(objAssignmentAux.Id)) 
                        {
                            lstSAaux = mpAssignmentXlistSAs.get(objAssignmentAux.Id);
                        }
                        else 
                        {
                            lstSAaux = null;
                        }
                    }
                }
                else
                {
                    objAssignmentAux = null;
                }

                if(mpPrjXServiceAppointments.containsKey(strProjectId))
                {
                    objSAAux = mpPrjXServiceAppointments.get(strProjectId).containsKey(strAssignee) ? mpPrjXServiceAppointments.get(strProjectId).get(strAssignee) : null;
                }
                else
                {
                    objSAAux = null;
                }

                System.debug('objAssignmentAux-----> '+ objAssignmentAux);
                System.debug('objSAAux-----> '+ objSAAux);
                System.debug('lstSAaux-----> '+ lstSAaux);
                System.debug('----------------------------------------------------------------------------------------------------------');
                System.debug('newAppointments.get(objSAAux.Id).Assignee__c------> ' + newAppointments.get(objSAAux.Id).Assignee__c); 
                System.debug('objSAAux.Assignee__c------> ' + objSAAux.Assignee__c); 
                System.debug('objAssignmentAux------> ' + objAssignmentAux); 
                System.debug('newAppointments.get(objSAAux.Id).Status------> ' + newAppointments.get(objSAAux.Id).Status); 
                System.debug('newAppointments.get(objSAAux.Id).Assignment__c------> ' + newAppointments.get(objSAAux.Id).Assignment__c); 
                System.debug('----------------------------------------------------------------------------------------------------------');


                if (newAppointments.get(objSAAux.Id).Status == 'New' && newAppointments.get(objSAAux.Id).Assignment__c != null && objAssignmentAux != null
                        &&  lstSAaux.size() == 1)
                {
                    List<pse__Project_Task_Assignment__c> lstPTAaux =  mpAssignXPTAssignment.get(objAssignmentAux.Id);

                    if(!lstPTAaux.isEmpty() && lstPTAaux != null)
                    {
                        delete lstPTAaux;
                    }

                    delete objAssignmentAux;
                }

                if (newAppointments.get(objSAAux.Id).Status == 'New' && objAssignmentAux != null && newAppointments.get(objSAAux.Id).Assignment__c != null
                        &&  lstSAaux.size() > 1)
                {
                    objSAAux.Assignment__c = null;

                    List<pse__Project_Task_Assignment__c> lstPTAaux =  mpAssignXPTAssignment.get(objAssignmentAux.Id);
                    pse__Project_Task_Assignment__c objPTADel =  new pse__Project_Task_Assignment__c();
                    System.debug('lstPTAaux------>' + lstPTAaux);
                    System.debug('newAppointments.get(objSAAux.Id).Assignment__c------>' + newAppointments.get(objSAAux.Id).Assignment__c);
                    System.debug('objAssignmentAux.Id------>' + objAssignmentAux.Id);
                    System.debug('objSAAux.Work_Order__r.Project_Task__r.Id------>' + objSAAux.Work_Order__r.Project_Task__r.Id);
                    Integer n = 0;
                    
                    if(!lstPTAaux.isEmpty() && lstPTAaux != null)
                    {
                        for(pse__Project_Task_Assignment__c objPTATemp : lstPTAaux)
                        {
                            System.debug('objPTATemp.pse__Project_Task__c------>' + objPTATemp.pse__Project_Task__c);
                            for(ServiceAppointment objSATemp : lstSAaux)
                            {
                                if (objPTATemp.pse__Project_Task__c == objSAAux.Work_Order__r.Project_Task__r.Id && objAssignmentAux.Id == newAppointments.get(objSAAux.Id).Assignment__c
                                    && objPTATemp.pse__Resource__c == strAssignee && objSAAux.Work_Order__r.Project_Task__r.Id == objSATemp.Work_Order__r.Project_Task__r.Id) 
                                {
                                    System.debug('TRUE');
                                    System.debug('objSATemp ID' +objSATemp.Id);
                                    objPTADel = objPTATemp;
                                    n++;
                                }
                            }        
                        }

                        if(n == 1 && objPTADel!=null)
                        {
                            delete objPTADel;
                        }
                    }
                    System.debug('n----->' + n);
                    mpUpdateSAs.put(objSAAux.Id, objSAAux);
                }
            }
        }

        update mpUpdateSAs.values();
        System.debug('UN - Limits--------->' + Limits.getDMLStatements());
    }**/

    /**
    * Orlando Monsalve
    * 2019-12-19
    * FinancialForce.com, Inc.
    * omonsalve.p@financialforce.com
    *
    * This method is called from ServiceAppointmentTrigger.trigger. Its purpose is to create a pse__Assignment__c record
    * and tie it to the ServiceAppointment.Assignment__c field if the Assignee__c field on ServiceAppointment changes
    * from null to not null and the Assignment__c field is currently null.
    */
    public static void changeAssigneeOnSA(Map<Id, ServiceAppointment> oldAppointments, Map<Id, ServiceAppointment> newAppointments)
    {
        preventRecursion = true;

         System.debug('CH - oldAppointments-----> ' + oldAppointments);
         System.debug('CH - newAppointments-----> ' + newAppointments);

        Map<String, Map<String,ServiceAppointment>> mpPrjXServiceAppointments = new Map<String, Map<String,ServiceAppointment>>();
        Map<String, Map<String,pse__Assignment__c>> mpPrjXAssignments = new Map<String, Map<String,pse__Assignment__c>>();
        Map<String, List<pse__Project_Task_Assignment__c>> mpAssignXPTAssignment = new Map<String, List<pse__Project_Task_Assignment__c>>();
        Map<String, List<ServiceAppointment>> mpAssignmentXlistSAs = new Map<String, List<ServiceAppointment>>();
        Map<String,ServiceAppointment> mpUpdateSAs = new  Map<String,ServiceAppointment>();
        Map<String,List<ServiceAppointment>> mpAssigneesXSA = new  Map<String,List<ServiceAppointment>>();
        Set<String> stProjectIds = new Set<String>();
        Set<String> stAsigneesIds = new Set<String>();
        List<ServiceAppointment> lstHelper = new List<ServiceAppointment>();
        lstHelper.addall(oldAppointments.values());
        lstHelper.addall(newAppointments.values());

        for( ServiceAppointment objHelper :lstHelper)
        {
            if(objHelper.Assignee__c != null)
                stAsigneesIds.add(objHelper.Assignee__c);
        }

        for (ServiceAppointment objSA : [SELECT Assignee__c, Assignee__r.pse__Resource_Role__c, Assignment__c, Project__r.pse__Start_Date__c, Project__r.pse__End_Date__c, Project__r.Id, /* omonsalve added field */
                                                Work_Order__r.Project_Task__r.Id, Id, SchedStartTime, SchedEndTime, Duration,
                                                Assignment__r.pse__Schedule__c, Assignment__r.pse__Project__c, Assignment__r.pse__Resource__c, Assignment__r.pse__Role__c, /* omonsalve added field */
                                                Assignment__r.pse__Bill_Rate__c, Assignment__r.pse__Cost_Rate_Amount__c /* omonsalve added field */
                                        FROM ServiceAppointment
                                        WHERE Id IN :newAppointments.values()
                                        AND Status != 'Canceled'])
            
        {
            System.debug('objSA==='+objSA);
            if(objSA.Project__c != null)
            {
                if (mpPrjXServiceAppointments.containsKey(objSA.Project__r.Id))
                {
                    mpPrjXServiceAppointments.get(objSA.Project__r.Id).put(objSA.Assignment__r.pse__Resource__c,objSA);
                }
                else
                {
                    mpPrjXServiceAppointments.put(objSA.Project__r.Id, new Map<String,ServiceAppointment>{objSA.Assignment__r.pse__Resource__c => objSA});
                }
                stProjectIds.add(objSA.Project__r.Id);
            }
            // stAsigneesIds.add(objSA.Assignee__c);
        }

        

        if(stAsigneesIds.size() > 0)
        {
            for(ServiceAppointment objSA : [SELECT Assignee__c, Assignee__r.pse__Resource_Role__c, Assignment__c, Project__r.pse__Start_Date__c, Project__r.pse__End_Date__c, Project__r.Id, /* omonsalve added field */
                                            Work_Order__r.Project_Task__r.Id, Id, SchedStartTime, SchedEndTime, Duration,
                                            Assignment__r.pse__Schedule__c, Assignment__r.pse__Project__c, Assignment__r.pse__Resource__c, Assignment__r.pse__Role__c, /* omonsalve added field */
                                            Assignment__r.pse__Bill_Rate__c, Assignment__r.pse__Cost_Rate_Amount__c /* omonsalve added field */
                                            FROM ServiceAppointment
                                            WHERE Assignee__c IN :stAsigneesIds
                                            AND Status != 'Canceled'])
            {
                if (mpAssigneesXSA.containsKey(objSA.Assignee__c))
                {
                    mpAssigneesXSA.get(objSA.Assignee__c).add(objSA);
                }
                else
                {
                    List<ServiceAppointment> lstaux = new List<ServiceAppointment>();
                    lstaux.add(objSA);
                    mpAssigneesXSA.put(objSA.Assignee__c, lstaux);
                }
            }
        }
        
        if(stProjectIds.size() > 0)
        {
            for (pse__Assignment__c objAssignment : [SELECT pse__Schedule__c, pse__Project__c, pse__Resource__c, pse__Role__c, Id,
                                                     pse__Bill_Rate__c, pse__Cost_Rate_Amount__c, (SELECT Id, Work_Order__r.Project_Task__r.Id, Assignee__c FROM Service_Appointments__r),
                                                     (SELECT pse__Assignment__c ,pse__Resource_Role__c, Id, pse__Project_Task__c, pse__Resource__c FROM pse__Project_Task_Assignments__r)
                                                     FROM pse__Assignment__c
                                                     WHERE pse__Project__c IN :stProjectIds])
            {
                if (mpPrjXAssignments.containsKey(objAssignment.pse__Project__c))
                {
                    mpPrjXAssignments.get(objAssignment.pse__Project__c).put(objAssignment.pse__Resource__c,objAssignment);
                }
                else
                {
                    mpPrjXAssignments.put(objAssignment.pse__Project__c, new Map<String,pse__Assignment__c>{objAssignment.pse__Resource__c => objAssignment});
                }
                
                if(mpAssignmentXlistSAs.containsKey(objAssignment.Id))
                {
                    mpAssignmentXlistSAs.get(objAssignment.Id).addAll(objAssignment.Service_Appointments__r);
                }
                else 
                {
                    List<ServiceAppointment> lstSAtemp = new List<ServiceAppointment>();
                    lstSAtemp.addAll(objAssignment.Service_Appointments__r);
                    mpAssignmentXlistSAs.put(objAssignment.Id, lstSAtemp);
                }
                
                if(mpAssignXPTAssignment.containsKey(objAssignment.Id))
                {
                    mpAssignXPTAssignment.get(objAssignment.Id).addAll(objAssignment.pse__Project_Task_Assignments__r);
                }
                else 
                {
                    List<pse__Project_Task_Assignment__c> lstPTAtemp = new List<pse__Project_Task_Assignment__c>();
                    lstPTAtemp.addAll(objAssignment.pse__Project_Task_Assignments__r);
                    mpAssignXPTAssignment.put(objAssignment.Id, lstPTAtemp);
                }
            }
        }

        System.debug('CH - mpPrjXServiceAppointments------> ' + mpPrjXServiceAppointments);
        System.debug('CH - mpPrjXAssignments------> ' + mpPrjXAssignments);
        System.debug('CH - mpAssignmentXlistSAs------> ' + mpAssignmentXlistSAs);
        System.debug('CH - mpAssignXPTAssignment------> ' + mpAssignXPTAssignment);
        System.debug('CH - mpAssigneesXSA------> ' + mpAssigneesXSA);

        for (String strProjectId  : mpPrjXServiceAppointments.keySet())
        {
            System.debug('CH - strProjectId-------->'+strProjectId);
            for (String strAssignee : mpPrjXServiceAppointments.get(strProjectId).keySet() )
            {
                System.debug('CH - strAssignee-------->'+strAssignee);
                pse__Assignment__c objAssignmentAux;
                ServiceAppointment objSAAux;
                List<ServiceAppointment> lstSAaux;

                if(mpPrjXServiceAppointments.containsKey(strProjectId))
                {
                    objSAAux = mpPrjXServiceAppointments.get(strProjectId).containsKey(strAssignee) ? mpPrjXServiceAppointments.get(strProjectId).get(strAssignee) : null;
                }
                else
                {
                    objSAAux = null;
                }

                if(mpPrjXAssignments.containsKey(strProjectId))
                {
                    String strHelp = '';
                    if(strAssignee == null)
                    {
                        strHelp = oldAppointments.get(objSAAux.Id).Assignee__c;
                    }
                    else
                    {
                        strHelp = strAssignee;
                    }
                    objAssignmentAux = mpPrjXAssignments.get(strProjectId).containsKey(strHelp) ? mpPrjXAssignments.get(strProjectId).get(strHelp) : null;
                    if(objAssignmentAux != null)
                    {
                        if (mpAssignmentXlistSAs.containsKey(objAssignmentAux.Id)) 
                        {
                            lstSAaux = mpAssignmentXlistSAs.get(objAssignmentAux.Id);
                        }
                        else 
                        {
                            lstSAaux = null;
                        }
                    }
                }
                else
                {
                    objAssignmentAux = null;
                }

                System.debug('CH - objAssignmentAux-----> '+ objAssignmentAux);
                System.debug('CH - objSAAux-----> '+ objSAAux);
                System.debug('CH - oldAppointments.get(objSAAux.Id).Assignee__c-----> '+ oldAppointments.get(objSAAux.Id).Assignee__c);
                System.debug('CH - objSAAux.Assignee__c-----> '+ objSAAux.Assignee__c);
                
                //scenario 1
                if (oldAppointments.get(objSAAux.Id).Assignee__c != null && objSAAux.Assignee__c != null 
                    && oldAppointments.get(objSAAux.Id).Assignee__c != objSAAux.Assignee__c)
                {
                    Boolean boolDeleteAssigment = true;
                    Integer n = 0;
                    System.debug('contains'+mpAssigneesXSA.containsKey(oldAppointments.get(objSAAux.Id).Assignee__c));
                    if(mpAssigneesXSA.containsKey(oldAppointments.get(objSAAux.Id).Assignee__c))
                    {
                        List<ServiceAppointment> lstTemp = mpAssigneesXSA.get(oldAppointments.get(objSAAux.Id).Assignee__c);
                        System.debug('lstTemp------------->' + lstTemp);
                        for(ServiceAppointment objSAtemp :lstTemp)
                        {
                            if(objSAtemp.Project__r.Id == strProjectId)
                            {
                                 System.debug('FALSE');
                                n++;
                            }

                        }
                    }
                    System.debug('n-------------> ' + n);

                    if(n == 0)
                    {
                        if (objAssignmentAux != null)
                        {
                            List<pse__Project_Task_Assignment__c> lstPTAaux =  mpAssignXPTAssignment.get(objAssignmentAux.Id);
                            if(!lstPTAaux.isEmpty() && lstPTAaux != null)
                            {
                                delete lstPTAaux;
                            }
                            delete objAssignmentAux;
                        }
                    }
                    if(mpPrjXAssignments.get(strProjectId) != null){
                        pse__Assignment__c objAssignmentTemp = mpPrjXAssignments.get(strProjectId).containsKey(objSAAux.Assignee__c) ? mpPrjXAssignments.get(strProjectId).get(objSAAux.Assignee__c) : null;
                        
                        if (objAssignmentTemp != null)
                        {
                            List<pse__Project_Task_Assignment__c> lstPTAaux =  mpAssignXPTAssignment.get(objAssignmentTemp.Id);
                             System.debug('CH -  lstPTAaux-------> '+ lstPTAaux);
                            //scenario 2
                            if(lstPTAaux.isEmpty() || lstPTAaux == null)
                            {
                                pse__Project_Task_Assignment__c pta = new pse__Project_Task_Assignment__c();
                                pta.pse__Project_Task__c = objSAAux.Work_Order__r.Project_Task__r.Id;
                                pta.pse__Resource__c = objSAAux.Assignee__c;
                                pta.pse__Resource_Role__c = objSAAux.Assignee__r.pse__Resource_Role__c;
                                pta.pse__Assignment__c = objAssignmentTemp.Id;
								pta.FBE_IDS_Assignment_IntegrationStatus__c = 'Pending Sync';
                                insert pta;
        
                                objSAAux.Assignment__c = objAssignmentTemp.Id;
                                mpUpdateSAs.put(objSAAux.Id, objSAAux);
                            }
                            //scenario 3
                            if(!lstPTAaux.isEmpty() && lstPTAaux != null)
                            {
                                Boolean boolNewPTA = true;
                                for(pse__Project_Task_Assignment__c objPTAaux : lstPTAaux)
                                {
                                    if(objPTAaux.pse__Project_Task__c == objSAAux.Work_Order__r.Project_Task__r.Id)
                                    {
                                        objSAAux.Assignment__c = objAssignmentTemp.Id;
                                        mpUpdateSAs.put(objSAAux.Id, objSAAux);
                                        boolNewPTA = false;
                                    }
                                }
        
                                if(boolNewPTA != false)
                                {
                                    pse__Project_Task_Assignment__c pta = new pse__Project_Task_Assignment__c();
                                    pta.pse__Project_Task__c = objSAAux.Work_Order__r.Project_Task__r.Id;
                                    pta.pse__Resource__c = objSAAux.Assignee__c;
                                    pta.pse__Resource_Role__c = objSAAux.Assignee__r.pse__Resource_Role__c;
                                    pta.pse__Assignment__c = objAssignmentTemp.Id;
									pta.FBE_IDS_Assignment_IntegrationStatus__c = 'Pending Sync';
                                    insert pta;
        
                                    objSAAux.Assignment__c = objAssignmentTemp.Id;
                                    mpUpdateSAs.put(objSAAux.Id, objSAAux);
                                }
                            }
                        }
                        else 
                        {
                            pse__Schedule__c schedule = new pse__Schedule__c();
                            schedule.pse__Start_Date__c = objSAAux.SchedStartTime.date();
                            schedule.pse__End_Date__c = objSAAux.SchedEndTime.date();
                            schedule.pse__Monday_Hours__c = 0.00;
                            schedule.pse__Tuesday_Hours__c = 0.00;
                            schedule.pse__Wednesday_Hours__c = 0.00;
                            schedule.pse__Thursday_Hours__c = 0.00;
                            schedule.pse__Friday_Hours__c = 0.00;
                            schedule.pse__Saturday_Hours__c = 0.00;
                            schedule.pse__Sunday_Hours__c = 0.00;
                            insert schedule;

                            pse__Assignment__c assignment = new pse__Assignment__c();
                            assignment.pse__Schedule__c = schedule.Id;
                            assignment.pse__Project__c = objSAAux.Project__r.Id;
                            assignment.pse__Resource__c = objSAAux.Assignee__c;
                            assignment.pse__Role__c   = objSAAux.Assignee__r.pse__Resource_Role__c; /* omonsalve added field */
                            assignment.pse__Bill_Rate__c = 0.00;
                            assignment.pse__Cost_Rate_Amount__c = 0.00;
                            insert assignment;

                            pse__Project_Task_Assignment__c pta = new pse__Project_Task_Assignment__c();
                            pta.pse__Project_Task__c = objSAAux.Work_Order__r.Project_Task__r.Id;
                            pta.pse__Resource__c = objSAAux.Assignee__c;
                            pta.pse__Resource_Role__c = objSAAux.Assignee__r.pse__Resource_Role__c; /* omonsalve added field */
                            pta.pse__Assignment__c = assignment.Id;
							pta.FBE_IDS_Assignment_IntegrationStatus__c = 'Pending Sync';
                            insert pta;

                            objSAAux.Assignment__c = assignment.Id;
                            mpUpdateSAs.put(objSAAux.Id, objSAAux);
                        }
                    }
                }
            }
        }
        update mpUpdateSAs.values();
        System.debug('CH - Limits--------->' + Limits.getDMLStatements());
       
    }

    /**
    * Orlando Monsalve
    * 2019-11-21
    * FinancialForce.com, Inc.
    * omonsalve.p@financialforce.com
    *
    * This method is called from ServiceAppointmentTrigger.trigger. Its purpose is to update the pse__Schedule__c lookup
    * from the pse__Assignment__c
    */
    public static void assignmentDateUpdate(Map<Id, ServiceAppointment> oldAppointments, Map<Id, ServiceAppointment> newAppointments)
    {
        preventRecursion = true;

        Map<Id, ServiceAppointment> mpOldSrvApp = new Map <Id, ServiceAppointment>();
        List<SObject> scheduleUpdate = new List<SObject>();
        Map<Id,SObject> mpScheduleUpdate = new  Map<Id,SObject>();

        for(ServiceAppointment objServiceAppointments : [SELECT Assignment__c, Assignment__r.pse__Schedule__r.pse__End_Date__c, Assignment__r.pse__Schedule__r.pse__Start_Date__c, Id,
                                                                SchedStartTime, SchedEndTime, ActualEndTime, ActualStartTime, Assignment__r.pse__Schedule__c
                                                        FROM ServiceAppointment
                                                        WHERE Id IN :oldAppointments.values()
                                                        AND Status != 'Canceled'])
        {
            system.debug('@@ actual time ' +objServiceAppointments.ActualStartTime);
            system.debug('@@ objServiceAppointments ' +objServiceAppointments);
            if(!mpOldSrvApp.containsKey(objServiceAppointments.Id))
            {
                mpOldSrvApp.put(objServiceAppointments.Id,objServiceAppointments);
            }
        }

        for (ServiceAppointment sa : [SELECT Assignment__c, Assignment__r.pse__Schedule__r.pse__End_Date__c, Assignment__r.pse__Schedule__r.pse__Start_Date__c, Id,
                                             SchedStartTime, SchedEndTime, ActualEndTime, ActualStartTime, Assignment__r.pse__Schedule__c
                                      FROM ServiceAppointment
                                      WHERE Id IN :newAppointments.values()
                                      AND Status != 'Canceled'])
        {
             system.debug('@@ sa ' +sa);
            if(mpOldSrvApp.get(sa.Id).Assignment__r.pse__Schedule__r.pse__Start_Date__c != null && sa.SchedStartTime != null)
            {
                 System.debug('Entro 1');
                if(sa.SchedStartTime.date() < mpOldSrvApp.get(sa.Id).Assignment__r.pse__Schedule__r.pse__Start_Date__c)
                {
                    sa.Assignment__r.pse__Schedule__r.pse__Start_Date__c = sa.SchedStartTime.date();
                    mpScheduleUpdate.put((String)sa.getSObject('Assignment__r').getSObject('pse__Schedule__r').get('Id'),(sa.getSObject('Assignment__r').getSObject('pse__Schedule__r')));
                }
            }

            if(mpOldSrvApp.get(sa.Id).Assignment__r.pse__Schedule__r.pse__End_Date__c != null && sa.SchedEndTime != null)
            {
                 System.debug('Entro 2');
                if(sa.SchedEndTime.date() > mpOldSrvApp.get(sa.Id).Assignment__r.pse__Schedule__r.pse__End_Date__c)
                {
                    sa.Assignment__r.pse__Schedule__r.pse__End_Date__c = sa.SchedEndTime.date();
                    mpScheduleUpdate.put((String)sa.getSObject('Assignment__r').getSObject('pse__Schedule__r').get('Id'),(sa.getSObject('Assignment__r').getSObject('pse__Schedule__r')));
                }
            }
              
            if(mpOldSrvApp.get(sa.Id).Assignment__r.pse__Schedule__r.pse__Start_Date__c != null && sa.ActualStartTime != null)

            {
                 System.debug('Entro 3');
                if(sa.ActualStartTime.date() <  mpOldSrvApp.get(sa.Id).Assignment__r.pse__Schedule__r.pse__Start_Date__c)
                {
                    sa.Assignment__r.pse__Schedule__r.pse__Start_Date__c = sa.ActualStartTime.date();
                    mpScheduleUpdate.put((String)sa.getSObject('Assignment__r').getSObject('pse__Schedule__r').get('Id'),(sa.getSObject('Assignment__r').getSObject('pse__Schedule__r')));
                }
            }

            if(mpOldSrvApp.get(sa.Id).Assignment__r.pse__Schedule__r.pse__End_Date__c != null && sa.ActualEndTime != null)
            {
                // System.debug('Entro 4');
                if(sa.ActualEndTime.date() > mpOldSrvApp.get(sa.Id).Assignment__r.pse__Schedule__r.pse__End_Date__c)
                {
                    sa.Assignment__r.pse__Schedule__r.pse__End_Date__c = sa.ActualEndTime.date();
                    mpScheduleUpdate.put((String)sa.getSObject('Assignment__r').getSObject('pse__Schedule__r').get('Id'),(sa.getSObject('Assignment__r').getSObject('pse__Schedule__r')));
                }
            }
        }

        // System.debug('---------->' + mpScheduleUpdate);

        update mpScheduleUpdate.values();
    }

    /**
    * Thomas Davis
    * 2019-02-06
    * FinancialForce.com, Inc.
    * thdavis@financialforce.com
    *
    * This method is called from ServiceAppointmentTrigger.trigger. Its purpose is to keep the Status of the parent WorkOrder
    * in sync with the ServiceAppointment status.
    */
    public static void synchronizeWorkOrderStatus(Map<Id, ServiceAppointment> oldMap, Map<Id, ServiceAppointment> newMap)
    {
        preventRecursion = true;
        Boolean isChangedStatus = false;

        Set<Id> workOrderIds = new Set<Id>();
        Map<Id, List<ServiceAppointment>> workOrderToServiceAppointmentMap = new Map<Id, List<ServiceAppointment>>();
        List<SObject> workOrderUpdates = new List<SObject>();

        for(ServiceAppointment sa : newMap.values()){
            ServiceAppointment objSA = oldMap.get(sa.ID);
            if(sa.Work_Order__c != null)
                workOrderIds.add(sa.Work_Order__c);
            if(sa.Status != objSA.status && sa.Work_Order__c != null){
                isChangedStatus = true;
            }
        }
        if(isChangedStatus){
            if(workOrderIds.size() > 0)
        {
            for (ServiceAppointment sa : [ SELECT Status, Work_Order__c FROM ServiceAppointment WHERE Work_Order__c IN :workOrderIds ])
            {
                if (!workOrderToServiceAppointmentMap.containsKey(sa.Work_Order__c))
                {
                    workOrderToServiceAppointmentMap.put(sa.Work_Order__c, new List<ServiceAppointment>());
                }
                
                workOrderToServiceAppointmentMap.get(sa.Work_Order__c).add(sa);
            }
        }

        List<ServiceAppointment> appointments =
        [
                SELECT Work_Order__r.Status
                FROM ServiceAppointment
                WHERE Id IN :newMap.values()
        ];

        for (ServiceAppointment sa : appointments)
        {
            if (oldMap.get(sa.Id).Status != newMap.get(sa.Id).Status)
            { 
                if (newMap.get(sa.Id).get('Status') == 'Scheduled' || newMap.get(sa.Id).get('Status') == 'New' || newMap.get(sa.Id).get('Status') == 'Dispatched')
                {
                    if(sa.Work_Order__r.Status != 'FF - Submitted'){
                      sa.Work_Order__r.Status = 'FF - Submitted';
                    workOrderUpdates.add(sa.getSObject('Work_Order__r'));  
                    }
                    
                }

                if (newMap.get(sa.Id).get('Status') == 'Click_Remote Execution' || newMap.get(sa.Id).get('Status') == 'Click_Onsite' || newMap.get(sa.Id).get('Status') == 'In Progress' || newMap.get(sa.Id).get('Status') == 'Click_Travel')
                {
                    if(sa.Work_Order__r.Status != 'FF - Work In Progress'){
                       sa.Work_Order__r.Status = 'FF - Work In Progress';
                    workOrderUpdates.add(sa.getSObject('Work_Order__r')); 
                    }
                    
                }

                if (newMap.get(sa.Id).get('Status') == 'Completed' || newMap.get(sa.Id).get('Status') == 'Cannot Complete'
                        && workOrderToServiceAppointmentMap.get(sa.Work_Order__c) != null)
                {
                    for (ServiceAppointment saObj : workOrderToServiceAppointmentMap.get(sa.Work_Order__c))
                    {
                        if (saObj.Status != 'Completed' && saObj.Status != 'Cannot Complete') return;
                    }

                    sa.Work_Order__r.Status = 'FF - Closed';
                    workOrderUpdates.add(sa.getSObject('Work_Order__r'));
                }

                if ((newMap.get(sa.Id).get('Status') == 'Canceled') && workOrderToServiceAppointmentMap.get(sa.Work_Order__c) != null)
                {
                    for (ServiceAppointment saObj : workOrderToServiceAppointmentMap.get(sa.Work_Order__c))
                    {
                        if (saObj.Status != 'Canceled') return;
                    }

                    sa.Work_Order__r.Status = 'FF - Cancelled';
                    workOrderUpdates.add(sa.getSObject('Work_Order__r'));
                }
            }
        }
        try{
            update workOrderUpdates;
        }catch(Exception e){
            System.debug('Error '+e.getMessage());
        }
            
        }
            

        
        
    }

    /**
    * Orlando Monsalve
    * 2019-11-12
    * FinancialForce.com, Inc.
    * omonsalve.p@financialforce.com
    *
    * This method is called from ServiceAppointmentTrigger.trigger. Its purpose is to keep the Status of the Assigment
    * in sync with the ServiceAppointment status.
    */
    public static void updateAssignmentStatus(Map<Id, ServiceAppointment> oldMap, Map<Id, ServiceAppointment> newMap)
    {
        //System.debug('--->oldMap<---' + oldMap);
        //System.debug('--->newMap<---' + newMap);
        // runOnce = true;

        Set<Id> assignmentIds = new Set<Id>();
        Map<Id, List<ServiceAppointment>> assignmentXSA = new Map<Id, List<ServiceAppointment>>();
        List<SObject> assignmentUpdate = new List<SObject>();
        Boolean isChangedStatus = false;
        for (ServiceAppointment sa : newMap.values())
        {
            ServiceAppointment objSA = oldMap.get(sa.Id);
            if(sa.Assignment__c != null){
              assignmentIds.add(sa.Assignment__c);  
            }
                
            if(sa.Status != objSA.Status && sa.Assignment__c != null){
                isChangedStatus = true;
            }
        }
        //System.debug('--->assignmentIds<---' + assignmentIds);

        if(isChangedStatus){
             if(assignmentIds.size() > 0)
        {
            for (ServiceAppointment sa : [ SELECT Status, Assignment__c, Assignment__r.pse__Status__c FROM ServiceAppointment WHERE Assignment__c IN :assignmentIds ])
            {
                if (!assignmentXSA.containsKey(sa.Assignment__c))
                {
                    assignmentXSA.put(sa.Assignment__c, new List<ServiceAppointment>());
                }
                
                assignmentXSA.get(sa.Assignment__c).add(sa);
            }
            //System.debug('--->assignmentXSA<---' + assignmentXSA);
        }

        List<ServiceAppointment> appointments =
        [
                SELECT Assignment__r.pse__Status__c, Assignment__c
                FROM ServiceAppointment
                WHERE Id IN :newMap.values()
        ];
        //System.debug('--->appointments<---' + appointments);

        for (ServiceAppointment sa : appointments)
        {
             //System.debug('--->sa-ID<---' + sa.Id);
             //System.debug('--->assignmentXSA.get(sa.Assignment__c)<---' + assignmentXSA.get(sa.Assignment__c));

            if (oldMap.get(sa.Id).Status != newMap.get(sa.Id).Status && sa.Assignment__c != null)
            {
                if (newMap.get(sa.Id).get('Status') == 'Click_Remote Execution' || newMap.get(sa.Id).get('Status') == 'In Progress' || newMap.get(sa.Id).get('Status') == 'Click_Onsite' || newMap.get(sa.Id).get('Status') == 'Click_Pause' || newMap.get(sa.Id).get('Status') == 'Click_Travel')
                {
                    sa.Assignment__r.pse__Status__c = 'In Progress';
                    assignmentUpdate.add(sa.getSObject('Assignment__r'));
                }

                if (newMap.get(sa.Id).get('Status') == 'Scheduled' && (sa.Assignment__r.pse__Status__c == 'Cancelled' || sa.Assignment__r.pse__Status__c == 'Closed'))
                {
                    sa.Assignment__r.pse__Status__c = 'Scheduled';
                    assignmentUpdate.add(sa.getSObject('Assignment__r'));
                }

                if (newMap.get(sa.Id).get('Status') == 'Canceled' && assignmentXSA.get(sa.Assignment__c) != null)
                {
                    String strStatus = 'Cancelled';
                    for (ServiceAppointment saObj : assignmentXSA.get(sa.Assignment__c))
                    {
                        if (saObj.Status != 'Canceled')
                        {
                            if (saObj.Status == 'Cannot Complete' || saObj.Status == 'Completed')
                            {
                                strStatus = 'Closed';
                            }
                            else
                            {
                                return;
                            }
                        }

                    }
                    if(sa.Assignment__r != null){
                        sa.Assignment__r.pse__Status__c = strStatus;
                        assignmentUpdate.add(sa.getSObject('Assignment__r'));
                    }
                }

                //System.debug('(newMap.get(sa.Id).get(Status)' + newMap.get(sa.Id).get('Status'));
                //System.debug('assignmentXSA.get(sa.Assignment__c)' + assignmentXSA.get(sa.Assignment__c));


                if (newMap.get(sa.Id).get('Status') == 'Cannot Complete' || newMap.get(sa.Id).get('Status') == 'Completed' 
                    && assignmentXSA.get(sa.Assignment__c) != null)
                {
                    //System.debug('--->Incomplete IF<---');
                    for (ServiceAppointment saObj : assignmentXSA.get(sa.Assignment__c))
                    {
                        if (saObj.Status != 'Cannot Complete' && saObj.Status != 'Completed')
                        {
                            if (saObj.Status == 'Canceled')
                            {

                            }
                            else
                            {
                                return;
                            }
                        }
                    }
                    if(sa.Assignment__r != null){
                        //System.debug('--->Assignment__r is not null<---');
                        sa.Assignment__r.pse__Status__c = 'Closed';
                        assignmentUpdate.add(sa.getSObject('Assignment__r'));
                        //System.debug('--->assignmentUpdate<---' + assignmentUpdate);
                        
                    }
                }
            }
        }

        if(!assignmentUpdate.isEmpty())
        {
            update assignmentUpdate;
        }
        }
    }

    /** 
    * Thomas Davis
    * 2019-02-07
    * FinancialForce.com, Inc.
    * thdavis@financialforce.com
    *
    * This method is called from ServiceAppointmentTrigger.trigger. Its purpose is to clone the Service Appointment when
    * the Physical_Helper_Requested_by_Engineer__c field is set from false to true and a sibling Service Appointment does not
    * exist where the Assist_Service_Appointment__c field is true.
    */
       public static void physicalHelperRequested(Map<Id, ServiceAppointment> oldMap, List<ServiceAppointment> serviceAppointments)
    {
        Set<Id> workOrderIds = new Set<Id>();
        Map<Id, List<ServiceAppointment>> workOrderToServiceAppointmentMap = new Map<Id, List<ServiceAppointment>>();
        List<ServiceAppointment> serviceAppointmentInserts = new List<ServiceAppointment>();
        Boolean isChangedStatus = false;
        
        for (ServiceAppointment sa : serviceAppointments)
        {
            ServiceAppointment objSA = oldMap.get(sa.ID);
            if(sa.Work_Order__c != null){
                workOrderIds.add(sa.Work_Order__c);
            }
            if(sa.Physical_Helper_Requested_by_Engineer__c != objSA.Physical_Helper_Requested_by_Engineer__c){
                isChangedStatus = true;
            }
            
        }
        if(isChangedStatus){
             if(workOrderIds.size() > 0)
        {
            for (ServiceAppointment sa : [ SELECT Assist_Service_Appointment__c, Work_Order__c FROM ServiceAppointment WHERE Work_Order__c IN :workOrderIds ])
            {
                if (!workOrderToServiceAppointmentMap.containsKey(sa.Work_Order__c))
                {
                    workOrderToServiceAppointmentMap.put(sa.Work_Order__c, new List<ServiceAppointment>());
                }
                
                workOrderToServiceAppointmentMap.get(sa.Work_Order__c).add(sa);
            }
        }

        for (ServiceAppointment sa : serviceAppointments)
        {
            if (!oldMap.get(sa.Id).Physical_Helper_Requested_by_Engineer__c && sa.Physical_Helper_Requested_by_Engineer__c)
            {
                if (workOrderToServiceAppointmentMap.get(sa.Work_Order__c) != null)
                {
                    for (ServiceAppointment sibling : workOrderToServiceAppointmentMap.get(sa.Work_Order__c))
                    {
                        if (sibling.Assist_Service_Appointment__c) return;
                    }

                    Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
                    ServiceAppointment assistSA = new ServiceAppointment();
                    assistSA.Assist_Service_Appointment__c = true;
                    assistSA.EarliestStartTime = sa.SchedStartTime;
                    assistSA.DueDate = sa.SchedEndTime;
                    assistSA.ContactId = sa.ContactId;
                    assistSA.Duration = sa.Duration;
                    assistSA.DurationType = sa.DurationType;
                    assistSA.Subject = sa.Subject;
                    assistSA.Project__c = sa.Project__c;
                    assistSA.Status = 'New';
                    assistSA.Work_Order__c = sa.Work_Order__c;
                    assistSA.ParentRecordId = sa.Work_Order__c;
                    assistSA.RecordTypeId = installationBadgeRecordType;
                    serviceAppointmentInserts.add(assistSA);
                }
            }
        }

        insert serviceAppointmentInserts;
            
        }
       
    }
    
    /**************
 * @ Method Name       : populatePMRequestedTime
 * @ Description       : This method is used  When PM Click on Get Appoinentment Tab on SA then nulify the Schedule Start, End Date & Assignee
 *                       Created as part of Feature #7868157.
 * @ CreatedBy         : Deloitte
 * @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    public static void populatePMRequestedTime(List<ServiceAppointment> newServiceAppointmentList , Map<Id, ServiceAppointment> oldServiceAppointment){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName == 'PSA Project Manager' || profileName == 'PSA Resource Manager'){
            for(ServiceAppointment sa: newServiceAppointmentList){
                ServiceAppointment oldSA = oldServiceAppointment.get(sa.Id);

                if( sa.SchedStartTime != null && profileName == 'PSA Project Manager'){
                    sa.Requested_Start_Time__c = sa.SchedStartTime;
                    sa.Requested_End_Time__c = sa.SchedEndTime; 
                    sa.Assignee__c =  null; 
                   sa.Assignment__c = null;
                }
                else{
                    if(profileName == 'PSA Resource Manager' && oldSA.SchedStartTime != null && sa.SchedStartTime == null ){

                        sa.Assignee__c =  null;
                        sa.Assignment__c = null;
                    }                        
                }                
            }
        }
    } 
    
    public static void createTimeSheetforSA(List<ServiceAppointment> newServiceAppointmentList, Map<Id, ServiceAppointment> oldAppointments){
      
        List<ServiceAppointment> assignedSAList = new List<ServiceAppointment>();
        Map<Id, AssignedResource> serviceResourceMap = new Map<Id, AssignedResource>(); 
        Set<Id> assigneeId = new Set<Id>();
        List<ServiceAppointment> saList = new List<ServiceAppointment>();

        for(ServiceAppointment sa : newServiceAppointmentList){
            system.debug('sa===='+sa);
            ServiceAppointment oldSA = oldAppointments.get(sa.Id);
            if(sa.Status == 'Dispatched' && oldSA.Status != 'Dispatched' && (sa.Assignee__c != null || sa.AppointmentType == 'Shadow Appointment') ){  
                //System.debug('sa.Assignee__c'+sa.Assignee__c);
                saList.add(sa); 
                assigneeId.add(sa.Id);
            }        
        }

        List<AssignedResource> resourceList = new List<AssignedResource>([SELECT Id,ServiceResourceId,ServiceResource.Name,ServiceAppointmentId,ServiceResource.RelatedRecordId FROM AssignedResource WHERE ServiceAppointmentId IN: assigneeId]);
        for(AssignedResource ar : resourceList){
            serviceResourceMap.put(ar.ServiceAppointmentId, ar);
        }
        
        if(!saList.isEmpty() && !resourceList.isEmpty() && !serviceResourceMap.isEmpty() ){
            TimeSheetTriggerHandler.createTimeSheet(saList, resourceList);  
        }
    }
    
    //Added for the story #9873713 to match Contact(Assignee)'s timezone with the ServiceAppointment's 'Resource Time_Zone' field
    // here adding Contact's timezone value in the Res_timeZone__c, so that it can be used in the'Resource Time_Zone' formula feild
    public static void populateTimeZone(List<ServiceAppointment> newAppointmentList, Map<Id, ServiceAppointment> oldAppointmentsMap){
        System.debug('inside timezone');
        Set<Id> contIds = new Set<Id>(); 
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        
        for(ServiceAppointment sa: newAppointmentList){
            if(oldAppointmentsMap==null || sa.Assignee__c!= oldAppointmentsMap.get(sa.Id).Assignee__c){
                contIds.add(sa.Assignee__c);
                saList.add(sa);
            }
        }
        if(!contIds.isEmpty()){
            Map<String,String> valueLabelMap = new Map<String,String>(); 
            Schema.DescribeFieldResult field = Contact.TimeZone__c.getDescribe();
            for(Schema.PicklistEntry entry : field.getPicklistValues()){
                valueLabelMap.put(entry.getValue(),entry.getLabel());  
            }
            
            Map<Id,Contact> contMap= new Map<Id,Contact>([Select id,TimeZone__c from contact where id IN : contIds]);      
            
            for(ServiceAppointment sa :saList){
                if(sa.Assignee__c==null){
                    sa.Res_timeZone__c =null;
                }else{
                    sa.Res_timeZone__c = valueLabelMap.get(contMap.get(sa.Assignee__c).TimeZone__c); 
                }            
            }
        }
    }
    
    
    public static void updateServiceAppointmentWithNewSA(Map<Id, ServiceAppointment> oldAppointments,List<ServiceAppointment> newSAList)
    {
        Map <Id,ServiceAppointment> mapSA = new Map <Id,ServiceAppointment >();
        for (ServiceAppointment sappt : newSAList) {   
            if (sappt.Status == 'Scheduled'){
                sappt.SchedEndTime = Datetime.now();
            }
                
        } 
        if ( mapSA.size() > 0 ) {
            List<ServiceAppointment> updatechildList = new List<ServiceAppointment>();
            updatechildList = [ SELECT Id, FSL__Related_Service__c, Status FROM ServiceAppointment WHERE FSL__Related_Service__c IN : mapSA.keySet() ]; 
            system.debug('updatechildList '+updatechildList);
            if  ( updatechildList.size() > 0  )  {
                for  (  ServiceAppointment con : updatechildList  )  {
                    con.Status  = mapSA.get( con.FSL__Related_Service__c ).Status;
                }
                try{
                update updatechildList;
                }catch(Exception e){ system.debug('Error in updateSA '+e.getMessage());}
            } 
        }
    }
   
    
    //Below method added by sivakumari for user termination feature
   /* public static void cloneServiceAppointment(List<ServiceAppointment> newAppointmentList, Map<Id, ServiceAppointment> oldAppointmentsMap){
      
        set<id> serviceResourceIds = new set<id>();
        List<AssignedResource> resourceList = new List<AssignedResource>([SELECT Id,ServiceResourceId,ServiceResource.Name,ServiceAppointmentId,ServiceResource.IsActive FROM AssignedResource]);
        for(AssignedResource ar : resourceList){
            if(ar.ServiceResource.isActive == false){
                serviceResourceIds.add(ar.id);     
            }
    
            
        }*/
    
    /**************
 * @ Method Name       : createWorkOrderForInCompleteAppointment
 * @ Description       : This method is to create new Work order when SA status is updated as either Completed or Cannot Completed  
 *                       Created as part of Feature #8844917.
 * @ CreatedBy         : Deloitte
 * @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
      /* public static void createWorkOrderForInCompleteAppointment(Map<Id, ServiceAppointment> oldAppointments, Map<Id, ServiceAppointment> newAppointments ){
        Map<Id, String> WorkOrderXAppointmentMap = new Map<Id, String>();
        List <WorkOrder> insertWOList = new List <WorkOrder>();
           
        for(ServiceAppointment sa : newAppointments.values()){
            system.debug('sa===='+sa);
            ServiceAppointment oldSA = oldAppointments.get(sa.Id);
            //Click_Incomplete
            if((sa.Status == 'Click_Incomplete' && sa.Incomplete_Reason__c != null && sa.Additional_Effort__c != 'No Additional Effort Required' && oldSA.Status !='Click_Incomplete') || 
               (sa.Status == 'Completed' && sa.Additional_Effort__c != 'No Additional Effort Required' && oldSA.Status !='Completed')){
                WorkOrderXappointmentMap.put(sa.Work_Order__c, sa.Additional_Effort__c);  
            } 
        }   
        List<WorkOrder> woList =[SELECT Id,WO_Type__c,
                                 Subject,
                                 Project_Task__c,
                                 AccountId,
                                 ContactId,
                                 Delivery_Method__c,
                                 Status,
                                 Resource_Type__c,
                                 Auto_Dispatch__C,
                                 DPSType__c,
                                 Project__c,
                                 Project_Location__c,
                                 Duration,
                                 RecordTypeId,
                                 City,
                                 Country,
                                 PostalCode,
                                 State,
                                 Street,
                                 Order__c,
                                 WorkTypeId,
                                 Schedule_Type__c
                                 FROM WorkOrder WHERE Id IN: WorkOrderXAppointmentMap.KeySet()];
           
        for(WorkOrder wo : woList){
            String ScheduleType = WorkOrderXAppointmentMap.get(wo.Id);
            WorkOrder woObj = new WorkOrder();
            woObj.WO_Type__c = 'Install';
            woObj.Subject = wo.Subject;
            woObj.Project_Task__c = wo.Project_Task__c;
            woObj.AccountId = wo.AccountId;
            woObj.ContactId = wo.ContactId;
            woObj.Delivery_Method__c = wo.Delivery_Method__c;
            woObj.Status = wo.Status;
            woObj.Resource_Type__c = wo.Resource_Type__c;
            woObj.Auto_Dispatch__C = wo.Auto_Dispatch__c;
            woObj.DPSType__c = wo.DPSType__c;
            woObj.Project__c = wo.Project__c;
            woObj.Project_Location__c = wo.Project_Location__c;
            woObj.Duration = wo.Duration;
            woObj.RecordTypeId = wo.RecordTypeId;
            woObj.City = wo.City;
            woObj.Country = wo.Country;
            woObj.PostalCode = wo.PostalCode;
            woObj.State = wo.State;
            woObj.Street = wo.Street;
            woObj.Order__c = wo.Order__c;
            woObj.WorkTypeId = wo.WorkTypeId;
            if(ScheduleType == 'Appointment Task'){
                woObj.Schedule_Type__c = 'Appointment';
            }
            else
            {
                woObj.Schedule_Type__c = 'Activity';
            }
            insertWOList.add(woObj);
               
        }
        insert insertWOList;
    } */
         
    }