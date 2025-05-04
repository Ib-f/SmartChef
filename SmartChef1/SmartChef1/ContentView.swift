import SwiftUI
import FirebaseDatabase
import FirebaseAuth

extension Color {
    static let smartChefRed = Color(red: 0.85, green: 0.1, blue: 0.1)
    static let smartChefLightGray = Color(UIColor.systemGray6)
}
struct ContentView: View {
    var body: some View {
        NavigationView {
            SignUpView()
        }
    }
}

struct SignUpView: View {
    @State private var fname: String = ""
    @State private var lname: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    @State private var isAuthenticated: Bool = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("SMARTCHEF")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.bottom, 40)
                
                
                Group {
                    TextField("First Name", text: $fname)
                    TextField("Last Name", text: $lname)
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                
                Button("Sign Up") {
                    authenticateUser()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                
                NavigationLink("Already have an account? Sign in", destination: SignInView())
                    .padding()
                
                
                NavigationLink("", destination: HomeView(), isActive: $isAuthenticated)
            }
            .padding()
        }
    }
    
    
    func authenticateUser() {
        
        guard fname.count >= 3 else {
            errorMessage = "First name must be at least 3 letters."
            return
        }
        guard lname.count >= 4 else {
            errorMessage = "Last name must be at least 4 letters."
            return
        }
        guard isValidUsername(username) else {
            errorMessage = "Username must be 3–10 characters, and include letters and numbers."
            return
        }
        guard isValidEmail(email) else {
            errorMessage = "Email must be from psu, gmail, outlook, hotmail, icloud, or yahoo."
            return
        }
        guard isValidPassword(password) else {
            errorMessage = "Password must be at least 8 characters and contain a number."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
            } else if let user = result?.user {
                let ref = Database.database().reference()
                let userData = [
                    "firstName": fname,
                    "lastName": lname,
                    "username": username,
                    "email": email
                ]
                ref.child("users").child(user.uid).setValue(userData) { error, _ in
                    if let error = error {
                        print("❗ Error saving user data: \(error.localizedDescription)")
                        self.errorMessage = "Failed to save user data."
                    } else {
                        print("✅ User data saved successfully.")
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }
}
struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isAuthenticated: Bool = false


    var body: some View {
        NavigationStack {
            VStack {
                Text("SMARTCHEF")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.bottom, 40)


                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()


                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()


                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }


                Button("Sign In") {
                    signInUser()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)


                NavigationLink("Forgot your password? Reset", destination: ResetPasswordView())
                    .padding()


                NavigationLink("", destination: HomeView(), isActive: $isAuthenticated)
            }
            .padding()
        }
    }


    func signInUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Sign-in failed: \(error.localizedDescription)"
            } else {
                isAuthenticated = true
            }
        }
    }
}
    // MARK: - Home Tab View
    struct HomeView: View {
        var body: some View {
            MainTabView()
        }
    }
    struct MainTabView: View {
        var body: some View {
            TabView {
                CommunityView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Community")
                    }
                ChatGPTPromptView()
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("Create")
                    }
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
            }
        }
    }
// MARK: - Recipe Model

struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String?
    let calories: Int
    let description: String
    let ingredients: String
    let allergies: [String]
    let measurements: String
    let steps: [String]
    let macros: String
}

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showSteps = false
    @State private var successMessage = ""
    @State private var errorMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let imageURL = recipe.imageName, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(height: 200)
                        case .success(let image):
                            image.resizable()
                                 .scaledToFit()
                                 .frame(height: 200)
                                 .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                Text(recipe.title)
                    .font(.title2)
                    .bold()

                Text("\(recipe.calories) kcal")
                    .foregroundColor(.smartChefRed)
                    .font(.headline)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Measurements").font(.headline)
                    Text(recipe.measurements).font(.subheadline)

                    Text("Steps").font(.headline)
                    DisclosureGroup("Show Instructions", isExpanded: $showSteps) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(recipe.steps.indices, id: \.self) { index in
                                Text("\(recipe.steps[index])")
                                    .font(.subheadline)
                            }
                        }.padding(.top, 4)
                    }

                    Text("Macros").font(.headline)
                    Text(recipe.macros).font(.subheadline)

                    if !recipe.allergies.isEmpty {
                        Text("Allergies")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(recipe.allergies.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)

                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Button(action: {
                    saveToFavorites(recipe)
                }) {
                    Text("Add to favorites")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.smartChefRed)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    func saveToFavorites(_ recipe: Recipe) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to save favorites."
            return
        }

        let ref = Database.database().reference()
            .child("users")
            .child(uid)
            .child("favorites")
            .childByAutoId()

        let data: [String: Any] = [
            "title": recipe.title,
            "imageName": recipe.imageName ?? "",
            "calories": recipe.calories,
            "description": recipe.description,
            "ingredients": recipe.ingredients,
            "allergies": recipe.allergies,
            "measurements": recipe.measurements,
            "steps": recipe.steps,
            "macros": recipe.macros,
            "timestamp": Date().timeIntervalSince1970
        ]

        ref.setValue(data) { error, _ in
            if let error = error {
                errorMessage = "❌ Failed: \(error.localizedDescription)"
                successMessage = ""
            } else {
                successMessage = "✅ Recipe added to favorites."
                errorMessage = ""
            }
        }
    }
}



