//
//  LThreadNotificationViewController.m
//  Learn
//
//  Created by 刘宪威 on 2019/5/20.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import "LThreadNotificationViewController.h"

@interface LThreadNotificationModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end

@implementation LThreadNotificationModel

- (void)setName:(NSString *)name {
    _name = name;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationKey" object:nil];
 
    NSLog(@"change name, thread = %@", [NSThread currentThread].name);
}

- (void)setAge:(NSInteger)age {
    _age = age;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationKey" object:nil];
    
    NSLog(@"change age, thread = %@", [NSThread currentThread].name);
}

@end

@interface LThreadNotificationViewController ()

@property (nonatomic, strong) LThreadNotificationModel *model;

@end

@implementation LThreadNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _model = [[LThreadNotificationModel alloc] init];
    _model.name = @"jack";
    _model.age = 1;
    
    __weak __typeof(self) weakSelf = self;
    NSThread *thread0 = [[NSThread alloc] initWithBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeName) name:@"notificationKey" object:nil];
    }];
    [thread0 setName:@"thread0"];
    [thread0 start];
    
    sleep(2);
    
    NSThread *thread1 = [[NSThread alloc] initWithBlock:^{
        weakSelf.model.name = @"jeff";
    }];
    [thread1 setName:@"thread1"];
    [thread1 start];

    NSThread *thread2 = [[NSThread alloc] initWithBlock:^{
        weakSelf.model.age = 2;
    }];
    [thread2 setName:@"thread2"];
    [thread2 start];
}

- (void)changeName {
    NSLog(@"received noti, thread = %@", [NSThread currentThread].name);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
