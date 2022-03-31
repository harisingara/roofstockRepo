import { LightningElement,track,api} from 'lwc';
import fromAddress from '@salesforce/apex/EmailMessages.fromAddress';

export default class SendEmailInspectionJob extends LightningElement {

    @api recordId;
    @track toEmail;
    @track body;
    @track emailServiceAddress;
    @track from;
    @track bccEmail;
    @track ccEmail;

    connectedCallback(){

        fromAddress({
            recordId:this.recordId
        }).then(data=>{
                if(data){
                    this.from = data;
                    this.emailServiceAddress =  data;
                    this.body = '<br/><br/>ref:'+this.recordId;
                }

        });
    }

    closeModal() {
        const closeQA = new CustomEvent('closepopup');
        this.dispatchEvent(closeQA);
    }

}