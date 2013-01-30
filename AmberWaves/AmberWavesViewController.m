//
//  AmberWavesViewController.m
//  AmberWaves
//
//  Created by Dina Li on 1/30/13.
//  Copyright (c) 2013 USDA ERS. All rights reserved.
//

#import "AmberWavesViewController.h"

@interface AmberWavesViewController ()

@end

@implementation AmberWavesViewController
@synthesize headerImageView = _headerImageView;
@synthesize titleLabel = _titleLabel;
@synthesize sideImageView = _sideImageView;
@synthesize contentOneTextView = _contentOneTextView;
@synthesize contentTwoTextView = _contentTwoTextView;
//@synthesize _contentWebView = _contentWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear{
    //self.title = @"Retrieve Data From Website API";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Charts of Note";
    
    dispatch_queue_t kBgQueue = dispatch_get_global_queue(
                                                          DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSURL *url = [NSURL URLWithString:@"http://api.ers.usda.gov/REST/v1/amberwaves/details/33942"]; // hard coded!!
    // NSURL *url = [NSURL URLWithString:@"http://api.ers.usda.gov/REST/v1/charts/mostrecent/3/"];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        url];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}

// Description:
// there is a top level array of dictionaries with the create date and release date
// each item in the array represents one Chart of Note (or whatever)
// below that, there is a Properties Array: index[1] contains the title, index[0] contains the image URL, index[8] contains the description
// need the title, url, release date, and description

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    
//    NSArray* jsonArray = [NSJSONSerialization
//                          JSONObjectWithData:responseData
//                          options:kNilOptions
//                          error:&error];
    
    NSDictionary *jsonDictionary = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:kNilOptions
                                    error:&error];
    
    id key = nil;
    NSString *value = nil;
    
        for (key in jsonDictionary) //WORKS IF ITS A DICTIONARY
        {
            value = [jsonDictionary objectForKey: key];
               NSLog(@"json dictionary value = %@", value); // value is NULL
               NSLog(@"json dictionary key = %@", key);
        }
    //    NSInteger j = 0;
    

    NSUInteger i = 0;
    NSUInteger records = [jsonDictionary count];
    NSString *item, *title, *url, *releaseDate, *description, *content, *chartID = nil;
    
    @try {
   // NSDictionary* jsonDictionary = [jsonArray objectAtIndex:0];
    NSArray *propertiesArray;
    
    //    key = @"Title";
    //    url = @"Url";
    //    releaseDate = @"ReleaseDate";
        
        // array of dictionaries within the big json array
        for (i = 0; i < records; i++)
        {
                for (item in jsonDictionary)
                {
                    title = [jsonDictionary objectForKey: @"Title"];
                    url = [jsonDictionary objectForKey: @"Url"];
                    releaseDate = [jsonDictionary objectForKey: @"ReleaseDate"];
                    chartID = [jsonDictionary objectForKey:@"Id"];
                    
                    if([item isEqualToString:@"Properties"])
                    {
                        propertiesArray = [jsonDictionary objectForKey:@"Properties"];
                        
                        if(propertiesArray.count > 0) // get the sub-dictionary that contains the description
                        {
                            // loop thru the Array and find the dictionary with the description keyField
                            NSUInteger g = 0;
                            
                            for(g =0; g<propertiesArray.count; g++)
                            {
                                NSDictionary *descriptionDictionary = [propertiesArray objectAtIndex:g]; // can't hard code because the structure changes!!
                                /*
                                 id key = nil;
                                 NSString *value = nil;
                                 
                                 for (key in descriptionDictionary) // what's inside?
                                 {
                                     value = [descriptionDictionary objectForKey: key];
                                     NSLog(@"json dictionary value = %@", value);
                                     NSLog(@"json dictionary key = %@", key);
                                 }
                                 */
                                // ALERT: !! strange format: keyfield:description; propertyValueField: the text description
                                if([[descriptionDictionary objectForKey:@"keyField"] isEqualToString:@"contents"])
                                {
                                    content = [descriptionDictionary objectForKey:@"propertyValueField"];
                                    NSLog(@"contents = %@", content);
                                }
                                else if([[descriptionDictionary objectForKey:@"keyField"] isEqualToString:@"description"])
                                {
                                    description = [descriptionDictionary objectForKey:@"propertyValueField"];
                                    NSLog(@"contents = %@", description);
                                }
                                
                            } // end for g
                        } // if arraycount > 0
                    } // if Properties
                } // for items
        } // end for
    }
    @catch (NSException *exception) {
        NSLog(@"error loading objects %@", exception);
    }
    @finally {
        // how to terminate here?
    }
    
    //////////////////////////////////
    /* display variables on UIView */
    /////////////////////////////////
    
    _titleLabel.text = title;
    _contentOneTextView.text = description;
    _contentTwoTextView.text = content;
    
    
//    _dateLabel.text = [self formatDate:releaseDate]; // get formatted date
//    _descriptionTextView.text = description;
//    _imageView.image = [self loadImage:url];
    //  NSLog(@"id = %@", chartID);
    
}
//
#pragma mark - date formatter
/* incoming date is the one that needs formatting */
- (NSString*) formatDate:(NSString*)unformattedDateString
{
    NSString *outputDateString = nil;
    
    if(unformattedDateString !=nil)
    {
        NSString *dateString = unformattedDateString;
        
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateStyle:NSDateFormatterMediumStyle];
        [outputFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        NSDate *date = [inputFormatter dateFromString:dateString];
        
        //this will set date's time components to 00:00
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                        startDate:&date
                                         interval:NULL
                                          forDate:date];
        
        outputDateString = [outputFormatter stringFromDate:date];
    }
    else
    {
        NSLog(@"incoming date was nil");
    }
    return outputDateString;
}

#pragma mark - retrieve image
/* TODO: this should be done on a background thread in case the image is slow or bombs */
- (UIImage*) loadImage:(NSString*)urlForImageString
{
    NSData * imageData = nil;
    UIImage * image = nil;
    
    NSString *urlPath = @"http://www.ers.usda.gov";
    
    NSMutableString *fullURL;
    
    if (fullURL == nil){
        fullURL = [[NSMutableString alloc] init];
    }
    
    [ fullURL appendString: urlPath];
    [ fullURL appendString: urlForImageString];
    
    NSURL *imageURL = [NSURL URLWithString:fullURL];
    
    @try {
        imageData = [NSData dataWithContentsOfURL:imageURL];
        image = [UIImage imageWithData:imageData];
    }
    @catch (NSException *exception) {
        NSLog(@"crashed loading the image = %@", exception);
    }
    @finally {
        //<#statements#>
    }
    
    return image;
}

- (void)viewDidUnload
{
//    [self setDescriptionTextView:nil];
//    [self setTitleLabel:nil];
//    [self setImageView:nil];
//    [self setDateLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
