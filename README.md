![Mobile Buy SDK](https://raw.github.com/Shopify/mobile-buy-sdk-ios/master/Assets/Mobile_Buy_SDK_Github_banner.png)

[![Build status](https://badge.buildkite.com/3951692121947fbf7bb06c4b741601fc091efea3fa119a4f88.svg)](https://buildkite.com/shopify/mobile-buy-sdk-ios/builds?branch=sdk-3.0%2Fmaster)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/Shopify/mobile-buy-sdk-ios/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/shopify/mobile-buy-sdk-ios.svg)](https://github.com/Shopify/mobile-buy-sdk-ios/releases)
[![CocoaPods](https://img.shields.io/cocoapods/v/Mobile-Buy-SDK.svg)](https://cocoapods.org/pods/Mobile-Buy-SDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Mobile Buy SDK for iOS

Shopify’s Mobile Buy SDK makes it simple to sell physical products inside your mobile app. With a few lines of code, you can connect your app with the Shopify platform and let your users buy your products using Apple Pay or their credit card.

- [Documentation](#documentation)
  - [API Documentation](#api-documentation)

- [Installation](#installation)
  - [Dynamic Framework Installation](#dynamic-framework-installation)
  - [CocoaPods](#cocoapods)
  - [Carthage](#carthage)

- [Getting Started](#getting-started)
- [Code Generation](#code-generation)
  - [Request models](#request-models)
  - [Response models](#response-models)
  - [The `Node` protocol](#the-node-protocol)
  - [Aliases](#aliases)

- [GraphClient](#)
  - [Queries](#queries)
  - [Mutations](#mutations)
  - [Retry & polling](#)
  - [Graph client errors](#)

- [Pay Helper](#)

- [Case study](#)
  - [Fetch Shop info](#)
  - [Fetch Collections ](#)
  - [Fetch Collections](#)
      - [Fetch Collection by ID](#)
      - [Fetch Product by ID](#)
  - [Create Checkout](#)
  - [Update Checkout](#)
      - [Update Checkout with Customer Email](#)
      - [Update Checkout with Customer Shipping Address](#)
      - [Polling Checkout Shipping Rates](#)
  - [Complete Checkout](#)
      - [With Credit Card](#)
      - [With Apple Pay](#)
      - [Polling Checkout Payment Status](#)
  - [Handling Errors](#)

- [Contributions](#contributions)
- [Help](#help)
- [License](#license)

### Documentation

Official documentation can be found on the [Mobile Buy SDK for iOS page](https://docs.shopify.com/mobile-buy-sdk/ios).

#### API Documentation

API docs (`.docset`) can be generated with the `Documentation` scheme or viewed online at Cocoadocs: [http://cocoadocs.org/docsets/Mobile-Buy-SDK/](http://cocoadocs.org/docsets/Mobile-Buy-SDK/).

The SDK includes a pre-compiled [.docset](https://github.com/Shopify/mobile-buy-sdk-ios/tree/master/Mobile Buy SDK/docs/com.shopify.Mobile-Buy-SDK.docset) that can be used in API documentation browser apps such as Dash.

### Installation

<a href="https://github.com/Shopify/mobile-buy-sdk-ios/releases/latest">Download the latest version</a>

#### Dynamic Framework Installation

2. Add `Buy.framework` target as a depenency by navigating to:
  - `Your Project` and (Select your target)
  - `Build Phases`
  - `Target Dependencies`
  -  Add  `Buy.framework`
3. Link `Buy.framework` by navigating to:
  - `Your Project` and (Select your target)
  - `Build Phases`
  - `Link Binary With Libraries`
  -  Add `Buy.framework`
4. Ensure the framework is copied into the bundle by navigating to:
  - `Your Project` and (Select your target)
  - `Build Phases`
  - Add `New Copy Files Phase`
  - Select `Destination` dropdown and chose `Frameworks`
  - Add `Buy.framework`
5. Import into your project files using `import Buy`
 
See the `Storefront` sample app for an example of how to add the `Buy` target a dependency.

#### CocoaPods

Add the following line to your podfile:

```ruby
pod "Mobile-Buy-SDK"
```

Then run `pod install`

Import the SDK module:
```swift
import Buy
```

#### Carthage

Add the following line to your Cartfile

```ruby
github "Shopify/mobile-buy-sdk-ios"
```

Then run `carthage update`

Import the SDK module:
```swift
import Buy
```

### Getting started

The Buy SDK is built on top of [GraphQL](http://graphql.org/). While some knowledge of GraphQL is good to have, you don't have to be an expert to start using it with the Buy SDK. Instead of writing stringed queries and parsing JSON responses, the SDK handles all the query generation and response parsing, exposing only typed models and compile-time checked query structures. The section below will give a brief introduction to this system and provide some examples of how it makes building custom storefronts safe and easy.

### Code Generation

The Buy SDK is built on a hierarchy of generated classes that construct and parse GraphQL queries and response. These classes are generated manually by running a custom Ruby script that relies on the [GraphQL Swift Generation](https://github.com/Shopify/graphql_swift_gen) library. Majority of the generation functionality lives inside the library. Ruby script is responsible for downloading StoreFront GraphQL schema, triggering Ruby gem for code generation, saving generated classes to the specified folder path and providing overrides for custom GraphQL scalar types. The library also includes supporting classes that are required by generated query and response models.


#### Request Models

All generated request models are derived from the `GraphQL.AbstractQuery` type. While this abstract type does contain enough functionality to build a query, you should never use it directly. Let's take a look at an example query for a shop's name:

```swift
// Never do this

let shopQuery = GraphQL.AbstractQuery()
shopQuery.addField(field: "name")

let query = GraphQL.AbstractQuery()
query.addField(field: "shop", subfields: shopQuery)

```
Instead, rely on the typed methods provided in the generated subclasses:

```swift
let query = Storefront.buildQuery { $0
    .shop { $0
        .name()
    }
}
```

Both of the above queries will produce identical GraphQL queries (below) but the latter apporach provides auto-completion and compile-time validation against the GraphQL schema. It will surface an error if requested fields don't exists, aren't the correct type or are deprecated. You also may have noticed that the latter approach resembles the GraphQL query language structure, and this is intentional. The query is both much more legible and easier to write.

```graphql
{ 
  shop { 
    name 
  } 
}
```

#### Response Models

All generated response models are derived from the `GraphQL.AbstractResponse` type. This abstract type provides a similar key-value type interface to a `Dictionary` for accessing field values in GraphQL responses. Just like `GraphQL.AbstractQuery`, you should never use these accessors directly, and instead opt for typed, derived properties in generated subclasses in stead. Let's continue the example of accessing the result of a shop name query:

```swift
// Never do this

let response: GraphQL.AbstractResponse

let shop = response.field("shop") as! GraphQL.AbstractResponse
let name = shop.field("name") as! String
```
Instead, use the typed accessors in generated subclasses:

```swift
// response: Storefront.QueryRoot

let name: String = response.shop.name
```

Again, both of the approach produce the same result but the latter case is safe and requires no casting as it already knows about the expect type.

#### The `Node` protocol

GraphQL shema defines a `Node` interface that declares an `id` field on any conforming type. This makes it convenient to query for any object in the schema given only it's `id`. The concept is carried across to Buy SDK as well but requeries a cast to the correct type. Make sure that requested `Node` by query `id` argument value corresonds to the casted type otherwise it will crash the application. Given this query:

```swift
let id    = GraphQL.ID(rawValue: "NkZmFzZGZhc")
let query = Storefront.buildQuery { $0
    .node(id: id) { $0
        .onOrder { $0
            .id()
            .createdAt()
        }
    }
}
```
accessing the order requires a cast:

```swift
// response: Storefront.QueryRoot

let order = response.node as! Storefront.Order
```

##### Aliases

Aliases are useful when a single query requests multiple fields with the same names at the same nesting level. GraphQL allows only unique field names otherwise multiple fields with the same names would produce a collision. This is where aliases come in. Multiple nodes can be queried by using a unique alias for each one:

```swift
let query = Storefront.buildQuery { $0
    .node(aliasSuffix: "collection", id: GraphQL.ID(rawValue: "NkZmFzZGZhc")) { $0
        .onCollection { $0
            // fields for Collection
        }
    }
    .node(aliasSuffix: "product", id: GraphQL.ID(rawValue: "GZhc2Rm")) { $0
        .onProduct { $0
            // fields for Product
        }
    }
}
```
Accessing the aliased nodes is similar to a plain node:

```swift
// response: Storefront.QueryRoot

let collection = response.aliasedNode(aliasSuffix: "collection") as! Storefront.Collection
let product    = response.aliasedNode(aliasSuffix: "product")    as! Storefront.Product
```

### Graph Client
The `Graph.Client` is core network layer of the Buy SDK. It requires the following to get started:

- your shop domain, the `.myshopify.com` is required
- api key, can be obtained in your shop's admin
- a `URLSession` (optional), if you want to customize the configuration used for network requests
 
```swift
let client = Graph.Client(
	shopDomain: "shoes.myshopify.com", 
	apiKey:     "dGhpcyBpcyBhIHByaXZhdGUgYXBpIGtleQ"
)
```
GraphQL specifies two types of operations - queries and mutations. The `Client` exposes both these types as separate methods for each to maintain type-safety.

#### Queries
Semantically a GraphQL `query` operation is equivalent to a `GET` RESTful call and garantees that no resources will be mutated on the server. With `Graph.Client` you can perform a query operation using:

```swift
public func queryGraphWith(_ query: Storefront.QueryRootQuery, retryHandler: RetryHandler<Storefront.QueryRoot>? = default, completionHandler: QueryCompletion) -> Task
```
For example, let's take a look at how we can query for a shop's name:

```swift
let query = Storefront.buildQuery { $0
    .shop {
        .name()
    }
}

client.queryGraphWith(query) { response, error in
    if let response = response {
        let name = response.shop.name
    } else {
        print("Query failed: \(error)")
    }
}
```

#### Mutations
Semantically a GraphQL `mutation` operation is equivalent to a `PUT`, `POST` or `DELETE` RESTful call. A mutation almost always is accompanied a by an input that represents values that will be updated and a query that is similar to a `query` operation that will contain fields of the modified resource. With `Graph.Client` you can perform a mutation operation using:

```swift
public func mutateGraphWith(_ mutation: Storefront.MutationQuery, retryHandler: RetryHandler<Storefront.Mutation>? = default, completionHandler: MutationCompletion) -> Task
```
For example, let's take a look at how we can reset a customer's password using a recovery token:

```swift
let customerID = GraphQL.ID(rawValue: "YSBjdXN0b21lciBpZA")
let input      = Storefront.CustomerResetInput(resetToken: "c29tZSB0b2tlbiB2YWx1ZQ", password: "abc123")
let mutation   = Storefront.buildMutation { $0
    .customerReset(id: customerID, input: input) { $0
        .customer { $0
            .id()
        }
        .userErrors { $0
            .field()
            .message()
        }
    }
}

client.mutateGraphWith(mutation) { response, error in
    if let mutation = response?.customerReset {
        
        if let customer = mutation.customer, !mutation.userErrors.isEmpty {
            let firstName = customer
        } else {
            
            print("Failed to reset password. Encountered invalid fields:")
            mutation.userErrors.forEach {
                let fieldPath = $0.field?.joined() ?? ""
                print("  \(fieldPath): \($0.message)")
            }
        }
        
    } else {
        print("Failed to reset password: \(error)")
    }
}
```
More often than not, a mutation will rely on some kind of user input. While you should always validate user input before posting a mutation, there are never garantees when it comes to dynamic data. For this reason, you should always request the `userErrors` field on mutations (where available) to provide useful feedback in your UI regarding any issues that were encountered in the mutation query. These errors can include anything from `invalid email address` to `password is too short`.

### Types and models

The Buy SDK provides classes for models that represent resources in the GraphQL schema 1-to-1. These classes are all scoped under the `Storefront` namespace. To access these classes you'll need to provide the entire name:

```swift
let collections: [Storefront.Collection] = []
collection.forEach {
    $0.doSomething()
}
```

Initialize the `GraphClient` with your credentials from the *Mobile App Channel*

```swift
let client = GraphClient(shopDomain: "yourshop.myshopify.com", apiKey: "your-api-key")
```
To learn more about GraphQL types & models go to official [page](http://graphql.org/learn/schema/)

### Queries & Mutations

The Buy SDK is built on GraphQL, which means that you'll inherit all the powerful capabilities GraphQL has to offer. As a result, there's a paradigm shift. With Buy SDK, you'll need to "query" the API and describe in the shape of an object graph what kind of fields and entities the server should return. Let's take a look at how to build a simple query.

GraphQL queries are written in plain text but the SDK offers a builder that abstracts the knowledge of the GraphQL schema and provides auto-completion. There are two types of queries:

#### Query
Using the `buildQuery()` method, we can build a query to retrieve entities and fields. Semantically, these are requivalent to `GET` requests in RESTful APIs. No reasource are modified as a result of a `query`.
```swift
let query = Storefront.buildQuery { $0
    .shop {
        .name()
        .currencyCode()
        .moneyFormat()
    }
}
```
this will produce the following GraphQL query:
```graphql
query {
	shop {
    	name
        currencyCode
        moneyFormat
    }
}
```

#### Mutation
Using the `buildMutation()` method, we can a build a query to modify resources on the server. Semantically, these are equivalent to `POST`, `PUT` and `DELETE` requests in RESTful APIs.
```swift
let mutation = Storefront.buildMutation { $0
    .customerCreate(input: customerInput) { $0
        .customer { $0
            .displayName()
            .firstName()
            .lastName()
        }
    }
}
```

Mutations are slightly different. Unlike simple queries, mutations can require an input object to represent the resource to be created or updated. The above `customerInput` parameter is created by simply initializing a `Storefront.CustomerInput` object like this:
```swift
let customerInput = Storefront.CustomerInput(
    firstName: "John",
    lastName:  "Smith",
    email:     "john.smith@gmail.com",
    password:  "johnny123",
    acceptsMarketing: true
)
```
The above will yield the following GraphQL query:
```graphql
mutation {
	customerCreate(input: {
    	firstName: "John"
        lastName:  "Smith"
        email:     "john.smith@gmail.com"
        password:  "johnny123"
        acceptsMarketing: true
    }) {
    	customer {
    		displayName
        	firstName
        	lastName
        }
    }
}
```
To learn more about GraphQL queries & mutations go to official [page](http://graphql.org/learn/queries/)

### Query Arguments
Example of query arguments:
```graphql
{
  shop {
    products(first:50, sortKey: TITLE) {
      edges {
        node {
          id
          title
        }
      }
    }
  }
}
```
To learn more about GraphQL errors go to official [page](http://graphql.org/learn/queries/#arguments)

### Errors
Example of GraphQL error reponse:
```graphql
{
  "errors": [
    {
      "message": "Field 'Shop' doesn't exist on type 'QueryRoot'",
      "locations": [
        {
          "line": 2,
          "column": 90
        }
      ],
      "fields": [
        "query CollectionsWithProducts",
        "Shop"
      ]
    }
  ]
}
```

### Code Generation
#### Ruby Script
#### Generated query & mutation request models
#### Generated query & mutation response models
#### Node, aliases

### GraphClient
#### Initialization
#### Query & mutations
#### Retry & polling
#### Graph client errors

### Pay Helper

### Case study
#### Fetch Shop info
#### Fetch Collections 
##### Fetch Collections with Products
#### Fetch Collection by ID
#### Fetch Product by ID
#### Create Checkout
#### Update Checkout
##### Update Checkout with Customer Email
##### Update Checkout with Customer Shipping Address
##### Polling Checkout Shipping Rates

### Complete Checkout
#### With Credit Card
#### With Apple Pay
#### Polling Checkout Payment Status

### Handling Errors


### Contributions

We welcome contributions. Follow the steps in [CONTRIBUTING](CONTRIBUTING.md) file.

### Help

For help, please post questions on our forum, in the Shopify APIs & Technology section: https://ecommerce.shopify.com/c/shopify-apis-and-technology

### License

The Mobile Buy SDK is provided under an MIT Licence.  See the [LICENSE](LICENSE) file
