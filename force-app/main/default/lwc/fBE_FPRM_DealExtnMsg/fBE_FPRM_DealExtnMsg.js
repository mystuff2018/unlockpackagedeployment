import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import DEAL_EXT_ELIGIBLE from '@salesforce/schema/Opportunity.FBE_FPRM_Eligible_for_Extension__c';
import DEAL_REG from '@salesforce/schema/Opportunity.FBE_Deal_Reg_Num2__c';
import DEAL_REG_ID from '@salesforce/schema/Opportunity.FBE_Linked_DealReg__c';
import PORTAL_NAME from '@salesforce/label/c.FBE_FPRM_Portal_Name';
import DEAL_EXT_COUNT from '@salesforce/schema/Opportunity.FBE_FPRM_Sub_Ext_Count__c';
//import DEAL_EXT_COUNT from '@salesforce/schema/Opportunity.FBE_Linked_DealReg__r.FBE_Num_of_Submitted_Extensions__c';
const fields = [DEAL_EXT_ELIGIBLE, DEAL_REG, DEAL_REG_ID, DEAL_EXT_COUNT];

export default class FBEFPRMDealExtnMsg extends LightningElement {
    record;
    error;
    @track color='#D8000C';
    @api recordId;
    @track DealReg;
    @track DealExtElg;
    @track DealRegId;
    @track DealRegUrl;
    @track isOpty;
    @track ExtCount;
    @track AllowExt;

    @wire(getRecord, { recordId: '$recordId', fields })
    wireddeal({ error, data }) {
        if (data) {
            this.record = data;
            console.log("Deal Info:  "+ this.record);
            this.DealReg =data.fields.FBE_Deal_Reg_Num2__c.value;
			this.DealExtElg =data.fields.FBE_FPRM_Eligible_for_Extension__c.value;
			this.DealRegId =data.fields.FBE_Linked_DealReg__c.value;
			this.DealRegUrl = '/'+PORTAL_NAME+'/s/detail/'+this.DealRegId;
            this.ExtCount = data.fields.FBE_FPRM_Sub_Ext_Count__c.value;

            if(this.recordId.substring(0,3)==='006' && this.DealExtElg===true)
            {
                this.isOpty = true;
            }
            else
            {
                this.isOpty = false;
            }
            if(this.ExtCount > 0 && this.DealExtElg===true)
            {
                this.AllowExt = false;
            }
            else
            {
                this.AllowExt = true;
            }
            this.error = undefined;
            if(this.AllowExt ===true) {
                this.color='#4BB543'; 
            }
            else if(this.AllowExt ===false){
                this.color='#D8000C';
            }
        } else if (error) {
            this.error = error;
            this.record = false;
        }
    }
}