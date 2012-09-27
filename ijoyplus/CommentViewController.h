//
//  CommentViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface CommentViewController : UIViewController<HPGrowingTextViewDelegate>

@property (assign, nonatomic)BOOL openKeyBoard;

@end
