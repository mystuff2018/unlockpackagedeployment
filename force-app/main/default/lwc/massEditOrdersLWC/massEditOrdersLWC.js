import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import apexSearch from '@salesforce/apex/MassEditOrdersController.search';
import apexUpdateMilestone from '@salesforce/apex/MassEditOrdersController.updateMilestonesToProject';
import apexsaveSelectedOrders from '@salesforce/apex/MassEditOrdersController.saveSelectedOrders';
import ordersToProject from '@salesforce/apex/MassEditOrdersController.getOrdersToProject';

export default class massEditOrdersLWC extends LightningElement {
    @api objectApiName;
    @api recordId;
    @track currenObjectName;
    @track currenRecordId;
    @track milestoneIdAll;
    @track milestoneIdOrder;
    @track selectedOrder = [];
    @track orders;
    @track saving = false;
    @track selectAll = false;

    get isDisabledUpdateAll(){
        return this.milestoneIdAll == undefined || this.milestoneIdAll == null;
    } 
    
    get isDisabledSave (){
        return this.selectedOrder.length == 0 || (this.milestoneIdOrder == undefined || this.milestoneIdOrder == null) ;
    }

    connectedCallback() {
        this.currenRecordId = this.recordId;
        this.currenObjectName = this.objectApiName;
        this.orders = [];
        
        ordersToProject({ 
            projectId: this.currenRecordId
        })
        .then(results => {
            for(const order of results){
                this.orders.push({label: order.OrderNumber__c, value: order.Id});
                console.log(order);
            }
            
        })
        .catch(error => {
            console.log(error);
        });
    }

    handleOrderChange(event){
        console.log(JSON.parse(JSON.stringify(event.detail.value)));
        this.selectedOrder = event.detail.value;
    }

    handleSelectAllChange(event){
        this.selectAll = event.target.checked;

        if(this.orders != null) {
            if(this.selectAll === true){
                this.selectedOrder = [];
                for(var i = 0 ; i < this.orders.length ; i++){
                    this.selectedOrder.push(this.orders[i].value);
                }
            }
            else
            {
                this.selectedOrder = [];
            }
        }
    }

    handleSearch(event) {

        var eventDetail = JSON.parse(JSON.stringify(event.detail));
        eventDetail.searchTerm += ";"+this.currenRecordId;
        const target = event.target;
        apexSearch(eventDetail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    }

    handleSelectionChangeAll(event){
        const selection = JSON.parse(JSON.stringify(event.target.getSelection()));
        console.log(selection);
        if(selection != null && selection.length > 0){
            this.milestoneIdAll = selection[0].id;
            console.log(selection[0].id);
            console.log(selection[0]);
         

        }else{
            this.milestoneIdAll = null;
            
        }
        
        console.log(selection);
    }

    handleSelectionChangeOrder(event){
        
        const selection = JSON.parse(JSON.stringify(event.target.getSelection()));
        console.log(selection);
        if(selection != null && selection.length > 0){
            this.milestoneIdOrder = selection[0].id;
            console.log(selection[0].id);
            console.log(selection[0]);
      
        }else{
            this.milestoneIdOrder = null;
        }
        
        
    }

    updateMilestonesToProject() {
        this.saving = true;
        apexUpdateMilestone({
            projectId: this.currenRecordId, milestoneId: this.milestoneIdAll
        })
        .then(results => {
            this.saving = false;
            const evt = new ShowToastEvent({
                title: 'Success!',
                message: 'Record updated',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log(results);
            
        })
        .catch(error => {
            this.saving = false;
            console.log(error);
            
        });

    }

    handleSave(){
        this.saving = true;
        apexsaveSelectedOrders({
            projectId: this.currenRecordId, milestoneId: this.milestoneIdOrder, orderIdList: this.selectedOrder
        })
        .then(results => {
            this.saving = false;
            const evt = new ShowToastEvent({
                title: 'Success!',
                message: 'Record updated',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log(results);
            
        })
        .catch(error => {
            this.saving = false;
            console.log(error);
            
        });

    }

}