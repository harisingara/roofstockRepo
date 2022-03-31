import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TRANSACTION_OBJECT from '@salesforce/schema/Transaction__c';
import BUYERCONTACT_FIELD from '@salesforce/schema/Transaction__c.Buyer_Contact1__c';
import SELLERCONTACT_FIELD from '@salesforce/schema/Transaction__c.Seller_Contact__c';
import TRANSACTIONRECORDID_FIELD from '@salesforce/schema/Transaction__c.Id';
import BUYERACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Buyer_Contact1__r.AccountId';
import SELLERACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Seller_Contact__r.AccountId';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
export default class CreateRecordInLWC extends NavigationMixin(LightningElement) {
/** Id of record to display. */
@api recordId;
@api recordTypeId;
@track conId;
@track accountId;
@track transactionRecordId;
@api recTypeName;
@track objectInfo;
@track recTId;
@wire(getObjectInfo, { objectApiName: CASE_OBJECT})
objectInfo;


/* Load Transaction__c.Transaction_Id__c for custom rendering */
@wire(getRecord, { recordId: '$recordId', fields: [BUYERCONTACT_FIELD,SELLERCONTACT_FIELD,TRANSACTIONRECORDID_FIELD,BUYERACCOUNTID_FIELD,SELLERACCOUNTID_FIELD] })
transaction(result){
if(result.data){
  console.log('=string='+JSON.stringify(result.data));
  if(this.recTypeName === 'Transaction-Buyer'){
    console.log('buyer');
    this.conId = result.data.fields.Buyer_Contact1__c.value;
    this.accountId = result.data.fields.Buyer_Contact1__r.value.fields.AccountId.value;
  }
  else if(this.recTypeName === 'Transaction-Seller'){
    console.log('seller');
    this.conId = result.data.fields.Seller_Contact__c.value;
    this.accountId = result.data.fields.Seller_Contact__r.value.fields.AccountId.value;
  }
  this.recTId = this.getRecordTypeId(this.recTypeName);
  console.log('=fianl rectypeId='+this.recTId);
  const defaultValues = encodeDefaultFieldValues({
    RecordTypeId:this.recTId,
    ContactId:this.conId,
    AccountId:this.accountId,
    Transaction__c:this.recordId
   
});
  this[NavigationMixin.Navigate]({

    type: 'standard__objectPage',
    attributes: {
        objectApiName: 'Case',
        actionName: 'new'                
    },
    state : {
        nooverride: '1',
        recordTypeId: this.recTId,
        defaultFieldValues:defaultValues
    }
});



}
else if(result.error)
{
//something went wrong
}


}
getRecordTypeId(recordTypeName) {

 // alert('rectypeName'+recordTypeName);
  let recordtypeinfo = this.objectInfo.data.recordTypeInfos;


  let recordTypeId;


  for(var eachRecordtype in  recordtypeinfo)


  {

     // alert('-rt2-'+recordtypeinfo[eachRecordtype].name);
      if(recordtypeinfo[eachRecordtype].name===recordTypeName){


          recordTypeId = recordtypeinfo[eachRecordtype].recordTypeId;


          break;


      }


  }


  console.log('returning -   ' + recordTypeId);


  return recordTypeId;


}    


}