// MARK: - Community View

struct CommunityView: View {
    @State private var showAddRecipe = false
    @State private var communityRecipes: [Recipe] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Community")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.smartChefRed)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddRecipe = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding(8)
                            .background(Color.smartChefRed)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding(.trailing)
                    .sheet(isPresented: $showAddRecipe) {
                        ShareRecipeFromPreviousView()
                    }
                }
                .padding([.top, .leading])
                
                Text("Total \(communityRecipes.count) results")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                if isLoading {
                    ProgressView("Loading...").padding()
                } else if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red).padding()
                } else {
                    CommunityGrid(recipes: communityRecipes)
                }
            }
            .onAppear {
                loadCommunityRecipes()
            }
        }
    }
    func loadCommunityRecipes() {
        isLoading = true
        let ref = Database.database().reference().child("community_recipes")
        ref.observeSingleEvent(of: .value) { snapshot in
            var loadedRecipes: [Recipe] = []
            for child in snapshot.children {
                if let childSnap = child as? DataSnapshot,
                   let data = childSnap.value as? [String: Any],
                   let recipeText = data["recipe"] as? String {
                    let recipe = parseFullRecipeText(recipeText)
                    loadedRecipes.append(recipe)
                }
            }
            self.communityRecipes = loadedRecipes.reversed()
            self.isLoading = false
        } withCancel: { error in
            self.errorMessage = "Failed to load community posts: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    ;func parseFullRecipeText(_ text: String) -> Recipe {
        let lines = text.components(separatedBy: .newlines)
        
        var title = "Community Recipe"
        var description = ""
        var steps: [String] = []
        var macros = ""
        var allergies: [String] = []
        var ingredients = ""
        var calories = 0
        var isInIngredients = false
        var isInInstructions = false
        var isInMacros = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.lowercased().starts(with: "recipe:") {
                title = trimmed.replacingOccurrences(of: "Recipe:", with: "").trimmingCharacters(in: .whitespaces)
                continue
            }

            if trimmed.lowercased().starts(with: "ingredients:") {
                isInIngredients = true
                isInInstructions = false
                isInMacros = false
                continue
            }
            if trimmed.lowercased().starts(with: "instructions:") {
                isInIngredients = false
                isInInstructions = true
                isInMacros = false
                continue
            }
            if trimmed.range(of: #"(?i)macros"#, options: .regularExpression) != nil {
                isInIngredients = false
                isInInstructions = false
                isInMacros = true
                continue
            }
            if isInMacros && trimmed.isEmpty {
                isInMacros = false
                continue
            }
            if trimmed.lowercased().starts(with: "allergies:") {
                allergies = trimmed.replacingOccurrences(of: "Allergies:", with: "")
                    .components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                continue
            }
            if let calMatch = trimmed.range(of: #"(?i)calories:\s*(\d+)"#, options: .regularExpression) {
                let calLine = String(trimmed[calMatch])
                if let value = calLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces),
                   let calInt = Int(value) {
                    calories = calInt
                }
            }
            if isInIngredients {
                ingredients += trimmed + "\n"
            } else if isInInstructions {
                if trimmed.range(of: #"^\d+\."#, options: .regularExpression) != nil {
                    steps.append(trimmed)
                }
            } else if isInMacros {
                macros += trimmed + "\n"
            } else {
                description += trimmed + "\n"
            }
        }

        return Recipe(
            title: title,
            imageName: nil,
            calories: calories,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.trimmingCharacters(in: .whitespacesAndNewlines),
            allergies: allergies,
            measurements: ingredients.trimmingCharacters(in: .whitespacesAndNewlines),
            steps: steps,
            macros: macros.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

// MARK: - Recipe Grid & Cards

struct CommunityGrid: View {
    let recipes: [Recipe]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeCardView(recipe: recipe)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 4)

                VStack(spacing: 10) {
                    if let imageURL = recipe.imageName, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().frame(height: 80)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .foregroundColor(.gray)
                    }

                    Text(recipe.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)

                    Text("\(recipe.calories) kcal")
                        .font(.subheadline)
                        .foregroundColor(.smartChefRed)

                    if !recipe.allergies.isEmpty {
                        Text("Allergies: \(recipe.allergies.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .frame(height: 220)
        }
    }
}

    struct CreateRecipeView: View {
        @State private var navigateToPrompt = false
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Create or View Recipes")
                    .font(.title)
                    .bold()
                    .foregroundColor(.smartChefRed)
                    .padding(.top)
                
                Button(action: {
                    navigateToPrompt = true
                }) {
                    Text("Create New Recipe")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.smartChefRed)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                Button("View Previous Recipes") {
                    // TODO: Navigate to previous recipes view
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.smartChefRed)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToPrompt) {
                ChatGPTPromptView()
            }
        }
    }
    
