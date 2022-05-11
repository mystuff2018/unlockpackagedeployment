trigger ProjectTaskTrigger on pse__Project_Task__c (before insert, after insert, before update, after update,before delete, after delete,after undelete) {
	new FFProjectTaskTriggerHandler().run();
    
    //Sivakumari Novora Interlock -  Feature 8432644 
     if(Trigger.isUpdate && Trigger.isBefore){
          if(FBE_IDS_NovoraInterLock.runOnceNovoraBeforeUpdate()){
         ProjectTaskHandler.updateProjectTaskIntegrationStatus(Trigger.new);
           system.debug('i am in before '); 
          }
    }
    
    //Luis Campos 12-03-2019
      if (Trigger.isDelete && Trigger.isBefore){
            ProjectTaskHandler.preventDeletionActiveTasks(Trigger.oldMap);       
      }
       
    if(Trigger.isAfter){
      ProjectTaskHandler.handleProjectTasks(Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
    }
    //     ProjectTaskHandler.updateProjectSite(Trigger.newMap, Trigger.oldMap, Trigger.isUpdate, Trigger.isBefore);
    if (Trigger.isInsert && Trigger.isAfter) {
        //IdsProjectTaskHandler projectTaskHandlerJob = new IdsProjectTaskHandler(Trigger.new, false);
        //ID jobID = System.enqueueJob(projectTaskHandlerJob);

        // tdavis 2020-03-04 - added below method call - TFS Stories 7978722 and 7978728
        ProjectTaskDateRollupHandler.rollupDatesToProject(Trigger.new); 
       
    }

      //omonsalve 01-04-2019
      if (Trigger.isUpdate && Trigger.isAfter) 
      {
            ProjectTaskHandler.updateProjectStatus(Trigger.newMap,Trigger.oldMap);
            // tdavis 2020-03-04 - added below method call - TFS Stories 7978722 and 7978728
            ProjectTaskDateRollupHandler.rollupDatesToProject(Trigger.new);     
      }

    
    // ShivaKumari Novora InterLock -  Feature 8432644 
    if (Trigger.isDelete && Trigger.isAfter) 
    {
        FBE_IDS_NovoraInterLock.processDeletedProjectTasks(Trigger.old);  
        System.debug('I am after delete');
         
    }
}