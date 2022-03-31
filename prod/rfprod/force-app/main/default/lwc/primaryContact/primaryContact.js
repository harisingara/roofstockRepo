import { LightningElement,api,track } from 'lwc';
import primaryContacts from '@salesforce/apex/PrimaryContact.investmentAccountContacts';
import investmentAccount from '@salesforce/apex/PrimaryContact.investmentAccount';



export default class PrimaryContact extends LightningElement {
    @api recordId;
    @track showContacts;
    @track investmentAccountId;
    @track contacts;
    @track to;
    @track cc;
    @api selectContactContext;
    /* Get Primary Contact */
    connectedCallback(){
        investmentAccount({
            recordId:this.recordId
           }
            ).then(data=>{
                this.investmentAccountId = data;
                console.log('-investmentAccountId-'+this.investmentAccountId);

            })

    }

handleContacts(event){
    console.log('-recId-'+this.recordId);
    primaryContacts({
        recordId:this.recordId,
    investmentAccountId:this.investmentAccountId
}).then(data=>{
    console.log('-data-'+JSON.stringify(data));
    if(data.length>0){
        

        this.contacts =  data;
    }
    else{
        this.noContacts = true;
    }
})
this.showContacts = true;
this.showEmail = false;
    
}

/* Submit the selected contact's email Ids */
submitDetails(){

    let rows = Array.from(this.template.querySelectorAll("tr.inputRows") );
    var records=[];
    var recordToSave;
    rows.map(row => {
        let texts = Array.from(row.querySelectorAll(".fields"));
        if(texts)
        {
                var textVal=this.fieldValues(texts);
                records=[...records,textVal];
        }
    
    });
    
    let emailList=[];
    for(let i=0;i<records.length;i++){
        if(records[i].Selected){
            emailList.push(records[i].Email);
        }
    
    }
    if(emailList.length){
        if(this.selectContactContext == 'to'){
            this.to = emailList.join(',');
            this.to = Array.from(new Set(this.to.split(','))).toString();
            this.to  = this.to.replace(/,/g, ';');
            var selectedEvent = new CustomEvent('sendtoemails', { detail:  {primaryContacts : this.to}});
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
    
        }
        else if(this.selectContactContext == 'cc'){
            this.cc = emailList.join(',');
            this.cc = Array.from(new Set(this.cc.split(','))).toString();
            this.cc  = this.cc.replace(/,/g, ';');
            var selectedEvent = new CustomEvent('sendccemails', { detail:  {primaryContacts : this.cc}});
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);

        }
        /*else if(this.selectContactContext == 'tobtn'){
            this.contactEmail = this.contactEmail.replace(/;/g, ',');
            //this.contactEmail = this.contactEmail+','+emailList.join(',');
            if(!this.contactEmail){
                this.contactEmail = emailList.join(',');
            }
            else{
                this.contactEmail = this.contactEmail+','+emailList.join(',');
            }
            this.contactEmail = Array.from(new Set(this.contactEmail.split(','))).toString();
            this.contactEmail  = this.contactEmail.replace(/,/g, ';');
        }*/
    
    }
    
    
    this.showContacts = false;
    this.showEmail = true;
    }
    
    fieldValues(cells)
    {
    var obj = new Object();
    return cells.reduce((record, cell) => {
    if(cell.label == 'Selected'){
        var inputVal = cell.checked;
    }
    else{
        var inputVal = cell.value;
    }
    if(inputVal!=undefined)
    {
        
        record[cell.label] = inputVal;
        
    }
    return record;
        }, {});
    }

    closeModal(){
        this.showContacts = false;
    }
}