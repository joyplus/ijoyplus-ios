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

@interface SearchViewController : GenericBaseViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>{
    UIButton *menuBtn;
    UIImageView *topImage;
    UIImageView *bgImage;
    CustomSearchBar *sBar;
    UITableView *table;
    
    NSMutableArray *historyArray;
    NSMutableArray *hotKeyArray;
    
    NSMutableArray *hotKeyIndex;
    
    NSMutableDictionary *hotKeyBtnWidth;
    BOOL removePreviousView;
}


- (id)initWithFrame:(CGRect)frame;
- (void)addKeyToLocalHistory:(NSString *)key;
@property (nonatomic, weak)id <MenuViewControllerDelegate> menuViewControllerDelegate;
@end
