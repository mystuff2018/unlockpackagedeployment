/*  @File Name          : fBE_FPRM_DealMessagelwc.js
  @Description        : Story 9912115: SFDC PRM UI-Home Screen; 
  based the status of the Deal reacord the object colour and message will chage at deal page in FPRM
  @Author             : Sitaram Teki
  @Group              : 
  @Last Modified By   : Sitaram Teki
  @Last Modified On   : 12-21-2021
  @Modification Log   : 
  Ver       Date            Author      		    Modification
  1.0    01/FEB/2021        Sitaram Teki            Initial Version
*/
import { LightningElement,api,wire,track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PROD_CLASSIF from '@salesforce/schema/Deal_Registration__c.FBE_Deal_Product_Classification__c';
import REGISTRATION_STATUS from '@salesforce/schema/Deal_Registration__c.FBE_Deal_Registration_Status__c';
import DECLINE_REASON from '@salesforce/schema/Deal_Registration__c.FBE_Declined_Reason__c';
const fields = [REGISTRATION_STATUS,PROD_CLASSIF,DECLINE_REASON];
export default class FBE_FPRM_DealMessagelwc extends LightningElement {
    @api recordId;
    record;
    error;
    boolhistVisible=false;
    historicaldeal;
    Dealstatus='';
    Decline_Reason='';
    color='#0070d2';
    boolapprovalprocess=false;
    @track message='';
    @track boolVisible = false;  
    
    @wire(getRecord, { recordId: '$recordId', fields })
    wireddeal({ error, data }) {
        if (data) {
            this.record = data;
            console.log("Deal Status:  "+ this.record);
            const Status =data.fields.FBE_Deal_Registration_Status__c.value;
            this.historicaldeal=data.fields.FBE_Deal_Product_Classification__c.value;
            const DeclineReason = data.fields.FBE_Declined_Reason__c.value;
            this.Decline_Reason =DeclineReason;
            console.log("FBE_Deal_Product_Classification__c:  "+ this.historicaldeal);
           if(this.historicaldeal !== null && this.historicaldeal !== '')
            {
                this.boolhistVisible=true; 
            }
  
            this.Dealstatus =Status;
            console.log("Deal Status:  "+ this.Dealstatus);
            if(Status ==='Approved'){
                this.message='Registration cannot be edited';
                this.boolVisible=true;
                this.color='#D8000C';
               
            }
            else if(Status ==='Submitted'){
                this.message='Registration cannot be edited';
                this.boolVisible=true;
                this.color='#D8000C';
                
            }
            else if(Status ==='New'){
                this.message='Registration is not yet submitted for approval';
                this.boolVisible=true;
                this.color='#4BB543';
                
            }
            else if(Status ==='Recalled'){
                this.message='Registration cannot be edited';
                this.boolVisible=true;
                this.color='#D8000C';
                
            }
            else if(Status ==='Rejected'){
                //this.message='Registration is Rejected Please check the Declined Reason';
                if(DeclineReason !== null && DeclineReason !== '' && (DeclineReason ==='Not enough information' || DeclineReason ==='Ineligible Product(s)'|| DeclineReason === 'Criteria Not Met'))
                {
                    
                    this.message='Registration has been rejected with a declined reason of ‘'+this.Decline_Reason+'’. Please review and resubmit if necessary.';
                    
                }
                else{
                    
                    this.message='A registration that has been rejected with the declined reason of ‘'+this.Decline_Reason+'’ cannot be resubmitted.';
                }
                this.boolVisible=true;
                this.color='#ffae42';
                
            }
            //story# 10262642 - start
            else if(Status ==='Expired'){
                
                this.message='Registration cannot be edited';
                this.boolVisible=true;
                this.color='#D8000C';
                
            }
            else if(Status ==='Hold for Review'){
                
                this.message='';
                this.boolVisible=true;
                this.color='#D8000C';
                
            }
            //story# 10262642 - end
            else{
                this.boolVisible=false;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = false;
        }
    }
}