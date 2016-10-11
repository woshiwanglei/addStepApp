//
//  ViewController.m
//  计步器控制
//
//  Created by wanglei on 16/9/26.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>
#import "SVProgressHUD.h"

@interface ViewController ()
{
    HKHealthStore *healthStore;
    HKQuantityType *quantityTypeIdentifier;
}
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //2初始化 HKHealthStore
    healthStore = [[HKHealthStore alloc] init];
    //3创建步数类型
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *writeDataTypes = [NSSet setWithObjects:stepCountType,  nil];
    NSSet *readDataTypes = [NSSet setWithObjects:stepCountType,  nil];
    //发出具体的请求许可
    [healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
        if (!success) {
            //失败了
            [SVProgressHUD showErrorWithStatus:@"请求许可失败"];
            return;
        }
    }];
    //4 设置步数并且保存
    //数据看类型为步数.
    quantityTypeIdentifier = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
}

- (IBAction)clickToSureButton:(id)sender {
    if ( _textField.text.length == 0 ) {
        [SVProgressHUD showErrorWithStatus:@"请输入要增加的步数"];
        return;
    }
    [self addStepWithNumber:[_textField.text doubleValue]];
    _textField.text = nil;
}

- (void)addStepWithNumber:(double)stepNum{
    //表示步数的数据单位的数量
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:stepNum];
    
    //数量样本.
    HKQuantitySample *temperatureSample = [HKQuantitySample quantitySampleWithType:quantityTypeIdentifier quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
    
    //保存
    [healthStore saveObject:temperatureSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"保存步数成功"];
            //保存的时间较长，有0.3秒左右（加的步数越多，时间越长，长的时候有接近1秒钟），所以造成了不能连续点击，所以连续点时有点卡顿
#warning 为何不能在这写：tempSelf.textField.text = nil???
        }else {
            [SVProgressHUD showSuccessWithStatus:@"保存步数失败"];
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
