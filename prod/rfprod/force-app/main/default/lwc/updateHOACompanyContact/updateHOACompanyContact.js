import { LightningElement,api } from 'lwc';
import vendorRecords from '@salesforce/apex/UpdateHOACompanyContactController.vendorRecords';
import saveHOAVendorInfo from '@salesforce/apex/UpdateHOACompanyContactController.saveHOAVendorInfo';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class UpdateHOACompanyContact extends LightningElement {
    propertyId;
    propertyUnitId;
    @api recordId;
    vendorDetails;
    companyName;
    rsAccountID;
    email;
    phone;
    name;
    firstName;
    lastNmae;
    fields ={};
    vendorDetails = {};

    connectedCallback() {
        window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
                vendorRecords({
                "recordId":this.recordId
                }).then(result=>{
                    this.vendorDetails = result;
                    console.log('-result-'+JSON.stringify(result));
                    console.log('vendor detauls -'+result);
                for(let i=0; i < this.vendorDetails.length; i++) {
                    console.log('inside if condition');
                    if(this.vendorDetails[i].Type__c == 'HOA Company') {
                        this.companyName = this.vendorDetails[i].Name;
                        this.rsAccountID = this.vendorDetails[i].HOA_Company_Account__c;
                        console.log('RS Account value::'+this.companyName + this.rsAccountID);
                    } else if(this.vendorDetails[i].Type__c == 'HOA Company Contact') {
                        this.email = this.vendorDetails[i].Email__c;
                        this.phone = this.vendorDetails[i].Phone__c;
                        this.name = this.vendorDetails[i].Name;
                        this.remittanceAddress = this.vendorDetails[i].Remittance_Address__c;
                        console.log('BPM Contact value::'+ this.name +this.email + this.phone);
                    }
                }
                this.isLoaded = true;
            })
        }, 0);
        this.isLoaded = true;
    } 

    // method to upsert vendor detail and update current HOA record.
    save(event){
        if(this.isInputValid()) {
        var inp=this.template.querySelectorAll("lightning-input");
        var area=this.template.querySelectorAll("lightning-textarea");
        inp.forEach(function(element){
            if(element.name=="companyName"){
                this.fields.companyName=element.value;
            }
            else if(element.name=="rsAccountId"){
                this.fields.rsAccountId=element.value;
            }
            else if(element.name=="name"){
                this.fields.name=element.value;
            }
            else if(element.name=="email"){
                this.fields.email=element.value;
            }
            else if(element.name=="phone"){
                this.fields.phone=element.value;
            }
            

        },this);

        area.forEach(function(element){
            if(element.name=="remittanceAddress"){
                this.fields.remittanceAddress=element.value;
            }
        },this);
        
        console.log('-fields-'+JSON.stringify(this.fields));

        saveHOAVendorInfo({
            "updatedVendorInput":JSON.stringify(this.fields),
            "recordId":this.recordId
        }).then(result =>{
            if(result){
                console.log("result is success");
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Data Updated Successfully!!!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isLoaded = true;
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            else{

                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Data Failed to Update',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isLoaded = true;
            }
        })
    }
    }

    Close(event){
        this.dispatchEvent(new CustomEvent('close'));
        
    }
    handleClose(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.hoaContact');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
            
        });
        return isValid;
    }
}