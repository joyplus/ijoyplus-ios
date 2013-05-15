//
//  FeedbackViewController.h
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"

@interface FeedbackViewController : UIViewController <UMFeedbackDataDelegate> {
    
    UMFeedback *feedbackClient;
}

@property (nonatomic, retain) IBOutlet UITextField *mTextField;
@property (nonatomic, retain) IBOutlet UITableView *mTableView;
@property (nonatomic, retain) IBOutlet UIToolbar   *mToolBar;

@property (nonatomic, retain)  NSMutableArray *mFeedbackDatas;

- (IBAction)sendFeedback:(id)sender;

@end
