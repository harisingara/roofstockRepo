import { LightningElement,api,track,wire } from 'lwc';
import poolTypeValues from '@salesforce/apex/PropertyAndPropertyUnitController.poolTypeValues';
import mailBoxTypeValues from '@salesforce/apex/PropertyAndPropertyUnitController.mailBoxTypeValues';
import garbageDisposalBinTypeValues from '@salesforce/apex/PropertyAndPropertyUnitController.garbageDisposalBinTypeValues';
import trashrResponsibilityValues from '@salesforce/apex/PropertyAndPropertyUnitController.trashrResponsibilityValues';
import hasPoolValues from '@salesforce/apex/PropertyAndPropertyUnitController.hasPoolValues';
import trashBinAvailableValues from '@salesforce/apex/PropertyAndPropertyUnitController.trashBinAvailableValues';
import recycleBinavailableValues from '@salesforce/apex/PropertyAndPropertyUnitController.recycleBinavailableValues';
import propertyPropertyUnitDetails from '@salesforce/apex/PropertyAndPropertyUnitController.propertyPropertyUnitDetails';
import savePropertyPropertyUnitDetails from '@salesforce/apex/PropertyAndPropertyUnitController.savePropertyPropertyUnitDetails';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class PropertyDetails extends LightningElement {
    @track propertyDetails={};
    @api propertyId;
    @api propertyUnitId;
    isLoaded = false;
    fields={};
    poolTypeOptions;
    mailBoxTypeOptions;
    disposalBinTypeOptions;
    trashResponsibilityOptions;
    recycleBinavailableOption;
    isTrashBinAvailable;
    hasPoolOption;

    connectedCallback(){
        console.log('-propertyId-'+this.propertyId);
        console.log('-propertyUnitId-'+this.propertyUnitId);
        propertyPropertyUnitDetails({"propertyId":this.propertyId,
        "propertyUnitId":this.propertyUnitId    
        }).then(result => {
            if(result){
                console.log('-result-'+JSON.stringify(result));
                console.log('-result-'+result.hasPool);
                //this.propertyDetails = result;
            }
            poolTypeValues().then(result =>{
                let poolOptions = [];               
                for (var key in result) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    poolOptions.push({ label: result[key], value: result[key] });
 
                    // Here Name and Id are fields from sObject list.
                }
                this.poolTypeOptions = poolOptions;

                mailBoxTypeValues().then(result=>{
                    let mailBoxOptions = [];
                    for (var key in result) {
                        console.log('--'+result[key]);
                    // Here key will have index of list of records starting from 0,1,2,....
                        mailBoxOptions.push({ label: result[key], value: result[key] });
                    // Here Name and Id are fields from sObject list.
                    }
                    this.mailBoxTypeOptions = mailBoxOptions;

                    garbageDisposalBinTypeValues().then(result=>{
                        let disposalOptions = [];
                        for (var key in result) {
                            console.log('--'+result[key]);
                            disposalOptions.push({ label: result[key], value: result[key] });
                        }
                        this.disposalBinTypeOptions = disposalOptions;

                        trashrResponsibilityValues().then(result=>{
                            let trashOptions=[];
                            for (var key in result) {
                                console.log('--'+result[key]);
                                trashOptions.push({ label: result[key], value: result[key] });
                                }
                            this.trashResponsibilityOptions = trashOptions;

                                recycleBinavailableValues().then(result => {
                                    let recycleBinOption = [];
                                    for(var key in result) {
                                        recycleBinOption.push({label: result[key], value: result[key] });
                                    }
                                    this.recycleBinavailableOption =  recycleBinOption;

                                    trashBinAvailableValues().then(result => {
                                        let trashBinOptions = [];
                                        for(var key in result) {
                                            trashBinOptions.push({label : result[key], value : result[key]});
                                        }
                                        this.isTrashBinAvailable = trashBinOptions;

                                        hasPoolValues().then(result => {
                                            let hasPoolVal = [];
                                            for(var key in result) {
                                                hasPoolVal.push({label: result[key], value: result[key]});
                                            }
                                            this.hasPoolOption = hasPoolVal;
                                        })
                                })
                            })

                        })
                    })

                })

            })
            this.isLoaded = true;
            this.propertyDetails = result;
        })

    }

    save(event) {
        this.isLoaded = false;
        let propertyDetails;
        console.log(event.target.label);
        var inp=this.template.querySelectorAll("lightning-input");
        var cmb=this.template.querySelectorAll("lightning-combobox");

        inp.forEach(function(element){
            if(element.name=="gateCode"){
                this.fields.gateCode=element.value;
            }
            else if(element.name=="lockboxLocation"){
                this.fields.lockboxLocation=element.value;
            }
            else if(element.name=="lockboxCode"){
                this.fields.lockboxCode=element.value;
            }
            else if(element.name=="serialNumber"){
                this.fields.selfShowingLockboxSerialNumber=element.value;
            }

        },this);

        cmb.forEach(function(element){
            if(element.name=="pool"){
                this.fields.hasPool=element.value;
            }
            else if(element.name=="PoolType"){
                console.log(element.value);
                this.fields.poolType=element.value;
            }
            else if(element.name=="mailBoxType"){
                this.fields.mailBoxType=element.value;
            }
            else if(element.name=="disposalBinType"){
                this.fields.garbageDisposalBinType=element.value;
            }
            else if(element.name=="trashResponsibility"){
                this.fields.trashrResponsibility=element.value;
            }
            else if(element.name=="recycleBin"){
                this.fields.isRecycleBinAvailable=element.value;
            }
            else if(element.name=="trashBin"){
                this.fields.isTrashBinAvailable=element.value;    
            }

        },this);

        propertyDetails = JSON.stringify(this.fields);
        console.log('-fields-'+JSON.stringify(this.fields));

        savePropertyPropertyUnitDetails({
            "propertyId":this.propertyId,
            "propertyUnitId":this.propertyUnitId,
            "propertyDetails":propertyDetails
        }).then(result=>{
            
            if(result){
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Data Updated Successfully!!!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isLoaded = true;
                this.dispatchEvent(new CustomEvent('close'));
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
    Close(event){
        this.dispatchEvent(new CustomEvent('close'));
   
    }
    handleMailBoxTypeChange(event){
        this.value = event.target.value;
    }
    handleHasPool(event){
        this.value = event.target.value;
    }
    handlePoolTypeChange(event){
        this.value = event.target.value;
    }
    handleDisposalBinTypeChange(event){
        this.value = event.target.value;
    }
    handleTrashResponsibilityChange(event){
        this.value = event.target.value;
    }
    handleIsTrashBinAvailable(event){
        this.value = event.target.value;
    }
    handleIsRecycleBinavailable(event){
        this.value = event.target.value;
    }
    

}