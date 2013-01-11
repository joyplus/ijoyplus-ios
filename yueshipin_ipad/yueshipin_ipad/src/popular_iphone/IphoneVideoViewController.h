//
//  IphoneVideoViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-10.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"
#define DING 1
#define ADDFAV  2
@interface IphoneVideoViewController : UITableViewController<SinaWeiboDelegate,SinaWeiboRequestDelegate>{
     SinaWeibo *_mySinaWeibo;
    NSDictionary *_infoDic;
}
@property (nonatomic, strong) SinaWeibo *mySinaWeibo;
@property (nonatomic, strong) NSDictionary *infoDic;
- (void)showOpSuccessModalView:(float)closeTime with:(int)type;
- (void)showOpFailureModalView:(float)closeTime with:(int)type;
@end
