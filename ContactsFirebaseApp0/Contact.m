//
//  Contact.m
//  ContactsFirebaseApp0
//
//  Created by alex on 18/7/21.
//

#import "Contact.h"

@implementation Contact

//
//- (instancetype)initWithName: (NSString*) name
//                       email: (NSString*) email
//                       phone: (NSString*) phone
//                    position: (NSString*) position
//                       photo: (NSString*) photo
//
//    self = [super init];
//    if (self) {
//        _name = name;
//        _email = email;
//        _phone = phone;
//        _position = position;
//        _photo = photo;
//        _autoId = @"";
//    }
//    return self;
//}

- (instancetype)initWithName: (NSString*) name
                       email: (NSString*) email
                       phone: (NSString*) phone
                    position: (NSString*) position
                       photo: (NSString*) photo
                      autoId: (NSString*) autoId
{
    self = [super init];
    if (self) {
        _name = name;
        _email = email;
        _phone = phone;
        _position = position;
        _photo = photo;
        _autoId = autoId;
    }
    return self;
}



- (instancetype)initWithDictionary: (NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        _autoId = dictionary[@"autoId"];
        _name = dictionary[@"name"];
        _email = dictionary[@"email"];
        _phone = dictionary[@"phone"];
        _position = dictionary[@"position"];
        _photo = dictionary[@"photo"];
    }
    return self;
}

-(NSString*) description{
    
    return  [NSString stringWithFormat:@"name: %@ email: %@ phone: %@ position: %@", _name, _email, _phone, _position] ;

}


@end
