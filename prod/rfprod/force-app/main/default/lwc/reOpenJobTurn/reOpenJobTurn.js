import { LightningElement,track,api,wire } from 'lwc';
import findTurnsImperative from '@salesforce/apex/ReOpenJobTurn.findTurns';


export default class ReOpenJobTurn extends LightningElement {
  @api recordId;
  @track message;
  @track success;

  connectedCallback(){
    findTurnsImperative({
      currentRecId: this.recordId 
    }).then(data => {
    console.log('success'+data);
    if(data){
      console.log('==data=='+JSON.stringify(data));
      console.log('Response'+data);  
      this.success = true;
      this.message = 'Successfully Synced From Yardi!'; 
      const successMessage = new CustomEvent('success');
      this.dispatchEvent(successMessage); 
      
    }
    else if(data === false){
      console.log('dont open');  
      this.success = false;
      this.message = 'Error:Only The Most Recent Turn Can Be Synced From Yardi!';   
    }
    }).
    catch(error => {
     // console.log('Response'+data);
      this.success = false;
      this.message = 'Error:Unable To Find Turn Information In Yardi.';
    })
}

}