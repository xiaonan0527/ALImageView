## ALImageView(图片加载器)

A ImageView Class for loading image concurrently in iOS.You only need two source files(ALImageView.h/ALImageView.m),You can reuse a image view to reload different url in a tableview cell.

一个最轻量的网络图片加载器——一个ImageView类。只需要两个源文件，将可以重用一个image view去加载不同url的图片。

![Screenshot](https://dl.dropboxusercontent.com/u/59801943/Screenshots/ALImageView.png)

Support local and memory cache;
Support place holder;
Support tap touch(target-action);
Support corner for the image view;
Support multi-image container;

支持本地和内存缓存；
支持占位图；
支持点击事件；
支持图片圆角；
支持多图容器；



### Usage(用法)

``` objective-c
        ALImageView *alImageView = [[[ALImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 100.f)] autorelease];
        alImageView.contentEdgeInsets = UIEdgeInsetsMake(3.f, 4.f, 3.f, 4.f);
        alImageView.isCorner = YES;
        [alImageView addTarget:self action:@selector(didPressImageViewAction:)];
        alImageView.placeholderImage = [UIImage imageNamed:@"placeholder"];
        alImageView.imageURL = @"image_url";
        //[alImageView loadImage:@"image_url" placeholderImage:[UIImage imageNamed:@"placeholder"]];
```

There is also a good demo in the project.
