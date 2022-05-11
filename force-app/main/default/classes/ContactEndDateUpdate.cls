/**************
* @ Class Name        : ContactEndDateUpdate
* @ Description       : This is a batch class to update Contact, Created as part of IDS Feature #10672632.
* @ CreatedBy         : DFN Services
* @ CreatedOn         : 08/11/2021
* @ Modification Log  : Version 1.0 - [Sivakumari Ediga] : Initially created the script.
***************/

global class ContactEndDateUpdate implements Database.Batchable<sObject>,Database.Stateful {
    public set<id> userIds = new set<id>();
    public set<id> conids = new set<id>();
    public set<String> psaNames = new set<String>();
    public List<String> toAddresses = new List<String>();
    public list<Contact> contactList = new list<Contact>(); 
    public list<serviceResource> srListToUpdate = new list<serviceResource>();
    public list<ServiceAppointment> saListToClone =  new list<ServiceAppointment>();
    public Map<Id,ServiceAppointment> serviceAppointmentMap = new Map<Id,ServiceAppointment>();
    
    public ContactEndDateUpdate()
    {
        list<PSA_ProfileNames__mdt> pa = [Select MasterLabel, Profile_Name__c from PSA_ProfileNames__mdt];
        System.debug('Profile List ::: ' +pa);
        for(PSA_ProfileNames__mdt p : pa)
        {
            psaNames.add(p.Profile_Name__c);
            System.debug('Psa Names ' +psaNames);
        }
    }
    
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return Database.getQuerylocator([SELECT id, IsActive, FBE_Services_Termination__c, Profile.Name FROM User WHERE IsActive = True AND Profile.Name IN :psaNames]);
    }
    
    global void execute(Database.BatchableContext BC, List<user> lstScope)
    {
        System.debug('User List :::: ' +lstScope);
        
        for(User u : lstScope)
        {
            if(u.FBE_Services_Termination__c  <= System.today())
            {
                userIds.add(u.id);
            }
        }  
       try{
        //Update contact Last Date and active checkbox
         
        for(Contact con : [SELECT Id, pse__Last_Date__c, pse__Is_Resource_Active__c, pse__Salesforce_User__c FROM Contact Where pse__Salesforce_User__c IN: userids])
        {
            System.debug('Contact List :::: ' +con); 
            con.pse__Is_Resource_Active__c = false;
            con.pse__Last_Date__c = system.today(); 
            contactList.add(con);
        }
        
        if(!contactList.isEmpty())
        {
            Database.update(contactList);  
        }
        
         
        conids = new map<id,contact>(contactList).keyset();
        System.debug('Contact Ids :::: ' +conids);
        
        //Update ServiceResource 
        for(serviceResource sr :[select id, IsActive From ServiceResource where FBE_Contact__c IN :conIds])
        {
            System.debug('Service Resource List :::: ' +sr);
            sr.IsActive = false;
            srListToUpdate.add(sr);
            SYstem.debug('update List ::::' +srListToUpdate);
        }
        
        if(!srListToUpdate.isEmpty())
        {
            Database.update(srListToUpdate);
        }
        
        //Update Service Appointments
       
            for(ServiceAppointment serAppointment : [SELECT id,Status, Assignment__c, Assignee__c,Assignee__r.pse__Is_Resource_Active__c,
                                                     Project__r.pse__Start_Date__c,Project__r.pse__End_Date__c, Project__r.Id,Work_Order__c,
                                                     Work_Order__r.Project_Task__r.Id,Work_Order__r.WorkTypeId,SchedStartTime,SchedEndTime,Subject,
                                                     Duration FROM ServiceAppointment 
                                                     WHERE (Status = 'Dispatched' OR Status = 'In Progress') AND Assignment__c != null AND Assignee__c IN :conIds])
            {
                System.debug('Service Appointments ::: ' +serAppointment);
                if(serAppointment.id != null && serAppointment.Assignee__c != null && serAppointment.Work_Order__c != null){
                   
                    if(serAppointment.Status == 'Dispatched' ){
                        serAppointment.Status = 'Canceled';
                        saListToClone.add(serAppointment);
                        System.debug('List to update on Dispatch :::::' +saListToClone);
                        
                    }
                    
                    if(serAppointment.Status == 'In Progress' ){
                        serAppointment.Status = 'Cannot Complete';
                        serAppointment.Additional_Effort__c = 'Appointment Task';
                        serAppointment.Incomplete_Reason__c = 'Unplanned OOO';
                        serAppointment.Incomplete_Notes__c = 'User is no longer with Dell';
                        saListToClone.add(serAppointment);
                        System.debug('List to update for inprogress :::::' +saListToClone);
                        
                    }
                }
                
                }
            
                if(!saListToClone.isEmpty())
                {
                    System.debug('Inside if');
                    database.update(saListToClone);
                    System.debug('List to update 2 :::::' +saListToClone);  
                    
                }
        
          
          //add updated list to a map 
           for(ServiceAppointment cloneList : saListToClone){
              serviceAppointmentMap.put(cloneList.id, cloneList); 
           }
           system.debug('@@99 serviceAppointmentMap ' +serviceAppointmentMap);
          
         
           //Clone canceled and in progress Service Appointments on resource termination
           List<ServiceAppointment> insertClonedServiceAppointments = new List<ServiceAppointment>();
           Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
           System.debug('Inside Clone method');
           for(ServiceAppointment sa : serviceAppointmentMap.values()){
               ServiceAppointment cloneInProgreSA = new ServiceAppointment();
               ServiceAppointment cloneCanceldSA = new ServiceAppointment();
              //create a new SA with same details for cannot complete status SA's
               if(sa.Status == 'Cannot Complete' && sa.Work_Order__c != null){
                   System.debug('Status :' +sa.Status);
                   cloneInProgreSA.EarliestStartTime = System.now();
                   if(sa.SchedStartTime != null){
                       DateTIme dT = sa.SchedStartTime;
                       Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                       Integer numberDaysDue = myDate.daysBetween(system.today());
                       system.debug('numberDaysDue ' +numberDaysDue);
                       cloneInProgreSA.Duration = numberDaysDue;
                       cloneInProgreSA.Project__c = sa.Project__c;
                       cloneInProgreSA.Status = 'New';
                       cloneInProgreSA.Work_Order__c = sa.Work_Order__c;
                       cloneInProgreSA.WorkTypeId = sa.Work_Order__r.WorkTypeId;
                        System.debug('Work Type ID ## ' +sa.Work_Order__r.WorkTypeId);
                       cloneInProgreSA.ParentRecordId = sa.Work_Order__c;
                       cloneInProgreSA.RecordTypeId = installationBadgeRecordType;
                       insertClonedServiceAppointments.add(cloneInProgreSA);
                       System.debug('Clone one ' +insertClonedServiceAppointments);
                   }
               }
               //create a new SA with same details for canceld status SA's
               if(sa.Status == 'Canceled' && sa.Work_Order__c != null){
                   system.debug(' In Canceled');
                   cloneCanceldSA.Project__c = sa.Project__c;
                   cloneCanceldSA.Status = 'New';
                   cloneCanceldSA.Work_Order__c = sa.Work_Order__c;
                   cloneCanceldSA.WorkTypeId = sa.Work_Order__r.WorkTypeId;
                   System.debug('Work Type ID ' +sa.Work_Order__r.WorkTypeId);
                   cloneCanceldSA.ParentRecordId = sa.Work_Order__c;
                   cloneCanceldSA.RecordTypeId = installationBadgeRecordType;
                   insertClonedServiceAppointments.add(cloneCanceldSA);
                   System.debug('Clone two ' +insertClonedServiceAppointments);
               }
           }
           
           if(!insertClonedServiceAppointments.isEmpty()){
               System.debug('Inside CLone If ###### ' +insertClonedServiceAppointments);
               Database.insert(insertClonedServiceAppointments, False);
               System.debug('CLone  ###### ' +insertClonedServiceAppointments);
           }   
           
       }catch(System.DmlException dml) {
           insert SaveResultExceptionLogger.createExceptionLogger(dml, ContactEndDateUpdate.Class.getName(), 'ContactEndDateUpdate');
           System.debug('Exception ' +dml);

        }
        
    }
          
    
    global void finish(Database.BatchableContext BC){
       
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName = 'FFNotificationHelper'];
        Messaging.CustomNotification mail = new Messaging.CustomNotification();
         set<string> pmToAddresses = new set<string>();
        map<id,pse__Assignment__c> targetObjectIdMap = new map<id,pse__Assignment__c>();
       
        for(pse__Assignment__c asgnmnt : [SELECT id, pse__Project__c, pse__Project__r.Name, pse__Project__r.Ownerid, pse__Project__r.pse__Project_Manager__c, pse__Project__r.pse__Project_Manager__r.Email,pse__Resource__c, pse__Resource__r.Name, pse__Resource__r.pse__Is_Resource_Active__c  FROM pse__Assignment__c
                                          WHERE pse__Resource__r.pse__Is_Resource_Active__c = False AND pse__Resource__c IN:conids])
        {
             
            if(asgnmnt.pse__Project__r.Ownerid != null)
                  System.debug('Owner Id ##### ::::' +asgnmnt.pse__Project__r.Ownerid );
            {
                pmToAddresses.add(asgnmnt.pse__Project__r.Ownerid); 
                                }
                mail.setNotificationTypeId(notificationType.id);  
                mail.setTargetId(asgnmnt.pse__Project__r.Ownerid);
                mail.setTitle('Resource Termination ');
                mail.setBody( 'Please note that ' +asgnmnt.pse__Resource__r.Name + ' user is no longer with Dell, needs to reassign team members for terminated resource. ');     
              
        }  
          mail.Send(pmToAddresses);  
          System.debug('pmToAddresses ##### ::::' +pmToAddresses);
        
       
         
    }
       
}