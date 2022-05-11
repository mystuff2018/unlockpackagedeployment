trigger MilestoneTrigger on pse__Milestone__c (after insert, after update, before delete, before update) {
    
    new MilestoneHandler().run();
   
}