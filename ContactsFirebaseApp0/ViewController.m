//
//  ViewController.m
//  ContactsFirebaseApp0
//
//  Created by alex on 11/7/21.
//

#import "ViewController.h"
#import "Contact.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *positionTextField;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // self.ref = [[FIRDatabase database] reference];

    // Get an instance of the Firestore database
    self.firestore = [FIRFirestore firestore];
    
    /** Tests some queries
        As in firestore we can have multiple collections, if we want to work with a collection, we need to
        specify which collection we want to manipulate
     */
    FIRCollectionReference *contactsCollectionRef = [[self firestore] collectionWithPath:@"Contacts"];
    //create a query to play with data already registered in the database
    FIRQuery *query = [contactsCollectionRef queryWhereField:@"position" isEqualTo:@"HR"];
    //execute the query
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"Error retrieving documents: %@", error);
        }else{
            //FIRDocumentSnapshot *document = snapshot.documents.firstObject;
            for (FIRDocumentSnapshot *document in [snapshot documents]) {
                NSLog(@"DocumentId: %@", [document documentID]);
                NSDictionary *myContacts = [document data];
                NSLog(@"contact: %@", myContacts);
            }
        }
        
    }];
    
    /** Let's create a contact with hardcoded data
        https://firebase.google.com/docs/firestore/manage-data/add-data?hl=fi-fiandcsw%3D1#add_a_document
        Create a document int the Contacts collection. Sometimes there isn't a meaningful ID for the document, and it's more convenient to let Cloud Firestore auto-generate an ID for you.
        You can do this by calling:
     */
    
    /*
    __block FIRDocumentReference *documentReference = [[[self firestore] collectionWithPath:@"Contacts"] addDocumentWithData:@{
        @"name":@"Kurt Cobain",
        @"email":@"kc@grunge.com",
        @"phone":@"032948575",
        @"photo":@"Kurt",
        @"position":@"HR",
    } completion:^(NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"Error adding document: %@", error);
        }else {
            NSLog(@"Document added with ID: %@", documentReference.documentID);
        }
    }];
     */
    
    /** In some cases, it can be useful to create a document reference with an auto-generated ID, then use the reference later. For this use case, you can call
     */
    /*
    FIRDocumentReference *newContactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithAutoID];
    //Do something with the new contact and then, send it to the DB
    [newContactReference setData:@{
        @"name":@"Don Murako",
        @"email":@"donM@onthedole.com",
        @"phone":@"0756090008",
        @"photo":@"Don",
        @"position":@"Software Architect"
    } completion:^(NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"Error adding document: %@", error);
        }else {
            NSLog(@"all good...");
        }
    }];
     */
}
    
-(void) clearScreen{
    [[self idTextField] setText:@""];
    [[self emailTextField] setText:@""];
    [[self nameTextField] setText:@""];
    [[self phoneTextField] setText:@""];
    [[self positionTextField] setText:@""];
}

- (IBAction)didPressClear:(id)sender {
    [self clearScreen];
}


- (IBAction)didPressSave:(id)sender {
    NSString *email = [[self emailTextField] text];
    NSString *phone = [[self phoneTextField] text];
    NSString *name  = [[self nameTextField] text];
    NSString *position = [[self positionTextField] text];
    
    //create a contact class with an initialiser
    Contact* contact = [[Contact alloc] initWithName:name email:email phone:phone position:position photo:@"Unknown" autoId:@""];

    NSMutableArray* validationFailedMessages = [[NSMutableArray alloc] init];
    //the method contactPassedValidations will do the validations
    if([self contactPassedValidations:contact error:validationFailedMessages]){
        if([self add:contact]){
            [self showUIAlertWithMessage:@"Contact Saved" andTitle:@"Save"];
            [self clearScreen];
        }else{
            [self showUIAlertWithMessage:@"The contact was not saved" andTitle:@"Save"];
        }
    }else{
        NSMutableString* invalidFieldsMessage = [NSMutableString new];
        for (NSString* message in validationFailedMessages) {
            [invalidFieldsMessage appendString:message];
            [invalidFieldsMessage appendString:@"\n"];
        }
        [self showUIAlertWithMessage:invalidFieldsMessage andTitle:@"Invalid Fields"];
    }
    
}

