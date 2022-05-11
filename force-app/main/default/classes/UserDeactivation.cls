/**************
 * @ Class Name        : UserDeactivation
 * @ Description       : This is a batch class to update USERS
 *                       Created as part of IDS Feature #10672632.
 * @ CreatedBy         : DFN Services
 * @ CreatedOn         : 08/11/2021
 * @ Modification Log  : Version 1.0 - [Sivakumari Ediga] : Initially created the script.
***************/

global class UserDeactivation implements Database.Batchable<sObject>, Database.Stateful {
    public list<user> updatedUserList;
    public set<string> psaNames = new set<string>();
    public Set<String> toAddresses = new Set<String>();
    public map<Id,string> deactivatedUsers = new map<id,string>();
    public list<String> profileNames = new list<string>();
    
    public UserDeactivation()
    {
        list<PSA_ProfileNames__mdt> pa = [Select MasterLabel, Profile_Name__c from PSA_ProfileNames__mdt];
        System.debug('Profile List ::: ' +pa);
        for(PSA_ProfileNames__mdt p : pa)
        {
            psaNames.add(p.Profile_Name__c);
            System.debug('Psa Names ' +psaNames);
        }
    }
       
    global Database.Querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT id, Name, IsActive, FBE_Services_Termination__c, Profile.Name FROM User WHERE IsActive = True AND Profile.Name IN: psaNames]);
    }
 
    global void execute(Database.BatchableContext BC, List<User> userList){
        System.debug('User List ##### :' +userList);
        System.debug('in execute');
        
       updatedUserList = new list<user>();
        try{
            for(User u: userList){        
                if(u.FBE_Services_Termination__c  <= System.today()){
                    System.debug('Termination date :::' +u.FBE_Services_Termination__c);
                    u.IsActive = false;
                    updatedUserList.add(u);
                    
                }
            }
            
            if(!updatedUserList.isEmpty()){
                Database.update(updatedUserList);    
            }
            
        }catch(Exception ex) {
            //insert SaveResultExceptionLogger.createExceptionLogger(dml, UserDeactivation.Class.getName(), 'UserDeactivation');
            System.debug('Get Error ' +ex.getMessage() + 'Get Line Number ' +ex.getLineNumber());
        }
    }        
        global void finish(Database.BatchableContext BC){
           CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName = 'FFNotificationHelper'];
            List<id> inactiveUserids = new List<id>();
             List<Messaging.CustomNotification> mails = new List<Messaging.CustomNotification>();
             Messaging.CustomNotification mail = new Messaging.CustomNotification();
 
            Map<id, User> userListToSendEmail = new map<id,user>([Select id,Name,Email,Profile.Name,IsActive from user where Profile.Name LIKE 'PSA%']);
            system.debug('userListToSendEmail ######### ' +userListToSendEmail);
            for(User u : userListToSendEmail.values()){
                if(u.profile.Name.Contains('PSA Resource Manager'))
                    toAddresses.add(u.id);
            }
            for(User us : updatedUserList){ 
                if(us.profile.Name.Contains('PSA Technical Resource') || us.profile.Name.Contains('PSA Project Manager')){ 
                    mail.setNotificationTypeId(notificationType.id);
                    mail.setTargetId(us.Id);
                    System.debug('user Id ##### ::::' +us.id);
                    mail.setTitle('User Termination');
                    // mail.setSaveAsActivity(false);
                    mail.setBody('User '  + us.name +  ' is no longer with Dell ');
                    System.debug(' User Name ' +us.name);
                   
                }
                mail.send(toAddresses);
            }
            
            // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('mail ##### ::::' +mail);
            
            
        }
}