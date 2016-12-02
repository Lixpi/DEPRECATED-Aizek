//
//  UIImageResize+Rotate.h
//  ReKo SDK
//
//  Created by cys on 7/24/13.
//  Copyright (c) 2013 Orbeus Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIImage (ResizeFixOrientation)
    + (UIImage *) imageWithImage: (UIImage *) image scaledToSize: (CGSize)newSize;
    - (UIImage *)fixOrientation;
@end