struct ChatGPTPromptView: View {
    @State private var ingredients: [IngredientEntry] = [IngredientEntry()]
    @State private var generatedRecipe: String = ""
    @State private var isLoading = false
    @State private var dietType: String = "Any"
    @State private var previousRecipes: [String] = []

    let dietOptions = ["Any", "Low Carbs", "High Carbs", "High Protein", "Low Calories", "High Calories"]
    let units = ["g", "ml", "oz", "Pc"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView()
                    IngredientsSection(ingredients: $ingredients, units: units)
                    DietMenu(dietType: $dietType, options: dietOptions)
                    GenerateButton(isLoading: $isLoading, action: generateRecipe)

                    if !generatedRecipe.isEmpty {
                        RecipeOutputView(recipe: generatedRecipe)
                    }

                    NavigationLink(destination: ViewPreviousRecipes()) {
                        Text("View Previous Recipes")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.smartChefRed)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .background(Color.white)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    func generateRecipe() {
        isLoading = true
        let filledIngredients = ingredients.filter { !$0.name.isEmpty }
        let formattedIngredients = filledIngredients
            .map { "\($0.amount) \($0.unit) \($0.name)" }
            .joined(separator: ", ")


        let prompt = """
        Check if all the following are valid cooking ingredients: \(formattedIngredients).


        If **any** ingredient is invalid, reply ONLY with:
        "❌ Invalid ingredient detected: [list invalid items]"


        ❗️Do NOT suggest a recipe or provide any further output if ingredients are invalid.


        If all ingredients are valid, then:
        - Provide a recipe title
        - List ingredients
        - Include numbered instructions
        - List macros (Calories, Proteins, Carbs, Fats)
        """


        ChatGPTService.shared.generateRecipe(prompt: prompt) { response in
            DispatchQueue.main.async {
                if let recipe = response {
                    if recipe.contains("❌ Invalid ingredient detected") {
                        self.generatedRecipe = recipe // Just show the warning
                    } else {
                        self.generatedRecipe = recipe
                        self.previousRecipes.append(recipe)
                        saveRecipeToDatabase(recipe)
                    }
                } else {
                    self.generatedRecipe = "⚠️ Failed to generate recipe. Please try again later."
                }
                self.isLoading = false
            }
        }
    }







    func saveRecipeToDatabase(_ recipe: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
            .child("past_recipes")
            .child(uid)
            .childByAutoId()

        let recipeData: [String: Any] = [
            "recipe": recipe,
            "timestamp": Date().timeIntervalSince1970
        ]

        ref.setValue(recipeData)
    }
}

struct IngredientEntry: Identifiable, Equatable {
    var id = UUID()
    var name: String = ""
    var amount: String = ""
    var unit: String = ""
    var amountError: String = ""
}

struct HeaderView: View {
    var body: some View {
        Text("Create or View Recipes")
            .font(.title)
            .bold()
            .foregroundColor(.smartChefRed)
            .padding(.top)
    }
}

struct IngredientsSection: View {
    @Binding var ingredients: [IngredientEntry]
    let units: [String]

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Ingredients")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Amount")
                    .frame(width: 70)
                Text("Unit")
                    .frame(width: 60)
            }
            .font(.headline)
            .padding(.horizontal)

            ForEach(ingredients.indices, id: \.self) { index in
                HStack(spacing: 10) {
                    TextField("Ingredient", text: $ingredients[index].name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                        .onChange(of: ingredients[index].name) { newValue in
                            ingredients[index].name = newValue.filter { $0.isLetter || $0.isWhitespace }
                            if !newValue.isEmpty && index == ingredients.count - 1 {
                                ingredients.append(IngredientEntry())
                            }
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Amount", text: $ingredients[index].amount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .onChange(of: ingredients[index].amount) { newValue in
                                ingredients[index].amount = newValue.filter { $0.isNumber }
                                if ingredients[index].amount.isEmpty || ingredients[index].amount == "0" {
                                    ingredients[index].amountError = "❗ Enter a valid amount"
                                } else {
                                    ingredients[index].amountError = ""
                                }
                            }

                        if !ingredients[index].amountError.isEmpty {
                            Text(ingredients[index].amountError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    Menu {
                        ForEach(units, id: \.self) { unit in
                            Button(unit) {
                                ingredients[index].unit = unit
                            }
                        }
                    } label: {
                        HStack {
                            Text(ingredients[index].unit.isEmpty ? "Unit" : ingredients[index].unit)
                            Image(systemName: "chevron.down")
                        }
                        .frame(width: 60)
                        .padding(8)
                        .background(Color.smartChefLightGray)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct DietMenu: View {
    @Binding var dietType: String
    let options: [String]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    dietType = option
                }
            }
        } label: {
            HStack {
                Text("Diet: \(dietType)")
                Image(systemName: "chevron.down")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.smartChefLightGray)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct GenerateButton: View {
    @Binding var isLoading: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Generate Recipe!")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLoading ? Color.gray : Color.smartChefRed)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .disabled(isLoading)
    }
}

struct RecipeOutputView: View {
    let recipe: String

    var body: some View {
        ScrollView {
            Text(recipe)
                .padding()
                .background(Color.smartChefLightGray)
                .cornerRadius(12)
                .padding()
        }
    }
}
struct ViewPreviousRecipes: View {
    @State private var recipes: [String] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var successMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Previous Recipes")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.smartChefRed)
                    .padding(.top)

                if isLoading {
                    ProgressView("Loading...").padding()
                } else if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if recipes.isEmpty {
                    Text("No previous recipes yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(recipes, id: \.self) { recipe in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(recipe)
                                .padding()
                                .background(Color.smartChefLightGray)
                                .cornerRadius(12)

                            Button(action: {
                                addToFavorites(recipe)
                            }) {
                                Label("Favorite", systemImage: "heart")
                                    .font(.subheadline)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !successMessage.isEmpty {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.top, 10)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchRecipesFromFirebase()
        }
    }

    func fetchRecipesFromFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            isLoading = false
            return
        }

        let ref = Database.database().reference().child("past_recipes").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            var loadedRecipes: [String] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let recipeText = dict["recipe"] as? String {
                    loadedRecipes.append(recipeText)
                }
            }
            self.recipes = loadedRecipes.reversed()
            self.isLoading = false
        } withCancel: { error in
            self.errorMessage = "Failed to fetch recipes: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    func addToFavorites(_ recipe: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            successMessage = "Login required to favorite."
            return
        }

        let ref = Database.database().reference()
            .child("favored_recipes")
            .child(uid)
            .childByAutoId()

        ref.setValue(["recipe": recipe]) { error, _ in
            if let error = error {
                successMessage = "❌ Failed: \(error.localizedDescription)"
            } else {
                successMessage = "✅ Added to favorites!"
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                successMessage = ""
            }
        }
    }
}

    
struct ProfileView: View {
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = true
    @State private var navigateTo: String? = nil
    @State private var fname : String = ""
    @State private var lname : String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        VStack(spacing: 8) {
                            Spacer().frame(height: 50)
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.smartChefRed)
                            
                            
                            Text("\(fname.uppercased()) \(lname.uppercased())")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.black)
                        }
                        .padding(.top, 20)
                        
                        
                        // Profile Buttons
                        VStack(spacing: 16) {
                            Button { navigateTo = "EditProfile" } label: {
                                ProfileRow(icon: "person", title: "Edit Profile")
                            }
                            
                            
                            Button { navigateTo = "Favorites" } label: {
                                ProfileRow(icon: "heart", title: "Favorites")
                            }
                            
                            
                            Button { navigateTo = "MyPosts" } label: {
                                ProfileRow(icon: "doc.text", title: "My Posts")
                            }
                            
                            
                            Button { navigateTo = "Help" } label: {
                                ProfileRow(icon: "questionmark.circle", title: "Help")
                            }
                        }
                        
                        
                        Spacer().frame(height: 100)
                    }
                }
                
                VStack {
                    Button {
                        isAuthenticated = false
                        navigateTo = "Logout"
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.left")
                                .foregroundColor(.smartChefRed)
                            Text("Log Out")
                                .foregroundColor(.smartChefRed)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.smartChefLightGray)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    NavigationLink(destination: SignInView(), tag: "Logout", selection: $navigateTo) { EmptyView() }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            NavigationLink(destination: EditProfileView(), tag: "EditProfile", selection: $navigateTo) { EmptyView() }
            NavigationLink(destination: FavoritesView(), tag: "Favorites", selection: $navigateTo) { EmptyView() }
            NavigationLink(destination: MyPostsView(), tag: "MyPosts", selection: $navigateTo) { EmptyView() }
            NavigationLink(destination: HelpView(), tag: "Help", selection: $navigateTo) { EmptyView() }
        }
        .onAppear{
            loadUserProfile()
        }
    }
        func loadUserProfile() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let ref = Database.database().reference().child("users").child(uid)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: Any] {
                    fname = data["firstName"] as? String ?? ""
                    lname = data["lastName"] as? String ?? ""
                }
            }
    }
}

