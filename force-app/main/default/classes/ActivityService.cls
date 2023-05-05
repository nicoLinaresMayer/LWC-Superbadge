public with sharing class ActivityService {
    
    class CustomException extends Exception{}

    public class ClassWrapper {
        String name;
        Double commentPercentage;
        Boolean hasQueryInside;
        Integer totalLines;

        public ClassWrapper(String name, Double commentPercentage, Boolean hasQueryInside, Integer totalLines){
            this.name = name;
            this.commentPercentage = commentPercentage;
            this.hasQueryInside = hasQueryInside;
            this.totalLines = totalLines;
        }
    }


    public static Map<String,String> getFilesWithContentGithub(String endpoint){
        Map<String,String> classBodyByNames = new Map<String,String>();
		List<String> endpointsList = new List<String>();
		List<HttpRequest> requests = new List<HttpRequest>();
        //If endpoint is about a folder we should call 
        if( ! endpoint.contains('.cls') ){
            HttpRequest req = new HttpRequest();
            system.debug('endpoint->'+endpoint);
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('accept', 'application/vnd.github+json');
            HttpResponse res = new Http().send(req);
            if(res.getStatusCode() == 200){
                List<Object> fileDataList = (List<Object>) JSON.deserializeUntyped(res.getBody());
                for(Object fileData : fileDataList){
                	Map<String,Object> fileDataMap = (Map<String,Object>)fileData;
                    endpointsList.add(endpoint+'/'+fileDataMap.get('name'));   
                }
            }
            else{
                throw new CustomException('Error (code '+res.getStatusCode() +') in HTTP request');
            }
        }
        
        else{
            endpointsList.add(endpoint);
        }

        //Make the necessary requests
        for(String endpt : endpointsList){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpt);
            req.setMethod('GET');
            req.setHeader('accept', 'application/vnd.github+json');
            requests.add(req);
        }

        //Send the requests and get body and name of all classes
        for(HttpRequest request : requests){
            HttpResponse res = new Http().send(request);
            if(res.getStatusCode() == 200){
                Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                String className = String.valueOf(responseMap.get('name'));
                String classBody = EncodingUtil.base64Decode(String.valueOf(responseMap.get('content'))).toString();
                classBodyByNames.put(className,classBody);
            }
           
            else{
                throw new CustomException('Error (code '+res.getStatusCode() +') in HTTP request');
            }
        }

        return classBodyByNames;
    }


    public static Map<String,String> getFilesWithContentBitBucket(String endpoint){

        Map<String,String> classBodyByNames = new Map<String,String>();
        List<String> endpointsList = new List<String>();
        Map<HttpRequest,String> classNameByRequest = new Map<HttpRequest,String>();

        //If endpoint is about a folder we should call 
        if( ! endpoint.contains('.cls') ){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('accept', 'application/json');
            HttpResponse res = new Http().send(req);
            if(res.getStatusCode() == 200){
            Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

            List<Object> responseValues = (List<Object>) responseMap.get('values');
                for(Object value : responseValues){
                    Map<String,Object> valueMap = (Map<String,Object>)value;
                    endpointsList.add(endpoint+'/'+String.valueOf(valueMap.get('path')).subStringAfterLast('/'));
                }
            
                
            }
            else{
                throw new CustomException('Error (code '+res.getStatusCode() +') in HTTP request');
            
            }
        }
        
        else{
            endpointsList.add(endpoint);
        }

        system.debug(endpointsList.size());
        //Make the necessary requests
        for(String endpt : endpointsList){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpt);
            req.setMethod('GET');
            req.setHeader('accept', 'application/vnd.github+json');
            classNameByRequest.put(req,endpt.substringAfterLast('/'));
        }

        //Send the requests and get body and name of all classes
        for(HttpRequest request : classNameByRequest.keySet()){
            HttpResponse res = new Http().send(request);
            if(res.getStatusCode() == 200){
                String classBody = String.valueOf(res.getBody());
                classBodyByNames.put(classNameByRequest.get(request),classBody);
            }
        
            else{
                throw new CustomException('Error (code '+res.getStatusCode() +') in HTTP request');  
            }
        }
            return classBodyByNames;
    }

    
    public static List<String> getCodeLines(String code){
        return code.split('\n');
    }


    public static Integer getCommentLines(String code){
        Integer totalLines = code.split('\n').size();
        Integer commentLines = 0;
        for (String line : code.split('\n')) {
            if (line.trim().startsWith('//') || line.trim().startsWith('/*')) {
                commentLines++;
            }
        }
        return commentLines;
    }


    public static Double getCommentPercentage(String code) {
        
        Integer totalLines = code.split('\n').size();
        Integer commentLines = getCommentLines(code);
        Double commentsPercent = Double.valueOf(commentLines) / Double.valueOf(totalLines) * 100;
        Integer commentsPercentRounded = Math.round(commentsPercent);
        system.debug('El porcentaje de comentarios en este codigo es de: '+ commentsPercentRounded + '% con ' + commentLines + ' lineas comentadas');
        return commentsPercentRounded;
    }
	

    public static Boolean hasQueryInsideLoop(String code) {
        Integer queriesInLoopsCount = 0;
        Boolean insideLoop = false;
        for (String line : code.split('\n')) {
            if (line.contains('for') && line.contains('(') && line.contains(')')) {
                insideLoop = true;
            } else if (insideLoop && (line.contains('[select') || line.contains('[SELECT') || line.contains('[ SELECT') || line.contains('[ select'))) {
                queriesInLoopsCount++;
            } else if (line.contains('}')) {
                insideLoop = false;
            }
        }
        System.debug('Se han encontrado ' + queriesInLoopsCount + ' queries dentro de loops');
        return queriesInLoopsCount > 0;
    }

    public static List<ClassWrapper> 1(Id activityId){
       
        String endpoint =  ActivityService.getRepoEndpoint(activityId);
        Map<String,String> classBodyByNames = new Map<String,String>();
        if(endpoint.contains('github')){
            classBodyByNames = ActivityService.getFilesWithContentGithub(endpoint);
        }
        else if(endpoint.contains('bitbucket')){
            classBodyByNames = ActivityService.getFilesWithContentBitbucket(endpoint);
        }
        else{
            throw new CustomException('Error : Only GitHub or Bitbucket repositories are allowed');  
        }
       
        List<ClassWrapper> analyzedClasses = ActivityService.getClassesAnalysis(classBodyByNames);
        for(ClassWrapper singleClass :analyzedClasses ){
            // HERE Sum all comments, lines, etc to update fields
        }

        //HERE update Activity fields

        return analyzedClasses;
    }

    public static String getRepoEndpoint(Id activityId){
       
        final String GITHUB = 'GitHub';
        final String BITBUCKET = 'Bitbucket';
        final String GITHUB_BASEURL = 'https://github.com/';
        final String BITBUCKET_BASEURL ='https://bitbucket.org/'; 
        final String GITHUB_API_BASEURL = 'https://api.github.com/repos/';
        final String BITBUCKET_API_BASEURL ='https://api.bitbucket.org/2.0/repositories/';
        
        String path = 'force-app/main/default/classes';
        String endpoint;
        Activity__c activity = [SELECT Repository_Link__c , Repository__c FROM Activity__c WHERE Id=:activityId];
        String repositoryLink = activity.Repository_Link__c;//query activity
        
       
        if(activity.Repository__c == GITHUB){
                String repositoryName = repositoryLink.substringAfterLast('/');
                String username = repositoryLink.substringAfter(GITHUB_BASEURL).substringBefore('/');
                endpoint = GITHUB_API_BASEURL+username+'/'+ repositoryName + '/contents/'+path;
            }
            else if(activity.Repository__c == BITBUCKET){
                String username = repositoryLink.substringAfter(BITBUCKET_BASEURL).substringBefore('/');
                String repositoryName = repositoryLink.substringAfterLast('/'+username+'/').substringBeforeLast('/').substringBeforeLast('/').substringBeforeLast('/');
                system.debug(repositoryName);
                endpoint = BITBUCKET_API_BASEURL+username+'/'+repositoryName+'/src/main/'+path;
            }
            else{
                endpoint= '';
            }
        
        return endpoint;
    }
    
    public static List<ClassWrapper> getClassesAnalysis(Map<String,String> classBodyByName){
        Double sumClassesPercentage = 0;
        List<ClassWrapper> classWrapperList = new List<ClassWrapper>();
        for(String className : classBodyByName.keySet()){
            
            String classBody = classBodyByName.get(className);   
           
            //Analysis starts
            Double commentPercentage = ActivityService.getCommentPercentage(classBody);
            Boolean hasQueryInside = ActivityService.hasQueryInsideLoop(classBody);
            Integer totalLines = ActivityService.getCodeLines(classBody).size();

            //Add info to wrapper class and add it to list
            classWrapperList.add(new ClassWrapper (className,commentPercentage,hasQueryInside,totalLines));
            sumClassesPercentage+=commentPercentage;
        
        }
        /**
             * totalLines  ActivityService.getFilesWithContent();
             * totalComments getCommentLines(String code)
             * totalClasses
             * totalQueries
             * --totalMethods--
             */
       
        //HERE update Activity fields such as TotalComments , TotalLines, etc

        return classWrapperList;
    }
    


    public static void testingAll(){
        List<ClassWrapper> classWrapperList = ActivityService.startRepositoryAnalysis('a0C8B000001nRG0UAM');
        for(ClassWrapper classItem :classWrapperList){
            System.debug('Class name : ' + classItem.Name);
            System.debug('       commentPercentage : ' + classItem.commentPercentage);
            System.debug('       totalLines : ' + classItem.totalLines);
            System.debug('       hasQueryInside : ' + classItem.hasQueryInside);
        }
    }

    

   
}

