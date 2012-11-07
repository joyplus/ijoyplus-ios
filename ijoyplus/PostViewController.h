//
//  PostViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TencentOAuth.h"

@interface PostViewController : UIViewController <UITextViewDelegate, TencentSessionDelegate>

@property (strong, nonatomic) IBOutlet UIButton *sinaBtn;
@property (strong, nonatomic) IBOutlet UIButton *qqBtn;
@property (nonatomic, strong)NSDictionary *program;
@end
