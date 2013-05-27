//
//  SubsearchViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AddSearchViewController.h"
#import "SubsearchViewController.h"

@interface AddSearchViewController : SubsearchViewController
- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, strong)NSString *topId;
@property (nonatomic, strong)UIViewController *backToViewController;
@property (assign, nonatomic) int type;
@end
