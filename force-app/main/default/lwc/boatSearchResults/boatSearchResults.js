import { LightningElement ,api, wire} from 'lwc';
import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import updateBoatList from '@salesforce/apex/BoatDataService.updateBoatList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { publish,MessageContext } from 'lightning/messageService';
import BOATMC from '@salesforce/messageChannel/Boat__c';

const SUCCESS_TITLE = 'Success';
const MESSAGE_SHIP_IT     = 'Ship it!';
const SUCCESS_VARIANT     = 'success';
const ERROR_TITLE   = 'Error';
const ERROR_VARIANT = 'error';

export default class BoatSearchResults extends LightningElement {
  selectedBoatId;
  @api boatTypeId = '';
  boats;
  isLoading = true;
  error= undefined;
  draftValues = [];
  columns = [
    {label : 'Name' , fieldName : 'Name', editable: true},
    {label : 'Length' , fieldName : 'Length__c',editable: true},
    {label : 'Price' , fieldName : 'Price__c',editable: true},
    {label : 'Description' , fieldName : 'Description__c',editable: true}
  ]

  // wired message context
  @wire(MessageContext)
  messageContext;
  // wired getBoats method 
  @wire(getBoats,{boatTypeId : '$boatTypeId'})
  wiredBoats({error,data}) {
    if(data){
      this.boats = data;
      this.isLoading = false;
      this.notifyLoading();
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
  async refresh() {
    this.isLoading = true;
    this.notifyLoading();
    await refreshApex(this.wiredBoats);
   /* setTimeout(() => {
      eval("$A.get('e.force:refreshView').fire();");
    }, 500);*/
    this.draftValues = [];
    this.isLoading = false;
    this.notifyLoading();
   }
  
  // this function must update selectedBoatId and call sendMessageService
  updateSelectedTile(evt) { 
    this.selectedBoatId = evt.detail;
    this.sendMessageService(this.selectedBoatId);

  }
  
  // Publishes the selected boat Id on the BoatMC.
  sendMessageService(boatId) { 
      const payload = {recordId: boatId};
      publish(this.messageContext, BOATMC, payload);
    // explicitly pass boatId to the parameter recordId
  }
  
  // The handleSave method must save the changes in the Boat Editor
  // passing the updated fields from draftValues to the 
  // Apex method updateBoatList(Object data).
  // Show a toast message with the title
  // clear lightning-datatable draft values
  handleSave(event) {
    // notify loading
    this.draftValues = event.detail.draftValues.map(element=>{
      return {
        Id : element.Id,
        Name : element.Name,
        Length__c : element.Length__c,
        Price__c : element.Price__c,
        Description__c : element.Description__c 
     }
    });
    // Update the records via Apex
    updateBoatList({data: this.draftValues})
    .then((data) => {
      console.log(data);
      const evt = new ShowToastEvent({
        title: SUCCESS_TITLE,
        message: MESSAGE_SHIP_IT,
        variant: SUCCESS_VARIANT,
    });
    this.dispatchEvent(evt);
    this.refresh();
    this.draftValues = [];
    
    })
    .catch(error => {
      console.log(error);
      const evt = new ShowToastEvent({
        title: ERROR_TITLE,
        message: error,
        variant: ERROR_VARIANT,
    });
    this.dispatchEvent(evt);
    })
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