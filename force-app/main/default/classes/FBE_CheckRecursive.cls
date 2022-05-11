/**************
 *@ Class Name        : FBE_CheckRecursive
 *@ Description       : This class is written to handle the Trigger recursive calls. 
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 04-10-2017
 *@ Modification Log  : [10-8-2019 Yogesh Mishra] Added 'runBeforeOnce' & 'runAfterOnce' methods to check recursive calls specifically before & after Trigger Call.                    
 ***************/
public Class FBE_CheckRecursive{
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
         run=false;    
         return true;
        }else{
            return run;
        }
    }

    private static boolean runOptyInsert = true;
    private static boolean runOptyUpdate = true;
    public static boolean runOptyInsertOnce(){
        if(runOptyInsert){
         runOptyInsert=false;
         return true;
        }else{
            return runOptyInsert;
        }
    }   
    public static boolean runOptyUpdateOnce(){
        if(runOptyUpdate){
         runOptyUpdate=false;
         return true;
        }else{
            return runOptyUpdate;
        }
    }      
    
    private static boolean runDealInsert = true;
    private static boolean runDealUpdate = true;
    public static boolean runDealInsertOnce(){
        if(runDealInsert){
         runDealInsert=false;
         return true;
        }else{
            return runDealInsert;
        }
    }   
    public static boolean runDealUpdateOnce(){
        if(runDealUpdate){
         runDealUpdate=false;
         return true;
        }else{
            return runDealUpdate;
        }
    }     
    
    private static boolean runBefore = true;
    private static boolean runAfter = true;
    public static boolean runBeforeOnce(){
        if(runBefore){
         runBefore=false;
         return true;
        }else{
            return runBefore;
        }
    }   
    public static boolean runAfterOnce(){
        if(runAfter){
         runAfter=false;
         return true;
        }else{
            return runAfter;
        }
    }
    private static boolean runAfterIns = true;
    private static boolean runAfterUpd = true;
    public static boolean runAfterInsert(){
        if(runAfterIns){
         runAfterIns=false;
         return true;
        }else{
            return runAfterIns;
        }
    }   
    public static boolean runAfterUpdate(){
        if(runAfterUpd){
         runAfterUpd=false;
         return true;
        }else{
            return runAfterUpd;
        }
    }   
}