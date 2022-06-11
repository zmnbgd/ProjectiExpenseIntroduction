DAY 36


in the process you’ll learn how to show another screen, how to share data across screens, how to load and save user data, and more – the kinds of features that really help take your SwiftUI skills to the next level.

That doesn’t mean the app is perfect – as you’ll learn later, UserDefaults isn’t the ideal choice for what we’re doing here, and instead something like the much bigger and more complex Core Data would be a better fit – but that’s okay. Remember, we’re setting out to build something small and work our way up, rather than just jumping into one all-encompassing mega-project.

Today you have seven topics to work through, in which you’ll learn about @StateObject, sheet(), onDelete(), and more.



iExpense: Introduction


Our next two projects are going to start pushing your SwiftUI skills beyond the basics, as we explore apps that have multiple screens, that load and save user data, and have more complex user interfaces.
In this project we’re going to build iExpense, which is an expense tracker that separates personal costs from business costs. At its core this is an app with a form (how much did you spend?) and a list (here are the amounts you spent), but in order to accomplish those two things you’re going to need to learn how to:
* Present and dismiss a second screen of data.
* Delete rows from a list
* Save and load user data
…and more.




Why @State only works with structs



SwiftUI’s State property wrapper is designed for simple data that is local to the current view, but as soon as you want to share data between views it stops being useful.

Let’s break this down with some code – here’s a struct to store a user’s first and last name:

struct User {
    var firstName = "Bilbo"
    var lastName = "Baggins"
}

We can now use that in a SwiftUI view by creating an @State property and attaching things to $user.firstName and $user.lastName, like this:

struct ContentView: View {
    @State private var user = User()

    var body: some View {
        VStack {
            Text("Your name is \(user.firstName) \(user.lastName).")

            TextField("First name", text: $user.firstName)
            TextField("Last name", text: $user.lastName)
        }
    }
}

That all works: SwiftUI is smart enough to understand that one object contains all our data, and will update the UI when either value changes. Behind the scenes, what’s actually happening is that each time a value inside our struct changes the whole struct changes – it’s like a new user every time we type a key for the first or last name. That might sound wasteful, but it’s actually extremely fast.

Previously we looked at the differences between classes and structs, and there were two important differences I mentioned. First, that structs always have unique owners, whereas with classes multiple things can point to the same value. And second, that classes don’t need the mutating keyword before methods that change their properties, because you can change properties of constant classes.

In practice, what this means is that if we have two SwiftUI views and we send them both the same struct to work with, they actually each have a unique copy of that struct; if one changes it, the other won’t see that change. On the other hand, if we create an instance of a class and send that to both views, they will share changes.

For SwiftUI developers, what this means is that if we want to share data between multiple views – if we want two or more views to point to the same data so that when one changes they all get those changes – we need to use classes rather than structs.

So, please change the User struct to be a class. From this:

struct User {
To this:
class User {

Now run the program again and see what you think.

Spoiler: it doesn’t work any more. Sure, we can type into the text fields just like before, but the text view above doesn’t change.

When we use @State, we’re asking SwiftUI to watch a property for changes. So, if we change a string, flip a Boolean, add to an array, and so on, the property has changed and SwiftUI will re-invoke the body property of the view.

When User was a struct, every time we modified a property of that struct Swift was actually creating a new instance of the struct. @State was able to spot that change, and automatically reloaded our view. Now that we have a class, that behavior no longer happens: Swift can just modify the value directly.

Remember how we had to use the mutating keyword for struct methods that modify properties? This is because if we create the struct’s properties as variable but the struct itself is constant, we can’t change the properties – Swift needs to be able to destroy and recreate the whole struct when a property changes, and that isn’t possible for constant structs. Classes don’t need the mutating keyword, because even if the class instance is marked as constant Swift can still modify variable properties.

I know that all sounds terribly theoretical, but here’s the twist: now that User is a class the property itself isn’t changing, so @State doesn’t notice anything and can’t reload the view. Yes, the values inside the class are changing, but @State doesn’t monitor those, so effectively what’s happening is that the values inside our class are being changed but the view isn’t being reloaded to reflect that change.

To fix this, it’s time to leave @State behind. Instead we need a more powerful property wrapper called @StateObject.




Sharing SwiftUI state with @StateObject


If you want to use a class with your SwiftUI data – which you will want to do if that data should be shared across more than one view – then SwiftUI gives us three property wrappers that are useful: @StateObject, @ObservedObject, and @EnvironmentObject. We’ll be looking at environment objects later on, but for now let’s focus on the first two.

Here’s some code that creates a User class, and shows that user data in a view:  

class User {
    var firstName = "Bilbo"
    var lastName = "Baggins"
}

struct ContentView: View {
    @State private var user = User()

