//
//  Encryption.h
//  VivatToday
//
//  Created by Gal Blank on 4/26/10.
//  Copyright 2010 Mobixie. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Encryption : NSObject {

}
+ (Encryption *)sharedInstance;
- (NSData*) encryptString:(NSString*)plaintext withKey:(NSString*)key;
- (NSString*) decryptData:(NSData*)ciphertext withKey:(NSString*)key;

@end
