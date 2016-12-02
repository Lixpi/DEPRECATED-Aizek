//
//  NSDictionary+HTTPBody.h
//  NSDictionary+HTTPBody
//
//  Created by Juan Ignacio Laube on 08/03/13.
//  Copyright (c) 2013 Juan Ignacio Laube. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HTTPBody)

- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding;

@end
