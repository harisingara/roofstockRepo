import { LightningElement,api,track,wire } from 'lwc';
import getDiligence from '@salesforce/apex/InspectionHelper.inspection';
import linkDiligence from '@salesforce/apex/InspectionHelper.associatedInspectionToJob';
import { NavigationMixin } from 'lightning/navigation';
import JOB_OBJECT from '@salesforce/schema/Job__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CreateRecordInLWC extends NavigationMixin(LightningElement) {

@api recordId;
@api recordTypeId;
@track propertyUnit;
@track property;
@track objectInfo;
@track recTId;

@wire(getObjectInfo, { objectApiName: JOB_OBJECT})
handleObjectInfo({error, data}) {
    if (data) {
        const rtis = data.recordTypeInfos;
        this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Renovation');
    }
}

connectedCallback(){
    getDiligence({recordId: this.recordId })
    .then(result =>{
        this.propertyUnit = result.Property_Unit__c;
        this.property = result.Property__c;
        //alert('=1=');
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; 
        var yyyy = today.getFullYear();
        //alert('2');
        var jobName;
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        today = yyyy+'-'+mm+'-'+dd;
        jobName = 'Renovation-'+result.Property_Unit__r.Name+'-'+today;

        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName == 'Property_Unit__c')
                    field.value = this.propertyUnit;
                if(field.fieldName == 'Property__c')
                    field.value = this.property;
                if(field.fieldName == 'Name')
                    field.value = jobName;
                if(field.fieldName == 'Job_Type__c')
                    field.value = 'Renovation';
            });
        }

       
})
}

handleSubmit(event){
    const fields = event.detail.fields;
    this.template.querySelector('lightning-record-edit-form').submit(fields);
 }
 handleSuccess(event){
   //alert('Success'+this.recordId);
  // alert('event'+event.detail.id);
    //console.log('==============record id', event.detail.id);
    linkDiligence({delRecordId:this.recordId,jobRecordId:event.detail.id})
    .then(result =>{  
        if(result){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.detail.id,
                    actionName: 'view',
            },
        });
    }
    })


 }




/*
renderedCallback() {
    alert('=ppt unit='+this.propertyUnit);
    const inputFields = this.template.querySelectorAll(
        'lightning-input-field'
    );
    if (inputFields) {
        inputFields.forEach(field => {
            if(field.fieldName == 'Name')
                field.value = 'Tushar Sharma';
            if(field.fieldName == 'AccountNumber')
                field.value = '987987';
        });
    }
}

*/

}