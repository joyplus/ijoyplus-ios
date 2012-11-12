//
//  SettingsViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchFriendBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *aboutUsBtn;
@property (weak, nonatomic) IBOutlet UIButton *scoreBtn;
- (IBAction)logout:(id)sender;
- (IBAction)searchFriend:(id)sender;
- (IBAction)commentBtnClicked:(id)sender;
- (IBAction)aboutUs:(id)sender;

@end
