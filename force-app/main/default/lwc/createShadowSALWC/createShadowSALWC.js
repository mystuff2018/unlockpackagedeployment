import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createShadowAppointment from '@salesforce/apex/FSLCreateShadowAppointmentCtrl.createChildShadowSA';
export default class CreateShadowSALWC extends NavigationMixin(LightningElement) {
    @api recordId;
    recId;
    serviceAppt;
    error;
    handleClick() {
        createShadowAppointment({ recordId: this.recordId })
            .then((result) => {
                debugger;
                this.serviceAppt = result;
                this.error = undefined;
                debugger;
                this.dispatchEvent(
                            new ShowToastEvent({
                            title : 'Success',
                            message : `Records saved successfully! You will be redirected to Shadow Service Appointment Record Page`,
                            variant : 'success',
                            mode: 'sticky'
                            }),
                )
                this.navigateToViewServiceAppointment(this.serviceAppt);
                } )
            .catch((error) => {
                this.error = error;
                this.serviceAppt = undefined;
                this.dispatchEvent(
                        new ShowToastEvent({
                        title: 'Error',
                        message: this.error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                        }),
                        )
            });
        }
    navigateToViewServiceAppointment(recId){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: 'ServiceAppointment',
                actionName: 'view'
            },
        });
    }  
}