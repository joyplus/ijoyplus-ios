//
//  FriendDetailViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeiBoInviteViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
- (IBAction)submitBtnClicked:(id)sender;

@property (strong, nonatomic) NSDictionary *friendInfo;
@end
