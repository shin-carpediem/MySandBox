import SwiftUI

struct FormView: View {
    @State var email: String
    @State var password: String

    var body: some View {
        VStack {
            EmailTextField(email: $email, onChange: { _ in })
            EmailTextField(email: $password, onChange: { _ in })
        }
    }
}

struct EmailTextField: View {
    @Binding var email: String
    let onChange: (String) -> Void

    var body: some View {
        TextField("", text: $email)
            .onChange(of: email) { oldValue, newValue in
                onChange(newValue)
            }
    }
}
struct PasswordTextField: View {
    @Binding var password: String
    let onChange: (String) -> Void

    var body: some View {
        TextField("", text: $password)
            .onChange(of: password) { oldValue, newValue in
                onChange(newValue)
            }
    }
}
