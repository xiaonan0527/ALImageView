//
//  PreviewImageViewController.m
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "PreviewImageViewController.h"
#import "OriginalImageViewController.h"

#define PageCount(t_num, p_num)  (t_num%p_num ? (t_num/p_num+1) : t_num/p_num)
#define PreviewImageViewControllerContainerImageCount      (AL_CONTAINER_VIEW_COLUMN_COUNT*AL_CONTAINER_VIEW_ROW_COUNT)

@interface PreviewImageViewController ()
{
    NSMutableArray *_containerViews;
    NSMutableArray *_imagePaths;
    NSInteger _fromIndex;
}

- (NSInteger)calculateCurrentPageIndex;
- (NSInteger)calculateNextPageIndex;
- (void)reloadRemoteImages:(NSInteger)index;
- (void)reloadRemoteImages:(ALContainerView *)containerView index:(NSInteger)index;

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
    if (nil != _imagePaths) {
        [_imagePaths release];
        _imagePaths = nil;
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"title") style:UIBarButtonItemStylePlain target:self action:@selector(didPressBarButtonItemAction:)] autorelease];
    
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(3*_scrollView.bounds.size.width, _scrollView.bounds.size.height);
    _scrollView.contentOffset = CGPointMake(_scrollView.bounds.size.width, 0.f);
    
    if (nil == _imagePaths) {
        _imagePaths = [[NSMutableArray alloc] init];
        _fromIndex = -PreviewImageViewControllerContainerImageCount;
    }
    
    [self getImagePathsFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"%s self retain count %d self.navigationController retain count %d", __FUNCTION__, [self retainCount], [self.navigationController retainCount]);
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
    
    NSLog(@"%s self retain count %d self.navigationController retain count %d imagepaths  retain count %d", __FUNCTION__, [self retainCount], [self.navigationController retainCount], [_imagePaths retainCount]);
}

- (void)getImagePathsFromServer
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    activityView.center = self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    NSMutableArray *blockPaths = _imagePaths;
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
                [blockPaths addObject:imgDic];
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
    if (0 == [_imagePaths count]) {
        return;
    }
    
    CGRect bounds = self.view.bounds;
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    NSLog(@"%s previewcontrollerself  retain count %d self.navigationController retain count %d", __FUNCTION__, [self retainCount], [self.navigationController retainCount]);
    
    // It will lead to retain cycles!!!
//    CSelectIndexBlock block = ^(ALContainerView *icView, NSInteger index) {
//        NSLog(@"block didSelectIndex:%d", icView.fromIndex+index);
//        OriginalImageViewController *originalImageVC = [[OriginalImageViewController alloc] init];
//        NSDictionary *dic = [(__unsafe_unretained id)_imagePaths objectAtIndex:icView.fromIndex+index];
//        originalImageVC.path = [dic objectForKey:@"RemoteOriginal"];
//        [(__unsafe_unretained id)self.navigationController pushViewController:originalImageVC animated:YES];
//        [originalImageVC release];
//    };
    
    if (nil == _containerViews) {
        _containerViews = [[NSMutableArray alloc] init];
    }

    int tempCount = [_containerViews count];
    for (int i=0; i<PageCount([_imagePaths count], PreviewImageViewControllerContainerImageCount); i++) {
        ALContainerView *imageContainerView = nil;
        if (tempCount > i) {
            imageContainerView = [[_containerViews objectAtIndex:i] retain];
        } else {
            imageContainerView = [[ALContainerView alloc] initWithFrame:CGRectMake(i*width+x, y, width, height)];
//            [imageContainerView setSelectIndexBlock:block];
            imageContainerView.delegate = self;
            [_containerViews addObject:imageContainerView];
            [_scrollView addSubview:imageContainerView];
        }
        [imageContainerView release];
    }
    for (int i=0; i<[_containerViews count]; i++) {
        ALContainerView *imageContainerView = [_containerViews objectAtIndex:i];
        if (PageCount([_imagePaths count], PreviewImageViewControllerContainerImageCount) > i) {
            imageContainerView.tag = 1;
        } else {
            imageContainerView.tag = -1;
        }
    }
    
    for (ALContainerView *imageContainerView in _containerViews) {
        if (imageContainerView.tag == 1) {
            imageContainerView.hidden = NO;
        } else {
            imageContainerView.hidden = YES;
        }
    }
    _scrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    _scrollView.contentSize = CGSizeMake(PageCount([_imagePaths count], PreviewImageViewControllerContainerImageCount)*bounds.size.width, bounds.size.height);
    _scrollView.contentOffset = CGPointMake(0.f, 0.f);
    [self updatePageNumber];   //更新翻页的数字
    
    int i = 0;
    for (ALContainerView *imageContainerView in _containerViews) {
        if (1 == imageContainerView.tag) {
            NSInteger index = i*PreviewImageViewControllerContainerImageCount;
            if (index+PreviewImageViewControllerContainerImageCount >= [_imagePaths count]) {
                [imageContainerView setImageCount:[_imagePaths count]-index fromIndex:index];
            } else {
                [imageContainerView setImageCount:PreviewImageViewControllerContainerImageCount fromIndex:index];
            }
            i++;
        }
    }
    
    [self reloadContainerViews:_fromIndex];
}

