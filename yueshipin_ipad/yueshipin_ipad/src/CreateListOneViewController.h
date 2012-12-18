//
//  CreateList1ViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "CustomPlaceHolderTextView.h"
#import "RadioButton.h"

@interface CreateListOneViewController : GenericBaseViewController <UITextFieldDelegate, RadioButtonDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIImageView *contentBgImage;
@property (weak, nonatomic) IBOutlet CustomPlaceHolderTextView *contentText;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *titleFieldBg;
@property (weak, nonatomic) IBOutlet UIButton *movieTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *dramaTypeBtn;
- (IBAction)videoTypeBtnClicked:(id)sender;

@property (strong, nonatomic)NSString *prodId;

@end
