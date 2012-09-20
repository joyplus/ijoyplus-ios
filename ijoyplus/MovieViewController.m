#import "MovieViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "PlayRootViewController.h"
#import "CMConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface MovieViewController(){
    WaterflowView *flowView;
    NSMutableArray *imageUrls;
    int currentPage;
    int tempCount;
}
- (void)addContentView;
@end

@implementation MovieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageUrls = [NSMutableArray arrayWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg",@"http://img1.douban.com/lpic/s11184513.jpg",@"http://img1.douban.com/lpic/s9127643.jpg",@"http://img3.douban.com/lpic/s6781186.jpg",@"http://img1.douban.com/mpic/s9039761.jpg",nil];
    tempCount = imageUrls.count;
    [self addContentView];
    
    UISwipeGestureRecognizer *downGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideNavigationBarAnimation)];
    downGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [flowView addGestureRecognizer:downGesture];
}

- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    flowView = [[WaterflowView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [flowView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *flag = @"0";
    if(appDelegate.userLoggedIn){
        flag = @"1";
    }
    flowView.cellSelectedNotificationName = [NSString stringWithFormat:@"%@%@", @"movieSelected",flag];
    [flowView showsVerticalScrollIndicator];
    flowView.flowdatasource = self;
    flowView.flowdelegate = self;
    [self.view addSubview:flowView];
    
    currentPage = 1;
    [flowView reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark-
#pragma mark- WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    return 10;
}

- (WaterFlowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"movieCell";
	WaterFlowCell *cell = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
    cell.cellSelectedNotificationName = flowView.cellSelectedNotificationName;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    if(indexPath.section == 0){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    } else {        
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
    }
    [imageView setImageWithURL:[NSURL URLWithString:[imageUrls objectAtIndex:(indexPath.row + indexPath.section) % tempCount]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(1, 1);
    imageView.layer.shadowOpacity = 1;
    [cell addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, MOVIE_LOGO_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT)];
    titleLabel.text = [NSString stringWithFormat:@"%i, %i", indexPath.row, indexPath.section];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = CMConstants.titleFont;
    [cell addSubview:titleLabel];
    return cell;
    
}

#pragma mark-
#pragma mark- WaterflowDelegate
-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	return MOVIE_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT;
    
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select at %i %i in %@",indexPath.row, indexPath.section, self.class);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    PlayRootViewController *viewController = [[PlayRootViewController alloc]init];
//    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [navController pushViewController:viewController animated:YES];
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    [imageUrls addObject:@"http://img5.douban.com/mpic/s10389149.jpg"];
    tempCount = imageUrls.count;
    [flowView reloadData];
}

@end
