@isTest
public class CustomPopupController_Test {

/******     
 static testmethod void setup() {
        List<User> lUsrNonIntegration = new list<User>();
        lUsrNonIntegration = FBE_Test_Utility.createUser('System Administrator', 1, 'ab');    
    }
  *****/  
    static testmethod void Runloginflow(){
    List<User> lUsrNonIntegration = new list<User>();
    lUsrNonIntegration = FBE_Test_Utility.createUser('FBE Business Admin', 1, 'ab'); 
    system.debug('lUsrNonIntegration######'+lUsrNonIntegration);
       string retURL;
       //string checkboxField;
      // Boolean inputText = true;
        Test.starttest();
         PageReference pageRef = Page.LoginPopup;
        // pageref.getparameters().put(inputText,true); 
        // pageref.getparameters().put(checkboxField,'true');
         Test.setCurrentPage(pageRef); 
        CustomPopupController popupControllerClass = new CustomPopupController();
        popupControllerClass.inputText = true;
        popupControllerClass.openPopup();
        popupControllerClass.Cancel(); 
        popupControllerClass.updateCurrentRecord();
        lUsrNonIntegration[0].Skip_Login_Flow__c = true;
        update lUsrNonIntegration;
        
       // popupControllerClass.inputText = true;
       // lUsrNonIntegration[0].Skip_Login_Flow__c = true;
       // update lUsrNonIntegration;
        system.debug('intUser#####' +lUsrNonIntegration[0].Skip_Login_Flow__c);
        pageref.getParameters().put('retURL', '/home/home.jsp');
        Auth.SessionManagement.finishLoginFlow(retURL);
        popupControllerClass.openPopup();
        popupControllerClass.updateCurrentRecord();
        Test.stoptest();
    }
}