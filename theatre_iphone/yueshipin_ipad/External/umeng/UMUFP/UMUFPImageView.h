//
//  UMUFPImageView.h
//  UFP
//
//  Created by liu yu on 1/17/12.
//  Updated by liu yu on 04/02/13.
//  Copyright 2010-2013 Umeng.com. All rights reserved.
//  Version 3.5.4

#import <UIKit/UIKit.h>

@protocol delegate;

/**
 
 UMUFPImageView is a subclass of UIImageView class that support remote image loading and cache.
 
 */

@interface UMUFPImageView : UIImageView {
@private
    NSURL   *_imageURL;
    UIImage *_placeholderImage;
    
    id<delegate> _dataLoadDelegate;
}

/**
 
 This method return a UMUFPImageView object
 
 @param  anImage placeholder image for the imageview
 
 @return a UMUFPImageView object
 
 */

- (id)initWithPlaceholderImage:(UIImage*)anImage;

/**
 
 This method check whether image for certain url loaded
 
 @param  imageUrl url for a remote image
 
 @return a BOOL value
 
 */

- (BOOL)isCachedImageWithUrl:(NSURL *)imageUrl; //Check whether image for the releated url has been downloaded

@property(nonatomic, retain) NSURL   *imageURL; //Url of the image releated the imageview currently
@property(nonatomic, retain) UIImage *placeholderImage; //Placeholder image for the imageview during image loading progress
@property(nonatomic, assign) id<delegate> dataLoadDelegate; //Delegate

@end

/**
 
 delegate is a protocol for UMUFPImageView.
 Optional methods of the protocol allow the delegate to capture UMUFPImageView releated events, and perform other actions.
 
 */

@protocol delegate <NSObject>

@optional

- (void)didLoadFinish:(UMUFPImageView *)imageview; //releated image load finished
- (void)didLoadFailed:(UMUFPImageView *)imageview; //releated image load failed

@end