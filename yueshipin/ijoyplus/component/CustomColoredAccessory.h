//
//  CustomColoredAccessory.h
//  GoHappy
//
//  Created by scottliyq on 12-7-30.
//
//

#import <UIKit/UIKit.h>

@interface CustomColoredAccessory : UIControl

{
	UIColor *_accessoryColor;
	UIColor *_highlightedColor;
}

@property (nonatomic, retain) UIColor *accessoryColor;
@property (nonatomic, retain) UIColor *highlightedColor;

+ (CustomColoredAccessory *)accessoryWithColor:(UIColor *)color;

@end
