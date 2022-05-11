/****************************************************************************************************
 * Author         : Dell Team - CPQ [Sireesha Myla - STORY 12079756]
 * Description    : Apply Contract button on FPRM opportunity. 
 * Date Created   : 09-Mar-2022
 * Version        : 1.0
 * Modification Log           Developer          Last Modified Date           Description
 * 1.0                        Sireesha Myla      17-Mar-2022                  STORY 12079756
 * 
 ****************************************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getContracts from '@salesforce/apex/FBE_CPQ_ContractHandler.getContracts';
import updateOpp from '@salesforce/apex/FBE_CPQ_ContractHandler.saveOpportunity';
import includeContract from '@salesforce/label/c.FBE_CPQ_IncludeContract';
import FBE_CPQ_OPTYSTAGE from '@salesforce/label/c.FBE_CPQ_Opp_SalesStageLOVs';
import FBE_CPQ_CloseOptyError from '@salesforce/label/c.FBE_CPQ_LockedOptyError';
import FBE_CPQ_OPTY_RECORTYPE from '@salesforce/label/c.FBE_CPQ_Opp_Standard_RecordType';
import FBE_CPQ_applyContractAccountNull from '@salesforce/label/c.FBE_CPQ_applyContractAccountNull';
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
            if (data) 
            {
                this.opportunity = data;  
                this.recordTypeName = this.opportunity.recordTypeInfo.name;
                let optyStage = this.opportunity.fields.StageName.value;
                var optyStageList = FBE_CPQ_OPTYSTAGE.split(',');
                var isoptystage = false;
                if(optyStageList)
                {
                    optyStageList.forEach(stage => {
                        if(stage.toUpperCase() === optyStage.toUpperCase() && this.recordTypeName == FBE_CPQ_OPTY_RECORTYPE)
                        {
                            isoptystage = true;
                            return;            
                        }
                    });
                }
                this.isClosedOpty = isoptystage ? false : true;
            }else if(error){
                        console.log('Wired Error :::::', error);
                    }
        }
    connectedCallback()
    {   
        this.isShowComponent = this.recordId.startsWith("006") ? true : false;
    }
    handlepopup(event)
    {
        let title = '';
        var optystages = this.optyStageIs;
        this.applyFlag = false;
     
        getContracts({optyId: this.recordId})
        .then(result =>{
           if( this.isClosedOpty === true)
           {
              this.checkBool = false;
              let msg = FBE_CPQ_CloseOptyError;
                            this.showToast(msg, 'error', title);
           }
           else if(result.length>1)
           {
                this.checkBool = true;
                this.options = result; 
                this.options = result.map(item=>{
                return {...item,"nameColor":"slds-text-color_success" }
                })           
           }
           else if(result.length == 0){
                this.checkBool = false;
              let msg = FBE_CPQ_applyContractAccountNull;
              
                            this.showToast(msg, 'warning', title);
           }
           else {
                this.checkBool = false;
                updateOpp({optyId: this.recordId, conId :result[0].Id })
                .then(result =>{
                    this.recordId = result;
                    this.checkBool = false;
                    let msg = 'Opportunity Updated Successfully!';
                                    this.showToast(msg, 'success', title);
                    eval("$A.get('e.force:refreshView').fire();");
                })
                .catch(error =>{
                    this.showToast(error.body.message, 'error', title);
                    return;
                })
            }
        })
        .catch(error =>{
            this.showToast(error.body.message, 'error', title);
        })
    }
    getselected(event)
    {
         var selectedRows=event.detail.selectedRows;
         console.log('selectedRows :'+event.detail.selectedRows);
         if(selectedRows.length >0)
         {
             this.applyFlag = true;
         }
         this.selectedRowId = selectedRows[0].Id;
    }
    onApplyContract(event) 
    {
        let title = '';
       updateOpp({optyId: this.recordId, conId :this.selectedRowId })
        .then(result =>{
            this.recordId = result;
                console.log('result:',this.selectedRowId);
             this.checkBool = false;
             let msg = 'Opportunity Updated Successfully!';
               console.log('Success:',msg);             
                            this.showToast(msg, 'success', title);
             eval("$A.get('e.force:refreshView').fire();");
             return;
        })
        .catch(error =>{
            console.log('Error :'+error.body.message);
           this.showToast(error.body.message, 'error', title);
             return;
        })
        
    }
    
    showPopUp()
    {
        this.checkBool = true;// Enable popup
    }
    closeModal()
    { 
        this.checkBool = false; //Disable popup
    }
    showToast(msg, varientType, title) 
    {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: varientType
        });
        this.dispatchEvent(event);
     }
}