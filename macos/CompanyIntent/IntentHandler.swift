//
//  IntentHandler.swift
//  CompanyIntent
//
//  Created by hillel on 14/06/2023.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {

    func provideCompanyOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<Company> {
              
        let sharedDefaults = UserDefaults.init(suiteName: "group.com.invoiceninja.app")
        var exampleData: WidgetData = WidgetData(url: "", companies: [:])

        if sharedDefaults != nil {
          do {
            let shared = sharedDefaults!.string(forKey: "widget_data")
              
              print("## Shared: \(shared!)")
              
            if shared != nil {
              let decoder = JSONDecoder()
              exampleData = try decoder.decode(WidgetData.self, from: shared!.data(using: .utf8)!)
            }
          } catch {
            print(error)
          }
        }
        
        let companies = exampleData.companies.values.map { company in
            
            let company = Company(
                identifier: company.id,
                display: company.name
            )
            
            return company
        }
          
        let collection = INObjectCollection(items: companies)
        
        return collection
        
    }
    
    func provideCurrencyOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<Currency> {
              
        let sharedDefaults = UserDefaults.init(suiteName: "group.com.invoiceninja.app")
        var exampleData: WidgetData = WidgetData(url: "", companies: [:])

        if sharedDefaults != nil {
          do {
            let shared = sharedDefaults!.string(forKey: "widget_data")
              
              print("## Shared: \(shared!)")
              
            if shared != nil {
              let decoder = JSONDecoder()
              exampleData = try decoder.decode(WidgetData.self, from: shared!.data(using: .utf8)!)
            }
          } catch {
            print(error)
          }
        }
        
        let company = exampleData.companies[(intent.company?.identifier)!]
        let currencies = company!.currencies.values.map { currency in
            
            let currency = Currency(
                identifier: currency.id,
                display: currency.name
            )
            
            return currency
        }
          
        let collection = INObjectCollection(items: currencies)
        
        return collection
        
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
