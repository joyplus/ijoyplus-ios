//
//  UIImage+Scale.m
//  yueshipin
//
//  Created by 08 on 13-1-7.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)
+(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
