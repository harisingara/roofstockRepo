import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'ortoo_e2a__EmailMessage__c.ortoo_e2a__Html_Body__c',
];

export default class E2aDisplayOrtooEmailCMP extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    email;

    get emailBody() {
        return this.email.data.fields.ortoo_e2a__Html_Body__c.value;
    }

}