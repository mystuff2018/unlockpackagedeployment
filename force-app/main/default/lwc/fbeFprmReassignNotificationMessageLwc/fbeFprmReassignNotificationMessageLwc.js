import { LightningElement,api,wire} from 'lwc';
import getapprovalobject from '@salesforce/apex/FBE_FPRM_GetObject_Name_Approval_Cls.getobjectnameofapprovalrecord';

export default class FbeFprmReassignNotificationMessageLwc extends LightningElement {
    @api recordId;
    showdealmessage = false;
    showdealextmessage = false;
    @wire(getapprovalobject, { recordId: '$recordId'})
    wiredData({ error, data }) {
      if (data) {
          if(data =='Deal_Registration__c'){
            this.showdealmessage=true;
            this.showdealextmessage=false;
          }
          else if(data =='Deal_Extension__c'){
            this.showdealextmessage=true;
            this.showdealmessage =false;
          }
          else{
            this.showdealmessage =false;
            this.showdealextmessage =false;
          }
        console.log('Data', data);
      } else if (error) {
         console.error('Error:', error);
         this.showdealmessage =false;
            this.showdealextmessage =false;
      }
    }


}