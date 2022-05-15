DAY 27

Today we’re going to build our project, combining both SwiftUI and Core ML in remarkably few lines of code – I think you’ll be impressed. 

What I hope you’ll get from this project – apart from all the SwiftUI goodies, of course – is just a little glimpse into the wider world of app development. Core ML is just one of Apple’s powerhouse frameworks, and there are over a dozen more: ARKit, Core Graphics, Core Image, MapKit, WebKit, and more, are all waiting to be discovered when you’re ready.

Today you have three topics to work through, and you’ll get busy implementing Stepper, DatePicker, DateFormatter, and more in a real app.



Building a basic layout


This app is going to allow user input with a date picker and two steppers, which combined will tell us when they want to wake up, how much sleep they usually like, and how much coffee they drink.

So, please start by adding three properties that let us store the information for those controls:

@State private var wakeUp = Date.now
@State private var sleepAmount = 8.0
@State private var coffeeAmount = 1

Inside our body we’re going to place three sets of components wrapped in a VStack and a NavigationView, so let’s start with the wake up time. Replace the default “Hello World” text view with this:

NavigationView {
    VStack {
        Text("When do you want to wake up?")
            .font(.headline)

        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
            .labelsHidden()

        // more to come
    }
}

We’ve asked for .hourAndMinute configuration because we care about the time someone wants to wake up and not the day, and with the labelsHidden() modifier we don’t get a second label for the picker – the one above is more than enough.
Next we’re going to add a stepper to let users choose roughly how much sleep they want. By giving this thing an in range of 4...12 and a step of 0.25 we can be sure they’ll enter sensible values, but we can combine that with the formatted() method so we see numbers like “8” and not “8.000000”.

Add this code in place of the // more to come comment”

Text("Desired amount of sleep")
    .font(.headline)

Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
Finally we’ll add one last stepper and label to handle how much coffee they drink. This time we’ll use the range of 1 through 20 (because surely 20 coffees a day is enough for anyone?), but we’ll also display one of two labels inside the stepper to handle pluralization better. If the user has set a coffeeAmount of exactly 1 we’ll show “1 cup”, otherwise we’ll use that amount plus “cups”, all decided using the ternary conditional operator.

Add these inside the VStack, below the previous views:

Text("Daily coffee intake")
    .font(.headline)

Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)

The final thing we need is a button to let users calculate the best time they should go to sleep. We could do that with a simple button at the end of the VStack, but to spice up this project a little I want to try something new: we’re going to add a button directly to the navigation bar.

First we need a method for the button to call, so add an empty calculateBedtime() method like this:

func calculateBedtime() {
}

Now we need to use the toolbar() modifier to add a trailing button to the navigation view. We used this previously along with ToolbarItemGroup to place a button next to the keyboard, but here our needs are much simpler: we just want a single button in the navigation bar, which can be done by adding a button directly to the toolbar.

While we’re here, we might as well also use navigationTitle() to put some text at the top.

So, add these modifiers to the VStack:

.navigationTitle("BetterRest")
.toolbar {
    Button("Calculate", action: calculateBedtime)
}

Tip: Our button will automatically be placed in the top-right corner for left-to-right languages such as English, but will automatically move to the other side for right-to-left languages.



Connecting SwiftUI to Core ML


In the same way that SwiftUI makes user interface development easy, Core ML makes machine learning easy. How easy? Well, once you have a trained model you can get predictions in just two lines of code – you just need to send in the values that should be used as input, then read what comes back.

In our case, we already made a Core ML model using Xcode’s Create ML app, so we’re going to use that. You should have saved it on your desktop, so please now drag it into the project navigator in Xcode. When Xcode prompts you to “Copy items if needed”, please make sure that box is checked.

When you add an .mlmodel file to Xcode, it will automatically create a Swift class of the same name. You can’t see the class, and don’t need to – it’s generated automatically as part of the build process. However, it does mean that if your model file is named oddly then the auto-generated class name will also be named oddly.

