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


