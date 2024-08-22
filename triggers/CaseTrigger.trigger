trigger CaseTrigger on Case (after insert, after update) {

    if (Trigger.isAfter){
            
        if(Trigger.isInsert){
            CaseTriggerHandler.onAfterInsert(Trigger.new);
        }
               
        if(Trigger.isUpdate){
            CaseTriggerHandler.onAfterUpdate(Trigger.new);
        }
        
    }
}