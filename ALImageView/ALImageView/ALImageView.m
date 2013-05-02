//
//  ALImageView.m
//  ALImageView
//
//  Created by SpringOx on 12-8-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "ALImageView.h"

@interface ALImageCache : NSCache

+ (ALImageCache *)sharedInstance;

- (UIImage *)cachedImageForRemotePath:(NSString *)path;

- (void)cacheImage:(UIImage *)image forRemotePath:(NSString *)path;

@end

@implementation ALImageCache

+ (ALImageCache *)sharedInstance {
    static ALImageCache *_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _imageCache = [[ALImageCache alloc] init];
    });
    return _imageCache;
}

- (UIImage *)cachedImageForRemotePath:(NSString *)path
{
	return [self objectForKey:path];
}

- (void)cacheImage:(UIImage *)image forRemotePath:(NSString *)path
{
    if (image && path) {
        [self setObject:image forKey:path];
    }
}

@end


@interface ALImageView ()
{
    UIActivityIndicatorView *_activityView;
    id _target;
    SEL _action;
    NSInteger _requestCount;   //添加该计数是为了对象被复用重新加载图片的时候，旧的block能在效果上等效被cancel
}

- (UIImage *)insertBgImage:(UIImage *)bgImage toImage:(UIImage *)image;

@end

@implementation ALImageView

- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    if (_placeholderImage == placeholderImage) {
        return;
    }
    
    if (nil != _placeholderImage) {
        [_placeholderImage release];
        _placeholderImage = nil;
    }
    
    if (nil != placeholderImage) {
        _placeholderImage = [placeholderImage retain];
    }
    
    self.image = _placeholderImage;
}

- (void)setRemotePath:(NSString *)remotePath
{
    if (_remotePath == remotePath) {
        return;
    }
    
    if (nil != _remotePath) {
        [_remotePath release];
        _remotePath = nil;
    }
    
    if (nil != remotePath) {
        _remotePath = [remotePath retain];
    }
    
    if (0 < [_remotePath length]) {
        UIImage *img = [[ALImageCache sharedInstance] cachedImageForRemotePath:_remotePath];
        if (nil != img) {
            if (nil != _placeholderImage) {
                self.image = [self insertBgImage:_placeholderImage toImage:img];
            } else {
                self.image = img;
                self.backgroundColor = [UIColor whiteColor];
            }
            NSLog(@"load cache image!");
            return;
        }
        NSString *imgCachePath = [[ALImageView localDirectory] stringByAppendingPathComponent:[_remotePath lastPathComponent]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imgCachePath]) {
            UIImage *img = [UIImage imageWithContentsOfFile:imgCachePath];
            if (nil != _placeholderImage) {
                self.image = [self insertBgImage:_placeholderImage toImage:img];
            } else {
                self.image = img;
                self.backgroundColor = [UIColor whiteColor];
            }
            [[ALImageCache sharedInstance] cacheImage:img forRemotePath:_remotePath];
            NSLog(@"load local image!");
            return;
        }
        [self asyncLoadImageWithURL:[NSURL URLWithString:[_remotePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
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

+ (NSString *)localDirectory
{    
    static NSString *_localDirectory = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        if (0 < [cachesPath length]) {
            _localDirectory = [[cachesPath stringByAppendingPathComponent:@"ALImages"] retain];
            
            BOOL isDirectory = YES;
            if (![[NSFileManager defaultManager] fileExistsAtPath:_localDirectory isDirectory:&isDirectory] || !isDirectory) {
                NSError *error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:_localDirectory withIntermediateDirectories:YES attributes:nil error:&error];
            }
        }
        NSLog(@"localDirectory %@", _localDirectory);
    });
    return _localDirectory;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _index = -UINT_MAX;
        _queuePriority = ALImageViewQueuePriorityHigh;
    }
    return self;
}

- (void)dealloc
{
    self.remotePath = nil;
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
        if (nil == _placeholderImage) {
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != data) {
                NSString *targetPath = [[ALImageView localDirectory] stringByAppendingPathComponent:[[url absoluteString] lastPathComponent]];
                NSError *error = nil;
                [data writeToFile:targetPath options:NSDataWritingFileProtectionMask error:&error];
                NSLog(@"asyncLoadImage targetPath:%@ error:%@", targetPath, error);
                if (countStamp == _requestCount) {   //该计数是为了对象被复用重新加载图片的时候，旧的block能在效果上等效被cancel
                    UIImage *img = [UIImage imageWithData:data];
                    if (nil != _placeholderImage) {
                        self.image = [self insertBgImage:_placeholderImage toImage:img];
                    } else {
                        self.image = img;
                    }
                    _asyncLoadImageFinished = YES;
                    [_activityView stopAnimating];
                    
                    if ([_delegate respondsToSelector:@selector(imageView:didAsynchronousLoadImage:)]) {
                        [_delegate imageView:self didAsynchronousLoadImage:img];
                    }
                    
                    [[ALImageCache sharedInstance] cacheImage:img forRemotePath:[url absoluteString]];
                    
                    NSLog(@"asyncLoadImage finish!");
                }
            } else {
                [_activityView stopAnimating];
                NSLog(@"asyncLoadImage finish without setImage!");
            }
        });
    };
    
    if (ALImageViewQueuePriorityHigh == _queuePriority) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), loadImageBlock);
    } else if (ALImageViewQueuePriorityNormal == _queuePriority) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loadImageBlock);
    } else {
        static dispatch_queue_t imageQueue = NULL;
        
        if (NULL == imageQueue) {
            imageQueue = dispatch_queue_create("asynchronous_load_image", nil);
        }
        dispatch_async(imageQueue, loadImageBlock);
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
