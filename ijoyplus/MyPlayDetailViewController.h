//
//  PlayViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroductionView.h"
#import "FriendPlayDetailViewController.h"
#import "RecommendReasonCell.h"
@interface MyPlayDetailViewController : FriendPlayDetailViewController{
    RecommendReasonCell *reasonCell;
}
@end
