import { LightningElement,api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SelectOrdersToAssociateToEngagement extends NavigationMixin(LightningElement) {
    @api orderListToSelect;
    @api selectedOrdersList;
    @track _accountNameByOrderIdMap;
    noOrdersSelected = false;
    userDetailNavigateRef;
    recordPageId;

    statusList = 
    {
        BK: 'Booked', CL: 'Cancelled', HL: 'On Hold', EC: 'Export Compliant', PP: 'Pre-Production', IP: 'In Production', SC: 'Ship Completed',
        MN: 'Manifest', TG: 'Shipped', CD: 'Shipped/Closed', IN: 'Invoiced'
    };

    gridColumns = [
        {
            type: 'text',
            fieldName: 'OrderNumber__c',
            label: 'Order Number',
            initialWidth: 130,
        },
        {
            type: 'text',
            fieldName: 'Status',
            label: 'Order Status',
            initialWidth: 120,
        },
        {
            type: 'text',
            fieldName: 'BUID__c',
            label: 'BUID',
            initialWidth: 80,
        },
        {
            type: 'text',
            fieldName: 'AccountName',
            label: 'Account Name',
            initialWidth: 170,
        },
        {
            type: 'text',
            fieldName: 'LineItems',
            label: 'Line Items',
            initialWidth: 100,
        },
        {
            type: 'text',
            fieldName: 'TotalAmount',
            label: 'Order Amount',
            initialWidth: 130,
        }
    ];

    gridData=[];

    @api
    get accountNameByOrderIdMap(){
        return this._accountNameByOrderIdMap;
    }    
    set accountNameByOrderIdMap(value){        
        this.setAttribute('accountNameByOrderIdMap', value);
        this._accountNameByOrderIdMap = value;   
    }

    connectedCallback(){
        var map = new Map(Object.entries(this._accountNameByOrderIdMap));
        var statusMap = new Map(Object.entries(this.statusList));
        var isDisabled;
        var lineItems;
        var orderIsCancelled = false;
        var orderHasNoLineItems = false;
        var orderIsAssociatedToEngagement = false;

        for (var i=0, item; item = this.orderListToSelect[i]; i++) {
            isDisabled = 'slds-hint-parent';
            this.orderIsCancelled = (item.Status === 'CL');

            if ((item.Status === 'BK') && (item.OrderItems == null)){
                this.orderHasNoLineItems = true;
                lineItems = 0;    
            }else{
                lineItems = item.OrderItems.length;
                this.orderHasNoLineItems = false;    
            }

            this.orderIsAssociatedToEngagement = (item.Project__c != null);

            if ((this.orderIsCancelled) || (this.orderHasNoLineItems) || (this.orderIsAssociatedToEngagement)){
                isDisabled = isDisabled + ' disabled';        
            }
            
            var orders = {
                OrderNumber__c: item.OrderNumber__c,
                BUID__c:item.BUID__c,
                Status:statusMap.get(item.Status),
                AccountName: map.get(item.AccountId),
                LineItems:lineItems,
                TotalAmount: item.CurrencyIsoCode + ' ' + parseFloat(item.TotalAmount).toFixed(2),
                Id:item.Id,
                IsDisabled: isDisabled,
                IdCheckbox: 'checkbox-0' + i,
                IdCheckboxButton: 'check-button-label-0'+i,
                IdCheckboxButtonLabelledBy: 'check-button-label-0'+i+' '+ 'column-group-header'                
            };
            this.gridData[i] = orders;            
        }
    }
    
    @api
    handleOrderSelection(){
        this.noOrdersSelected = false;
        var rowCount;
        var order;
        var selectedOrders=[];
        var checkboxIsChecked;
        

        var tableRows = this.template.querySelector("table").rows;        
        for(rowCount=1; rowCount < tableRows.length; rowCount++){
            checkboxIsChecked = (tableRows[rowCount].firstChild.firstChild.firstElementChild.checked);
            if (checkboxIsChecked){                
                order = {
                    OrderNumber__c: tableRows[rowCount].cells[1].innerText,                
                    Status:tableRows[rowCount].cells[2].innerText,
                    BUID__c:tableRows[rowCount].cells[3].innerText,
                    AccountName: tableRows[rowCount].cells[4].innerText,
                    LineItems:tableRows[rowCount].cells[5].innerText,
                    TotalAmount: tableRows[rowCount].cells[6].innerText,
                    Id:tableRows[rowCount].dataset.id
                };
                selectedOrders[rowCount-1] = order;                
            }
        }
        if (selectedOrders.length <= 0){
            this.noOrdersSelected = true;
            return    
        }
        const retrieveSelectedOrdersEvent = new CustomEvent('retrieveselectedorders', {detail: selectedOrders});
        this.dispatchEvent(retrieveSelectedOrdersEvent);
    }

    handleCheckAll(event){
        var rowCount;
        var tableRows;

        tableRows = this.template.querySelector("table").rows;
        for(rowCount=1; rowCount < tableRows.length; rowCount++){
            if (tableRows[rowCount].classList.length > 1){
                continue;
            }            
            tableRows[rowCount].firstChild.firstChild.firstElementChild.checked = event.target.checked;                                                                            
        }
    }

    disableError(){
        this.noOrdersSelected = false;    
    }

    @api
    navigateToOrderRecordPage = (event) =>{
        var orderIdClicked = event.target.getAttribute('data-id');

        this.userDetailNavigateRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: orderIdClicked,
                objectApiName: 'Order',
                actionName: 'view'
            }
         };

        this[NavigationMixin.GenerateUrl](this.userDetailNavigateRef)
         .then(url => { window.open(url, "_blank") });
    }
}