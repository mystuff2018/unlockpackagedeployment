/**************
*@ Trigger Name                                                  : TaskTrigger
*@ Description                                                   : Task Trigger.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 12-19-2019 [Sireesha Myla]
*@ Modification Log                                             : 
***************/ 
trigger TaskTrigger on Task (after insert, before insert, before delete, before update, after update)
{
    if (Trigger.isAfter)
    {
        //insert event
        if (Trigger.isInsert)
        {
            FBE_TaskTriggerHandler.onAfterInsert(Trigger.newMap);
            
        } 
        if (Trigger.isUpdate){
            FBE_TaskTriggerHandler.onafterUpdate(trigger.new,trigger.oldMap);
            FBE_TaskBL.onafterupd(trigger.newmap, trigger.oldmap);
            
        } 
    }else
        if (Trigger.isBefore)
    {
        //insert event
        if (Trigger.isInsert)
        {
            FBE_TaskTriggerHandler.onBeforeInsert(Trigger.new);
            FBE_TaskTriggerHandler.remindersetinsrtupd(Trigger.new);
        } 
        
        if(Trigger.isUpdate)
        {
            FBE_TaskTriggerHandler.onBeforeUpdate(trigger.new,trigger.oldMap);
            FBE_TaskTriggerHandler.remindersetinsrtupd(Trigger.new);
        }
    }
}