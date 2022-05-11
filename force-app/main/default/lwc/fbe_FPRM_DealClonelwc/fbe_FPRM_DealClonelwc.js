import { LightningElement, api, wire,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import originalDealReg from '@salesforce/apex/FBE_FPRM_DealCloneHandler.originalDealReg';
import onSubmitUI from '@salesforce/apex/FBE_FPRM_DealCloneHandler.onSubmitUI';

export default class Fbe_FPRM_DealClonelwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @track errorMsg ;
    @api newDealId;
    @api oldDealRegId;
    @api dealRelatedProds = [];
    @api isdealProds = false;
    @api dealRecord =[];
    @api childRecord = [];
    @track mapData= [];
    @track mapValue = [];
    @track mapChildData= [];
    @track mapChildValue = [];
    @api childArrays =[];
    @track name;
   
    @wire(originalDealReg, {dealId: "$recordId"}) 
    deal({error, data})
    {
        if(data){
            this.oldDealRegId = data.dealId; 
            this.dealRelatedProds = data.dealProducts;
            if(this.dealRelatedProds.length>0)
            {
                this.isdealProds = true;
            }
            else if(this.dealRelatedProds.length == 0 )
            {
                this.isdealProds = false;
            }
        }else if(error){
            console.log(error);
        }
    };
   
    
    @track dname;
    @track bookdate;
   
    connectedCallback()
    {
        console.log('dname:'+this.dname);
        this.dname='';
        this.bookdate = '';
        
        /*    var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();
            today = yyyy + '-' + mm + '-' + dd;
            //console.log('old date:'+this.template.querySelector('[data-bookdate]').value);
            console.log(today);
        this.bookdate = today;*/
       
       
    
        /*this.name = this.template.querySelector('[data-name]').value;
        this.template.querySelector('[data-name]').value = '';
        
        */
        
    }
    handleQuantityChange(event)
    {
        var element =event.target.dataset.id;
        console.log(event.target.value+'element:'+element);
        let tempAllRecords =  JSON.parse(JSON.stringify(this.dealRelatedProds));
        console.log(tempAllRecords+'JSON: '+tempAllRecords.length);
        tempAllRecords[element].FBE_Quantity__c = event.target.value;
        this.dealRelatedProds = tempAllRecords;
      
        this.dealRelatedProds = [...this.dealRelatedProds];
        console.log('quant change:'+JSON.stringify(this.dealRelatedProds));
    }
    handlePriceChange(event)
    {
        var element =event.target.dataset.id;
        console.log(event.target.value+'element:'+element);
        let tempAllRecords =  JSON.parse(JSON.stringify(this.dealRelatedProds));
        console.log(tempAllRecords+'JSON : '+tempAllRecords.length);
        tempAllRecords[element].FBE_Sales_price__c = event.target.value;
        this.dealRelatedProds = tempAllRecords;

        this.dealRelatedProds = [...this.dealRelatedProds];
        console.log('price change:'+JSON.stringify(this.dealRelatedProds));
    }
    handleError(event) 
    {
        var message = '';
        if (Object.entries(event.detail.output.fieldErrors).length !== 0) {
            const getField = Object.keys(event.detail.output.fieldErrors)[0];
            message = event.detail.output.fieldErrors[getField][0].message;
        }
        else {
            message = event.detail.message + "\n" + event.detail.detail;
        }
    }
    handleSubmit(event) {

        event.preventDefault(); 
        console.log('submit  = ' + JSON.stringify(this.dealRelatedProds));
        const fields = this.template.querySelectorAll('lightning-input-field');
       
        if (fields){
            this.dealRecord =this.apexParentRecordCreation(fields)
            
        }
       
        let tempAllRecords = JSON.parse(JSON.stringify(this.dealRelatedProds));
       onSubmitUI({dealRec: this.dealRecord,lstProducts:tempAllRecords})
        .then(result =>{
            this.newDealId = result;
            console.log('New Rec:'+this.newDealId);
            this.showToast('New Deal Registration was created successfully.', 'SUCCESS', 'success');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.newDealId,
                        objectApiName: 'Deal_Registration__c',
                        actionName: 'view'
                    }
                });
            
        })
        .catch(error =>{
            this.errorMsg = error;
            this.showToast('Something went wrong', error.body.message, 'error');
            return;
        })
        
        
    }
    handleSuccess(event) {
     
        console.log('success: Id'+event.detail.id);
        
        console.log('Prod List: '+this.dealRelatedProds.length);
        this.newDealId = event.detail.id;
       
        
    }
   
    onCancel1() 
    {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Deal_Registration__c',
                actionName: 'view'
            }
        });
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    
    removeRow(event){
        let tempAllRecords = Object.assign([], this.dealRelatedProds);
        console.log('rmv :'+event.target.dataset.id);
                let idTodel = event.target.dataset.id;
		        tempAllRecords.splice(idTodel,1);
                //tempAllRecords[j] = tempRec;
        
        this.dealRelatedProds = tempAllRecords;
        console.log('Prod List:'+this.dealRelatedProds.length);
        if(this.dealRelatedProds.length == 0 )
        {
            this.isdealProds = false;
        }
     
    } 
    apexParentRecordCreation(data){
        if(data){
            data.forEach(items=>{
                this.mapData.push(items.fieldName)
                this.mapValue.push(items.value)
            })
        }
        const keys = JSON.stringify(this.mapData)
        const values = JSON.stringify(this.mapValue)
        const resultdata =  JSON.parse(values).reduce(function(result, field, index) {
        result[JSON.parse(keys)[index]] = field;
        return result;
        }, {})
        return resultdata       
    }
   

}