No matter what name your model file has, please rename it to be “SleepCalculator.mlmodel”, thus making the auto-generated class be called SleepCalculator.

How can we be sure that’s the class name? Well, just select the model file itself and Xcode will show you more information. You’ll see it knows our author, the name of the Swift class that gets made, plus a list of inputs and their types, and an output plus type too – these were encoded in the model file, which is why it was (comparatively!) so big.

We’re going to start filling in calculateBedtime() in just a moment, but before that can start we need to add an import for CoreML because we’re using functionality outside of SwiftUI.

So, scroll to the top of ContentView.swift and add this before the import line for SwiftUI:

import CoreML

Tip: You don’t strictly need to add CoreML before SwiftUI, but keeping your imports in alphabetical order makes them easier to check later on.

Okay, now we can turn to calculateBedtime(). First, we need to create an instance of the SleepCalculator class, like this:

do {
    let config = MLModelConfiguration()
    let model = try SleepCalculator(configuration: config)

    // more code here
} catch {
    // something went wrong!
}

That model instance is the thing that reads in all our data, and will output a prediction. The configuration is there in case you need to enable a handful of what are fairly obscure options – perhaps folks working in machine learning full time need these, but honestly I’d guess only 1 in 1000 folks actually use these.

I do want you to focus on the do/catch blocks, because using Core ML can throw errors in two places: loading the model as seen above, but also when we ask for predictions. Honestly, I can’t think I’ve ever had a prediction fail in my life, but there’s no harm being safe!

Anyway, we trained our model with a CSV file containing the following fields:

* “wake”: when the user wants to wake up. This is expressed as the number of seconds from midnight, so 8am would be 8 hours multiplied by 60 multiplied by 60, giving 28800.
* “estimatedSleep”: roughly how much sleep the user wants to have, stored as values from 4 through 12 in quarter increments.
* “coffee”: roughly how many cups of coffee the user drinks per day.

So, in order to get a prediction out of our model, we need to fill in those values.

We already have two of them, because our sleepAmount and coffeeAmount properties are mostly good enough – we just need to convert coffeeAmount from an integer to a Double so that Swift is happy.

But figuring out the wake time requires more thinking, because our wakeUp property is a Date not a Double representing the number of seconds. Helpfully, this is where Swift’s DateComponents type comes in: it stores all the parts required to represent a date as individual values, meaning that we can read the hour and minute components and ignore the rest. All we then need to do is multiply the minute by 60 (to get seconds rather than minutes), and the hour by 60 and 60 (to get seconds rather than hours).

We can get a DateComponents instance from a Date with a very specific method call: Calendar.current.dateComponents(). We can then request the hour and minute components, and pass in our wake up date. The DateComponents instance that comes back has properties for all its components – year, month, day, timezone, etc – but most of them won’t be set. The ones we asked for – hour and minute – will be set, but will be optional, so we need to unwrap them carefully.

So, put this in place of the // more code here comment in calculateBedtime():

let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
let hour = (components.hour ?? 0) * 60 * 60
let minute = (components.minute ?? 0) * 60

That code uses 0 if either the hour or minute can’t be read, but realistically that’s never going to happen so it will result in hour and minute being set to those values in seconds.

The next step is to feed our values into Core ML and see what comes out. This is done using the prediction() method of our model, which wants the wake time, estimated sleep, and coffee amount values required to make a prediction, all provided as Double values. We just calculated our hour and minute as seconds, so we’ll add those together before sending them in.

Please add this just below the previous code:

let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

// more code here

With that in place, prediction now contains how much sleep they actually need. This almost certainly wasn’t part of the training data our model saw, but was instead computed dynamically by the Core ML algorithm.

However, it’s not a helpful value for users – it will be some number in seconds. What we want is to convert that into the time they should go to bed, which means we need to subtract that value in seconds from the time they need to wake up.
Thanks to Apple’s powerful APIs, that’s just one line of code – you can subtract a value in seconds directly from a Date, and you’ll get back a new Date! So, add this line of code after the prediction:

let sleepTime = wakeUp - prediction.actualSleep

