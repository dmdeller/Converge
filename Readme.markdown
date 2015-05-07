Converge
========

![CocoaPod version](https://img.shields.io/cocoapods/v/Converge.svg)
![License](https://img.shields.io/cocoapods/l/Converge.svg)
![Build Status](https://img.shields.io/travis/tripcraft/Converge.svg)

Converge is an Objective-C library that receives data from a web server, and puts it into Core Data. It can also do the reverse, sending data from Core Data back to the web server. It uses AFNetworking for HTTP requests and JSON parsing.

Converge is optimized for use with Ruby on Rails servers, and favors the **convention over configuration** philosophy. If you make a Core Data model that is the same as your ActiveRecord model, Converge can figure out most or all of the attributes and relationships automatically, so you don't have to configure (almost) anything.

Not using Rails? Working a bit outside of convention? Not a problem; Converge is configurable enough that you should be able to use it with almost any kind of server and data structure. It will be easiest if you do use Rails convention, however.

Converge **does not do synchronization**. Sync is a famously hard problem, and by not attempting to solve it, we are able to keep Converge simpler and easier, while still being useful. Converge only ever performs data operations at your explicit request; nothing is ever retrieved from, or sent to, the web server, except when you decide to. Converge only operates on the set of data that you specify; it is expected that you might only want to the client to know about a subset of the records available on the server.

Converge believes that **the web server's data is The Truth**. In case of any discrepencies that are encountered between Core Data's version of the data and the web server's version, the web server always wins, and Core Data's version is overwritten to match the server.

Installation
------------

Install Converge using CocoaPods, by adding this to your Podfile, and then running `pod install`:

    pod 'Converge', '~> 1.0.0'

**Note:** For this pod, make sure to specify all three decimal places, rather than only two as CocoaPods suggests.

Version numbers will be in the form `x.y.z`. `y` versions may contain backwards-incompatible API changes; `z` versions will only contain backwards-compatible bug fixes. Specifying the version as above means that when you run `pod update`, it will only update you to `z`-level bug fixes, for safety. To get `y` and `x`-level changes, edit your Podfile.

Basics
------

Say you have a model named Article. On your server, you access the collection of articles at a URL like this:

    GET /articles

The response from the server, in JSON format, would look like this:

    [
      {
        "id": 1,
        "title": "Lorem ipsum",
        "body_text": "Dolor sit amet"
      },
      {
        "id": 2,
        "title": "Consectetur adipiscing elit",
        "body_text": "Aliquam ac mi ac leo"
      }
    ]

In Core Data, you should configure your model to match the server as closely as possible. Create a model, name it Article, and make it a subclass of `ConvergeRecord`. Give it these attributes:

* id — Integer 64
* title — String
* bodyText — String

You'll notice that we renamed `body_text` slightly, to be camel-cased according to Cocoa convention. That's fine; Converge handles the translation to camel-case and back automatically. If the server also used camel-case, that would be fine too. Or if you decided to use underscores in Core Data for some reason, that would also work. No configuration is necessary in any of these cases. However, it's important that the name is still essentially the same. If we had called it `bodyStuff` in Core Data, it wouldn't work automatically. (If the name needs to be different, see the Mapping section below.)

Now, to retrieve some data. In your Objective-C app:

    ConvergeClient *client = [ConvergeClient.alloc initWithBaseURL:@"http://example.com" context:self.managedObjectContext];
    AFHTTPRequestOperation *operation = [client fetchRecordsOfClass:Article.class parameters:nil success:^(AFHTTPRequestOperation *operation_, NSArray *records)
     {
         // We got some records!
     }
    failure:^(NSError *error)
     {
         // Handle the error
     }];
     
Converge automatically does the GET request noted above.

If you already had any articles with the same ID in your database, Converge overwrites them with the server's new versions. By default, Converge expects the ID attribute to be named `id`. You can change this by overriding `+ IDAttributeName` in your model classes.

You can use these similar methods for retrieving only a single record:

    - (AFHTTPRequestOperation *)fetchRecord:(ConvergeRecord *)record parameters:(id)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;
    - (AFHTTPRequestOperation *)fetchRecordOfClass:(Class)recordClass withID:(id)recordID parameters:(id)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;

Or these, for sending a new record to the server:

    - (AFHTTPRequestOperation *)sendNewRecord:(ConvergeRecord *)record parameters:(NSDictionary *)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;
    
And for updating an existing record:

    - (AFHTTPRequestOperation *)sendUpdatedRecord:(ConvergeRecord *)record parameters:(NSDictionary *)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;

Foreign Keys
------------

Your server may be backed by a relational database, similar to Core Data, which allows expressing relationships between records. Sometimes, it is useful to output these in the form of foreign keys; in other words, the related record's ID.

Here's an example of some ProductReview records from the server:

    [
      {
        "id": 1,
        "product_id": 5,
        "name": "Alice",
        "review_text": "Your products all suck"
      },
      {
        "id": 2,
        "product_id: 6",
        "name": "Bob",
        "review_text": "I'm really satisfied with my vaccum cleaner!"
      }
    ]

It would be inefficient to include all of the product data with every review, so the server just sends us the ID, and assumes we already have the Product record.

The good news is that Converge will handle this situation automatically. Set up your Product and ProductReview models in Core Data, and make a 1-to-many relationship between Product and ProductReview, to match the relationship implicit in the server's data. Name the relationship `productReviews` on the Product side, and `product` on the ProductReview side. When Converge encounters the `product_id` attribute in the server data, it will search for a relationship named `product`, and make the connection.

The only caveat is this: Converge searches for the related product with that ID when it is parsing the ProductReviews. Therefore, **the related record must already exist in Core Data prior to evaluating the foreign key**. So, you should retrieve any Product records that may be needed prior to retrieving the ProductReview records.

This also works with a list of foreign keys, in case you have a to-many relationship:

    {
      "id": 1,
      "product_ids": [5, 6]
      "name": "Alice",
      "review_text": "Your products all suck"
    }

In this example, the relationship should be named `products` on the ProductReview side. Converge singularizes it before looking for the `_ids` attribute.

Embedded Records
----------------

Sometimes it is more convenient for the server to embed one record inside of another in its response. This can save you from needing to do multiple HTTP requests, and also avoids the need for a prerequisite request, noted in the above section.

    {
      "id": 1,
      "name": "Katamari Damacy T-Shirt",
      "image": {
        "id": 4,
        "url": "http://example.com/katamari.jpg",
        "title": "Roll it up!"
      }
    }

As explained in the previous section, make sure to have the relationships set up in Core Data using the same names. In this case, name the relationship `image` on the Product side.
    
This also works when you have multiple embedded records.

    {
      "id": 1,
      "name": "Katamari Damacy T-Shirt",
      "images": [
        {
          "id": 4,
          "url": "http://example.com/katamari.jpg",
          "title": "Roll it up!"
        },
        {
          "id": 5,
          "url": "http://example.com/rolling.jpg",
          "title": "Rollin'"
        }
      ]
    }
    
In this example, name the relationship `images` instead.

URL Paths
---------

By default, Converge determines the URLs it should request based on the model name, and Rails convention. So, for a model named ArticleComment, Converge will attempt to use these URLs:

    GET /article_comments
    GET /article_comments/1
    POST /article_comments
    PATCH /article_comments/1

No configuration is necessary to use this default behavior.

You may be used to seeing URLs like this with a `.json` extension. Instead of that, Converge includes the following header in every request:

    Accept: application/json
    
Some servers, such as Ruby on Rails, make the file name extension unnecessary when the Accept header is supplied like this.

If your server uses a different URL strategy, override the following methods in your models.

This method is used for POST, and for GET when we don't have an ID:

    + (NSString *)collectionURLPathForHTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters

This method is used for PATCH, and for GET when we do have an ID:

    + (NSString *)URLPathForID:(id)recordID HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters

Mapping
-------

In some cases, you may need to have different attribute and relationship names than the server has. Maybe Converge's name transformation logic got it wrong, or maybe you're trying to use an attribute name like `description` that Objective-C doesn't allow, or maybe your server developer is just stubborn and bad at naming things. In any case, Converge allows you to override any of its mappings.

For attributes, override `+ attributeMap` on your model class. Return a dictionary with the mapped attributes that you want to customize; use the Core Data name as the key, and the server's name as the value.

    + (NSDictionary *)attributeMap
    {
        return @{
            @"description_": @"description",
        };
    }
    
Keep in mind that you only need to explicitly define the ones that couldn't be determined automatically - not all of them. If you also have other attributes on the same model, such as `id`, `name`, etc., which are the same in both places, there is no need to put them in this dictionary.

You can also deal with server data that is nested in multiple levels, if perhaps you don't want to make it a Core Data relationship (explained in the Embedded Records section above). Like if you get this from the server:

    {
      "id": 1,
      "name": "Katamari Damacy T-Shirt",
      "image": {
        "id": 4,
        "url": "http://example.com/katamari.jpg",
        "title": "Roll it up!"
      }
    }

Perhaps you don't want a separate, related Image record, and just want to include its `url` attribute as part of your Product record. You can do that by specifying the server's attribute name as an array, indicating how the embedded records should be traversed:

    + (NSDictionary *)attributeMap
    {
        return @{
            @"imageURL": @[@"image", @"url"],
        };
    }
    
As implied earlier, the ID attribute is special, in that Converge uses it to match server data to existing records, search for foreign keys, etc. If you use an ID attribute name in Core Data other than `id`, you must override `+ IDAttributeName`. If this is also different than the ID attribute name that the server uses, you must also include it in `+ attributeMap`.

For names of foreign keys, override `+ foreignKeyMap`, following the same format.

For names of embedded records, override `+ relationshipMap`.

Format Conversions
------------------

Sometimes, the data you get from the server will be in a different format than you want to store it in Core Data. Converge generally avoids trying to guess what you want in these cases, but it does provide a way to automatically convert data when it is being parsed.

For example, say the server gives you a timestamp in string format, and you want to store those as NSDate:

    {
      "id": 1,
      "title": "Graeme Devine is right",
      "created_at": "2011-07-10 09:51:03 -0700"
    }

In your model class, override the method `+ (ConvergeAttributeConversionBlock)conversionForAttribute:(NSString *)ourAttributeName`. Like so:

    + (ConvergeAttributeConversionBlock)conversionForAttribute:(NSString *)ourAttributeName
    {
        if ([ourAttributeName isEqualToString:@"createdAt"])
        {
            return ^NSDate *(NSString *value)
            {
                if (value == nil || ![value isKindOfClass:NSString.class]) return nil;
                
                ISO8601DateFormatter *formatter = ISO8601DateFormatter.new;
                
                return [formatter dateFromString:value];
            };
        }
        
        return [super conversionForAttribute:ourAttributeName];
    }

For your convenience, Converge provides a number of built-in conversions:

    + (ConvergeAttributeConversionBlock)stringToIntegerConversion;
    + (ConvergeAttributeConversionBlock)stringToFloatConversion;
    + (ConvergeAttributeConversionBlock)stringToDecimalConversion;
    + (ConvergeAttributeConversionBlock)stringToDateConversion;
    + (ConvergeAttributeConversionBlock)stringToURLConversion;
    
However, you would still have to specify them, like so:

    + (ConvergeAttributeConversionBlock)conversionForAttribute:(NSString *)ourAttributeName
    {
        if ([ourAttributeName isEqualToString:@"createdAt"])
        {
            return self.stringToDateConversion;
        }
        
        return [super conversionForAttribute:ourAttributeName];
    }

If you want to do the reverse, when sending your data back to the server, override the method `+ (ConvergeAttributeConversionBlock)reverseConversionForAttribute:(NSString *)ourAttributeName` in the same way. Remember that you cannot reuse the same conversion logic, but instead must write a conversion that does the reverse.

Caching
-------

If you need to repeatedly check the server for new data, it may be inefficient for the server to transfer the entire data set back to you when nothing has changed since the last time you requested it. Converge provides a way to avoid this.

On your `ConvergeClient` instance, set the property `trackModifiedTimes` to `YES`. The next time you do a GET request, Converge will record the URL (including any GET parameters) along with the date and time. The next time you tell Converge to make an identical request (i.e., identical URL and GET parameters), Converge will look up the timestamp of the previous request, and send this information to the server in the `If-Modified-Since` header. The rest is then up to your server; it has the option of sending back a `304 Not Modified` response with no data in the response body, if nothing has changed. (Rails can do this automatically.) In that case, Converge calls your `success` block immediately. If the server sends a `200` response, Converge behaves as it otherwise would, and processes the response data.

**Caveat 1:** In the event of a `304 Not Modified`, the second parameter of your `success` callback will be `nil`. If you need the data that would normally be there, then you will need to query Core Data for it, since it is not available in the server's response.

**Caveat 2:** To keep track of your requests, when `trackModifiedTimes` is enabled, Converge creates a file in your application's documents directory. You can get the URL to this file with `- requestTimestampsFileURL`. If you make any changes that would cause your database to no longer be in sync with the server, such as deleting the database entirely (or merely some of the records that had previously been requested), then you should delete this timestamps file; otherwise, Converge will continue to treat the non-existent records as cached, and they will not be retrieved in subsequent requests.

Because of the above caveats, `trackModifiedTimes` is off by default.

When enabled, `trackModifiedTimes` is only used for GET requests; not for any other requests, such as POST or PATCH.

Advanced Customization
----------------------

Perhaps your server uses a data structure that is totally off-the-wall, and Converge can't make any sense of it, even with the above configuration options. It's possible to override what Converge does after it parses the JSON, but before it tries to make sense of the data.

If that's the case, you may wish to take a look at overriding these mthods in your model class:

    - (BOOL)mergeChangesFromProvider:(NSDictionary *)providerRecord withQuery:(NSDictionary *)query recursive:(BOOL)recursive error:(NSError **)errorRef;
    + (NSArray *)mergeChangesFromProviderCollection:(NSArray *)collection withQuery:(NSDictionary *)query recursive:(BOOL)recursive deleteStale:(BOOL)shouldDeleteStale context:(NSManagedObjectContext *)context skipInvalidRecords:(BOOL)skipInvalid error:(NSError **)errorRef;

This would leave it up to you to do whatever is necessary to get the data into Core Data.

TODO
----

HTTP DELETE operation is not yet implemented (simply because I haven't needed it yet).

Has a basic test suite, but could use better test coverage. Add a new regression test whenever a bug is found.

License
-------

MIT. See `License.txt`.

Contributing
------------

Pull requests welcome :)

Please try to match existing style. If you're contemplating a major change, maybe start a discussion in Issues first to propose it.

After making changes, make sure the tests still pass. Add new test(s) for new functionality, as appropriate.

Authors
-------

Created by David Deller <david.deller@tripcraft.com>.

Copyright © 2012-2015 TripCraft LLC.
