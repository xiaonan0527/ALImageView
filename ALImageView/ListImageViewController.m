//
//  ListImageViewController.m
//  ALImageView
//
//  Created by SpringOx on 13-5-15.
//  Copyright (c) 2013年 SpringOx. All rights reserved.
//
//  Contact:jiachunke@gmail.com
//

#import "ListImageViewController.h"
#import "ALContainerView.h"

#define CellCount(t_num, p_num)  (t_num%p_num ? (t_num/p_num+1) : t_num/p_num)
#define ListImageViewControllerContainerImageCount     4

@interface ListImageCell ()

@end

@implementation ListImageCell

- (void)dealloc
{
    self.containerView = nil;
    [super dealloc];
}

@end


@interface ListImageViewController ()
{
    NSMutableArray *_imageArray;
}

@end

@implementation ListImageViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    if (nil != _imageArray) {
        [_imageArray release];
        _imageArray = nil;
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = NSLocalizedString(@"ALImageView", @"title");
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"title") style:UIBarButtonItemStylePlain target:self action:@selector(didPressBarButtonItemAction:)] autorelease];
    
    if (nil == _imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    
    [self getImagesFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPressBarButtonItemAction:(id)sender
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)getImagesFromServer
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    activityView.center = self.navigationController.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    dispatch_block_t tempBlock = ^(void) {
        NSURL *url = [NSURL URLWithString:@"http://api.springox.com/app_store.php"];
        NSData *resData = [NSData dataWithContentsOfURL:url];
        
        if (0 < [resData length]) {
            NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"resDic : %@", resDic);
            for (NSDictionary *dic in [resDic objectForKey:@"images"]) {
                [_imageArray addObject:[dic objectForKey:@"preview"]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            [self.tableView reloadData];
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), tempBlock);
}

- (NSRange)rangeWithIndexPath:(NSIndexPath *)indexPath
{
    NSInteger fromIndex = ListImageViewControllerContainerImageCount*indexPath.row;
    NSInteger imageCount = (fromIndex+ListImageViewControllerContainerImageCount)<=[_imageArray count] ? ListImageViewControllerContainerImageCount : [_imageArray count]-fromIndex;
    NSRange range = {fromIndex, imageCount};
    return range;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return CellCount([_imageArray count], ListImageViewControllerContainerImageCount);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListImageCell";
    ListImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ListImageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
        ALContainerView *imageContainerView = [[[ALContainerView alloc] initWithFrame:CGRectMake(tableView.frame.size.width-110.f, 0.f, 100.f, 100.f)] autorelease];
        imageContainerView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
        imageContainerView.edgeInsets = ALContainerEdgeInsetsMake(4.f, 4.f, 4.f, 4.f);
        imageContainerView.composition = ALContainerCompositionMake(2, 2, 6.f, 6.f);
        imageContainerView.isCorner = YES;
        imageContainerView.groupPlaceholder = [UIImage imageNamed:@"img_pld"];
        [cell.contentView addSubview:imageContainerView];
        
        cell.containerView = imageContainerView;
    }
    
    // Configure the cell...
    NSRange range = [self rangeWithIndexPath:indexPath];
    [cell.containerView setImageCount:range.length groupTag:range.location];
    
    cell.textLabel.text = [NSString stringWithFormat:@"I am container! #%d-%d#", range.location+1, range.location+range.length];
    
    return cell;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListImageCell *listImageCell = (ListImageCell *)cell;
    NSRange range = [self rangeWithIndexPath:indexPath];
    listImageCell.containerView.imageURLs = [_imageArray subarrayWithRange:range];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
