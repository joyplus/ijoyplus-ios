//
//  PlayRootViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayViewController.h"

@interface PlayRootViewController : UIViewController{
    PlayViewController *previousViewController;
    PlayViewController *nextViewController;
    PlayViewController *currentViewController;
}

@property (nonatomic, strong) NSString *programId;

- (void)initViewController;
- (void)like;
- (void)watch;
- (void)collection;
- (void)comment;

@end
