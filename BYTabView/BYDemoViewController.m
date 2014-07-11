//
//  BYDemoViewController.m
//  BYTabView
//
//  Created by booy on 14/7/10.
//  Copyright (c) 2014年 BYOS. All rights reserved.
//

#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#import "BYDemoViewController.h"

@interface BYDemoViewController ()
@end

@implementation BYDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"BYTabView Demo";
    
    BYTabView *tabView1 = [[BYTabView alloc] initWithFrame:CGRectMake(0, 0, 320.f, 80.f) titleViewFrame:CGRectMake(0, 60.f, 320.f, 20.f) edgeInsets:UIEdgeInsetsZero];
    tabView1.tag = 1;
    tabView1.dataSource = self;
    tabView1.playInterval = 3;
    [self.view addSubview:tabView1];
    
//    BYTabView *tabView2 = [[BYTabView alloc] initWithFrame:CGRectMake(0, 90.f, 320.f, 80.f) titleViewFrame:CGRectMake(0, 78.f, 320.f, 2.f) edgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
//    tabView2.titleCellSize = CGSizeMake(320 / 4, 2);
//    tabView2.tag = 2;
//    tabView2.dataSource = self;
//    [self.view addSubview:tabView2];
//    
//    BYTabView *tabView3 = [[BYTabView alloc] initWithFrame:CGRectMake(0, 180.f, 320.f, 80.f) titleViewFrame:CGRectMake(0, 0, 320.f, 18.f) edgeInsets:UIEdgeInsetsMake(18, 0, 0, 0)];
//    tabView3.titleCellSize = CGSizeMake(320 / 4, 18);
//    tabView3.tag = 3;
//    tabView3.dataSource = self;
//    [self.view addSubview:tabView3];
//    
//    BYTabView *tabView4 = [[BYTabView alloc] initWithFrame:CGRectMake(0, 270.f, 320.f, 80.f) titleViewFrame:CGRectMake(0, 0, 40.f, 80.f) edgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
//    tabView4.titleCellSize = CGSizeMake(40, 80 / 4);
//    tabView4.tag = 4;
//    tabView4.dataSource = self;
//    [self.view addSubview:tabView4];

}

- (CGFloat)gapOfTitleCellsInTabView:(BYTabView *)tabView
{
    if (tabView.tag == 1) {
        return 10.f;
    }
    return 0.f;
}

- (BYTabCell *)tabView:(BYTabView *)tabView titleCellForIndex:(NSInteger)index
{
    if (tabView.tag == 3) {
        BYTabCell *cell = [[BYTabCell alloc] init];

        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 0, 80.f, 18.f);
        label.textAlignment = NSTextAlignmentCenter;
        
        NSArray *titles = @[@"Home", @"Search", @"List", @"More"];
        
        label.text = titles[index];
        
        if (tabView.currentIndex == index) {
            label.textColor = UIColorFromHex(0xF35A4A);
        }else{
            label.textColor = UIColorFromHex(0x666666);
        }
        
        [cell addSubview:label];
        return cell;
    }else{
        return nil;
    }
}

- (NSInteger)numberOfTabsInTabView:(BYTabView *)tabView
{
    return 4;
}

- (BYTabCell *)tabView:(BYTabView *)tabView contentCellForIndex:(NSInteger)index
{
    static NSString *identifer = @"BYTabContentCellIdentifer";
    
    BYTabCell *cell = [tabView dequeueReusableContentCellWithIdentifier:identifer];
    
    if (cell == nil) {
        cell = [[BYTabCell alloc] initWithReuseIdentifier:identifer];
    }
    
    NSArray *colors = @[@0xF7C6C7, @0xBDB791, @0xFFEF94, @0xB7BA68, @0xC0D6BF, @0xF09476, @0xEDBBAB, @0xE4EBCC, @0xF7F7CB];
    UIColor *color = UIColorFromHex([[colors objectAtIndex:arc4random() % colors.count] intValue]);
    
    cell.backgroundColor = color;
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
