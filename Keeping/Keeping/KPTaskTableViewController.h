//
//  KPTaskTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPTaskTableViewCell.h"
#import "KPWeekdayPickerView.h"
#import "KPColorPickerView.h"
#import "KPWeekdayPickerView.h"
#import "KPNavigationTitleView.h"

@interface KPTaskTableViewController : UITableViewController <PassImgDelegate, KPWeekdayPickerDelegate, KPColorPickerDelegate, UIViewControllerPreviewingDelegate, KPNavigationTitleDelegate>

@property (nonnull, nonatomic) NSMutableArray *taskArr;
@property (nonnull, nonatomic) NSMutableArray *historyTaskArr;

@property (nonatomic) int selectedColorNum;

@property (nonnull, nonatomic) NSMutableArray *selectedWeekdayArr;
@property (nonnull, nonatomic) IBOutlet KPWeekdayPickerView *weekDayView;

@property (nonnull, nonatomic) NSString *sortFactor;
@property (nonnull, nonatomic) NSNumber *isAscend;

- (void)searchAction:(_Nonnull id)senders;
- (void)editAction:(_Nonnull id)senders;

@end
