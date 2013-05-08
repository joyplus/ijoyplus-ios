//
//  UMUFPBannerView.h
//  UFP
//
//  Created by liu yu on 11/7/11.
//  Updated by liu yu on 12/04/12.
//  Copyright 2010-2012 Umeng.com. All rights reserved.
//  Version 3.5.2

#import <UIKit/UIKit.h>

@class UMUFPBannerViewInternal;

@protocol UMUFPBannerViewDelegate;

@interface UMUFPBannerView : UIView {
@private
    NSString   *_mKeywords;
    float      _mAnimationDuration;
    float      _mIntervalDuration; 
    BOOL       _mAutoFill;
    
    id<UMUFPBannerViewDelegate> _delegate;
    UMUFPBannerViewInternal     *_mBannerInternal;
}

@property (nonatomic, assign) id<UMUFPBannerViewDelegate> delegate; //delegate for banner view
@property (nonatomic, copy)   NSString *mKeywords;                  //keywords for the promoters data, promoter list will return according to this property, default is @""
@property (nonatomic, retain) UIColor *mBackgroundColor;            //background color for banner
@property (nonatomic, retain) UIColor *mTextColor;                  //color for text
@property (nonatomic, retain) UIFont *mTitleLabelFont;              //default is "Helvetica-Bold" 15.0
@property (nonatomic, retain) UIFont *mDescriptionLabelFont;        //default is "Helvetica"      12.0
@property (nonatomic) CGRect  mImageViewFrame;                      //frame for app icon
@property (nonatomic) CGRect  mTitleLabelFrame;                     //frame for title label
@property (nonatomic) CGRect  mDescriptionLabelFrame;               //frame for description label
@property (nonatomic) BOOL    mAutoFill;                            //default is true
@property (nonatomic) float   mAnimationDuration;                   //duration for the animation between two promoters, default is 0.6s
@property (nonatomic) float   mIntervalDuration;                    //duration for the promoter present time，default is 15s 

 /** 
 
 This method return a UMANBannerView object
 
 @param  frame frame for the banner view
 @param  appkey appkey get from www.umeng.com, if you want use ufp service only, set this parameter empty
 @param  slotId slotId get from ufp.umeng.com
 @param  controller view controller releated to the view that the banner view added into
 
 @return a UMANBannerView object
 */

- (id)initWithFrame:(CGRect)frame appKey:(NSString *)appkey slotId:(NSString *)slotId currentViewController:(UIViewController *)controller;

/** 
 
 This method start the promoter data load in background, promoter data will be load until this method called
 
 */

- (void)requestPromoterDataInBackground;

/**
 
 This method set background image for banner view
 
 */

- (void)setBackgroundImage:(UIImage *)image;

/** 
 
 This method set channel for this app, the default channel is App Store, call this method if you want to set channel for another value, don't need to call this method among different views, only once is enough
 
 */

+ (void)setAppChannel:(NSString *)channel;

@end

@protocol UMUFPBannerViewDelegate <NSObject>

@optional

- (void)bannerWillAppear:(UMUFPBannerView *)banner; //called when will appear the 1st time, implement this mothod if you want to change animation for the banner appear or do something else before banner appear
- (void)UMUFPBannerView:(UMUFPBannerView *)banner didLoadDataFinish:(NSInteger)promotersAmount; //called when promoter list loaded from the server
- (void)UMUFPBannerView:(UMUFPBannerView *)banner didLoadDataFailWithError:(NSError *)error; //called when promoter list loaded failed for some reason, for example network problem or the promoter list is empty
- (void)UMUFPBannerView:(UMUFPBannerView *)banner didClickPromoterForUrl:(NSURL *)url; //implement this method if you want to handle promoter click event for the case that should open an url in webview  
- (void)UMUFPBannerView:(UMUFPBannerView *)banner didClickedPromoterAtIndex:(NSInteger)index;   //called when banner clicked
- (void)UMUFPBannerView:(UMUFPBannerView *)banner openAdsForFlag:(NSString *)flagStr; // called when promoter with special schema url clicked

@end