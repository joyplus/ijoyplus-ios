//
//  PostViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommandViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong)NSString *programId;
@property (strong, nonatomic) IBOutlet UIButton *sinaBtn;
@end
