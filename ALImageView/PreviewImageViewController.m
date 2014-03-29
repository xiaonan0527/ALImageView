//
//  PreviewImageViewController.m
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//
//  Contact:jiachunke@gmail.com
//

#import "PreviewImageViewController.h"
#import "OriginalImageViewController.h"

#define PageCount(t_num, p_num)  (t_num%p_num ? (t_num/p_num+1) : t_num/p_num)
#define PreviewImageViewControllerContainerImageCount     6

@interface PreviewImageViewController ()
{
    NSMutableArray *_containerViews;
    NSMutableArray *_imageInfos;
    NSInteger _fromIndex;
}

- (NSInteger)calculateCurrentPageIndex;
- (NSInteger)calculateNextPageIndex;
- (void)reloadImages:(NSInteger)index;
- (void)reloadImages:(ALContainerView *)containerView index:(NSInteger)index;

@end

@implementation PreviewImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.scrollView = nil;
    self.pageNumLabel = nil;
    if (nil != _containerViews) {
        [_containerViews release];
        _containerViews = nil;
    }
    if (nil != _imageInfos) {
        [_imageInfos release];
        _imageInfos = nil;
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Preview", @"title");
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"title") style:UIBarButtonItemStylePlain target:self action:@selector(didPressBarButtonItemAction:)] autorelease];
    
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(3*_scrollView.bounds.size.width, _scrollView.bounds.size.height);
    _scrollView.contentOffset = CGPointMake(_scrollView.bounds.size.width, 0.f);
    
    if (nil == _imageInfos) {
        _imageInfos = [[NSMutableArray alloc] init];
        _fromIndex = -PreviewImageViewControllerContainerImageCount;
    }
    
    [self getImageInfosFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"%s self retain count %d; self.navigationController retain count %d;", __FUNCTION__, [self retainCount], [self.navigationController retainCount]);
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
    
    NSLog(@"%s self retain count %d; self.navigationController retain count %d; imagepaths  retain count %d;", __FUNCTION__, [self retainCount], [self.navigationController retainCount], [_imageInfos retainCount]);
}

- (void)getImageInfosFromServer
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
                NSDictionary *imgDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [dic objectForKey:@"preview"], @"RemotePreview",
                                        [dic objectForKey:@"original"], @"RemoteOriginal", nil];
                [_imageInfos addObject:imgDic];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            [self layoutContainerViews];
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), tempBlock);
}

- (NSInteger)calculateCurrentPageIndex
{
    return _fromIndex+PreviewImageViewControllerContainerImageCount;
}

- (NSInteger)calculateNextPageIndex
{
    return _fromIndex+2*PreviewImageViewControllerContainerImageCount;
}

- (void)layoutContainerViews
{
    if (0 == [_imageInfos count]) {
        return;
    }
    
    CGRect bounds = self.view.bounds;
    CGFloat x = 10.f;
    CGFloat y = 10.f;
    CGFloat width = bounds.size.width-20.f;
    CGFloat height = bounds.size.height-40.f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        y += self.navigationController.navigationBar.frame.size.height+20.f;
        height -= self.navigationController.navigationBar.frame.size.height+20.f;
    }

    NSLog(@"%s previewcontrollerself  retain count %d; self.navigationController retain count %d;", __FUNCTION__, [self retainCount], [self.navigationController retainCount]);
    /*
    // It will lead to retain cycles!!!
    CSelectIndexBlock block = ^(ALContainerView *icView, NSInteger index) {
        NSLog(@"block didSelectIndex:%d", icView.fromIndex+index);
        OriginalImageViewController *originalImageVC = [[OriginalImageViewController alloc] init];
        NSDictionary *dic = [(__unsafe_unretained id)_imageInfos objectAtIndex:icView.fromIndex+index];
        originalImageVC.path = [dic objectForKey:@"RemoteOriginal"];
        [(__unsafe_unretained id)self.navigationController pushViewController:originalImageVC animated:YES];
        [originalImageVC release];
    };
     */

    // Create container group.
    if (nil == _containerViews) {
        _containerViews = [[NSMutableArray alloc] init];
    }
    int tempCount = [_containerViews count];
    for (int i=0; i<PageCount([_imageInfos count], PreviewImageViewControllerContainerImageCount); i++) {
        ALContainerView *imageContainerView = nil;
        if (tempCount > i) {
            imageContainerView = [[_containerViews objectAtIndex:i] retain];
        } else {
            imageContainerView = [[ALContainerView alloc] initWithFrame:CGRectMake(i*bounds.size.width+x, y, width, height)];
            imageContainerView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
            imageContainerView.edgeInsets = ALContainerEdgeInsetsMake(24.f, 22.f, 24.f, 22.f);
            CGFloat gapX = 20;
            CGFloat itemWidth = ceil((width-2*imageContainerView.edgeInsets.left-gapX)/2);
            CGFloat gapY = ceil((height-2*imageContainerView.edgeInsets.top-3*itemWidth)/2);
            imageContainerView.composition = ALContainerCompositionMake(2, 3, gapX, gapY);
            imageContainerView.isCorner = YES;
            imageContainerView.delegate = self;
            //[imageContainerView setSelectIndexBlock:block];
            [_containerViews addObject:imageContainerView];
            [_scrollView addSubview:imageContainerView];
        }
        [imageContainerView release];
    }
    for (int i=0; i<[_containerViews count]; i++) {
        ALContainerView *imageContainerView = [_containerViews objectAtIndex:i];
        if (PageCount([_imageInfos count], PreviewImageViewControllerContainerImageCount) > i) {
            imageContainerView.tag = 1;
        } else {
            imageContainerView.tag = -1;
        }
    }
    
    // Set views status for layout.
    for (ALContainerView *imageContainerView in _containerViews) {
        if (imageContainerView.tag == 1) {
            imageContainerView.hidden = NO;
        } else {
            imageContainerView.hidden = YES;
        }
    }
    _scrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    _scrollView.contentSize = CGSizeMake(PageCount([_imageInfos count], PreviewImageViewControllerContainerImageCount)*bounds.size.width, bounds.size.height);
    _scrollView.contentOffset = CGPointMake(0.f, 0.f);
    [self updatePageNumber];
    
    // Set image count for container.
    int i = 0;
    for (ALContainerView *imageContainerView in _containerViews) {
        if (1 == imageContainerView.tag) {
            NSInteger index = i*PreviewImageViewControllerContainerImageCount;
            if (index+PreviewImageViewControllerContainerImageCount >= [_imageInfos count]) {
                [imageContainerView setImageCount:[_imageInfos count]-index groupTag:index];
            } else {
                [imageContainerView setImageCount:PreviewImageViewControllerContainerImageCount groupTag:index];
            }
            i++;
        }
    }
    
    // Reload images for container.
    [self reloadContainerViews:_fromIndex];
}

