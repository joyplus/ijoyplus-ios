//
//  PlayRootViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayRootViewController : UIViewController{
    UIViewController *previousViewController;
    UIViewController *nextViewController;
    UIViewController *currentViewController;
}

@property (nonatomic, strong) NSString *programId;

- (void)initViewController;
- (void)recommand;
- (void)watch;
- (void)collection;
- (void)comment;

@end
