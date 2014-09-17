//
//  PLSettingsTableViewController.m
//  CriticalMass
//
//  Created by Norman Sander on 17.09.14.
//  Copyright (c) 2014 Pokus Labs. All rights reserved.
//

#import "PLSettingsTableViewController.h"
#import "PLData.h"

@interface PLSettingsTableViewController ()

@end

@implementation PLSettingsTableViewController{
    PLData *_data;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _data = [PLData sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return 2;
    }else if(section == 2){
        return 3;
    }else if(section == 3){
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    if(indexPath.section == 0 && indexPath.row == 0){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Enable GPS";
        
        UISwitch *gpsSwitch = [[UISwitch alloc]init];
        [gpsSwitch addTarget:self action:@selector(onSwitchGPS:) forControlEvents:UIControlEventTouchUpInside];
        [gpsSwitch setOn:_data.gpsEnabledUser];
        cell.accessoryView = gpsSwitch;
    }else if (indexPath.section == 1){
        if(indexPath.row == 0){
            cell.textLabel.text = @"Visit Facebook Fanpage";
        }
        if(indexPath.row == 1){
            cell.textLabel.text = @"Visit Twitter Page";
        }
    }else if (indexPath.section == 2){
        if(indexPath.row == 0){
            cell.textLabel.text = @"Logo Design";
            cell.detailTextLabel.text = @"http://www.thomas-hollnack.de";
        }
        if(indexPath.row == 1){
            cell.textLabel.text = @"Github";
            cell.detailTextLabel.text = @"https://github.com/headione/criticalmass-berlin";
        }
        if(indexPath.row == 2){
            cell.textLabel.text = @"Website";
            cell.detailTextLabel.text = @"http://www.criticalmass-berlin.org/";
        }
    }else if (indexPath.section == 3){
        if(indexPath.row == 0){
            cell.imageView.image = [UIImage imageNamed:@"Paypal"];
            cell.detailTextLabel.text = @"Please donate";
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        if(indexPath.row == 0){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.facebook.com/pages/Critical-Mass-Berlin/74806304846"]];
        }
        if(indexPath.row == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://twitter.com/cmberlin"]];
        }
    }else if (indexPath.section == 2){
        if(indexPath.row == 0){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.thomas-hollnack.de"]];
        }
        if(indexPath.row == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/headione/criticalmass-berlin"]];
        }
        if(indexPath.row == 2){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.criticalmass-berlin.org"]];
        }
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"GPS settings";
    }else if (section == 1){
        return @"Social Media";
    }else if (section == 2){
        return @"About";
    }
    
    return @"";
}

-(IBAction)onSwitchGPS:(id)sender
{
    _data.gpsEnabledUser = [sender isOn];
    _data.gpsEnabledUser ? [_data enableGps] : [_data disableGps];
}

@end
