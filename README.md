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