// MARK: - Profile Row UI
struct ProfileRow: View {
    var icon: String
    var title: String


    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.smartChefRed)
                .frame(width: 24, height: 24)
            Text(title)
                .foregroundColor(.black)
            Spacer()
        }
        .padding()
        .background(Color.smartChefLightGray)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Placeholder Views


 struct EditProfileView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Profile")
                .font(.largeTitle)
                .bold()

            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Save Changes") {
                saveProfileChanges()
            }
            .padding()
            .background(Color.smartChefRed)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .onAppear {
            loadUserData()
        }
    }

    // MARK: - Validation
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8 && password.rangeOfCharacter(from: .decimalDigits) != nil
    }

    // MARK: - Load Profile Data
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                firstName = data["firstName"] as? String ?? ""
                lastName = data["lastName"] as? String ?? ""
            }
        }
    }

    // MARK: - Save Profile Changes
    func saveProfileChanges() {
        errorMessage = ""
        successMessage = ""
        if !newPassword.isEmpty || !confirmPassword.isEmpty {
            if newPassword != confirmPassword {
                errorMessage = "Passwords do not match."
                return
            }
            if !isValidPassword(newPassword) {
                errorMessage = "Password must be at least 8 characters and include a number."
                return
            }
            updatePassword()
        }

        updateUserProfile()
    }

    // MARK: - Update Name Fields in Firebase
    func updateUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            return
        }

        let ref = Database.database().reference().child("users").child(uid)
        let updates = [
            "firstName": firstName,
            "lastName": lastName
        ]

        ref.updateChildValues(updates) { error, _ in
            if let error = error {
                errorMessage = "Update failed: \(error.localizedDescription)"
            } else {
                successMessage = "Profile updated successfully!"
            }
        }
    }

    // MARK: - Update Password with FirebaseAuth
    func updatePassword() {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                errorMessage = "Password update failed: \(error.localizedDescription)"
            } else {
                successMessage = "Password updated successfully!"
            }
        }
    }
}
struct FavoritesView: View {
    @State private var recipes: [(id: String, recipe: Recipe)] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var isSelectionMode = false
    @State private var selectedIDs: Set<String> = []


    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading favorites...").padding()
                } else if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if recipes.isEmpty {
                    Text("No favorite recipes.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(recipes, id: \.id) { item in
                                HStack(alignment: .top) {
                                    if isSelectionMode {
                                        Image(systemName: selectedIDs.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.smartChefRed)
                                            .onTapGesture {
                                                toggleSelection(for: item.id)
                                            }
                                    }


                                    NavigationLink(destination: RecipeDetailView(recipe: item.recipe)) {
                                        RecipeCardView(recipe: item.recipe)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }


                if isSelectionMode && !selectedIDs.isEmpty {
                    Button(role: .destructive) {
                        deleteSelectedFavorites()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .transition(.opacity)
                }
            }
            .padding(.top)
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            isSelectionMode.toggle()
                            selectedIDs.removeAll()
                        }
                    }) {
                        Image(systemName: isSelectionMode ? "xmark.circle" : "trash")
                            .foregroundColor(.smartChefRed)
                    }
                }
            }
            .onAppear {
                fetchFavorites()
            }
        }
    }


    // MARK: - Load from Firebase
    func fetchFavorites() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated."
            self.isLoading = false
            return
        }


        let ref = Database.database().reference().child("users").child(uid).child("favorites")
        ref.observeSingleEvent(of: .value) { snapshot in
            var loaded: [(id: String, recipe: Recipe)] = []


            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let title = dict["title"] as? String,
                   let calories = dict["calories"] as? Int,
                   let description = dict["description"] as? String,
                   let ingredients = dict["ingredients"] as? String,
                   let measurements = dict["measurements"] as? String,
                   let steps = dict["steps"] as? [String],
                   let macros = dict["macros"] as? String {
                    
                    let allergies = dict["allergies"] as? [String] ?? []
                    let imageName = dict["imageName"] as? String


                    let recipe = Recipe(
                        title: title,
                        imageName: imageName,
                        calories: calories,
                        description: description,
                        ingredients: ingredients,
                        allergies: allergies,
                        measurements: measurements,
                        steps: steps,
                        macros: macros
                    )
                    loaded.append((id: snap.key, recipe: recipe))
                }
            }
            self.recipes = loaded.reversed()
            self.isLoading = false
        } withCancel: { error in
            self.errorMessage = "Failed to load favorites: \(error.localizedDescription)"
            self.isLoading = false
        }
    }


    // MARK: - Selection
    func toggleSelection(for id: String) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }


    // MARK: - Delete
    func deleteSelectedFavorites() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid).child("favorites")


        for id in selectedIDs {
            ref.child(id).removeValue()
        }


        recipes.removeAll { selectedIDs.contains($0.id) }
        selectedIDs.removeAll()
        isSelectionMode = false
    }
}


