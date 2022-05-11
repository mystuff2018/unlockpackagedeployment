import { LightningElement, wire, api, track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDealReg from '@salesforce/apex/FBE_FPRM_Deal_Transfer_Controller.getDealRegs';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import DealReg_OBJECT from '@salesforce/schema/Deal_Registration__c';
import DealReg_Status_FIELD from '@salesforce/schema/Deal_Registration__c.FBE_Deal_Registration_Status__c';
import updateDealOwnerLEX from '@salesforce/apex/FBE_FPRM_UpdateDealOwner.updateDealOwner';
import USER_ID from '@salesforce/user/Id';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';  
import ContactID_FIELD from '@salesforce/schema/User.ContactId';
import OnlineRole_FIELD from '@salesforce/schema/User.FBE_FPRM_OnlineRole__c';
import ProfileName_FIELD from '@salesforce/schema/User.Profile.Name';

const columns = [
    {label: 'Registration #',fieldName: 'FBE_Deal_Reg_Num__c',sortable: true}, 
    {label: 'Registration Name',fieldName: 'Name',sortable: true},
    {label: 'Opportunity Name',fieldName: 'opportunityName',sortable: true},
    {label: 'Submitter Name',fieldName: 'FBE_Deal_Submitter_Name__c',sortable: true},
    {label: 'Partner Owner',fieldName: 'FBE_Partner_Owner__c',sortable: true},
    //{label: 'Owner',fieldName: 'ownerName',sortable: true}, //TEKI: Jun-3-2021:10695973 : added Partner owner as per the defect.
    {label: 'Partner Sales Rep Name',fieldName: 'FBE_Partner_Sales_Rep_Name__c',sortable: true},
    {label: 'Partner Sales Rep Email',fieldName: 'FBE_Partner_Sales_Rep_Email__c',sortable: true},
    {label: 'Partner Sales Rep Phone',fieldName: 'FBE_Partner_Sales_Rep_Phone__c',sortable: true},
    {label: 'Update status',fieldName:'updateStatus'}
];

export default class FBE_FPRM_Transfer_Deal_Lwc extends LightningElement {

    @track regStatusOptions;
    @track isModalOpen = false;
    @track noOfRecordSelected;
    @track selectedDealRecords;
    @api selectedOwnerId;
    @track isLoading = false;

    @track isOuterLoading = false;
    @track isInnerLoading = false;
    
    @track data; 
    columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    selectedRows = [];
    @api partnerOwnerEmail = '';
    @api submitterEmail = '';
    @api regNumber = '';
    @api dealRegStatus = '';
    @api partnerSalesEmail = '';
    internalProfiles = ["FBE Business Admin", "FBE System Administrator", "System Administrator"];
    
    @track showErrorMessage;
    @track isUseFeature;
    //Fetch current partner userdata to fetch contact information
    @wire(getRecord, {recordId: USER_ID,fields: [ContactID_FIELD,ProfileName_FIELD],optionalFields: [OnlineRole_FIELD] }) 
    wireuser({error,data}) {
        if (error) {
           console.log('error::' + JSON.stringify(error));
        } else if (data) {
            let contactId = getFieldValue(data, ContactID_FIELD);
            let onlineRole = getFieldValue(data, OnlineRole_FIELD);
            let profileName = getFieldValue(data, ProfileName_FIELD);
            console.log('==contactId===' + contactId);
            console.log('==onlineRole===' + onlineRole);
            console.log('==profileName===' + profileName);
            if(contactId === null && this.internalProfiles.includes(profileName)){
                this.showErrorMessage = false;
                this.isUseFeature  = true;
            }
            else if(contactId !== null && onlineRole.includes("Admin")){
                this.showErrorMessage = false;
                this.isUseFeature  = true;
            }
            else{
                this.showErrorMessage = true;
                this.isUseFeature  = false;
            }
        }
    }

    @wire(getDealReg, {ownerEmail: '$partnerOwnerEmail',submitterEmail: '$submitterEmail',regNumber: '$regNumber',dealRegStatus: '$dealRegStatus',partnerSalesEmail: '$partnerSalesEmail'})
    wiredDeals({ error, data }) {
        if (data) {
            //this.data = data;
            this.data = data.map(row=>{
                return{...row,ownerName: row.Owner.Name, opportunityName: row.FBE_Related_Opportunity__c ? row.FBE_Related_Opportunity__r.Name : '',updateStatus: ''}
            })
            this.columns = columns;
            this.error = undefined;
            this.isOuterLoading = false;
        } else if (error) {
            this.error = error;
            this.data = undefined;
            this.isOuterLoading = false;
        }
    }
    
    //Get the Deal Reg Status picklist values
    @wire(getObjectInfo, { objectApiName: DealReg_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DealReg_Status_FIELD })
    getPicklistValues({ error, data }) {
        if (data) {
            this.regStatusOptions = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
            this.regStatusOptions = [ { label: '---None---', value: '', selected: true }, ...this.regStatusOptions];
        } else if (error) {
            console.log('==============Error  ' + error);
        }
    }

    validateLookupField() {
        this.template.querySelector('c-custom-lookup').isValid();
    }

    // Used to sort the column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    } 

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    searchDeals(){

        var checkOwnerEmailNull = false;
        //get the current owner email field value
        var inputs = this.template.querySelectorAll("lightning-input");
        inputs.forEach(function(element){
            if(element.name=="txtCurrOwnerEmail" && !element.value){
                checkOwnerEmailNull = true;
            }

        },this);
 

        if(checkOwnerEmailNull === true){
            this.showErrorToast('Partner owner email field is required!');
        }
        else{
            this.isOuterLoading = true;
            inputs.forEach(function(element){
                if(element.name=="txtRegNumber")
                    this.regNumber=element.value;
    
                else if(element.name=="txtSubEmail")
                    this.submitterEmail=element.value;
    
                else if(element.name=="txtPartnerSalesRepEmail")
                    this.partnerSalesEmail=element.value;
    
                else if(element.name=="txtCurrOwnerEmail")
                    this.partnerOwnerEmail = element.value
    
            },this);
    
            var statusValue = this.template.querySelector("lightning-combobox").value;
            console.log('statusValue===' + statusValue);
            if(statusValue === undefined){
                statusValue = '';
            }
            this.dealRegStatus = statusValue;
            return refreshApex(this.data);
        }
        

        
    }

    //Get the selected owner Id
    handleOwnerSelcted(event) {
        this.selectedOwnerId = event.detail;
    }
    
    onUserSelection(event){  
        this.selectedOwnerId = event.detail.selectedRecordId;  
    }      
    
    getSelectedDeals() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();  
        if (selectedRecords.length === 0) { 
            console.log("Display Pop up");
            this.showErrorToast('Select at least one Deal and try again.');
            //alert('Select at least one Deal and try again.');
        }
        else{
            console.log('selectedRecords===' + selectedRecords.length);
            this.noOfRecordSelected = selectedRecords.length;
            this.selectedDealRecords = selectedRecords;
            this.openModal();
        }
    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    showErrorToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: msg,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleChangeOwner(){

        //console.log('Selected Records==' + JSON.stringify(this.selectedDealRecords));
        //console.log('Selected OwnerId==' + this.selectedOwnerId);
        if(this.selectedOwnerId){

            //Used to re-render datatable once data update
            let currentData = [];
            this.data.forEach(function(element){  
                currentData.push(Object.assign(element, {}));                          
            });  
            this.data = [];
            this.isInnerLoading = true;

            updateDealOwnerLEX({ lstDeals: this.selectedDealRecords,ownerId: this.selectedOwnerId})
            .then((result) => {
                
                console.log('result===' + result);
                if(result.includes("Exception occured at")){
                    //if apex throw any error
                    this.showErrorToast('Something went wrong! please contact your administrator salesforce.');
                }
                else{
                    //get  the success and failed recordIds
                    let resultData =  JSON.parse(result); 
                    let varSuccessIds = resultData.successIds;
                    let varFailedIds = resultData.failedIds;

                    if(varFailedIds.length > 0){
                        this.showErrorToast('Some records are failed to update. Please check the update status.');
                    }
                    else{
                        this.showSuccessToast('Partner owner updated sucessfully!');
                    } 
                    let selectedRecordIds = [];
                    this.selectedDealRecords.forEach(function(element){
                        selectedRecordIds.push(element.Id);
                    });
                    //console.log('selectedRecordIds===' + selectedRecordIds);

                    currentData.forEach(function(element){  
                        if(selectedRecordIds.includes(element.Id)){
                            if(varSuccessIds && varSuccessIds.includes(element.Id)){
                                element.updateStatus = 'success';
                            }
                            else if(varFailedIds && varFailedIds.includes(element.Id)){
                                element.updateStatus = 'failure';
                            }
                        }                              
                    });  
                    //console.log('currentData===' +  JSON.stringify(currentData));
                    let datascope = this;
                    currentData.forEach(function(element){ 
                        //console.log('ID===' + element.Id);
                        datascope.data = [...datascope.data,element];
                    });
                    //console.log('this.data===' +  JSON.stringify(this.data));
                    this.closeModal();
                    this.isInnerLoading = false;
                    this.error = undefined;
                }               
            })
            .catch((error) => {
                console.log('error===' + error);
                this.error = error;
                this.contacts = undefined;  
            });
        }
        else{
            this.showErrorToast('Please select the user to assign owner.');
        }
        
    }

    //Reset search data and filter element
    resetPage(){
        this.regNumber = '';
        this.submitterEmail = '';
        this.partnerSalesEmail  = '';
        this.dealRegStatus = '';
        this.partnerOwnerEmail = '';
        this.setSelectedRows = []; 

        //Reset textbox values
        var inputs = this.template.querySelectorAll("lightning-input");
        inputs.forEach(function(element){
            element.value = '';
        },this);
        var statusCombo = this.template.querySelector("lightning-combobox");
        statusCombo.value = '';
        return refreshApex(this.data);
    }

}