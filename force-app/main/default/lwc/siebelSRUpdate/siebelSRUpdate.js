import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import updateSR from "@salesforce/apex/SiebelUpdateSRController.updateSR";

export default class siebelSRCreation extends LightningElement {
  @api recordId;
  loaded = true;

  renderedCallback() {
    if (this.loaded) {
      this.loaded = false;
      return;
    }

    updateSR({ caseId: this.recordId })
      .then((result) => {
        console.log(result);

        if(result.isSuccess) {
          this.displayNotification("The SR was updated successfully", "success");
        } else {
          this.displayNotification("SR update failed", "error");
        }
        
        this.loaded = false;
        this.closeQuickAction();
      })
      .catch((error) => {
        console.log(error);
        this.displayNotification("SR update failed", "error");
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