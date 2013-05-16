//
//  SearchResultsViewCell.h
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewCell : UITableViewCell{
    UIImageView *imageview_;
    UILabel *label_;
    UILabel *actors_;
    UILabel *area_;
    UILabel *type_;
    UIImageView *addImageView_;
}
@property (strong, nonatomic)UIImageView *imageview;
@property (strong, nonatomic)UILabel *label;
@property (strong, nonatomic)UILabel *actors;
@property (strong, nonatomic)UILabel *area;
@property (strong, nonatomic)UILabel *type;
@property (strong, nonatomic)UIImageView *addImageView;
@end
