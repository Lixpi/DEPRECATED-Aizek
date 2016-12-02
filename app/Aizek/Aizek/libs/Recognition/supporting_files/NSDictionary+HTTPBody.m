//
//  NSDictionary+HTTPBody.m
//  NSDictionary+HTTPBody
//
//  Created by Juan Ignacio Laube on 08/03/13.
//  Copyright (c) 2013 Juan Ignacio Laube. All rights reserved.
//

#import "NSDictionary+HTTPBody.h"

@implementation NSDictionary (HTTPBody)

- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding
{
    NSMutableString *bodyString = [[NSMutableString alloc] init];
    
    NSArray *keys = [self allKeys];
    if([self count] > 0)
    {
        [bodyString appendFormat:@"%@=%@", keys[0], [self valueForKey:keys[0]]];
        for(int i = 1; i < [self count]; i++)
        {
            [bodyString appendFormat:@"&%@=%@", keys[i], [self valueForKey:keys[i]]];
        }
    }
    
    //NSLog(@"string -> %@", bodyString);
    return [bodyString dataUsingEncoding:encoding];
}

@end
