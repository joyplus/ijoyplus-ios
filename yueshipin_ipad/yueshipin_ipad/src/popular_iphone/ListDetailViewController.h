//
//  ListDetailViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListDetailViewController : UITableViewController{

    NSMutableArray *listArr_;
    int Type_;
    NSString *topicId_;
}
@property (strong, nonatomic) NSMutableArray *listArr;
@property (assign, nonatomic)int Type;
@property (strong, nonatomic)NSString *topicId;
-(void)initTopicData:(NSString *)topicId;
@end