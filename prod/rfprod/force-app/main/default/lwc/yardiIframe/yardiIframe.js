import { LightningElement,wire,api,track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TURN_OBJECT from '@salesforce/schema/Turn__c';
import YARDIURL_FIELD from '@salesforce/schema/Turn__c.Property_Unit__r.Yardi_Unit_Id__c';
export default class YardiIframe extends LightningElement {
 //Tracking Attribute Values
 @api iframeUrl;
 @api width;
 @api height;
 @api scrolling;
 @api frameBorder;
 @api styles;
 @api sandbox;
 @api cardName;
 /** Id of record to display. */
 @api recordId;
  /* Load Transaction__c.Transaction_Id__c for custom rendering */
  @wire(getRecord, { recordId: '$recordId', fields: [YARDIURL_FIELD] })
  yardi(result){
    if(result.data){
        let yardiUnitId= result.data.fields.Property_Unit__r.value.fields.Yardi_Unit_Id__c.value;
        this.iframeUrl = 'https://www.yardipca.com/90114goldenpc/Pages/SFHHome.aspx?Id='+yardiUnitId;
        console.log('iframe value'+ this.iframeUrl); 
    }
    else if(result.error)
    {
      //something went wrong
    }
  }


}