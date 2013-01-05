//
//  SearchResultsViewCell.m
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SearchResultsViewCell.h"

@implementation SearchResultsViewCell
@synthesize imageview = imageview_;
@synthesize label = label_;
@synthesize actors = actors_;
@synthesize area = area_;
@synthesize type = type_;
@synthesize addImageView = addImageView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15, 6, 57, 84)];
        [self addSubview:self.imageview];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(82, 9, 170, 14)];
        self.label.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.label];
        
        actors_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 32, 200, 12)];
        actors_.font = [UIFont systemFontOfSize:12];
        actors_.textColor = [UIColor grayColor];
        area_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 48, 170, 12)];
        area_.font = [UIFont systemFontOfSize:12];
        area_.textColor = [UIColor grayColor];
        
        type_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 64, 170, 12)];
        type_.font = [UIFont systemFontOfSize:12];
        type_.textColor = [UIColor grayColor];
        [self addSubview:actors_];
        [self addSubview:area_];
        [self addSubview:type_];
        
        addImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(250, 46, 57, 26)];
        addImageView_.backgroundColor = [UIColor clearColor];
        [self addSubview:addImageView_];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        line.frame = CGRectMake(0, 94, 320, 1);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
