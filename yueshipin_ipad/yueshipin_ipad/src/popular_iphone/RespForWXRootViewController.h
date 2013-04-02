//
//  RespForWeChatViewController.h
//  yueshipin
//
//  Created by 08 on 13-4-2.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RespForWXRootView.h"
#import "RespForWXDetailViewController.h"

@protocol RespForWXRootViewControllerDelegate;

@interface RespForWXRootViewController : UIViewController <UISearchBarDelegate,RespForWXRootViewDelegate,RespForWXDetailViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UISearchBar         *searchBar_;
    NSString            *_strHotId;
    RespForWXRootView   *_viewRespForWX;
    UITableView         *_tableSearchHistory;
    NSArray             *_arrHistory;
}

@property (nonatomic, weak) id <RespForWXRootViewControllerDelegate>delegate;

@end

@protocol RespForWXRootViewControllerDelegate <NSObject>

- (void)backButtonClick;
- (void)removeRespForWXRootView;
- (void)shareVideoResp:(NSDictionary *)data;

@end