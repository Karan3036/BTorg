public without sharing class PDFController {
    @AuraEnabled(cacheable=true)
    public static String convertBlobToHTML() {
                // Retrieve the PDF file from a static resource
                StaticResource pdfResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'Releasenote'];
        
                // Convert the PDF Blob to HTML body
                String pdfContent ='';
                String htmlBody = '';
                Blob pdfBlob;
                String pdfUrl = '';
                if (pdfResource != null && pdfResource.Body != null) {
                
                        pdfBlob = pdfResource.Body;
                        System.debug('pdfblob' + pdfBlob);
                        pdfContent = EncodingUtil.base64Encode(pdfBlob);
                         pdfUrl = 'data:application/pdf;base64,' + pdfContent;

                        htmlBody = '<html><body><embed src="data:application/pdf;base64,' + pdfContent + '" type="application/pdf" width="100%" height="100%"></embed></body></html>';
                }
                return htmlBody;
            }

    @AuraEnabled
    public static String sendemail(String name, String email, String subject, String body){
        try{
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            String myCustomLabel = System.Label.supportEmail;
            List<String> toEmailAddress = new List<String>();
            if(myCustomLabel.contains(',')){
                toEmailAddress.addAll(myCustomLabel.split(','));
            }else{ 
                toEmailAddress.add(myCustomLabel); 
            }             

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(subject);
            mail.setplaintextbody(body + '\n\n\nFrom ' + name + '\nEmail ' + email);
            mail.setToAddresses(toEmailAddress) ;
            emailList.add(mail);
            // Messaging.sendEmail(emailList);

            // return 'success';
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailList);
        if (emailResults[0].isSuccess()) {
            return 'success';
        } else {
            return 'fail';
        }
        } catch (Exception e){
            return 'fail';
        }
    }

    @AuraEnabled
    public static void createCase(String subject, String body) {
        Case newCase = new Case();
        newCase.Subject = subject;
        newCase.Description = body;
        newCase.Origin = 'Web';
        // newCase.CurrencyIsoCode = 'USD - U.S. Dollar';
        newCase.Status = 'New';

        try {
            insert newCase;
            System.debug('Case created successfully with ID: ' + newCase.Id);
        } catch (Exception ex) {
            System.debug('Error creating case: ' + ex.getMessage());
        }
    }

}