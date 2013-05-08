//
//  UMUFPImageView.h
//  UFP
//
//  Created by liu yu on 1/17/12.
//  Updated by liu yu on 12/04/12.
//  Copyright 2010-2012 Umeng.com. All rights reserved.
//  Version 3.5.2

#import <UIKit/UIKit.h>

@protocol delegate;

@interface UMUFPImageView : UIImageView {
@private
    NSURL   *_imageURL;
    UIImage *_placeholderImage;
    
    id<delegate> _dataLoadDelegate;
}

- (id)initWithPlaceholderImage:(UIImage*)anImage;

@property(nonatomic, retain) NSURL   *imageURL;
@property(nonatomic, retain) UIImage *placeholderImage;
@property(nonatomic, assign) id<delegate> dataLoadDelegate;

@end

@protocol delegate <NSObject>

@optional

- (void)didLoadFinish:(UMUFPImageView *)imageview; //releated image load finished
- (void)didLoadFailed:(UMUFPImageView *)imageview; //releated image load failed

@end