DAY 26

Today you have five topics to work through, and you’ll meet Stepper, DatePicker, DateFormatter, and more.

BetterRest: Introduction

This SwiftUI project is another forms-based app that will ask the user to enter information and convert that all into an alert, which might sound dull – you’ve done this already, right?

Well, yes, but practice is never a bad thing. However, the reason we have a fairly simple project is because I want to introduce you to one of the true power features of iOS development: machine learning (ML).

All iPhones come with a technology called Core ML built right in, which allows us to write code that makes predictions about new data based on previous data it has seen. We’ll start with some raw data, give that to our Mac as training data, then use the results to build an app able to make accurate estimates about new data – all on device, and with complete privacy for users.

The actual app we’re building is called BetterRest, and it’s designed to help coffee drinkers get a good night’s sleep by asking them three questions:

1. When do they want to wake up?
2. Roughly how many hours of sleep do they want?
3. How many cups of coffee do they drink per day?

Once we have those three values, we’ll feed them into Core ML to get a result telling us when they ought to go to bed. If you think about it, there are billions of possible answers – all the various wake times multiplied by all the number of sleep hours, multiplied again by the full range of coffee amounts.

That’s where machine learning comes in: using a technique called regression analysis we can ask the computer to come up with an algorithm able to represent all our data. This in turn allows it to apply the algorithm to fresh data it hasn’t seen before, and get accurate results.

Entering numbers with Stepper

SwiftUI has two ways of letting users enter numbers, and the one we’ll be using here is Stepper: a simple - and + button that can be tapped to select a precise number. The other option is Slider, which we’ll be using later on – it also lets us select from a range of values, but less precisely.

Steppers are smart enough to work with any kind of number type you like, so you can bind them to Int, Double, and more, and it will automatically adapt. For example, we might create a property like this:

@State private var sleepAmount = 8.0

We could then bind that to a stepper so that it showed the current value, like this:

Stepper("\(sleepAmount) hours", value: $sleepAmount)

Now, as a father of two kids I can’t tell you how much I love to sleep, but even I can’t sleep that much. Fortunately, Stepper lets us limit the values we want to accept by providing an in range, like this:

Stepper("\(sleepAmount) hours", value: $sleepAmount, in: 4...12)

With that change, the stepper will start at 8, then allow the user to move between 4 and 12 inclusive, but not beyond. This allows us to control the sleep range so that users can’t try to sleep for 24 hours, but it also lets us reject impossible values – you can’t sleep for -1 hours, for example.

There’s a fourth useful parameter for Stepper, which is a step value – how far to move the value each time - or + is tapped. Again, this can be any sort of number, but it does need to match the type used for the binding. So, if you are binding to an integer you can’t then use a Double for the step value.

In this instance, we might say that users can select any sleep value between 4 and 12, moving in 15 minute increments:

Stepper("\(sleepAmount) hours", value: $sleepAmount, in: 4...12, step: 0.25)

That’s starting to look useful – we have a precise range of reasonable values, a sensible step increment, and users can see exactly what they have chosen each time.

Before we move on, though, let’s fix that text: it says 8.000000 right now, which is accurate but a little too accurate. To fix this, we can just ask Swift to format the Double using formatted():

Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)


Selecting dates and times with DatePicker
