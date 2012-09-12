#import "PopularViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "PlayRootViewController.h"

#define NUMBER_OF_COLUMNS 3
#define TOP_TAB_HEIGHT 40
#define BOTTOM_TAB_HEIGHT 60
#define COLUMN_GAP_WIDTH 10

@interface PopularViewController(){
    WaterflowView *flowView;
    NSMutableArray *imageUrls;
    int currentPage;
    int tempCount;
}
- (void)addContentView;
@end

@implementation PopularViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    imageUrls = [NSMutableArray arrayWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg",@"http://img1.douban.com/lpic/s11184513.jpg",@"http://img1.douban.com/lpic/s9127643.jpg",@"http://img3.douban.com/lpic/s6781186.jpg",@"http://img1.douban.com/mpic/s9039761.jpg",nil];
    tempCount = imageUrls.count;
    [self addContentView];
}

- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    flowView = [[WaterflowView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - TOP_TAB_HEIGHT - BOTTOM_TAB_HEIGHT + 8)];
    [flowView showsVerticalScrollIndicator];
    flowView.flowdatasource = self;
    flowView.flowdelegate = self;
    [self.view addSubview:flowView];
    
    currentPage = 1;
    [flowView reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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

    static NSString *CellIdentifier = @"Cell";
	WaterFlowCell *cell = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];

    float height = [self flowView:nil heightForRowAtIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    if(indexPath.section == 0){
        imageView.frame = CGRectMake(COLUMN_GAP_WIDTH, COLUMN_GAP_WIDTH, (self.view.frame.size.width - (NUMBER_OF_COLUMNS+1)*COLUMN_GAP_WIDTH)/NUMBER_OF_COLUMNS, height - 30);
    } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
        imageView.frame = CGRectMake(COLUMN_GAP_WIDTH/2, COLUMN_GAP_WIDTH, (self.view.frame.size.width - (NUMBER_OF_COLUMNS+1)*COLUMN_GAP_WIDTH)/NUMBER_OF_COLUMNS, height - 30);
    } else {        
        imageView.frame = CGRectMake(COLUMN_GAP_WIDTH/2, COLUMN_GAP_WIDTH, (self.view.frame.size.width - (NUMBER_OF_COLUMNS+1)*COLUMN_GAP_WIDTH)/NUMBER_OF_COLUMNS, height - 30);
    }
    [imageView setImageWithURL:[NSURL URLWithString:[imageUrls objectAtIndex:(indexPath.row + indexPath.section) % tempCount]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [cell addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.text = @"电影";
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake(self.view.frame.size.width / NUMBER_OF_COLUMNS / 2, height - 10);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [cell addSubview:titleLabel];
    return cell;
    
}


- (CGFloat)flowView:(WaterflowView *)flowView heightForCellAtIndex:(NSInteger)index
{
    return 50;
}
#pragma mark-
#pragma mark- WaterflowDelegate


-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	return 150;
    
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select at %i %i",indexPath.row, indexPath.section);
    PlayRootViewController *viewController = [[PlayRootViewController alloc]init];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    [imageUrls addObject:@"http://img5.douban.com/mpic/s10389149.jpg"];
    tempCount = imageUrls.count;
    [flowView reloadData];
}

@end
