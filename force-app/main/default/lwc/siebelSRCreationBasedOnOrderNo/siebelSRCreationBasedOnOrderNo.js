import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import createSr from "@salesforce/apex/SiebelCreateSRBasedOnOrderNoCtrl.createSR";

export default class siebelSRCreation extends LightningElement {
  @api recordId;
  loaded = true;
		
  renderedCallback(){
    if(this.loaded){
      this.loaded = false;
      return;
    }

    createSr({ caseId: this.recordId })
      .then((result) => {
        if(result.srNumber){
          let message = 'SR Number: ' + result.srNumber;
          this.displayNotification(message,'info');
          getRecordNotifyChange([{recordId: this.recordId}]);
        } else {
          this.displayNotification(result.errorMessage,'warning');
          getRecordNotifyChange([{recordId: this.recordId}]);
        }
        
        this.loaded = false;
        this.closeQuickAction();
      })
      .catch((error) => {
        let errorMessage = 'There was an error.';
        if (error.body) {
            errorMessage = error.body.message;
        }
        this.displayNotification(errorMessage,'error');
        this.loaded = false;
        this.closeQuickAction();
      });
  }

  closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  displayNotification(message, variant) {
    const evt = new ShowToastEvent({
        message: message,
        variant: variant,
    });
    this.dispatchEvent(evt);
  }
}