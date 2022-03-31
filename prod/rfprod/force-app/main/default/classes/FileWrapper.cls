public class FileWrapper {
    @AuraEnabled public String statusCode;  //OK
    @AuraEnabled public boolean isSuccess;
    @AuraEnabled public Entitycls[] entity;
    @AuraEnabled public boolean hasEntity;
    @AuraEnabled public String lineNumber;
    @AuraEnabled public String message; //
    @AuraEnabled public String errorCode;
    @AuraEnabled public String exceptions;
    @AuraEnabled public String url;

   public class Entitycls {
        @AuraEnabled public String type;    //TransactionPurchaseSaleAgreement
        @AuraEnabled public String fileName;    //2651_Glen_Mawr_PSA.pdf
        @AuraEnabled public String uri; //https://dev.roofstock.com/resources/bpm/460505d3-6b8d-4c81-b897-b1a481674df6?useSas=true
        @AuraEnabled public Integer sizeInByte; //1017197
        @AuraEnabled public String uploadedOnUtc;   //2017-06-20T00:13:20Z
        @AuraEnabled public String uploadedBy;  //system
    }
}