    var body: some View {
        VStack {
            Text("Your name is \(user.firstName) \(user.lastName).")

            TextField("First name", text: $user.firstName)
            TextField("Last name", text: $user.lastName)
        }
    }
}

However, that code won’t work as intended: we’ve marked the user property with @State, which is designed to track local structs rather than external classes. As a result, we can type into the text fields but the text view above won’t be updated.
To fix this, we need to tell SwiftUI when interesting parts of our class have changed. By “interesting parts” I mean parts that should cause SwiftUI to reload any views that are watching our class – it’s possible you might have lots of properties inside your class, but only a few should be exposed to the wider world in this way.

Our User class has two properties: firstName and lastName. Whenever either of those two changes, we want to notify any views that are watching our class that a change has happened so they can be reloaded. We can do this using the @Published property observer, like this:

class User {
    @Published var firstName = "Bilbo"
    @Published var lastName = "Baggins"
}

@Published is more or less half of @State: it tells Swift that whenever either of those two properties changes, it should send an announcement out to any SwiftUI views that are watching that they should reload.

How do those views know which classes might send out these notifications? That’s another property wrapper, @StateObject, which is the other half of @State – it tells SwiftUI that we’re creating a new class instance that should be watched for any change announcements.

So, change the user property to this:

@StateObject var user = User()

I removed the private access control there, but whether or not you use it depends on your usage – if you’re intending to share that object with other views then marking it as private will just cause confusion.

Now that we’re using @StateObject, our code will no longer compile. It’s not a problem, and in fact it’s expected and easy to fix: the @StateObject property wrapper can only be used on types that conform to the ObservableObject protocol. This protocol has no requirements, and really all it means is “we want other things to be able to monitor this for changes.”
So, modify the User class to this:

class User: ObservableObject {
    @Published var firstName = "Bilbo"
    @Published var lastName = "Baggins"
}

Our code will now compile again, and, even better, it will now actually work again – you can run the app and see the text view update when either text field is changed.

As you’ve seen, rather than just using @State to declare local state, we now take three steps:
* Make a class that conforms to the ObservableObject protocol.
* Mark some properties with @Published so that any views using the class get updated when they change.
* Create an instance of our class using the @StateObject property wrapper.


The end result is that we can have our state stored in an external object, and, even better, we can now use that object in multiple views and have them all point to the same values.

However, there is a catch. Like I said earlier, @StateObject tells SwiftUI that we’re creating a new class instance that should be watched for any change announcements, but that should only be used when you’re creating the object like we are with our User instance.

When you want to use a class instance elsewhere – when you’ve created it in view A using @StateObject and want to use that same object in view B – you use a slightly different property wrapper called @ObservedObject. That’s the only difference: when creating the shared data use @StateObject, but when you’re just using it in a different view you should use @ObservedObject instead.




Showing and hiding views



There are several ways of showing views in SwiftUI, and one of the most basic is a sheet: a new view presented on top of our existing one. On iOS this automatically gives us a card-like presentation where the current view slides away into the distance a little and the new view animates in on top.

Sheets work much like alerts, in that we don’t present them directly with code such as mySheet.present() or similar. Instead, we define the conditions under which a sheet should be shown, and when those conditions become true or false the sheet will either be presented or dismissed respectively.

Let’s start with a simple example, which will be showing one view from another using a sheet. First, we create the view we want to show inside a sheet, like this:

struct SecondView: View {
    var body: some View {
        Text("Second View")
    }
}

There’s nothing special about that view at all – it doesn’t know it’s going to be shown in a sheet, and doesn’t need to know it’s going to be shown in a sheet.

Next we create our initial view, which will show the second view. We’ll make it simple, then add to it:

struct ContentView: View { 
    var body: some View {
        Button("Show Sheet") {
            // show the sheet
        }
    }
}

Filling that in requires four steps, and we’ll tackle them individually.

First, we need some state to track whether the sheet is showing. Just as with alerts, this can be a simple Boolean, so add this property to ContentView now:

@State private var showingSheet = false

Second, we need to toggle that when our button is tapped, so replace the // show the sheet comment with this:

showingSheet.toggle()


Third, we need to attach our sheet somewhere to our view hierarchy. If you remember, we show alerts using isPresented with a two-way binding to our state property, and we use something almost identical here: sheet(isPresented:).
sheet() is a modifier just like alert(), so please add this modifier to our button now:

.sheet(isPresented: $showingSheet) {
    // contents of the sheet
}

Fourth, we need to decide what should actually be in the sheet. In our case, we already know exactly what we want: we want to create and show an instance of SecondView. In code that means writing SecondView(), then… er… well, that’s it.
So, the finished ContentView struct should look like this:

struct ContentView: View {
    @State private var showingSheet = false

