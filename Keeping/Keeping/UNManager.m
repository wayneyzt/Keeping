//
//  UNManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/20.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "UNManager.h"
#import "DateTools.h"
#import "DateUtil.h"
#import "TaskManager.h"
#import <UIKit/UIKit.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation UNManager

//定时推送
+ (void)createLocalizedUserNotification:(Task *)task{
    // 设置触发条件 UNNotificationTrigger
    for(NSNumber *weekday in task.reminderDays){
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.weekday = [weekday integerValue];
        
        components.hour = task.reminderTime.hour;
        components.minute = task.reminderTime.minute;
        
        //FOR TEST
//        components.hour = [[NSDate date] hour];
//        components.minute = [[[NSDate date] dateByAddingMinutes:1] minute];
//        NSLog(@"通知时间 %ld %ld", (long)components.hour, (long)components.minute);
        
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        
        // 创建通知内容 UNMutableNotificationContent, 注意不是 UNNotificationContent, 此对象为不可变对象。
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = task.name;
        content.subtitle = @"";
//        if (task.memo != NULL && ![task.memo isEqualToString:@""]) {
//            content.subtitle = task.memo;
//        }
        
        if(task.appScheme != NULL){
            content.body = [NSString stringWithFormat:@"前往→%@", task.appScheme.allKeys[0]];
        }else{
            content.body = @"就是现在!";
        }
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"badgeCount"]){
            content.badge = @1;
        }
        
        content.sound = [UNNotificationSound defaultSound];
        
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithObject:@(task.id) forKey:@"taskid"];
        if (task.appScheme != NULL) {
            tempDict[@"taskapp"] = task.appScheme.allValues[0];
        }
        content.userInfo = tempDict;
        
        if (task.image != NULL) {
            NSString *imageId = [NSString stringWithFormat:@"image%d_%d.png", task.id, weekday.intValue];
            
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            path = [path stringByAppendingPathComponent:imageId];
            
            [task.image writeToFile:path atomically:YES];
            
            NSURL *url = [NSURL fileURLWithPath:path];
            
            NSError *err;
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"img" URL:url options:@{} error:&err];
            
            content.attachments = @[attachment];
        }
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        //当日未完成
//        if(![task.punchDateArr containsObject:[DateUtil transformDate:[NSDate date]]]){
            UNNotificationAction *doneAction = [UNNotificationAction actionWithIdentifier:@"action.done" title:@"标记为已完成" options:UNNotificationActionOptionAuthenticationRequired];
            UNNotificationAction *cancelAction = [UNNotificationAction actionWithIdentifier:@"action.cancel" title:NSLocalizedString(@"Cancel", nil) options:UNNotificationActionOptionDestructive];
            // 注册 category
            UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"taskLocalCategory" actions:@[doneAction, cancelAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
            content.categoryIdentifier = @"taskLocalCategory";
            // 将 category 添加到通知中心
            [center setNotificationCategories:[NSSet setWithObject:notificationCategory]];
//        }
        
        // 创建通知标示
        NSString *requestIdentifier = [NSString stringWithFormat:@"unid%@%@",task.addDate.description,weekday];
        // 创建通知请求 UNNotificationRequest 将触发条件和通知内容添加到请求中
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
        // 将通知请求 add 到 UNUserNotificationCenter
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
//                NSLog(@"推送添加成功 %@ %@", requestIdentifier, task.reminderTime.description);
            } else {
                NSLog(@"推送添加失败 %@", error.description);
            }
        }];
    }
}

+ (void)deleteLocalizedUserNotification:(Task *)task{
    for(NSNumber *weekday in task.reminderDays){
        //创建通知标示
        NSString *requestIdentifier = [NSString stringWithFormat:@"unid%@%@",task.addDate.description,weekday];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removePendingNotificationRequestsWithIdentifiers:@[requestIdentifier]];
//        NSLog(@"删除通知");
    }
}

+ (void)reconstructNotifications{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center removeAllPendingNotificationRequests];
    [center removeAllDeliveredNotifications];
    
    for(Task *task in [[TaskManager shareInstance] getTasks]){
        if(task.reminderTime != nil){
            [self createLocalizedUserNotification:task];
        }
    }
}

+ (void)printNumberOfNotifications{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
//        for(UNNotificationRequest *request in requests){
//            NSLog(@"%@", [request.content.userInfo valueForKey:@"taskid"]);
//        }
    }];
}

@end