-(BOOL) add: (Contact *) contact{
    //https://cloud.google.com/firestore/docs/manage-data/add-data
    __block BOOL added = YES;
    @try {
        //Returns a FIRDocumentReference pointing to a new document with an auto-generated ID.
        FIRDocumentReference *newContactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithAutoID];
        //Do something with the new contact and then, send it to the DB by calling setData
        
        [newContactReference setData:@{
            @"name": [contact name],
            @"email": [contact email],
            @"phone": [contact phone],
            @"photo": [contact photo],
            @"position": [contact position]
        } completion:^(NSError * _Nullable error) {
            if(error != nil){
                NSLog(@"Error adding document: %@", error);
                added = NO;
            }else {
                NSLog(@"all good...");
            }
        }];
    } @catch (NSException *exception) {
        added = NO;
    }
    return added;
}

/**
    Here add any validation you need, by default I made every field mandatory
 */
-(BOOL) contactPassedValidations: (Contact*) contact
                           error: (NSMutableArray*) validationFailedMessages {
    
    BOOL passed = YES;
    /** Validate Contact Name */
    //remove empty spaces at the beginning and end
    NSString* trimmedContactName = [[contact name] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //check if there is something to search for after removing the empty spaces
    if([trimmedContactName length] == 0){
        [validationFailedMessages addObject:@"Name is mandatory"];
        passed = NO;
    }
    
    /** Validate Contact Email */
    NSString* trimmedContactEmail = [[contact email] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([trimmedContactEmail length] == 0){
        [validationFailedMessages addObject:@"Email is mandatory"];
        passed = NO;
    }
    
    /** Validate Contact Phone */
    NSString* trimmedContactPhone = [[contact phone] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //check if there is something to search for after removing the empty spaces
    if([trimmedContactPhone length] == 0){
        [validationFailedMessages addObject:@"Phone is mandatory"];
        passed = NO;
    }
    
    /** Validate Contact Position */
    NSString* trimmedContactPosition = [[contact position] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //check if there is something to search for after removing the empty spaces
    if([trimmedContactPosition length] == 0){
        [validationFailedMessages addObject:@"Position is mandatory"];
        passed = NO;
    }
    
    return passed;
}



- (IBAction)didPressSearch:(id)sender {
    /**
        Get Data once
        https://firebase.google.com/docs/firestore/query-data/get-data?hl=fi-fiandcsw%3D1
     */
    
    //get the ID typed by the user
    NSString* contactId = [[self idTextField] text];

    if( [self contactHasAValidId:contactId] ){
        /**
                        If we want to get the contact object returned from a method that in turns call an asynchronous method( All calls to Firestore are asynchronous, and it makes sense since the app won't stop waiting for the result)
                        we will need to pass a block containing the class we want to return from that method, this time we named this block: completeBlock
                        See the implementation of the method to know how to work with it.
         */
        [self searchContactById:contactId completeBlock:^(Contact *contact) {
            if( contact != nil ){
                [[self nameTextField] setText:[contact name]];
                [[self emailTextField] setText:[contact email]];
                [[self phoneTextField] setText:[contact phone]];
                [[self positionTextField] setText:[contact position]];
            }else{
                [self showUIAlertWithMessage:@"Contact Id not found" andTitle:@"Contact Search"];
            }
        }];
    
    }else{
        [self showUIAlertWithMessage:@"You must provide the contact ID to search for" andTitle:@"Contact Search Failed"];
        [[self idTextField] setText:@""];
    }
    
}

/**
    Given a contactId this method will search Contacts collection to retrieve the correspondent document
    What we're trying to do is asynchronous, so to return the contactFound we will have to add add a completion block parameter to our searchContactById method which is called when the inner completion handler is called
 
 */
-(void) searchContactById: (NSString* ) contactId completeBlock: (void(^)(Contact *)) completeBlock{
    
    __block Contact *contactFound;
    
    FIRDocumentReference *contactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithPath:contactId];
    
    [contactReference getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        NSLog(@"snapshot: %@", snapshot);
        if([snapshot exists]){

            NSDictionary<NSString *,id> *contactDictionary = [snapshot data];

            NSString* idFound = [snapshot documentID];
            
            contactFound = [[Contact alloc] initWithDictionary:contactDictionary];
            [contactFound setAutoId:idFound];

            if(completeBlock){
                NSLog(@"contact found in complete block: %@", contactFound);
                completeBlock(contactFound);
            }
            
            NSLog(@"contact found: %@", contactFound);

        }else{
//            completion(nil);
            NSLog(@"Document does not exist");
        }
    }];
        NSLog(@"abc: " );
}

/**
    Given a contact ID it validates it is not empty or has empty spaces
 */
-(BOOL) contactHasAValidId: (NSString* ) contactId{
    //remove empty spaces at the beginning and end
    NSString* trimmedContactId = [contactId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //check if there is something to search for after removing the empty spaces
    if([trimmedContactId length] == 0){
        return NO;
    }
    return YES;
}


-(IBAction)didPressDelete:(id)sender {
    
    //get the ID typed by the user
    NSString* contactId = [[self idTextField] text];
    
    if( [self contactHasAValidId:contactId] ){
        Contact * contact = [[Contact alloc] init];
        [contact setAutoId:contactId];
        
        if([self deleteC:contact]){
            [self showUIAlertWithMessage:@"Contact Deleted" andTitle:@"Delete"];
            [self clearScreen];
        }else{
            [self showUIAlertWithMessage:@"We could not delete the contact, try searching for it before" andTitle:@"Delete"];
        }

    }else{
        [self showUIAlertWithMessage:@"You must provide the contact ID of the contact to delete" andTitle:@"Delete"];
    }
    
}


-(BOOL) deleteC: (Contact*) contact{
    /**
        https://firebase.google.com/docs/firestore/manage-data/delete-data
         Warning: Deleting a document does not delete its subcollections!
     
         When you delete a document, Cloud Firestore does not automatically delete the documents within its subcollections.
         You can still access the subcollection documents by reference. For example, you can access the document at path /mycoll/mydoc/mysubcoll/mysubdoc even if you delete the ancestor document at /mycoll/mydoc.

         Non-existent ancestor documents appear in the console, but they do not appear in query results and snapshots.
         If you want to delete a document and all the documents within its subcollections, you must do so manually. For more information, see Delete Collections.
     */
    __block BOOL deleted = YES;
    FIRDocumentReference *contactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithPath:[contact autoId]];
    
    [contactReference deleteDocumentWithCompletion:^(NSError * _Nullable error) {
            if(error != nil){
                NSLog(@"Error removing contact: %@", error);
                deleted = NO;
            }
    }];
    return deleted;
}

-(void) showUIAlertWithMessage:(NSString*) message andTitle:(NSString*)title{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
    
        [self presentViewController:alert animated:YES completion:^{
            NSLog(@"%@", message);
        }];
}

-(IBAction)didPressUpdate:(id)sender {
    
    //get the ID typed by the user
    NSString* contactId = [[self idTextField] text];
    NSString *email = [[self emailTextField] text];
    NSString *phone = [[self phoneTextField] text];
    NSString *name  = [[self nameTextField] text];
    NSString *position = [[self positionTextField] text];
    
    if([self contactHasAValidId:contactId]){
        
        //create a contact class using the initialiser
        Contact* contact = [[Contact alloc] initWithName:name email:email phone:phone position:position photo:@"Unknown" autoId:@""];
        [contact setAutoId:contactId];

        NSMutableArray* validationFailedMessages = [[NSMutableArray alloc] init];
        //the method contactPassedValidations will do the validations
        if([self contactPassedValidations:contact error:validationFailedMessages]){
            if([self update: contact]){
                [self showUIAlertWithMessage:@"Contact updated" andTitle:@"Update"];
            }else{
                [self showUIAlertWithMessage:@"We couldn't save your changes" andTitle:@"Update"];
            }
        }else{
            NSMutableString* invalidFieldsMessage = [NSMutableString new];
            for (NSString* message in validationFailedMessages) {
                [invalidFieldsMessage appendString:message];
                [invalidFieldsMessage appendString:@"\n"];
            }
            [self showUIAlertWithMessage:invalidFieldsMessage andTitle:@"Invalid Fields"];
        }
    }else{
        [self showUIAlertWithMessage:@"You must provide the contact ID of the contact to delete" andTitle:@"Update"];
    }
    
}

-(BOOL) update: (Contact*) contact{
    __block BOOL updated = YES;
    
    //Fetch the document by using the Id
    FIRDocumentReference *contactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithPath:[contact autoId]];
    /**
            To update some fields of a document without overwriting the entire document, use the update() method.
            Else use setData with the merge property, in this case setData is recommended, I'm using update as demonstration
    */
    [contactReference updateData:@{
        @"name": [contact name],
        @"email": [contact email],
        @"phone": [contact phone],
        @"photo": [contact photo],
        @"position": [contact position]
    } completion:^(NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"Error updating document: %@", error);
            updated = NO;
        }else{
            NSLog(@"Document successfully updated");
        }
    }];
    return updated;
}

@end
