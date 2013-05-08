//
//  UMUFPTableView.h
//  UFP
//
//  Created by liu yu on 12/17/11.
//  Updated by liu yu on 12/04/12.
//  Copyright 2010-2012 Umeng.com. All rights reserved.
//  Version 3.5.2

#import <UIKit/UIKit.h>

@protocol UMUFPTableViewDataLoadDelegate;

@interface UMUFPTableView : UITableView {
@private
    BOOL      _mAutoFill;
    BOOL      _mIsAllLoaded;
    BOOL      _mIsLoadingMore;
    BOOL      _mIsLoading;
    NSInteger _mRequestCount;
    NSString         *_mKeywords;
    NSMutableArray   *_mPromoterDatas;
    UIViewController *_mCurrentViewController;
    id<UMUFPTableViewDataLoadDelegate> _dataLoadDelegate;
}

@property (nonatomic, copy) NSString *mKeywords;        //keywords for the promoters data, promoter list will return according to this property, default is @""
@property (nonatomic)           BOOL mAutoFill;
@property (nonatomic, readonly) BOOL mIsAllLoaded;      //shows whether there are promoters list left to load
@property (nonatomic, readonly) BOOL mIsLoadingMore;    //shows whether more promoters list are loaded background
@property (nonatomic, readonly) BOOL mIsLoading;        //shows whether 1th promoters list are loaded background
@property (nonatomic, readonly) NSMutableArray *mPromoterDatas; //all the loaded promoters list for the releated appkey / slot_id
@property (nonatomic) NSInteger mRequestCount;          //number of promoters for every load more request, default is 10
@property (nonatomic, assign)   id<UMUFPTableViewDataLoadDelegate> dataLoadDelegate; //dataLoadDelegate for tableview
@property (nonatomic, readonly) NSInteger mNewPromoterCount;    //number of new promoters, default is -1(no new promoter)

/** 
 
 This method start the promoter data load in background, promoter data will be load until this method called
 
 */

- (void)requestPromoterDataInBackground;

/** 
 
 This method request more promoter data in background, should called after requestPromoterDataInBackground, as some initialization should be done in requestPromoterDataInBackground
 
 */

- (void)requestMorePromoterInBackground;

/** 
 
 This method return a UMANTableView object
 
 @param  frame frame for the UMANTableView 
 @param  style tableview style, UITableViewStylePlain or UITableViewStyleGrouped 
 @param  appkey appkey get from www.umeng.com, if you want use ufp service only, set this parameter empty
 @param  slotId slotId get from ufp.umeng.com
 @param  controller view controller releated to the view that the table view added into

 @return a UMANTableView object
 */

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style appkey:(NSString *)appkey slotId:(NSString *)slotId currentViewController:(UIViewController *)controller;

/** 
 
 This method called when promoter clicked
 
 @param  promoter info of the clicked promoter 
 @param  index index of the clicked promoter in the promoter array
 
 */

- (void)didClickPromoterAtIndex:(NSDictionary *)promoter index:(NSInteger)index;

/**
 
 This method check whether the app releated the promoter info installed
 
 @param  promoter info of the app to be checked

 @return a bool value, YES is installed, else NO
 */

+ (BOOL)isAppInstalled:(NSDictionary *)promoterInfo;

/** 
 
 This method set channel for this app, the default channel is App Store, call this method if you want to set channel for another value, don't need to call this method among different views, only once is enough
 
 */

+ (void)setAppChannel:(NSString *)channel;

@end

@protocol UMUFPTableViewDataLoadDelegate <NSObject>

@optional

- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview promoters:(NSArray *)promoters; //called when promoter list loaded
- (void)UMUFPTableView:(UMUFPTableView *)tableview didLoadDataFailWithError:(NSError *)error; //called when promoter list loaded failed for some reason
- (void)UMUFPTableView:(UMUFPTableView *)tableview didClickPromoterForUrl:(NSURL *)url; //implement this method if you want to handle promoter click event for the case that should open an url in webview  
- (void)UMUFPTableView:(UMUFPTableView *)tableview didClickedPromoterAtIndex:(NSInteger)promoterIndex; //called when table cell clicked, current action is go to app store

- (void)UMUFPTableView:(UMUFPTableView *)tableview didStartToLoadDetailPageAtIndex:(NSInteger)promoterIndex;
- (void)UMUFPTableView:(UMUFPTableView *)tableview didReadyToShowDetailPageAtIndex:(NSInteger)promoterIndex;

@end

