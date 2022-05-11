/* -----------------------------------------------------------------------------------------------------------------------
Name:         NonAgentWoCreationController
Description:  Rest class to initiate WO creation 
----------------------------------------------------------------------------------------------------------------------------
Date          Version        Author               Summary of Changes 
---------------------------------------------------------------------------------------------------------------------------
07/03/2020     1.0          Anvesh Arveti           August Release
-------------------------------------------------------------------------------------------------------------------------- */

global class NonAgentWoCreationController {
	global static boolean nonagentWoflag = false;
	
   /* public static void RtpWOCreation(List<String> rtpWoIdList){
		
	  try{
		System.debug('Inside RTP Method');	
		if(rtpWoIdList.size() > 0)
		{	
			String parentWONumber = rtpWoIdList.get(0);
			System.debug('ParentRTPWONumber '+ parentWONumber);
			String rtpWoId = '';
			rtpWoId = RtrRtpWOCreation('RTP',parentWONumber,'','','');
			system.debug('RTP wo Created with the ID -'+rtpWoId);
		}	
       }catch(Exception e){
		system.debug('Exception on WO CreateNonAgentWORTP Method'+e);  
	   }	  
	}
    
    public static String RtrRtpWOCreation(String CreationType, String parentWONo, String servicestartDate, String serviceendDate,String sappId){
		
		try{	
		list < Workorder > workOrderList = new List < Workorder > ();
		list < ServiceAppointment > sAList = new List < ServiceAppointment > ();
		list < DispatchDefaults__c > dDList = new List < DispatchDefaults__c > ();
		list < DispatchInstruction__c > parentdInstList = new List < DispatchInstruction__c > ();
		list < DispatchInstruction__c > childdInstList = new List < DispatchInstruction__c > ();
		list < Customer_Reminder__c > parentcRList = new List < Customer_Reminder__c > ();
		list < Customer_Reminder__c > childcRList = new List < Customer_Reminder__c > ();
		list < Dispatch_Alert__c > parentdAlertList = new List < Dispatch_Alert__c > ();
		list < Dispatch_Alert__c > childdAlertList = new List < Dispatch_Alert__c > ();
		list < Special_Instruction__c > parentspclinstList = new List < Special_Instruction__c > ();
		list < Special_Instruction__c > childspclinstList = new List < Special_Instruction__c > ();
		WorkOrder parentworkorderRecord = new WorkOrder();
		WorkOrder childworkorderRecord = new WorkOrder();
		ServiceAppointment parentsrvapp = new ServiceAppointment();
		ServiceAppointment childsrvapp =  new ServiceAppointment();
		DispatchDefaults__c parentdd = new DispatchDefaults__c();
		DispatchDefaults__c childdd = new DispatchDefaults__c();
		List<ConvergeWorkOrderInboundLog__c> convergeWorkOrderInboundLogs=new List<ConvergeWorkOrderInboundLog__c>();
		
		 parentworkorderRecord = [ Select Id, AccountId, CaseId,Out_of_Warranty__c, CheckForServiceTypeEqualsLaborOnly__c,CheckForServiceTypeEqualsRepairCenter__c,CheckForServiceTypeEqualsPartsOnly__c,AssetId,ContactId,Region__c,DPS_BUID__c,DPS_Region__c,DPS_Sub_Region__c,Service_Country__c,CurrencyIsoCode,CountryCode__c,WO_Type__c, Status,Entitlement_Details__c,Service_Type__c,Product_Classification__c,Approve_Reject_Comments__c,Approve_Reject_Reason__c,Approved_Rejected__c,DSP__c,CallType__c,Delivery_Option__c,DPSType__c,DSPName__c,EventDateTime__c,FSD_DSP_Selection__c,IsConvergeWorkOrder__c,Labor_Status__c,Need_by_Date__c,Need_by_Time__c,
		OperationType__c,Priority,Reason_for_repeat_Work_Order__c,ContactRole__c,Schedule_Enable_Flag__c,Service_Option__c,SiteAccessConfirmed__c,SLAEndDate__c,SLAStartDate__c,Timezone__c,WorkOrderTarget__c,EntitlementEndDate__c,AdditionContactRole__c,AdditionalContactId__c,After_Hours_Contact__c,Bill_To__c,EntitlementStartDate__c,Special_Handling_Visibility__c,Federal__c,Unscheduled_Reason__c,Ground_Shipment_Flag__c From workOrder Where PartnerWorkOrderNumber__c =: parentWONo ];
		
		 parentsrvapp = [select id,RTR_Reason__c,Additional_Scheduling_Contact__c,Status,Event_Type__c,Alternate_Account__c,Address_Line_2__c,State__c,state,Labor_Type__c,Address_Line_1__c,City,City__c,Country__c,Country,PostalCode,Zip__c,Scheduling_Contact__c,ContactId,Primary_Contact__c,Primary_Contact_Role__c,CurrencyIsoCode,DueDate,EarliestStartTime,RecordTypeId,Service_Date__c,Service_Start__c,Service_Start_UI__c,Service_End__c,Service_End_UI__c,RTR_Comments__c from ServiceAppointment where Work_Order__c =: parentworkorderRecord.id and (Event_Type__c = 'Labor' or Event_Type__c = 'Main' ) limit 1 ];
		 
		 
		 parentdd =[select Id, ReverseAgency__c,OutOfWarranty__c,CompleteCareOption__c,ServiceHours__c,Complete_Care_Option__c,OutOfHours__c,ProSupport__c,DigitalEntitlements__c,DSP_Override_Request__c,KYHDOption__c,BasicEntitlement__c,Keep_Your_Components__c,DataRecovery__c,ServiceLevel__c,Work_Order__c from DispatchDefaults__c where Work_Order__c =: parentworkorderRecord.id limit 1 ];
		 
		 
		 if(parentworkorderRecord != null){
			
		childworkorderRecord.AccountId = parentworkorderRecord.AccountId;
		childworkorderRecord.Out_of_Warranty__c  = parentworkorderRecord.Out_of_Warranty__c; 
		childworkorderRecord.CheckForServiceTypeEqualsRepairCenter__c = parentworkorderRecord.CheckForServiceTypeEqualsRepairCenter__c;
		childworkorderRecord.CheckForServiceTypeEqualsLaborOnly__c = parentworkorderRecord.CheckForServiceTypeEqualsLaborOnly__c;
		childworkorderRecord.CheckForServiceTypeEqualsPartsOnly__c = parentworkorderRecord.CheckForServiceTypeEqualsPartsOnly__c; 
		childworkorderRecord.Ground_Shipment_Flag__c = parentworkorderRecord.Ground_Shipment_Flag__c;  	   
		childworkorderRecord.AssetId = parentworkorderRecord.AssetId;
		childworkorderRecord.CaseId = parentworkorderRecord.CaseId;
		childworkorderRecord.ContactId = parentworkorderRecord.ContactId;
		childworkorderRecord.Region__c = parentworkorderRecord.Region__c;
		childworkorderRecord.DPS_BUID__c = parentworkorderRecord.DPS_BUID__c;
		childworkorderRecord.DPS_Region__c = parentworkorderRecord.DPS_Region__c;
		childworkorderRecord.DPS_Sub_Region__c = parentworkorderRecord.DPS_Sub_Region__c;
		childworkorderRecord.Service_Country__c = parentworkorderRecord.Service_Country__c;
		childworkorderRecord.CurrencyIsoCode = parentworkorderRecord.CurrencyIsoCode;
		childworkorderRecord.CountryCode__c = parentworkorderRecord.CountryCode__c;
		childworkorderRecord.WO_Type__c = parentworkorderRecord.WO_Type__c;
		childworkorderRecord.Status = 'Open';
		childworkorderRecord.RecordTypeId = system.label.Dispatch_Record_Type_Create;
		childworkorderRecord.Entitlement_Details__c = parentworkorderRecord.Entitlement_Details__c;
		childworkorderRecord.Service_Type__c = 'Labor Only';
		childworkorderRecord.CheckForServiceTypeEqualsPartsOnly__c = false;
		childworkorderRecord.Product_Classification__c = parentworkorderRecord.Product_Classification__c;
		//childworkorderRecord.Approve_Reject_Comments__c = parentworkorderRecord.Approve_Reject_Comments__c;
		childworkorderRecord.Approve_Reject_Reason__c = parentworkorderRecord.Approve_Reject_Reason__c;
		childworkorderRecord.Approved_Rejected__c = parentworkorderRecord.Approved_Rejected__c;	
		childworkorderRecord.CallType__c = parentworkorderRecord.CallType__c;
		childworkorderRecord.Delivery_Option__c = parentworkorderRecord.Delivery_Option__c;
		childworkorderRecord.DPSType__c = parentworkorderRecord.DPSType__c;		
		childworkorderRecord.EventDateTime__c = parentworkorderRecord.EventDateTime__c;
		childworkorderRecord.FSD_DSP_Selection__c = parentworkorderRecord.FSD_DSP_Selection__c;
		childworkorderRecord.IsConvergeWorkOrder__c = parentworkorderRecord.IsConvergeWorkOrder__c;
		childworkorderRecord.Labor_Status__c = 'Open';
		childworkorderRecord.Bill_To__c = parentworkorderRecord.Bill_To__c;   
		childworkorderRecord.Need_by_Date__c = parentworkorderRecord.Need_by_Date__c;
		childworkorderRecord.Need_by_Time__c = parentworkorderRecord.Need_by_Time__c;
		childworkorderRecord.OperationType__c = parentworkorderRecord.OperationType__c;
		childworkorderRecord.Priority = parentworkorderRecord.Priority;
		childworkorderRecord.ParentWorkOrderId = parentworkorderRecord.Id;
		childworkorderRecord.ContactRole__c = parentworkorderRecord.ContactRole__c;
		childworkorderRecord.AdditionalContactId__c = parentworkorderRecord.AdditionalContactId__c;
		childworkorderRecord.After_Hours_Contact__c = parentworkorderRecord.After_Hours_Contact__c;
		childworkorderRecord.AdditionContactRole__c = parentworkorderRecord.AdditionContactRole__c;    
		if(parentsrvapp!= null && CreationType ==  'RTR'){
		childworkorderRecord.DSP__c = parentworkorderRecord.DSP__c;
		 childworkorderRecord.DSPName__c = parentworkorderRecord.DSPName__c;
		 childworkorderRecord.Reason_for_repeat_Work_Order__c = parentsrvapp.RTR_Reason__c; 
		 childworkorderRecord.Unscheduled_Reason__c = parentsrvapp.RTR_Reason__c;	
		} 
		else if(CreationType ==  'RTP'){
		  childworkorderRecord.Reason_for_repeat_Work_Order__c = 'Redirect to Partner';  
		  childworkorderRecord.Unscheduled_Reason__c='Redirect to Partner';// added for DEFECT 9026413
          childworkorderRecord.S_AS_Queue__c='Other';//added for STORY 8810442 and STORY 8810376
		
		}	
	   
		childworkorderRecord.Schedule_Enable_Flag__c = parentworkorderRecord.Schedule_Enable_Flag__c;
		childworkorderRecord.Service_Option__c = parentworkorderRecord.Service_Option__c;
		childworkorderRecord.SiteAccessConfirmed__c = parentworkorderRecord.SiteAccessConfirmed__c;
		childworkorderRecord.SLAEndDate__c = parentworkorderRecord.SLAEndDate__c;
		childworkorderRecord.SLAStartDate__c = parentworkorderRecord.SLAStartDate__c;
		childworkorderRecord.Timezone__c = parentworkorderRecord.Timezone__c;
		childworkorderRecord.WorkOrderTarget__c = parentworkorderRecord.WorkOrderTarget__c;
		childworkorderRecord.EntitlementEndDate__c = parentworkorderRecord.EntitlementEndDate__c;
		childworkorderRecord.EntitlementStartDate__c = parentworkorderRecord.EntitlementStartDate__c;
		childworkorderRecord.DispatchEvent__c = 'DISPATCH_CREATION_COMPLETE';
		}
		 ConvergeWorkOrderInboundLog__c convergeWorkOrderInboundLog=new ConvergeWorkOrderInboundLog__c();	
		convergeWorkOrderInboundLog.ApexClass__c='NonAgentWoCreationController' ;
		convergeWorkOrderInboundLog.ApexMethod__c='CreateNonAgentWOController' + CreationType;  
	   
		if (childworkorderRecord != null)
		{
			workOrderList.add(childworkorderRecord);   
		}
	   	nonagentWoflag = true; 
		if (workOrderList != null && workOrderList.size()>0)
		{
           insert workOrderList;
		   convergeWorkOrderInboundLog.Status__c='NonAgent WO Creation success - Type '+ CreationType;
           convergeWorkOrderInboundLog.Message__c='Operation completed successfully';
           convergeWorkOrderInboundLog.WorkOrder__c=childworkorderRecord.Id;
           convergeWorkOrderInboundLogs.add(convergeWorkOrderInboundLog);
		}
	   	
		if(parentsrvapp!= null && workOrderList[0].Id != null)
		{
			childsrvapp.Work_Order__c = childworkorderRecord.Id;
			childsrvapp.ParentRecordId = childworkorderRecord.Id;
			childsrvapp.Status = 'Open';
			childsrvapp.Event_Type__c = parentsrvapp.Event_Type__c;
			childsrvapp.Labor_Type__c = parentsrvapp.Labor_Type__c;
			childsrvapp.Address_Line_1__c = parentsrvapp.Address_Line_1__c;
            childsrvapp.Address_Line_2__c = parentsrvapp.Address_Line_2__c;
            childsrvapp.Alternate_Account__c = parentsrvapp.Alternate_Account__c;
			childsrvapp.City = parentsrvapp.City;
			childsrvapp.State__c = parentsrvapp.State__c;
			childsrvapp.state = parentsrvapp.state ;
            childsrvapp.Additional_Scheduling_Contact__c = parentsrvapp.Additional_Scheduling_Contact__c;
			childsrvapp.City__c = parentsrvapp.City__c;
			childsrvapp.Country__c = parentsrvapp.Country__c;
            childsrvapp.Country = parentsrvapp.Country;
			childsrvapp.PostalCode = parentsrvapp.PostalCode;
			childsrvapp.ContactId = parentsrvapp.ContactId;
			childsrvapp.Scheduling_Contact__c = parentsrvapp.Scheduling_Contact__c;
			childsrvapp.Primary_Contact__c = parentsrvapp.Primary_Contact__c;
			childsrvapp.Primary_Contact_Role__c = parentsrvapp.Primary_Contact_Role__c;
			childsrvapp.CurrencyIsoCode = parentsrvapp.CurrencyIsoCode;
			childsrvapp.DueDate = parentsrvapp.DueDate;
			childsrvapp.EarliestStartTime = parentsrvapp.EarliestStartTime;
			//childsrvapp.RecordTypeId = '0122h0000009sGBAAY';
			if(CreationType == 'RTR'){
			childsrvapp.Service_Date__c = parentsrvapp.Service_Date__c;
			childsrvapp.Service_Start__c = servicestartDate;
			childsrvapp.Service_Start_UI__c = servicestartDate ;
			childsrvapp.Service_End__c = serviceendDate;
			childsrvapp.Service_End_UI__c = serviceendDate;
            childsrvapp.Ext_Ref_Id__c = sappId;    
			}
            childsrvapp.Zip__c = parentsrvapp.Zip__c;
		}	
		
		if(childsrvapp != null)
		{
		 sAList.add(childsrvapp);
		}	

		 if (sAList != null && sAList.size()>0)
		{
         insert sAList;
		}
	           
		if(parentdd != null && childworkorderRecord.Id != null)
		{
		  childdd.ReverseAgency__c = parentdd.ReverseAgency__c;
		  childdd.CompleteCareOption__c = parentdd.CompleteCareOption__c;
		  childdd.ServiceHours__c = parentdd.ServiceHours__c;
		  childdd.Complete_Care_Option__c = parentdd.Complete_Care_Option__c;
		  childdd.OutOfHours__c = parentdd.OutOfHours__c;
		  childdd.ProSupport__c = parentdd.ProSupport__c;
          childdd.OutOfWarranty__c=parentdd.OutOfWarranty__c;
		  childdd.DigitalEntitlements__c = parentdd.DigitalEntitlements__c;
		  childdd.DSP_Override_Request__c = parentdd.DSP_Override_Request__c;
		  childdd.KYHDOption__c = parentdd.KYHDOption__c;
		  childdd.BasicEntitlement__c = parentdd.BasicEntitlement__c;
		  childdd.Keep_Your_Components__c = parentdd.Keep_Your_Components__c;
		  childdd.DataRecovery__c = parentdd.DataRecovery__c;
		  childdd.ServiceLevel__c = parentdd.ServiceLevel__c;
		  childdd.Work_Order__c = childworkorderRecord.Id ;
		}	
	   
		if(childdd != null)
		{
		  dDList.add(childdd);
		}

		if(dDList != null && dDList.size() >0)
		{
		   insert dDList;
		}
	   
		parentdInstList = [SELECT Id, Name, Type__c,Type_of_Instruction__c,Vendor_Instructions__c,Visibility__c,Audience__c, Receiver__c, Instruction__c,Work_Order__c FROM DispatchInstruction__c WHERE Work_Order__c =: parentworkorderRecord.id ];
	   
		if(parentdInstList.size() > 0 && childworkorderRecord != null){
		   
		   for( DispatchInstruction__c parentinstrctions : parentdInstList)
		   {
			   DispatchInstruction__c childinstructions = new DispatchInstruction__c();
			   //childinstructions.Name = parentinstrctions.Name;
			   childinstructions.Receiver__c = parentinstrctions.Receiver__c;
			   childinstructions.Instruction__c = parentinstrctions.Instruction__c;
			   childinstructions.Audience__c = parentinstrctions.Audience__c;
			   childinstructions.Type__c= parentinstrctions.Type__c;
			   childinstructions.Type_of_Instruction__c = parentinstrctions.Type_of_Instruction__c;
			   childinstructions.Vendor_Instructions__c = parentinstrctions.Vendor_Instructions__c;
			   childinstructions.Visibility__c = parentinstrctions.Visibility__c;
			   childinstructions.Work_Order__c = childworkorderRecord.Id;
			   childdInstList.add(childinstructions);
		   }
		}  
	   
		if(childdInstList.size() >0 ){
			insert childdInstList;
		}
        nonagentWoflag = false;
        if(convergeWorkOrderInboundLogs.size()>0){
            try{
               Insert convergeWorkOrderInboundLogs;
            }catch(Exception e){
                system.debug('Exception on convergeWorkOrderInboundLogs '+e);
            }
        }
		
		if(CreationType == 'RTR'){
		List<Id> ids=new List<Id>();
		ids.add(childworkorderRecord.Id);
		System.enqueueJob(new NonAgentWOSubmissionRTR(ids)); 
		}	
		
	  return childworkorderRecord.Id;	
	  
	}catch (Exception e){
        system.debug('Exception on Wo Creation '+e);
		  ConvergeWorkOrderInboundLog__c convergeWorkOrderInboundLog=new ConvergeWorkOrderInboundLog__c();
		  convergeWorkOrderInboundLog.ApexClass__c='NonAgentWoCreationController' ;
		  convergeWorkOrderInboundLog.ApexMethod__c='CreateNonAgentWOController' + CreationType;  		
		  convergeWorkOrderInboundLog.Status__c='NonAgent WO Creation Failed - Type '+ CreationType;
          convergeWorkOrderInboundLog.Message__c='';
		  Insert convergeWorkOrderInboundLog;
        System.debug('convergeWorkOrderInboundLog'+convergeWorkOrderInboundLog);
		return 'WO Creation failed due to data issue';
       }
	
	
  } */
    

}