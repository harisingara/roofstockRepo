import { LightningElement,wire,track,api} from 'lwc';
import hoaDetails from '@salesforce/apex/SendEmailHoa.hoaDetails';
import fromAddress from '@salesforce/apex/EmailMessages.fromAddress';

export default class SendEmailHOA extends LightningElement {

    @api recordId;
    @track hoaEmail;
    @track body;
    @track emailServiceAddress;
    @track from;
    @track bccEmail;
    @track ccEmail;

    connectedCallback(){
        hoaDetails({
            recordId:this.recordId
        }).then(data=>{
            console.log('-data-'+data);
            this.hoaEmail = data.Payment_Email__c;
            this.body = '<br/><br/>ref:'+this.recordId;
            this.ccEmail = data.PM_Email__c;
        });

        fromAddress({
            recordId:this.recordId
        }).then(data=>{
                if(data){
                    this.from = data;
                    this.bccEmail = data;
                }
        });
    }

    closeModal() {
        const closeQA = new CustomEvent('closepopup');
        this.dispatchEvent(closeQA);
    }

}