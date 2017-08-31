//
//  ViewController.m
//  SYGCDStudy
//
//  Created by 666gps on 2017/8/31.
//  Copyright © 2017年 666gps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
}
@property (nonatomic,strong) dispatch_queue_t dispatch_serial;/**<串行队列*/
@property (nonatomic,strong) dispatch_queue_t dispatch_concurrent;/**<并行队列*/
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建两个队列
    _dispatch_serial = dispatch_queue_create("dispatch_serial", DISPATCH_QUEUE_SERIAL);
    _dispatch_concurrent = dispatch_queue_create("dispatch_concurrent", DISPATCH_QUEUE_CONCURRENT);
    
    [self serialAndSynchronize];
    [self serialAndASynchronize];
    [self concurrentAndSynchronize];
    [self concurrentAndASynchronize];
}
//串行同步队列
-(void)serialAndSynchronize{
    dispatch_sync(_dispatch_serial, ^{
        NSLog(@"1---------%@",[NSThread mainThread]);
    });
    dispatch_sync(_dispatch_serial, ^{
        NSLog(@"2---------- %@",[NSThread mainThread]);
    });
    dispatch_sync(_dispatch_serial, ^{
        NSLog(@"3---------- %@",[NSThread mainThread]);
    });
    NSLog(@"4------------ %@",[NSThread mainThread]);
}
//串行异步队列
-(void)serialAndASynchronize{
    dispatch_async(_dispatch_serial, ^{
        NSLog(@"1------------ %@",[NSThread mainThread]);
    });
    dispatch_async(_dispatch_serial, ^{
        NSLog(@"2------------ %@",[NSThread mainThread]);
    });
    dispatch_async(_dispatch_serial, ^{
        NSLog(@"3------------ %@",[NSThread mainThread]);
    });
    NSLog(@"4------------ %@",[NSThread mainThread]);
}
//并行同步队列
-(void)concurrentAndSynchronize{
    dispatch_sync(_dispatch_concurrent, ^{
        NSLog(@"1------------ %@",[NSThread mainThread]);
    });
    dispatch_sync(_dispatch_concurrent, ^{
       NSLog(@"2------------ %@",[NSThread mainThread]);
    });
    dispatch_sync(_dispatch_concurrent, ^{
        NSLog(@"3------------ %@",[NSThread mainThread]);
    });
    NSLog(@"4------------ %@",[NSThread mainThread]);
}
//并行异步队列
-(void)concurrentAndASynchronize{
    dispatch_async(_dispatch_concurrent, ^{
       NSLog(@"1------------ %@",[NSThread mainThread]);
    });
    dispatch_async(_dispatch_concurrent, ^{
       NSLog(@"2------------ %@",[NSThread mainThread]);
    });
    dispatch_async(_dispatch_concurrent, ^{
        NSLog(@"3------------ %@",[NSThread mainThread]);
    });
    NSLog(@"4------------ %@",[NSThread mainThread]);
}
//只执行一次
- (IBAction)carryOutOne:(id)sender {
    static dispatch_once_t oneDispatch;
    dispatch_once(&oneDispatch, ^{
        NSLog(@"这个方法只会执行一次");
    });
}
//重复执行
- (IBAction)recurButton:(id)sender {
    dispatch_apply(5, _dispatch_serial, ^(size_t i) {
        NSLog(@"重复执行的次数。    %ld",i);
    });
}
//延时执行
- (IBAction)afterButton:(id)sender {
    NSLog(@"延时三秒执行主线程--- 开始时间。%@",[NSDate date]);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"延时三秒执行主线程。%@",[NSDate date]);
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"延时五秒执行主线程。%@",[NSDate date]);
    });
}
//分组完成
- (IBAction)groupButton:(id)sender {
    dispatch_group_t groupDispatch = dispatch_group_create();
    __block NSInteger index_1 = 0;
    __block NSInteger index_2 = 0;
    dispatch_group_async(groupDispatch, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         dispatch_apply(10000, _dispatch_serial, ^(size_t i) {
             index_1 = index_1 + i;
        });
    });
    dispatch_group_async(groupDispatch, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_apply(2000, _dispatch_serial, ^(size_t i) {
            index_2 = index_2 + i;
        });
    });
    dispatch_group_notify(groupDispatch, dispatch_get_main_queue(), ^{
        NSLog(@"这时候的 %ld，%ld",index_1,index_2);
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
