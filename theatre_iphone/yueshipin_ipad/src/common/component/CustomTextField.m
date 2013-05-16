//
//  CustomTextField.m
//  Surf's Up
//
//  Created by Baranski Steve on 7/4/11.
//  Copyright 2011 komorka technology, llc. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
	return CGRectInset(bounds, 5, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	return CGRectInset(bounds, 5, 0);	
}

- (void)drawRect:(CGRect)rect
{
    UIImage *textFieldBackground = [[UIImage imageNamed:@"text_field_teal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 5.0, 15.0, 5.0)];
    [textFieldBackground drawInRect:[self bounds]];
}

@end
