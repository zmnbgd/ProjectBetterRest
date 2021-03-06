//
//  ContentView.swift
//  BetterRest
//
//  Created by Marko Zivanovic on 10.5.22..
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
        
    }
    
    var body: some View {
        NavigationView {
            Form {
//MARK: Challenge 1. Replace each VStack in our form with a Section, where the text view is the title of the section. Do you prefer this layout or the VStack layout? It’s your app – you choose!
                
//MARK Challendge 1. I changed it only for the first section, for other sections I changed it differently because I didn't like the UI
                
                Section(header: Text("When do you want to wake up")) {
    
                    DatePicker("Plese enter the time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                    Text("Desire amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                } header: {
                    Text("Select sleep time")
                }
                
                Section {
//                    VStack(alignment: .leading, spacing: 0) {
//                    Text("Daily coffee intake")
//                        .font(.headline)
//
//              Stepper(coffeAmount == 1 ? "1 cup" : "\(coffeAmount) cups", value: $coffeAmount, in: 1...10)
                    
                    
//MARK: Challenge 2. Replace the “Number of cups” stepper with a Picker showing the same range of values.
                    
                    Picker("Daily coffee intake", selection: $coffeAmount) {
                        ForEach(1..<11) {
                            Text("\($0) cup")
                                .font(.headline)
                        }
                    }
                } header: {
                    Text("How much you drink coffee")
                }
                
                Section(header: Text("Your bedtime is ...")) {
                    VStack(alignment: .leading, spacing: 0)  {
                        Text(calculateBedtime())
                            .font(.headline)
                    }

                } 
            }
            
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("Ok") { }
//            } message: {
//                Text(alertMessage)
//            }

        }

    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            //MARK: Challenge 3. Change the user interface so that it always shows their recommended bedtime using a nice and large font. You should be able to remove the “Calculate” button entirely.
            let formater = DateFormatter()
            formater.timeStyle = .short
            
            return formater.string(from: sleepTime)
             
        } catch {
            
            return "Sorry, you forgot to wear pyjamas"
            
//            alertTitle = "Your ideal cedtime is ..."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
//        } catch {
//            alertTitle = "Error"
//            alertMessage = "Sorry there was a problem alculating your bedtime"
//        }
//        showingAlert = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

}
