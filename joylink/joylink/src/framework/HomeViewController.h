//
//  FeedController.h
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericBaseViewController.h"

@protocol HomeViewControllerDelegate <NSObject>

- (void)closeChildWindow:(UIViewController *)viewController;
- (void)closePopupView;

@end

@interface HomeViewController : GenericBaseViewController <HomeViewControllerDelegate>

@end
