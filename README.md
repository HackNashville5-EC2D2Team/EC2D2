EC2D2
=====

An OSX widget for at-a-glance info on AWS EC2 instances.

How to use
-----

First, you must have the AWS CLI tools installed (command line tools) at `/usr/local/bin/aws`.  To do this, type `pip install awscli` in a Terminal window.  The application uses AWS CLI calls under the hood to get the information it needs.

Next, open the project in XCode.  Compile it and select "Distribute" to generate EC2D2.app.  Once you've generated it, feel free to drag and drop it to your Applications directory.  We even go to System Preferences -> Users and add it as a startup item!

First, you'll need to go to Settings, then add your AWS Access Key, Secret Key, and type in the region you want to track (us-east-1 for instance).  Once you have typed them in, hit apply, then select Refresh to refresh the list (give it a few seconds and your instances should appear in the list).

Contributing
-----

If you have any feature requests or want to fork the code and submit a pull request, feel free!  We may add some extra features here and there when we have time!  We are both relatively new to OSX apps and Objective-C, so if our code looks blatantly wrong and ugly, we'd love a fork and pull request with comments about how you made our code better :-)
