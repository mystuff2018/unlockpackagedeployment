import { LightningElement, api, track, wire } from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getContracts from '@salesforce/apex/FBE_CPQ_ContractHandler.getContracts';
import updateOpp from '@salesforce/apex/FBE_CPQ_ContractHandler.saveOpportunity';
import includeContract from '@salesforce/label/c.FBE_CPQ_IncludeContract';
import FBE_CPQ_OPTYSTAGE from '@salesforce/label/c.FBE_CPQ_Opp_SalesStageLOVs';
import FBE_CPQ_CloseOptyError from '@salesforce/label/c.FBE_CPQ_LockedOptyError';
import FBE_CPQ_OPTY_RECORTYPE from '@salesforce/label/c.FBE_CPQ_Opp_Standard_RecordType';
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
let i=0;
const columns = [{ label: 'Name', fieldName: 'Name', hideDefaultActions: true, cellAttributes:{
        class:{fieldName:'nameColor'} }}];
const FIELDS = [STAGE_FIELD];
export default class FBE_CPQ_OptyComponent extends LightningElement 
{
    @api recordId;
    isShowComponent;
     @track checkBool = false;    
     columns = columns; 
     @api options = [];
     @track selectedValue;
     @track optyStageIs;
     @track applyFlag = false ;
      @track isClosedOpty = false;
      @track selectedRowId ;
     
      
   
     @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
     if (data) {
      
      this.opportunity = data;  
      //console.log('Oppty data::', this.opportunity);
      this.recordTypeName = this.opportunity.recordTypeInfo.name;
      //console.log('this.recordTypeName:::: ', this.recordTypeName);
      let optyStage = this.opportunity.fields.StageName.value;
      var optyStageList = FBE_CPQ_OPTYSTAGE.split(',');
      var isoptystage = false;
      if(optyStageList){
       // console.log('optyStageList>>>>',optyStageList);
        optyStageList.forEach(stage => {
          if(stage.toUpperCase() === optyStage.toUpperCase() && this.recordTypeName == FBE_CPQ_OPTY_RECORTYPE){
            isoptystage = true;
            return;            
          }
         });
      }
      //console.log('iS isHide  :::::', isoptystage);
      this.isClosedOpty = isoptystage ? false : true;
            
  
    }else if(error){
      console.log('Wired Error :::::', error);
    }
  }
     
    connectedCallback(){   
        //console.log('reco Id**', this.recordId);
        this.isShowComponent = this.recordId.startsWith("006") ? true : false;
        console.log('Flag**', this.isShowComponent);
        
        //this.optyRecordId = this.isShowComponent ? this.recordId : '';
    }
  
    onApplyContract(event) {
     
       updateOpp({optyId: this.recordId, conId :this.selectedRowId })
        .then(result =>{
            this.recordId = result;
            
             this.checkBool = false;
             let msg = 'Opportunity Updated Successfully!';
                            let title = '';
                            this.showToast(msg, 'success', title);
             eval("$A.get('e.force:refreshView').fire();");
        })
        .catch(error =>{
           this.showToast('Something went wrong', error.body.message, 'error');
             return;
        })
        
    }
    getselected(event)
    {
         var selectedRows=event.detail.selectedRows;
         console.log('row:',selectedRows);
         if(selectedRows.length >0)
         {
             this.applyFlag = true;
         }
           /* if(selectedRows.length>1)
            {
                var el = this.template.querySelector('lightning-datatable');
                selectedRows=el.selectedRows=el.selectedRows.slice(1);
                //this.showNotification();
                event.preventDefault();
                 
                return;
                
            }*/
            
             //for (let i = 0; i < selectedRows.length; i++){
                 console.log('log::: here', selectedRows[0].Id);
                 this.selectedRowId = selectedRows[0].Id;
           // }

    }
    handlepopup(event)
    {
        var optystages = this.optyStageIs;
        this.applyFlag = false;
        //this.checkBool = true;
         //this.options = [];
        console.log('reco Id**', this.recordId);
      /*  getdata({recordId: this.recordId})
        .then(result =>{
                this.options = result;
                console.log( 'Options are ' +JSON.stringify(this.options)  );
        })
        .catch(error =>{
            console.error( JSON.stringify( error ) );
        })*/
        
        getContracts({optyId: this.recordId})
        .then(result =>{
           if( this.isClosedOpty === true)
           {
              this.checkBool = false;
              let msg = FBE_CPQ_CloseOptyError;
                            let title = '';
                            this.showToast(msg, 'error', title);
           }
           else if(result.length>1){
            this.checkBool = true;
            this.options = result; 
            this.options = result.map(item=>{
              
              return {...item,"nameColor":"slds-text-color_success" }
            })
            console.log('record:::', result[0].Id);
           
           }
           else {
              this.checkBool = false;
            
              console.log('result:::', result[0].Id); 
              updateOpp({optyId: this.recordId, conId :result[0].Id })
              .then(result =>{
                  this.recordId = result;
                  
                  this.checkBool = false;
                  let msg = 'Opportunity Updated Successfully!';
                                  let title = '';
                                  this.showToast(msg, 'success', title);
                  eval("$A.get('e.force:refreshView').fire();");
              })
              .catch(error =>{
                let title = '';
                this.showToast(error.body.message, 'error', title);
                  return;
              })
           }
         
                
               /* for(i=0; i<result.length; i++) {
                                                           
                              const option = {
                                label: result[i].Name,
                                value: result[i].Name
                             }
                        this.options = [ ...this.options, option ];
               
                                            
                      }*/
                      
                     // console.log( 'Options are ' + JSON.stringify( result ) );
            
            //console.log(JSON.stringify(this.options)+ 'Options are ' +this.options  );

            
        })
        .catch(error =>{
           // this.showToast('Something went wrong', error.body.message, 'error');
             console.error( JSON.stringify( error ) );
        })

    }
    

    showPopUp(){

        this.checkBool = true;
       
    }

    closeModal() { 
 
        this.checkBool = false; 
        
 
    }
    
    showToast(msg, varientType, title) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: varientType
        });
        this.dispatchEvent(event);
     }


}