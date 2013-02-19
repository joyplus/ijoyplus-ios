//
//  RecordListCell.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "RecordListCell.h"

@implementation RecordListCell
@synthesize titleLab = titleLab_;
@synthesize actors = actors_;
@synthesize date = date_;
@synthesize play = play_;
@synthesize deleteBtn = deleteBtn_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 296, 60);
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, 200, 15)];
        self.titleLab.font = [UIFont systemFontOfSize:14];
        titleLab_.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLab];
        
        self.actors = [[UILabel alloc] initWithFrame:CGRectMake(12, 31, 200, 15)];
        self.actors.font = [UIFont systemFontOfSize:12];
        self.actors.textColor = [UIColor grayColor];
        actors_.backgroundColor = [UIColor clearColor];
        [self addSubview:self.actors];
        
        date_ = [[UILabel alloc] initWithFrame:CGRectMake(12, 45, 200, 15)];
        date_.font = [UIFont systemFontOfSize:12];
        date_.textColor = [UIColor grayColor];
        date_.backgroundColor = [UIColor clearColor];
        [self addSubview:date_];
        
        play_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        play_.frame = CGRectMake(230, 18, 60, 30);
        [play_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon_see.png"] forState:UIControlStateNormal];
        [play_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon_see_s.png"] forState:UIControlStateHighlighted];
        [self addSubview:play_];
        
        deleteBtn_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        deleteBtn_.frame = CGRectMake(240, 14, 48, 32);
        //[deleteBtn_ setTitle:@"delete" forState:UIControlStateNormal];
        deleteBtn_.hidden = YES;
        [deleteBtn_ setBackgroundImage:[UIImage imageNamed:@"dele_bt.png"] forState:UIControlStateNormal];
        [deleteBtn_ setBackgroundImage:[UIImage imageNamed:@"dele_bt_pressed.png"] forState:UIControlStateHighlighted];
        [self addSubview:deleteBtn_];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        line.frame = CGRectMake(0, 59, 320, 1);
        [self addSubview:line];
        
       
        
        
    }
    return self;
}
-(void)addCustomGestureRecognizer{
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [rightSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [self addGestureRecognizer:rightSwipeRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [leftSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    [self addGestureRecognizer:leftSwipeRecognizer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recover:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
}
-(void)handleSwipeFrom:(id)sender{
    if (play_.hidden) {
        play_.hidden = NO;
        deleteBtn_.hidden = YES;

    }
    else{
        play_.hidden = YES;
        deleteBtn_.hidden = NO;

    }
    
}
-(void)recover:(id)sender{
    play_.hidden = NO;
    deleteBtn_.hidden = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
