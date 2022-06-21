import { LightningElement ,api, wire} from 'lwc';
import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import updateBoatList from '@salesforce/apex/BoatDataService.updateBoatList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const SUCCESS_TITLE = 'Success';
const MESSAGE_SHIP_IT     = 'Ship it!';
const SUCCESS_VARIANT     = 'success';
const ERROR_TITLE   = 'Error';
const ERROR_VARIANT = 'error';

export default class BoatSearchResults extends LightningElement {
  selectedBoatId;
  @api boatTypeId = '';
  boats;
  isLoading = false;
  error= undefined;
  columns = [
    {label : 'Name' , fieldName : 'Name', editable: true},
    {label : 'Length' , fieldName : 'Length__c',editable: true},
    {label : 'Price' , fieldName : 'Price__c',editable: true},
    {label : 'Description' , fieldName : 'Description__c',editable: true}
  ]

  // wired message context
  messageContext;
  // wired getBoats method 
  @wire(getBoats,{boatTypeId : '$boatTypeId'})
  wiredBoats({error,data}) {
    if(data){
      this.boats = data;
      console.log(data);
      notifyLoading();
    }
    else if(error){
      console.log('error' + error.getMessage())
    }
    else{
      this.isLoading = true;
    }
  }
  
  // public function that updates the existing boatTypeId property
  // uses notifyLoading
  searchBoats(boatTypeId) { }
  
  // this public function must refresh the boats asynchronously
  // uses notifyLoading
  refresh() { }
  
  // this function must update selectedBoatId and call sendMessageService
  updateSelectedTile(evt) { 
    this.selectedBoatId = evt.detail;
    console.log(this.selectedBoatId);

  }
  
  // Publishes the selected boat Id on the BoatMC.
  sendMessageService(boatId) { 
    // explicitly pass boatId to the parameter recordId
  }
  
  // The handleSave method must save the changes in the Boat Editor
  // passing the updated fields from draftValues to the 
  // Apex method updateBoatList(Object data).
  // Show a toast message with the title
  // clear lightning-datatable draft values
  handleSave(event) {
    // notify loading
    const updatedFields = event.detail.draftValues.map(element=>{
     return {
        Id : element.Id,
        Name : element.Name,
        Length__c : element.Length__c,
        Price__c : element.Price__c,
        Description__c : element.Description__c 
     }
    });
    // Update the records via Apex
    updateBoatList({data: updatedFields})
    .then(() => {
      const evt = new ShowToastEvent({
        title: SUCCESS_TITLE,
        message: MESSAGE_SHIP_IT,
        variant: SUCCESS_VARIANT,
    });
    this.dispatchEvent(evt);
    })
    .catch(error => {console.log(error)})
    .finally(() => {});
  }
  // Check the current value of isLoading before dispatching the doneloading or loading custom event
  notifyLoading() { 
 
    if(this.isLoading){
      this.dispatchEvent(new CustomEvent('loading'))
    }
    else{
      this.dispatchEvent(new CustomEvent('doneloading'))
    }
    
  }
}