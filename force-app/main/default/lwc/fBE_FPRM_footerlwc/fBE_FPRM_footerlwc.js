import { LightningElement ,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FBE_FPRM_footerlwc extends NavigationMixin (LightningElement) {
    currentYear;
    @api DellTechnologiesUrl ='https://www.delltechnologies.com/en-us/index.htm';
    @api DellUrl='https://www.dell.com/en-us/';
    @api DellEMCUrl ='https://www.dellemc.com/en-us/index.htm';
    @api TermsUrl ='https://www.dellemc.com/partner/en-us/partner/terms-and-conditions.htm';
    @api FederalTermsurl ='https://ge2dev-dell-fed.cs33.force.com/federalterms'
    connectedCallback(){
        this.currentYear =new Date().getFullYear();
    }
    
    /*handleDellTechnologiesUrlclick(event){
        console.log("handleDellTechnologiesUrlclick");
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.DellTechnologiesUrl
            }
        });
       
       
    }
    handleDellUrlClick(event){
        console.log("handleDellUrlClick");
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.DellUrl
            }
        });
       
       
    }

    handleDellEMCUrlClick(event){
        console.log("handlePartnerProgramClick");
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.DellEMCUrl
            }
        });
       
       
    }

    handleTermsUrlClick(event){
        console.log("handleTermsUrlClick");
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.TermsUrl
            }
        });
       
       
    }

    handleFederalTermsurlClick(event){
        console.log("handleFederalTermsurlClick");
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.FederalTermsurl
            }
        });
       
       
    }*/


}