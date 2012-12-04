//
//  PreviewImageViewController.m
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "PreviewImageViewController.h"
#import "ALContainerView.h"
#import "OriginalImageViewController.h"

#define PageCount(t_num, p_num)  (t_num%p_num ? (t_num/p_num+1) : t_num/p_num)
#define PreviewImageViewControllerContainerImageCount      (ALContainerViewColumnCount+ALContainerViewRowCount)

@interface PreviewImageViewController ()
{
    NSMutableArray *_containerViews;
    
    NSMutableArray *_imagePaths;
    NSInteger _fromIndex;
}

- (NSInteger)calculateCurrentPageIndex;
- (NSInteger)calculateNextPageIndex;
- (void)loadLocalImages:(ALContainerView *)containerView index:(NSInteger)index;
- (void)setContainerViewCount:(NSInteger)index;
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

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getImagePathsFromServer];
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

- (void)getImagePathsFromServer
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_block_t tempBlock = ^(void) {
        
        //http request
        
        for (int i=0; i<15; i++) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"http://allseeing-i.com/ASIHTTPRequest/tests/images/small-image.jpg", @"RemotePreview",
                                 @"http://allseeing-i.com/ASIHTTPRequest/tests/images/large-image.jpg", @"RemoteOriginal",
                                 nil];
            [_imagePaths addObject:dic];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    CSelectIndexBlock block = ^(ALContainerView *icView, NSInteger index) {
        NSLog(@"block didSelectIndex:%d", icView.fromIndex+index);
        OriginalImageViewController *originalImageVC = [[OriginalImageViewController alloc] init];
        NSDictionary *dic = [_imagePaths objectAtIndex:index];
        NSString *tempPath = [dic objectForKey:@"RemotePreview"];
        originalImageVC.thumbnailPath = [ALImageViewCacheDirectoryForDemo stringByAppendingFormat:@"/%@", [tempPath lastPathComponent]];
        tempPath = [dic objectForKey:@"RemoteOriginal"];
//        originalImageVC.localPath = [ALImageViewCacheDirectoryForDemo stringByAppendingFormat:@"/%@", [tempPath lastPathComponent]];
        originalImageVC.remotePath = tempPath;
        [self.navigationController pushViewController:originalImageVC animated:YES];
        [originalImageVC release];
    };
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
            [imageContainerView setSelectIndexBlock:block];
            [_containerViews addObject:imageContainerView];
            [_scrollView addSubview:imageContainerView];
        }
        imageContainerView.localPaths = nil;
        imageContainerView.remotePaths = nil;
        [imageContainerView release];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i=0; i<[_containerViews count]; i++) {
            ALContainerView *imageContainerView = [_containerViews objectAtIndex:i];
            if (PageCount([_imagePaths count], PreviewImageViewControllerContainerImageCount) > i) {
                imageContainerView.hidden = NO;
            } else {
                imageContainerView.hidden = YES;
            }
        }
        
        _scrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
        _scrollView.contentSize = CGSizeMake(PageCount([_imagePaths count], PreviewImageViewControllerContainerImageCount)*bounds.size.width, bounds.size.height);
        _scrollView.contentOffset = CGPointMake(0.f, 0.f);
        
        [self updatePageNumber];   //更新翻页的数字
    });
    
    int i = 0;
    for (ALContainerView *imageContainerView in _containerViews) {
        if (!imageContainerView.hidden) {
            [self loadLocalImages:imageContainerView index:i*PreviewImageViewControllerContainerImageCount];
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
        [self setContainerViewCount:leftIndex];
    }
    
    NSInteger centerIndex = [self calculateCurrentPageIndex];
    NSAssert(0 <= centerIndex, @"0 <= centerIndex error!");
    [self setContainerViewCount:centerIndex];
    
    NSInteger rightIndex = [self calculateNextPageIndex];
    NSAssert(PreviewImageViewControllerContainerImageCount <= rightIndex, @"PreviewImageViewControllerContainerImageCount <= rightIndex error!");
    if ([_imagePaths count] > rightIndex) {   //显示最后一屏的右边不用加载
        [self setContainerViewCount:rightIndex];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updatePageNumber];   //更新翻页的数字
    });
}

- (void)loadLocalImages:(ALContainerView *)containerView index:(NSInteger)index
{
    if (index+PreviewImageViewControllerContainerImageCount >= [_imagePaths count]) {
        [containerView setImageCount:[_imagePaths count]-index fromIndex:index];
    } else {   //大于三屏时fromIndex为变量
        [containerView setImageCount:PreviewImageViewControllerContainerImageCount fromIndex:index];
    }
    
    if (0 == containerView.imageCount) {
        return;
    }
    NSMutableArray *localPaths = [NSMutableArray array];
    NSInteger mixIndex = containerView.fromIndex;
    NSInteger maxIndex = containerView.fromIndex+containerView.imageCount;
    NSAssert(0 <= mixIndex, @"mixIndex error!");
    NSAssert([_imagePaths count] >= maxIndex, @"maxIndex error!");
    NSLog(@"mixIndex:%d maxIndex:%d", mixIndex, maxIndex);
    for (int i=mixIndex; i<maxIndex; i++) {
        NSDictionary *d = [_imagePaths objectAtIndex:i];
        NSString *localPreview = [d objectForKey:@"LocalPreview"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localPreview]) {
            [localPaths addObject:localPreview];
        } else {
            [localPaths addObject:@""];
        }
    }
    NSLog(@"localPaths:%@", localPaths);
    containerView.localPaths = localPaths;
}

- (void)setContainerViewCount:(NSInteger)index
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
        NSString *localPreview = [d objectForKey:@"LocalPreview"];
        NSString *remotePreview = [d objectForKey:@"RemotePreview"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localPreview]) {
            [remotePaths addObject:@""];
        } else {
            [remotePaths addObject:remotePreview];
        }
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

@end
