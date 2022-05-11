/* -----------------------------------------------------------------------------------------------------------------------
Name:       InstructionTriggerHandler
Description: Handler for DispatchInstruction 
Date         Version          Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
Nov-16-2020     1.0         Salesforce          Tech Debt - Performance Improvements
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class InstructionTriggerHandler extends TriggerHandler {

    // get trigger config
    public static boolean restrictWoTriggerflag = false;
    private static List<Trigger_Handler_Configuration__mdt> triggerConfig;

    public InstructionTriggerHandler() 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:        InstructionTriggerHandler
    Description: Constructor
    Date                 Version            Author                 Summary of Changes 
    ---------------------------------------------------------------------------------------------------------------------------
    Nov-16-2020          1.0                Salesforce             Tech Debt - Performance Improvements
    --------------------------------------------------------------------------------------------------------------------------*/
    {        
        // initialize this handler
        restrictWoTriggerflag = true;
        if(!this.initializeHandler()) {            
            System.Debug('Bypassed Handler -- >' + InstructionTriggerHandler.class.getName());                  
            return;
        } 
    }
    public override Boolean initializeHandler()
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       initializeHandler
    Description:  This handles logic needed when the class is initiated
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Nov-16-2020    1.0    Salesforce        Tech Debt - Performance Improvements
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        // check if this handler is bypassed
        if(TriggerHandler.isBypassed(InstructionTriggerHandler.class.getName())) {
            System.Debug('Is this bypassed? -- > '+InstructionTriggerHandler.class.getName());
            return false;
        }
        
        // get implicit bypass details from trigger config - static so that query doesn't have to run more than once
        // every trigger handler should use the object api and handler name
        triggerConfig = new List<Trigger_Handler_Configuration__mdt>();
      /*  triggerConfig = [SELECT Id, Record_Type_Name__c, Enable_Implicit_Bypass__c, Implicit_Bypass_Levels__c  
                        FROM Trigger_Handler_Configuration__mdt
                        WHERE
                        Object_API_Name__c =: DispatchInstruction__c.sObjectType.getDescribe().getName() AND
                        Handler_Class_Name__c =: InstructionTriggerHandler.class.getName() AND 
                        Enable_Implicit_Bypass__c = true LIMIT 1];
        if(triggerConfig != null && triggerConfig.size() > 0) {
            this.IMPLICIT_BYPASS_LEVELS = triggerConfig[0].Implicit_Bypass_Levels__c != null ? (Integer)triggerConfig[0].Implicit_Bypass_Levels__c : this.IMPLICIT_BYPASS_LEVELS;
            this.ENABLE_IMPLICIT_BYPASS = triggerConfig[0].Enable_Implicit_Bypass__c;
        }*/
        
        return true;
    }

    public override void beforeInsert()
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       beforeInsert
    Description:  This method handles logic in before insert context
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Oct-27-2020     1.0    Salesforce        Tech Debt - Performance Improvements
    Nov-30-2021            Saurabh           Added updateSendToVendor method for Defect 11633171 
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        /*ConvergeInstructionHandler.preventSpecialCharater((List<DispatchInstruction__c>)trigger.new);
        ConvergeInstructionHandler.updateSendToVendor((List<DispatchInstruction__c>)trigger.new);*/
    }

    public override void beforeUpdate()
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       beforeInsert
    Description:  This method handles logic in before update context
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Oct-27-2020     1.0    Salesforce        Tech Debt - Performance Improvements
    -------------------------------------------------------------------------------------------------------------------------- */
    {
       // ConvergeInstructionHandler.preventSpecialCharater((List<DispatchInstruction__c>)trigger.new);
    }

    public override void beforeDelete()
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       beforeInsert
    Description:  This method handles logic in before delete context
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Oct-27-2020     1.0    Salesforce        Tech Debt - Performance Improvements
    -------------------------------------------------------------------------------------------------------------------------- */
    {
      //  ConvergeInstructionHandler.preventDelete((Map<Id, DispatchInstruction__c>)trigger.oldMap);
    }

}