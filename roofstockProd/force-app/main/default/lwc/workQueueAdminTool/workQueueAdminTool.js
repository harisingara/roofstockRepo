import { LightningElement,api } from 'lwc';
import adminToolURL from '@salesforce/apex/RoofstockOneAdminTool.adminToolUrl';

export default class WorkQueueAdminTool extends LightningElement {
    @api recordId;
    @api iframeUrl;
    @api width;
    @api height;
    @api scrolling;
    @api frameBorder;
    @api styles;

    connectedCallback(){
        console.log('-recordId-'+this.recordId);
        adminToolURL({recordId:this.recordId}).then(result=>{
            console.log('-result-'+result);
            this.iframeUrl = result;

        })

        }
    }