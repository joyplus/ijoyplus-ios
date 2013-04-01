//
//  FilmReviewDetailView.m
//  yueshipin
//
//  Created by 08 on 13-3-29.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "FilmReviewDetailView.h"

#define FILM_DETAIL_REVIEW_FRAME(Height)    (CGRectMake(30, 80, 258, Height))
#define FILM_DETAIL_CLOSE_BUTTON_FRAME      (CGRectMake(330, 0, 30, 30))
#define FILM_DETAIL_TITLE_LABEL_FRAME       (CGRectMake(20, 30, 218, 30))
#define FILM_DETAIL_CONTENT_FRAME(Height)   (CGRectMake(10, 65, 238, Height))

@implementation FilmReviewDetailView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSString *)content
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //背景按钮
        UIButton * bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bgBtn.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f];
        bgBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [bgBtn addTarget:self
                  action:@selector(closeButtonClick:)
        forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgBtn];
        
        UIView * detailView = [[UIView alloc] initWithFrame:FILM_DETAIL_REVIEW_FRAME(self.frame.size.height - 140)];
        detailView.backgroundColor = [UIColor whiteColor];
        [self addSubview:detailView];
        
        UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = FILM_DETAIL_CLOSE_BUTTON_FRAME;
        [closeBtn addTarget:self
                     action:@selector(closeButtonClick:)
           forControlEvents:UIControlEventTouchUpInside];
        [detailView addSubview:closeBtn];
        
        UILabel * detailLab   = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        detailLab.textAlignment = UITextAlignmentCenter;
        detailLab.font   = [UIFont boldSystemFontOfSize:15];
        detailLab.text = @"影片详情";
        detailLab.backgroundColor   = [UIColor clearColor];
        detailLab.textColor   = [UIColor grayColor];
        [detailView addSubview:detailLab];
        
        _labTitle   = [[UILabel alloc] initWithFrame:FILM_DETAIL_TITLE_LABEL_FRAME];
        _labTitle.textAlignment = UITextAlignmentCenter;
        _labTitle.font   = [UIFont boldSystemFontOfSize:15];
        _labTitle.backgroundColor   = [UIColor clearColor];
        _labTitle.textColor   = [UIColor grayColor];
        [detailView addSubview:_labTitle];
        _labTitle.text = title;
        
        _viewContent = [[UITextView alloc] initWithFrame:FILM_DETAIL_CONTENT_FRAME(detailView.frame.size.height - 65)];
        _viewContent.editable = NO;
        [detailView addSubview:_viewContent];
        _viewContent.text = [NSString stringWithFormat:@" %@",content];
        [_viewContent setBackgroundColor:[UIColor clearColor]];
        
        for (UIGestureRecognizer * gRec in _viewContent.gestureRecognizers)
        {
            if ([gRec isKindOfClass:[UILongPressGestureRecognizer class]]
                || [gRec isKindOfClass:[UITapGestureRecognizer class]])
            {
                [gRec removeTarget:nil action:nil];
            }
        }
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)closeButtonClick:(id)sender
{
    [self removeFromSuperview];
}

@end
