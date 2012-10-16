//
//  PostViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendCommentViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *sinaBtn;
@property (strong, nonatomic) IBOutlet UIButton *qqBtn;
@property (nonatomic, strong)NSString *programId;
@end
