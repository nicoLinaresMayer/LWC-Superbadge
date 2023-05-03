public static String getFileContentBitBucket(String endpoint){


        
        /** 
         * Endpoints examples *
        String endpoint2= 'https://api.github.com/repos/nicoLinaresMayer/LWC-Superbadge/contents/force-app/main/default/lwc/testClass.cls';
        String endpoint = 'https://api.bitbucket.org/2.0/repositories/cafexcitd/credit-suisse/src/master/';

        GitHub = 
        Bitbucket = https://bitbucket.org/{usuario}/{repo}/src/{branch}/{path}
         * 
         * 
        */
        String fileContent = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('accept', 'application/json');
        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            String content = res.getBody();
            Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(content);
            //fileContent= EncodingUtil.base64Decode((String) result.get('content')).toString();
        } else {
            fileContent =  'Error: ' +res.getStatusCode();
        }

        return fileContent;
    }
