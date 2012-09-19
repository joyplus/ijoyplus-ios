//
//  SettingsViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UIButton *logoutBtn;
@property (strong, nonatomic) IBOutlet UIButton *searchFriendBtn;
@property (strong, nonatomic) IBOutlet UIButton *commentBtn;
@property (strong, nonatomic) IBOutlet UIButton *aboutUsBtn;
@property (strong, nonatomic) IBOutlet UIButton *scoreBtn;
- (IBAction)logout:(id)sender;

@end
