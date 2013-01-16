//
//  CreateMyListOneViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateMyListOneViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>{
    UITextField *titleTextField_;
    UITextView *detailTextView_;
    NSMutableDictionary *infoDic_;
    NSString *topicId_;
    UILabel *detailLabel_;
    UIButton *nextBtn_;
}
@property (nonatomic, strong)UITextField *titleTextField;
@property (nonatomic, strong)UITextView *detailTextView;
@property (nonatomic, strong)NSMutableDictionary *infoDic;
@property (nonatomic, strong)NSString *topicId;
@property (nonatomic, strong)UILabel *detailLabel;
@property (nonatomic, strong)UIButton *nextBtn;
@end
