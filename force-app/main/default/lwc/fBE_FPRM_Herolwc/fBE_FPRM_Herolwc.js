import { LightningElement, api} from 'lwc';
import IMAGE_URL from '@salesforce/resourceUrl/FBE_FPRM_Resources';
const IMAGE = 'Image';
export default class FBE_FPRM_Herolwc extends LightningElement {
    @api title;
    @api slogan;
    @api buttonText;
    @api heroDetailsPosition;
    @api resourceUrl;
    @api imgOrVideo ='IMAGE';
    @api internalResource;
    @api overlay;
    @api opacity;
    @api resUrl;


    connectedCallback() {
        this.resUrl = IMAGE_URL + this.resourceUrl;
        console.log('***this resource URL***'+ this.resUrl);

    }
    

    get isImg() {
        return this.imgOrVideo === IMAGE;
    }

    get isOverlay() {
        return this.overlay === 'true';
    }

    // Apply CSS Class depending upon what position to put the hero text block
    get heroDetailsPositionClass() {
        if (this.heroDetailsPosition === 'left') {
            return 'c-hero-center-left';
        } else if (this.heroDetailsPosition === 'right') {
            return 'c-hero-center-right';
        }

        return 'c-hero-center-default';
    }

    renderedCallback() {
        // Update the overlay with the opacity configured by the admin in builder
        const overlay = this.template.querySelector('div');
        if (overlay) {
            overlay.style.opacity = parseInt(this.opacity, 10) / 10;
        }
    }


}