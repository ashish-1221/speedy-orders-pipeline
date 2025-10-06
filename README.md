## Steps for creating a Amazon SNS
1. Open Amazon SNS service from AWS console
2. Click on Create Topic in the Amazon SNS console.
3. In Type select *Standard*, and give the topic a name
4. Click on **Create Topic** button.
5. After the topic is created,Click on the **Edit** Button
6. In the *Access Policy* section,clear the present policy, and attach the following policy, with modifications
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSNSTopicPublishFromS3",
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
      "Action": "SNS:Publish",
      "Resource": "SNS_TOPIC_ARN",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "BUCKET_OWNER_ACCOUNT_ID"
        },
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:s3:::BUCKET_NAME"
        }
      }
    }
  ]
}


```
7. Click on *Save Changes*.
8. After the topic is created, click on Subscriptions on the overview panel, to create an subscriber to subscribe to the created topic.
9. Click on *Create Subscription*.
10. Select the topic ARN, that has just been created.
11. I am creating a Email notification, hence in *protocol* select **Email**.
12. In the endpoint give the *email id* you want to receive notification in.
12. Click on **Create Subscription**.
13. After this you will get a confirm subscription in the specified email. Please confirm it to continue..

## Configuring S3 bucket for SQS notifications
1. Open the AWS S3 console.
2. In the *Properties* tab search for **Event Notifications**.
3. Click on *Create Event notification*.
4. Provide *event name*.
5. In event types select appropiate events you want to receive notifications for.
6. In *Destination*, select **SNS Topic**, and select the topic you just created.

For testing, upload a file in S3 bucket and open the queue from the SQS console.
If you are receiving a message then all is good.
