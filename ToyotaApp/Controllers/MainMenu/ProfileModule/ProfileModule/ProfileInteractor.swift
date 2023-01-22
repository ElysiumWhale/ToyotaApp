import Foundation

final class ProfileInteractor {
    private let service: PersonalInfoService
    private let updateUserHandler = DefaultRequestHandler()

    private var changedPerson: Person?

    let user: UserProxy

    var profile: Person {
        user.person
    }

    var onUserUpdateFailure: ParameterClosure<String>?

    init(user: UserProxy, service: PersonalInfoService = InfoService()) {
        self.user = user
        self.service = service

        setupRequestHandlers()
    }

    func updateProfile(_ person: Person) {
        changedPerson = person

        service.updateProfile(
            with: EditProfileBody.from(person, userId: user.id),
            updateUserHandler
        )
    }

    private func setupRequestHandlers() {
        updateUserHandler
            .observe(on: .main)
            .bind { [weak self] _ in
                self?.handlePersonUpdateSuccess()
            } onFailure: { [weak self] error in
                self?.onUserUpdateFailure?(error.message ?? .error(.savingError))
            }
    }

    private func handlePersonUpdateSuccess() {
        guard let changedPerson = changedPerson else {
            return
        }

        self.changedPerson = nil
        user.updatePerson(from: changedPerson)
    }
}

private extension EditProfileBody {
    static func from(_ person: Person, userId: String) -> Self {
        EditProfileBody(
            brandId: Brand.Toyota,
            userId: userId,
            firstName: person.firstName,
            secondName: person.secondName,
            lastName: person.lastName,
            email: person.email,
            birthday: person.birthday
        )
    }
}
