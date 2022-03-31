global class RoofstockSandboxPostCopy implements SandboxPostCopy {
  global void runApexClass(SandboxContext context) {
    System.debug('Organization ID: ' + context.organizationId());
    System.debug('Sandbox ID: ' + context.sandboxId());
    System.debug('Sandbox Name: ' + context.sandboxName());

    Database.executeBatch(new AnonymizeContactEmailsBatchable());
    Database.executeBatch(new AnonymizeLeadEmailsBatchable());
    Database.executeBatch(new AnonymizeAccountEmailsBatchable());
    Database.executeBatch(new AnonymizeOpportunityEmailsBatchable());
    
    Database.executeBatch(new AnonymizeTransactionEmailsBatchable());
    Database.executeBatch(new AnonymizeCertificationEmailsBatchable());
      
    Database.executeBatch(new AnonymizeLeadIdBatchable());
    Database.executeBatch(new AnonymizeContactIdBatchable());
    Database.executeBatch(new AnonymizeAccountIdBatchable());
    Database.executeBatch(new AnonymizePropertyIdBatchable());
    Database.executeBatch(new AnonymizePropertyUnitIdBatchable());
      
      
  }
}