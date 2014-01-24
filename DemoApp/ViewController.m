//
//  ViewController.m
//  DemoApp
//
//  Created by taiki on 1/23/14.
//  Copyright (c) 2014 taiki. All rights reserved.
//

#import "ViewController.h"

#import "YSPagingView.h"

@interface ViewController () <YSPagingViewDataSource>
@property (strong, nonatomic) IBOutlet YSPagingView *pagingView;

@property (strong, nonatomic) NSArray *dummyPages;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pagingView.dataSource = self;
    _pagingView.rightInset = 30;
    _pagingView.pagingSpace = 20;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSArray *)dummyPages
{
    if (!_dummyPages) {
        NSMutableArray *a = NSMutableArray.new;
        for (int i = 0; i < 3; ++i) {
            UIView *v =
                [[UIView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(_pagingView.bounds) - 30, 220)];
            v.backgroundColor = [UIColor colorWithHue:arc4random_uniform(255)/255.0 saturation:1 brightness:1 alpha:1];
            [a addObject:v];
        }
        _dummyPages = [a copy];
    }
    return _dummyPages;
}

#pragma mark - YSPagingViewDataSource

- (NSUInteger)numberOfPagesInPagingView:(YSPagingView *)pagingView
{
    return self.dummyPages.count;
}

- (UIView *)pagingView:(YSPagingView *)pagingView pageViewOfIndex:(NSUInteger)index
{
    return index < self.dummyPages.count ? self.dummyPages[index] : nil;
}

@end
