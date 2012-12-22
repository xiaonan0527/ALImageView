//
//  ALImageView.m
//  ALImageView
//
//  Created by SpringOx on 12-8-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "ALImageView.h"

@interface ALImageView ()
{
    UIActivityIndicatorView *_activityView;
    id _target;
    SEL _action;
    NSInteger _requestCount;   //添加该计数是为了对象被复用重新加载图片的时候，旧的block能在效果上等效被cancel
}

- (UIImage *)insertBgImage:(UIImage *)bgImage toImage:(UIImage *)image;

@end

//static dispatch_queue_t imageQueue;

@implementation ALImageView

- (void)setBgImage:(UIImage *)bgImage
{
    if (nil != _bgImage) {
        [_bgImage release];
        _bgImage = nil;
    }
    
    if (nil != bgImage) {
        _bgImage = [bgImage retain];
    }
    
    self.image = _bgImage;
}

- (void)setThumbnailPath:(NSString *)thumbnailPath
{
    if (nil != _thumbnailPath) {
        self.image = nil;
        [_thumbnailPath release];
        _thumbnailPath = nil;
    }
    
    if (nil != thumbnailPath) {
        _thumbnailPath = [thumbnailPath retain];
    }
    
    if (nil != _thumbnailPath && 0 < [_thumbnailPath length]) {
        UIImage *img = [UIImage imageWithContentsOfFile:_thumbnailPath];
        if (nil != img) {
            if (nil != _bgImage) {
                self.image = [self insertBgImage:_bgImage toImage:img];
            } else {
                self.image = img;
                self.backgroundColor = [UIColor whiteColor];
            }
        }
    }
}

- (void)setLocalPath:(NSString *)localPath
{
    if (nil != _localPath) {
        self.image = nil;
        [_localPath release];
        _localPath = nil;
    }
    
    if (nil != localPath) {
        _localPath = [localPath retain];
    }
    
    if (nil != _localPath && 0 < [_localPath length]) {
        UIImage *img = [UIImage imageWithContentsOfFile:_localPath];
        if (nil != img) {
            if (nil != _bgImage) {
                self.image = [self insertBgImage:_bgImage toImage:img];
            } else {
                self.image = img;
                self.backgroundColor = [UIColor whiteColor];
            }
        }
    }
}

- (void)setRemotePath:(NSString *)remotePath
{
    if (nil != _remotePath) {
        [_remotePath release];
        _remotePath = nil;
    }
    
    if (nil != remotePath) {
        _remotePath = [remotePath retain];
    }
    
    if (nil != _remotePath && 0 < [_remotePath length]) {
        [self asyncLoadImageWithURL:[NSURL URLWithString:[_remotePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
}

- (void)setCacheDirectory:(NSString *)cacheDirectory
{
    if (nil != _cacheDirectory) {
        [_cacheDirectory release];
        _cacheDirectory = nil;
    }
    
    if (nil != cacheDirectory) {
        _cacheDirectory = [cacheDirectory retain];
    }
    
    if (nil != _cacheDirectory) {
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheDirectory isDirectory:&isDirectory] || !isDirectory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

- (void)setIsCorner:(BOOL)isCorner
{
    _isCorner = isCorner;
    if (_isCorner) {
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;
    } else {
        self.layer.cornerRadius = 0.0f;
        self.clipsToBounds = NO;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _index = -UINT_MAX;
    }
    return self;
}

- (void)dealloc
{
    self.localPath = nil;
    self.remotePath = nil;
    self.cacheDirectory = nil;
    if (nil != _activityView) {
        [_activityView stopAnimating];
        [_activityView release];
    }
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIImage *)insertBgImage:(UIImage *)bgImage toImage:(UIImage *)image
{
    CGFloat s = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(s*self.bounds.size.width, s*self.bounds.size.height);
    UIGraphicsBeginImageContext(size);
    [bgImage drawInRect:CGRectMake(0.f, 0.f, s*self.bounds.size.width, s*self.bounds.size.height)];
    [image drawInRect:CGRectMake(s*4.f, s*3.f, s*(self.bounds.size.width-8.f), s*(self.bounds.size.height-8.f))];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (void)asyncLoadImageWithURL:(NSURL *)url
{
    if (nil == _activityView) {
        if (nil == _bgImage) {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        } else {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _activityView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [self addSubview:_activityView];
    }
    [_activityView startAnimating];
    
    _requestCount++;
    dispatch_block_t loadImageBlock = ^(void) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSInteger countStamp = _requestCount;
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *remoteLastPath = [_remotePath lastPathComponent];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != data) {
                if (nil != _cacheDirectory) {
                    NSError *error = nil;
                    NSString *targetPath = [NSString stringWithFormat:@"%@/%@", _cacheDirectory, remoteLastPath];
                    [data writeToFile:targetPath options:NSDataWritingFileProtectionMask error:&error];
                    NSLog(@"asyncLoadImage targetPath:%@ error:%@", targetPath, error);
                }
                if (countStamp == _requestCount) {   //该计数是为了对象被复用重新加载图片的时候，旧的block能在效果上等效被cancel
                    UIImage *img = [UIImage imageWithData:data];
                    if (nil != _bgImage) {
                        self.image = [self insertBgImage:_bgImage toImage:img];
                    } else {
                        self.image = img;
                    }
                    _asyncLoadImageFinished = YES;
                    [_activityView stopAnimating];
                    
                    if ([_delegate respondsToSelector:@selector(alImageView:didAsynchronousLoadImage:)]) {
                        [_delegate alImageView:self didAsynchronousLoadImage:img];
                    }
                    
                    NSLog(@"asyncLoadImage finish!");
                }
            } else {
                [_activityView stopAnimating];
                NSLog(@"asyncLoadImage finish without setImage!");
            }
        });
    };
    
//    if (NULL == imageQueue) {
//        NSLog(@"create imageQueue!!!!!!!!!");
//        imageQueue = dispatch_queue_create("asynchronous_load_image", nil);
//    }
//    
//    dispatch_async(imageQueue, loadImageBlock);
    
    if (ALImageViewQueuePriorityHigh == _queuePriority) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), loadImageBlock);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loadImageBlock);
    }
}

- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGestureRecognizer:)];
    [self addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
}

- (void)didTapGestureRecognizer:(id)sender
{
    if (nil == self.image || _activityView.isAnimating) {
        return;
    }
    [_target performSelector:_action withObject:self];
}

@end
