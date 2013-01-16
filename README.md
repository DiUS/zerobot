# Welcome to Zerobot!

We wanted to make a tool that helps project teams big and small get started with minimal fuss. 

# Improvements made every day

The team behind Zerobot are working hard to ensure it becomes to tool teams will love to use. It is under constant development, and the team is always thinking of new and innovative ways to help bootstrap project teams.

# What is it?

Zerobot allows teams to create environments in a flexible manner, leveraging the following technologies:

* AWS (CloudFormation, EC2, S3, Route 53)
* Github
* Jenkins
* Built with Rubyon Rails, Backbone, jQuery, Twitter Bootstrap

# The Launchpad

It starts at the launchpad. From here users authenticate with github and select a repository, provide AWS authentication details and an AWS region. The user will eventually be presented with a link to their very own Zerobot Dashboard.

The launchpad is currently public and can be found at http://zerobot.io/launchpad. Users can provide details and start zerobotting today.

# The Dashboard

The dashboard is the place teams visit on a frequent basis. The dashboard features include:

* Burn down charts and current velocity with Pivotal Tracker
* Performance graphs from New Relic
* Jenkins/CI integration
* AWS Environment management

## Environment Management

The dashboard provides an easy to use interface to AWS, giving teams the flexibility to customise their environments as need be. Teams can:

* Create and remove environments
* View the status of an environment
* View the estimated cost of running the environment

### Customising environments

Environments leverage AWS CloudFormation to provide an easy and flexible way to manage environments. 

CloudFormation templates live on S3 and are completely customisable. The dashboard takes the CloudFormation templates from S3 and presents them to the team member using the dashboard. Team members can then provide the parameters the template needs and create an environment. 

Teams can customise these templates and create ANY type of topology they wish!

## Continuous Integration

Zerobot provides continuous integration out of the box, giving teams a build pipeline all the way to Production. 

Teams can also deploy specific versions of their code to ANY environment they created using the dashboard. Teams can customise the build pipeline if they wish to.

# Developers getting started

If you would like to get Zerobot running on your machine, check out https://github.com/DiUS/zerobot/wiki/Development-startup-guide for more details.