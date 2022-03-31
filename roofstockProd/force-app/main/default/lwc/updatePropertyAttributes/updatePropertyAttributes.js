import { LightningElement,api } from 'lwc';
import propertyRecordIds from '@salesforce/apex/UpdatePropertyAttributesController.propertyRecordIds';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class UpdatePropertyAttributes extends LightningElement {
    propertyId;
    propertyUnitId;
    @api recordId;
    invokeChildComponent;

    connectedCallback() {
        window.clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
            propertyRecordIds({
                "recordId":this.recordId
                }).then(result=>{
                    
                    console.log('-result-'+JSON.stringify(result));
                    console.log('-result1-'+result.propertyId);
                    console.log('-result2-'+result.propertyUnitId);
                this.propertyId = result.propertyId;
                this.propertyUnitId = result.propertyUnitId;
                this.invokeChildComponent = true;
            })
        }, 0);
     
    }
    closeQA(event){
        this.dispatchEvent(new CloseActionScreenEvent());     
    }  
}