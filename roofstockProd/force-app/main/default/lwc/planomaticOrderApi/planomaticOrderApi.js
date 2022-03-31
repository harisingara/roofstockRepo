import { LightningElement,api,track,wire } from 'lwc';
import qualifyPlanomatic from '@salesforce/apex/PlanomaticCreateOrderController.qualifyPlanomatic';
import planomaticOrder from '@salesforce/apex/PlanomaticCreateOrderController.planomaticOrder';
import accessDetails from '@salesforce/apex/PlanomaticCreateOrderController.checkAccessCodeDetails';
import planomaticButton from '@salesforce/label/c.Enable_Planomatic_Button';
import laDetails from '@salesforce/apex/PlanomaticCreateOrderController.displayLeasingAvailabilityDetails';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class PlanomaticOrderApi extends LightningElement {
    @api recordId;
    @track qualifyCalloutFailed;
    @track calloutSuccess;
    @track calloutFailed;
    @track isLoaded=true;
    @track noAccessDetails;
    @track buttonDisabled;
    @track operatingStatus;
    @track occupancyStatus;
    @track existingPhotos;
    @track readyDate;
    @track disable = false; 
    

    connectedCallback() {
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            console.log('-planomaticButton-'+planomaticButton);
            if(planomaticButton !='true'){
                this.isLoaded = true;
                this.buttonDisabled = true;
                return;
            }
            laDetails({
                recordId:this.recordId
            }).then((data) => {
                if(data){
                    this.operatingStatus = data.Operating_Status__c;
                    this.occupancyStatus = data.Occupancy_Status__c;
                    this.readyDate = data.Ready_Date__c;
                    this.existingPhotos = data.Existing_Photos__c;
                }

            });



        }, 0);
    }

    validatePlanomaticOrder(){
            this.isLoaded=false;            
            let qualified;
            let accessDetailsProvided;
            console.log(this.recordId);
            let poNotes = this.template.querySelector(".po-Notes").value;
            console.log('value of notes::'+poNotes);
            qualifyPlanomatic
                ({
                    recordId:this.recordId
                }).then( (data) => {
    
                qualified = data;
                console.log('-type-'+typeof(qualified));
                if(qualified){
                    accessDetails({
                        recordId:this.recordId
                    }).then(data=>{
                        accessDetailsProvided = data;
                        if(accessDetailsProvided){

                            planomaticOrder({
                                recordId:this.recordId,
                                notes : poNotes
                            }).then(data=>{
                                if(data){
                                    this.isLoaded = true;
                                    this.calloutSuccess = true;
                                    this.disable = true;
                                }
                                else{
                                    this.isLoaded = true;
                                    this.calloutFailed = true;    
                                }
                                console.log('-2-'+this.calloutSuccess);
                            })


                        }
                        else{
                            this.isLoaded = true;
                            this.noAccessDetails = true;
                        }

                    })
                    
    
                }
                else{
                    this.isLoaded = true;
                    this.qualifyCalloutFailed = true;
                }
                
            }).catch( error => {
                
            });

    }
    handleCancel(event) {
        // Add your cancel button implementation here
        this.dispatchEvent(new CloseActionScreenEvent());
     }
    

}