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


SwiftUI gives us a dedicated picker type called DatePicker that can be bound to a date property. Yes, Swift has a dedicated type for working with dates, and it’s called – unsurprisingly – Date.
So, to use it you’d start with an @State property such as this:

@State private var wakeUp = Date.now

You could then bind that to a date picker like this:

DatePicker("Please enter a date", selection: $wakeUp)

Try running that in the simulator so you can see how it looks. You should see a tappable options to control days and times, plus the “Please enter a date” label on the left.
Now, you might think that label looks ugly, and try replacing it with this:

DatePicker("", selection: $wakeUp)

But if you do that you now have two problems: the date picker still makes space for a label even though it’s empty, and now users with the screen reader active (more familiar to us as VoiceOver) won’t have any idea what the date picker is for.

A better alternative is to use the labelsHidden() modifier, like this:

DatePicker("Please enter a date", selection: $wakeUp)
    .labelsHidden()

That still includes the original label so screen readers can use it for VoiceOver, but now they aren’t visible onscreen any more – the date picker won’t be pushed to one side by some empty text.

Date pickers provide us with a couple of configuration options that control how they work. First, we can use displayedComponents to decide what kind of options users should see:

* If you don’t provide this parameter, users see a day, hour, and minute.
* If you use .date users see month, day, and year.
* If you use .hourAndMinute users see just the hour and minute components.

we can select a precise time like this:

DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)

Finally, there’s an in parameter that works just the same as with Stepper: we can provide it with a date range, and the date picker will ensure the user can’t select beyond it.

Finally, there’s an in parameter that works just the same as with Stepper: we can provide it with a date range, and the date picker will ensure the user can’t select beyond it.
Now, we’ve been using ranges for a while now, and you’re used to seeing things like 1...5 or 0..<10, but we can also use Swift dates with ranges. For example:

func exampleDates() {
    // create a second Date instance set to one day in seconds from now
    let tomorrow = Date.now.addingTimeInterval(86400)

    // create a range from those two
    let range = Date.now...tomorrow
}


That’s really useful with DatePicker, but there’s something even better: Swift lets us form one-sided ranges – ranges where we specify either the start or end but not both, leaving Swift to infer the other side.

For example, we could create a date picker like this:

DatePicker("Please enter a date", selection: $wakeUp, in: Date.now...)

That will allow all dates in the future, but none in the past – read it as “from the current date up to anything.”



Working with dates 


Having users enter dates is as easy as binding an @State property of type Date to a DatePicker SwiftUI control, but things get a little woolier afterwards.

You see, working with dates is hard. Like, really hard – way harder than you think. Way harder than I think, and I’ve been working with dates for years.

Take a look at this trivial example:

let now = Date.now
let tomorrow = Date.now.addingTimeInterval(86400)
let range = now...tomorrow

That creates a range from now to the same time tomorrow (86400 is the number of seconds in a day).

That might seem easy enough, but do all days have 86,400 seconds? If they did, a lot of people would be out of jobs! Think about daylight savings time: sometimes clocks go forward (losing an hour) and sometimes go backwards (gaining an hour), meaning that we might have 23 or 25 hours in those days. Then there are leap seconds: times that get added to the clocks in order to adjust for the Earth’s slowing rotation.

If you think that’s hard, try running this from your Mac’s terminal: cal. This prints a simple calendar for the current month, showing you the days of the week. Now try running cal 9 1752, which shows you the calendar for September 1752 – you’ll notice 12 whole days are missing, thanks to the calendar moving from Julian to Gregorian.

Now, the reason I’m saying all this isn’t to scare you off – dates are inevitable in our programs, after all. Instead, I want you to understand that for anything significant – any usage of dates that actually matters in our code – we should rely on Apple’s frameworks for calculations and formatting.

In the project we’re making we’ll be using dates in three ways:

1. Choosing a sensible default “wake up” time.
2. Reading the hour and minute they want to wake up.
3. Showing their suggested bedtime neatly formatted.

We could, if we wanted, do all that by hand, but then you’re into the realm of daylight savings, leap seconds, and Gregorian calendars.

Much better is to have iOS do all that hard work for us: it’s much less work, and it’s guaranteed to be correct regardless of the user’s region settings.

Let’s tackle each of those individually, starting with choosing a sensible wake up time.

As you’ve seen, Swift gives us Date for working with dates, and that encapsulates the year, month, date, hour, minute, second, timezone, and more. However, we don’t want to think about most of that – we want to say “give me an 8am wake up time, regardless of what day it is today.”

Swift has a slightly different type for that purpose, called DateComponents, which lets us read or write specific parts of a date rather than the whole thing.

So, if we wanted a date that represented 8am today, we could write code like this:

var components = DateComponents()
components.hour = 8
components.minute = 0
let date = Calendar.current.date(from: components)

Now, because of difficulties around date validation, that date(from:) method actually returns an optional date, so it’s a good idea to use nil coalescing to say “if that fails, just give me back the current date”, like this:

let date = Calendar.current.date(from: components) ?? Date.now

The second challenge is how we could read the hour they want to wake up. Remember, DatePicker is bound to a Date giving us lots of information, so we need to find a way to pull out just the hour and minute components.

Again, DateComponents comes to the rescue: we can ask iOS to provide specific components from a date, then read those back out. One hiccup is that there’s a disconnect between the values we request and the values we get thanks to the way DateComponents works: we can ask for the hour and minute, but we’ll be handed back a DateComponents instance with optional values for all its properties. Yes, we know hour and minute will be there because those are the ones we asked for, but we still need to unwrap the optionals or provide default values.

So, we might write code like this:

let components = Calendar.current.dateComponents([.hour, .minute], from: someDate)
let hour = components.hour ?? 0
let minute = components.minute ?? 0

The last challenge is how we can format dates and times, and here we have two options.
First is to rely on the format parameter that has worked so well for us in the past, and here we can ask for whichever parts of the date we want to show.

For example, if we just wanted the time from a date we would write this:

Text(Date.now, format: .dateTime.hour().minute())

Or if we wanted the day, month, and year, we would write this:

Text(Date.now, format: .dateTime.day().month().year())

You might wonder how that adapts to handling different date formats – for example, here in the UK we use day/month/year, but in some other countries they use month/day/year. Well, the magic is that we don’t need to worry about this: when we write day().month().year() we’re asking for that data, not arranging it, and iOS will automatically format that data using the user’s preferences.

As an alternative, we can use the formatted() method directly on dates, passing in configuration options for how we want both the date and the time to be formatted, like this:

Text(Date.now.formatted(date: .long, time: .shortened))

The point is that dates are hard, but Apple has provided us with stacks of helpers to make them less hard. If you learn to use them well you’ll write less code, and write better code too!




