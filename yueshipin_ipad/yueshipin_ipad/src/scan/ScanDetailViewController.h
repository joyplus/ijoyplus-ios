//
//  ScanDetailViewController.h
//  yueshipin
//
//  Created by lily on 13-7-10.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IpadBunDingViewController.h"
@interface ScanDetailViewController : UIViewController{

    BOOL isBunding_;
    IpadBunDingViewController *ipadBundingView;
}
@property (nonatomic,assign) BOOL isBunding;
@end