    var body: some View {
        Button("Show Sheet") {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            SecondView()
        }
    }
}

If you run the program now you’ll see you can tap the button to have our second view slide upwards from the bottom, and you can then drag that down to dismiss it.

When you create a view like this, you can pass in any parameters it needs to work. For example, we could require that SecondView be sent a name it can display, like this:

struct SecondView: View {
    let name: String

    var body: some View {
        Text("Hello, \(name)!")
    }
}

And now just using SecondView() in our sheet isn’t good enough – we need to pass in a name string to be shown. For example, we could pass in my Twitter username like this:

.sheet(isPresented: $showingSheet) {
    SecondView(name: "@twostraws")
}

Now the sheet will show “Hello, @twostraws”.

Swift is doing a ton of work on our behalf here: as soon as we said that SecondView has a name property, Swift ensured that our code wouldn’t even build until all instances of SecondView() became SecondView(name: "some name"), which eliminates a whole range of possible errors.

Before we move on, there’s one more thing I want to demonstrate, which is how to make a view dismiss itself. Yes, you’ve seen that the user can just swipe downwards, but sometimes you will want to dismiss views programmatically – to make the view go away because a button was pressed, for example.

To dismiss another view we need another property wrapper – and yes, I realize that so often the solution to a problem in SwiftUI is to use another property wrapper.

Anyway, this new one is called @Environment, and it allows us to create properties that store values provided to us externally. Is the user in light mode or dark mode? Have they asked for smaller or larger fonts? What timezone are they on? All these and more are values that come from the environment, and in this instance we’re going to ask the environment to dismiss our view.

Yes, we need to ask the environment to dismiss our view, because it might have been presented in any number of different ways. So, we’re effectively saying “hey, figure out how my view was presented, then dismiss it appropriately.”
To try it out add this property to SecondView, which creates a property called dismiss based on a value from the environment:

@Environment(\.dismiss) var dismiss

Now replace the text view in SecondView with this button:

Button("Dismiss") {
    dismiss()
}



Deleting items using onDelete


SwiftUI gives us the onDelete() modifier for us to use to control how objects should be deleted from a collection. In practice, this is almost exclusively used with List and ForEach: we create a list of rows that are shown using ForEach, then attach onDelete() to that ForEach so the user can remove rows they don’t want.

This is another place where SwiftUI does a heck of a lot of work on our behalf, but it does have a few interesting quirks as you’ll see.

First, let’s construct an example we can work with: a list that shows numbers, and every time we tap the button a new number appears. Here’s the code for that:

struct ContentView: View {
    @State private var numbers = [Int]()
    @State private var currentNumber = 1

    var body: some View {
        VStack {
            List {
                ForEach(numbers, id: \.self) {
                    Text("Row \($0)")
                }
            }

            Button("Add Number") {
                numbers.append(currentNumber)
                currentNumber += 1
            }
        }
    }
}

Now, you might think that the ForEach isn’t needed – the list is made up of entirely dynamic rows, so we could write this instead:

List(numbers, id: \.self) {
    Text("Row \($0)")
}

That would also work, but here’s our first quirk: the onDelete() modifier only exists on ForEach, so if we want users to delete items from a list we must put the items inside a ForEach. This does mean a small amount of extra code for the times when we have only dynamic rows, but on the flip side it means it’s easier to create lists where only some rows can be deleted.

In order to make onDelete() work, we need to implement a method that will receive a single parameter of type IndexSet. This is a bit like a set of integers, except it’s sorted, and it’s just telling us the positions of all the items in the ForEach that should be removed.

Because our ForEach was created entirely from a single array, we can actually just pass that index set straight to our numbers array – it has a special remove(atOffsets:) method that accepts an index set.

So, add this method to ContentView now:

func removeRows(at offsets: IndexSet) {
    numbers.remove(atOffsets: offsets)
} 

Finally, we can tell SwiftUI to call that method when it wants to delete data from the ForEach, by modifying it to this:

ForEach(numbers, id: \.self) {
    Text("Row \($0)")
}
.onDelete(perform: removeRows)

Now go ahead and run your app, then add a few numbers. When you’re ready, swipe from right to left across any of the rows in your list, and you should find a delete button appears. You can tap that, or you can also use iOS’s swipe to delete functionality by swiping further.

Given how easy that was, I think the result works really well. But SwiftUI has another trick up its sleeve: we can add an Edit/Done button to the navigation bar, that lets users delete several rows more easily.

First, wrap your VStack in a NavigationView, then add this modifier to the VStack:

.toolbar {
    EditButton()
}




Storing user settings with UserDefaults


Most users pretty much expect apps to store their data so they can create more customized experiences, and as such it’s no surprise that iOS gives us several ways to read and write user data.

One common way to store a small amount of data is called UserDefaults, and it’s great for simple user preferences. There is no specific number attached to “a small amount”, but everything you store in UserDefaults will automatically be loaded when your app launches – if you store a lot in there your app launch will slow down. To give you at least an idea, you should aim to store no more than 512KB in there.

Tip: If you’re thinking “512KB? How much is that?” then let me give you a rough estimate: it’s about as much text as all the chapters you’ve read in this book so far.

UserDefaults is perfect for storing things like when the user last launched the app, which news story they last read, or other passively collected information. Even better, SwiftUI can often wrap up UserDefaults inside a nice and simple property wrapper called @AppStorage – it only supports a subset of functionality right now, but it can be really helpful.
Enough chat – let’s look at some code. Here’s a view with a button that shows a tap count, and increments that count every time the button is tapped:

struct ContentView: View {
    @State private var tapCount = 0

