class User {
    final int? id;
    final String? name;
    final String? email;
    final String? role;

    User({
        this.id,
        this.name,
        this.email,
        this.role,
    });

    factory User.formJson(Map<String, dynamic> json) {
      return User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
      );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
    };
}