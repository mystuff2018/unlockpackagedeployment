import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WorkOrderManualCreationMethod from '@salesforce/apex/WorkOrderManualCreation.getWorkOrderManualCreation';


export default class WorkOderManualCreation extends LightningElement {
    @api recordId;
    @track disabled = false;

    handleWoCreationEventClick(event){
        WorkOrderManualCreationMethod({
            projectId: this.recordId
        }).then(() => {
            
        }).catch(error => {

        })

        const userFeedback = new ShowToastEvent({
            title: 'Work Order Creation Process has been started',
            message: 'The system will send a notification when it is finished',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(userFeedback);
        this.disabled = true;

    }
}