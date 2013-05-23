//
// DemoTableHeaderView.m
//
// @author Shiki
//

#import "DemoTableHeaderView.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation DemoTableHeaderView

@synthesize title,dateLabel;
@synthesize activityIndicator;
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) awakeFromNib
{
  self.backgroundColor = [UIColor clearColor];
  title.font = [UIFont boldSystemFontOfSize:13];
  title.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
  title.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
  title.shadowOffset = CGSizeMake(0.0f, 1.0f);
  dateLabel.font = [UIFont boldSystemFontOfSize:12];
  dateLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
  dateLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
  dateLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
  dateLabel.text = @"";
  [super awakeFromNib];
}

@end
