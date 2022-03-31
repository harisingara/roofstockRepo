import { LightningElement,api,track } from 'lwc';
import escalateToBuyerBroker from '@salesforce/apex/EscalateToBuyerBrokerController.escalateToBuyerBroker';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class EscalateToBuyerBroker extends LightningElement {
    @api recordId;
    @track escalateSuccess;
    @track escalateFailed;
    @track isLoaded;
    connectedCallback(){
        escalateToBuyerBroker({
            recordId:this.recordId
        }).then(data=>{
            if(data){
                this.escalateSuccess = true;
                this.isLoaded = true;
            }
            else{
                this.escalateFailed = true;
                this.isLoaded = true;
            }

        })
    }
    closeQA(){
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA); 
    }
}