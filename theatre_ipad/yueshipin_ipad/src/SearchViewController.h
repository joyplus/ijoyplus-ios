//
//  SettingsViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"
#import "MenuViewController.h"
#import "CustomSearchBar.h"

@protocol SearchViewControllerDelegate

- (void)clearSearchBarContent;
- (void)historyCellClicked:(NSString *)keyword;
- (void)resignFirstRespond;
@end

@interface SearchViewController : GenericBaseViewController <SearchViewControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>{

    UIImageView *topImage;
    UIImageView *bgImage;
    CustomSearchBar *sBar;
    
    NSMutableArray *historyArray;
    NSMutableArray *hotKeyArray;
    BOOL removePreviousView;
    
    int leftWidth;
}


- (id)initWithFrame:(CGRect)frame;
- (void)addKeyToLocalHistory:(NSString *)key;
- (void)reloadSearchList;

@end
