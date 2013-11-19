//
//  JobsViewController.m
//  LocalNotificationSchedule
//
//  Created by 傅小柳 on 13/10/22.
//  Copyright (c) 2013年 Harris. All rights reserved.
//

#import "JobsViewController.h"
#import "JobsAppDelegate.h"

@interface JobsViewController () <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UITextField *eventText;
@property (strong, nonatomic) IBOutlet UITableView *listTableView;

@end

@implementation JobsViewController

#pragma mark - View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _listTableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableView:)
                                                 name:@"RefershTableViewDatas"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)scheduleAction:(id)sender {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [_datePicker date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = _eventText.text;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];

//    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
//    NSLog(@"%@", notifs);
    
    //重新安排 applicationIconBadgeNumber
    JobsAppDelegate *appDelegate = [[JobsAppDelegate alloc] init];
    //每增加一分通知就呼叫一次
    [appDelegate reorderApplocationIconBadgeNumber];
    
    [_listTableView reloadData];
    [_eventText resignFirstResponder];
}

- (IBAction)textDoneAction:(id)sender {
    
    [sender resignFirstResponder];
}

#pragma mark - Table View DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    return [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    UILocalNotification *notif = [notifs objectAtIndex:indexPath.row];
//    cell.textLabel.text = notif.alertBody;
    cell.textLabel.text = [NSString stringWithFormat:@"(%ld) %@", notif.applicationIconBadgeNumber, notif.alertBody];
    
    //取出時間，轉換時區，顯示在 cell.detailTextLabel
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.detailTextLabel.text = [dateFormat stringFromDate:notif.fireDate];
    
    return cell;
}

#pragma mark - Refresh TableView

- (void)refreshTableView:(NSNotification *)notification {

    [_listTableView reloadData];
}

@end
