import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TRANSACTION_OBJECT from '@salesforce/schema/Certification__c';
import BPMCERTIFICATIONID_FIELD from '@salesforce/schema/Certification__c.BPM_Certification_Id__c';

export default class BPMCertification extends LightningElement {
    //Tracking Attribute Values
    @api iframeUrl;
    @api width;
    @api height;
    @api scrolling;
    @api frameBorder;
    @api styles;
    @api sandbox;
    @api cardName;
    @api objectApiName;
    /** Id of record to display. */
    @api recordId;

    /* Load Transaction__c.Transaction_Id__c for custom rendering */
    @wire(getRecord, { recordId: '$recordId', fields: [BPMCERTIFICATIONID_FIELD] })
    transaction(result){
      if(result.data){
          let bpmCertificationId = result.data.fields.BPM_Certification_Id__c.value;
          this.iframeUrl = this.iframeUrl.substring(0, this.iframeUrl.lastIndexOf('/'));
          this.iframeUrl = this.iframeUrl+'/'+bpmCertificationId;
          //alert('=iframe url='+this.iframeUrl);
          console.log('iframe value'+ this.iframeUrl); 
      }
      else if(result.error)
      {
        //something went wrong
      }
    }


}