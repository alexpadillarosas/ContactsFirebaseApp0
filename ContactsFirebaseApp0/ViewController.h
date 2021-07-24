//
//  ViewController.h
//  ContactsFirebaseApp0
//
//  Created by alex on 11/7/21.
//

#import <UIKit/UIKit.h>
@import Firebase;
@import FirebaseDatabase;

@interface ViewController : UIViewController

//@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (nonatomic, strong) FIRFirestore *firestore;

@end

