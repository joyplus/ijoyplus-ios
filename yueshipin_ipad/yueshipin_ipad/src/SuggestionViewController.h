//
//  CreateList1ViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "CustomPlaceHolderTextView.h"

@interface SuggestionViewController : GenericBaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIImageView *contentBgImage;
@property (weak, nonatomic) IBOutlet CustomPlaceHolderTextView *contentText;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *titleFieldBg;

@property (strong, nonatomic)NSString *prodId;

@end