    var body: some View {
        Button("Tap count: \(tapCount)") {
            tapCount += 1
        }
    }
}

As this is clearly A Very Important App, we want to save the number of taps that the user made, so when they come back to the app in the future they can pick up where they left off.

To make that happen, we need to write to UserDefaults inside our button’s action closure. So, add this after the tapCount += 1 line:

UserDefaults.standard.set(self.tapCount, forKey: "Tap")

In just that single line of code you can see three things in action:

1. We need to use UserDefaults.standard. This is the built-in instance of UserDefaults that is attached to our app, but in more advanced apps you can create your own instances. For example, if you want to share defaults across several app extensions you might create your own UserDefaults instance.
2. There is a single set() method that accepts any kind of data – integers, Booleans, strings, and more.
3. We attach a string name to this data, in our case it’s the key “Tap”. This key is case-sensitive, just like regular Swift strings, and it’s important – we need to use the same key to read the data back out of UserDefaults.

Speaking of reading the data back, rather than start with tapCount set to 0 we should instead make it read the value back from UserDefaults like this:

@State private var tapCount = UserDefaults.standard.integer(forKey: "Tap")

Notice how that uses exactly the same key name, which ensures it reads the same integer value.

Go ahead and give the app a try and see what you think – you ought to be able tap the button a few times, go back to Xcode, run the app again, and see the number exactly where you left it.

There are two things you can’t see in that code, but both matter. First, what happens if we don’t have the “Tap” key set? This will be the case the very first time the app is run, but as you just saw it works fine – if the key can’t be found it just sends back 0.

Sometimes having a default value like 0 is helpful, but other times it can be confusing. With Booleans, for example, you get back false if boolean(forKey:) can’t find the key you asked for, but is that false a value you set yourself, or does it mean there was no value at all?

Second, it takes iOS a little time to write your data to permanent storage – to actually save that change to the device. They don’t write updates immediately because you might make several back to back, so instead they wait some time then write out all the changes at once. How much time is another number we don’t know, but a couple of seconds ought to do it.
As a result of this, if you tap the button then quickly relaunch the app from Xcode, you’ll find your most recent tap count wasn’t saved. There used to be a way of forcing updates to be written immediately, but at this point it’s worthless – even if the user immediately started the process of terminating your app after making a choice, your defaults data would be written immediately so nothing will be lost.

Now, I mentioned that SwiftUI provides an @AppStorage property wrapper around UserDefaults, and in simple situations like this one it’s really helpful. What it does is let us effectively ignore UserDefaults entirely, and just use @AppStorage rather than @State, like this:

struct ContentView: View {
    @AppStorage("tapCount") private var tapCount = 0

    var body: some View {
        Button("Tap count: \(tapCount)") {
            tapCount += 1
        }
    }
}

Again, there are three things I want to point out in there:

1. Our access to the UserDefaults system is through the @AppStorage property wrapper. This works like @State: when the value changes, it will reinvoked the body property so our UI reflects the new data.
2. We attach a string name, which is the UserDefaults key where we want to store the data. I’ve used “tapCount”, but it can be anything at all – it doesn’t need to match the property name.
3. The rest of the property is declared as normal, including providing a default value of 0. That will be used if there is existing value saved inside UserDefaults.

Clearly using @AppStorage is easier than UserDefaults: it’s one line of code rather than two, and it also means we don’t have to repeat the key name each time. However, right now at least @AppStorage doesn’t make it easy to handle storing complex objects such as Swift structs – perhaps because Apple wants us to remember that storing lots of data in there is a bad idea!




