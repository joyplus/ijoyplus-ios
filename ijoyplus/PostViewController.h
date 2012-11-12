//
//  PostViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TencentOAuth.h"
#import "CustomPlaceHolderTextView.h"

@interface PostViewController : UIViewController <UITextViewDelegate, TencentSessionDelegate>

@property (strong, nonatomic) IBOutlet UIButton *sinaBtn;
@property (strong, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIImageView *filmImageView;
@property (weak, nonatomic) IBOutlet CustomPlaceHolderTextView *inputArea;
@property (nonatomic, strong)NSDictionary *program;
@property (nonatomic, strong)NSString *type;
@end
