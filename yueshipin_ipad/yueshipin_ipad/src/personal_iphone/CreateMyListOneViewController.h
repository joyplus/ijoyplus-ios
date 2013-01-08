//
//  CreateMyListOneViewController.h
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateMyListOneViewController : UIViewController{
    UITextField *titleTextField_;
    UITextView *detailTextView_;
    NSMutableDictionary *infoDic_;
    NSString *topicId_;
    
}
@property (nonatomic, strong)UITextField *titleTextField;
@property (nonatomic, strong)UITextView *detailTextView;
@property (nonatomic, strong)NSMutableDictionary *infoDic;
@property (nonatomic, strong)NSString *topicId;
@end
