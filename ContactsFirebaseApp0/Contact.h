//
//  Contact.h
//  ContactsFirebaseApp0
//
//  Created by alex on 18/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Contact : NSObject

@property NSString* autoId;
@property NSString* name;
@property NSString* email;
@property NSString* photo;
@property NSString* phone;
@property NSString* position;

- (instancetype)initWithName: (NSString*) name
                       email: (NSString*) email
                       phone: (NSString*) phone
                    position: (NSString*) position
                       photo: (NSString*) photo
                      autoId: (NSString*) autoId;

- (instancetype)initWithDictionary: (NSDictionary*) dictionary;

@end

NS_ASSUME_NONNULL_END
