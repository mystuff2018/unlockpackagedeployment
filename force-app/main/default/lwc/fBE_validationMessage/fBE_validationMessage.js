import { LightningElement, api, wire} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BOOKDATE_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import RECORDTYPE_FIELD from '@salesforce/schema/Opportunity.RecordTypeId';
import getRecordTypeName from '@salesforce/apex/FBE_OpportunityAuraHandler.getRecordTypeName';

const fields = [BOOKDATE_FIELD,RECORDTYPE_FIELD];
export default class FBE_validationMessage extends LightningElement {
    @api recordId;
    @api RecordType;
    booDate;
    showError = false;
    @wire(getRecord, { recordId: '$recordId', fields })
    loadFields({error, data}){
        console.log('loadFields, recordId: ', this.recordId);
        if(error){
        }else if(data){
            this.booDate = getFieldValue(data, BOOKDATE_FIELD);
            var today = new Date().toDateString();
            var book = new Date(this.booDate).toDateString();
            getRecordTypeName({ recordTypeId : getFieldValue(data, RECORDTYPE_FIELD), objectName : 'Opportunity'})
            .then(result => {
                let todatDate = Date.parse(today);
                let bookDate = Date.parse(book);
                console.log(today)
                console.log(book)
                console.log(todatDate)
                console.log(bookDate)
                console.log('result>',result)
                if(bookDate < todatDate && result == this.RecordType){
                    this.showError = true;
                }
                else {
                    this.showError = false;
                }
                console.log('recordtype Id',getFieldValue(data, RECORDTYPE_FIELD));
                console.log('showError>',this.showError);
            })
        }
    }
}