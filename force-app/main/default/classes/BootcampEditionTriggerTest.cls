@isTest 
public class BootcampEditionTriggerTest {
    
    @TestSetup
    static void createData(){
        DataFactoryTest.createBootcampStructures(new List<String>{'Developer','Administrator'});
        DataFactoryTest.createBootcamps(101, 'Developer');
        DataFactoryTest.createBootcamps(101, 'Developer');
        DataFactoryTest.createUsersAndUsersBootcampEdition(3,1);
    }
    
    @isTest
    public static void updateNotStartedToComplete(){
        Bootcamp__c bootcamp = [SELECT Id,Status__c FROM Bootcamp__c WHERE Status__c = 'Not started' LIMIT 1];
        bootcamp.Status__c = 'Completed';
               
        Test.startTest();
        Database.SaveResult saveResult = Database.update(bootcamp, false);
        Test.stopTest();
        Bootcamp__c bootcampUpdated = [SELECT Id,Status__c FROM Bootcamp__c WHERE ID = :bootcamp.Id];
        System.assertEquals(false, saveResult.isSuccess());
        System.assertEquals(1, saveResult.getErrors().size());
        System.assertEquals('Not started', bootcampUpdated.Status__c);
    }

    @isTest
    public static void updateNotStartedToInProgress(){
        Bootcamp__c bootcamp = [SELECT ID FROM Bootcamp__c WHERE ID IN (SELECT Bootcamp__c  FROM trailheadapp__Trailhead_User_Data__c WHERE Assistant__c != null) AND Status__c = 'Not started' LIMIT 1];
        Bootcamp__c bootcampNoAssistant = [SELECT ID FROM Bootcamp__c WHERE ID IN (SELECT Bootcamp__c  FROM trailheadapp__Trailhead_User_Data__c WHERE Assistant__c = null) AND Status__c = 'Not started' LIMIT 1];
        
        bootcamp.Status__c = 'In progress';
        bootcampNoAssistant.Status__c = 'In progress';
 
        Test.startTest();
        Database.SaveResult bootcampResult = Database.update(bootcamp, false);
        Database.SaveResult bootcampNoAssistantResult = Database.update(bootcampNoAssistant, false);
        Test.stopTest();
        Bootcamp__c bootcampUpdated = [SELECT Id,Status__c FROM Bootcamp__c WHERE ID = :bootcamp.Id];
        Bootcamp__c bootcampNoAssistantUpdated = [SELECT Id,Status__c FROM Bootcamp__c WHERE ID = :bootcampNoAssistant.Id];
        System.assertEquals(true, bootcampResult.isSuccess(), 'Bootcamp update should be success');
        System.assertEquals(0, bootcampResult.getErrors().size());
        System.assertEquals('In progress', bootcampUpdated.Status__c);
        
        //System.assertEquals(false, bootcampNoAssistantResult.isSuccess());
        System.assertEquals(1, bootcampNoAssistantResult.getErrors().size());
        System.assertEquals('Not started', bootcampNoAssistantUpdated.Status__c);
    }
    @isTest
    public static void updateNotStartedToCompleteBulk(){
        List<Bootcamp__c> bootcamps = [SELECT Id,Status__c FROM Bootcamp__c WHERE Status__c = 'Not Started'];
        for (Bootcamp__c bootcamp : bootcamps) {
            bootcamp.Status__c = 'Completed';
         }

        Test.startTest();
        List<Database.SaveResult> saveResultList= Database.update(bootcamps, false);
        Test.stopTest();
        bootcamps = [SELECT Id,Status__c FROM Bootcamp__c WHERE ID IN:bootcamps];
        for(Integer i = 0 ; i<bootcamps.size();i++){
            System.assertEquals(false, saveResultList[i].isSuccess());
            System.assertEquals(1, saveResultList[i].getErrors().size());
            System.assertEquals('Not started', bootcamps[i].Status__c);
        }
            
        }
    @isTest
    public static void updateNotStartedToInProgressBulk(){
        List<Bootcamp__c> bootcamps = [SELECT ID FROM Bootcamp__c WHERE ID IN (SELECT Bootcamp__c  FROM trailheadapp__Trailhead_User_Data__c WHERE Assistant__c != null) AND Status__c = 'Not started'];
        List<Bootcamp__c> bootcampsNoAssistant = [SELECT ID FROM Bootcamp__c WHERE ID IN (SELECT Bootcamp__c  FROM trailheadapp__Trailhead_User_Data__c WHERE Assistant__c = null) AND Status__c = 'Not started'];
        
        for(Bootcamp__c bootcamp : bootcamps){
            bootcamp.Status__c = 'In progress';
        }

        for(Bootcamp__c bootcamp : bootcampsNoAssistant){
            bootcamp.Status__c = 'In progress';
        }
       
        
 
        Test.startTest();
        List<Database.SaveResult> bootcampsResults = Database.update(bootcamps, false);
        List<Database.SaveResult> bootcampsNoAssistantResults = Database.update(bootcampsNoAssistant, false);
        Test.stopTest();
        List<Bootcamp__c> bootcampsUpdated = [SELECT Id,Status__c FROM Bootcamp__c WHERE ID IN :bootcamps];
        List<Bootcamp__c> bootcampsNoAssistantUpdated = [SELECT Id,Status__c FROM Bootcamp__c WHERE ID IN :bootcampsNoAssistant];
       
        for(Integer i = 0 ; i<bootcampsResults.size(); i++){
            System.assertEquals(true, bootcampsResults[i].isSuccess(), 'Bootcamp update should be success');
            System.assertEquals(0, bootcampsResults[i].getErrors().size());
            System.assertEquals('In progress', bootcampsUpdated[i].Status__c);
        }
        for(Integer i = 0 ; i<bootcampsNoAssistantResults.size(); i++){
            System.assertEquals(false, bootcampsNoAssistantResults[i].isSuccess());
            System.assertEquals(1, bootcampsNoAssistantResults[i].getErrors().size());
            System.assertEquals('Not started', bootcampsNoAssistantUpdated[i].Status__c);
        }
        
       

           
    }
    
}