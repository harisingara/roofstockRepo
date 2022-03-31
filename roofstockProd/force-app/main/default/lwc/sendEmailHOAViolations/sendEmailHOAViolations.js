import { LightningElement,wire,track,api} from 'lwc';
import violationHoaDetails from '@salesforce/apex/SendEmailHoa.violationHoaDetails';
import fromAddress from '@salesforce/apex/EmailMessages.fromAddress';
import toEmailAddress from '@salesforce/apex/SendEmailHoa.toAddress';

export default class SendEmailHOAViolations extends LightningElement {

    @api recordId;
    @track hoaEmail;
    @track body;
    @track emailServiceAddress;
    @track from;
    @track bccEmail;
    @track ccEmail;
    @track toEmail;

    connectedCallback(){
        violationHoaDetails({
            recordId:this.recordId
        }).then(data=>{
            console.log('-data-'+data);
            this.hoaEmail = data;
            //this.body = '<br/><br/>ref:'+this.recordId;
        });

        fromAddress({
            recordId:this.recordId
        }).then(data=>{
                if(data){
                    this.from = data;
                }

        });
        toEmailAddress({
            recordId:this.recordId
        }).then(data=>{
                if(data){
                    this.toEmail = data;
                }

        });
    }

    closeModal() {
        const closeQA = new CustomEvent('closepopup');
        this.dispatchEvent(closeQA);
    }

}