//
//  FilmReviewDetailView.m
//  yueshipin
//
//  Created by 08 on 13-3-29.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "FilmReviewDetailView.h"

#define FILM_DETAIL_REVIEW_FRAME(Height)    (CGRectMake(30, 80, 258, Height))
#define FILM_DETAIL_CLOSE_BUTTON_FRAME      (CGRectMake(214, 6, 38, 38))
#define FILM_DETAIL_TITLE_LABEL_FRAME       (CGRectMake(20, 30, 218, 30))
#define FILM_DETAIL_CONTENT_FRAME(Height)   (CGRectMake(10, 70, 250, Height))

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
        
        UIImageView * detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(27, 77, 264, self.frame.size.height - 134)];
        detailImage.image = [[UIImage imageNamed:@"popview_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        detailImage.backgroundColor = [UIColor clearColor];
        [self addSubview:detailImage];
        
        UIView * detailView = [[UIView alloc] initWithFrame:FILM_DETAIL_REVIEW_FRAME(self.frame.size.height - 140)];
        detailView.backgroundColor = [UIColor clearColor];
        [self addSubview:detailView];
        
        UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = FILM_DETAIL_CLOSE_BUTTON_FRAME;
        [closeBtn addTarget:self
                     action:@selector(closeButtonClick:)
           forControlEvents:UIControlEventTouchUpInside];
        [detailView addSubview:closeBtn];
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 19, 19, 0);
        [closeBtn setImage:[UIImage imageNamed:@"download_shut.png"]
                  forState:UIControlStateNormal];
        [closeBtn setImage:[UIImage imageNamed:@"download_shut_pressed.png"]
                  forState:UIControlStateHighlighted];
        closeBtn.backgroundColor = [UIColor clearColor];
        
        UILabel * detailLab   = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 80, 30)];
        detailLab.textAlignment = UITextAlignmentCenter;
        detailLab.font   = [UIFont boldSystemFontOfSize:16];
        detailLab.text = @"影评详情";
        detailLab.backgroundColor   = [UIColor clearColor];
        detailLab.textColor = [UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1];
        [detailView addSubview:detailLab];
        
        CGRect titleRect = FILM_DETAIL_TITLE_LABEL_FRAME;
        _labTitle   = [[UILabel alloc] init];
        _labTitle.numberOfLines = 2;
        _labTitle.font = [UIFont boldSystemFontOfSize:14];
        _labTitle.backgroundColor   = [UIColor clearColor];
        _labTitle.textColor   = [UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1];
        [detailView addSubview:_labTitle];
        
        CGSize size = [title sizeWithFont:[UIFont boldSystemFontOfSize:14]
                        constrainedToSize:CGSizeMake(FILM_DETAIL_TITLE_LABEL_FRAME.size.width, CGFLOAT_MAX)];
        titleRect.size.height = (size.width > 50) ? (50.0f) : (size.width);
        _labTitle.frame = titleRect;
        _labTitle.text = title;
        
        
        _viewContent = [[UITextView alloc] initWithFrame:FILM_DETAIL_CONTENT_FRAME(detailView.frame.size.height - 80)];
        _viewContent.editable = NO;
        [detailView addSubview:_viewContent];
        _viewContent.text = [NSString stringWithFormat:@"%@",content];
        [_viewContent setBackgroundColor:[UIColor clearColor]];
        _viewContent.textColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1];
        _viewContent.font = [UIFont systemFontOfSize:12];
        
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