- (void)reloadContainerViews:(NSInteger)fromIndex
{
    NSInteger leftIndex = fromIndex;
    NSAssert(-PreviewImageViewControllerContainerImageCount <= leftIndex, @"-PreviewImageViewControllerContainerImageCount <= leftIndex error!");
    if (0 <= leftIndex) {   //显示第一屏的左边不用加载
        [self reloadRemoteImages:leftIndex];
    }
    
    NSInteger centerIndex = [self calculateCurrentPageIndex];
    NSAssert(0 <= centerIndex, @"0 <= centerIndex error!");
    [self reloadRemoteImages:centerIndex];
    
    NSInteger rightIndex = [self calculateNextPageIndex];
    NSAssert(PreviewImageViewControllerContainerImageCount <= rightIndex, @"PreviewImageViewControllerContainerImageCount <= rightIndex error!");
    if ([_imagePaths count] > rightIndex) {   //显示最后一屏的右边不用加载
        [self reloadRemoteImages:rightIndex];
    }
    
    [self updatePageNumber];   //更新翻页的数字
}

- (void)reloadRemoteImages:(NSInteger)index
{
    ALContainerView *containerView = [_containerViews objectAtIndex:index/PreviewImageViewControllerContainerImageCount];
    if (index == containerView.fromIndex && nil != containerView.remotePaths) {
        return;
    }
    [self reloadRemoteImages:containerView index:index];
}

- (void)reloadRemoteImages:(ALContainerView *)containerView index:(NSInteger)index
{
    if (0 == containerView.imageCount) {
        return;
    }
    NSMutableArray *remotePaths = [NSMutableArray array];
    NSInteger mixIndex = containerView.fromIndex;
    NSInteger maxIndex = containerView.fromIndex+containerView.imageCount;
    NSAssert(0 <= mixIndex, @"mixIndex error!");
    NSAssert([_imagePaths count] >= maxIndex, @"maxIndex error!");
    NSLog(@"mixIndex:%d maxIndex:%d", mixIndex, maxIndex);
    for (int i=mixIndex; i<maxIndex; i++) {
        NSDictionary *d = [_imagePaths objectAtIndex:i];
        NSString *remotePreview = [d objectForKey:@"RemotePreview"];
        [remotePaths addObject:remotePreview];
    }
    containerView.remotePaths = remotePaths;
}

- (void)updatePageNumber
{
    int currentPage = PageCount([self calculateNextPageIndex], PreviewImageViewControllerContainerImageCount);
    int totalPage = PageCount([_imagePaths count], PreviewImageViewControllerContainerImageCount);
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
    NSLog(@"didSelectIndex:%d", cView.fromIndex+index);
    OriginalImageViewController *originalImageVC = [[OriginalImageViewController alloc] init];
    NSDictionary *dic = [_imagePaths objectAtIndex:cView.fromIndex+index];
    originalImageVC.path = [dic objectForKey:@"RemoteOriginal"];
    [self.navigationController pushViewController:originalImageVC animated:YES];
    [originalImageVC release];
}

@end
