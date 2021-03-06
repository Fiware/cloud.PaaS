# -*- coding: utf-8 -*-
Feature: Update a tier of an environment in a tenant

    As a fi-ware user
    I want to be able to update a tier of an environment in a tenant
    so that I do not need to delete it and create it again when some change is needed

    @happy_path
    Scenario: Update tier of an environment leaving the same data
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | nameqa | descqa      |
        And a tier has already been added to the environment "nameqa" with data:
            | name       |
            | tiernameqa |
        When I request the update of the tier "tiernameqa" of the environment "nameqa" with data:
            | name       |
            | tiernameqa |
        Then I receive a "No Content" response
        And the data of the tier "tiernameqa" of the environment "nameqa" becomes:
            | name       |
            | tiernameqa |

    Scenario Outline: Update tier of an environment adding new products
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       |
            | <tiername> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       | products   |
            | <tiername> | <products> |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       | products   |
            | <tiername> | <products> |
        
        Examples:
            | name    | tiername    | products                 |
            | nameqa1 | tiernameqa1 | git=1.7                  |
            | nameqa2 | tiernameqa2 | git=1.7,mediawiki=1.17.0 |
        
    Scenario Outline: Update tier of an environment removing its products
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       | products   |
            | <tiername> | <products> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       |
            | <tiername> |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       |
            | <tiername> |
        
        Examples:
            | name    | tiername    | products                 |
            | nameqa1 | tiernameqa1 | git=1.7                  |
            | nameqa2 | tiernameqa2 | git=1.7,mediawiki=1.17.0 |
        

    Scenario Outline: Update tier of an environment adding new networks
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       |
            | <tiername> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       | networks   |
            | <tiername> | <networks> |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       | networks   |
            | <tiername> | <networks> |
        
        Examples:
            | name    | tiername    | networks      |
            | nameqa1 | tiernameqa1 | netqa1        |
            | nameqa2 | tiernameqa2 | netqa1,netqa2 |

    Scenario Outline: Update tier of an environment removing its networks
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       | networks   |
            | <tiername> | <networks> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       |
            | <tiername> |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       |
            | <tiername> |
        
        Examples:
            | name    | tiername    | networks      |
            | nameqa1 | tiernameqa1 | netqa1        |
            | nameqa2 | tiernameqa2 | netqa1,netqa2 |

    Scenario Outline: Update tier of an environment adding new products and networks
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       |
            | <tiername> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       | products   | networks   |
            | <tiername> | <products> | <networks> |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       | products   | networks   |
            | <tiername> | <products> | <networks> |
        
        Examples:
            | name    | tiername    | products                 | networks      |
            | nameqa1 | tiernameqa1 | git=1.7                  | netqa1        |
            | nameqa2 | tiernameqa2 | git=1.7,mediawiki=1.17.0 | netqa1,netqa2 |

    Scenario Outline: Update tier of an environment removing its products and networks
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       | products   | networks   |
            | <tiername> | <products> | <networks> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       |
            | <tiername> |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       |
            | <tiername> |
        
        Examples:
            | name    | tiername    | products                 | networks      |
            | nameqa1 | tiernameqa1 | git=1.7                  | netqa1        |
            | nameqa2 | tiernameqa2 | git=1.7,mediawiki=1.17.0 | netqa1,netqa2 |
        
    Scenario: Update tier of an environment changing its name
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | nameqa | descqa      |
        And a tier has already been added to the environment "nameqa" with data:
            | name       |
            | tiernameqa |
        When I request the update of the tier "tiernameqa" of the environment "nameqa" with data:
            | name        | networks |
            | newtiername | netqa1   |
        Then I receive a "Bad Request" response
        
    Scenario: Update tier of an environment in the wrong path
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | nameqa | descqa      |
        And a tier has already been added to the environment "nameqa" with data:
            | name       |
            | tiernameqa |
        When I request the update of the tier "wrong_tiername" of the environment "nameqa" with data:
            | name       | networks |
            | tiernameqa | netqa1   |
        Then I receive a "Not Found" response
        
    Scenario: Update non existing tier of an environment
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | nameqa | descqa      |
        When I request the update of the tier "tiernameqa" of the environment "nameqa" with data:
            | name       | networks |
            | tiernameqa | netqa1   |
        Then I receive a "Not Found" response

    Scenario Outline: Update tier of an environment. Update Region
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       |
            | <tiername> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       | region         |
            | <tiername> | <param_value>  |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       | region        |
            | <tiername> | <param_value> |

        Examples:
            | name    | tiername   | param_value                     |
            | nameqa1 | tiernameqa | Spain                           |
            | nameqa2 | tiernameqa | Trento                          |


    Scenario Outline: Update tier of an environment. Update Image
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       |
            | <tiername> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       | image         |
            | <tiername> | <param_value> |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       | image         |
            | <tiername> | <param_value> |

        Examples:
            | name    | tiername   | param_value                     |
            | nameqa3 | tiernameqa | asdasda-dvsvs-df34wd2-123123123 |
            | nameqa4 | tiernameqa | 12312qqq123123                  |


    Scenario Outline: Update tier of an environment. Update floatingip
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       |
            | <tiername> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       | floatingip     |
            | <tiername> | <param_value>  |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       | floatingip     |
            | <tiername> | <param_value>  |

        Examples:
            | name    | tiername   | param_value                     |
            | nameqa6 | tiernameqa | true                            |
            | nameqa7 | tiernameqa | false                           |


    Scenario Outline: Update tier of an environment. Update flavour
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       |
            | <tiername> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       | flavour        |
            | <tiername> | <param_value>  |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       | flavour        |
            | <tiername> | <param_value>  |

        Examples:
            | name    | tiername   | param_value |
            | nameqa8 | tiernameqa | 4           |


    Scenario Outline: Update tier of an environment. Update mini, max and initial number of instances
        Given the paas manager is up and properly configured
        And an environment has already been created with data:
            | name   | description |
            | <name> | descqa      |
        And a tier has already been added to the environment "<name>" with data:
            | name       |
            | <tiername> |
        When I request the update of the tier "<tiername>" of the environment "<name>" with data:
            | name       | minimumNumberInstances     | maximumNumberInstances    | initialNumberInstances    |
            | <tiername> | <minimumNumberInstances>   | <maximumNumberInstances>  | <initialNumberInstances>  |
        Then I receive a "No Content" response
        And the data of the tier "<tiername>" of the environment "<name>" becomes:
            | name       | minimumNumberInstances     | maximumNumberInstances    | initialNumberInstances    |
            | <tiername> | <minimumNumberInstances>   | <maximumNumberInstances>  | <initialNumberInstances>  |

        Examples:
            | name    | tiername   | minimumNumberInstances | maximumNumberInstances | initialNumberInstances |
            | nameqa9 | tiernameqa | 2                      | 5                      | 3                      |
