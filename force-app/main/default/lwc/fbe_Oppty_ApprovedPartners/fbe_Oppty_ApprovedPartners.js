/****************************************************************************************************
 * Author         : Dell Team - Oppty [Nirmal Kumar Ravi - STORY 11970896]
 * Description    : Previously Approved Partners. 
 * Date Created   : 9/2/2022
 * Version        : 1.0
 * Modification Log           Developer          Last Modified Date           Description
 * 1.0                        Nirmal Kumar Ravi       
 * 
 ****************************************************************************************************/
 import { api, LightningElement} from 'lwc';
 import getApprovedPartnersList from '@salesforce/apex/FBE_Oppty_ApprovedPartnersListController.getApprovedPartnersList';
 export default class Fbe_Oppty_ApprovedPartners extends LightningElement {
 
     @api recordId;
     data = [];
 
     columns = [{
         label: 'Partner Name',
         fieldName: 'Name',
         type: 'text',
     },
    {
        label: 'Partner Account',    
        fieldName: 'PartnerAccount',   
        type: 'text',         
     },
     {
         label: 'Opportunity Number',
         fieldName: 'Opportunity_Number__c',
         type: 'text',
     },
     {
         label: 'TA Discussion Approved Status',
         fieldName: 'TA_Discussion_Approved_Status__c',
         type: 'text',
     },
     {
         label: 'TA Discussion Approved Date',
         fieldName: 'TA_Discussion_Approved_Date__c',
         type: 'Date',
     },
 
     ];
 
     connectedCallback(event) {
         this.getApprovedPartners();
     }
 
     getApprovedPartners() {
        getApprovedPartnersList({ recordId: this.recordId })
            .then(result => {
                this.data = result.map(row=>{
                    return{...row, PartnerAccount: row.Partner_Account__c ? row.Partner_Account__r.Name : ''}
                })       
            })
            .catch(error => {
                console.log('error>>', error.message);
            })
    }
 }