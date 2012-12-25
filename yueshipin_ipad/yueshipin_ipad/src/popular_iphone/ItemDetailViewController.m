//
//  ItemDetailViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController
@synthesize infoDic = infoDic_;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.title = [self.infoDic objectForKey:@"prod_name"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:{
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 87, 129)];
            [imageView setImageWithURL:[NSURL URLWithString:[self.infoDic objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
            [cell addSubview:imageView];
            
            NSString *directors = [self.infoDic objectForKey:@"directors"];
            NSString *actors = [self.infoDic objectForKey:@"stars"];
            NSString *date = [self.infoDic objectForKey:@"publish_date"];
            NSString *area = [self.infoDic objectForKey:@"area"];
            UILabel *actorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 59, 200, 15)];
            actorsLabel.text = [NSString stringWithFormat:@"主演: %@",actors];
            [cell addSubview:actorsLabel];
            
            NSString *labelText = [NSString stringWithFormat:@"地区: %@\n编剧: %@\n年代: %@",area,directors,date];
            UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 75, 200, 70)];
            infoLabel.text = labelText;
            infoLabel.lineBreakMode = UILineBreakModeWordWrap;
            infoLabel.numberOfLines = 0;
            [cell addSubview:infoLabel];
            
            UIButton *play = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            play.frame = CGRectMake(115, 28, 87, 27);
            [play setTitle:@"播放视频" forState:UIControlStateNormal];
            [play addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:play];
            
            UIButton *addFav = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            addFav.frame = CGRectMake(14, 152, 142, 27);
            [addFav setTitle:[NSString stringWithFormat:@"收藏（%@）",[self.infoDic objectForKey:@"favority_num" ]]  forState:UIControlStateNormal];
            [addFav addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:addFav];
            
            UIButton *support = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            support.frame = CGRectMake(165, 152, 142, 27);
            [support setTitle:[NSString stringWithFormat:@"顶（%@）",[self.infoDic objectForKey:@"support_num" ]] forState:UIControlStateNormal];
            [support addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:support];
            
            break;
        }
        case 1:{
        
            
            
            
            break;
        }
                 
        case 2:{
            
            
            
            
            break;
        }
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = indexPath.row;
    if (row == 0) {
        return 181;
    }
    else if(row == 1){
        return 152;
    }
    else if(row == 2){
        return 100;
    }
    return 0;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
-(void)action:(id)sender {
    
}
@end