And now we know exactly when they should go to sleep. Our final challenge, for now at least, is to show that to the user. We’ll be doing this with an alert, because you’ve already learned how to do that and could use the practice.

So, start by adding three properties that determine the title and message of the alert, and whether or not it’s showing:

@State private var alertTitle = ""
@State private var alertMessage = ""
@State private var showingAlert = false

We can immediately use those values in calculateBedtime(). If our calculation goes wrong – if reading a prediction throws an error – we can replace the // something went wrong comment with some code that sets up a useful error message:

alertTitle = "Error"
alertMessage = "Sorry, there was a problem calculating your bedtime."

And regardless of whether or not the prediction worked, we should show the alert. It might contain the results of their prediction or it might contain the error message, but it’s still useful. So, put this at the end of calculateBedtime(), after the catch block:

showingAlert = true

If the prediction worked we create a constant called sleepTime that contains the time they need to go to bed. But this is a Date rather than a neatly formatted string, so we’ll pass it through the formatted() method to make sure it’s human-readable, then assign it to alertMessage.

So, put these final lines of code into calculateBedtime(), directly after where we set the sleepTime constant:

alertTitle = "Your ideal bedtime is…"

alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)

To wrap up this stage of the app, we just need to add an alert() modifier that shows alertTitle and alertMessage when showingAlert becomes true.

Please add this modifier to our VStack:

.alert(alertTitle, isPresented: $showingAlert) {
    Button("OK") { }
} message: {
    Text(alertMessage)
}


Cleaning up the user interface


Let’s look at the usability problem first, because it’s possible it hasn’t occurred to you. When you read Date.now it is automatically set to the current date and time. So, when we create our wakeUp property with a new date, the default wake up time will be whatever time it is right now.

Although the app needs to be able to handle any sort of times – we don’t want to exclude folks on night shift, for example – I think it’s safe to say that a default wake up time somewhere between 6am and 8am is going to be more useful to the vast majority of users.

To fix this we’re going to add a computed property to our ContentView struct that contains a Date value referencing 7am of the current day. This is surprisingly easy: we can just create a new DateComponents of our own, and use Calendar.current.date(from:) to convert those components into a full date.

So, add this property to ContentView now:

var defaultWakeTime: Date {
    var components = DateComponents()
    components.hour = 7
    components.minute = 0
    return Calendar.current.date(from: components) ?? Date.now
}

And now we can use that for the default value of wakeUp in place of Date.now:
@State private var wakeUp = defaultWakeTime

If you try compiling that code you’ll see it fails, and the reason is that we’re accessing one property from inside another – Swift doesn’t know which order the properties will be created in, so this isn’t allowed.

The fix here is simple: we can make defaultWakeTime a static variable, which means it belongs to the ContentView struct itself rather than a single instance of that struct. This in turn means defaultWakeTime can be read whenever we want, because it doesn’t rely on the existence of any other properties.

So, change the property definition to this:

static var defaultWakeTime: Date {

That fixes our usability problem, because the majority of users will find the default wake up time is close to what they want to choose.

As for our styling, this requires more effort. A simple change to make is to switch to a Form rather than a VStack. So, find this:

NavigationView {
    VStack {
And replace it with this:
NavigationView {
    Form {

That immediately makes the UI look better – we get a clearly segmented table of inputs, rather than some controls centered in a white space.

There’s still an annoyance in our form: every view inside the form is treated as a row in the list, when really all the text views form part of the same logical form section.

We could use Section views here, with our text views as titles – you’ll get to experiment with that in the challenges. Instead, we’re going to wrap each pair of text view and control with a VStack so they are seen as a single row each.
Go ahead and wrap each of the pairs in a VStack now, using .leading for the alignment and 0 for spacing. For example, you’d take these two views:

Text("Desired amount of sleep")
    .font(.headline)

Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
And wrap them in a VStack like this:

VStack(alignment: .leading, spacing: 0) {
    Text("Desired amount of sleep")
        .font(.headline)

    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
}

