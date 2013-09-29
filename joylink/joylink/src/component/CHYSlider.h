//
//  CHYSlider.h
//  CHYSliderDemo
//
//  Created by Chen Chris on 8/16/12.
//  Copyright (c) 2012 ciderstudios.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHYSliderDelegate <NSObject>

- (void)beginTrackingWithTouch;
- (void)endTrackingWithTouch;
@end

@interface CHYSlider : UIControl {
    BOOL _thumbOn;                              // track the current touch state of the slider
    UIImageView *_thumbImageView;               // the slide knob
    UIImageView *_trackImageViewNormal;         // slider track image in normal state
    UIImageView *_trackImageViewHighlighted;    // slider track image in highlighted state
}

/**
 same properties by referring UISlider
 */
@property(nonatomic, assign) float value;                           // default 0.0. this value will be pinned to min/max
@property(nonatomic, assign) float minimumValue;                    // default 0.0. the current value may change if outside new min value
@property(nonatomic, assign) float maximumValue;                    // default 1.0. the current value may change if outside new max value
@property(nonatomic, assign) BOOL continuous;   // if set, value change events are generated any time the value changes due to dragging. default = YES

/**
 Use these properties to customize UILabel font and color
 */
@property(nonatomic, strong) UILabel *labelOnThumb;                 // overlayed above the thumb knob, moves along with the thumb You may customize its `font`, `textColor` and other properties.
@property(nonatomic, strong) UILabel *labelAboveThumb;              // displayed on top fo the thumb, moves along with the thumb You may customize its `font`, `textColor` and other properties.
@property(nonatomic, assign) int decimalPlaces;                     // determin how many decimal places are displayed in the value labels

@property(nonatomic, assign) BOOL stepped;      // if set, the slider is segmented with 6 values, and thumb only stays on these values. default = NO. (Note: the stepped slider is not fully implemented, I'm considering adding a NSArray steppedValues property in next release)
@property(nonatomic, weak) id<CHYSliderDelegate>delegate;
@end
