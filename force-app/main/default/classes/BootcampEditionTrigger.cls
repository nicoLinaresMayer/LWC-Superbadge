public with sharing class BootcampEditionTrigger {

    public static void onBeforeUpdate(List<Bootcamp__c> bootcamps, Map<Id,Bootcamp__c> bootcampsOldMap) {

      //Look for bootcamp's field status change
        Map<Id,Bootcamp__c> bootcampById = New Map<Id,Bootcamp__c> ();
        for(Bootcamp__c bootcamp : bootcamps){
            if(bootcamp.Status__c != bootcampsOldMap.get(bootcamp.Id).Status__c){
                if(bootcampsOldMap.get(bootcamp.Id).Status__c == 'Not started' && bootcamp.Status__c == 'Completed'  ){
                bootcamp.addError(Label.ErrorChangeStatusToComplete);
                }
                else{
                    if(bootcamp.Status__c == 'In progress' || bootcamp.Status__c == 'Completed'){
                        bootcampById.put(bootcampsOldMap.get(bootcamp.Id).Id, bootcamp);             
                   } 
                }
            }
        }

        //Query for bootcamps that have users without assistants
        List<Bootcamp__c> bootcampsWithNullAssistant = [SELECT ID,(SELECT ID,Assistant__c,Bootcamp__c  FROM Trailhead_Users_Data__r) FROM Bootcamp__c WHERE ID IN (SELECT Bootcamp__c  FROM trailheadapp__Trailhead_User_Data__c WHERE Assistant__c = null AND Bootcamp__c IN :bootcampById.keySet())];
        for(Bootcamp__c bootcamp : bootcampsWithNullAssistant){
            if(!bootcampById.get(bootcamp.Id).hasErrors()){
                bootcampById.get(bootcamp.Id).addError(Label.ErrorChangeStatusWithoutAssistant);
            }
                  
        }   
    }     
}