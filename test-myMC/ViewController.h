//
//  ViewController.h
//  test-myMC
//
//  Created by Don Miller on 3/8/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "ConnectivityManager.h" // need for delegate

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ConnectivityManagerDelegate>

@end