- (void)reloadContainerViews:(NSInteger)fromIndex
{
    NSInteger leftIndex = fromIndex;
    NSAssert(-PreviewImageViewControllerContainerImageCount <= leftIndex, @"-PreviewImageViewControllerContainerImageCount <= leftIndex error!");
    if (0 <= leftIndex) {   // Display the first screen of the left do not have to reload images
        [self reloadImages:leftIndex];
    }
    
    NSInteger centerIndex = [self calculateCurrentPageIndex];
    NSAssert(0 <= centerIndex, @"0 <= centerIndex error!");
    [self reloadImages:centerIndex];
    
    NSInteger rightIndex = [self calculateNextPageIndex];
    NSAssert(PreviewImageViewControllerContainerImageCount <= rightIndex, @"PreviewImageViewControllerContainerImageCount <= rightIndex error!");
    if ([_imageInfos count] > rightIndex) {   // Display the first screen of the left do not
                                              // have to reload images
        [self reloadImages:rightIndex];
    }
    
    [self updatePageNumber];
}

- (void)reloadImages:(NSInteger)index
{
    ALContainerView *containerView = [_containerViews objectAtIndex:index/PreviewImageViewControllerContainerImageCount];
    if (index == containerView.groupTag && nil != containerView.imageURLs) {
        return;
    }
    [self reloadImages:containerView index:index];
}

- (void)reloadImages:(ALContainerView *)containerView index:(NSInteger)index
{
    if (0 == [containerView.imageViews count]) {
        return;
    }
    NSMutableArray *imageURLs = [NSMutableArray array];
    NSInteger mixIndex = containerView.groupTag;
    NSInteger maxIndex = containerView.groupTag+[containerView.imageViews count];
    NSAssert(0 <= mixIndex, @"mixIndex error!");
    NSAssert([_imageInfos count] >= maxIndex, @"maxIndex error!");
    NSLog(@"mixIndex:%d maxIndex:%d", mixIndex, maxIndex);
    for (int i=mixIndex; i<maxIndex; i++) {
        NSDictionary *d = [_imageInfos objectAtIndex:i];
        NSString *remotePreview = [d objectForKey:@"RemotePreview"];
        [imageURLs addObject:remotePreview];
    }
    containerView.imageURLs = imageURLs;
}

- (void)updatePageNumber
{
    int currentPage = PageCount([self calculateNextPageIndex], PreviewImageViewControllerContainerImageCount);
    int totalPage = PageCount([_imageInfos count], PreviewImageViewControllerContainerImageCount);
    if (0 == totalPage) {
        _pageNumLabel.text = @"";
        _pageNumLabel.hidden = YES;
    } else {
        _pageNumLabel.text = [NSString stringWithFormat:@"%d/%d", currentPage, totalPage];
        _pageNumLabel.hidden = NO;
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollView.contentOffset.x:%f", scrollView.contentOffset.x);
    NSInteger newIndex = scrollView.contentOffset.x/self.view.bounds.size.width;
    if ([self calculateCurrentPageIndex]/PreviewImageViewControllerContainerImageCount != newIndex) {
        _fromIndex = (newIndex-1)*PreviewImageViewControllerContainerImageCount;
        [self reloadContainerViews:_fromIndex];
        NSLog(@"scroll to _fromIndex:%d", _fromIndex);
    } else {
        // do nothing
    }
}

#pragma mark -
#pragma mark ALContainerViewDelegate

- (void)containerView:(ALContainerView *)cView didSelectIndex:(NSInteger)index
{
    NSLog(@"didSelectIndex:%d", cView.groupTag+index);
    OriginalImageViewController *originalImageVC = [[OriginalImageViewController alloc] init];
    NSDictionary *dic = [_imageInfos objectAtIndex:cView.groupTag+index];
    originalImageVC.url = [dic objectForKey:@"RemoteOriginal"];
    [self.navigationController pushViewController:originalImageVC animated:YES];
    [originalImageVC release];
}

@end
