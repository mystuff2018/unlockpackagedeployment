import { LightningElement,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class FBE_FPRM_Hero_Detailslwc extends NavigationMixin(LightningElement) {
   
    @api title;
    @api slogan;

  
}