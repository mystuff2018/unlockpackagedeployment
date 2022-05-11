import { LightningElement,api, track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import { getRecord,getFieldValue  } from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import ContactID_FIELD from '@salesforce/schema/User.ContactId';
import ContactEmail_FIELD from '@salesforce/schema/User.Contact.Email';
import ContactPhone_FIELD from '@salesforce/schema/User.Contact.Phone';
import ContactAcountId_FIELD from '@salesforce/schema/User.Contact.AccountId';

export default class FBE_FPRM_Quicklinkscaselwc extends NavigationMixin (LightningElement) {
    
title = "Quick Links";
showFeatures =true;

    
  @api PremierStorelink ='https://ecomm.federal.dell.com/esales/';
  @api PartnerProgramlink ='https://www.delltechnologies.com/partner/en-us/partner/partner.htm';
 
    //Fetch current partner userdata to fetch contact information
    @track userData;
    @wire(getRecord, {recordId: USER_ID,fields: [ContactID_FIELD,ContactAcountId_FIELD,ContactEmail_FIELD,ContactPhone_FIELD]}) 
    wireuser({error,data}) {
        if (error) {
           console.log('error::' + error);
        } else if (data) {
            this.userData = data;
        }
    }
        
     /* TEKI: Story 9912115: FPRM Added this method to navigate to Premier Program link and we need to menction the link at the Component Bundle Design */
    handlePremierStoreClick(event){
        console.log("handlePremierStoreClick");
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": this.PremierStorelink
                }
            });
    }

    /* TEKI: Added this method to navigate to partner Program link and we need to menction the link at the Component Bundle Design */ 
    handlePartnerProgramClick(event){
        console.log("handlePartnerProgramClick");
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.PartnerProgramlink
            }
        });
       
       
    }
    
    handleCaseEventsClick(event){

        const defaultValues = encodeDefaultFieldValues({
            ContactId: getFieldValue(this.userData, ContactID_FIELD),
            AccountId: getFieldValue(this.userData, ContactAcountId_FIELD),
            ContactEmail: getFieldValue(this.userData, ContactEmail_FIELD),
            ContactPhone: getFieldValue(this.userData, ContactPhone_FIELD),
        });
        console.log("handleCaseEventsClick");
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        }); 
    }
}