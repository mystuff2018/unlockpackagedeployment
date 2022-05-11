public with sharing class CustomPopupController {
    
    public boolean showPopup {get;set;}
    public boolean inputText {get; set;}
    public boolean returnValue {get; set;}
    public List<Splash_Screen_Data__mdt> Sales_Datapoints {get;set;}
    public List<Splash_Screen_Data__mdt> Service_Datapoints {get;set;}
    public List<Splash_Screen_Data__mdt> Deal_Datapoints {get;set;}
    public CustomPopupController ()
    {
        showPopup = false;
        Sales_Datapoints = [select Ordered__c,Heading__c,Body__c,Body1__c,Body2__c,Body3__c,Body4__c,Body5__c from Splash_Screen_Data__mdt where Type__c = 'Sales' order by Ordered__c];
        Service_Datapoints = [select Ordered__c,Heading__c,Body__c,Body1__c,Body2__c,Body3__c,Body4__c,Body5__c from Splash_Screen_Data__mdt where Type__c = 'Services' order by Ordered__c];
        Deal_Datapoints = [select Ordered__c,Heading__c,Body__c,Body1__c,Body2__c,Body3__c,Body4__c,Body5__c from Splash_Screen_Data__mdt where Type__c = 'Deal' order by Ordered__c];
    }
    
    public PageReference updateCurrentRecord(){
        user u =[Select id,Skip_Login_Flow__c from User where id =: UserInfo.getUserId()];
        u.Skip_Login_Flow__c = inputText;
        
        try{
            update u;  
            system.debug('Updated');
        }
       
        catch(Exception e){
            system.debug('Exception'+e);
        }
        ApexPages.addMessage(
            New ApexPages.Message(
                ApexPages.Severity.INFO, 'You entered ' + inputText
            )
        );
                 //  Map<String, String> sessionAttributes;
        //sessionAttributes = Auth.SessionManagement.getCurrentSession();          
     String startURL = apexpages.currentpage().getparameters().get('startURL');
     String retURL = apexpages.currentpage().getparameters().get('retURL');
     system.debug('retURL####'+retURL);
          system.debug('startURL####'+startURL);
          startURL  = retURL ;
            return Auth.SessionManagement.finishLoginFlow(retURL);
    }
    
    
    public PageReference openPopup()
    {
        PageReference pr;
        user u =[Select id,Skip_Login_Flow__c from User where id =: UserInfo.getUserId()];
        system.debug('u.Skip_Login_Flow__c'+u.Skip_Login_Flow__c);
        if(u.Skip_Login_Flow__c == False)
        {showPopup = true;
         return null;}
        else{
            system.debug('elsePart');
           // Map<String, String> sessionAttributes;
        //sessionAttributes = Auth.SessionManagement.getCurrentSession();          
     String startURL = apexpages.currentpage().getparameters().get('startURL');
     String retURL = apexpages.currentpage().getparameters().get('retURL');
     system.debug('retURL####'+retURL);
          system.debug('startURL####'+startURL);
          startURL  = retURL ;
            return Auth.SessionManagement.finishLoginFlow(retURL);
             
        }
       
        
    }
    
    public PageReference Cancel()
    {
        showPopup = false;
        return null;
    }
    
    
}