struct MyPostsView: View {
    @State private var posts: [(id: String, recipe: String)] = []
    @State private var selectedPosts: Set<String> = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var isSelecting = false

    var body: some View {
        VStack {
            HStack {
                Text("Your Shared Posts")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.smartChefRed)
                Spacer()
                if !posts.isEmpty {
                    Button(action: {
                        isSelecting.toggle()
                        selectedPosts.removeAll()
                    }) {
                        Text(isSelecting ? "Cancel" : "Select")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding([.horizontal, .top])

            if isSelecting && !selectedPosts.isEmpty {
                Button(action: deleteSelectedPosts) {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if posts.isEmpty {
                Text("You haven't shared any recipes yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    ForEach(posts, id: \.id) { post in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(post.recipe)
                                    .padding()
                                    .background(Color.smartChefLightGray)
                                    .cornerRadius(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if isSelecting {
                                Button(action: {
                                    toggleSelection(post.id)
                                }) {
                                    Image(systemName: selectedPosts.contains(post.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedPosts.contains(post.id) ? .red : .gray)
                                        .padding(.top, 12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            Spacer()
        }
        .onAppear(perform: fetchMyPosts)
    }

    func fetchMyPosts() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            isLoading = false
            return
        }

        let ref = Database.database().reference().child("users").child(uid).child("myPosts")
        ref.observeSingleEvent(of: .value) { snapshot in
            var loadedPosts: [(id: String, recipe: String)] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let recipe = dict["recipe"] as? String {
                    loadedPosts.append((id: snap.key, recipe: recipe))
                }
            }

            self.posts = loadedPosts.reversed()
            self.isLoading = false
        } withCancel: { error in
            self.errorMessage = "Failed to fetch posts: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    func toggleSelection(_ id: String) {
        if selectedPosts.contains(id) {
            selectedPosts.remove(id)
        } else {
            selectedPosts.insert(id)
        }
    }

 func deleteSelectedPosts() {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let userRef = Database.database().reference().child("users").child(uid).child("myPosts")
    let communityRef = Database.database().reference().child("community_recipes")

    for id in selectedPosts {
    
        if let recipeText = posts.first(where: { $0.id == id })?.recipe {
            
            userRef.child(id).removeValue()

            communityRef.observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let dict = snap.value as? [String: Any],
                       let recipe = dict["recipe"] as? String,
                       recipe == recipeText {
                        communityRef.child(snap.key).removeValue()
                    }
                }
            }
        }
    }

    posts.removeAll { selectedPosts.contains($0.id) }
    selectedPosts.removeAll()
    isSelecting = false
}


}



struct HelpView: View {
    var body: some View {
        VStack {
            Spacer ()
            Text("Tech support: help@smartchef.com")
                .multilineTextAlignment(.center)
                .font(.title2)
                .foregroundColor(.gray)
                .padding()
            Spacer()
        }
    }
}

    
struct ResetPasswordView: View {
    @State private var email = ""
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Your Password")
                .font(.title)
                .bold()
                .foregroundColor(.smartChefRed)

            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Send Reset Email") {
                sendPasswordReset()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.smartChefRed)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    func sendPasswordReset() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "❌ Error: \(error.localizedDescription)"
            } else {
                message = "✅ Password reset email sent. Please check your inbox."
            }
        }
    }
}


func isValidEmail(_ email: String) -> Bool {
    let allowedDomains = ["gmail.com", "outlook.com", "hotmail.com", "icloud.com", "yahoo.com", "psu.edu.sa"]
    guard let domain = email.split(separator: "@").last else { return false }
    return allowedDomains.contains(String(domain))
}
func isValidPassword(_ password: String) -> Bool {
    return password.count >= 8 && password.rangeOfCharacter(from: .decimalDigits) != nil
}
func isValidUsername(_ username: String) -> Bool {
    let regex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{3,10}$"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
}


struct ShareRecipeFromPreviousView: View {
    @Environment(\.dismiss) var dismiss
    @State private var previousRecipes: [(id: String, text: String)] = []
    @State private var isLoading = true
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select Recipe to Share")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                if isLoading {
                    ProgressView("Loading recipes...")
                        .padding()
                } else if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if previousRecipes.isEmpty {
                    Text("No recipes to share.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(previousRecipes, id: \.id) { recipe in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(recipe.text)
                                    .padding()
                                    .background(Color.smartChefLightGray)
                                    .cornerRadius(12)

                                Button("Post to Community") {
                                    postToCommunity(recipeText: recipe.text)
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.smartChefRed)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                fetchPreviousRecipes()
            }
        }
    }

    func fetchPreviousRecipes() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            isLoading = false
            return
        }

        let ref = Database.database().reference().child("past_recipes").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            var loaded: [(id: String, text: String)] = []
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let recipeText = dict["recipe"] as? String {
                    loaded.append((id: snap.key, text: recipeText))
                }
            }
            self.previousRecipes = loaded.reversed()
            self.isLoading = false
        } withCancel: { error in
            self.errorMessage = "Failed to load recipes: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    func postToCommunity(recipeText: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        let postId = ref.child("community_recipes").childByAutoId().key ?? UUID().uuidString

        let recipeData = [
            "recipe": recipeText,
            "userId": uid,
            "timestamp": Date().timeIntervalSince1970
        ] as [String: Any]

        // Save to community
        ref.child("community_recipes").child(postId).setValue(recipeData)

        ref.child("users").child(uid).child("myPosts").child(postId).setValue(recipeData)

        dismiss()
    }
}

    // MARK: - Preview
    #Preview {
        ContentView()
    }

    
