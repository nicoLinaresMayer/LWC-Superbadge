import { LightningElement } from 'lwc';

 // imports
 export default class BoatSearch extends LightningElement {
    isLoading = false;
    boatType = '' ;
    
    // Handles loading event
    handleLoading() {
      this.isLoading =true;
    }
    
    // Handles done loading event
    handleDoneLoading() {
      this.isLoading = false;
    }
    
    // Handles search boat event
    // This custom event comes from the form
    searchBoats(event) {
      this.boatType = event.detail;
    }
    
    createNewBoat() { }
  }