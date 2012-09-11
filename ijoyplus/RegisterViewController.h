//
//  RegisterViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGlossyButton.h"

@interface RegisterViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIGlossyButton *sinaButton;
@property (strong, nonatomic) IBOutlet UIGlossyButton *tecentButton;
@property (strong, nonatomic) IBOutlet UIGlossyButton *renrenButton;
@property (strong, nonatomic) IBOutlet UIGlossyButton *douban;
@property (strong, nonatomic) IBOutlet UIGlossyButton *registerButton;
- (IBAction)register:(id)sender;

@end
