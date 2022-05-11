/****************************************************************************************************
 * Author         : Dell Team - CPQ [Ravi Sirigiri - STORY 11262962 ,Sireesha Myla - STORY 11262929]
 * Description    : Interlock between SFDC and DI(Create the new soulion in DI). 
 * Date Created   : 10/5/2021
 * Version        : 1.0
 * Modification Log           Developer          Last Modified Date           Description
 * 1.0                        Ravi Sirigiri      20-Oct-2021
 * 2.0                        Soumiithri Rekha   10-Mar-2022                  12079761- added contractstatusto URL
 ****************************************************************************************************/
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import DisableNewSolutionLabel from '@salesforce/label/c.FBE_CPQ_Disable_New_Solution';
import FBE_CPQ_OSC_Url from '@salesforce/label/c.FBE_CPQ_OSC_Url';
import FBE_CPQ_OSC_ErrorMsg from '@salesforce/label/c.FBE_CPQ_OSC_ErrorMsg';
import FBE_CPQ_OPTYSTAGE from '@salesforce/label/c.FBE_CPQ_Opp_SalesStageLOVs';
import FBE_CPQ_INCLUDECONTRACT from '@salesforce/label/c.FBE_CPQ_IncludeContract';
import FBE_CPQ_OPTY_RECORTYPE from '@salesforce/label/c.FBE_CPQ_Opp_Standard_RecordType';
import FBE_CPQ_OPTY_ERROR from '@salesforce/label/c.FBE_CPQ_ContractError';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Opportunity.Name', 'Opportunity.FBE_Opportunity_Number__c', 'Opportunity.FBE_CPQ_Latest_Solution_ID__c',
                'Opportunity.FBE_CPQ_Enduser_DCN__c', 'Opportunity.FBE_CPQ_Distributor_DCN__c', 
                'Opportunity.FBE_CPQ_Reseller_DCN__c', 'Opportunity.RecordType.Name', 'Opportunity.StageName','Opportunity.FBE_CPQ_ContractStatus__c','Opportunity.FBE_CPQ_ContractCode__c'];

export default class FBE_CPQ_createNewSolution extends LightningElement {
  @api recordId;
  opportunity;
  oscUrlParam;
  isHide;
  recordTypeName;
  titleOfTheButton;
  //buttonLabel;
  objedata;
  isShowOpty;
  isShowComponent;
  isShowContract;
  optyRecordId;

  connectedCallback(){   
    //this.buttonLabel = 'Create New Solution';
    //console.log('recordId:::', this.recordId);
    //this.campaignId = this.recordId;
    this.isShowComponent = this.recordId.startsWith("006") ? true : false;
    this.optyRecordId = this.isShowComponent ? this.recordId : '';
  }

  @wire(getRecord, { recordId: '$optyRecordId', fields: FIELDS })
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
      this.isHide = isoptystage ? false : true;
      this.titleOfTheButton = DisableNewSolutionLabel;
      this.isShowOpty = this.isShowComponent;
      if(FBE_CPQ_INCLUDECONTRACT.toUpperCase() == 'ACTIVE'){
        this.isShowContract = true;
      }
      else{
        this.isShowContract = false;
      }
  
    }else if(error){
      console.log('Wired Error :::::', error);
    }
  }

  handleClick(){
    console.log('opportunity:::',this.opportunity);
      var includeContractcode = FBE_CPQ_INCLUDECONTRACT;
      var contractStatus = this.opportunity.fields.FBE_CPQ_ContractStatus__c.value;
      var contractCode = this.opportunity.fields.FBE_CPQ_ContractCode__c.value;
      var oscUrlParam = FBE_CPQ_OSC_Url;     
      var opptyNum = this.opportunity.fields.FBE_Opportunity_Number__c.value;
      var opptyName = this.opportunity.fields.Name.value;
      var enduserDCN = this.opportunity.fields.FBE_CPQ_Enduser_DCN__c.value;
      var distributorDCN = this.opportunity.fields.FBE_CPQ_Distributor_DCN__c.value;
      var resellerDCN = this.opportunity.fields.FBE_CPQ_Reseller_DCN__c.value;
      var billTo = distributorDCN ? distributorDCN : resellerDCN;
      var soldTo = distributorDCN ? distributorDCN : resellerDCN; 
      var installedAt = this.opportunity.fields.FBE_CPQ_Enduser_DCN__c.value;
      var solutionId  = this.opportunity.fields.FBE_CPQ_Latest_Solution_ID__c.value; 
            
      solutionId = solutionId ? solutionId : null;
      resellerDCN = resellerDCN ? resellerDCN : null;
      //|| !resellerDCN
      let isNull = false;
      if(!opptyNum || !opptyName || !enduserDCN || !billTo  || !installedAt) isNull = true;
   
      console.log('this.oscUrlParam:::: ',oscUrlParam);
      if((contractStatus === '' || contractStatus.toUpperCase() !== 'ACTIVE') && includeContractcode.toUpperCase() === 'ACTIVE'){
        let msg = FBE_CPQ_OPTY_ERROR;
          let title = '';
          this.showToast(msg, 'error', title);
          console.log('OSC Inactivr::', msg);
      }
      
      else if (oscUrlParam && !isNull) {//
        oscUrlParam += 'dealid=' + opptyNum + '&opportunityname=' + opptyName + '&EndUser=' + enduserDCN + '&BillTo=' + billTo + '&SoldTo=' + soldTo + '&Reseller=' + resellerDCN + '&ShipTo=' + enduserDCN + '&InstallAt=' + installedAt + '&solutionid='+solutionId;
        console.log('this.oscUrlParam2222:::: ',oscUrlParam); 
        if(contractStatus.toUpperCase() == 'ACTIVE' && includeContractcode.toUpperCase() == 'ACTIVE'){
           console.log('OSC URL::', oscUrlParam);
          oscUrlParam += '&contractcode='+contractCode;
         
        }
        window.open(oscUrlParam, '_blank'); 
       
      }
      else{
        console.log('OSC Error::', oscUrlParam);
        let msg = FBE_CPQ_OSC_ErrorMsg;
        let title = '';
        this.showToast(msg, 'error', title);
      } 
      
  }

  showToast(msg, varientType, title) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: varientType
        });
        this.dispatchEvent(event);
     }

  showtooltip(){
    var divblock = this.template.querySelector('[data-id="tooltip"]');
        if(divblock){
            this.template.querySelector('[data-id="tooltip"]').className='toggle_none';
        }   
  }
  hidetooltip(){
      var divblock = this.template.querySelector('[data-id="tooltip"]');
        if(divblock){
            this.template.querySelector('[data-id="tooltip"]').className='toggle';
        }   
  }
  

}