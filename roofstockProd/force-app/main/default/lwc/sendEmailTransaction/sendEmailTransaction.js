import { LightningElement,api,track } from 'lwc';
import fromAddress from '@salesforce/apex/EmailMessages.fromAddress';
import transactionDetails from '@salesforce/apex/SendEmailHoa.getTransactionId';


export default class SendEmailTransaction extends LightningElement {
    @api recordId;
    @track body;
    @track emailServiceAddress;
    @track from;
    @track toEmail;
    @track ccEmail;
    @track transactionId;
    composeEmail = false;

connectedCallback(){
    transactionDetails({
        recId:this.recordId
    }).then(data=>{
        if(data){
            this.transactionId = data;
        }
    })

    fromAddress({
        recordId:this.recordId
    }).then(data=>{
            if(data){
                this.from = data;
                this.emailServiceAddress =  data;
                this.body = '<br/><br/>ref:TRNS-'+this.transactionId;
            }

    });

}
closeModal(){
    const closeQA = new CustomEvent('closepopup');
    this.dispatchEvent(closeQA);
}
sendEmail(event){
    this.composeEmail = true;
}
    
}