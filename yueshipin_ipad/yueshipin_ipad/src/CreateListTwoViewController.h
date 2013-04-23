//
//  CreateListTwoViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"

@interface CreateListTwoViewController : GenericBaseViewController <UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong, nonatomic) NSString *titleContent;
@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSString *topId;
@end
