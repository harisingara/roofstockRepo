import { LightningElement,wire,track,api } from 'lwc';
import sellerFileUrl from '@salesforce/apex/SellerFilesController.sellerFiles';

export default class SellerFileUrls extends LightningElement {
    @api recordId;
    @track numberOFFiles;
    @track urlList=[];
    @track urls;
    connectedCallback(){
        sellerFileUrl({
            recordId:this.recordId
        }).then(data=>{
            if(data){
                console.log('-data-'+JSON.stringify(data));
                this.numberOFFiles = 'Attachments'+' '+'('+data.length+')';
                this.urls = data;
                console.log('-urls-'+JSON.stringify(this.urls));

            }

        });
    }

}