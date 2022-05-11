public with sharing class TriggerHandlerRunner  extends TriggerHandler {
    public static boolean HandlerRunnerClass(string className) {
        boolean blnreturn = false;
        type HandlerClass = Type.forName(className);
        Type Iplugin= TriggerHandler.class;
        if(HandlerClass!=null && Iplugin.isAssignableFrom(HandlerClass)){
            TriggerHandler newHandlerClass = (TriggerHandler)HandlerClass.newInstance();
            blnreturn=true;
            newHandlerClass.run();
        }
        return blnreturn;
    }
    
}