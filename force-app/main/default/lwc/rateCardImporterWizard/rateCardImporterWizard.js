import { LightningElement, track } from 'lwc';
import upsertFromCSV from '@salesforce/apex/RateCardImporter.upsertFromCSV';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MAX_PREVIEW_LINES = 4;

export default class RateCardImporterWizard extends LightningElement {
    @track rateCardFile;
    @track rateCardFilePreview;
    showModal = false;
    errorMsg = null;
    isButtonDisabled = true;

    readFile(file) {
        let reader = new FileReader();
        reader.onload = () => {
            let filedata = reader.result;
            this.rateCardFile = {
                'filename': file.name,
                'filedata': filedata,
            };
            let fileSplit = this.rateCardFile.filedata.split('\n');
            this.rateCardFilePreview = '';
            for (let i=0; i < fileSplit.length && i < MAX_PREVIEW_LINES; i++) {
                this.rateCardFilePreview += fileSplit[i] + '\n';
            }
            if (fileSplit.length > MAX_PREVIEW_LINES) {
                this.rateCardFilePreview += `... (${(fileSplit.length - MAX_PREVIEW_LINES)} more lines)`;
            }
            this.rateCardFilePreview = this.rateCardFilePreview.trim();
            this.isButtonDisabled = false;
        }
        reader.readAsText(file);
    }

    onFileUpload(event) {
        this.readFile(event.target.files[0]);
    }

    onDropFile(event) {
        event.preventDefault();
        this.readFile(event.dataTransfer.files[0]);
        setTimeout(() => {
            let dropRegion = this.template.querySelector('.drop-region');
            dropRegion.classList.remove('drop-region-highlight');
        }, 85);
    }
    onDragOver(event) {
        event.preventDefault();
        setTimeout(() => {
            let dropRegion = this.template.querySelector('.drop-region');
            dropRegion.classList.add('drop-region-highlight');
        }, 25);
    }
    onDragLeave(event) {
        event.preventDefault();
        setTimeout(() => {
            let dropRegion = this.template.querySelector('.drop-region');
            dropRegion.classList.remove('drop-region-highlight');
        }, 85);
    }
    onDragEnter(event) {
        event.preventDefault();
        // setTimeout(() => {
        //     let dropRegion = this.template.querySelector('.drop-region');
        //     dropRegion.classList.add('drop-region-highlight');
        // }, 50);
    }
    onClickFileUpload() {
        let hiddenInput = this.template.querySelector('.hidden-file-input');
        hiddenInput.click();
    }

    closeModal(event) {
        this.showModal = false;
        this.errorMsg = null;
    }

    async handleImportRateCard(event) {
        let result = await upsertFromCSV({csvData: this.rateCardFile.filedata});
        let errorText = null;
        if (result.length > 0) {
            errorText = '';
            for (let error of result) {
                errorText += error.Description__c;
            }
            console.error(errorText);
            this.errorMsg = errorText;
            this.showModal = true;
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title:   'Success',
                    message: 'Rate Cards were successful!ly imported!',
                    variant: 'success'
                })
            );
        }
    }

}