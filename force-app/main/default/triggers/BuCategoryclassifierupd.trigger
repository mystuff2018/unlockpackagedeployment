trigger BuCategoryclassifierupd on OpportunityLineItem (after insert, after update, after delete, after undelete) {
if(trigger.isAfter && (trigger.isInsert || trigger.isupdate|| trigger.isdelete|| trigger.isUndelete)){
FBE_BuCategoryClassifierTriggerHandler.updbucategoryclassifier(trigger.new,trigger.old);
} 
}