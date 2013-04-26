//
//  MyListCell.m
//  yueshipin
//
//  Created by Rong on 13-4-23.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "MyListCell.h"
#import "UIImageView+WebCache.h"
@implementation MyListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initCell:(NSDictionary*)infoDic{
    
    
    UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
    frame.frame = CGRectMake(10, 7, 43, 64);
    [self.contentView addSubview:frame];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 8, 40, 60)];
    [imageView setImageWithURL:[NSURL URLWithString:[infoDic objectForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    [self.contentView addSubview:imageView];
    
    NSMutableArray *items = (NSMutableArray *)[infoDic objectForKey:@"items"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 5, 180, 14)];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = [infoDic objectForKey:@"name"];
    titleLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:titleLabel];
    
    for (NSDictionary *dic in items) {
        int index = [items indexOfObject:dic];
        if (index > 5) break;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(62+(index/3)*110, 23+(index%3)*13, 105, 9)];
        label.text = [dic objectForKey:@"prod_name"];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor grayColor];
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];
    }
    
    UIImageView *typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(268, 4, 25, 18)];
    NSString *type = [infoDic objectForKey:@"prod_type"];
    if ([type isEqualToString:@"1"]) {
        typeImageView.image = [UIImage imageNamed:@"tab1_movieflag"];
    }
    else if ([type isEqualToString:@"2"]){
        typeImageView.image = [UIImage imageNamed:@"tab1_seriesflag"];
    }
    [self.contentView addSubview:typeImageView];
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
