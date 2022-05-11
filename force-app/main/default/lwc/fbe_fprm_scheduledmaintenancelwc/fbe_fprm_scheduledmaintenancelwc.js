import { LightningElement,api } from 'lwc';

export default class Fbe_fprm_scheduledmaintenancelwc extends LightningElement {
    @api showmessage = false;
    @api maintenancemessage ='We Will be right back';
}